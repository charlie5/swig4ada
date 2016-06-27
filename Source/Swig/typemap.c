/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * typemap.c
 *
 * A somewhat generalized implementation of SWIG1.1 typemaps.
 * ----------------------------------------------------------------------------- */

char cvsroot_typemap_c[] = "$Id: typemap.c 961 2009-03-03 14:54:44Z krischik $";

#include "swig.h"
#include "cparse.h"
#include <ctype.h>

#if 0
#define SWIG_DEBUG
#endif

static void replace_embedded_typemap(String *s);

/* -----------------------------------------------------------------------------
 * Typemaps are stored in a collection of nested hash tables.  Something like
 * this:
 *
 * [ type ]
 *    +-------- [ name ]
 *    +-------- [ name ]
 *    
 * Each hash table [ type ] or [ name ] then contains references to the
 * different typemap methods.    These are referenced by names such as
 * "tmap:in", "tmap:out", "tmap:argout", and so forth.
 *
 * The object corresponding to a specific method has the following
 * attributes:
 *
 *    "type"    -  Typemap type
 *    "pname"   -  Parameter name
 *    "code"    -  Typemap code
 *    "typemap" -  Descriptive text describing the actual map
 *    "locals"  -  Local variables (if any)
 * 
 * ----------------------------------------------------------------------------- */

#define MAX_SCOPE  32


static Hash *typemaps[MAX_SCOPE];
static int tm_scope = 0;

static Hash *get_typemap(int tm_scope, SwigType *type) {
  Hash *tm = 0;
  SwigType *dtype = 0;
  if (SwigType_istemplate(type)) {
    String *ty = Swig_symbol_template_deftype(type, 0);
    dtype = Swig_symbol_type_qualify(ty, 0);
    /* Printf(stderr,"gettm %s %s\n", type, dtype); */
    type = dtype;
    Delete(ty);
  }
  tm = Getattr(typemaps[tm_scope], type);


  if (dtype) {
    if (!tm) {
      String *t_name = SwigType_templateprefix(type);
      if (!Equal(t_name, type)) {
	tm = Getattr(typemaps[tm_scope], t_name);
      }
      Delete(t_name);
    }
    Delete(dtype);
  }

  return tm;
}

static void set_typemap(int tm_scope, SwigType *type, Hash *tm) {
  SwigType *dtype = 0;
  if (SwigType_istemplate(type)) {
    String *ty = Swig_symbol_template_deftype(type, 0);
    dtype = Swig_symbol_type_qualify(ty, 0);
    /* Printf(stderr,"settm %s %s\n", type, dtype); */
    type = dtype;
    Delete(ty);
  } else {
    dtype = Copy(type);
    type = dtype;
  }
  Setattr(typemaps[tm_scope], type, tm);
  Delete(dtype);
}


/* -----------------------------------------------------------------------------
 * Swig_typemap_init()
 *
 * Initialize the typemap system
 * ----------------------------------------------------------------------------- */

void Swig_typemap_init() {
  int i;
  for (i = 0; i < MAX_SCOPE; i++) {
    typemaps[i] = 0;
  }
  typemaps[0] = NewHash();
  tm_scope = 0;
}

static String *tmop_name(const String_or_char *op) {
  static Hash *names = 0;
  String *s;
  /* Due to "interesting" object-identity semantics of DOH,
     we have to make sure that we only intern strings without object
     identity into the hash table.

     (Swig_typemap_attach_kwargs calls tmop_name several times with
     the "same" String *op (i.e., same object identity) but differing
     string values.)

     Most other callers work around this by using char* rather than
     String *.
     -- mkoeppe, Jun 17, 2003
   */
  const char *op_without_object_identity = Char(op);
  if (!names)
    names = NewHash();
  s = Getattr(names, op_without_object_identity);
  if (s)
    return s;
  s = NewStringf("tmap:%s", op);
  Setattr(names, op_without_object_identity, s);
  Delete(s);
  return s;
}

/* -----------------------------------------------------------------------------
 * Swig_typemap_new_scope()
 * 
 * Create a new typemap scope
 * ----------------------------------------------------------------------------- */

void Swig_typemap_new_scope() {
  tm_scope++;
  typemaps[tm_scope] = NewHash();
}

/* -----------------------------------------------------------------------------
 * Swig_typemap_pop_scope()
 *
 * Pop the last typemap scope off
 * ----------------------------------------------------------------------------- */

Hash *Swig_typemap_pop_scope() {
  if (tm_scope > 0) {
    return typemaps[tm_scope--];
  }
  return 0;
}

/* ----------------------------------------------------------------------------- 
 * Swig_typemap_register()
 *
 * Add a new multi-valued typemap
 * ----------------------------------------------------------------------------- */

void Swig_typemap_register(const String_or_char *op, ParmList *parms, String_or_char *code, ParmList *locals, ParmList *kwargs) {
  Hash *tm;
  Hash *tm1;
  Hash *tm2;
  Parm *np;
  String *tmop;
  SwigType *type;
  String *pname;

  if (!parms)
    return;
  tmop = tmop_name(op);

  /* Register the first type in the parameter list */

  type = Getattr(parms, "type");
  pname = Getattr(parms, "name");

  /* See if this type has been seen before */
  tm = get_typemap(tm_scope, type);
  if (!tm) {
    tm = NewHash();
    set_typemap(tm_scope, type, tm);
    Delete(tm);
  }
  if (pname) {
    /* See if parameter has been seen before */
    tm1 = Getattr(tm, pname);
    if (!tm1) {
      tm1 = NewHash();
      Setattr(tm, pname, tm1);
      Delete(tm1);
    }
    tm = tm1;
  }

  /* Now see if this typemap op has been seen before */
  tm2 = Getattr(tm, tmop);
  if (!tm2) {
    tm2 = NewHash();
    Setattr(tm, tmop, tm2);
    Delete(tm2);
  }

  /* For a multi-valued typemap, the typemap code and information
     is really only stored in the last argument.  However, to
     make this work, we perform a really neat trick using
     the typemap operator name.

     For example, consider this typemap

     %typemap(in) (int foo, int *bar, char *blah[]) {
     ...
     }

     To store it, we look at typemaps for the following:

     operator                  type-name
     ----------------------------------------------
     "in"                      int foo
     "in-int+foo:"             int *bar
     "in-int+foo:-p.int+bar:   char *blah[]

     Notice how the operator expands to encode information about
     previous arguments.        

   */

  np = nextSibling(parms);
  if (np) {
    /* Make an entirely new operator key */
    String *newop = NewStringf("%s-%s+%s:", op, type, pname);
    /* Now reregister on the remaining arguments */
    Swig_typemap_register(newop, np, code, locals, kwargs);

    /*    Setattr(tm2,newop,newop); */
    Delete(newop);
  } else {
    String *str = SwigType_str(type, pname);
    String *typemap = NewStringf("typemap(%s) %s", op, str);
    ParmList *clocals = CopyParmList(locals);
    ParmList *ckwargs = CopyParmList(kwargs);

    Setattr(tm2, "code", code);
    Setattr(tm2, "type", type);
    Setattr(tm2, "typemap", typemap);
    if (pname) {
      Setattr(tm2, "pname", pname);
    }
    Setattr(tm2, "locals", clocals);
    Setattr(tm2, "kwargs", ckwargs);

    Delete(clocals);
    Delete(ckwargs);

    Delete(str);
    Delete(typemap);
  }
}

/* -----------------------------------------------------------------------------
 * Swig_typemap_get()
 *
 * Retrieve typemap information from current scope.
 * ----------------------------------------------------------------------------- */

static Hash *Swig_typemap_get(SwigType *type, String_or_char *name, int scope) {
  Hash *tm, *tm1;
  /* See if this type has been seen before */
  if ((scope < 0) || (scope > tm_scope))
    return 0;
  tm = get_typemap(scope, type);
  if (!tm) {
    return 0;
  }
  if ((name) && Len(name)) {
    tm1 = Getattr(tm, name);
    return tm1;
  }
  return tm;
}

/* -----------------------------------------------------------------------------
 * Swig_typemap_copy()
 *
 * Copy a typemap
 * ----------------------------------------------------------------------------- */

int Swig_typemap_copy(const String_or_char *op, ParmList *srcparms, ParmList *parms) {
  Hash *tm = 0;
  String *tmop;
  Parm *p;
  String *pname;
  SwigType *ptype;
  int ts = tm_scope;
  String *tmops, *newop;
  if (ParmList_len(parms) != ParmList_len(srcparms))
    return -1;

  tmop = tmop_name(op);
  while (ts >= 0) {
    p = srcparms;
    tmops = NewString(tmop);
    while (p) {
      ptype = Getattr(p, "type");
      pname = Getattr(p, "name");

      /* Lookup the type */
      tm = Swig_typemap_get(ptype, pname, ts);
      if (!tm)
	break;

      tm = Getattr(tm, tmops);
      if (!tm)
	break;

      /* Got a match.  Look for next typemap */
      newop = NewStringf("%s-%s+%s:", tmops, ptype, pname);
      Delete(tmops);
      tmops = newop;
      p = nextSibling(p);
    }
    Delete(tmops);

    if (!p && tm) {

      /* Got some kind of match */
      Swig_typemap_register(op, parms, Getattr(tm, "code"), Getattr(tm, "locals"), Getattr(tm, "kwargs"));
      return 0;
    }
    ts--;
  }
  /* Not found */
  return -1;

}

/* -----------------------------------------------------------------------------
 * Swig_typemap_clear()
 *
 * Delete a multi-valued typemap
 * ----------------------------------------------------------------------------- */

void Swig_typemap_clear(const String_or_char *op, ParmList *parms) {
  SwigType *type;
  String *name;
  Parm *p;
  String *newop;
  Hash *tm = 0;

  /* This might not work */
  newop = NewString(op);
  p = parms;
  while (p) {
    type = Getattr(p, "type");
    name = Getattr(p, "name");
    tm = Swig_typemap_get(type, name, tm_scope);
    if (!tm)
      return;
    p = nextSibling(p);
    if (p)
      Printf(newop, "-%s+%s:", type, name);
  }
  if (tm) {
    tm = Getattr(tm, tmop_name(newop));
    if (tm) {
      Delattr(tm, "code");
      Delattr(tm, "locals");
      Delattr(tm, "kwargs");
    }
  }
  Delete(newop);
}

/* -----------------------------------------------------------------------------
 * Swig_typemap_apply()
 *
 * Multi-argument %apply directive.  This is pretty horrible so I sure hope
 * it works.
 * ----------------------------------------------------------------------------- */

static
int count_args(String *s) {
  /* Count up number of arguments */
  int na = 0;
  char *c = Char(s);
  while (*c) {
    if (*c == '+')
      na++;
    c++;
  }
  return na;
}

int Swig_typemap_apply(ParmList *src, ParmList *dest) {
  String *ssig, *dsig;
  Parm *p, *np, *lastp, *dp, *lastdp = 0;
  int narg = 0;
  int ts = tm_scope;
  SwigType *type = 0, *name;
  Hash *tm, *sm;
  int match = 0;

  /*  Printf(stdout,"apply : %s --> %s\n", ParmList_str(src), ParmList_str(dest)); */

  /* Create type signature of source */
  ssig = NewStringEmpty();
  dsig = NewStringEmpty();
  p = src;
  dp = dest;
  lastp = 0;
  while (p) {
    lastp = p;
    lastdp = dp;
    np = nextSibling(p);
    if (np) {
      Printf(ssig, "-%s+%s:", Getattr(p, "type"), Getattr(p, "name"));
      Printf(dsig, "-%s+%s:", Getattr(dp, "type"), Getattr(dp, "name"));
      narg++;
    }
    p = np;
    dp = nextSibling(dp);
  }

  /* make sure a typemap node exists for the last destination node */
  type = Getattr(lastdp, "type");
  tm = get_typemap(tm_scope, type);
  if (!tm) {
    tm = NewHash();
    set_typemap(tm_scope, type, tm);
    Delete(tm);
  }
  name = Getattr(lastdp, "name");
  if (name) {
    Hash *tm1 = Getattr(tm, name);
    if (!tm1) {
      tm1 = NewHash();
      Setattr(tm, NewString(name), tm1);
      Delete(tm1);
    }
    tm = tm1;
  }

  /* This is a little nasty.  We need to go searching for all possible typemaps in the
     source and apply them to the target */

  type = Getattr(lastp, "type");
  name = Getattr(lastp, "name");

  while (ts >= 0) {

    /* See if there is a matching typemap in this scope */
    sm = Swig_typemap_get(type, name, ts);

    /* if there is not matching, look for a typemap in the
       original typedef, if any, like in:

       typedef unsigned long size_t;
       ...
       %apply(size_t) {my_size};  ==>  %apply(unsigned long) {my_size};
     */
    if (!sm) {
      SwigType *ntype = SwigType_typedef_resolve(type);
      if (ntype && (Cmp(ntype, type) != 0)) {
	sm = Swig_typemap_get(ntype, name, ts);
      }
      Delete(ntype);
    }

    if (sm) {
      /* Got a typemap.  Need to only merge attributes for methods that match our signature */
      Iterator ki;
      match = 1;
      for (ki = First(sm); ki.key; ki = Next(ki)) {
	/* Check for a signature match with the source signature */
	if ((count_args(ki.key) == narg) && (Strstr(ki.key, ssig))) {
	  String *oldm;
	  /* A typemap we have to copy */
	  String *nkey = Copy(ki.key);
	  Replace(nkey, ssig, dsig, DOH_REPLACE_ANY);

	  /* Make sure the typemap doesn't already exist in the target map */

	  oldm = Getattr(tm, nkey);
	  if (!oldm || (!Getattr(tm, "code"))) {
	    String *code;
	    ParmList *locals;
	    ParmList *kwargs;
	    Hash *sm1 = ki.item;

	    code = Getattr(sm1, "code");
	    locals = Getattr(sm1, "locals");
	    kwargs = Getattr(sm1, "kwargs");
	    if (code) {
	      Replace(nkey, dsig, "", DOH_REPLACE_ANY);
	      Replace(nkey, "tmap:", "", DOH_REPLACE_ANY);
	      Swig_typemap_register(nkey, dest, code, locals, kwargs);
	    }
	  }
	  Delete(nkey);
	}
      }
    }
    ts--;
  }
  Delete(ssig);
  Delete(dsig);
  return match;
}

/* -----------------------------------------------------------------------------
 * Swig_typemap_clear_apply()
 *
 * %clear directive.   Clears all typemaps for a type (in the current scope only).    
 * ----------------------------------------------------------------------------- */

/* Multi-argument %clear directive */
void Swig_typemap_clear_apply(Parm *parms) {
  String *tsig;
  Parm *p, *np, *lastp;
  int narg = 0;
  Hash *tm;
  String *name;

  /* Create a type signature of the parameters */
  tsig = NewStringEmpty();
  p = parms;
  lastp = 0;
  while (p) {
    lastp = p;
    np = nextSibling(p);
    if (np) {
      Printf(tsig, "-%s+%s:", Getattr(p, "type"), Getattr(p, "name"));
      narg++;
    }
    p = np;
  }
  tm = get_typemap(tm_scope, Getattr(lastp, "type"));
  if (!tm) {
    Delete(tsig);
    return;
  }
  name = Getattr(lastp, "name");
  if (name) {
    tm = Getattr(tm, name);
  }
  if (tm) {
    /* Clear typemaps that match our signature */
    Iterator ki, ki2;
    char *ctsig = Char(tsig);
    for (ki = First(tm); ki.key; ki = Next(ki)) {
      char *ckey = Char(ki.key);
      if (strncmp(ckey, "tmap:", 5) == 0) {
	int na = count_args(ki.key);
	if ((na == narg) && strstr(ckey, ctsig)) {
	  Hash *h = ki.item;
	  for (ki2 = First(h); ki2.key; ki2 = Next(ki2)) {
	    Delattr(h, ki2.key);
	  }
	}
      }
    }
  }
  Delete(tsig);
}

/* Internal function to strip array dimensions. */
static SwigType *strip_arrays(SwigType *type) {
  SwigType *t;
  int ndim;
  int i;
  t = Copy(type);
  ndim = SwigType_array_ndim(t);
  for (i = 0; i < ndim; i++) {
    SwigType_array_setdim(t, i, "ANY");
  }
  return t;
}

/* -----------------------------------------------------------------------------
 * Swig_typemap_search()
 *
 * Search for a typemap match.    Tries to find the most specific typemap
 * that includes a 'code' attribute.
 * ----------------------------------------------------------------------------- */

Hash *Swig_typemap_search(const String_or_char *op, SwigType *type, const String_or_char *name, SwigType **matchtype) {
  Hash *result = 0, *tm, *tm1, *tma;
  Hash *backup = 0;
  SwigType *noarrays = 0;
  SwigType *primitive = 0;
  SwigType *ctype = 0;
  int ts;
  int isarray;
  const String *cname = 0;
  SwigType *unstripped = 0;
  String *tmop = tmop_name(op);

  if ((name) && Len(name))
    cname = name;
  ts = tm_scope;

  while (ts >= 0) {
    ctype = type;
    while (ctype) {
      /* Try to get an exact type-match */
      tm = get_typemap(ts, ctype);
      if (tm && cname) {
	tm1 = Getattr(tm, cname);
	if (tm1) {
	  result = Getattr(tm1, tmop);	/* See if there is a type-name match */
	  if (result && Getattr(result, "code"))
	    goto ret_result;
	  if (result)
	    backup = result;
	}
      }
      if (tm) {
	result = Getattr(tm, tmop);	/* See if there is simply a type match */
	if (result && Getattr(result, "code"))
	  goto ret_result;
	if (result)
	  backup = result;
      }
      isarray = SwigType_isarray(ctype);
      if (isarray) {
	/* If working with arrays, strip away all of the dimensions and replace with "ANY".
	   See if that generates a match */
	if (!noarrays) {
	  noarrays = strip_arrays(ctype);
	}
	tma = get_typemap(ts, noarrays);
	if (tma && cname) {
	  tm1 = Getattr(tma, cname);
	  if (tm1) {
	    result = Getattr(tm1, tmop);	/* type-name match */
	    if (result && Getattr(result, "code"))
	      goto ret_result;
	    if (result)
	      backup = result;
	  }
	}
	if (tma) {
	  result = Getattr(tma, tmop);	/* type match */
	  if (result && Getattr(result, "code"))
	    goto ret_result;
	  if (result)
	    backup = result;
	}
	Delete(noarrays);
	noarrays = 0;
      }

      /* No match so far.   If the type is unstripped, we'll strip its
         qualifiers and check.   Otherwise, we'll try to resolve a typedef */

      if (!unstripped) {
	unstripped = ctype;
	ctype = SwigType_strip_qualifiers(ctype);
	if (!Equal(ctype, unstripped))
	  continue;		/* Types are different */
	Delete(ctype);
	ctype = unstripped;
	unstripped = 0;
      }
      {
	String *octype;
	if (unstripped) {
	  Delete(ctype);
	  ctype = unstripped;
	  unstripped = 0;
	}
	octype = ctype;
	ctype = SwigType_typedef_resolve(ctype);
	if (octype != type)
	  Delete(octype);
      }
    }

    /* Hmmm. Well, no match seems to be found at all. See if there is some kind of default mapping */

    primitive = SwigType_default(type);
    while (primitive) {
      tm = get_typemap(ts, primitive);
      if (tm && cname) {
	tm1 = Getattr(tm, cname);
	if (tm1) {
	  result = Getattr(tm1, tmop);	/* See if there is a type-name match */
	  if (result)
	    goto ret_result;
	}
      }
      if (tm) {			/* See if there is simply a type match */
	result = Getattr(tm, tmop);
	if (result)
	  goto ret_result;
      }
      {
	SwigType *nprim = SwigType_default(primitive);
	Delete(primitive);
	primitive = nprim;
      }
    }
    if (ctype != type) {
      Delete(ctype);
      ctype = 0;
    }
    ts--;			/* Hmmm. Nothing found in this scope.  Guess we'll go try another scope */
  }
  result = backup;

ret_result:
  if (noarrays)
    Delete(noarrays);
  if (primitive)
    Delete(primitive);
  if ((unstripped) && (unstripped != type))
    Delete(unstripped);
  if (matchtype) {
    *matchtype = Copy(ctype);
  }
  if (type != ctype)
    Delete(ctype);
  return result;
}


/* -----------------------------------------------------------------------------
 * Swig_typemap_search_multi()
 *
 * Search for a multi-valued typemap.
 * ----------------------------------------------------------------------------- */

Hash *Swig_typemap_search_multi(const String_or_char *op, ParmList *parms, int *nmatch) {
  SwigType *type;
  SwigType *mtype = 0;
  String *name;
  String *newop;
  Hash *tm, *tm1;

  if (!parms) {
    *nmatch = 0;
    return 0;
  }
  type = Getattr(parms, "type");
  name = Getattr(parms, "name");

  /* Try to find a match on the first type */
  tm = Swig_typemap_search(op, type, name, &mtype);
  if (tm) {
    if (mtype && SwigType_isarray(mtype)) {
      Setattr(parms, "tmap:match", mtype);
    }
    Delete(mtype);
    newop = NewStringf("%s-%s+%s:", op, type, name);
    tm1 = Swig_typemap_search_multi(newop, nextSibling(parms), nmatch);
    if (tm1)
      tm = tm1;
    if (Getattr(tm, "code")) {
      *(nmatch) = *nmatch + 1;
    } else {
      tm = 0;
    }
    Delete(newop);
  }
  return tm;
}


/* -----------------------------------------------------------------------------
 * typemap_replace_vars()
 *
 * Replaces typemap variables on a string.  index is the $n variable.
 * type and pname are the type and parameter name.
 * ----------------------------------------------------------------------------- */

static
void replace_local_types(ParmList *p, const String *name, const String *rep) {
  SwigType *t;
  while (p) {
    t = Getattr(p, "type");
    Replace(t, name, rep, DOH_REPLACE_ANY);
    p = nextSibling(p);
  }
}

static
int check_locals(ParmList *p, const char *s) {
  while (p) {
    char *c = GetChar(p, "type");
    if (strstr(c, s))
      return 1;
    p = nextSibling(p);
  }
  return 0;
}

static
int typemap_replace_vars(String *s, ParmList *locals, SwigType *type, SwigType *rtype, String *pname, String *lname, int index) {
  char var[512];
  char *varname;
  SwigType *ftype;
  int bare_substitution_count = 0;

  Replaceall(s, "$typemap", "$TYPEMAP");

  ftype = SwigType_typedef_resolve_all(type);

  if (!pname)
    pname = lname;
  {
    Parm *p;
    int rep = 0;
    p = locals;
    while (p) {
      if (Strchr(Getattr(p, "type"), '$'))
	rep = 1;
      p = nextSibling(p);
    }
    if (!rep)
      locals = 0;
  }

  sprintf(var, "$%d_", index);
  varname = &var[strlen(var)];

  /* If the original datatype was an array. We're going to go through and substitute
     its array dimensions */

  if (SwigType_isarray(type) || SwigType_isarray(ftype)) {
    String *size;
    int ndim;
    int i;
    if (SwigType_array_ndim(type) != SwigType_array_ndim(ftype))
      type = ftype;
    ndim = SwigType_array_ndim(type);
    size = NewStringEmpty();
    for (i = 0; i < ndim; i++) {
      String *dim = SwigType_array_getdim(type, i);
      if (index == 1) {
	char t[32];
	sprintf(t, "$dim%d", i);
	Replace(s, t, dim, DOH_REPLACE_ANY);
	replace_local_types(locals, t, dim);
      }
      sprintf(varname, "dim%d", i);
      Replace(s, var, dim, DOH_REPLACE_ANY);
      replace_local_types(locals, var, dim);
      if (Len(size))
	Putc('*', size);
      Append(size, dim);
      Delete(dim);
    }
    sprintf(varname, "size");
    Replace(s, var, size, DOH_REPLACE_ANY);
    replace_local_types(locals, var, size);
    Delete(size);
  }

  /* Parameter name substitution */
  if (index == 1) {
    Replace(s, "$parmname", pname, DOH_REPLACE_ANY);
  }
  strcpy(varname, "name");
  Replace(s, var, pname, DOH_REPLACE_ANY);

  /* Type-related stuff */
  {
    SwigType *star_type, *amp_type, *base_type, *lex_type;
    SwigType *ltype, *star_ltype, *amp_ltype;
    String *mangle, *star_mangle, *amp_mangle, *base_mangle, *base_name;
    String *descriptor, *star_descriptor, *amp_descriptor;
    String *ts;
    char *sc;

    sc = Char(s);

    if (strstr(sc, "type") || check_locals(locals, "type")) {
      /* Given type : $type */
      ts = SwigType_str(type, 0);
      if (index == 1) {
	Replace(s, "$type", ts, DOH_REPLACE_ANY);
	replace_local_types(locals, "$type", type);
      }
      strcpy(varname, "type");
      Replace(s, var, ts, DOH_REPLACE_ANY);
      replace_local_types(locals, var, type);
      Delete(ts);
      sc = Char(s);
    }
    if (strstr(sc, "ltype") || check_locals(locals, "ltype")) {
      /* Local type:  $ltype */
      ltype = SwigType_ltype(type);
      ts = SwigType_str(ltype, 0);
      if (index == 1) {
	Replace(s, "$ltype", ts, DOH_REPLACE_ANY);
	replace_local_types(locals, "$ltype", ltype);
      }
      strcpy(varname, "ltype");
      Replace(s, var, ts, DOH_REPLACE_ANY);
      replace_local_types(locals, var, ltype);
      Delete(ts);
      Delete(ltype);
      sc = Char(s);
    }
    if (strstr(sc, "mangle") || strstr(sc, "descriptor")) {
      /* Mangled type */

      mangle = SwigType_manglestr(type);
      if (index == 1)
	Replace(s, "$mangle", mangle, DOH_REPLACE_ANY);
      strcpy(varname, "mangle");
      Replace(s, var, mangle, DOH_REPLACE_ANY);

      descriptor = NewStringf("SWIGTYPE%s", mangle);

      if (index == 1)
	if (Replace(s, "$descriptor", descriptor, DOH_REPLACE_ANY))
	  SwigType_remember(type);

      strcpy(varname, "descriptor");
      if (Replace(s, var, descriptor, DOH_REPLACE_ANY))
	SwigType_remember(type);

      Delete(descriptor);
      Delete(mangle);
    }

    /* One pointer level removed */
    /* This creates variables of the form
       $*n_type
       $*n_ltype
     */

    if (SwigType_ispointer(ftype) || (SwigType_isarray(ftype)) || (SwigType_isreference(ftype))) {
      if (!(SwigType_isarray(type) || SwigType_ispointer(type) || SwigType_isreference(type))) {
	star_type = Copy(ftype);
      } else {
	star_type = Copy(type);
      }
      if (!SwigType_isreference(star_type)) {
	if (SwigType_isarray(star_type)) {
	  SwigType_del_element(star_type);
	} else {
	  SwigType_del_pointer(star_type);
	}
	ts = SwigType_str(star_type, 0);
	if (index == 1) {
	  Replace(s, "$*type", ts, DOH_REPLACE_ANY);
	  replace_local_types(locals, "$*type", star_type);
	}
	sprintf(varname, "$*%d_type", index);
	Replace(s, varname, ts, DOH_REPLACE_ANY);
	replace_local_types(locals, varname, star_type);
	Delete(ts);
      } else {
	SwigType_del_element(star_type);
      }
      star_ltype = SwigType_ltype(star_type);
      ts = SwigType_str(star_ltype, 0);
      if (index == 1) {
	Replace(s, "$*ltype", ts, DOH_REPLACE_ANY);
	replace_local_types(locals, "$*ltype", star_ltype);
      }
      sprintf(varname, "$*%d_ltype", index);
      Replace(s, varname, ts, DOH_REPLACE_ANY);
      replace_local_types(locals, varname, star_ltype);
      Delete(ts);
      Delete(star_ltype);

      star_mangle = SwigType_manglestr(star_type);
      if (index == 1)
	Replace(s, "$*mangle", star_mangle, DOH_REPLACE_ANY);

      sprintf(varname, "$*%d_mangle", index);
      Replace(s, varname, star_mangle, DOH_REPLACE_ANY);

      star_descriptor = NewStringf("SWIGTYPE%s", star_mangle);
      if (index == 1)
	if (Replace(s, "$*descriptor", star_descriptor, DOH_REPLACE_ANY))
	  SwigType_remember(star_type);
      sprintf(varname, "$*%d_descriptor", index);
      if (Replace(s, varname, star_descriptor, DOH_REPLACE_ANY))
	SwigType_remember(star_type);

      Delete(star_descriptor);
      Delete(star_mangle);
      Delete(star_type);
    } else {
      /* TODO: Signal error if one of the $* substitutions is
         requested */
    }
    /* One pointer level added */
    amp_type = Copy(type);
    SwigType_add_pointer(amp_type);
    ts = SwigType_str(amp_type, 0);
    if (index == 1) {
      Replace(s, "$&type", ts, DOH_REPLACE_ANY);
      replace_local_types(locals, "$&type", amp_type);
    }
    sprintf(varname, "$&%d_type", index);
    Replace(s, varname, ts, DOH_REPLACE_ANY);
    replace_local_types(locals, varname, amp_type);
    Delete(ts);

    amp_ltype = SwigType_ltype(type);
    SwigType_add_pointer(amp_ltype);
    ts = SwigType_str(amp_ltype, 0);

    if (index == 1) {
      Replace(s, "$&ltype", ts, DOH_REPLACE_ANY);
      replace_local_types(locals, "$&ltype", amp_ltype);
    }
    sprintf(varname, "$&%d_ltype", index);
    Replace(s, varname, ts, DOH_REPLACE_ANY);
    replace_local_types(locals, varname, amp_ltype);
    Delete(ts);
    Delete(amp_ltype);

    amp_mangle = SwigType_manglestr(amp_type);
    if (index == 1)
      Replace(s, "$&mangle", amp_mangle, DOH_REPLACE_ANY);
    sprintf(varname, "$&%d_mangle", index);
    Replace(s, varname, amp_mangle, DOH_REPLACE_ANY);

    amp_descriptor = NewStringf("SWIGTYPE%s", amp_mangle);
    if (index == 1)
      if (Replace(s, "$&descriptor", amp_descriptor, DOH_REPLACE_ANY))
	SwigType_remember(amp_type);
    sprintf(varname, "$&%d_descriptor", index);
    if (Replace(s, varname, amp_descriptor, DOH_REPLACE_ANY))
      SwigType_remember(amp_type);

    Delete(amp_descriptor);
    Delete(amp_mangle);
    Delete(amp_type);

    /* Base type */
    if (SwigType_isarray(type)) {
      SwigType *bt = Copy(type);
      Delete(SwigType_pop_arrays(bt));
      base_type = SwigType_str(bt, 0);
      Delete(bt);
    } else {
      base_type = SwigType_base(type);
    }

    base_name = SwigType_namestr(base_type);
    if (index == 1) {
      Replace(s, "$basetype", base_name, DOH_REPLACE_ANY);
      replace_local_types(locals, "$basetype", base_name);
    }
    strcpy(varname, "basetype");
    Replace(s, var, base_type, DOH_REPLACE_ANY);
    replace_local_types(locals, var, base_name);

    base_mangle = SwigType_manglestr(base_type);
    if (index == 1)
      Replace(s, "$basemangle", base_mangle, DOH_REPLACE_ANY);
    strcpy(varname, "basemangle");
    Replace(s, var, base_mangle, DOH_REPLACE_ANY);
    Delete(base_mangle);
    Delete(base_type);
    Delete(base_name);

    lex_type = SwigType_base(rtype);
    if (index == 1)
      Replace(s, "$lextype", lex_type, DOH_REPLACE_ANY);
    strcpy(varname, "lextype");
    Replace(s, var, lex_type, DOH_REPLACE_ANY);
    Delete(lex_type);
  }

  /* Replace any $n. with (&n)-> */
  {
    char temp[64];
    sprintf(var, "$%d.", index);
    sprintf(temp, "(&$%d)->", index);
    Replace(s, var, temp, DOH_REPLACE_ANY);
  }

  /* Replace the bare $n variable */
  sprintf(var, "$%d", index);
  bare_substitution_count = Replace(s, var, lname, DOH_REPLACE_ANY);
  Delete(ftype);
  return bare_substitution_count;
}

/* ------------------------------------------------------------------------
 * static typemap_locals()
 *
 * Takes a string, a parameter list and a wrapper function argument and
 * creates the local variables.
 * ------------------------------------------------------------------------ */

static void typemap_locals(DOHString * s, ParmList *l, Wrapper *f, int argnum) {
  Parm *p;
  char *new_name;

  p = l;
  while (p) {
    SwigType *pt = Getattr(p, "type");
    SwigType *at = SwigType_alttype(pt, 1);
    String *pn = Getattr(p, "name");
    String *value = Getattr(p, "value");
    if (at)
      pt = at;
    if (pn) {
      if (Len(pn) > 0) {
	String *str;
	int isglobal = 0;

	str = NewStringEmpty();

	if (strncmp(Char(pn), "_global_", 8) == 0) {
	  isglobal = 1;
	}

	/* If the user gave us $type as the name of the local variable, we'll use
	   the passed datatype instead */

	if ((argnum >= 0) && (!isglobal)) {
	  Printf(str, "%s%d", pn, argnum);
	} else {
	  Append(str, pn);
	}
	if (isglobal && Wrapper_check_local(f, str)) {
	  p = nextSibling(p);
	  Delete(str);
	  if (at)
	    Delete(at);
	  continue;
	}
	if (value) {
	  String *pstr = SwigType_str(pt, str);
	  new_name = Wrapper_new_localv(f, str, pstr, "=", value, NIL);
	  Delete(pstr);
	} else {
	  String *pstr = SwigType_str(pt, str);
	  new_name = Wrapper_new_localv(f, str, pstr, NIL);
	  Delete(pstr);
	}
	if (!isglobal) {
	  /* Substitute  */
	  Replace(s, pn, new_name, DOH_REPLACE_ID | DOH_REPLACE_NOQUOTE);
	}
	Delete(str);
      }
    }
    p = nextSibling(p);
    if (at)
      Delete(at);
  }
}

/* -----------------------------------------------------------------------------
 * Swig_typemap_lookup()
 *
 * Attach one or more typemaps to a node and optionally generate the typemap contents
 * into the wrapper.
 * op         - typemap name, eg "out", "newfree"
 * node       - the node to attach the typemaps to
 * lname      - name of variable to substitute $1, $2 etc for
 * f          - wrapper code to generate into if non null
 * actioncode - code to generate into f before the out typemap code, unless
 *              the optimal attribute is set in the out typemap in which case
 *              $1 in the out typemap will be replaced  by the code in actioncode.
 * ----------------------------------------------------------------------------- */

static String *Swig_typemap_lookup_impl(const String_or_char *op, Node *node, const String_or_char *lname, Wrapper *f, String *actioncode) {
  SwigType *type;
  SwigType *mtype = 0;
  String *pname;
  Hash *tm = 0;
  String *s = 0;
  String *sdef = 0;
  ParmList *locals;
  ParmList *kw;
  char temp[256];
  String *symname;
  String *cname = 0;
  String *clname = 0;
  char *cop = Char(op);
  int optimal_attribute = 0;
  int optimal_substitution = 0;
  int num_substitutions = 0;

  /* special case, we need to check for 'ref' call 
     and set the default code 'sdef' */
  if (node && Cmp(op, "newfree") == 0) {
    sdef = Swig_ref_call(node, lname);
  }

  type = Getattr(node, "type");
  if (!type)
    return sdef;

  pname = Getattr(node, "name");

#if 1
  if (pname && node && checkAttribute(node, "kind", "function")) {
    /* 
       For functions, look qualified names first, such as

       struct Foo {
       int *foo(int bar)   ->  Foo::foo
       };
     */
    Symtab *st = Getattr(node, "sym:symtab");
    String *qsn = st ? Swig_symbol_string_qualify(pname, st) : 0;
    if (qsn) {
      if (Len(qsn) && !Equal(qsn, pname)) {
	tm = Swig_typemap_search(op, type, qsn, &mtype);
	if (tm && (!Getattr(tm, "pname") || strstr(Char(Getattr(tm, "type")), "SWIGTYPE"))) {
	  tm = 0;
	}
      }
      Delete(qsn);
    }
  }
  if (!tm)
#endif
    tm = Swig_typemap_search(op, type, pname, &mtype);
  if (!tm)
    return sdef;

  s = Getattr(tm, "code");
  if (!s)
    return sdef;

  /* Empty typemap. No match */
  if (Cmp(s, "pass") == 0)
    return sdef;

  s = Copy(s);			/* Make a local copy of the typemap code */

  /* Attach kwargs - ie the typemap attributes */
  kw = Getattr(tm, "kwargs");
  while (kw) {
    String *value = Copy(Getattr(kw, "value"));
    String *type = Getattr(kw, "type");
    char *ckwname = Char(Getattr(kw, "name"));
    if (type) {
      String *mangle = Swig_string_mangle(type);
      Append(value, mangle);
      Delete(mangle);
    }
    sprintf(temp, "%s:%s", cop, ckwname);
    Setattr(node, tmop_name(temp), value);
    if (Cmp(temp, "out:optimal") == 0)
      optimal_attribute = (Cmp(value, "0") != 0) ? 1 : 0;
    Delete(value);
    kw = nextSibling(kw);
  }
  
  if (optimal_attribute) {
    /* Note: "out" typemap is the only typemap that will have the "optimal" attribute set.
     * If f and actioncode are NULL, then the caller is just looking to attach the "out" attributes
     * ie, not use the typemap code, otherwise both f and actioncode must be non null. */
    if (actioncode) {
      clname = Copy(actioncode);
      /* check that the code in the typemap can be used in this optimal way.
       * The code should be in the form "result = ...;\n". We need to extract
       * the "..." part. This may not be possible for various reasons, eg
       * code added by %exception. This optimal code generation is bit of a
       * hack and circumvents the normal requirement for a temporary variable 
       * to hold the result returned from a wrapped function call.
       */
      if (Strncmp(clname, "result = ", 9) == 0) {
        int numreplacements = Replace(clname, "result = ", "", DOH_REPLACE_ID_BEGIN);
        if (numreplacements == 1) {
          numreplacements = Replace(clname, ";\n", "", DOH_REPLACE_ID_END);
          if (numreplacements == 1) {
            if (Strchr(clname, ';') == 0) {
              lname = clname;
              actioncode = 0;
              optimal_substitution = 1;
            }
          }
        }
      }
      if (!optimal_substitution) {
        Swig_warning(WARN_TYPEMAP_OUT_OPTIMAL_IGNORED, Getfile(node), Getline(node), "Method %s usage of the optimal attribute in the out typemap at %s:%d ignored as the following cannot be used to generate optimal code: %s\n", Swig_name_decl(node), Getfile(s), Getline(s), clname);
        Delattr(node, "tmap:out:optimal");
      }
    } else {
      assert(!f);
    }
  }
  if (actioncode) {
    assert(f);
    Append(f->code, actioncode);
  }

  /* emit local variables declared in typemap, eg emit declarations for aa and bb in:
   * %typemap(in) foo (int aa, int bb) "..." */
  locals = Getattr(tm, "locals");
  if (locals)
    locals = CopyParmList(locals);

  if (pname) {
    if (SwigType_istemplate(pname)) {
      cname = SwigType_namestr(pname);
      pname = cname;
    }
  }
  if (SwigType_istemplate((char *) lname)) {
    clname = SwigType_namestr((char *) lname);
    lname = clname;
  }

  if (mtype && SwigType_isarray(mtype)) {
    num_substitutions = typemap_replace_vars(s, locals, mtype, type, pname, (char *) lname, 1);
  } else {
    num_substitutions = typemap_replace_vars(s, locals, type, type, pname, (char *) lname, 1);
  }
  if (optimal_substitution && num_substitutions > 1)
    Swig_warning(WARN_TYPEMAP_OUT_OPTIMAL_MULTIPLE, Getfile(node), Getline(node), "Multiple calls to %s might be generated due to optimal attribute usage in the out typemap at %s:%d.\n", Swig_name_decl(node), Getfile(s), Getline(s));

  if (locals && f) {
    typemap_locals(s, locals, f, -1);
  }
  replace_embedded_typemap(s);

  Replace(s, "$name", pname, DOH_REPLACE_ANY);

  symname = Getattr(node, "sym:name");
  if (symname) {
    Replace(s, "$symname", symname, DOH_REPLACE_ANY);
  }

  Setattr(node, tmop_name(op), s);
  if (locals) {
    sprintf(temp, "%s:locals", cop);
    Setattr(node, tmop_name(temp), locals);
    Delete(locals);
  }

  if (Checkattr(tm, "type", "SWIGTYPE")) {
    sprintf(temp, "%s:SWIGTYPE", cop);
    Setattr(node, tmop_name(temp), "1");
  }

  /* Look for warnings */
  {
    String *w;
    sprintf(temp, "%s:warning", cop);
    w = Getattr(node, tmop_name(temp));
    if (w) {
      Swig_warning(0, Getfile(node), Getline(node), "%s\n", w);
    }
  }

  /* Look for code fragments */
  {
    String *f;
    sprintf(temp, "%s:fragment", cop);
    f = Getattr(node, tmop_name(temp));
    if (f) {
      String *fname = Copy(f);
      Setfile(fname, Getfile(node));
      Setline(fname, Getline(node));
      Swig_fragment_emit(fname);
      Delete(fname);
    }
  }

  Delete(cname);
  Delete(clname);
  Delete(mtype);
  if (sdef) {			/* put 'ref' and 'newfree' codes together */
    String *p = NewStringf("%s\n%s", sdef, s);
    Delete(s);
    Delete(sdef);
    s = p;
  }
  Delete(actioncode);
  return s;
}

String *Swig_typemap_lookup_out(const String_or_char *op, Node *node, const String_or_char *lname, Wrapper *f, String *actioncode) {
  assert(actioncode);
  assert(Cmp(op, "out") == 0);
  return Swig_typemap_lookup_impl(op, node, lname, f, actioncode);
}

String *Swig_typemap_lookup(const String_or_char *op, Node *node, const String_or_char *lname, Wrapper *f) {
  return Swig_typemap_lookup_impl(op, node, lname, f, 0);
}


/* -----------------------------------------------------------------------------
 * Swig_typemap_attach_kwargs()
 *
 * If this hash (tm) contains a linked list of parameters under its "kwargs"
 * attribute, add keys for each of those named keyword arguments to this
 * parameter for later use.
 * For example, attach the typemap attributes to p:
 * %typemap(in, foo="xyz") ...
 * A new attribute called "tmap:in:foo" with value "xyz" is attached to p.
 * ----------------------------------------------------------------------------- */

void Swig_typemap_attach_kwargs(Hash *tm, const String_or_char *op, Parm *p) {
  String *temp = NewStringEmpty();
  Parm *kw = Getattr(tm, "kwargs");
  while (kw) {
    String *value = Copy(Getattr(kw, "value"));
    String *type = Getattr(kw, "type");
    if (type) {
      Hash *v = NewHash();
      Setattr(v, "type", type);
      Setattr(v, "value", value);
      Delete(value);
      value = v;
    }
    Clear(temp);
    Printf(temp, "%s:%s", op, Getattr(kw, "name"));
    Setattr(p, tmop_name(temp), value);
    Delete(value);
    kw = nextSibling(kw);
  }
  Clear(temp);
  Printf(temp, "%s:match_type", op);
  Setattr(p, tmop_name(temp), Getattr(tm, "type"));
  Delete(temp);
}

/* -----------------------------------------------------------------------------
 * Swig_typemap_warn()
 *
 * If any warning message is attached to this parameter's "tmap:op:warning"
 * attribute, print that warning message.
 * ----------------------------------------------------------------------------- */

static void Swig_typemap_warn(const String_or_char *op, Parm *p) {
  String *temp = NewStringf("%s:warning", op);
  String *w = Getattr(p, tmop_name(temp));
  Delete(temp);
  if (w) {
    Swig_warning(0, Getfile(p), Getline(p), "%s\n", w);
  }
}

static void Swig_typemap_emit_code_fragments(const String_or_char *op, Parm *p) {
  String *temp = NewStringf("%s:fragment", op);
  String *f = Getattr(p, tmop_name(temp));
  if (f) {
    String *fname = Copy(f);
    Setfile(fname, Getfile(p));
    Setline(fname, Getline(p));
    Swig_fragment_emit(fname);
    Delete(fname);
  }
  Delete(temp);
}

/* -----------------------------------------------------------------------------
 * Swig_typemap_attach_parms()
 *
 * Given a parameter list, this function attaches all of the typemaps for a
 * given typemap type
 * ----------------------------------------------------------------------------- */

String *Swig_typemap_get_option(Hash *tm, String *name) {
  Parm *kw = Getattr(tm, "kwargs");
  while (kw) {
    String *kname = Getattr(kw, "name");
    if (Equal(kname, name)) {
      return Getattr(kw, "value");
    }
    kw = nextSibling(kw);
  }
  return 0;
}

void Swig_typemap_attach_parms(const String_or_char *op, ParmList *parms, Wrapper *f) {
  Parm *p, *firstp;
  Hash *tm;
  int nmatch = 0;
  int i;
  String *s;
  ParmList *locals;
  int argnum = 0;
  char temp[256];
  char *cop = Char(op);
  String *kwmatch = 0;
  p = parms;

#ifdef SWIG_DEBUG
  Printf(stdout, "Swig_typemap_attach_parms:  %s\n", op);
#endif

  while (p) {
    argnum++;
    nmatch = 0;
#ifdef SWIG_DEBUG
    Printf(stdout, "parms:  %s %s %s\n", op, Getattr(p, "name"), Getattr(p, "type"));
#endif
    tm = Swig_typemap_search_multi(op, p, &nmatch);
#ifdef SWIG_DEBUG
    if (tm)
      Printf(stdout, "found:  %s\n", tm);
#endif
    if (!tm) {
      p = nextSibling(p);
      continue;
    }
    /*
       Check if the typemap requires to match the type of another
       typemap, for example:

       %typemap(in) SWIGTYPE * (int var) {...}
       %typemap(freearg,match="in") SWIGTYPE * {if (var$argnum) ...}

       here, the freearg typemap requires the "in" typemap to match,
       or the 'var$argnum' variable will not exist.
     */
    kwmatch = Swig_typemap_get_option(tm, "match");
    if (kwmatch) {
      String *tmname = NewStringf("tmap:%s", kwmatch);
      String *tmin = Getattr(p, tmname);
      Delete(tmname);
#ifdef SWIG_DEBUG
      if (tm)
	Printf(stdout, "matching:  %s\n", kwmatch);
#endif
      if (tmin) {
	String *tmninp = NewStringf("tmap:%s:numinputs", kwmatch);
	String *ninp = Getattr(p, tmninp);
	Delete(tmninp);
	if (ninp && Equal(ninp, "0")) {
	  p = nextSibling(p);
	  continue;
	} else {
	  SwigType *typetm = Getattr(tm, "type");
	  String *temp = NewStringf("tmap:%s:match_type", kwmatch);
	  SwigType *typein = Getattr(p, temp);
	  Delete(temp);
	  if (!Equal(typein, typetm)) {
	    p = nextSibling(p);
	    continue;
	  } else {
	    int nnmatch;
	    Hash *tmapin = Swig_typemap_search_multi(kwmatch, p, &nnmatch);
	    String *tmname = Getattr(tm, "pname");
	    String *tnname = Getattr(tmapin, "pname");
	    if (!(tmname && tnname && Equal(tmname, tnname)) && !(!tmname && !tnname)) {
	      p = nextSibling(p);
	      continue;
	    }
	  }

	}
      } else {
	p = nextSibling(p);
	continue;
      }
    }

    s = Getattr(tm, "code");
    if (!s) {
      p = nextSibling(p);
      continue;
    }
#ifdef SWIG_DEBUG
    if (s)
      Printf(stdout, "code:  %s\n", s);
#endif

    /* Empty typemap. No match */
    if (Cmp(s, "pass") == 0) {
      p = nextSibling(p);
      continue;
    }

    s = Copy(s);
    locals = Getattr(tm, "locals");
    if (locals)
      locals = CopyParmList(locals);
    firstp = p;
#ifdef SWIG_DEBUG
    Printf(stdout, "nmatch:  %d\n", nmatch);
#endif
    for (i = 0; i < nmatch; i++) {
      SwigType *type;
      String *pname;
      String *lname;
      SwigType *mtype;


      type = Getattr(p, "type");
      pname = Getattr(p, "name");
      lname = Getattr(p, "lname");
      mtype = Getattr(p, "tmap:match");

      if (mtype) {
	typemap_replace_vars(s, locals, mtype, type, pname, lname, i + 1);
	Delattr(p, "tmap:match");
      } else {
	typemap_replace_vars(s, locals, type, type, pname, lname, i + 1);
      }

      if (Checkattr(tm, "type", "SWIGTYPE")) {
	sprintf(temp, "%s:SWIGTYPE", cop);
	Setattr(p, tmop_name(temp), "1");
      }
      p = nextSibling(p);
    }

    if (locals && f) {
      typemap_locals(s, locals, f, argnum);
    }

    replace_embedded_typemap(s);

    /* Replace the argument number */
    sprintf(temp, "%d", argnum);
    Replace(s, "$argnum", temp, DOH_REPLACE_ANY);

    /* Attach attributes to object */
#ifdef SWIG_DEBUG
    Printf(stdout, "attach: %s %s %s\n", Getattr(firstp, "name"), tmop_name(op), s);
#endif
    Setattr(firstp, tmop_name(op), s);	/* Code object */

    if (locals) {
      sprintf(temp, "%s:locals", cop);
      Setattr(firstp, tmop_name(temp), locals);
      Delete(locals);
    }

    /* Attach a link to the next parameter.  Needed for multimaps */
    sprintf(temp, "%s:next", cop);
    Setattr(firstp, tmop_name(temp), p);

    /* Attach kwargs */
    Swig_typemap_attach_kwargs(tm, op, firstp);

    /* Print warnings, if any */
    Swig_typemap_warn(op, firstp);

    /* Look for code fragments */
    Swig_typemap_emit_code_fragments(op, firstp);

    /* increase argnum to consider numinputs */
    argnum += nmatch - 1;
    Delete(s);
#ifdef SWIG_DEBUG
    Printf(stdout, "res: %s %s %s\n", Getattr(firstp, "name"), tmop_name(op), Getattr(firstp, tmop_name(op)));
#endif

  }
#ifdef SWIG_DEBUG
  Printf(stdout, "Swig_typemap_attach_parms: end\n");
#endif

}

/* -----------------------------------------------------------------------------
 * split_embedded()
 *
 * This function replaces the special variable $typemap(....) with typemap
 * code.  The general form of $typemap is as follows:
 *
 *   $TYPEMAP(method, $var1=value, $var2=value, $var3=value,...)
 *
 * For example:
 *
 *   $TYPEMAP(in, $1=int x, $input=y, ...)
 *
 * Note: this was added as an experiment and could be removed
 * ----------------------------------------------------------------------------- */

/* Splits the arguments of an embedded typemap */
static List *split_embedded(String *s) {
  List *args = 0;
  char *c, *start;
  int level = 0;
  int leading = 1;
  args = NewList();

  c = strchr(Char(s), '(');
  c++;

  start = c;
  while (*c) {
    if (*c == '\"') {
      c++;
      while (*c) {
	if (*c == '\\') {
	  c++;
	} else {
	  if (*c == '\"')
	    break;
	}
	c++;
      }
    }
    if ((level == 0) && ((*c == ',') || (*c == ')'))) {
      String *tmp = NewStringWithSize(start, c - start);
      Append(args, tmp);
      Delete(tmp);
      start = c + 1;
      leading = 1;
      if (*c == ')')
	break;
      c++;
      continue;
    }
    if (*c == '(')
      level++;
    if (*c == ')')
      level--;
    if (isspace((int) *c) && leading)
      start++;
    if (!isspace((int) *c))
      leading = 0;
    c++;
  }
  return args;
}

static void split_var(String *s, String **name, String **value) {
  char *eq;
  char *c;

  eq = strchr(Char(s), '=');
  if (!eq) {
    *name = 0;
    *value = 0;
    return;
  }
  c = Char(s);
  *name = NewStringWithSize(c, eq - c);

  /* Look for $n variables */
  if (isdigit((int) *(c))) {
    /* Parse the value as a type */
    String *v;
    Parm *p;
    v = NewString(eq + 1);
    p = Swig_cparse_parm(v);
    Delete(v);
    *value = p;
  } else {
    *value = NewString(eq + 1);
  }
}

static void replace_embedded_typemap(String *s) {
  char *start = 0;
  while ((start = strstr(Char(s), "$TYPEMAP("))) {

    /* Gather the argument */
    char *end = 0, *c;
    int level = 0;
    String *tmp;
    c = start;
    while (*c) {
      if (*c == '(')
	level++;
      if (*c == ')') {
	level--;
	if (level == 0) {
	  end = c + 1;
	  break;
	}
      }
      c++;
    }
    if (end) {
      tmp = NewStringWithSize(start, (end - start));
    } else {
      tmp = 0;
    }

    /* Got a substitution. Split it apart into pieces */
    if (tmp) {
      List *l;
      Hash *vars;
      String *method;
      int i, ilen;

      l = split_embedded(tmp);
      vars = NewHash();
      ilen = Len(l);
      for (i = 1; i < ilen; i++) {
	String *n, *v;
	split_var(Getitem(l, i), &n, &v);
	if (n && v) {
	  Insert(n, 0, "$");
	  Setattr(vars, n, v);
	}
	Delete(n);
	Delete(v);
      }

      method = Getitem(l, 0);
      /* Generate the parameter list for matching typemaps */

      {
	Parm *p = 0;
	Parm *first = 0;
	char temp[32];
	int n = 1;
	while (1) {
	  Hash *v;
	  sprintf(temp, "$%d", n);
	  v = Getattr(vars, temp);
	  if (v) {
	    if (p) {
	      set_nextSibling(p, v);
	      set_previousSibling(v, p);
	    }
	    p = v;
	    Setattr(p, "lname", Getattr(p, "name"));
	    if (Getattr(p, "value")) {
	      Setattr(p, "name", Getattr(p, "value"));
	    }
	    if (!first)
	      first = p;
	    DohIncref(p);
	    Delattr(vars, temp);
	  } else {
	    break;
	  }
	  n++;
	}
	/* Perform a typemap search */
	if (first) {
#ifdef SWIG_DEBUG
	  Printf(stdout, "Swig_typemap_attach_parms:  embedded\n");
#endif
	  Swig_typemap_attach_parms(method, first, 0);
	  {
	    String *tm;
	    int match = 0;
	    char attr[64];
	    sprintf(attr, "tmap:%s", Char(method));

	    /* Look for the typemap code */
	    tm = Getattr(first, attr);
	    if (tm) {
	      sprintf(attr, "tmap:%s:next", Char(method));
	      if (!Getattr(first, attr)) {
		/* Should be no more matches.  Hack??? */
		/* Replace all of the remaining variables */
		Iterator ki;
		for (ki = First(vars); ki.key; ki = Next(ki)) {
		  Replace(tm, ki.key, ki.item, DOH_REPLACE_ANY);
		}
		/* Do the replacement */
		Replace(s, tmp, tm, DOH_REPLACE_ANY);
		Delete(tm);
		match = 1;
	      }
	    }
	    if (!match) {
	      Swig_error(Getfile(s), Getline(s), "No typemap found for %s\n", tmp);
	    }
	  }
	}
      }
      Replace(s, tmp, "<embedded typemap>", DOH_REPLACE_ANY);
      Delete(vars);
      Delete(tmp);
      Delete(l);
    }
  }
}

/* -----------------------------------------------------------------------------
 * Swig_typemap_debug()
 * ----------------------------------------------------------------------------- */

void Swig_typemap_debug() {
  int ts;
  Printf(stdout, "---[ typemaps ]--------------------------------------------------------------\n");

  ts = tm_scope;
  while (ts >= 0) {
    Printf(stdout, "::: scope %d\n\n", ts);
    Printf(stdout, "%s\n", typemaps[ts]);
    ts--;
  }
  Printf(stdout, "-----------------------------------------------------------------------------\n");
}
