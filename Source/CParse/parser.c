/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison implementation for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2021 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* C LALR(1) parser skeleton written by Richard Stallman, by
   simplifying the original so-called "semantic" parser.  */

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

/* All symbols defined below should begin with yy or YY, to avoid
   infringing on user name space.  This should be done even for local
   variables, as they might otherwise be expanded by user macros.
   There are some unavoidable exceptions within include files to
   define necessary library symbols; they are noted "INFRINGES ON
   USER NAME SPACE" below.  */

/* Identify Bison output, and Bison version.  */
#define YYBISON 30802

/* Bison version string.  */
#define YYBISON_VERSION "3.8.2"

/* Skeleton name.  */
#define YYSKELETON_NAME "yacc.c"

/* Pure parsers.  */
#define YYPURE 0

/* Push parsers.  */
#define YYPUSH 0

/* Pull parsers.  */
#define YYPULL 1




/* First part of user prologue.  */
#line 33 "CParse/parser.y"

/* doh.h uses #pragma GCC poison with GCC to prevent direct calls to certain
 * standard C library functions being introduced, but those cause errors due
 * to checks like `#if defined YYMALLOC || defined malloc` in the bison
 * template code.  We can't easily arrange to include headers after that
 * template code, so instead we disable the problematic poisoning for this
 * file.
 */
#define DOH_NO_POISON_MALLOC_FREE

/* Include stdint.h so that PTRDIFF_MAX is defined before the bison template code picks a type for YYPTRDIFF_T - it
 * otherwise falls back to long, which is 32 bits on 64 bit Windows and gives an MSVC C4244 warning. */
#include <stdint.h>

#include "swig.h"
#include "cparse.h"
#include "preprocessor.h"
#include <ctype.h>

#define YYMALLOC Malloc
#define YYFREE Free

/* -----------------------------------------------------------------------------
 *                               Externals
 * ----------------------------------------------------------------------------- */

int  yyparse(void);

/* NEW Variables */

static void    *top = 0;      /* Top of the generated parse tree */
static int      unnamed = 0;  /* Unnamed datatype counter */
static Hash    *classes = 0;        /* Hash table of classes */
static Hash    *classes_typedefs = 0; /* Hash table of typedef classes: typedef struct X {...} Y; */
static Symtab  *prev_symtab = 0;
static Node    *current_class = 0;
String  *ModuleName = 0;
static Node    *module_node = 0;
static String  *Classprefix = 0;  
static String  *Namespaceprefix = 0;
static int      inclass = 0;
static Node    *currentOuterClass = 0; /* for nested classes */

/* swig4ada: a base class which is inherited virtually, or a member whose type is a nested class with no name,
   changes the layout of its class in a way which a language module cannot see from the parse tree. Each is
   noted on the node of the class ("has_virtual_base", "has_unnamed_member"). */
static int      virtual_base_seen = 0;
/* swig4ada: which of the bases is inherited virtually, as their places in the object depend on it: each such base
   is noted on its specifier ("virtual"), and the list of their names on the node of the class ("virtualbaselist"),
   beside "baselist". */
static int      this_base_virtual = 0;
static String  *last_cpptype = 0;
static int      inherit_list = 0;
static Parm    *template_parameters = 0;
static int      parsing_template_declaration = 0;
static int      extendmode   = 0;
static int      compact_default_args = 0;
static int      template_reduce = 0;
static int      cparse_externc = 0;
int		ignore_nested_classes = 0;
int		kwargs_supported = 0;

/* swig4ada: a language module which binds a nested class with no name itself (see below) sets this, so that it is
   kept for the module where nested classes are flattened for it by default, as where they are ignored. */
int		cparse_keep_unnamed_nested = 0;

/* swig4ada: a language module which binds a private nested class for its shape alone (so that a member of the outer
   class whose type it is takes its place in the layout) sets this, so that such a class is kept as a protected one is,
   to be flattened and ignored by the core as any nested class which is not public is. */
int		cparse_keep_private_nested = 0;

/* -----------------------------------------------------------------------------
 *                            Doxygen Comment Globals
 * ----------------------------------------------------------------------------- */
static String *currentDeclComment = NULL; /* Comment of C/C++ declaration. */

/* -----------------------------------------------------------------------------
 *                            Assist Functions
 * ----------------------------------------------------------------------------- */


 
/* Called by the parser (yyparse) when an error is found.*/
static void yyerror (const char *e) {
  (void)e;
}

static Node *new_node(const_String_or_char_ptr tag) {
  Node *n = Swig_cparse_new_node(tag);
  return n;
}

/* Copies a node.  Does not copy tree links or symbol table data (except for
   sym:name) */

static Node *copy_node(Node *n) {
  Node *nn;
  Iterator k;
  nn = NewHash();
  Setfile(nn,Getfile(n));
  Setline(nn,Getline(n));
  for (k = First(n); k.key; k = Next(k)) {
    String *ci;
    String *key = k.key;
    char *ckey = Char(key);
    if ((strcmp(ckey,"nextSibling") == 0) ||
	(strcmp(ckey,"previousSibling") == 0) ||
	(strcmp(ckey,"parentNode") == 0) ||
	(strcmp(ckey,"lastChild") == 0)) {
      continue;
    }
    if (Strncmp(key,"csym:",5) == 0) continue;
    /* We do copy sym:name.  For templates */
    if ((strcmp(ckey,"sym:name") == 0) || 
	(strcmp(ckey,"sym:weak") == 0) ||
	(strcmp(ckey,"sym:typename") == 0)) {
      String *ci = Copy(k.item);
      Setattr(nn,key, ci);
      Delete(ci);
      continue;
    }
    if (strcmp(ckey,"sym:symtab") == 0) {
      Setattr(nn,"sym:needs_symtab", "1");
    }
    /* We don't copy any other symbol table attributes */
    if (strncmp(ckey,"sym:",4) == 0) {
      continue;
    }
    /* If children.  We copy them recursively using this function */
    if (strcmp(ckey,"firstChild") == 0) {
      /* Copy children */
      Node *cn = k.item;
      while (cn) {
	Node *copy = copy_node(cn);
	appendChild(nn,copy);
	Delete(copy);
	cn = nextSibling(cn);
      }
      continue;
    }
    /* We don't copy the symbol table.  But we drop an attribute 
       requires_symtab so that functions know it needs to be built */

    if (strcmp(ckey,"symtab") == 0) {
      /* Node defined a symbol table. */
      Setattr(nn,"requires_symtab","1");
      continue;
    }
    /* Can't copy nodes */
    if (strcmp(ckey,"node") == 0) {
      continue;
    }
    if ((strcmp(ckey,"parms") == 0) || (strcmp(ckey,"pattern") == 0) || (strcmp(ckey,"throws") == 0)
	|| (strcmp(ckey,"kwargs") == 0)) {
      ParmList *pl = CopyParmList(k.item);
      Setattr(nn,key,pl);
      Delete(pl);
      continue;
    }
    if (strcmp(ckey,"nested:outer") == 0) { /* don't copy outer classes links, they will be updated later */
      Setattr(nn, key, k.item);
      continue;
    }
    /* defaultargs will be patched back in later in update_defaultargs() */
    if (strcmp(ckey,"defaultargs") == 0) {
      Setattr(nn, "needs_defaultargs", "1");
      continue;
    }
    /* C++20 constraint subtree must be deep copied: cparse_template_expand patches the subtree
       in place, so a shallow Copy() (which only duplicates the root hash) would alias the inner
       atom and requires-expression / requirement nodes between the primary and every instantiation,
       leaking the first instantiation's substitutions into all subsequent ones. */
    if (strcmp(ckey,"constraint") == 0) {
      Node *cs = copy_node((Node *)k.item);
      Setattr(nn, key, cs);
      Delete(cs);
      continue;
    }
    /* same for abstracts, which contains pointers to the source node children, and so will need to be patch too */
    if (strcmp(ckey,"abstracts") == 0) {
      SetFlag(nn, "needs_abstracts");
      continue;
    }
    /* Looks okay.  Just copy the data using Copy */
    ci = Copy(k.item);
    Setattr(nn, key, ci);
    Delete(ci);
  }
  return nn;
}

static void set_comment(Node *n, String *comment) {
  String *name;
  Parm *p;
  if (!n || !comment)
    return;

  if (Getattr(n, "doxygen"))
    Append(Getattr(n, "doxygen"), comment);
  else {
    Setattr(n, "doxygen", comment);
    /* This is the first comment, populate it with @params, if any */
    p = Getattr(n, "parms");
    while (p) {
      if (Getattr(p, "doxygen"))
	Printv(comment, "\n@param ", Getattr(p, "name"), Getattr(p, "doxygen"), NIL);
      p=nextSibling(p);
    }
  }
  
  /* Append same comment to every generated overload */
  name = Getattr(n, "name");
  if (!name)
    return;
  n = nextSibling(n);
  while (n && Getattr(n, "name") && Strcmp(Getattr(n, "name"), name) == 0) {
    Setattr(n, "doxygen", comment);
    n = nextSibling(n);
  }
}

/* -----------------------------------------------------------------------------
 *                              Variables
 * ----------------------------------------------------------------------------- */

static int cplus_mode  = 0;

/* C++ modes */

#define  CPLUS_PUBLIC    1
#define  CPLUS_PRIVATE   2
#define  CPLUS_PROTECTED 3

/* storage classes */

#define SWIG_STORAGE_CLASS_EXTERNC	0x0001
#define SWIG_STORAGE_CLASS_EXTERNCPP	0x0002
#define SWIG_STORAGE_CLASS_EXTERN	0x0004
#define SWIG_STORAGE_CLASS_STATIC	0x0008
#define SWIG_STORAGE_CLASS_TYPEDEF	0x0010
#define SWIG_STORAGE_CLASS_VIRTUAL	0x0020
#define SWIG_STORAGE_CLASS_FRIEND	0x0040
#define SWIG_STORAGE_CLASS_EXPLICIT	0x0080
#define SWIG_STORAGE_CLASS_CONSTEXPR	0x0100
#define SWIG_STORAGE_CLASS_THREAD_LOCAL	0x0200

/* Test if multiple bits are set in x. */
static int multiple_bits_set(unsigned x) { return (x & (x - 1)) != 0; }

static const char* storage_class_string(int c) {
  switch (c) {
    case SWIG_STORAGE_CLASS_EXTERNC:
      return "extern \"C\"";
    case SWIG_STORAGE_CLASS_EXTERNCPP:
      return "extern \"C++\"";
    case SWIG_STORAGE_CLASS_EXTERN:
      return "extern";
    case SWIG_STORAGE_CLASS_STATIC:
      return "static";
    case SWIG_STORAGE_CLASS_TYPEDEF:
      return "typedef";
    case SWIG_STORAGE_CLASS_VIRTUAL:
      return "virtual";
    case SWIG_STORAGE_CLASS_FRIEND:
      return "friend";
    case SWIG_STORAGE_CLASS_EXPLICIT:
      return "explicit";
    case SWIG_STORAGE_CLASS_CONSTEXPR:
      return "constexpr";
    case SWIG_STORAGE_CLASS_THREAD_LOCAL:
      return "thread_local";
  }
  assert(0);
  return "<unknown>";
}

/* include types */
static int   import_mode = 0;

void SWIG_cparse_set_compact_default_args(int defargs) {
  compact_default_args = defargs;
}

int SWIG_cparse_template_reduce(int treduce) {
  template_reduce = treduce;
  return treduce;  
}

/* -----------------------------------------------------------------------------
 *                           Assist functions
 * ----------------------------------------------------------------------------- */

static int promote_type(int t) {
  if (t <= T_UCHAR || t == T_CHAR || t == T_WCHAR) return T_INT;
  return t;
}

/* Perform type-promotion for binary operators */
static int promote(int t1, int t2) {
  t1 = promote_type(t1);
  t2 = promote_type(t2);
  return t1 > t2 ? t1 : t2;
}

static String *yyrename = 0;

/* Forward renaming operator */

static String *resolve_create_node_scope(String *cname, int is_class_definition, int *errored);


Hash *Swig_cparse_features(void) {
  static Hash   *features_hash = 0;
  if (!features_hash) features_hash = NewHash();
  return features_hash;
}

/* -----------------------------------------------------------------------------
 * feature_identifier_fix()
 *
 * If a template, return template with all template parameters fully resolved.
 *
 * This is a copy and modification of typemap_identifier_fix.
 * ----------------------------------------------------------------------------- */

static String *feature_identifier_fix(String *s) {
  String *tp = SwigType_istemplate_templateprefix(s);
  if (tp) {
    String *ts, *ta, *tq;
    ts = SwigType_templatesuffix(s);
    ta = SwigType_templateargs(s);
    tq = Swig_symbol_type_qualify(ta,0);
    Append(tp,tq);
    Append(tp,ts);
    Delete(ts);
    Delete(ta);
    Delete(tq);
    return tp;
  } else {
    return NewString(s);
  }
}

static void set_access_mode(Node *n) {
  if (cplus_mode == CPLUS_PUBLIC)
    Setattr(n, "access", "public");
  else if (cplus_mode == CPLUS_PROTECTED)
    Setattr(n, "access", "protected");
  else
    Setattr(n, "access", "private");
}

static void restore_access_mode(Node *n) {
  String *mode = Getattr(n, "access");
  if (Strcmp(mode, "private") == 0)
    cplus_mode = CPLUS_PRIVATE;
  else if (Strcmp(mode, "protected") == 0)
    cplus_mode = CPLUS_PROTECTED;
  else
    cplus_mode = CPLUS_PUBLIC;
}

/* Generate the symbol table name for an object */
/* This is a bit of a mess. Need to clean up */
static String *add_oldname = 0;



static String *make_name(Node *n, String *name,SwigType *decl) {
  String *made_name = 0;
  int destructor = name && (*(Char(name)) == '~');

  if (yyrename) {
    String *s = NewString(yyrename);
    Delete(yyrename);
    yyrename = 0;
    if (destructor  && (*(Char(s)) != '~')) {
      Insert(s,0,"~");
    }
    return s;
  }

  if (!name) return 0;

  if (parsing_template_declaration)
    SetFlag(n, "parsing_template_declaration");
  made_name = Swig_name_make(n, Namespaceprefix, name, decl, add_oldname);
  Delattr(n, "parsing_template_declaration");

  return made_name;
}

/* Generate an unnamed identifier */
static String *make_unnamed(void) {
  unnamed++;
  return NewStringf("$unnamed%d$",unnamed);
}

static int is_operator(String *name) {
  return Strncmp(name,"operator ", 9) == 0;
}

/* Classifier for the 'type' attribute of a parm reaching the templateparameter
 * 'parm' fallback with a name set.  Distinguishes a C++20 type-constraint
 * ('template<Numeric T>' / 'template<Printable... Ts>' / 'template<Pair<int> T>')
 * from a real non-type template parameter and from an undeclared identifier.
 * The "candidate concept-id" test (below) accepts a possibly variadic prefixed
 * scope qualified identifier (with or without template arguments) that names
 * neither a built in primitive nor an enum and carries no SwigType decoration (where
 * 'type' contains the template parameters in the examples below):
 *
 *   TPC_REMAP    candidate and the symbol resolves to a concept (for a
 *                template-id like 'Pair<int>' the bare prefix 'Pair' is the
 *                symbol that must resolve to a concept)
 *                -> rewrite the parm to 'typename T' (or 'v.typename Ts...')
 *                   and attach a concept-id constraint atom carrying the full
 *                   (possibly template-id) concept-id string
 *                Examples:
 *                  template<Numeric T>                  T cube(T x);
 *                  template<nest::Integral T>           T half(T x);
 *                  template<Numeric... Ts>              int count(Ts...);
 *                  template<std::convertible_to<int> T> T as_int(T x);    // template-id is a concept (and SWIG has parsed the concept definition)
 *                  template<Pair<int> T>                T first_int(T x); // template-id is a concept (not a class)
 *   TPC_KEEP     not a candidate, or the symbol resolves to a type (non-concept)
 *                (typedef, class, enum) -> leave as a non-type parameter
 *                Examples:
 *                  template<int N>                 int times_n(int x);  // primitive
 *                  template<unsigned long N>       int times_n(int x);  // multi word primitive
 *                  template<size_t N>              int times_n(int x);  // typedef'd alias
 *                  template<Color C>               int as_int();        // enum
 *                  template<MyClass *P>            void deref();        // decorated
 *                  template<std::convertible_to<int> T> T as_int(T x);  // template-id is a concept (and SWIG has NOT parsed the concept definition)
 *                  template<std::array<int,4> A>   int sum_array();     // template-id naming a class (not a concept)
 *   TPC_UNKNOWN  candidate but the symbol is not declared in the current
 *                scope -> the user almost certainly meant a concept that
 *                hasn't been made visible to SWIG - the action remaps anyway but should warn later.
 *                Examples:
 *                  template<Numeric T>                  T cube(T x);   // 'Numeric' not declared
 *                  template<MisspeltConcept T>          T f(T);        // typo
 *                  template<UndeclaredConcept<int> T>   T g(T);        // template-id, prefix unknown
 */
enum {
  TPC_KEEP = 0,
  TPC_REMAP = 1,
  TPC_UNKNOWN = 2
};
static int classify_template_param_type(const SwigType *type) {
  SwigType *probe;
  Node *n;
  String *templatetype;
  int verdict;
  if (!type || Len(type) == 0) return TPC_KEEP;
  /* Strip the variadic prefix - 'v.' is the only decoration we look past.  Any other
   * SwigType decoration (pointer, reference, array, qualifier, function, member pointer)
   * makes SwigType_issimple() false and falls into TPC_KEEP below. */
  probe = SwigType_isvariadic(type) ? SwigType_del_variadic(Copy(type)) : Copy(type);
  /* SwigType_type() maps every recognised primitive (including multi word forms like
   * 'unsigned int' / 'long long' and resolvable typedefs such as 'size_t') to a
   * non-T_USER code; T_USER means SWIG has no record of this name, which is exactly
   * the population we want to consider for a type-constraint remap.  Enums are
   * T_INT in SwigType_type, so SwigType_isenum() rejects them separately. */
  if (SwigType_type(probe) != T_USER ||
      SwigType_isenum(probe) ||
      !SwigType_issimple(probe)) {
    Delete(probe);
    return TPC_KEEP;
  }
  /* For a template-id concept-id like 'Pair<(int)>' or 'std::convertible_to<(int)>'
   * the concept declaration is registered under the bare template prefix.  Look that
   * up; for a probe that is not a template-id the prefix is the probe itself. */
  if (SwigType_istemplate(probe)) {
    String *prefix = SwigType_templateprefix(probe);
    n = Swig_symbol_clookup(prefix, 0);
    Delete(prefix);
  } else {
    n = Swig_symbol_clookup(probe, 0);
  }
  templatetype = n ? Getattr(n, "templatetype") : 0;
  if (templatetype && Equal(templatetype, "concept")) {
    verdict = TPC_REMAP;
  } else if (!n) {
    verdict = TPC_UNKNOWN;
  } else {
    verdict = TPC_KEEP;
  }
  Delete(probe);
  return verdict;
}

/* If the cdecl 'n' has any parameter whose type is 'auto' or 'Concept auto' (a C++20 abbreviated function template) replace
 * each such parm with an invented type template parameter (named '__dummy_auto_<N>__') and convert 'n' to a template node
 * carrying those typenames as templateparms.  When a concept type-constraint is present, attach it as a 'constraint' attribute
 * on the invented template parm. This lets the existing %template machinery work for abbreviated function templates.
 * Detection uses SwigType_isauto, which looks through any decoration prefix and recognises both the bare 'auto' base form and
 * the C++20 'auto.c(<id>)' constrained form.  The concept-id (if any) is read via SwigType_concept_name.
 * Returns 1 if a transformation happened, 0 otherwise. */
static int promote_abbreviated_template(Node *n) {
  ParmList *parms = Getattr(n, "parms");
  Parm *p;
  int auto_count = 0;
  ParmList *templateparms = 0;
  Parm *last_invented = 0;
  static int auto_cnt = 0;

  if (!parms)
    return 0;

  for (p = parms; p; p = nextSibling(p)) {
    SwigType *ty = Getattr(p, "type");
    if (SwigType_isauto(ty))
      auto_count++;
  }

  if (auto_count == 0)
    return 0;

  for (p = parms; p; p = nextSibling(p)) {
    SwigType *ty = Getattr(p, "type");
    String *concept_name;
    if (!ty || !SwigType_isauto(ty))
      continue;
    {
      String *invented_name = NewStringf("__dummy_auto_%d__", auto_cnt++);
      Parm *tp = NewParmWithoutFileLineInfo(NewString("typename"), invented_name);
      Setfile(tp, Getfile(n));
      Setline(tp, Getline(n));
      SetFlag(tp, "abbreviated_auto");
      concept_name = SwigType_concept_name(ty);
      if (concept_name) {
        Node *atom = Constraint_new_atom("concept-id");
        Setattr(atom, "type", concept_name);
        Setattr(tp, "constraint", atom);
      }
      /* Replace the 'auto' placeholder (and any 'c(<id>)' base) with the invented name,
       * preserving outer decoration so 'r.auto' -> 'r.__dummy_auto_N__',
       * 'r.q(const).auto.c(Numeric)' -> 'r.q(const).__dummy_auto_N__', etc. */
      Setattr(p, "type", SwigType_replace_auto_base(ty, invented_name));
      if (last_invented) {
        set_nextSibling(last_invented, tp);
      } else {
        templateparms = tp;
      }
      last_invented = tp;
      Delete(invented_name);
      Delete(concept_name);
    }
  }

  Setattr(n, "templatetype", nodeType(n));
  set_nodeType(n, "template");
  Setattr(n, "templateparms", templateparms);
  Setattr(n, "sym:typename", "1");
  return 1;
}

/* Return 1 if 'unqualified_id' is the terminal name of a base class of class 'cls', following
 * typedefs to the base class' own name (as Swig_make_inherit_list does).  A using declaration whose
 * unqualified-id names a base class this way could be an inheriting constructor, even when the
 * nested-name-specifier names the base through a typedef, eg 'using Alias::Base;' where Alias is a
 * typedef for the base Base. */
static int inheriting_ctor_base_match(Node *cls, String *unqualified_id) {
  static const char *baselists[3] = {"baselist", "protectedbaselist", "privatebaselist"};
  int i;
  for (i = 0; i < 3; i++) {
    List *bases = Getattr(cls, baselists[i]);
    int len = bases ? Len(bases) : 0;
    int j;
    for (j = 0; j < len; j++) {
      Node *s = Swig_symbol_clookup_resolve_typedef(Getitem(bases, j), 0);
      if (s && (Strcmp(nodeType(s), "class") == 0 || Strcmp(nodeType(s), "template") == 0)) {
	String *terminal = Swig_scopename_last(Getattr(s, "name"));
	String *base_terminal = SwigType_istemplate(terminal) ? SwigType_templateprefix(terminal) : terminal;
	int match = Equal(unqualified_id, base_terminal);
	if (base_terminal != terminal)
	  Delete(base_terminal);
	Delete(terminal);
	if (match)
	  return 1;
      }
    }
  }
  return 0;
}

/* Add declaration list to symbol table */
static int  add_only_one = 0;

static void add_symbols(Node *n) {
  String *decl;
  String *wrn = 0;

  while (n) {
    String *symname = 0;
    String *old_prefix = 0;
    Symtab *old_scope = 0;
    int isfriend = inclass && Strstr(Getattr(n, "storage"), "friend") != NULL;
    int iscdecl = Cmp(nodeType(n),"cdecl") == 0;
    int only_csymbol = 0;
    
    if (inclass) {
      String *name = Getattr(n, "name");
      if (isfriend) {
	/* Friends methods in a class are declared in the namespace enclosing the class (outer most class if a nested class) */
	String *prefix = name ? Swig_scopename_prefix(name) : 0;
	Node *outer = currentOuterClass;
	Symtab *namespace_symtab;
	old_prefix = Namespaceprefix;
	old_scope = Swig_symbol_current();

	assert(outer);
	while (Getattr(outer, "nested:outer")) {
	  outer = Getattr(outer, "nested:outer");
	}
	namespace_symtab = Getattr(outer, "sym:symtab");
	if (!namespace_symtab)
	  namespace_symtab = Getattr(outer, "unofficial:symtab");
	Swig_symbol_setscope(namespace_symtab);
	Namespaceprefix = Swig_symbol_qualifiedscopename(0);

	if (!prefix) {
	  /* To check - this should probably apply to operators too */
	  if (name && !is_operator(name) && Namespaceprefix) {
	    String *friendusing = NewStringf("using namespace %s;", Namespaceprefix);
	    Setattr(n, "friendusing", friendusing);
	    Delete(friendusing);
	  }
	} else {
	  /* Qualified friend declarations should not be possible as they are ignored in the parse tree */
	  assert(0);
	}
      } else if (Equal(nodeType(n), "using")) {
	String *uname = Getattr(n, "uname");
	String *nested_name_specifier = 0;
	String *unqualified_id = 0;
	Swig_scopename_split(uname, &nested_name_specifier, &unqualified_id);
        /* A note regarding C++ standards terminology when given a fully-qualified member W::X::Y::Z
         *   W::X::Y is the nested-name-specifier
         *   Y is the terminal name (c++23) or last component of the nested-name-specifier (pre c++23)
         *   Z is the unqualified-id
         *
         * Recognise a using declaration that could be an inheriting constructor, ie one that names a
	 * constructor of a base class. It is a candidate when either:
	 *  (a) the terminal name of the nested-name-specifier is the same as the unqualified-id, eg
	 *      using Base::Base;   using C<A>::C;   using base_type::base_type;
	 *  (b) the unqualified-id is the terminal name of a base class of the enclosing class, eg
	 *      using Alias::Base;   where Alias is a typedef for the base Base.
	 * Both are only candidates - whether the nested-name-specifier really names an immediate base class
	 * cannot be decided here as base classes are not resolved into nodes until Typepass::usingDeclaration,
         * which verifies the candidate as an inheriting constructor. */
	if (nested_name_specifier && currentOuterClass) {
	  String *terminal = Swig_scopename_last(nested_name_specifier);
	  String *terminal_name = SwigType_istemplate(terminal) ? SwigType_templateprefix(terminal) : Copy(terminal);
	  if (Equal(terminal_name, unqualified_id) || inheriting_ctor_base_match(currentOuterClass, unqualified_id)) {
	    /* Rename the node to the enclosing class so the symbol table registers it as a constructor of this
	     * class (reverted in typepass stage if inheriting constructor verification fails). */
	    Symtab *stab = Swig_symbol_current();
	    Setattr(n, "name", Getattr(stab, "name"));
	    SetFlag(n, "usingctor");
	  }
	  Delete(terminal_name);
	  Delete(terminal);
	}
      } else {
	/* for member functions, we need to remove the redundant
	   class scope if provided, as in
	   
	   struct Foo {
	   int Foo::method(int a);
	   };
	   
	*/
	String *prefix = name ? Swig_scopename_prefix(name) : 0;
	if (prefix) {
	  if (Classprefix && (Equal(prefix,Classprefix))) {
	    String *base = Swig_scopename_last(name);
	    Setattr(n,"name",base);
	    Delete(base);
	  }
	  Delete(prefix);
	}
      }
    }

    if (!isfriend && (inclass || extendmode)) {
      Setattr(n,"ismember","1");
    }

    if (extendmode) {
      if (!Getattr(n, "template"))
        SetFlag(n,"isextendmember");
    }

    if (!isfriend && inclass) {
      if ((cplus_mode != CPLUS_PUBLIC)) {
	only_csymbol = 1;
	if (cplus_mode == CPLUS_PROTECTED) {
	  Setattr(n,"access", "protected");
	  only_csymbol = !Swig_need_protected(n);
	} else {
	  Setattr(n,"access", "private");
	  /* private are needed only when they are pure virtuals - why? */
	  if ((Cmp(Getattr(n,"storage"),"virtual") == 0) && (Cmp(Getattr(n,"value"),"0") == 0)) {
	    only_csymbol = 0;
	  }
	  if (Cmp(nodeType(n),"destructor") == 0) {
	    /* Needed for "unref" feature */
	    only_csymbol = 0;
	  }
	}
      } else {
	Setattr(n, "access", "public");
      }
    } else if (extendmode && !inclass) {
      Setattr(n, "access", "public");
    }

    if (Getattr(n,"sym:name")) {
      n = nextSibling(n);
      continue;
    }
    decl = Getattr(n,"decl");
    if (!SwigType_isfunction(decl)) {
      String *name = Getattr(n,"name");
      String *makename = Getattr(n,"parser:makename");
      if (iscdecl) {	
	String *storage = Getattr(n, "storage");
	if (Cmp(storage,"typedef") == 0) {
	  Setattr(n,"kind","typedef");
	} else {
	  SwigType *type = Getattr(n,"type");
	  String *value = Getattr(n,"value");
	  Setattr(n,"kind","variable");
	  if (value && Len(value)) {
	    Setattr(n,"hasvalue","1");
	  }
	  if (type) {
	    SwigType *ty;
	    SwigType *tmp = 0;
	    if (decl) {
	      ty = tmp = Copy(type);
	      SwigType_push(ty,decl);
	    } else {
	      ty = type;
	    }
	    if (storage && (Strstr(storage, "constexpr") || (Strstr(storage, "static") && !SwigType_ismutable(ty)))) {
	      SetFlag(n, "hasconsttype");
	    }
	    Delete(tmp);
	  }
	  if (!type) {
	    Printf(stderr,"notype name %s\n", name);
	  }
	}
      }
      Swig_features_get(Swig_cparse_features(), Namespaceprefix, name, 0, n);
      if (makename) {
	symname = make_name(n, makename,0);
        Delattr(n,"parser:makename"); /* temporary information, don't leave it hanging around */
      } else {
        makename = name;
	symname = make_name(n, makename,0);
      }
      
      if (!symname) {
	symname = Copy(Getattr(n,"unnamed"));
      }
      if (symname) {
	if (parsing_template_declaration)
	  SetFlag(n, "parsing_template_declaration");
	wrn = Swig_name_warning(n, Namespaceprefix, symname,0);
	Delattr(n, "parsing_template_declaration");
      }
    } else {
      String *name = Getattr(n,"name");
      SwigType *fdecl = Copy(decl);
      SwigType *fun = SwigType_pop_function(fdecl);
      if (iscdecl) {	
	Setattr(n,"kind","function");
      }
      
      Swig_features_get(Swig_cparse_features(),Namespaceprefix,name,fun,n);

      symname = make_name(n, name,fun);
      if (parsing_template_declaration)
	SetFlag(n, "parsing_template_declaration");
      wrn = Swig_name_warning(n, Namespaceprefix,symname,fun);
      Delattr(n, "parsing_template_declaration");
      
      Delete(fdecl);
      Delete(fun);
      
    }
    if (!symname) {
      n = nextSibling(n);
      continue;
    }

    if (GetFlag(n, "valueignored")) {
      SWIG_WARN_NODE_BEGIN(n);
      Swig_warning(WARN_PARSE_ASSIGNED_VALUE, Getfile(n), Getline(n), "Value assigned to %s not used due to limited parsing implementation.\n", SwigType_namestr(Getattr(n, "name")));
      SWIG_WARN_NODE_END(n);
    }

    if (cparse_cplusplus) {
      String *value = Getattr(n, "value");
      if (value && Strcmp(value, "delete") == 0) {
	/* C++11 deleted definition / deleted function */
        SetFlag(n,"deleted");
        SetFlag(n,"feature:ignore");
      }
      if (SwigType_isrvalue_reference(Getattr(n, "refqualifier"))) {
	/* Ignore rvalue ref-qualifiers by default
	 * Use Getattr instead of GetFlag to handle explicit ignore and explicit not ignore */
	if (!(Getattr(n, "feature:ignore") || Strncmp(symname, "$ignore", 7) == 0)) {
	  SWIG_WARN_NODE_BEGIN(n);
	  Swig_warning(WARN_TYPE_RVALUE_REF_QUALIFIER_IGNORED, Getfile(n), Getline(n),
	      "Method with rvalue ref-qualifier %s ignored.\n", Swig_name_decl(n));
	  SWIG_WARN_NODE_END(n);
	  SetFlag(n, "feature:ignore");
	}
      }
      if (Equal(Getattr(n, "type"), "auto")) {
	/* Ignore functions with an auto return type and no trailing return type
	 * Use Getattr instead of GetFlag to handle explicit ignore and explicit not ignore */
	if (!(Getattr(n, "feature:ignore") || Strncmp(symname, "$ignore", 7) == 0)) {
	  SWIG_WARN_NODE_BEGIN(n);
	  if (SwigType_isfunction(Getattr(n, "decl")))
	    Swig_warning(WARN_CPP14_AUTO, Getfile(n), Getline(n), "Unable to deduce auto return type for '%s' (ignored).\n", Swig_name_decl(n));
	  else
	    Swig_warning(WARN_CPP11_AUTO, Getfile(n), Getline(n), "Unable to deduce auto type for variable '%s' (ignored).\n", Swig_name_decl(n));
	  SWIG_WARN_NODE_END(n);
	  SetFlag(n, "feature:ignore");
	}
      }
    }
    if (only_csymbol || GetFlag(n, "feature:ignore") || Strncmp(symname, "$ignore", 7) == 0) {
      /* Only add to C symbol table and continue */
      Swig_symbol_add(0, n);
      if (!only_csymbol && !GetFlag(n, "feature:ignore")) {
	/* Print the warning attached to $ignore name, if any */
        char *c = Char(symname) + 7;
	if (strlen(c)) {
	  SWIG_WARN_NODE_BEGIN(n);
	  Swig_warning(0,Getfile(n), Getline(n), "%s\n",c+1);
	  SWIG_WARN_NODE_END(n);
	}
	/* If the symbol was ignored via "rename" and is visible, set also feature:ignore*/
	SetFlag(n, "feature:ignore");
      }
      if (!GetFlag(n, "feature:ignore") && Strcmp(symname,"$ignore") == 0) {
	/* Add feature:ignore if the symbol was explicitly ignored, regardless of visibility */
	SetFlag(n, "feature:ignore");
      }
    } else {
      Node *c;
      if ((wrn) && (Len(wrn))) {
	String *metaname = symname;
	if (!Getmeta(metaname,"already_warned")) {
	  SWIG_WARN_NODE_BEGIN(n);
	  Swig_warning(0,Getfile(n),Getline(n), "%s\n", wrn);
	  SWIG_WARN_NODE_END(n);
	  Setmeta(metaname,"already_warned","1");
	}
      }
      c = Swig_symbol_add(symname,n);

      if (c != n) {
	/* symbol conflict attempting to add in the new symbol */
	if (Getattr(n,"sym:weak")) {
	  Setattr(n,"sym:name",symname);
	} else {
	  Swig_symbol_conflict_warn(n, c, symname, inclass);
        }
      }
    }
    /* restore the class scope if needed */
    if (isfriend) {
      Swig_symbol_setscope(old_scope);
      if (old_prefix) {
	Delete(Namespaceprefix);
	Namespaceprefix = old_prefix;
      }
    }
    Delete(symname);

    if (add_only_one) return;
    n = nextSibling(n);
  }
}


/* add symbols a parse tree node copy */

static void add_symbols_copy(Node *n) {
  int    emode = 0;
  while (n) {
    if (Equal(nodeType(n), "access")) {
      String *kind = Getattr(n,"kind");
      if (Strcmp(kind,"public") == 0) {
	cplus_mode = CPLUS_PUBLIC;
      } else if (Strcmp(kind,"private") == 0) {
	cplus_mode = CPLUS_PRIVATE;
      } else if (Strcmp(kind,"protected") == 0) {
	cplus_mode = CPLUS_PROTECTED;
      }
      n = nextSibling(n);
      continue;
    }

    add_oldname = Getattr(n,"sym:name");
    if ((add_oldname) || (Getattr(n,"sym:needs_symtab"))) {
      int old_inclass = -1;
      int old_cplus_mode = cplus_mode;   /* swig4ada: restored after a nested class, whose default access is its own. */
      Node *oldCurrentOuterClass = 0;
      if (add_oldname) {
	DohIncref(add_oldname);
	/*  Disable this, it prevents %rename to work with templates */
	/* If already renamed, we used that name  */
	/*
	if (Strcmp(add_oldname, Getattr(n,"name")) != 0) {
	  Delete(yyrename);
	  yyrename = Copy(add_oldname);
	}
	*/
      }
      Delattr(n,"sym:needs_symtab");
      Delattr(n,"sym:name");

      add_only_one = 1;
      add_symbols(n);

      if (Getattr(n,"partialargs")) {
	Swig_symbol_cadd(Getattr(n,"partialargs"),n);
      }
      add_only_one = 0;
      if (Equal(nodeType(n), "class")) {
	/* add_symbols() above sets "sym:symtab", so "unofficial:symtab" is not required */
	old_inclass = inclass;
	oldCurrentOuterClass = currentOuterClass;
	inclass = 1;
	currentOuterClass = n;
	if (Strcmp(Getattr(n,"kind"),"class") == 0) {
	  cplus_mode = CPLUS_PRIVATE;
	} else {
	  cplus_mode = CPLUS_PUBLIC;
	}
      }
      if (Equal(nodeType(n), "extend")) {
	emode = cplus_mode;
	cplus_mode = CPLUS_PUBLIC;
      }

      if (Getattr(n, "requires_symtab")) {
	Swig_symbol_newscope();
	Swig_symbol_setscopename(Getattr(n, "name"));
	Delete(Namespaceprefix);
	Namespaceprefix = Swig_symbol_qualifiedscopename(0);
      }

      add_symbols_copy(firstChild(n));

      if (Equal(nodeType(n), "extend")) {
	cplus_mode = emode;
      }
      if (Getattr(n,"requires_symtab")) {
	Setattr(n,"symtab", Swig_symbol_popscope());
	Delattr(n,"requires_symtab");
	Delete(Namespaceprefix);
	Namespaceprefix = Swig_symbol_qualifiedscopename(0);
      }
      if (add_oldname) {
	Delete(add_oldname);
	add_oldname = 0;
      }
      if (Equal(nodeType(n), "class")) {
	inclass = old_inclass;
	currentOuterClass = oldCurrentOuterClass;
	/* swig4ada: the members of the class which hold this one keep the access which they were declared with (a
	   member of a template instance after a private nested structure was taken to be public, and given a wrapper). */
	cplus_mode = old_cplus_mode;
      }
    } else {
      if (Equal(nodeType(n), "extend")) {
	emode = cplus_mode;
	cplus_mode = CPLUS_PUBLIC;
      }
      add_symbols_copy(firstChild(n));
      if (Equal(nodeType(n), "extend")) {
	cplus_mode = emode;
      }
    }
    n = nextSibling(n);
  }
}

/* Add in the "defaultargs" attribute for functions in instantiated templates.
 * n should be any instantiated template (class or start of linked list of functions). */
static void update_defaultargs(Node *n) {
  if (n) {
    Node *firstdefaultargs = n;
    update_defaultargs(firstChild(n));
    n = nextSibling(n);
    /* recursively loop through nodes of all types, but all we really need are the overloaded functions */
    while (n) {
      update_defaultargs(firstChild(n));
      if (!Getattr(n, "defaultargs")) {
	if (Getattr(n, "needs_defaultargs")) {
	  Setattr(n, "defaultargs", firstdefaultargs);
	  Delattr(n, "needs_defaultargs");
	} else {
	  firstdefaultargs = n;
	}
      } else {
	/* Functions added in with %extend (for specialized template classes) will already have default args patched up */
	assert(Getattr(n, "defaultargs") == firstdefaultargs);
      }
      n = nextSibling(n);
    }
  }
}

/* Check a set of declarations to see if any are pure-abstract */

static List *pure_abstracts(Node *n) {
  List *abstracts = 0;
  while (n) {
    if (Cmp(nodeType(n),"cdecl") == 0) {
      String *decl = Getattr(n,"decl");
      if (SwigType_isfunction(decl)) {
	String *init = Getattr(n,"value");
	if (Cmp(init,"0") == 0) {
	  if (!abstracts) {
	    abstracts = NewList();
	  }
	  Append(abstracts,n);
	  SetFlag(n,"abstract");
	}
      }
    } else if (Cmp(nodeType(n),"destructor") == 0) {
      if (Cmp(Getattr(n,"value"),"0") == 0) {
	if (!abstracts) {
	  abstracts = NewList();
	}
	Append(abstracts,n);
	SetFlag(n,"abstract");
      }
    }
    n = nextSibling(n);
  }
  return abstracts;
}

/* Recompute the "abstracts" attribute for the classes in instantiated templates, similarly to update_defaultargs() above. */
static void update_abstracts(Node *n) {
  for (; n; n = nextSibling(n)) {
    Node* const child = firstChild(n);
    if (!child)
      continue;

    update_abstracts(child);

    if (Getattr(n, "needs_abstracts")) {
      Setattr(n, "abstracts", pure_abstracts(child));
      Delattr(n, "needs_abstracts");
    }
  }
}

/* Make a classname */

static String *make_class_name(String *name) {
  String *nname = 0;
  String *prefix;
  if (Namespaceprefix) {
    nname= NewStringf("%s::%s", Namespaceprefix, name);
  } else {
    nname = NewString(name);
  }
  prefix = SwigType_istemplate_templateprefix(nname);
  if (prefix) {
    String *args, *qargs;
    args   = SwigType_templateargs(nname);
    qargs  = Swig_symbol_type_qualify(args,0);
    Append(prefix,qargs);
    Delete(nname);
    Delete(args);
    Delete(qargs);
    nname = prefix;
  }
  return nname;
}

/* Use typedef name as class name */

static void add_typedef_name(Node *n, Node *declnode, String *oldName, Symtab *cscope, String *scpname) {
  String *class_rename = 0;
  SwigType *decl = Getattr(declnode, "decl");
  if (!decl || !Len(decl)) {
    String *cname;
    String *tdscopename;
    String *class_scope = Swig_symbol_qualifiedscopename(cscope);
    String *name = Getattr(declnode, "name");
    cname = Copy(name);
    Setattr(n, "tdname", cname);
    tdscopename = class_scope ? NewStringf("%s::%s", class_scope, name) : Copy(name);
    class_rename = Getattr(n, "class_rename");
    if (class_rename && (Strcmp(class_rename, oldName) == 0))
      Setattr(n, "class_rename", NewString(name));
    if (!classes_typedefs) classes_typedefs = NewHash();
    if (!Equal(scpname, tdscopename) && !Getattr(classes_typedefs, tdscopename)) {
      Setattr(classes_typedefs, tdscopename, n);
    }
    Setattr(n, "decl", decl);
    Delete(class_scope);
    Delete(cname);
    Delete(tdscopename);
  }
}

/* If the class name is qualified.  We need to create or lookup namespace entries */

static Symtab *set_scope_to_global(void) {
  Symtab *symtab = Swig_symbol_global_scope();
  Swig_symbol_setscope(symtab);
  return symtab;
}
 
/* Remove the block braces, { and }, if the 'noblock' attribute is set.
 * Node *kw can be either a Hash or Parmlist. */
static String *remove_block(Node *kw, const String *inputcode) {
  String *modified_code = 0;
  while (kw) {
   String *name = Getattr(kw,"name");
   if (name && (Cmp(name,"noblock") == 0)) {
     char *cstr = Char(inputcode);
     int len = Len(inputcode);
     if (len && cstr[0] == '{') {
       --len; ++cstr; 
       if (len && cstr[len - 1] == '}') { --len; }
       /* we now remove the extra spaces */
       while (len && isspace((int)cstr[0])) { --len; ++cstr; }
       while (len && isspace((int)cstr[len - 1])) { --len; }
       modified_code = NewStringWithSize(cstr, len);
       break;
     }
   }
   kw = nextSibling(kw);
  }
  return modified_code;
}

/*
#define RESOLVE_DEBUG 1
*/
static Node *nscope = 0;
static Node *nscope_inner = 0;

/* Remove the scope prefix from cname and return the base name without the prefix.
 * The scopes required for the symbol name are resolved and/or created, if required.
 * For example AA::BB::CC as input returns CC and creates the namespace AA then inner 
 * namespace BB in the current scope. */
static String *resolve_create_node_scope(String *cname_in, int is_class_definition, int *errored) {
  Symtab *gscope = 0;
  Node *cname_node = 0;
  String *cname = cname_in;
  String *last = Swig_scopename_last(cname);
  nscope = 0;
  nscope_inner = 0;  
  *errored = 0;

  if (Strncmp(cname, "::", 2) == 0) {
    if (is_class_definition) {
      Swig_error(cparse_file, cparse_line, "Using the unary scope operator :: in class definition '%s' is invalid.\n", SwigType_namestr(cname));
      *errored = 1;
      return last;
    }
    cname = NewString(Char(cname) + 2);
  }
  if (is_class_definition) {
    /* Only lookup symbols which are in scope via a using declaration but not via a using directive.
       For example find y via 'using x::y' but not y via a 'using namespace x'. */
    cname_node = Swig_symbol_clookup_no_inherit(cname, 0);
    if (!cname_node) {
      Node *full_lookup_node = Swig_symbol_clookup(cname, 0);
      if (full_lookup_node) {
       /* This finds a symbol brought into scope via both a using directive and a using declaration. */
	Node *last_node = Swig_symbol_clookup_no_inherit(last, 0);
	if (last_node == full_lookup_node)
	  cname_node = last_node;
      }
    }
  } else {
    /* For %template, the template needs to be in scope via any means. */
    cname_node = Swig_symbol_clookup(cname, 0);
  }
#if RESOLVE_DEBUG
  if (!cname_node)
    Printf(stdout, "symbol does not yet exist (%d): [%s]\n", is_class_definition, cname_in);
  else
    Printf(stdout, "symbol does exist (%d): [%s]\n", is_class_definition, cname_in);
#endif

  if (cname_node) {
    /* The symbol has been defined already or is in another scope.
       If it is a weak symbol, it needs replacing and if it was brought into the current scope,
       the scope needs adjusting appropriately for the new symbol.
       Similarly for defined templates. */
    Symtab *symtab = Getattr(cname_node, "sym:symtab");
    Node *sym_weak = Getattr(cname_node, "sym:weak");
    if ((symtab && sym_weak) || Equal(nodeType(cname_node), "template")) {
      /* Check if the scope is the current scope */
      String *current_scopename = Swig_symbol_qualifiedscopename(0);
      String *found_scopename = Swig_symbol_qualifiedscopename(symtab);
      if (!current_scopename)
	current_scopename = NewString("");
      if (!found_scopename)
	found_scopename = NewString("");

      {
	int fail = 1;
	List *current_scopes = Swig_scopename_tolist(current_scopename);
	List *found_scopes = Swig_scopename_tolist(found_scopename);
        Iterator cit = First(current_scopes);
	Iterator fit = First(found_scopes);
#if RESOLVE_DEBUG
Printf(stdout, "comparing current: [%s] found: [%s]\n", current_scopename, found_scopename);
#endif
	for (; fit.item && cit.item; fit = Next(fit), cit = Next(cit)) {
	  String *current = cit.item;
	  String *found = fit.item;
#if RESOLVE_DEBUG
	  Printf(stdout, "  looping %s %s\n", current, found);
#endif
	  if (Strcmp(current, found) != 0)
	    break;
	}

	if (!cit.item) {
	  String *subscope = NewString("");
	  for (; fit.item; fit = Next(fit)) {
	    if (Len(subscope) > 0)
	      Append(subscope, "::");
	    Append(subscope, fit.item);
	  }
	  if (Len(subscope) > 0)
	    cname = NewStringf("%s::%s", subscope, last);
	  else
	    cname = Copy(last);
#if RESOLVE_DEBUG
	  Printf(stdout, "subscope to create: [%s] cname: [%s]\n", subscope, cname);
#endif
	  fail = 0;
	  Delete(subscope);
	} else {
	  if (is_class_definition) {
	    if (!fit.item) {
	      /* It is valid to define a new class with the same name as one forward declared in a parent scope */
	      fail = 0;
	    } else if (Swig_scopename_check(cname)) {
	      /* Classes defined with scope qualifiers must have a matching forward declaration in matching scope */
	      fail = 1;
	    } else {
	      /* This may let through some invalid cases */
	      fail = 0;
	    }
#if RESOLVE_DEBUG
	    Printf(stdout, "scope for class definition, fail: %d\n", fail);
#endif
	  } else {
#if RESOLVE_DEBUG
	    Printf(stdout, "no matching base scope for template\n");
#endif
	    fail = 1;
	  }
	}

	Delete(found_scopes);
	Delete(current_scopes);

	if (fail) {
	  String *cname_resolved = NewStringf("%s::%s", found_scopename, last);
	  Swig_error(cparse_file, cparse_line, "'%s' resolves to '%s' and was incorrectly instantiated in scope '%s' instead of within scope '%s'.\n",
	    SwigType_namestr(cname_in), SwigType_namestr(cname_resolved), SwigType_namestr(current_scopename), SwigType_namestr(found_scopename));
	  *errored = 1;
	  Delete(cname_resolved);
	}
      }

      Delete(current_scopename);
      Delete(found_scopename);
    }
  } else if (!is_class_definition) {
    /* A template instantiation requires a template to be found in scope */
    Swig_error(cparse_file, cparse_line, "Template '%s' undefined.\n", SwigType_namestr(cname_in));
    *errored = 1;
  }

  if (*errored)
    return last;

  if (Swig_scopename_check(cname) && !*errored) {
    Node   *ns;
    String *prefix = Swig_scopename_prefix(cname);
    if (Len(prefix) == 0) {
      String *base = Copy(last);
      /* Use the global scope, but we need to add a 'global' namespace.  */
      if (!gscope) gscope = set_scope_to_global();
      /* note that this namespace is not the "unnamed" one,
	 and we don't use Setattr(nscope,"name", ""),
	 because the unnamed namespace is private */
      nscope = new_node("namespace");
      Setattr(nscope,"symtab", gscope);;
      nscope_inner = nscope;
      Delete(last);
      return base;
    }
    /* Try to locate the scope */
    ns = Swig_symbol_clookup(prefix,0);
    if (!ns) {
      Swig_error(cparse_file, cparse_line, "Undefined scope '%s'\n", SwigType_namestr(prefix));
      *errored = 1;
    } else {
      Symtab *nstab = Getattr(ns,"symtab");
      if (!nstab) {
	Swig_error(cparse_file, cparse_line, "'%s' is not defined as a valid scope.\n", SwigType_namestr(prefix));
	*errored = 1;
	ns = 0;
      } else {
	/* Check if the node scope is the current scope */
	String *tname = Swig_symbol_qualifiedscopename(0);
	String *nname = Swig_symbol_qualifiedscopename(nstab);
	if (tname && (Strcmp(tname,nname) == 0)) {
	  ns = 0;
	  cname = Copy(last);
	}
	Delete(tname);
	Delete(nname);
      }
      if (ns) {
	/* we will try to create a new node using the namespaces we
	   can find in the scope name */
	List *scopes = Swig_scopename_tolist(prefix);
	String *sname;
	Iterator si;

	for (si = First(scopes); si.item; si = Next(si)) {
	  Node *ns1,*ns2;
	  sname = si.item;
	  ns1 = Swig_symbol_clookup(sname,0);
	  assert(ns1);
	  if (Strcmp(nodeType(ns1),"namespace") == 0) {
	    if (Getattr(ns1,"alias")) {
	      ns1 = Getattr(ns1,"namespace");
	    }
	  } else {
	    /* now this last part is a class */
	    si = Next(si);
	    /*  or a nested class tree, which is unrolled here */
	    for (; si.item; si = Next(si)) {
	      if (si.item) {
		Printf(sname,"::%s",si.item);
	      }
	    }
	    /* we get the 'inner' class */
	    nscope_inner = Swig_symbol_clookup(sname,0);
	    /* set the scope to the inner class */
	    Swig_symbol_setscope(Getattr(nscope_inner,"symtab"));
	    /* save the last namespace prefix */
	    Delete(Namespaceprefix);
	    Namespaceprefix = Swig_symbol_qualifiedscopename(0);
	    /* and return the node name, including the inner class prefix */
	    break;
	  }
	  /* here we just populate the namespace tree as usual */
	  ns2 = new_node("namespace");
	  Setattr(ns2,"name",sname);
	  Setattr(ns2,"symtab", Getattr(ns1,"symtab"));
	  add_symbols(ns2);
	  Swig_symbol_setscope(Getattr(ns1,"symtab"));
	  Delete(Namespaceprefix);
	  Namespaceprefix = Swig_symbol_qualifiedscopename(0);
	  if (nscope_inner) {
	    if (Getattr(nscope_inner,"symtab") != Getattr(ns2,"symtab")) {
	      appendChild(nscope_inner,ns2);
	      Delete(ns2);
	    }
	  }
	  nscope_inner = ns2;
	  if (!nscope) nscope = ns2;
	}
	cname = Copy(last);
	Delete(scopes);
      }
    }
    Delete(prefix);
  }
  Delete(last);

  return cname;
}
 
/* look for simple typedef name in typedef list */
static String *try_to_find_a_name_for_unnamed_structure(const String *storage, Node *decls) {
  String *name = 0;
  Node *n = decls;
  if (storage && Equal(storage, "typedef")) {
    for (; n; n = nextSibling(n)) {
      if (!Len(Getattr(n, "decl"))) {
	name = Copy(Getattr(n, "name"));
	break;
      }
    }
  }
  return name;
}

/* traverse copied tree segment, and update outer class links*/
static void update_nested_classes(Node *n)
{
  Node *c = firstChild(n);
  while (c) {
    if (Getattr(c, "nested:outer"))
      Setattr(c, "nested:outer", n);
    update_nested_classes(c);
    c = nextSibling(c);
  }
}

/* -----------------------------------------------------------------------------
 * mark_nested_ignore()
 *
 * Mark the type definitions nested inside an ignored nested class (such as a nested
 * enum or class) to be ignored too, so that the target languages treat references to
 * them the same as when the nested class was a forward declaration. Function and
 * variable declarations (cdecl) are left alone, so that, for example, a method brought
 * into a derived class by a using declaration is still wrapped.
 * ----------------------------------------------------------------------------- */

static void mark_nested_ignore(Node *n, int set_nested_ignore) {
  Node *c;
  for (c = firstChild(n); c; c = nextSibling(c)) {
    if (!Equal(nodeType(c), "cdecl")) {
      SetFlag(c, "feature:ignore");
      if (set_nested_ignore)
        SetFlag(c, "nested:ignore");
    }
    mark_nested_ignore(c, set_nested_ignore);
  }
}

/* -----------------------------------------------------------------------------
 * nested_forward_declaration()
 *
 * Nested struct handling for C++ code if the nested classes are disabled.
 * Create the nested class/struct/union as a forward declaration.
 * ----------------------------------------------------------------------------- */

static Node *nested_forward_declaration(const String *storage, const String *kind, String *sname, String *name, Node *cpp_opt_declarators) {
  Node *nn = 0;

  if (sname) {
    /* Add forward declaration of the nested type */
    Node *n = new_node("classforward");
    Setattr(n, "kind", kind);
    Setattr(n, "name", sname);
    Setattr(n, "storage", storage);
    Setattr(n, "sym:weak", "1");
    SetFlag(n, "nested:forward");
    add_symbols(n);
    nn = n;
  }

  /* Add any variable instances. Also add in any further typedefs of the nested type.
     Note that anonymous typedefs (eg typedef struct {...} a, b;) are treated as class forward declarations */
  if (cpp_opt_declarators) {
    int storage_typedef = (storage && Equal(storage, "typedef"));
    int variable_of_anonymous_type = !sname && !storage_typedef;
    if (!variable_of_anonymous_type) {
      int anonymous_typedef = !sname && storage_typedef;
      Node *n = cpp_opt_declarators;
      SwigType *type = name;
      while (n) {
	Setattr(n, "type", type);
	Setattr(n, "storage", storage);
	if (anonymous_typedef) {
	  Setattr(n, "nodeType", "classforward");
	  Setattr(n, "sym:weak", "1");
	}
	n = nextSibling(n);
      }
      add_symbols(cpp_opt_declarators);

      if (nn) {
	set_nextSibling(nn, cpp_opt_declarators);
      } else {
	nn = cpp_opt_declarators;
      }
    }
  }

  if (!currentOuterClass || !GetFlag(currentOuterClass, "nested")) {
    if (nn && Equal(nodeType(nn), "classforward")) {
      Node *n = nn;
      if (!GetFlag(n, "feature:ignore")) {
	SWIG_WARN_NODE_BEGIN(n);
	Swig_warning(WARN_PARSE_NAMED_NESTED_CLASS, cparse_file, cparse_line, "Nested %s not currently supported (%s ignored)\n", kind, SwigType_namestr(sname ? sname : name));
	SWIG_WARN_NODE_END(n);
      }
    } else {
      Swig_warning(WARN_PARSE_UNNAMED_NESTED_CLASS, cparse_file, cparse_line, "Nested %s not currently supported (ignored).\n", kind);
      if (currentOuterClass)
	SetFlag(currentOuterClass, "has_unnamed_member");
    }
  }

  return nn;
}


Node *Swig_cparse(File *f) {
  scanner_file(f);
  top = 0;
  if (yyparse() == 2) {
    Swig_error(cparse_file, cparse_line, "Parser exceeded stack depth or ran out of memory\n");
    Exit(EXIT_FAILURE);
  }
  return (Node *)top;
}

static void single_new_feature(const char *featurename, String *val, Hash *featureattribs, char *declaratorid, SwigType *type, ParmList *declaratorparms, String *qualifier) {
  String *fname;
  String *name;
  String *fixname;
  SwigType *t = Copy(type);

  /* Printf(stdout, "single_new_feature: [%s] [%s] [%s] [%s] [%s] [%s]\n", featurename, val, declaratorid, t, ParmList_str_defaultargs(declaratorparms), qualifier); */

  fname = NewStringf("feature:%s",featurename);
  if (declaratorid) {
    fixname = feature_identifier_fix(declaratorid);
  } else {
    fixname = NewStringEmpty();
  }
  if (Namespaceprefix) {
    name = NewStringf("%s::%s",Namespaceprefix, fixname);
  } else {
    name = fixname;
  }

  if (declaratorparms) Setmeta(val,"parms",declaratorparms);
  if (!Len(t)) t = 0;
  if (t) {
    if (qualifier) SwigType_push(t,qualifier);
    if (SwigType_isfunction(t)) {
      SwigType *decl = SwigType_pop_function(t);
      if (SwigType_ispointer(t)) {
	String *nname = NewStringf("*%s",name);
	Swig_feature_set(Swig_cparse_features(), nname, decl, fname, val, featureattribs);
	Delete(nname);
      } else {
	Swig_feature_set(Swig_cparse_features(), name, decl, fname, val, featureattribs);
      }
      Delete(decl);
    } else if (SwigType_ispointer(t)) {
      String *nname = NewStringf("*%s",name);
      Swig_feature_set(Swig_cparse_features(),nname,0,fname,val, featureattribs);
      Delete(nname);
    }
  } else {
    /* Global feature, that is, feature not associated with any particular symbol */
    Swig_feature_set(Swig_cparse_features(),name,0,fname,val, featureattribs);
  }
  Delete(fname);
  Delete(name);
}

/* Add a new feature to the Hash. Additional features are added if the feature has a parameter list (declaratorparms)
 * and one or more of the parameters have a default argument. An extra feature is added for each defaulted parameter,
 * simulating the equivalent overloaded method. */
static void new_feature(const char *featurename, String *val, Hash *featureattribs, char *declaratorid, SwigType *type, ParmList *declaratorparms, String *qualifier) {

  ParmList *declparms = declaratorparms;

  /* remove the { and } braces if the noblock attribute is set */
  String *newval = remove_block(featureattribs, val);
  val = newval ? newval : val;

  /* Add the feature */
  single_new_feature(featurename, val, featureattribs, declaratorid, type, declaratorparms, qualifier);

  /* Add extra features if there are default parameters in the parameter list */
  if (type) {
    while (declparms) {
      if (ParmList_has_defaultargs(declparms)) {

        /* Create a parameter list for the new feature by copying all
           but the last (defaulted) parameter */
        ParmList* newparms = CopyParmListMax(declparms, ParmList_len(declparms)-1);

        /* Create new declaration - with the last parameter removed */
        SwigType *newtype = Copy(type);
        Delete(SwigType_pop_function(newtype)); /* remove the old parameter list from newtype */
        SwigType_add_function(newtype,newparms);

        single_new_feature(featurename, Copy(val), featureattribs, declaratorid, newtype, newparms, qualifier);
        declparms = newparms;
      } else {
        declparms = 0;
      }
    }
  }
}

/* check if a function declaration is a plain C object */
static int is_cfunction(Node *n) {
  if (!cparse_cplusplus || cparse_externc)
    return 1;
  if (Swig_storage_isexternc(n)) {
    return 1;
  }
  return 0;
}

/* If the Node is a function with parameters, check to see if any of the parameters
 * have default arguments. If so create a new function for each defaulted argument. 
 * The additional functions form a linked list of nodes with the head being the original Node n. */
static void default_arguments(Node *n) {
  Node *function = n;

  if (function) {
    ParmList *varargs = Getattr(function,"feature:varargs");
    if (varargs) {
      /* Handles the %varargs directive by looking for "feature:varargs" and 
       * substituting ... with an alternative set of arguments.  */
      Parm     *p = Getattr(function,"parms");
      Parm     *pp = 0;
      while (p) {
	SwigType *t = Getattr(p,"type");
	if (Strcmp(t,"v(...)") == 0) {
	  if (pp) {
	    ParmList *cv = Copy(varargs);
	    set_nextSibling(pp,cv);
	    Delete(cv);
	  } else {
	    ParmList *cv =  Copy(varargs);
	    Setattr(function,"parms", cv);
	    Delete(cv);
	  }
	  break;
	}
	pp = p;
	p = nextSibling(p);
      }
    }

    /* Do not add in functions if kwargs is being used or if user wants old default argument wrapping
       (one wrapped method per function irrespective of number of default arguments) */
    if (compact_default_args 
	|| is_cfunction(function) 
	|| GetFlag(function,"feature:compactdefaultargs") 
	|| (GetFlag(function,"feature:kwargs") && kwargs_supported)) {
      ParmList *p = Getattr(function,"parms");
      if (p) 
        Setattr(p,"compactdefargs", "1"); /* mark parameters for special handling */
      function = 0; /* don't add in extra methods */
    }
  }

  while (function) {
    ParmList *parms = Getattr(function,"parms");
    if (ParmList_has_defaultargs(parms)) {

      /* Create a parameter list for the new function by copying all
         but the last (defaulted) parameter */
      ParmList* newparms = CopyParmListMax(parms,ParmList_len(parms)-1);

      /* Create new function and add to symbol table */
      {
	SwigType *ntype = Copy(nodeType(function));
	char *cntype = Char(ntype);
        Node *new_function = new_node(ntype);
        SwigType *decl = Copy(Getattr(function,"decl"));
        int constqualifier = SwigType_isconst(decl);
	String *ccode = Copy(Getattr(function,"code"));
	String *cstorage = Copy(Getattr(function,"storage"));
	String *cvalue = Copy(Getattr(function,"value"));
	SwigType *ctype = Copy(Getattr(function,"type"));
	String *cthrow = Copy(Getattr(function,"throw"));

        Delete(SwigType_pop_function(decl)); /* remove the old parameter list from decl */
        SwigType_add_function(decl,newparms);
        if (constqualifier)
          SwigType_add_qualifier(decl,"const");

        Setattr(new_function,"name", Getattr(function,"name"));
        Setattr(new_function,"code", ccode);
        Setattr(new_function,"decl", decl);
        Setattr(new_function,"parms", newparms);
        Setattr(new_function,"storage", cstorage);
        Setattr(new_function,"value", cvalue);
        Setattr(new_function,"type", ctype);
        Setattr(new_function,"throw", cthrow);

	Delete(ccode);
	Delete(cstorage);
	Delete(cvalue);
	Delete(ctype);
	Delete(cthrow);
	Delete(decl);

        {
          Node *throws = Getattr(function,"throws");
	  ParmList *pl = CopyParmList(throws);
          if (throws) Setattr(new_function,"throws",pl);
	  Delete(pl);
        }

        /* copy specific attributes for global (or in a namespace) template functions - these are not class template methods */
        if (strcmp(cntype,"template") == 0) {
          Node *templatetype = Getattr(function,"templatetype");
          Node *symtypename = Getattr(function,"sym:typename");
          Parm *templateparms = Getattr(function,"templateparms");
          if (templatetype) {
	    Node *tmp = Copy(templatetype);
	    Setattr(new_function,"templatetype",tmp);
	    Delete(tmp);
	  }
          if (symtypename) {
	    Node *tmp = Copy(symtypename);
	    Setattr(new_function,"sym:typename",tmp);
	    Delete(tmp);
	  }
          if (templateparms) {
	    Parm *tmp = CopyParmList(templateparms);
	    Setattr(new_function,"templateparms",tmp);
	    Delete(tmp);
	  }
        } else if (strcmp(cntype,"constructor") == 0) {
          /* only copied for constructors as this is not a user defined feature - it is hard coded in the parser */
          if (GetFlag(function,"feature:new")) SetFlag(new_function,"feature:new");
        }

        add_symbols(new_function);
        /* mark added functions as ones with overloaded parameters and point to the parsed method */
        Setattr(new_function,"defaultargs", n);

        /* Point to the new function, extending the linked list */
        set_nextSibling(function, new_function);
	Delete(new_function);
        function = new_function;
	
	Delete(ntype);
      }
    } else {
      function = 0;
    }
  }
}

/* -----------------------------------------------------------------------------
 * mark_nodes_as_extend()
 *
 * Used by the %extend to mark subtypes with "feature:extend".
 * template instances declared within %extend are skipped
 * ----------------------------------------------------------------------------- */

static void mark_nodes_as_extend(Node *n) {
  for (; n; n = nextSibling(n)) {
    if (Getattr(n, "template") && Strcmp(nodeType(n), "class") == 0)
      continue;
    /* Fix me: extend is not a feature. Replace with isextendmember? */
    Setattr(n, "feature:extend", "1");
    mark_nodes_as_extend(firstChild(n));
  }
}

/* -----------------------------------------------------------------------------
 * add_qualifier_to_declarator()
 *
 * Normally the qualifier is pushed on to the front of the type.
 * Adding a qualifier to a pointer to member function is a special case.
 * For example       : typedef double (Cls::*pmf)(void) const;
 * The qualifier is  : q(const).
 * The declarator is : m(Cls).f(void).
 * We need           : m(Cls).q(const).f(void).
 * ----------------------------------------------------------------------------- */

static String *add_qualifier_to_declarator(SwigType *type, SwigType *qualifier) {
  int is_pointer_to_member_function = 0;
  String *decl = Copy(type);
  String *poppedtype = NewString("");
  assert(qualifier);

  while (decl) {
    if (SwigType_ismemberpointer(decl)) {
      String *memberptr = SwigType_pop(decl);
      if (SwigType_isfunction(decl)) {
	is_pointer_to_member_function = 1;
	SwigType_push(decl, qualifier);
	SwigType_push(decl, memberptr);
	Insert(decl, 0, poppedtype);
	Delete(memberptr);
	break;
      } else {
	Append(poppedtype, memberptr);
      }
      Delete(memberptr);
    } else {
      String *popped = SwigType_pop(decl);
      if (!popped)
	break;
      Append(poppedtype, popped);
      Delete(popped);
    }
  }

  if (!is_pointer_to_member_function) {
    Delete(decl);
    decl = Copy(type);
    SwigType_push(decl, qualifier);
  }

  Delete(poppedtype);
  return decl;
}


#line 1899 "CParse/parser.c"

# ifndef YY_CAST
#  ifdef __cplusplus
#   define YY_CAST(Type, Val) static_cast<Type> (Val)
#   define YY_REINTERPRET_CAST(Type, Val) reinterpret_cast<Type> (Val)
#  else
#   define YY_CAST(Type, Val) ((Type) (Val))
#   define YY_REINTERPRET_CAST(Type, Val) ((Type) (Val))
#  endif
# endif
# ifndef YY_NULLPTR
#  if defined __cplusplus
#   if 201103L <= __cplusplus
#    define YY_NULLPTR nullptr
#   else
#    define YY_NULLPTR 0
#   endif
#  else
#   define YY_NULLPTR ((void*)0)
#  endif
# endif

#include "parser.h"
/* Symbol kind.  */
enum yysymbol_kind_t
{
  YYSYMBOL_YYEMPTY = -2,
  YYSYMBOL_YYEOF = 0,                      /* END  */
  YYSYMBOL_YYerror = 1,                    /* error  */
  YYSYMBOL_YYUNDEF = 2,                    /* "invalid token"  */
  YYSYMBOL_ID = 3,                         /* ID  */
  YYSYMBOL_HBLOCK = 4,                     /* HBLOCK  */
  YYSYMBOL_POUND = 5,                      /* POUND  */
  YYSYMBOL_STRING = 6,                     /* STRING  */
  YYSYMBOL_WSTRING = 7,                    /* WSTRING  */
  YYSYMBOL_INCLUDE = 8,                    /* INCLUDE  */
  YYSYMBOL_IMPORT = 9,                     /* IMPORT  */
  YYSYMBOL_INSERT = 10,                    /* INSERT  */
  YYSYMBOL_CHARCONST = 11,                 /* CHARCONST  */
  YYSYMBOL_WCHARCONST = 12,                /* WCHARCONST  */
  YYSYMBOL_NUM_INT = 13,                   /* NUM_INT  */
  YYSYMBOL_NUM_DOUBLE = 14,                /* NUM_DOUBLE  */
  YYSYMBOL_NUM_FLOAT = 15,                 /* NUM_FLOAT  */
  YYSYMBOL_NUM_LONGDOUBLE = 16,            /* NUM_LONGDOUBLE  */
  YYSYMBOL_NUM_UNSIGNED = 17,              /* NUM_UNSIGNED  */
  YYSYMBOL_NUM_LONG = 18,                  /* NUM_LONG  */
  YYSYMBOL_NUM_ULONG = 19,                 /* NUM_ULONG  */
  YYSYMBOL_NUM_LONGLONG = 20,              /* NUM_LONGLONG  */
  YYSYMBOL_NUM_ULONGLONG = 21,             /* NUM_ULONGLONG  */
  YYSYMBOL_NUM_BOOL = 22,                  /* NUM_BOOL  */
  YYSYMBOL_TYPEDEF = 23,                   /* TYPEDEF  */
  YYSYMBOL_TYPE_INT = 24,                  /* TYPE_INT  */
  YYSYMBOL_TYPE_UNSIGNED = 25,             /* TYPE_UNSIGNED  */
  YYSYMBOL_TYPE_SHORT = 26,                /* TYPE_SHORT  */
  YYSYMBOL_TYPE_LONG = 27,                 /* TYPE_LONG  */
  YYSYMBOL_TYPE_FLOAT = 28,                /* TYPE_FLOAT  */
  YYSYMBOL_TYPE_DOUBLE = 29,               /* TYPE_DOUBLE  */
  YYSYMBOL_TYPE_CHAR = 30,                 /* TYPE_CHAR  */
  YYSYMBOL_TYPE_WCHAR = 31,                /* TYPE_WCHAR  */
  YYSYMBOL_TYPE_VOID = 32,                 /* TYPE_VOID  */
  YYSYMBOL_TYPE_SIGNED = 33,               /* TYPE_SIGNED  */
  YYSYMBOL_TYPE_BOOL = 34,                 /* TYPE_BOOL  */
  YYSYMBOL_TYPE_COMPLEX = 35,              /* TYPE_COMPLEX  */
  YYSYMBOL_TYPE_NON_ISO_INT8 = 36,         /* TYPE_NON_ISO_INT8  */
  YYSYMBOL_TYPE_NON_ISO_INT16 = 37,        /* TYPE_NON_ISO_INT16  */
  YYSYMBOL_TYPE_NON_ISO_INT32 = 38,        /* TYPE_NON_ISO_INT32  */
  YYSYMBOL_TYPE_NON_ISO_INT64 = 39,        /* TYPE_NON_ISO_INT64  */
  YYSYMBOL_LPAREN = 40,                    /* LPAREN  */
  YYSYMBOL_RPAREN = 41,                    /* RPAREN  */
  YYSYMBOL_COMMA = 42,                     /* COMMA  */
  YYSYMBOL_SEMI = 43,                      /* SEMI  */
  YYSYMBOL_EXTERN = 44,                    /* EXTERN  */
  YYSYMBOL_LBRACE = 45,                    /* LBRACE  */
  YYSYMBOL_RBRACE = 46,                    /* RBRACE  */
  YYSYMBOL_PERIOD = 47,                    /* PERIOD  */
  YYSYMBOL_ELLIPSIS = 48,                  /* ELLIPSIS  */
  YYSYMBOL_CONST_QUAL = 49,                /* CONST_QUAL  */
  YYSYMBOL_VOLATILE = 50,                  /* VOLATILE  */
  YYSYMBOL_REGISTER = 51,                  /* REGISTER  */
  YYSYMBOL_STRUCT = 52,                    /* STRUCT  */
  YYSYMBOL_UNION = 53,                     /* UNION  */
  YYSYMBOL_EQUAL = 54,                     /* EQUAL  */
  YYSYMBOL_SIZEOF = 55,                    /* SIZEOF  */
  YYSYMBOL_ALIGNOF = 56,                   /* ALIGNOF  */
  YYSYMBOL_MODULE = 57,                    /* MODULE  */
  YYSYMBOL_LBRACKET = 58,                  /* LBRACKET  */
  YYSYMBOL_RBRACKET = 59,                  /* RBRACKET  */
  YYSYMBOL_BEGINFILE = 60,                 /* BEGINFILE  */
  YYSYMBOL_ENDOFFILE = 61,                 /* ENDOFFILE  */
  YYSYMBOL_CONSTANT = 62,                  /* CONSTANT  */
  YYSYMBOL_RENAME = 63,                    /* RENAME  */
  YYSYMBOL_NAMEWARN = 64,                  /* NAMEWARN  */
  YYSYMBOL_EXTEND = 65,                    /* EXTEND  */
  YYSYMBOL_PRAGMA = 66,                    /* PRAGMA  */
  YYSYMBOL_FEATURE = 67,                   /* FEATURE  */
  YYSYMBOL_VARARGS = 68,                   /* VARARGS  */
  YYSYMBOL_ENUM = 69,                      /* ENUM  */
  YYSYMBOL_CLASS = 70,                     /* CLASS  */
  YYSYMBOL_TYPENAME = 71,                  /* TYPENAME  */
  YYSYMBOL_PRIVATE = 72,                   /* PRIVATE  */
  YYSYMBOL_PUBLIC = 73,                    /* PUBLIC  */
  YYSYMBOL_PROTECTED = 74,                 /* PROTECTED  */
  YYSYMBOL_COLON = 75,                     /* COLON  */
  YYSYMBOL_STATIC = 76,                    /* STATIC  */
  YYSYMBOL_VIRTUAL = 77,                   /* VIRTUAL  */
  YYSYMBOL_FRIEND = 78,                    /* FRIEND  */
  YYSYMBOL_THROW = 79,                     /* THROW  */
  YYSYMBOL_CATCH = 80,                     /* CATCH  */
  YYSYMBOL_EXPLICIT = 81,                  /* EXPLICIT  */
  YYSYMBOL_STATIC_ASSERT = 82,             /* STATIC_ASSERT  */
  YYSYMBOL_CONSTEXPR = 83,                 /* CONSTEXPR  */
  YYSYMBOL_THREAD_LOCAL = 84,              /* THREAD_LOCAL  */
  YYSYMBOL_DECLTYPE = 85,                  /* DECLTYPE  */
  YYSYMBOL_AUTO = 86,                      /* AUTO  */
  YYSYMBOL_NOEXCEPT = 87,                  /* NOEXCEPT  */
  YYSYMBOL_OVERRIDE = 88,                  /* OVERRIDE  */
  YYSYMBOL_FINAL = 89,                     /* FINAL  */
  YYSYMBOL_CONCEPT = 90,                   /* CONCEPT  */
  YYSYMBOL_REQUIRES = 91,                  /* REQUIRES  */
  YYSYMBOL_USING = 92,                     /* USING  */
  YYSYMBOL_NAMESPACE = 93,                 /* NAMESPACE  */
  YYSYMBOL_NATIVE = 94,                    /* NATIVE  */
  YYSYMBOL_INLINE = 95,                    /* INLINE  */
  YYSYMBOL_TYPEMAP = 96,                   /* TYPEMAP  */
  YYSYMBOL_ECHO = 97,                      /* ECHO  */
  YYSYMBOL_APPLY = 98,                     /* APPLY  */
  YYSYMBOL_CLEAR = 99,                     /* CLEAR  */
  YYSYMBOL_SWIGTEMPLATE = 100,             /* SWIGTEMPLATE  */
  YYSYMBOL_FRAGMENT = 101,                 /* FRAGMENT  */
  YYSYMBOL_WARN = 102,                     /* WARN  */
  YYSYMBOL_LESSTHAN = 103,                 /* LESSTHAN  */
  YYSYMBOL_GREATERTHAN = 104,              /* GREATERTHAN  */
  YYSYMBOL_DELETE_KW = 105,                /* DELETE_KW  */
  YYSYMBOL_DEFAULT = 106,                  /* DEFAULT  */
  YYSYMBOL_LESSTHANOREQUALTO = 107,        /* LESSTHANOREQUALTO  */
  YYSYMBOL_GREATERTHANOREQUALTO = 108,     /* GREATERTHANOREQUALTO  */
  YYSYMBOL_EQUALTO = 109,                  /* EQUALTO  */
  YYSYMBOL_NOTEQUALTO = 110,               /* NOTEQUALTO  */
  YYSYMBOL_LESSEQUALGREATER = 111,         /* LESSEQUALGREATER  */
  YYSYMBOL_ARROW = 112,                    /* ARROW  */
  YYSYMBOL_QUESTIONMARK = 113,             /* QUESTIONMARK  */
  YYSYMBOL_TYPES = 114,                    /* TYPES  */
  YYSYMBOL_PARMS = 115,                    /* PARMS  */
  YYSYMBOL_NONID = 116,                    /* NONID  */
  YYSYMBOL_DSTAR = 117,                    /* DSTAR  */
  YYSYMBOL_DCNOT = 118,                    /* DCNOT  */
  YYSYMBOL_TEMPLATE = 119,                 /* TEMPLATE  */
  YYSYMBOL_OPERATOR = 120,                 /* OPERATOR  */
  YYSYMBOL_CONVERSIONOPERATOR = 121,       /* CONVERSIONOPERATOR  */
  YYSYMBOL_PARSETYPE = 122,                /* PARSETYPE  */
  YYSYMBOL_PARSEPARM = 123,                /* PARSEPARM  */
  YYSYMBOL_PARSEPARMS = 124,               /* PARSEPARMS  */
  YYSYMBOL_DOXYGENSTRING = 125,            /* DOXYGENSTRING  */
  YYSYMBOL_DOXYGENPOSTSTRING = 126,        /* DOXYGENPOSTSTRING  */
  YYSYMBOL_LOR = 127,                      /* LOR  */
  YYSYMBOL_LAND = 128,                     /* LAND  */
  YYSYMBOL_OR = 129,                       /* OR  */
  YYSYMBOL_XOR = 130,                      /* XOR  */
  YYSYMBOL_AND = 131,                      /* AND  */
  YYSYMBOL_LSHIFT = 132,                   /* LSHIFT  */
  YYSYMBOL_RSHIFT = 133,                   /* RSHIFT  */
  YYSYMBOL_PLUS = 134,                     /* PLUS  */
  YYSYMBOL_MINUS = 135,                    /* MINUS  */
  YYSYMBOL_STAR = 136,                     /* STAR  */
  YYSYMBOL_SLASH = 137,                    /* SLASH  */
  YYSYMBOL_MODULO = 138,                   /* MODULO  */
  YYSYMBOL_UMINUS = 139,                   /* UMINUS  */
  YYSYMBOL_NOT = 140,                      /* NOT  */
  YYSYMBOL_LNOT = 141,                     /* LNOT  */
  YYSYMBOL_CAST = 142,                     /* CAST  */
  YYSYMBOL_DCOLON = 143,                   /* DCOLON  */
  YYSYMBOL_YYACCEPT = 144,                 /* $accept  */
  YYSYMBOL_program = 145,                  /* program  */
  YYSYMBOL_interface = 146,                /* interface  */
  YYSYMBOL_declaration = 147,              /* declaration  */
  YYSYMBOL_swig_directive = 148,           /* swig_directive  */
  YYSYMBOL_extend_directive = 149,         /* extend_directive  */
  YYSYMBOL_150_1 = 150,                    /* $@1  */
  YYSYMBOL_apply_directive = 151,          /* apply_directive  */
  YYSYMBOL_clear_directive = 152,          /* clear_directive  */
  YYSYMBOL_constant_directive = 153,       /* constant_directive  */
  YYSYMBOL_echo_directive = 154,           /* echo_directive  */
  YYSYMBOL_stringtype = 155,               /* stringtype  */
  YYSYMBOL_fname = 156,                    /* fname  */
  YYSYMBOL_fragment_directive = 157,       /* fragment_directive  */
  YYSYMBOL_include_directive = 158,        /* include_directive  */
  YYSYMBOL_159_2 = 159,                    /* @2  */
  YYSYMBOL_includetype = 160,              /* includetype  */
  YYSYMBOL_inline_directive = 161,         /* inline_directive  */
  YYSYMBOL_insert_directive = 162,         /* insert_directive  */
  YYSYMBOL_module_directive = 163,         /* module_directive  */
  YYSYMBOL_native_directive = 164,         /* native_directive  */
  YYSYMBOL_pragma_directive = 165,         /* pragma_directive  */
  YYSYMBOL_pragma_arg = 166,               /* pragma_arg  */
  YYSYMBOL_pragma_lang = 167,              /* pragma_lang  */
  YYSYMBOL_rename_directive = 168,         /* rename_directive  */
  YYSYMBOL_rename_namewarn = 169,          /* rename_namewarn  */
  YYSYMBOL_feature_directive = 170,        /* feature_directive  */
  YYSYMBOL_stringbracesemi = 171,          /* stringbracesemi  */
  YYSYMBOL_featattr = 172,                 /* featattr  */
  YYSYMBOL_varargs_directive = 173,        /* varargs_directive  */
  YYSYMBOL_varargs_parms = 174,            /* varargs_parms  */
  YYSYMBOL_typemap_directive = 175,        /* typemap_directive  */
  YYSYMBOL_typemap_type = 176,             /* typemap_type  */
  YYSYMBOL_tm_list = 177,                  /* tm_list  */
  YYSYMBOL_tm_list_builder = 178,          /* tm_list_builder  */
  YYSYMBOL_typemap_parm = 179,             /* typemap_parm  */
  YYSYMBOL_types_directive = 180,          /* types_directive  */
  YYSYMBOL_template_directive = 181,       /* template_directive  */
  YYSYMBOL_warn_directive = 182,           /* warn_directive  */
  YYSYMBOL_c_declaration = 183,            /* c_declaration  */
  YYSYMBOL_184_3 = 184,                    /* $@3  */
  YYSYMBOL_c_decl = 185,                   /* c_decl  */
  YYSYMBOL_c_decl_tail = 186,              /* c_decl_tail  */
  YYSYMBOL_initializer = 187,              /* initializer  */
  YYSYMBOL_cpp_alternate_rettype = 188,    /* cpp_alternate_rettype  */
  YYSYMBOL_cpp_lambda_decl = 189,          /* cpp_lambda_decl  */
  YYSYMBOL_lambda_introducer = 190,        /* lambda_introducer  */
  YYSYMBOL_lambda_template = 191,          /* lambda_template  */
  YYSYMBOL_lambda_body = 192,              /* lambda_body  */
  YYSYMBOL_lambda_tail = 193,              /* lambda_tail  */
  YYSYMBOL_194_4 = 194,                    /* $@4  */
  YYSYMBOL_c_enum_key = 195,               /* c_enum_key  */
  YYSYMBOL_c_enum_inherit = 196,           /* c_enum_inherit  */
  YYSYMBOL_c_enum_forward_decl = 197,      /* c_enum_forward_decl  */
  YYSYMBOL_c_enum_decl = 198,              /* c_enum_decl  */
  YYSYMBOL_c_constructor_decl = 199,       /* c_constructor_decl  */
  YYSYMBOL_deduction_guide = 200,          /* deduction_guide  */
  YYSYMBOL_cpp_declaration = 201,          /* cpp_declaration  */
  YYSYMBOL_cpp_class_decl = 202,           /* cpp_class_decl  */
  YYSYMBOL_203_5 = 203,                    /* @5  */
  YYSYMBOL_204_6 = 204,                    /* @6  */
  YYSYMBOL_cpp_opt_declarators = 205,      /* cpp_opt_declarators  */
  YYSYMBOL_cpp_forward_class_decl = 206,   /* cpp_forward_class_decl  */
  YYSYMBOL_cpp_template_decl = 207,        /* cpp_template_decl  */
  YYSYMBOL_208_7 = 208,                    /* $@7  */
  YYSYMBOL_cpp_template_possible = 209,    /* cpp_template_possible  */
  YYSYMBOL_cpp_concept_decl = 210,         /* cpp_concept_decl  */
  YYSYMBOL_template_parms = 211,           /* template_parms  */
  YYSYMBOL_template_parms_builder = 212,   /* template_parms_builder  */
  YYSYMBOL_templateparameter = 213,        /* templateparameter  */
  YYSYMBOL_cpp_using_decl = 214,           /* cpp_using_decl  */
  YYSYMBOL_using_conversion = 215,         /* using_conversion  */
  YYSYMBOL_using_scope = 216,              /* using_scope  */
  YYSYMBOL_cpp_namespace_decl = 217,       /* cpp_namespace_decl  */
  YYSYMBOL_218_8 = 218,                    /* @8  */
  YYSYMBOL_219_9 = 219,                    /* @9  */
  YYSYMBOL_cpp_members = 220,              /* cpp_members  */
  YYSYMBOL_cpp_members_builder = 221,      /* cpp_members_builder  */
  YYSYMBOL_cpp_member_no_dox = 222,        /* cpp_member_no_dox  */
  YYSYMBOL_cpp_member = 223,               /* cpp_member  */
  YYSYMBOL_224_10 = 224,                   /* $@10  */
  YYSYMBOL_cpp_constructor_decl = 225,     /* cpp_constructor_decl  */
  YYSYMBOL_cpp_destructor_decl = 226,      /* cpp_destructor_decl  */
  YYSYMBOL_cpp_conversion_operator = 227,  /* cpp_conversion_operator  */
  YYSYMBOL_cpp_catch_decl = 228,           /* cpp_catch_decl  */
  YYSYMBOL_cpp_static_assert = 229,        /* cpp_static_assert  */
  YYSYMBOL_cpp_protection_decl = 230,      /* cpp_protection_decl  */
  YYSYMBOL_cpp_swig_directive = 231,       /* cpp_swig_directive  */
  YYSYMBOL_cpp_vend = 232,                 /* cpp_vend  */
  YYSYMBOL_anonymous_bitfield = 233,       /* anonymous_bitfield  */
  YYSYMBOL_anon_bitfield_type = 234,       /* anon_bitfield_type  */
  YYSYMBOL_storage_class = 235,            /* storage_class  */
  YYSYMBOL_storage_class_list = 236,       /* storage_class_list  */
  YYSYMBOL_storage_class_raw = 237,        /* storage_class_raw  */
  YYSYMBOL_parms = 238,                    /* parms  */
  YYSYMBOL_rawparms = 239,                 /* rawparms  */
  YYSYMBOL_parm_no_dox = 240,              /* parm_no_dox  */
  YYSYMBOL_parm = 241,                     /* parm  */
  YYSYMBOL_valparms = 242,                 /* valparms  */
  YYSYMBOL_valparms_builder = 243,         /* valparms_builder  */
  YYSYMBOL_valparm = 244,                  /* valparm  */
  YYSYMBOL_def_args = 245,                 /* def_args  */
  YYSYMBOL_parameter_declarator = 246,     /* parameter_declarator  */
  YYSYMBOL_plain_declarator = 247,         /* plain_declarator  */
  YYSYMBOL_declarator = 248,               /* declarator  */
  YYSYMBOL_notso_direct_declarator = 249,  /* notso_direct_declarator  */
  YYSYMBOL_direct_declarator = 250,        /* direct_declarator  */
  YYSYMBOL_abstract_declarator = 251,      /* abstract_declarator  */
  YYSYMBOL_direct_abstract_declarator = 252, /* direct_abstract_declarator  */
  YYSYMBOL_pointer = 253,                  /* pointer  */
  YYSYMBOL_cv_ref_qualifier = 254,         /* cv_ref_qualifier  */
  YYSYMBOL_ref_qualifier = 255,            /* ref_qualifier  */
  YYSYMBOL_type_qualifier = 256,           /* type_qualifier  */
  YYSYMBOL_type_qualifier_raw = 257,       /* type_qualifier_raw  */
  YYSYMBOL_type = 258,                     /* type  */
  YYSYMBOL_rawtype = 259,                  /* rawtype  */
  YYSYMBOL_type_right = 260,               /* type_right  */
  YYSYMBOL_decltype = 261,                 /* decltype  */
  YYSYMBOL_262_11 = 262,                   /* @11  */
  YYSYMBOL_decltypeexpr = 263,             /* decltypeexpr  */
  YYSYMBOL_primitive_type = 264,           /* primitive_type  */
  YYSYMBOL_primitive_type_list = 265,      /* primitive_type_list  */
  YYSYMBOL_type_specifier = 266,           /* type_specifier  */
  YYSYMBOL_definetype = 267,               /* definetype  */
  YYSYMBOL_default_delete = 268,           /* default_delete  */
  YYSYMBOL_deleted_definition = 269,       /* deleted_definition  */
  YYSYMBOL_explicit_default = 270,         /* explicit_default  */
  YYSYMBOL_ename = 271,                    /* ename  */
  YYSYMBOL_constant_directives = 272,      /* constant_directives  */
  YYSYMBOL_optional_ignored_defines = 273, /* optional_ignored_defines  */
  YYSYMBOL_enumlist = 274,                 /* enumlist  */
  YYSYMBOL_enumlist_item = 275,            /* enumlist_item  */
  YYSYMBOL_edecl_with_dox = 276,           /* edecl_with_dox  */
  YYSYMBOL_edecl = 277,                    /* edecl  */
  YYSYMBOL_etype = 278,                    /* etype  */
  YYSYMBOL_expr = 279,                     /* expr  */
  YYSYMBOL_exprmem = 280,                  /* exprmem  */
  YYSYMBOL_constraint = 281,               /* constraint  */
  YYSYMBOL_constraint_or = 282,            /* constraint_or  */
  YYSYMBOL_constraint_and = 283,           /* constraint_and  */
  YYSYMBOL_constraint_primary = 284,       /* constraint_primary  */
  YYSYMBOL_285_12 = 285,                   /* @12  */
  YYSYMBOL_requires_expression = 286,      /* requires_expression  */
  YYSYMBOL_requirement_parameter_list_opt = 287, /* requirement_parameter_list_opt  */
  YYSYMBOL_requirement_body = 288,         /* requirement_body  */
  YYSYMBOL_exprsimple = 289,               /* exprsimple  */
  YYSYMBOL_valexpr = 290,                  /* valexpr  */
  YYSYMBOL_exprnum = 291,                  /* exprnum  */
  YYSYMBOL_exprcompound = 292,             /* exprcompound  */
  YYSYMBOL_variadic_opt = 293,             /* variadic_opt  */
  YYSYMBOL_inherit = 294,                  /* inherit  */
  YYSYMBOL_raw_inherit = 295,              /* raw_inherit  */
  YYSYMBOL_296_13 = 296,                   /* $@13  */
  YYSYMBOL_base_list = 297,                /* base_list  */
  YYSYMBOL_base_specifier = 298,           /* base_specifier  */
  YYSYMBOL_299_14 = 299,                   /* @14  */
  YYSYMBOL_300_15 = 300,                   /* @15  */
  YYSYMBOL_access_specifier = 301,         /* access_specifier  */
  YYSYMBOL_templcpptype = 302,             /* templcpptype  */
  YYSYMBOL_cpptype = 303,                  /* cpptype  */
  YYSYMBOL_classkey = 304,                 /* classkey  */
  YYSYMBOL_classkeyopt = 305,              /* classkeyopt  */
  YYSYMBOL_opt_virtual = 306,              /* opt_virtual  */
  YYSYMBOL_virt_specifier_seq = 307,       /* virt_specifier_seq  */
  YYSYMBOL_virt_specifier_seq_opt = 308,   /* virt_specifier_seq_opt  */
  YYSYMBOL_requires_clause_opt = 309,      /* requires_clause_opt  */
  YYSYMBOL_class_virt_specifier_opt = 310, /* class_virt_specifier_opt  */
  YYSYMBOL_exception_specification = 311,  /* exception_specification  */
  YYSYMBOL_qualifiers_exception_specification = 312, /* qualifiers_exception_specification  */
  YYSYMBOL_cpp_const = 313,                /* cpp_const  */
  YYSYMBOL_ctor_end = 314,                 /* ctor_end  */
  YYSYMBOL_ctor_initializer = 315,         /* ctor_initializer  */
  YYSYMBOL_mem_initializer_list = 316,     /* mem_initializer_list  */
  YYSYMBOL_mem_initializer = 317,          /* mem_initializer  */
  YYSYMBOL_less_valparms_greater = 318,    /* less_valparms_greater  */
  YYSYMBOL_identifier = 319,               /* identifier  */
  YYSYMBOL_idstring = 320,                 /* idstring  */
  YYSYMBOL_idstringopt = 321,              /* idstringopt  */
  YYSYMBOL_idcolon = 322,                  /* idcolon  */
  YYSYMBOL_idcolontail = 323,              /* idcolontail  */
  YYSYMBOL_idtemplate = 324,               /* idtemplate  */
  YYSYMBOL_idtemplatetemplate = 325,       /* idtemplatetemplate  */
  YYSYMBOL_idcolonnt = 326,                /* idcolonnt  */
  YYSYMBOL_idcolontailnt = 327,            /* idcolontailnt  */
  YYSYMBOL_string = 328,                   /* string  */
  YYSYMBOL_wstring = 329,                  /* wstring  */
  YYSYMBOL_stringbrace = 330,              /* stringbrace  */
  YYSYMBOL_options = 331,                  /* options  */
  YYSYMBOL_kwargs = 332,                   /* kwargs  */
  YYSYMBOL_kwargs_builder = 333,           /* kwargs_builder  */
  YYSYMBOL_stringnum = 334                 /* stringnum  */
};
typedef enum yysymbol_kind_t yysymbol_kind_t;


/* Second part of user prologue.  */
#line 2153 "CParse/parser.y"


// Default-initialised instances of token types to avoid uninitialised fields.
// The compiler will initialise all fields to zero or NULL for us.

static const struct Decl default_decl;
static const struct Define default_dtype;

/* C++ decltype/auto type deduction. */
static SwigType *deduce_type(const struct Define *dtype) {
  Node *n;
  if (!dtype->val) return NULL;
  n = Swig_symbol_clookup(dtype->val, 0);
  if (n) {
    if (Strcmp(nodeType(n),"enumitem") == 0) {
      /* For an enumitem, the "type" attribute gives us the underlying integer
       * type - we want the "type" attribute from the enum itself, which is
       * "parentNode".
       */
      n = Getattr(n, "parentNode");
    }
    return Getattr(n, "type");
  } else if (dtype->type != T_AUTO && dtype->type != T_UNKNOWN) {
    /* Try to deduce the type from the T_* type code. */
    String *deduced_type = NewSwigType(dtype->type);
    if (Len(deduced_type) > 0) return deduced_type;
    Delete(deduced_type);
  }
  return NULL;
}

// Append scanner_ccode to expr.  Some cleaning up of the code may be done.
static void append_expr_from_scanner(String *expr) {
  if (Strchr(scanner_ccode, '"') == NULL) {
    // Append scanner_ccode, changing any whitespace character to a space.
    int len = Len(scanner_ccode);
    for (int i = 0; i < len; ++i) {
      char ch = Char(scanner_ccode)[i];
      if (isspace((unsigned char)ch)) ch = ' ';
      Putc(ch, expr);
    }
  } else {
    // The code contains a double quote so leave it be as changing a
    // backslash-escaped linefeed character (i.e. `\` followed by byte 0x0a)
    // in a string literal into a space will insert a space into the string
    // literal's value.  An expression containing a double quote won't work if
    // used in a context where a swig_type_info is generated as the typename
    // gets substituted into a string literal without any escaping which will
    // result in invalid code due to the double quotes.
    Append(expr, scanner_ccode);
  }
  Clear(scanner_ccode);
}

static Node *new_enum_node(SwigType *enum_base_type) {
  Node *n = new_node("enum");
  if (enum_base_type) {
    switch (SwigType_type(enum_base_type)) {
      case T_USER:
	// We get T_USER if the underlying type is a typedef.  Unfortunately we
	// aren't able to resolve a typedef at this point, so we have to assume
	// it's a typedef to an integral or boolean type.
	break;
      case T_BOOL:
      case T_SCHAR:
      case T_UCHAR:
      case T_SHORT:
      case T_USHORT:
      case T_INT:
      case T_UINT:
      case T_LONG:
      case T_ULONG:
      case T_LONGLONG:
      case T_ULONGLONG:
      case T_CHAR:
      case T_WCHAR:
	break;
      default:
	Swig_error(cparse_file, cparse_line, "Underlying type of enum must be an integral type\n");
    }
    Setattr(n, "enumbase", enum_base_type);
  }
  return n;
}


#line 2354 "CParse/parser.c"


#ifdef short
# undef short
#endif

/* On compilers that do not define __PTRDIFF_MAX__ etc., make sure
   <limits.h> and (if available) <stdint.h> are included
   so that the code can choose integer types of a good width.  */

#ifndef __PTRDIFF_MAX__
# include <limits.h> /* INFRINGES ON USER NAME SPACE */
# if defined __STDC_VERSION__ && 199901 <= __STDC_VERSION__
#  include <stdint.h> /* INFRINGES ON USER NAME SPACE */
#  define YY_STDINT_H
# endif
#endif

/* Narrow types that promote to a signed type and that can represent a
   signed or unsigned integer of at least N bits.  In tables they can
   save space and decrease cache pressure.  Promoting to a signed type
   helps avoid bugs in integer arithmetic.  */

#ifdef __INT_LEAST8_MAX__
typedef __INT_LEAST8_TYPE__ yytype_int8;
#elif defined YY_STDINT_H
typedef int_least8_t yytype_int8;
#else
typedef signed char yytype_int8;
#endif

#ifdef __INT_LEAST16_MAX__
typedef __INT_LEAST16_TYPE__ yytype_int16;
#elif defined YY_STDINT_H
typedef int_least16_t yytype_int16;
#else
typedef short yytype_int16;
#endif

/* Work around bug in HP-UX 11.23, which defines these macros
   incorrectly for preprocessor constants.  This workaround can likely
   be removed in 2023, as HPE has promised support for HP-UX 11.23
   (aka HP-UX 11i v2) only through the end of 2022; see Table 2 of
   <https://h20195.www2.hpe.com/V2/getpdf.aspx/4AA4-7673ENW.pdf>.  */
#ifdef __hpux
# undef UINT_LEAST8_MAX
# undef UINT_LEAST16_MAX
# define UINT_LEAST8_MAX 255
# define UINT_LEAST16_MAX 65535
#endif

#if defined __UINT_LEAST8_MAX__ && __UINT_LEAST8_MAX__ <= __INT_MAX__
typedef __UINT_LEAST8_TYPE__ yytype_uint8;
#elif (!defined __UINT_LEAST8_MAX__ && defined YY_STDINT_H \
       && UINT_LEAST8_MAX <= INT_MAX)
typedef uint_least8_t yytype_uint8;
#elif !defined __UINT_LEAST8_MAX__ && UCHAR_MAX <= INT_MAX
typedef unsigned char yytype_uint8;
#else
typedef short yytype_uint8;
#endif

#if defined __UINT_LEAST16_MAX__ && __UINT_LEAST16_MAX__ <= __INT_MAX__
typedef __UINT_LEAST16_TYPE__ yytype_uint16;
#elif (!defined __UINT_LEAST16_MAX__ && defined YY_STDINT_H \
       && UINT_LEAST16_MAX <= INT_MAX)
typedef uint_least16_t yytype_uint16;
#elif !defined __UINT_LEAST16_MAX__ && USHRT_MAX <= INT_MAX
typedef unsigned short yytype_uint16;
#else
typedef int yytype_uint16;
#endif

#ifndef YYPTRDIFF_T
# if defined __PTRDIFF_TYPE__ && defined __PTRDIFF_MAX__
#  define YYPTRDIFF_T __PTRDIFF_TYPE__
#  define YYPTRDIFF_MAXIMUM __PTRDIFF_MAX__
# elif defined PTRDIFF_MAX
#  ifndef ptrdiff_t
#   include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  endif
#  define YYPTRDIFF_T ptrdiff_t
#  define YYPTRDIFF_MAXIMUM PTRDIFF_MAX
# else
#  define YYPTRDIFF_T long
#  define YYPTRDIFF_MAXIMUM LONG_MAX
# endif
#endif

#ifndef YYSIZE_T
# ifdef __SIZE_TYPE__
#  define YYSIZE_T __SIZE_TYPE__
# elif defined size_t
#  define YYSIZE_T size_t
# elif defined __STDC_VERSION__ && 199901 <= __STDC_VERSION__
#  include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  define YYSIZE_T size_t
# else
#  define YYSIZE_T unsigned
# endif
#endif

#define YYSIZE_MAXIMUM                                  \
  YY_CAST (YYPTRDIFF_T,                                 \
           (YYPTRDIFF_MAXIMUM < YY_CAST (YYSIZE_T, -1)  \
            ? YYPTRDIFF_MAXIMUM                         \
            : YY_CAST (YYSIZE_T, -1)))

#define YYSIZEOF(X) YY_CAST (YYPTRDIFF_T, sizeof (X))


/* Stored state numbers (used for stacks). */
typedef yytype_int16 yy_state_t;

/* State numbers in computations.  */
typedef int yy_state_fast_t;

#ifndef YY_
# if defined YYENABLE_NLS && YYENABLE_NLS
#  if ENABLE_NLS
#   include <libintl.h> /* INFRINGES ON USER NAME SPACE */
#   define YY_(Msgid) dgettext ("bison-runtime", Msgid)
#  endif
# endif
# ifndef YY_
#  define YY_(Msgid) Msgid
# endif
#endif


#ifndef YY_ATTRIBUTE_PURE
# if defined __GNUC__ && 2 < __GNUC__ + (96 <= __GNUC_MINOR__)
#  define YY_ATTRIBUTE_PURE __attribute__ ((__pure__))
# else
#  define YY_ATTRIBUTE_PURE
# endif
#endif

#ifndef YY_ATTRIBUTE_UNUSED
# if defined __GNUC__ && 2 < __GNUC__ + (7 <= __GNUC_MINOR__)
#  define YY_ATTRIBUTE_UNUSED __attribute__ ((__unused__))
# else
#  define YY_ATTRIBUTE_UNUSED
# endif
#endif

/* Suppress unused-variable warnings by "using" E.  */
#if ! defined lint || defined __GNUC__
# define YY_USE(E) ((void) (E))
#else
# define YY_USE(E) /* empty */
#endif

/* Suppress an incorrect diagnostic about yylval being uninitialized.  */
#if defined __GNUC__ && ! defined __ICC && 406 <= __GNUC__ * 100 + __GNUC_MINOR__
# if __GNUC__ * 100 + __GNUC_MINOR__ < 407
#  define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN                           \
    _Pragma ("GCC diagnostic push")                                     \
    _Pragma ("GCC diagnostic ignored \"-Wuninitialized\"")
# else
#  define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN                           \
    _Pragma ("GCC diagnostic push")                                     \
    _Pragma ("GCC diagnostic ignored \"-Wuninitialized\"")              \
    _Pragma ("GCC diagnostic ignored \"-Wmaybe-uninitialized\"")
# endif
# define YY_IGNORE_MAYBE_UNINITIALIZED_END      \
    _Pragma ("GCC diagnostic pop")
#else
# define YY_INITIAL_VALUE(Value) Value
#endif
#ifndef YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
# define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
# define YY_IGNORE_MAYBE_UNINITIALIZED_END
#endif
#ifndef YY_INITIAL_VALUE
# define YY_INITIAL_VALUE(Value) /* Nothing. */
#endif

#if defined __cplusplus && defined __GNUC__ && ! defined __ICC && 6 <= __GNUC__
# define YY_IGNORE_USELESS_CAST_BEGIN                          \
    _Pragma ("GCC diagnostic push")                            \
    _Pragma ("GCC diagnostic ignored \"-Wuseless-cast\"")
# define YY_IGNORE_USELESS_CAST_END            \
    _Pragma ("GCC diagnostic pop")
#endif
#ifndef YY_IGNORE_USELESS_CAST_BEGIN
# define YY_IGNORE_USELESS_CAST_BEGIN
# define YY_IGNORE_USELESS_CAST_END
#endif


#define YY_ASSERT(E) ((void) (0 && (E)))

#if !defined yyoverflow

/* The parser invokes alloca or malloc; define the necessary symbols.  */

# ifdef YYSTACK_USE_ALLOCA
#  if YYSTACK_USE_ALLOCA
#   ifdef __GNUC__
#    define YYSTACK_ALLOC __builtin_alloca
#   elif defined __BUILTIN_VA_ARG_INCR
#    include <alloca.h> /* INFRINGES ON USER NAME SPACE */
#   elif defined _AIX
#    define YYSTACK_ALLOC __alloca
#   elif defined _MSC_VER
#    include <malloc.h> /* INFRINGES ON USER NAME SPACE */
#    define alloca _alloca
#   else
#    define YYSTACK_ALLOC alloca
#    if ! defined _ALLOCA_H && ! defined EXIT_SUCCESS
#     include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
      /* Use EXIT_SUCCESS as a witness for stdlib.h.  */
#     ifndef EXIT_SUCCESS
#      define EXIT_SUCCESS 0
#     endif
#    endif
#   endif
#  endif
# endif

# ifdef YYSTACK_ALLOC
   /* Pacify GCC's 'empty if-body' warning.  */
#  define YYSTACK_FREE(Ptr) do { /* empty */; } while (0)
#  ifndef YYSTACK_ALLOC_MAXIMUM
    /* The OS might guarantee only one guard page at the bottom of the stack,
       and a page size can be as small as 4096 bytes.  So we cannot safely
       invoke alloca (N) if N exceeds 4096.  Use a slightly smaller number
       to allow for a few compiler-allocated temporary stack slots.  */
#   define YYSTACK_ALLOC_MAXIMUM 4032 /* reasonable circa 2006 */
#  endif
# else
#  define YYSTACK_ALLOC YYMALLOC
#  define YYSTACK_FREE YYFREE
#  ifndef YYSTACK_ALLOC_MAXIMUM
#   define YYSTACK_ALLOC_MAXIMUM YYSIZE_MAXIMUM
#  endif
#  if (defined __cplusplus && ! defined EXIT_SUCCESS \
       && ! ((defined YYMALLOC || defined malloc) \
             && (defined YYFREE || defined free)))
#   include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#   ifndef EXIT_SUCCESS
#    define EXIT_SUCCESS 0
#   endif
#  endif
#  ifndef YYMALLOC
#   define YYMALLOC malloc
#   if ! defined malloc && ! defined EXIT_SUCCESS
void *malloc (YYSIZE_T); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
#  ifndef YYFREE
#   define YYFREE free
#   if ! defined free && ! defined EXIT_SUCCESS
void free (void *); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
# endif
#endif /* !defined yyoverflow */

#if (! defined yyoverflow \
     && (! defined __cplusplus \
         || (defined YYSTYPE_IS_TRIVIAL && YYSTYPE_IS_TRIVIAL)))

/* A type that is properly aligned for any stack member.  */
union yyalloc
{
  yy_state_t yyss_alloc;
  YYSTYPE yyvs_alloc;
};

/* The size of the maximum gap between one aligned stack and the next.  */
# define YYSTACK_GAP_MAXIMUM (YYSIZEOF (union yyalloc) - 1)

/* The size of an array large to enough to hold all stacks, each with
   N elements.  */
# define YYSTACK_BYTES(N) \
     ((N) * (YYSIZEOF (yy_state_t) + YYSIZEOF (YYSTYPE)) \
      + YYSTACK_GAP_MAXIMUM)

# define YYCOPY_NEEDED 1

/* Relocate STACK from its old location to the new one.  The
   local variables YYSIZE and YYSTACKSIZE give the old and new number of
   elements in the stack, and YYPTR gives the new location of the
   stack.  Advance YYPTR to a properly aligned location for the next
   stack.  */
# define YYSTACK_RELOCATE(Stack_alloc, Stack)                           \
    do                                                                  \
      {                                                                 \
        YYPTRDIFF_T yynewbytes;                                         \
        YYCOPY (&yyptr->Stack_alloc, Stack, yysize);                    \
        Stack = &yyptr->Stack_alloc;                                    \
        yynewbytes = yystacksize * YYSIZEOF (*Stack) + YYSTACK_GAP_MAXIMUM; \
        yyptr += yynewbytes / YYSIZEOF (*yyptr);                        \
      }                                                                 \
    while (0)

#endif

#if defined YYCOPY_NEEDED && YYCOPY_NEEDED
/* Copy COUNT objects from SRC to DST.  The source and destination do
   not overlap.  */
# ifndef YYCOPY
#  if defined __GNUC__ && 1 < __GNUC__
#   define YYCOPY(Dst, Src, Count) \
      __builtin_memcpy (Dst, Src, YY_CAST (YYSIZE_T, (Count)) * sizeof (*(Src)))
#  else
#   define YYCOPY(Dst, Src, Count)              \
      do                                        \
        {                                       \
          YYPTRDIFF_T yyi;                      \
          for (yyi = 0; yyi < (Count); yyi++)   \
            (Dst)[yyi] = (Src)[yyi];            \
        }                                       \
      while (0)
#  endif
# endif
#endif /* !YYCOPY_NEEDED */

/* YYFINAL -- State number of the termination state.  */
#define YYFINAL  60
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   9732

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  144
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  191
/* YYNRULES -- Number of rules.  */
#define YYNRULES  671
/* YYNSTATES -- Number of states.  */
#define YYNSTATES  1238

/* YYMAXUTOK -- Last valid token kind.  */
#define YYMAXUTOK   398


/* YYTRANSLATE(TOKEN-NUM) -- Symbol number corresponding to TOKEN-NUM
   as returned by yylex, with out-of-bounds checking.  */
#define YYTRANSLATE(YYX) YY_CAST (yysymbol_kind_t, YYX)

#if YYDEBUG
/* YYRLINE[YYN] -- Source line where rule number YYN was defined.  */
static const yytype_int16 yyrline[] =
{
       0,  2249,  2249,  2261,  2265,  2268,  2271,  2274,  2277,  2282,
    2291,  2296,  2305,  2310,  2311,  2312,  2313,  2314,  2323,  2339,
    2350,  2351,  2352,  2353,  2354,  2355,  2356,  2357,  2358,  2359,
    2360,  2361,  2362,  2363,  2364,  2365,  2366,  2367,  2368,  2375,
    2375,  2457,  2467,  2481,  2499,  2517,  2535,  2539,  2550,  2559,
    2572,  2579,  2583,  2594,  2604,  2619,  2632,  2632,  2693,  2694,
    2701,  2719,  2753,  2758,  2768,  2774,  2792,  2835,  2842,  2869,
    2875,  2882,  2883,  2886,  2887,  2894,  2940,  2986,  2997,  3000,
    3027,  3033,  3041,  3047,  3055,  3056,  3057,  3060,  3066,  3073,
    3109,  3110,  3144,  3163,  3173,  3188,  3210,  3215,  3218,  3229,
    3240,  3245,  3258,  3270,  3552,  3562,  3569,  3570,  3571,  3575,
    3575,  3612,  3618,  3628,  3642,  3649,  3736,  3787,  3851,  3918,
    3964,  4011,  4053,  4095,  4112,  4127,  4131,  4158,  4162,  4173,
    4174,  4180,  4181,  4182,  4183,  4187,  4188,  4192,  4196,  4201,
    4206,  4217,  4223,  4229,  4237,  4242,  4245,  4248,  4252,  4253,
    4253,  4265,  4268,  4271,  4280,  4283,  4290,  4313,  4342,  4440,
    4499,  4509,  4510,  4511,  4512,  4513,  4514,  4523,  4523,  4799,
    4799,  4990,  4991,  5003,  5022,  5022,  5255,  5264,  5268,  5274,
    5281,  5285,  5291,  5292,  5293,  5294,  5297,  5298,  5299,  5300,
    5310,  5318,  5321,  5326,  5329,  5340,  5348,  5356,  5364,  5433,
    5444,  5455,  5467,  5477,  5489,  5524,  5534,  5540,  5540,  5598,
    5598,  5620,  5647,  5650,  5655,  5658,  5663,  5669,  5672,  5702,
    5703,  5720,  5721,  5722,  5723,  5724,  5725,  5726,  5727,  5728,
    5729,  5730,  5731,  5732,  5733,  5734,  5735,  5736,  5738,  5739,
    5743,  5747,  5747,  5766,  5806,  5847,  5868,  5891,  5915,  5940,
    5965,  5973,  5980,  5987,  5995,  6003,  6006,  6008,  6009,  6010,
    6011,  6012,  6013,  6014,  6015,  6018,  6022,  6027,  6034,  6053,
    6054,  6055,  6057,  6063,  6105,  6108,  6109,  6117,  6118,  6128,
    6129,  6130,  6131,  6132,  6133,  6134,  6141,  6153,  6154,  6158,
    6163,  6169,  6176,  6183,  6188,  6200,  6215,  6230,  6246,  6262,
    6270,  6271,  6277,  6285,  6290,  6293,  6304,  6332,  6342,  6345,
    6353,  6359,  6365,  6371,  6377,  6385,  6408,  6425,  6444,  6463,
    6468,  6476,  6485,  6494,  6498,  6507,  6518,  6529,  6541,  6551,
    6565,  6574,  6584,  6594,  6604,  6616,  6628,  6641,  6652,  6663,
    6675,  6689,  6694,  6700,  6712,  6720,  6731,  6742,  6753,  6772,
    6778,  6791,  6799,  6806,  6813,  6824,  6836,  6847,  6859,  6870,
    6881,  6903,  6916,  6921,  6927,  6933,  6939,  6948,  6957,  6958,
    6967,  6976,  6982,  6988,  6993,  6999,  7007,  7018,  7029,  7040,
    7045,  7050,  7053,  7070,  7088,  7098,  7103,  7107,  7112,  7119,
    7122,  7127,  7134,  7138,  7144,  7148,  7154,  7155,  7156,  7162,
    7168,  7172,  7173,  7177,  7182,  7188,  7189,  7190,  7191,  7193,
    7196,  7199,  7202,  7202,  7219,  7222,  7235,  7261,  7262,  7316,
    7320,  7324,  7328,  7332,  7336,  7340,  7344,  7348,  7352,  7356,
    7360,  7364,  7368,  7374,  7375,  7378,  7379,  7383,  7391,  7400,
    7401,  7404,  7405,  7409,  7410,  7420,  7424,  7429,  7435,  7445,
    7456,  7467,  7472,  7477,  7478,  7484,  7492,  7510,  7528,  7529,
    7563,  7567,  7571,  7575,  7579,  7584,  7632,  7635,  7636,  7641,
    7642,  7647,  7653,  7653,  7670,  7676,  7693,  7696,  7701,  7708,
    7709,  7710,  7716,  7722,  7735,  7747,  7755,  7763,  7770,  7780,
    7787,  7788,  7798,  7806,  7817,  7856,  7866,  7876,  7886,  7897,
    7908,  7929,  7952,  7953,  7954,  7955,  7956,  7957,  7958,  7959,
    7960,  7961,  7964,  7975,  7986,  7991,  7996,  8001,  8006,  8011,
    8016,  8021,  8026,  8031,  8036,  8041,  8050,  8061,  8066,  8071,
    8088,  8093,  8098,  8103,  8108,  8113,  8118,  8123,  8128,  8133,
    8138,  8143,  8148,  8153,  8162,  8172,  8177,  8182,  8188,  8203,
    8210,  8236,  8247,  8252,  8259,  8262,  8267,  8270,  8270,  8271,
    8274,  8296,  8307,  8307,  8330,  8330,  8353,  8354,  8355,  8358,
    8363,  8370,  8371,  8375,  8381,  8384,  8387,  8392,  8393,  8396,
    8397,  8400,  8403,  8406,  8409,  8414,  8415,  8427,  8430,  8435,
    8438,  8443,  8448,  8452,  8456,  8462,  8467,  8473,  8478,  8481,
    8488,  8489,  8493,  8497,  8502,  8513,  8524,  8530,  8536,  8542,
    8556,  8557,  8560,  8561,  8562,  8563,  8566,  8578,  8584,  8593,
    8594,  8595,  8598,  8599,  8600,  8603,  8604,  8607,  8611,  8615,
    8618,  8621,  8624,  8629,  8635,  8639,  8642,  8646,  8652,  8655,
    8662,  8663,  8671,  8675,  8679,  8682,  8685,  8688,  8694,  8698,
    8701,  8705,  8711,  8716,  8718,  8724,  8730,  8736,  8739,  8740,
    8744,  8747,  8760,  8764,  8769,  8776,  8785,  8790,  8797,  8802,
    8811,  8812
};
#endif

/** Accessing symbol of state STATE.  */
#define YY_ACCESSING_SYMBOL(State) YY_CAST (yysymbol_kind_t, yystos[State])

#if YYDEBUG || 0
/* The user-facing name of the symbol whose (internal) number is
   YYSYMBOL.  No bounds checking.  */
static const char *yysymbol_name (yysymbol_kind_t yysymbol) YY_ATTRIBUTE_UNUSED;

/* YYTNAME[SYMBOL-NUM] -- String name of the symbol SYMBOL-NUM.
   First, the terminals, then, starting at YYNTOKENS, nonterminals.  */
static const char *const yytname[] =
{
  "END", "error", "\"invalid token\"", "ID", "HBLOCK", "POUND", "STRING",
  "WSTRING", "INCLUDE", "IMPORT", "INSERT", "CHARCONST", "WCHARCONST",
  "NUM_INT", "NUM_DOUBLE", "NUM_FLOAT", "NUM_LONGDOUBLE", "NUM_UNSIGNED",
  "NUM_LONG", "NUM_ULONG", "NUM_LONGLONG", "NUM_ULONGLONG", "NUM_BOOL",
  "TYPEDEF", "TYPE_INT", "TYPE_UNSIGNED", "TYPE_SHORT", "TYPE_LONG",
  "TYPE_FLOAT", "TYPE_DOUBLE", "TYPE_CHAR", "TYPE_WCHAR", "TYPE_VOID",
  "TYPE_SIGNED", "TYPE_BOOL", "TYPE_COMPLEX", "TYPE_NON_ISO_INT8",
  "TYPE_NON_ISO_INT16", "TYPE_NON_ISO_INT32", "TYPE_NON_ISO_INT64",
  "LPAREN", "RPAREN", "COMMA", "SEMI", "EXTERN", "LBRACE", "RBRACE",
  "PERIOD", "ELLIPSIS", "CONST_QUAL", "VOLATILE", "REGISTER", "STRUCT",
  "UNION", "EQUAL", "SIZEOF", "ALIGNOF", "MODULE", "LBRACKET", "RBRACKET",
  "BEGINFILE", "ENDOFFILE", "CONSTANT", "RENAME", "NAMEWARN", "EXTEND",
  "PRAGMA", "FEATURE", "VARARGS", "ENUM", "CLASS", "TYPENAME", "PRIVATE",
  "PUBLIC", "PROTECTED", "COLON", "STATIC", "VIRTUAL", "FRIEND", "THROW",
  "CATCH", "EXPLICIT", "STATIC_ASSERT", "CONSTEXPR", "THREAD_LOCAL",
  "DECLTYPE", "AUTO", "NOEXCEPT", "OVERRIDE", "FINAL", "CONCEPT",
  "REQUIRES", "USING", "NAMESPACE", "NATIVE", "INLINE", "TYPEMAP", "ECHO",
  "APPLY", "CLEAR", "SWIGTEMPLATE", "FRAGMENT", "WARN", "LESSTHAN",
  "GREATERTHAN", "DELETE_KW", "DEFAULT", "LESSTHANOREQUALTO",
  "GREATERTHANOREQUALTO", "EQUALTO", "NOTEQUALTO", "LESSEQUALGREATER",
  "ARROW", "QUESTIONMARK", "TYPES", "PARMS", "NONID", "DSTAR", "DCNOT",
  "TEMPLATE", "OPERATOR", "CONVERSIONOPERATOR", "PARSETYPE", "PARSEPARM",
  "PARSEPARMS", "DOXYGENSTRING", "DOXYGENPOSTSTRING", "LOR", "LAND", "OR",
  "XOR", "AND", "LSHIFT", "RSHIFT", "PLUS", "MINUS", "STAR", "SLASH",
  "MODULO", "UMINUS", "NOT", "LNOT", "CAST", "DCOLON", "$accept",
  "program", "interface", "declaration", "swig_directive",
  "extend_directive", "$@1", "apply_directive", "clear_directive",
  "constant_directive", "echo_directive", "stringtype", "fname",
  "fragment_directive", "include_directive", "@2", "includetype",
  "inline_directive", "insert_directive", "module_directive",
  "native_directive", "pragma_directive", "pragma_arg", "pragma_lang",
  "rename_directive", "rename_namewarn", "feature_directive",
  "stringbracesemi", "featattr", "varargs_directive", "varargs_parms",
  "typemap_directive", "typemap_type", "tm_list", "tm_list_builder",
  "typemap_parm", "types_directive", "template_directive",
  "warn_directive", "c_declaration", "$@3", "c_decl", "c_decl_tail",
  "initializer", "cpp_alternate_rettype", "cpp_lambda_decl",
  "lambda_introducer", "lambda_template", "lambda_body", "lambda_tail",
  "$@4", "c_enum_key", "c_enum_inherit", "c_enum_forward_decl",
  "c_enum_decl", "c_constructor_decl", "deduction_guide",
  "cpp_declaration", "cpp_class_decl", "@5", "@6", "cpp_opt_declarators",
  "cpp_forward_class_decl", "cpp_template_decl", "$@7",
  "cpp_template_possible", "cpp_concept_decl", "template_parms",
  "template_parms_builder", "templateparameter", "cpp_using_decl",
  "using_conversion", "using_scope", "cpp_namespace_decl", "@8", "@9",
  "cpp_members", "cpp_members_builder", "cpp_member_no_dox", "cpp_member",
  "$@10", "cpp_constructor_decl", "cpp_destructor_decl",
  "cpp_conversion_operator", "cpp_catch_decl", "cpp_static_assert",
  "cpp_protection_decl", "cpp_swig_directive", "cpp_vend",
  "anonymous_bitfield", "anon_bitfield_type", "storage_class",
  "storage_class_list", "storage_class_raw", "parms", "rawparms",
  "parm_no_dox", "parm", "valparms", "valparms_builder", "valparm",
  "def_args", "parameter_declarator", "plain_declarator", "declarator",
  "notso_direct_declarator", "direct_declarator", "abstract_declarator",
  "direct_abstract_declarator", "pointer", "cv_ref_qualifier",
  "ref_qualifier", "type_qualifier", "type_qualifier_raw", "type",
  "rawtype", "type_right", "decltype", "@11", "decltypeexpr",
  "primitive_type", "primitive_type_list", "type_specifier", "definetype",
  "default_delete", "deleted_definition", "explicit_default", "ename",
  "constant_directives", "optional_ignored_defines", "enumlist",
  "enumlist_item", "edecl_with_dox", "edecl", "etype", "expr", "exprmem",
  "constraint", "constraint_or", "constraint_and", "constraint_primary",
  "@12", "requires_expression", "requirement_parameter_list_opt",
  "requirement_body", "exprsimple", "valexpr", "exprnum", "exprcompound",
  "variadic_opt", "inherit", "raw_inherit", "$@13", "base_list",
  "base_specifier", "@14", "@15", "access_specifier", "templcpptype",
  "cpptype", "classkey", "classkeyopt", "opt_virtual",
  "virt_specifier_seq", "virt_specifier_seq_opt", "requires_clause_opt",
  "class_virt_specifier_opt", "exception_specification",
  "qualifiers_exception_specification", "cpp_const", "ctor_end",
  "ctor_initializer", "mem_initializer_list", "mem_initializer",
  "less_valparms_greater", "identifier", "idstring", "idstringopt",
  "idcolon", "idcolontail", "idtemplate", "idtemplatetemplate",
  "idcolonnt", "idcolontailnt", "string", "wstring", "stringbrace",
  "options", "kwargs", "kwargs_builder", "stringnum", YY_NULLPTR
};

static const char *
yysymbol_name (yysymbol_kind_t yysymbol)
{
  return yytname[yysymbol];
}
#endif

#define YYPACT_NINF (-1118)

#define yypact_value_is_default(Yyn) \
  ((Yyn) == YYPACT_NINF)

#define YYTABLE_NINF (-639)

#define yytable_value_is_error(Yyn) \
  0

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
static const yytype_int16 yypact[] =
{
     730,  7805,  7907,    82,   150,  7246, -1118, -1118, -1118, -1118,
   -1118, -1118, -1118, -1118, -1118, -1118, -1118, -1118, -1118, -1118,
   -1118, -1118, -1118, -1118, -1118, -1118, -1118, -1118, -1118, -1118,
     427,   127,   127,   229,    71, -1118, -1118,   170,   152,  8739,
     429, -1118,   333,  8811, -1118,  1773,   822, -1118, -1118, -1118,
    4859, -1118,   429,   152,   257,   285, -1118,   363, -1118,  8317,
   -1118,   283, -1118, -1118, -1118,   377, -1118, -1118,    66,   391,
    8483, -1118, -1118,   391,   432,   473,   482, -1118, -1118, -1118,
     495, -1118,   515, -1118, -1118,   192,   370,   551,    83,   600,
     640,  8883,  8883,   623,   647,   559,   655,  9096, -1118, -1118,
   -1118, -1118, -1118, -1118, -1118, -1118, -1118, -1118, -1118,   391,
   -1118, -1118, -1118, -1118, -1118, -1118,  1896, -1118, -1118, -1118,
   -1118, -1118, -1118, -1118, -1118, -1118, -1118, -1118, -1118, -1118,
   -1118, -1118, -1118, -1118, -1118, -1118, -1118, -1118,  8955,  1120,
   -1118, -1118, -1118, -1118, -1118, -1118, -1118,  6904,  2887,  3567,
      77,   100,  1497,   822,   429, -1118, -1118,   651,   425,   651,
     475,  1934,   603,   187,  3023, -1118, -1118, -1118, -1118,    71,
   -1118,   822,   638, -1118, -1118,   822, -1118, -1118, -1118,    71,
     164,   410, -1118, -1118,   687, -1118,    67, -1118,  1079, -1118,
    9290,   232,  1079,  1079,   248,  9027,  2607,   707,    15, -1118,
     421,   164,   164,  1079,  8113,  8317, -1118,   429,   429,   720,
     646,   721,   337, -1118,   250,   729,   164, -1118, -1118,  1079,
   -1118,   774,  8317,   738,   302,   746,   748, -1118,  1079,   559,
     774,  8317, -1118, -1118,   429,  8215,   429,   429, -1118, -1118,
     429,   454,   559,  1176,   564,  1626,  1079,   568,  1623,   685,
    2607,   429,  3265,   365,   722,   559, -1118,  2637,  7018,  1776,
    1776,   771,   783,  1993,   197, -1118, -1118, -1118, -1118, -1118,
   -1118, -1118, -1118, -1118, -1118, -1118, -1118, -1118,  6559, -1118,
    8666,   785,   787,   792, -1118, -1118,  6559,  6559,  6559,  6559,
    6559,  6559,   795,   779, -1118, -1118, -1118,  3536,   309, -1118,
   -1118, -1118, -1118, -1118,    61,    98,   500, -1118,  6690,   800,
    7018,   158,   429,   619,   475, -1118, -1118,   158,   619,   475,
   -1118,   822, -1118, -1118,  8317,  3703, -1118,  8317,  3839,   158,
    2371,  2893,   822,   619,   475, -1118,   724,  1237,   164, -1118,
   -1118,   285, -1118,   740,   803, -1118,  1826,  3536,    72,   203,
   -1118,   822,    71, -1118, -1118, -1118,   285,   848,  8009, -1118,
     816, -1118, -1118,   823,   774,   429,   429, -1118, -1118,   812,
     826,   827, -1118, -1118, -1118,  1272,   651,   625,  3159, -1118,
   -1118, -1118, -1118,   429,   835,   832,   839,   851,   836, -1118,
     853,   572,   859, -1118,  9027, -1118,   862,  9027,   410, -1118,
     429, -1118,   866,   882, -1118,   888,  8883, -1118, -1118,   627,
   -1118, -1118,  8883, -1118,   889, -1118,   335,   282,   892,   548,
     831,   847,   915, -1118, -1118,   183,   899, -1118, -1118, -1118,
   -1118,    94,   710,   710,   372,   530,   841,   920,    46,   158,
     158,   921,  8317,   158,  1829,  3029,   863,  1640,  2222,    24,
     901,   354,  7132,  2222, -1118,   934, -1118,   336,  2607,   774,
     943, -1118,  3806,   522,   522,  2716,   238,   510, -1118,   578,
   -1118, -1118,   522,   522,   659,   868,  1836,  3671,   902, -1118,
     967,   795, -1118, -1118, -1118,  8317,   942,  4355, -1118, -1118,
   -1118, -1118, -1118, -1118, -1118,  3975,  4111,  4247,  4383,  6559,
    6559,  4519,  4655,  4791,  4927,  5063,  5199,  5335,  5471,  5607,
    5743,  5879,  6015, -1118,  1005,  1011,  1013,  1014, -1118, -1118,
   -1118, -1118,  8317,  2018,    47,   619, -1118,  8317,  6151,   619,
     978, -1118,  9481,   984, -1118,  9562,   619,   158,   619,   475,
   -1118,   158,   619,   475, -1118,   822,  1258,   158,   985,  3437,
     619,   822,   152, -1118, -1118,  3023, -1118, -1118, -1118,  8317,
   -1118,  8317,   444,   986, -1118, -1118,  3267, -1118,  1079,   991,
    8317,   993,  1000, -1118,   697,  2609,  1006,  8317,  2607,  1008,
   -1118,  1012, -1118, -1118, -1118,   302,  7360,  1016, -1118,  1120,
    8883,  1017,  1010,  8317, -1118,   443,  1026,  1079,  8317,    93,
   -1118, -1118,  8215,   963,  8215, -1118,  8317, -1118,  1836,   884,
    2458,    30, -1118,  1019,   158,   158,  1855,  1032,   270,   990,
     992,   436, -1118, -1118,   665, -1118,   413, -1118, -1118,   982,
      41,  2229,  9359,   671,  1033,   320,   344,  1004, -1118, -1118,
   -1118,  1009,  2222, -1118, -1118,   868,   822, -1118, -1118, -1118,
     632,  1045,  1048,  1836,  6831,  6287,  3295,  3431,  6695,   128,
    6423,   164,  1053, -1118, -1118, -1118,   977, -1118,   977, -1118,
    2862, -1118,  2862,  1185,  2992, -1118,  4484, -1118,  4620, -1118,
    2853, -1118,  2331, -1118,  4355, -1118,   904, -1118,   904, -1118,
     784, -1118,   784, -1118, -1118, -1118, -1118, -1118, -1118, -1118,
   -1118, -1118, -1118,  1055,   668,   868, -1118,  2188,  1057, -1118,
    9594,  2358, -1118,   413, -1118,   619,   619,   158,  1051,  3573,
     619,   475,   619,   158,   158,   619, -1118, -1118, -1118, -1118,
   -1118, -1118,   774,  8317,  7474, -1118, -1118,   282, -1118,  1049,
   -1118,  1067, -1118, -1118, -1118, -1118,   774,  1066,   313,  1080,
    1408, -1118,  2222, -1118, -1118,  1082, -1118, -1118,  7588,  9027,
     532,  8317, -1118,  1086,   995, -1118,   352,  1036, -1118,  1094,
    1098, -1118, -1118, -1118,  1106, -1118,   774, -1118,  1047,   436,
    1061, -1118,  1118, -1118,  1836,  2222,   323,   158, -1118,  8317,
    6559, -1118, -1118, -1118, -1118, -1118,  1034,  1037, -1118, -1118,
   -1118, -1118, -1118,   436, -1118, -1118,  9428,  1119, -1118,  1070,
    1131, -1118, -1118,  1113,  9122,  2365,  6559,   536, -1118, -1118,
    1134, -1118,   956,  2757,  1132,   174, -1118, -1118,  1137,  1140,
   -1118,  1142,  3942,  6559,  6559,  9027,  6559,  1145,  1146,  1147,
    4078,  1151, -1118,  6559, -1118, -1118,   682, -1118, -1118, -1118,
   -1118,   619,   158,   158,   619,   619,   619,  1153, -1118,  3267,
     413,  2757,  3267,  1079,  1159, -1118,  2222,  1162, -1118, -1118,
    2607,   215, -1118,  8883, -1118,  1161,   413,    95,   164,   276,
   -1118,  3023,   247, -1118,  8317,   678, -1118,   429,   987,   523,
    7702,  1169, -1118,  1172,  4214, -1118,   436,   436, -1118,   649,
   -1118, -1118,   963, -1118,  1113, -1118,    54,  1170,    97,  8317,
    3159,  9027,  1166,  1148, -1118,  1179,  3536, -1118,  2607, -1118,
   -1118, -1118,  1004, -1118, -1118, -1118,   429, -1118, -1118, -1118,
    1180,  1156,  1157,  1163,  9479, -1118, -1118, -1118, -1118, -1118,
   -1118, -1118, -1118, -1118, -1118, -1118, -1118, -1118, -1118, -1118,
   -1118, -1118, -1118, -1118, -1118,  1190,  8381,  1089, -1118, -1118,
   -1118, -1118, -1118, -1118, -1118, -1118,  1539, -1118, -1118, -1118,
    9428, -1118, -1118, -1118, -1118, -1118, -1118, -1118,  6559,  6559,
   -1118, -1118, -1118,  4348, -1118,   619,   619,   947, -1118, -1118,
     651,  1191,   774,  1080,  2012,    93, -1118,  1198, -1118,  1199,
   -1118, -1118, -1118,   352, -1118, -1118,   352,  1141, -1118, -1118,
    1203,   380,  1192,    66,   429,  9193, -1118, -1118, -1118, -1118,
   -1118, -1118, -1118, -1118, -1118,  8555, -1118,  1205, -1118, -1118,
     649, -1118,  1037, -1118, -1118,   448,   571, -1118,   164,  1113,
   -1118,  1196,  2056,    11, -1118,  1209,  1216,  1223,   963,   437,
     429,   700, -1118,  2222, -1118,   127,  1004, -1118, -1118, -1118,
   -1118, -1118,  2082,  9560, -1118, -1118,  1193,  1194,  9027,   164,
    1195,  3401,  1201,   341,  2757,   649, -1118, -1118, -1118,  1224,
    1228, -1118, -1118, -1118,  2222, -1118, -1118, -1118, -1118, -1118,
    1231,  1235, -1118,   651,  9027,  1236,  8215,  2607, -1118, -1118,
     536,  8317, -1118,   653, -1118, -1118,  6559, -1118,  2222,  1113,
   -1118,  1113,   734, -1118,  1240,  1246,  1251,  1253,   585, -1118,
   -1118,   448, -1118,   429,  2757, -1118, -1118,  2222,   134,  1259,
    6559,  7132, -1118,  1256,   448, -1118, -1118,  1262, -1118, -1118,
   -1118,   302,   436,  1204,    40, -1118,  1269, -1118, -1118, -1118,
   -1118,  3536,   448, -1118, -1118, -1118, -1118, -1118, -1118,   429,
   -1118, -1118, -1118,   536,   127,  1265,   448,  8317,  1273,  1274,
      20,  8317,  3124,  1286,  2082,   536, -1118,  1285,  1289,   963,
    2501,  2222,  1290,   536,  1295, -1118, -1118, -1118,   536,  1293,
    8317,  8317,  8317,  1298,  1304, -1118,  9122, -1118, -1118, -1118,
   -1118, -1118,    32, -1118, -1118, -1118, -1118,  2222,  1307,  1310,
    1311,  8317,  2222, -1118,  9027,   653, -1118,   503,  2222,  2222,
    2222,  1313, -1118,   963, -1118, -1118, -1118,  3159, -1118, -1118,
   -1118,  2222,  1314,  1315, -1118,   653, -1118, -1118
};

/* YYDEFACT[STATE-NUM] -- Default reduction number in state STATE-NUM.
   Performed when YYTABLE does not specify something else to do.  Zero
   means the default is an error.  */
static const yytype_int16 yydefact[] =
{
      12,     0,     0,     0,     0,     0,     4,   619,   419,   427,
     420,   421,   424,   425,   422,   423,   407,   426,   406,   428,
     429,   430,   431,   432,   299,   396,   397,   398,   572,   573,
     151,   555,   555,     0,   311,   620,   621,     0,   631,     0,
       0,   300,     0,     0,   394,   311,   401,   411,   405,   416,
     417,   571,     0,   638,   409,   629,     6,     0,     8,   293,
       1,    17,    62,    58,    59,     0,   280,    16,   277,   662,
       0,    78,    79,   662,    74,     0,     0,   279,   281,   282,
       0,   283,     0,   284,   285,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    10,    11,
       9,    13,    20,    21,    22,    23,    24,    25,    26,   662,
      27,    28,    29,    30,    31,    32,     0,    33,    34,    35,
      36,    37,    38,    14,   105,   111,   107,   106,    18,   108,
      15,   161,   162,   163,   164,   165,   166,   114,     0,   273,
     275,   153,   152,   554,   569,   570,   412,   293,     0,     0,
     631,   555,   555,   388,     0,   314,   295,   311,   323,   311,
     368,   555,   349,     0,   303,   632,   301,   408,     3,   311,
     395,   400,   409,   404,   294,   402,   418,   410,   639,   311,
       0,     0,   627,     5,     0,   286,   287,    19,     0,   653,
       0,   278,     0,     0,     0,     0,     0,   399,   638,   409,
     578,     0,     0,     0,   293,   293,   251,     0,     0,     0,
       0,     0,   629,   209,   638,     0,     0,    60,    61,     0,
      48,    49,   293,     0,   319,     0,    96,    97,   626,     0,
     104,   293,   133,   132,     0,   192,     0,     0,   140,   131,
       0,   135,     0,     0,     0,     0,     0,   323,     0,   349,
       0,   440,     0,   559,   409,   277,   276,     0,   293,   555,
     555,     0,     0,   555,   409,   657,   483,   484,   502,   503,
     504,   505,   506,   507,   508,   509,   510,   511,     0,   310,
       0,     0,     0,   477,   437,   438,     0,     0,     0,     0,
       0,     0,   459,   308,   434,   435,   436,   433,   480,   492,
     490,   458,   479,   491,   409,   481,   482,   379,     0,     0,
     293,   554,     0,   325,   370,   372,   341,   554,   324,   369,
     371,   387,   350,   312,   293,     0,   313,   293,     0,   554,
     555,   555,   386,   320,   363,   362,   341,   373,     0,   633,
     640,   630,   306,     0,   302,   304,   399,     0,   458,   409,
     297,   403,   311,   296,   637,   636,   635,     0,   293,   289,
     288,   623,   622,     0,   624,     0,     0,   652,   109,   666,
       0,   663,    66,    47,    46,     0,   311,   323,     0,   575,
     576,   574,   577,     0,     0,    70,    88,     0,     0,    90,
       0,     0,     0,   200,     0,   199,     0,     0,   206,    12,
       0,   207,     0,     0,    95,     0,     0,    99,   316,   323,
     317,    42,     0,   625,     0,    52,     0,    51,     0,     0,
       0,     0,   191,   193,   198,   571,     0,   134,   176,   137,
     136,     0,     0,     0,     0,   622,     0,     0,     0,     0,
       0,     0,   293,     0,     0,     0,   341,     0,   603,   349,
     155,   638,   293,   603,   557,     0,   556,   410,     0,   278,
       0,   413,     0,   555,   555,   555,   409,     0,   349,     0,
     384,   381,   555,   555,     0,   349,   373,     0,   490,   485,
       0,     0,   489,   486,   487,   293,     0,   500,   551,   550,
     501,   552,   553,   465,   309,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   464,     0,     0,     0,     0,   656,   655,
     654,   380,   293,   555,   409,   334,   342,   293,     0,   333,
       0,   358,     0,     0,   377,     0,   330,   554,   322,   367,
     365,   554,   321,   366,   364,   385,   375,     0,     0,     0,
     326,   374,     0,   628,   618,     0,   298,   634,     7,   293,
     290,   293,     0,     0,   179,    12,     0,   661,     0,     0,
     293,     0,     0,    73,     0,     0,     0,     0,     0,     0,
     202,     0,   204,   205,   201,   319,     0,     0,    12,   274,
       0,   100,     0,   293,    98,     0,     0,     0,     0,     0,
     139,   138,   192,   588,     0,   195,   293,    56,     0,     0,
       0,     0,    75,     0,     0,     0,     0,     0,   592,   581,
     582,     0,   393,   392,   597,   391,   389,   593,   598,   600,
       0,     0,     0,     0,     0,   409,   311,   580,   169,   173,
     589,   559,   603,   415,   414,     0,   373,   353,   352,   351,
     375,     0,     0,   374,   493,     0,     0,     0,   388,     0,
       0,     0,     0,   478,   475,   547,   529,   546,   528,   542,
     524,   543,   525,   548,     0,   541,   523,   540,   522,   536,
     518,   537,   519,   535,   517,   538,   520,   539,   521,   530,
     512,   531,   513,   532,   514,   533,   515,   534,   516,   463,
     461,   462,   460,     0,     0,   341,   343,   373,     0,   346,
       0,   360,   359,   382,   378,   332,   331,     0,     0,     0,
     327,   376,   335,     0,     0,   329,   641,   305,   292,   291,
      64,    65,    63,   293,     0,   668,   671,   670,   664,   667,
      44,     0,    43,    39,    72,    69,    71,     0,   670,    88,
       0,    91,   603,   250,   203,     0,   210,   211,     0,     0,
       0,   293,    41,     0,     0,   646,   644,     0,    55,     0,
       0,   660,    85,   659,     0,   102,   658,    84,     0,     0,
     174,   194,     0,    12,     0,   603,     0,     0,   360,   293,
       0,   595,   584,   583,   472,   602,   466,   467,   469,   474,
     471,   599,   390,     0,   121,   119,     0,     0,   144,   146,
       0,   154,   156,   444,   603,     0,     0,     0,   129,   579,
     558,   560,   562,     0,     0,     0,   354,   356,     0,     0,
     494,     0,     0,     0,     0,   387,     0,     0,     0,     0,
       0,     0,   476,     0,   361,   344,     0,   348,   347,   315,
     383,   336,     0,     0,   328,   340,   339,     0,   110,     0,
     360,     0,     0,     0,     0,    82,   603,     0,   112,   208,
       0,   638,    93,     0,    92,     0,   360,     0,     0,     0,
     642,   303,     0,    50,   293,     0,   587,     0,   274,     0,
       0,     0,    77,     0,     0,   473,     0,     0,   601,   586,
     124,   145,   588,   123,   441,   443,   451,     0,   445,   293,
       0,     0,   598,   611,   159,     0,   130,   128,     0,   125,
     127,   115,   580,   567,   566,   568,     0,   564,   216,   237,
       0,     0,     0,     0,   274,   262,   263,   256,   264,   235,
     231,   260,   255,   257,   258,   259,   261,   236,   232,   233,
     219,   226,   225,   229,   228,     0,   274,   238,   217,   220,
     221,   224,   230,   222,   223,   234,     0,   167,   122,   120,
       0,   355,   357,   544,   526,   497,   496,   495,     0,     0,
     545,   527,   488,   549,   345,   338,   337,     0,   669,   665,
     311,     0,   670,    88,     0,     0,    89,     0,    67,     0,
     101,   318,   647,   645,   651,   650,   649,     0,    53,    54,
       0,   311,     0,   277,     0,     0,   182,   189,   183,   186,
     185,   175,   188,   184,   187,     0,   177,     0,    57,    76,
     591,   596,   468,   470,   585,   311,     0,   442,     0,   444,
     453,   455,     0,   444,   447,   446,     0,     0,   588,     0,
       0,     0,   116,   603,   561,   555,   580,   241,   253,   252,
     254,   239,     0,   274,   218,   240,   407,   406,     0,     0,
       0,     0,   405,   409,     0,   586,   499,   498,   180,     0,
       0,    40,    87,    83,   603,    80,    68,    94,   643,   648,
       0,     0,   197,   311,     0,     0,   192,     0,   178,   594,
       0,   293,   147,     0,   454,   452,     0,   157,   603,   444,
     448,   444,     0,   608,     0,     0,   610,   612,     0,   604,
     605,   311,   563,     0,     0,   171,   170,   603,     0,     0,
       0,   293,   227,     0,   311,   181,    45,     0,   103,    86,
     196,   319,     0,     0,   349,   118,     0,   149,   148,   143,
     456,   457,   311,   450,   449,   606,   607,   160,   609,     0,
     614,   616,   617,     0,   555,     0,   311,   293,     0,     0,
       0,   293,     0,     0,     0,     0,    81,     0,     0,   588,
       0,   603,     0,     0,   613,   126,   565,   242,     0,     0,
     293,   293,   293,     0,     0,   268,   603,   168,   117,   113,
     190,   174,     0,   150,   158,   615,   172,   603,     0,     0,
       0,   293,   603,   243,     0,     0,   249,     0,   603,   603,
     603,     0,   244,   588,   141,   265,   267,     0,   247,   246,
     245,   603,     0,     0,   248,     0,   266,   142
};

/* YYPGOTO[NTERM-NUM].  */
static const yytype_int16 yypgoto[] =
{
   -1118, -1118,  -360, -1118, -1118, -1118, -1118,    23,    36,     7,
      38,  -543, -1118,    42,    48, -1118, -1118, -1118,    57, -1118,
   -1118,    63, -1118, -1118,    70, -1118,    76,  -699,  -693,    84,
   -1118,    85, -1118,  -347, -1118,   -66,   102,   105,   112,   121,
   -1118,   468,  -494,  -956,  -148, -1118, -1118, -1118, -1117,  -914,
   -1118,   -88, -1118, -1118, -1118, -1118,   476, -1118,     1, -1118,
   -1118,   189,    27,    28, -1118, -1118, -1118,  -580, -1118,   763,
     201, -1118, -1118, -1118, -1118, -1118,  -813, -1118,  -869,   414,
   -1118,   481, -1118,   483,   207, -1118, -1118, -1118,  -250, -1118,
   -1118,    13, -1118,  1233,    68, -1118,  1336,    33,   498, -1118,
     821,  -143,     2,  -570,   253,  1488,   -24,  -142,  1229,   340,
    -647,   757,    -1,    49,   -62,    62,    50,   -60, -1118, -1118,
     -70,  1334, -1118,  -371,  -137, -1118, -1118, -1118,   487,   346,
    -772, -1118, -1118,   349, -1118,  1345, -1118,  -748, -1118,   497,
     499, -1118,  -602, -1118, -1118,   525,  -162,  -514, -1118,   -28,
     754, -1118, -1118, -1118,   479, -1118, -1118, -1118,  -222,   -71,
   -1118, -1118,   348,  -574,   322,  -862, -1118,  -600,   694,   614,
     213, -1118, -1118,   251,   -18,  1214,   -97, -1118,   897,   126,
     -68,  1250, -1118,  -264,   159, -1118,   658,   298,  -173, -1118,
    -521
};

/* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int16 yydefgoto[] =
{
       0,     4,     5,   100,   101,   102,   861,   935,   936,   937,
     938,   415,   416,   939,   940,   783,   109,   110,   941,   112,
     113,   942,   745,   202,   943,   116,   944,   775,   576,   945,
     388,   946,   403,   225,   226,   227,   947,   948,   949,   950,
     565,   124,   921,   817,   236,   125,   809,   902,  1103,  1149,
    1182,    40,   633,   126,   127,   128,   129,   130,   951,  1074,
     823,  1126,   952,   953,   888,  1021,  1022,   421,   422,   423,
     954,   209,   210,   135,   588,   399,   955,   956,   957,   958,
    1124,   959,   960,   961,   962,   137,   963,   964,  1216,   965,
    1070,   966,   139,   140,   261,   185,    41,   186,   343,   344,
     345,   155,   174,   407,   157,   313,   247,   159,   160,   248,
     624,   625,   195,    44,   292,   197,    46,    47,   257,   461,
      48,    49,    50,   293,   361,   295,   296,   450,   905,   906,
     907,   908,  1039,  1040,  1150,   297,   298,   795,   796,   797,
     798,   895,   299,   486,   664,   300,   301,   302,   303,   335,
     455,   456,   637,   820,   821,   926,  1056,   927,    51,    52,
     382,   383,   822,   627,  1035,   780,   641,   628,   629,  1217,
     914,  1051,  1116,  1117,   178,    53,   369,   414,   304,   182,
      55,   356,   767,   880,   305,   306,   777,   193,   370,   371,
     738
};

/* YYTABLE[YYPACT[STATE-NUM]] -- What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule whose
   number is the opposite.  If YYTABLE_NINF, syntax error.  */
static const yytype_int16 yytable[] =
{
      43,    43,   348,   144,   145,   262,   131,   571,   196,   237,
     158,   294,   105,   425,   323,   755,   326,   212,   138,   799,
     165,   158,   778,   735,   801,   223,   240,   239,   103,   224,
     224,   886,   132,   133,    42,    57,   156,   238,    43,   586,
    1036,   104,   365,   106,   791,   175,   404,   107,   991,     7,
     251,   865,   736,   108,   749,   898,   864,     7,    43,   592,
    1192,   736,   111,    45,    45,  1061,   850,   253,   114,   378,
     437,   706,   189,    70,     7,   115,   252,  1102,   631,  1100,
     309,   117,   410,    58,   804,  1215,   805,   217,   706,   118,
     119,   363,   170,   171,  1180,   340,   372,   771,     7,   189,
     367,    45,   237,     7,   367,   518,   386,   120,   516,   358,
     121,   147,   354,   340,  -307,  1235,   262,   122,   164,   366,
     239,    45,    59,   315,   320,   148,   123,   184,   218,   149,
     238,   413,   165,   179,    35,    36,   772,  1109,   773,  1043,
     310,   447,    35,    36,  1214,   158,    43,   787,   311,   441,
      60,  1193,   321,   806,   607,   158,   332,   447,   149,    35,
      36,     7,    37,    43,   707,  1163,    38,     7,   262,   836,
     351,   350,   377,   517,  1167,   143,  -307,   799,  1175,  1038,
     164,   353,   153,    35,    36,   190,  1114,    37,    35,    36,
       7,   150,   359,   360,  1061,     7,  1183,   342,   438,   151,
     409,   799,   152,    43,    43,   734,   134,   153,   774,    45,
    1188,   154,   136,   990,   912,  1002,    37,   968,   481,   969,
      38,    43,  1044,  1045,   170,  -311,   346,   191,   758,  1001,
      43,   315,   320,   569,    43,   467,   469,   148,   367,   474,
     312,   294,  1027,   760,   170,   171,    35,    36,   373,   221,
     516,  1008,    35,    36,   230,   164,   837,    43,   998,   838,
     810,  1133,  1168,   207,   332,  1169,    45,    45,   424,   146,
     153,  1110,   389,   390,    37,    35,    36,   368,    38,     7,
      35,    36,   605,   179,    45,   208,   970,  -311,   367,   179,
     405,   374,  1009,    45,   799,   799,  1085,    45,   312,   418,
    1082,  1224,   540,   544,   400,     7,   338,   339,    37,    43,
     790,  1165,    38,   163,   476,   517,   988,  1201,   164,   367,
      45,  1237,   158,    43,   179,  1034,    43,   598,   158,   367,
     340,   545,   583,   168,   652,   585,   551,  1153,   989,  1154,
    1079,   993,   147,   179,   224,   736,   594,   364,   736,   513,
     224,   364,   364,   164,   556,   646,   514,    43,   619,   620,
     149,  1232,   364,   183,    35,    36,   892,  -624,     7,   246,
     170,   200,    45,     7,   161,     7,   596,   597,   364,   639,
     425,  -590,   425,     7,  1132,   161,    45,   364,   417,    45,
      35,    36,   530,   348,  1178,   533,  1005,  -439,   815,  -439,
     170,   431,   364,   180,   187,   364,   179,   242,   467,   469,
     474,  -590,   375,     7,   459,   213,  -272,   188,    37,   816,
      45,   515,   150,   890,   769,   640,   560,   458,   181,  -439,
     151,   192,     7,   152,   148,   315,   320,   608,   153,     7,
     454,    43,   154,   410,   540,   544,     7,   626,   730,   376,
     189,    43,   626,    35,    36,   180,  1099,   164,    35,    36,
      35,    36,    25,    26,    27,   324,   652,   553,    35,    36,
     878,   739,   201,   379,   380,   653,   794,   408,   747,   141,
     398,    37,   557,   325,    43,    38,    37,   263,    37,   731,
      38,   381,   150,   818,   294,   879,    37,   142,    35,    36,
      38,  1034,   148,   448,    45,   453,   519,   520,   332,   161,
     613,   829,   154,   203,    45,   327,  1143,    35,    36,   161,
     634,    43,   204,   816,    35,    36,    43,   283,   224,   338,
     355,    35,    36,   328,   726,   205,   771,   917,   189,  1047,
     799,   622,   284,   285,   623,    37,  1225,    45,  1226,    38,
     442,   647,    37,   662,    43,   206,    38,  1227,    43,   764,
      43,   409,   258,   765,   161,   189,  1026,     7,   325,    43,
     143,  1177,    25,    26,    27,   872,    43,   773,   918,   919,
     149,   920,   429,   434,    45,   430,   873,   131,   342,    45,
     703,   216,    43,   105,   170,   708,   912,    43,   465,   138,
     170,    43,   759,    43,   438,    43,  1145,   784,   442,   103,
     751,  1101,   439,   132,   133,   580,  1102,   346,   442,   648,
     581,    45,   104,    45,   106,  1161,   325,   728,   107,   729,
    1162,   770,    45,   164,   108,   424,   325,   424,   741,    45,
     219,   626,   829,   111,   220,   551,   189,  -638,  -638,   114,
     523,   622,    35,    36,   623,    45,   115,   835,   899,   527,
      45,   763,   117,   228,    45,   570,    45,   593,    45,  1185,
     118,   119,   258,  -638,   782,   170,   600,   528,   294,   601,
      37,  1198,   811,   325,    38,   325,   161,   229,   120,  1204,
     149,   121,   161,  1147,  1206,   231,  1148,   870,   122,   442,
     649,   744,   170,   189,   312,   148,   551,   123,   527,   845,
     626,   642,   626,     7,   812,   434,   813,   325,   237,   348,
     337,   732,   527,   984,   352,   737,   528,   364,   357,   651,
      28,    29,    43,   746,   748,   131,   239,   619,   620,  1088,
     528,   105,  1089,  1119,   617,  1120,   238,   138,    31,    32,
     375,   626,   618,   619,   620,   173,   364,   103,   776,   131,
      43,   132,   133,   393,   395,   105,   747,   394,   786,   396,
     104,   138,   106,   294,   401,   397,   107,  1155,   610,  1156,
     367,   103,   108,   406,   626,   132,   133,   134,    43,   411,
     412,   111,   434,   136,   104,    45,   106,   114,    35,    36,
     107,   857,   447,   478,   115,   482,   108,   999,   458,   810,
     117,   224,   470,   626,  1011,   111,   161,   659,   118,   119,
     904,   114,  1075,    45,   471,   483,    37,   484,   115,   875,
     150,   752,   485,   170,   117,   493,   120,   494,   408,   121,
     522,   546,   118,   119,   554,   555,   122,  1080,   558,  1048,
     154,    45,     1,     2,     3,   123,  1233,   893,   561,   626,
     120,   651,   785,   121,   562,   626,   566,   567,  1092,   568,
     122,    25,    26,    27,   425,   626,   573,   578,   251,   123,
      43,   575,   237,    43,   170,   171,   574,     7,   626,  1018,
     189,   131,   818,   577,   579,   253,  1072,   105,    54,    54,
     239,  1025,   582,   138,  1071,   584,   828,   589,    43,   776,
     238,   904,  1115,   103,   342,  1019,  1020,   132,   133,   776,
     510,   511,   512,   590,   375,   161,   104,   237,   106,   591,
     595,   162,   107,   599,   602,   134,    54,   167,   108,   606,
     172,   136,   162,   346,   240,   239,    45,   111,   161,   177,
    1140,   603,  1010,   114,   253,   238,    54,   604,   608,   134,
     115,   609,  1222,  1071,   612,   136,   117,   199,  1228,  1229,
    1230,    45,    35,    36,   118,   119,   632,  1046,   818,   638,
     616,  1234,   211,   215,   643,   650,   626,   663,   199,   199,
    1078,   818,   120,   161,   241,   121,    25,    26,    27,   410,
      37,  1129,   122,   866,   150,   660,  1128,   661,   699,   818,
      66,   123,   244,   249,   700,   245,   701,   702,   737,   711,
     153,   992,   364,   818,   154,   713,   733,  1122,   923,   924,
     925,  1013,  1141,   723,   740,   254,   742,   828,   508,   509,
     510,   511,   512,   294,   264,   743,   904,   750,   316,   316,
     904,   322,   626,   753,   779,   754,   762,   761,   336,   757,
     788,   349,   630,    77,    78,    79,   162,   636,    81,   768,
      83,    84,   789,   803,   814,   622,   162,  1014,   623,   792,
     793,   819,     7,   626,   454,   189,   826,   241,   499,   827,
     294,   134,   199,   249,   842,    43,   844,   136,   847,   852,
      43,    54,    54,   859,   391,   392,  1015,   626,   860,   506,
     507,   508,   509,   510,   511,   512,   904,   409,   904,    54,
     862,   162,   863,   997,   161,   868,   626,   876,    54,   424,
      43,   419,    54,   426,   427,   882,  1186,   428,   877,   881,
     436,   316,   316,    66,   883,   446,   884,   449,   167,   249,
     457,   885,  1223,   887,   776,   466,   468,   468,    45,   889,
     475,   896,   900,    45,   255,   897,    43,    35,    36,  1146,
      43,  1053,   459,   901,   903,    70,   922,   967,   971,     7,
     626,   972,   189,   973,   284,   285,   978,   979,   980,    43,
      43,    43,   982,    45,   987,   626,    77,    78,    79,  1173,
     994,    81,  1000,    83,    84,   996,   626,   524,   316,   526,
      43,   626,  1029,  1030,   316,  1065,  1042,   626,   626,   626,
    1049,    54,  1052,  1050,    54,  1057,   316,   316,   316,    45,
     626,  1058,  1059,    45,   316,  1189,  1062,  1081,  1060,  1194,
       7,  1086,  1087,   162,  1091,  1090,  1094,  1084,  1098,   162,
    1106,  1111,    45,    45,    45,    54,   825,  1112,  1208,  1209,
    1210,     7,   563,   564,    35,    36,  1113,  1135,  -271,  -270,
    1130,  1136,   436,    45,  1138,     7,  -269,   438,  1139,  1221,
     572,   284,   285,  1157,   198,   547,    25,    26,    27,  1158,
    1142,   199,    37,  1159,   199,  1108,    38,   587,   310,  1171,
     214,  1160,  1174,   199,   432,  1176,   717,   433,  1179,   199,
    1181,  1187,   153,  1190,  1191,  1127,   149,   506,   507,   508,
     509,   510,   511,   512,   453,    35,    36,  1196,  1199,   468,
     468,   468,  1200,  1203,  1207,   611,   316,   316,  1211,    54,
     316,   316,   316,  1205,   316,  1212,    35,    36,  1218,   635,
     448,  1219,  1220,    37,  1231,   249,  1016,    38,  1236,  1102,
      35,    36,   645,  1197,  1017,   548,   867,   781,   549,  1023,
    1064,  1024,   256,   162,    37,   166,   727,   312,    38,  1007,
     314,   319,    54,   802,   176,  1105,   718,  1104,    37,   719,
     334,  1037,    38,  1032,   408,   824,  1033,  1134,   312,   891,
     432,  1054,   362,   433,  1123,   849,   362,   362,   153,  1213,
    1184,     7,   771,   341,   189,   384,   385,   362,   874,    54,
     705,     0,     0,     0,    54,     0,     0,  1127,   913,     0,
     402,     0,     0,   362,   316,     0,     0,     0,   316,     0,
       0,     0,   362,   316,   316,     0,   316,     0,   375,     0,
       0,   772,   349,   773,     0,     0,    54,   435,    54,     0,
     362,     0,     0,     0,     0,   451,     0,    54,  1170,     0,
       0,   434,     0,     0,    54,   249,     0,     0,     0,     0,
     995,   161,   162,     0,     0,     0,     0,   199,   314,   319,
      54,     0,   334,     0,   308,    54,    35,    36,     0,    54,
       7,    54,     0,    54,     0,   162,   249,   316,     0,   347,
       0,   316,   316,   316,     0,     0,     0,     0,   800,     0,
       0,     0,     0,   774,    37,     0,     0,     0,   150,   199,
       0,     0,     0,     0,     0,     0,   244,   310,     0,   245,
       0,     0,     7,     0,   153,   317,     0,     0,   154,     0,
     162,     0,   552,     0,     0,   149,     0,     0,     0,   539,
     543,     0,     0,     8,     9,    10,    11,    12,    13,    14,
      15,  1066,    17,  1067,    19,    20,    21,    22,    23,     0,
       0,     0,     0,     0,     0,    35,    36,     0,    25,    26,
      27,    28,    29,     0,     0,     0,     0,     0,     0,     0,
       0,     0,   462,     0,   316,     0,     0,     0,    30,    31,
      32,     0,     0,    37,   316,     0,   316,    38,     0,     0,
     316,   316,     0,   477,    33,   250,     7,    35,    36,     7,
      54,   487,   488,   489,   490,   491,   492,   312,     0,     0,
     318,     0,     0,     7,     0,     0,     0,   249,     0,   333,
       0,     0,     0,     0,     0,    37,   199,     0,    54,    38,
    1068,     0,     0,   438,     0,     0,   438,  1121,     0,     0,
     532,   443,     0,   535,   440,     0,   800,     0,     0,  1069,
     438,   162,     0,     0,   316,     0,    54,     0,   547,     0,
       0,     0,   314,   319,   334,     0,     0,     0,  1137,     0,
     800,   539,   543,   241,     0,     0,     0,     0,     0,     0,
       0,    35,    36,     0,    35,    36,     0,     0,     0,     0,
       0,     0,  1152,     0,     0,     0,     0,     0,    35,    36,
       0,     0,   199,   318,     0,     0,   333,     0,     0,    37,
       0,  1166,    37,    38,     0,     0,    38,     0,     0,   316,
     316,   444,   334,     0,   445,     0,    37,     0,     0,   332,
      38,     0,     0,   312,     0,     0,   312,   249,   548,     0,
     199,   549,     0,     0,     0,   721,     7,     0,   349,     7,
     312,    54,   362,     0,  1012,     0,     0,     0,     0,   362,
       0,     0,     0,   800,   800,  1202,     0,     0,     0,   525,
       0,     0,     0,     0,     0,   529,    54,     0,   199,   766,
     913,   362,     0,   147,     0,   249,   147,   536,   538,   542,
       0,   173,     0,  1055,   143,   550,     0,   148,     0,     7,
       0,   149,     7,     0,   149,     0,     0,     0,     0,     7,
     666,   668,   670,   672,   673,   674,   676,   678,   680,   682,
     684,   686,   688,   690,   692,   694,   696,   698,     7,     0,
       0,    35,    36,  1073,    35,    36,   147,   241,  -311,   438,
       0,     0,     0,   710,   173,   841,   147,   614,     0,   721,
     148,     0,     0,     0,   149,    25,    26,    27,     0,    37,
       0,   249,    37,   150,   149,   438,   150,     0,     0,     7,
     347,   151,     0,   717,   152,     0,     0,     0,  1093,   153,
       0,  1095,   241,   154,    35,    36,   154,    35,    36,     0,
       0,     0,   254,     0,    35,    36,     0,   525,   529,     0,
    -311,   536,   538,   542,     0,   550,   243,     7,     0,   249,
       0,     0,    37,    35,    36,    37,   150,  1118,     0,    38,
       0,     0,    37,     0,   151,     0,   150,   152,     0,   249,
       0,     0,   153,     0,   151,   199,   154,   152,   249,   312,
       0,    37,   153,   871,   310,    38,   154,     0,     0,     0,
       0,     0,   329,   718,    35,    36,   719,     0,     0,     0,
       0,   199,   149,    54,  1144,   312,     7,     0,    54,   830,
     832,   678,   684,   694,     0,   840,     0,     0,     0,     0,
       0,   704,    37,     0,     0,     7,   150,     0,     0,     0,
    1164,     7,    35,    36,   244,   715,     0,   245,   635,   716,
       0,     0,   153,   147,   720,   722,   154,   725,   162,   800,
       0,   143,     0,     0,     0,     0,     0,     0,     0,     0,
      37,   149,   375,     0,    38,  1083,  1118,     0,   310,     7,
       0,     0,   330,     0,    54,   331,   143,     0,    54,     0,
     332,   249,     0,     0,   312,     0,   149,   362,     0,     0,
       0,    35,    36,     0,     0,     7,     0,    54,    54,    54,
       0,  1003,  1004,  1006,     0,     0,   375,     0,   704,  1107,
      35,    36,   715,   716,   720,     0,    35,    36,    54,    37,
       0,   199,     0,   150,     0,     0,     0,     0,     0,     0,
    1041,   472,   375,     0,   473,  1125,     0,     0,    37,   332,
       0,     0,   150,   154,    37,   894,     0,     0,    38,     0,
     244,     0,     0,   245,    35,    36,   472,     0,   153,   473,
       0,     0,   154,     0,   332,     0,     0,     0,   312,     0,
       0,   916,     0,     0,     0,     0,     0,     0,     0,     0,
      35,    36,    37,     0,     0,     0,   150,     0,   975,   976,
       0,   977,     0,     0,   244,     0,     0,   245,   983,     0,
       0,     7,   153,     0,     0,   846,   154,     0,    37,     0,
       0,     0,   150,     0,     0,   851,     0,   854,     0,     0,
     244,   855,   856,   245,     0,     0,     0,     0,   153,     0,
       0,     0,   154,     0,     0,     0,   347,     0,   438,     0,
     807,     0,     7,     0,     0,   189,   265,    25,    26,    27,
     266,   267,   268,   269,   270,   271,   272,   273,   274,   275,
     276,   277,  1041,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,   278,
       0,    25,    26,    27,     0,   846,    35,    36,    25,    26,
      27,    28,    29,     0,   280,   281,     0,   808,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    30,    31,
      32,   617,     0,     0,    37,     0,     0,     0,    38,   618,
     619,   620,     0,   621,    33,     0,   282,    35,    36,     0,
     283,     0,     0,  1076,  1077,     0,     0,     0,   312,     0,
       0,     0,     0,     0,   284,   285,     0,     0,     0,     0,
     985,   986,     0,     0,     0,    37,     0,     0,     0,    38,
     622,     0,     0,   623,     0,     0,     0,     0,     0,     0,
     286,     0,     0,   287,   288,   289,   915,     0,     7,   290,
     291,   189,   265,     0,     7,     0,   266,   267,   268,   269,
     270,   271,   272,   273,   274,   275,   276,   277,     0,     8,
       9,    10,    11,    12,    13,    14,    15,    16,    17,    18,
      19,    20,    21,    22,    23,   278,     0,    25,    26,    27,
     279,   310,     0,     0,    25,    26,    27,    28,    29,   537,
     280,   281,     0,     0,     0,     0,     0,     0,     0,   149,
       0,     0,     0,     0,    30,    31,    32,   617,   495,   496,
     497,   498,   499,     0,     0,   618,   619,   620,     0,     0,
      33,  1151,   282,    35,    36,     0,   283,     0,     0,    35,
      36,     7,   505,   506,   507,   508,   509,   510,   511,   512,
     284,   285,     0,     0,     0,  1172,     0,     0,     0,     0,
       0,    37,     0,     0,     0,    38,   622,    37,     0,   623,
       0,    38,     0,     0,     0,     0,   286,     0,   438,   287,
     288,   289,   807,     0,     7,   290,   291,   189,   265,     0,
       0,   312,   266,   267,   268,   269,   270,   271,   272,   273,
     274,   275,   276,   277,     0,     8,     9,    10,    11,    12,
      13,    14,    15,    16,    17,    18,    19,    20,    21,    22,
      23,   278,     0,     0,     0,     0,    35,    36,     0,     0,
      25,    26,    27,    28,    29,     0,   280,   281,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      30,    31,    32,     0,    37,     0,     0,     0,    38,     0,
       0,     0,     0,     0,     0,     0,    33,     0,   282,    35,
      36,     0,   283,     0,   332,     0,     0,     0,   312,     0,
       0,     0,     0,     0,     0,     0,   284,   285,     0,     0,
       7,     0,     7,     0,     0,   189,     0,    37,     0,     0,
       0,    38,   268,   269,   270,   271,   272,   273,   274,   275,
     276,   277,   286,     0,     0,   287,   288,   289,   460,     0,
       7,   290,   291,   189,   265,     0,     0,   375,   266,   267,
     268,   269,   270,   271,   272,   273,   274,   275,   276,   277,
       0,     8,     9,    10,    11,    12,    13,    14,    15,    16,
      17,    18,    19,    20,    21,    22,    23,   278,     0,     0,
       0,     0,     0,     0,     0,     0,    25,    26,    27,    28,
      29,     0,   280,   281,     0,    35,    36,    35,    36,     0,
       0,     0,     0,     0,     0,     0,    30,    31,    32,     0,
       0,     0,     0,     0,   284,   285,     0,     0,     0,     7,
       0,     0,    33,    37,   282,    35,    36,   150,   283,     0,
       0,     0,     0,     0,     0,   244,     0,     0,   245,     0,
       0,     0,     0,   153,     0,     0,     0,   154,     0,     0,
       0,     0,     0,    37,     0,     0,   258,    38,   928,     0,
    -274,    62,     0,     0,   143,    63,    64,    65,   286,     0,
       0,   287,   288,   289,   149,     0,     0,   290,   291,     0,
      66,  -274,  -274,  -274,  -274,  -274,  -274,  -274,  -274,  -274,
    -274,  -274,  -274,  -274,  -274,  -274,  -274,     0,     0,     0,
     929,    68,     0,  -214,    35,    36,  -274,  -274,  -274,  -274,
    -274,     0,     0,     0,     0,     0,     0,     0,     0,    70,
      71,    72,   930,    74,    75,    76,  -274,  -274,  -274,   931,
     932,   933,    37,    77,    78,    79,    38,    80,    81,    82,
      83,    84,  -274,  -274,   472,  -274,  -274,   473,     0,    85,
       0,     0,   332,    89,    90,    91,    92,    93,    94,    95,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    96,     0,  -274,     0,     0,    97,  -274,  -274,     0,
       0,     0,   934,     0,     0,     0,     0,     0,     0,     0,
       7,     0,     0,   189,   265,     0,     7,  -274,   266,   267,
     268,   269,   270,   271,   272,   273,   274,   275,   276,   277,
       0,     8,     9,    10,    11,    12,    13,    14,    15,    16,
      17,    18,    19,    20,    21,    22,    23,   278,     0,     0,
       0,     0,   279,   310,     0,     0,    25,    26,    27,    28,
      29,   541,   280,   281,     0,     0,     0,     0,     0,     0,
       0,   149,     0,     0,     0,     0,    30,    31,    32,     0,
     495,   496,   497,   498,   499,     0,     0,     0,     0,   495,
     496,     0,    33,   499,   282,    35,    36,     0,   283,     0,
       0,    35,    36,   504,   505,   506,   507,   508,   509,   510,
     511,   512,   284,   285,   506,   507,   508,   509,   510,   511,
     512,     0,     0,    37,     0,     0,     0,    38,     0,    37,
       0,     0,     0,    38,     0,     0,     0,     0,   286,     0,
       0,   287,   288,   289,     0,     0,     7,   290,   291,   189,
     265,     0,     7,   312,   266,   267,   268,   269,   270,   271,
     272,   273,   274,   275,   276,   277,     0,     8,     9,    10,
      11,    12,    13,    14,    15,    16,    17,    18,    19,    20,
      21,    22,    23,   278,     0,     0,     0,   843,     0,   438,
       0,    24,    25,    26,    27,    28,    29,   615,   280,   281,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    30,    31,    32,     0,     0,     0,     0,   495,
     496,   497,   498,   499,     0,   500,     0,     0,    33,    34,
     282,    35,    36,     0,   283,     0,     0,    35,    36,   501,
     502,   503,   504,   505,   506,   507,   508,   509,   510,   511,
     512,     0,     0,     0,     0,     0,     0,     0,     0,    37,
       0,     0,     0,    38,     0,    37,     0,     0,    39,    38,
       0,     0,     0,     0,   286,     0,     0,   287,   288,   289,
       0,     0,     7,   290,   291,   189,   265,  1195,     0,   312,
     266,   267,   268,   269,   270,   271,   272,   273,   274,   275,
     276,   277,     0,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,   278,
       0,     0,     0,     0,     0,     0,     0,     0,    25,    26,
      27,    28,    29,     0,   280,   281,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    30,    31,
      32,   495,   496,   497,   498,   499,     0,   500,     0,     0,
       0,     0,     0,     0,    33,     0,   282,    35,    36,     0,
     283,   501,   502,   503,   504,   505,   506,   507,   508,   509,
     510,   511,   512,     0,   284,   285,     0,     0,     7,     0,
       0,     0,     0,   189,     0,    37,     0,     0,     0,    38,
     268,   269,   270,   271,   272,   273,   274,   275,   276,   277,
     286,     0,     0,   287,   288,   289,     0,     0,     7,   290,
     291,   189,   265,     0,     0,   452,   266,   267,   268,   269,
     270,   271,   272,   273,   274,   275,   276,   277,     0,     8,
       9,    10,    11,    12,    13,    14,    15,    16,    17,    18,
      19,    20,    21,    22,    23,   278,   833,     0,     0,     0,
       0,     0,     0,   677,    25,    26,    27,    28,    29,     0,
     280,   281,     0,    35,    36,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    30,    31,    32,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      33,    37,   282,    35,    36,   150,   283,     0,     0,     0,
       0,     0,     0,   244,     0,     0,   245,     0,     0,     0,
       0,   153,     0,     0,     7,   154,     0,     0,     0,     0,
       0,    37,     0,     0,     0,    38,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   286,     0,     0,   287,
     288,   289,     0,     0,     7,   290,   291,   189,   265,     0,
       7,  1131,   266,   267,   268,   269,   270,   271,   272,   273,
     274,   275,   276,   277,     0,     8,     9,    10,    11,    12,
      13,    14,    15,    16,    17,    18,    19,    20,    21,    22,
      23,   278,   834,     0,     0,     0,     0,   438,     0,   683,
      25,    26,    27,    28,    29,   724,   280,   281,     0,    35,
      36,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      30,    31,    32,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    33,    37,   282,    35,
      36,   150,   283,     0,     0,    35,    36,     0,     0,   244,
       0,     0,   245,     0,     0,     0,     0,   153,     0,     0,
       0,   154,     0,     0,     0,     0,     0,    37,     0,     0,
       0,    38,     0,    37,     0,     0,     0,    38,     0,     0,
       0,     0,   286,     0,     0,   287,   288,   289,     0,     0,
       7,   290,   291,   189,   265,     0,     7,   312,   266,   267,
     268,   269,   270,   271,   272,   273,   274,   275,   276,   277,
       0,     8,     9,    10,    11,    12,    13,    14,    15,    16,
      17,    18,    19,    20,    21,    22,    23,   278,     0,     0,
       0,     0,     0,   438,     0,     0,    25,    26,    27,    28,
      29,   853,   280,   281,     0,     0,   307,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    30,    31,    32,     0,
       0,     0,     0,   495,   496,   497,   498,   499,     0,   500,
       0,     0,    33,     0,   282,    35,    36,     0,   283,     0,
       0,    35,    36,   501,   502,   503,   504,   505,   506,   507,
     508,   509,   510,   511,   512,     0,     0,     0,     0,     0,
       0,     0,     0,    37,     0,     0,     0,    38,     0,    37,
       0,     0,     0,    38,     0,     0,     0,     0,   286,     0,
       0,   287,   288,   289,     0,     0,     7,   290,   291,   189,
     265,     0,   654,   312,   266,   267,   268,   269,   270,   271,
     272,   273,   274,   275,   276,   277,     0,     8,     9,    10,
      11,    12,    13,    14,    15,    16,    17,    18,    19,    20,
      21,    22,    23,   278,     0,     0,     0,     0,     0,     0,
       0,     0,    25,    26,    27,    28,    29,     0,   280,   281,
       0,     0,   531,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    30,    31,    32,   655,     0,     0,   495,   496,
     497,   498,   499,     0,   500,     0,     0,     0,    33,     0,
     282,    35,    36,     0,   283,     0,     0,     0,   501,   656,
     503,   504,   657,   506,   507,   508,   509,   658,   511,   512,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    37,
       0,     0,     0,    38,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   286,     0,     0,   287,   288,   289,
       0,     0,     7,   290,   291,   189,   265,   644,     0,     0,
     266,   267,   268,   269,   270,   271,   272,   273,   274,   275,
     276,   277,     0,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,   278,
       0,     0,     0,     0,     0,     0,     0,     0,    25,    26,
      27,    28,    29,     0,   280,   281,     0,     0,   534,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    30,    31,
      32,     0,     0,   495,   496,   497,   498,   499,     0,   500,
       0,     0,     0,     0,    33,     0,   282,    35,    36,     0,
     283,     0,     0,   501,   502,   503,   504,   505,   506,   507,
     508,   509,   510,   511,   512,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    37,     0,     0,     0,    38,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     286,     0,     0,   287,   288,   289,     0,     0,     7,   290,
     291,   189,   265,   974,     0,     0,   266,   267,   268,   269,
     270,   271,   272,   273,   274,   275,   276,   277,     0,     8,
       9,    10,    11,    12,    13,    14,    15,    16,    17,    18,
      19,    20,    21,    22,    23,   278,     0,     0,     0,     0,
       0,     0,     0,   665,    25,    26,    27,    28,    29,     0,
     280,   281,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    30,    31,    32,     0,     0,   495,
     496,   497,   498,   499,     0,   500,     0,     0,     0,     0,
      33,     0,   282,    35,    36,     0,   283,     0,     0,   501,
     502,   503,   504,   505,   506,   507,   508,   509,   510,   511,
     512,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    37,     0,     0,     0,    38,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   286,     0,     0,   287,
     288,   289,     0,     0,     7,   290,   291,   189,   265,   981,
       0,     0,   266,   267,   268,   269,   270,   271,   272,   273,
     274,   275,   276,   277,     0,     8,     9,    10,    11,    12,
      13,    14,    15,    16,    17,    18,    19,    20,    21,    22,
      23,   278,     0,     0,     0,     0,     0,     0,     0,   667,
      25,    26,    27,    28,    29,     0,   280,   281,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      30,    31,    32,     0,     0,   495,   496,   497,   498,   499,
       0,   500,     0,     0,     0,     0,    33,     0,   282,    35,
      36,     0,   283,     0,     0,   501,   502,   503,   504,   505,
     506,   507,   508,   509,   510,   511,   512,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    37,     0,     0,
       0,    38,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,   286,     0,     0,   287,   288,   289,     0,     0,
       7,   290,   291,   189,   265,  1031,     0,     0,   266,   267,
     268,   269,   270,   271,   272,   273,   274,   275,   276,   277,
       0,     8,     9,    10,    11,    12,    13,    14,    15,    16,
      17,    18,    19,    20,    21,    22,    23,   278,     0,     0,
       0,     0,     0,     0,     0,   669,    25,    26,    27,    28,
      29,     0,   280,   281,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    30,    31,    32,     0,
       0,   495,   496,   497,   498,   499,     0,   500,     0,     0,
       0,     0,    33,     0,   282,    35,    36,     0,   283,     0,
       0,   501,   502,   503,   504,   505,   506,   507,   508,   509,
     510,   511,   512,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    37,     0,     0,     0,    38,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   286,     0,
       0,   287,   288,   289,     0,     0,     7,   290,   291,   189,
     265,     0,     0,     0,   266,   267,   268,   269,   270,   271,
     272,   273,   274,   275,   276,   277,     0,     8,     9,    10,
      11,    12,    13,    14,    15,    16,    17,    18,    19,    20,
      21,    22,    23,   278,     0,     0,     0,     0,     0,     0,
       0,   671,    25,    26,    27,    28,    29,     0,   280,   281,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    30,    31,    32,   495,   496,   497,   498,   499,
       0,     0,   495,   496,   497,   498,   499,     0,    33,     0,
     282,    35,    36,     0,   283,   501,   502,   503,   504,   505,
     506,   507,   508,   509,   510,   511,   512,   506,   507,   508,
     509,   510,   511,   512,     0,     0,     0,     0,     0,    37,
       0,     0,     0,    38,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   286,     0,     0,   287,   288,   289,
       0,     0,     7,   290,   291,   189,   265,     0,     0,     0,
     266,   267,   268,   269,   270,   271,   272,   273,   274,   275,
     276,   277,     0,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,   278,
       0,     0,     0,     0,     0,     0,     0,   675,    25,    26,
      27,    28,    29,     0,   280,   281,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    30,    31,
      32,   495,   496,   497,   498,   499,     0,     0,     0,     0,
       0,     0,     0,     0,    33,     0,   282,    35,    36,     0,
     283,     0,   502,   503,   504,   505,   506,   507,   508,   509,
     510,   511,   512,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    37,     0,     0,     0,    38,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     286,     0,     0,   287,   288,   289,     0,     0,     7,   290,
     291,   189,   265,     0,     0,     0,   266,   267,   268,   269,
     270,   271,   272,   273,   274,   275,   276,   277,     0,     8,
       9,    10,    11,    12,    13,    14,    15,    16,    17,    18,
      19,    20,    21,    22,    23,   278,     0,     0,     0,     0,
       0,     0,     0,   677,    25,    26,    27,    28,    29,     0,
     280,   281,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    30,    31,    32,   495,   496,   497,
     498,   499,     0,     0,     0,     0,     0,     0,     0,     0,
      33,     0,   282,    35,    36,     0,   283,     0,     0,   503,
     504,   505,   506,   507,   508,   509,   510,   511,   512,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    37,     0,     0,     0,    38,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   286,     0,     0,   287,
     288,   289,     0,     0,     7,   290,   291,   189,   265,     0,
       0,     0,   266,   267,   268,   269,   270,   271,   272,   273,
     274,   275,   276,   277,     0,     8,     9,    10,    11,    12,
      13,    14,    15,    16,    17,    18,    19,    20,    21,    22,
      23,   278,     0,     0,     0,     0,     0,     0,     0,   679,
      25,    26,    27,    28,    29,     0,   280,   281,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      30,    31,    32,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    33,     0,   282,    35,
      36,     0,   283,     8,     9,    10,    11,    12,    13,    14,
      15,     0,    17,     0,    19,    20,    21,    22,    23,     0,
       0,     0,     0,     0,     0,     0,     0,    37,     0,     0,
       0,    38,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,   286,     0,     0,   287,   288,   289,     0,     0,
       7,   290,   291,   189,   265,     0,     0,     0,   266,   267,
     268,   269,   270,   271,   272,   273,   274,   275,   276,   277,
       0,     8,     9,    10,    11,    12,    13,    14,    15,    16,
      17,    18,    19,    20,    21,    22,    23,   278,     0,     0,
       0,     0,     0,     0,     0,   681,    25,    26,    27,    28,
      29,     0,   280,   281,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    30,    31,    32,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    33,     0,   282,    35,    36,     0,   283,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    37,     0,     0,     0,    38,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   286,     0,
       0,   287,   288,   289,     0,     0,     7,   290,   291,   189,
     265,     0,     0,     0,   266,   267,   268,   269,   270,   271,
     272,   273,   274,   275,   276,   277,     0,     8,     9,    10,
      11,    12,    13,    14,    15,    16,    17,    18,    19,    20,
      21,    22,    23,   278,     0,     0,     0,     0,     0,     0,
       0,   683,    25,    26,    27,    28,    29,     0,   280,   281,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    30,    31,    32,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    33,     0,
     282,    35,    36,     0,   283,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    37,
       0,     0,     0,    38,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   286,     0,     0,   287,   288,   289,
       0,     0,     7,   290,   291,   189,   265,     0,     0,     0,
     266,   267,   268,   269,   270,   271,   272,   273,   274,   275,
     276,   277,     0,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,   278,
       0,     0,     0,     0,     0,     0,     0,   685,    25,    26,
      27,    28,    29,     0,   280,   281,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    30,    31,
      32,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    33,     0,   282,    35,    36,     0,
     283,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    37,     0,     0,     0,    38,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     286,     0,     0,   287,   288,   289,     0,     0,     7,   290,
     291,   189,   265,     0,     0,     0,   266,   267,   268,   269,
     270,   271,   272,   273,   274,   275,   276,   277,     0,     8,
       9,    10,    11,    12,    13,    14,    15,    16,    17,    18,
      19,    20,    21,    22,    23,   278,     0,     0,     0,     0,
       0,     0,     0,   687,    25,    26,    27,    28,    29,     0,
     280,   281,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    30,    31,    32,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      33,     0,   282,    35,    36,     0,   283,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    37,     0,     0,     0,    38,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   286,     0,     0,   287,
     288,   289,     0,     0,     7,   290,   291,   189,   265,     0,
       0,     0,   266,   267,   268,   269,   270,   271,   272,   273,
     274,   275,   276,   277,     0,     8,     9,    10,    11,    12,
      13,    14,    15,    16,    17,    18,    19,    20,    21,    22,
      23,   278,     0,     0,     0,     0,     0,     0,     0,   689,
      25,    26,    27,    28,    29,     0,   280,   281,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      30,    31,    32,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    33,     0,   282,    35,
      36,     0,   283,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    37,     0,     0,
       0,    38,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,   286,     0,     0,   287,   288,   289,     0,     0,
       7,   290,   291,   189,   265,     0,     0,     0,   266,   267,
     268,   269,   270,   271,   272,   273,   274,   275,   276,   277,
       0,     8,     9,    10,    11,    12,    13,    14,    15,    16,
      17,    18,    19,    20,    21,    22,    23,   278,     0,     0,
       0,     0,     0,     0,     0,   691,    25,    26,    27,    28,
      29,     0,   280,   281,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    30,    31,    32,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    33,     0,   282,    35,    36,     0,   283,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    37,     0,     0,     0,    38,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   286,     0,
       0,   287,   288,   289,     0,     0,     7,   290,   291,   189,
     265,     0,     0,     0,   266,   267,   268,   269,   270,   271,
     272,   273,   274,   275,   276,   277,     0,     8,     9,    10,
      11,    12,    13,    14,    15,    16,    17,    18,    19,    20,
      21,    22,    23,   278,     0,     0,     0,     0,     0,     0,
       0,   693,    25,    26,    27,    28,    29,     0,   280,   281,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    30,    31,    32,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    33,     0,
     282,    35,    36,     0,   283,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    37,
       0,     0,     0,    38,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   286,     0,     0,   287,   288,   289,
       0,     0,     7,   290,   291,   189,   265,     0,     0,     0,
     266,   267,   268,   269,   270,   271,   272,   273,   274,   275,
     276,   277,     0,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,   278,
       0,     0,     0,     0,     0,     0,     0,   695,    25,    26,
      27,    28,    29,     0,   280,   281,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    30,    31,
      32,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    33,     0,   282,    35,    36,     0,
     283,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    37,     0,     0,     0,    38,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     286,     0,     0,   287,   288,   289,     0,     0,     7,   290,
     291,   189,   265,     0,     0,     0,   266,   267,   268,   269,
     270,   271,   272,   273,   274,   275,   276,   277,     0,     8,
       9,    10,    11,    12,    13,    14,    15,    16,    17,    18,
      19,    20,    21,    22,    23,   278,     0,     0,     0,     0,
       0,     0,     0,   697,    25,    26,    27,    28,    29,     0,
     280,   281,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    30,    31,    32,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      33,     0,   282,    35,    36,     0,   283,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    37,     0,     0,     0,    38,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   286,     0,     0,   287,
     288,   289,     0,     0,     7,   290,   291,   189,   265,     0,
       0,     0,   266,   267,   268,   269,   270,   271,   272,   273,
     274,   275,   276,   277,     0,     8,     9,    10,    11,    12,
      13,    14,    15,    16,    17,    18,    19,    20,    21,    22,
      23,   278,     0,     0,     0,     0,     0,     0,     0,     0,
      25,    26,    27,    28,    29,     0,   280,   281,     0,     0,
     709,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      30,    31,    32,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    33,     0,   282,    35,
      36,     0,   283,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    37,     0,     0,
       0,    38,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,   286,     0,     0,   287,   288,   289,     0,     0,
       7,   290,   291,   189,   265,     0,     0,     0,   266,   267,
     268,   269,   270,   271,   272,   273,   274,   275,   276,   277,
       0,     8,     9,    10,    11,    12,    13,    14,    15,    16,
      17,    18,    19,    20,    21,    22,    23,   278,     0,     0,
       0,     0,     0,     0,     0,   831,    25,    26,    27,    28,
      29,     0,   280,   281,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    30,    31,    32,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    33,     0,   282,    35,    36,     0,   283,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    37,     0,     0,     0,    38,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   286,     0,
       0,   287,   288,   289,     0,     0,     7,   290,   291,   189,
     265,     0,     0,     0,   266,   267,   268,   269,   270,   271,
     272,   273,   274,   275,   276,   277,     0,     8,     9,    10,
      11,    12,    13,    14,    15,    16,    17,    18,    19,    20,
      21,    22,    23,   278,     0,     0,     0,     0,     0,     0,
       0,   839,    25,    26,    27,    28,    29,     0,   280,   281,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    30,    31,    32,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    33,     0,
     282,    35,    36,     0,   283,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    37,
       0,     0,     0,    38,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   286,     0,     0,   287,   288,   289,
       0,     0,     7,   290,   291,   189,   265,     0,     0,     0,
     266,   267,   268,   269,   270,   271,   272,   273,   274,   275,
     276,   277,     0,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,   278,
       0,     0,     0,     0,     0,     0,     0,     0,    25,    26,
      27,    28,    29,     0,   280,   281,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    30,    31,
      32,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    33,     0,   282,    35,    36,     0,
     283,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    37,     0,     0,     0,    38,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     286,     0,     0,   287,   288,   289,     0,     0,     7,   290,
     291,   189,   265,     0,     0,     0,   266,   267,   268,   269,
     270,   271,   272,   273,   274,   275,   276,   277,     0,     8,
       9,    10,    11,    12,    13,    14,    15,    16,    17,    18,
      19,    20,    21,    22,    23,   278,     0,     0,     0,     0,
       0,     0,     0,   693,    25,    26,    27,    28,    29,   521,
     280,   281,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    30,    31,    32,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      33,     0,   282,    35,    36,     0,   283,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   495,   496,   497,
     498,   499,     0,   500,     0,     0,     0,     0,     0,     0,
       0,    37,     0,     0,     0,    38,     0,   501,   502,   503,
     504,   505,   506,   507,   508,   509,   510,   511,   512,   287,
     288,     0,     0,     0,     7,   290,   291,   189,   265,     0,
       0,     0,   266,   267,   268,   269,   270,   271,   272,   273,
     274,   275,   276,   277,     0,     8,     9,    10,    11,    12,
      13,    14,    15,    16,    17,    18,    19,    20,    21,    22,
      23,   278,     0,     0,     0,     0,     0,     0,     0,     0,
      25,    26,    27,    28,    29,     0,   280,   281,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      30,    31,    32,     0,     0,     0,     0,     7,     0,     0,
       0,     0,     0,     0,     0,     0,    33,     0,   282,    35,
      36,     0,   283,     0,     0,     0,     0,     0,     8,     9,
      10,    11,    12,    13,    14,    15,    16,    17,    18,    19,
      20,    21,    22,    23,   258,     0,     0,    37,     0,     0,
       0,    38,    24,    25,    26,    27,    28,    29,     0,     0,
       0,     0,   149,     0,     0,     0,     0,     0,     0,     0,
       0,   290,   291,    30,    31,    32,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    33,
      34,     0,    35,    36,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      37,     7,     0,     0,    38,     0,     0,     0,     0,    39,
       0,     0,   259,     0,     0,   260,     0,     0,     0,     0,
     153,     0,     8,     9,    10,    11,    12,    13,    14,    15,
      16,    17,    18,    19,    20,    21,    22,    23,   258,     0,
       0,     0,     0,     0,     0,     0,    24,    25,    26,    27,
      28,    29,     0,     0,     0,     0,   149,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    30,    31,    32,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    33,    34,     0,    35,    36,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    37,     7,     0,     0,    38,     0,
       0,     0,     0,    39,     0,     0,   463,     0,     0,   464,
       0,     0,     0,     0,   153,     0,     8,     9,    10,    11,
      12,    13,    14,    15,    16,    17,    18,    19,    20,    21,
      22,    23,     0,     0,     0,     0,     0,     0,     0,     0,
      24,    25,    26,    27,    28,    29,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    30,    31,    32,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    33,    34,     0,
      35,    36,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    -2,    61,    37,  -274,
      62,     0,    38,     0,    63,    64,    65,    39,     0,     0,
     432,     0,     0,   433,     0,     0,     0,     0,   153,    66,
    -274,  -274,  -274,  -274,  -274,  -274,  -274,  -274,  -274,  -274,
    -274,  -274,  -274,  -274,  -274,  -274,     0,     0,     0,    67,
      68,     0,     0,     0,     0,  -274,  -274,  -274,  -274,  -274,
       0,     0,     0,    69,     0,     0,     0,     0,    70,    71,
      72,    73,    74,    75,    76,  -274,  -274,  -274,     0,     0,
       0,     0,    77,    78,    79,     0,    80,    81,    82,    83,
      84,  -274,  -274,     0,  -274,  -274,     0,     0,    85,    86,
      87,    88,    89,    90,    91,    92,    93,    94,    95,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      96,    61,  -274,  -274,    62,    97,  -274,     0,    63,    64,
      65,    98,    99,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    66,  -274,  -274,  -274,  -274,  -274,  -274,
    -274,  -274,  -274,  -274,  -274,  -274,  -274,  -274,  -274,  -274,
       0,     0,     0,    67,    68,     0,   756,     0,     0,  -274,
    -274,  -274,  -274,  -274,     0,     0,     0,    69,     0,     0,
       0,     0,    70,    71,    72,    73,    74,    75,    76,  -274,
    -274,  -274,     0,     0,     0,     0,    77,    78,    79,     0,
      80,    81,    82,    83,    84,  -274,  -274,     0,  -274,  -274,
       0,     0,    85,    86,    87,    88,    89,    90,    91,    92,
      93,    94,    95,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    96,    61,  -274,  -274,    62,    97,
    -274,     0,    63,    64,    65,    98,    99,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    66,  -274,  -274,
    -274,  -274,  -274,  -274,  -274,  -274,  -274,  -274,  -274,  -274,
    -274,  -274,  -274,  -274,     0,     0,     0,    67,    68,     0,
     858,     0,     0,  -274,  -274,  -274,  -274,  -274,     0,     0,
       0,    69,     0,     0,     0,     0,    70,    71,    72,    73,
      74,    75,    76,  -274,  -274,  -274,     0,     0,     0,     0,
      77,    78,    79,     0,    80,    81,    82,    83,    84,  -274,
    -274,     0,  -274,  -274,     0,     0,    85,    86,    87,    88,
      89,    90,    91,    92,    93,    94,    95,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    96,    61,
    -274,  -274,    62,    97,  -274,     0,    63,    64,    65,    98,
      99,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    66,  -274,  -274,  -274,  -274,  -274,  -274,  -274,  -274,
    -274,  -274,  -274,  -274,  -274,  -274,  -274,  -274,     0,     0,
       0,    67,    68,     0,   869,     0,     0,  -274,  -274,  -274,
    -274,  -274,     0,     0,     0,    69,     0,     0,     0,     0,
      70,    71,    72,    73,    74,    75,    76,  -274,  -274,  -274,
       0,     0,     0,     0,    77,    78,    79,     0,    80,    81,
      82,    83,    84,  -274,  -274,     0,  -274,  -274,     0,     0,
      85,    86,    87,    88,    89,    90,    91,    92,    93,    94,
      95,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    96,    61,  -274,  -274,    62,    97,  -274,     0,
      63,    64,    65,    98,    99,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    66,  -274,  -274,  -274,  -274,
    -274,  -274,  -274,  -274,  -274,  -274,  -274,  -274,  -274,  -274,
    -274,  -274,     0,     0,     0,    67,    68,     0,     0,     0,
       0,  -274,  -274,  -274,  -274,  -274,     0,     0,     0,    69,
       0,     0,     0,  1028,    70,    71,    72,    73,    74,    75,
      76,  -274,  -274,  -274,     0,     0,     0,     0,    77,    78,
      79,     0,    80,    81,    82,    83,    84,  -274,  -274,     0,
    -274,  -274,     0,     0,    85,    86,    87,    88,    89,    90,
      91,    92,    93,    94,    95,     0,     6,     0,     7,     0,
       0,     0,     0,     0,     0,     0,    96,     0,  -274,     0,
       0,    97,  -274,     0,     0,     0,     0,    98,    99,     8,
       9,    10,    11,    12,    13,    14,    15,    16,    17,    18,
      19,    20,    21,    22,    23,     0,     0,     0,     0,     0,
       0,     0,     0,    24,    25,    26,    27,    28,    29,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    30,    31,    32,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      33,    34,     0,    35,    36,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    56,     0,
       7,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    37,     0,     0,     0,    38,     0,     0,     0,     0,
      39,     8,     9,    10,    11,    12,    13,    14,    15,    16,
      17,    18,    19,    20,    21,    22,    23,     0,     0,     0,
       0,     0,     0,     0,     0,    24,    25,    26,    27,    28,
      29,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    30,    31,    32,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    33,    34,     0,    35,    36,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     7,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    37,     0,     0,     0,    38,     0,     0,
       0,     0,    39,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,     0,
       0,     0,     0,     0,     0,     0,     0,    24,    25,    26,
      27,    28,    29,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    30,    31,
      32,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    33,    34,     0,    35,    36,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     7,     0,     0,     0,
       0,     0,     0,     0,     0,    37,   387,     0,     0,    38,
       0,     0,     0,     0,    39,   559,     0,     8,     9,    10,
      11,    12,    13,    14,    15,    16,    17,    18,    19,    20,
      21,    22,    23,     0,     0,     0,     0,     0,     0,     0,
       0,    24,    25,    26,    27,    28,    29,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    30,    31,    32,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    33,    34,
       0,    35,    36,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     7,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    37,
       0,     0,     0,    38,     0,     0,     0,     0,    39,     8,
       9,    10,    11,    12,    13,    14,    15,    16,    17,    18,
      19,    20,    21,    22,    23,     0,     0,     0,     0,     0,
       0,     0,     0,    24,    25,    26,    27,    28,    29,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    30,    31,    32,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      33,    34,     0,    35,    36,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       7,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    37,     0,     0,   420,    38,     0,     0,     0,     0,
      39,     8,     9,    10,    11,    12,    13,    14,    15,    16,
      17,    18,    19,    20,    21,    22,    23,     0,     0,     0,
       0,     0,     0,     0,     0,    24,    25,    26,    27,    28,
      29,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    62,    30,    31,    32,    63,
      64,    65,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    33,    34,    66,    35,    36,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   929,    68,     0,  -212,     0,     0,
       0,     0,     0,    37,     0,     0,     0,    38,     0,     0,
       0,     0,    39,    70,    71,    72,   930,    74,    75,    76,
       0,     0,     0,   931,   932,   933,     0,    77,    78,    79,
       0,    80,    81,    82,    83,    84,     0,     0,     0,     0,
       0,     0,     0,    85,     0,     0,     0,    89,    90,    91,
      92,    93,    94,    95,   194,     0,     7,     0,     0,     0,
       0,     0,     0,     0,     0,    96,     0,     0,     0,     0,
      97,     0,     0,     0,     0,     0,  1063,     8,     9,    10,
      11,    12,    13,    14,    15,    16,    17,    18,    19,    20,
      21,    22,    23,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    25,    26,    27,    28,    29,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    30,    31,    32,     0,     0,     0,     7,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    33,     0,
       0,    35,    36,     0,     0,     0,     0,     0,     0,     8,
       9,    10,    11,    12,    13,    14,    15,    16,    17,    18,
      19,    20,    21,    22,    23,     0,     0,     0,     0,    37,
       0,     0,     0,    38,    25,    26,    27,    28,    29,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    30,    31,    32,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      33,  1097,     0,    35,    36,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     7,
       0,    37,   189,   265,     0,    38,  1068,   266,   267,   268,
     269,   270,   271,   272,   273,   274,   275,   276,   277,     0,
       8,     9,    10,    11,    12,    13,    14,    15,    16,    17,
      18,    19,    20,    21,    22,    23,   479,     0,     0,     0,
       0,     0,     0,     0,   480,    25,    26,    27,    28,    29,
       0,   280,   281,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    30,    31,    32,     0,     0,
       0,     0,     7,     0,     0,     0,     0,     0,     0,     0,
       0,    33,     0,   282,    35,    36,     0,     0,     0,     0,
       0,     0,     0,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,     0,
       0,     0,    37,     0,     0,     0,    38,    24,    25,    26,
      27,    28,    29,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    30,    31,
      32,     0,     0,     0,     7,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    33,    34,     0,    35,    36,     0,
       0,     0,     0,     0,     0,     8,     9,    10,    11,    12,
      13,    14,    15,    16,    17,    18,    19,    20,    21,    22,
      23,     0,     0,     0,     0,    37,     0,     0,     0,    38,
      25,    26,    27,    28,    29,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      30,    31,    32,     0,     0,     0,     7,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    33,   169,     0,    35,
      36,     0,     0,     0,     0,     0,     0,     8,     9,    10,
      11,    12,    13,    14,    15,    16,    17,    18,    19,    20,
      21,    22,    23,   222,     0,     0,     0,    37,     0,     0,
       0,    38,    25,    26,    27,    28,    29,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    30,    31,    32,     0,     0,     0,     7,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    33,     0,
       0,    35,    36,     0,     0,     0,     0,     0,     0,     8,
       9,    10,    11,    12,    13,    14,    15,    16,    17,    18,
      19,    20,    21,    22,    23,     0,     0,     0,     0,    37,
       0,     0,     0,    38,    25,    26,    27,    28,    29,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    30,    31,    32,     0,     0,     0,
       7,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      33,   250,     0,    35,    36,     0,     0,     0,     0,     0,
       0,     8,     9,    10,    11,    12,    13,    14,    15,    16,
      17,    18,    19,    20,    21,    22,    23,     0,     0,     0,
       0,    37,     0,     0,     0,    38,    25,    26,    27,    28,
      29,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    30,    31,    32,     7,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    33,     0,     0,    35,    36,     0,     0,     0,
       8,     9,    10,    11,    12,    13,    14,    15,   232,    17,
     233,    19,    20,    21,    22,    23,     0,     0,     0,     0,
       0,     0,     0,    37,     0,   234,     0,    38,    28,    29,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,   909,     0,     0,    30,    31,    32,     0,     0,
       0,    25,    26,    27,     0,     0,   910,     0,     0,     0,
       0,    33,     0,     0,    35,    36,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     7,     0,     0,   235,
       0,   617,     0,     0,     0,     0,     0,     0,     0,   618,
     619,   620,    37,   621,     0,     0,    38,     8,     9,    10,
      11,    12,    13,    14,    15,   232,    17,   233,    19,    20,
      21,    22,    23,     0,   911,     0,     0,     0,     0,     0,
       0,     0,   234,     0,     0,    28,    29,     0,     0,     0,
     622,     0,     0,   623,     0,     0,     0,     0,     0,     0,
       0,     0,    30,    31,    32,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    33,     0,
       0,    35,    36,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     7,     0,     0,  1096,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    37,
       0,     0,     0,    38,     8,     9,    10,    11,    12,    13,
      14,    15,   232,    17,   233,    19,    20,    21,    22,    23,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   234,
       0,     0,    28,    29,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    30,
      31,    32,     7,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    33,     0,     0,    35,    36,
       0,     0,     0,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,     0,
       0,     0,     0,     0,     0,     0,    37,     0,     0,     0,
      38,    28,    29,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    30,    31,
      32,     7,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    33,     0,     0,    35,    36,     0,
       0,     0,     8,     9,    10,    11,    12,    13,    14,    15,
     232,    17,   233,    19,    20,    21,    22,    23,     0,     0,
       0,     0,     0,     0,     0,    37,     0,   234,     0,    38,
       0,     0,     0,    62,     0,     0,     0,    63,    64,    65,
       0,     0,     0,     0,     0,     0,     0,    30,     0,     0,
       0,     0,    66,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    33,     0,     0,    35,    36,     0,     0,
       0,     0,   929,    68,     0,  -215,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     712,    70,    71,    72,    37,    74,    75,    76,    38,     0,
       0,   931,   932,   933,     0,    77,    78,    79,     0,    80,
      81,    82,    83,    84,    62,     0,     0,     0,    63,    64,
      65,    85,     0,     0,     0,    89,    90,    91,    92,    93,
      94,    95,     0,    66,     0,     0,     0,     0,   495,   496,
     497,   498,   499,    96,   500,     0,     0,     0,    97,     0,
       0,     0,     0,   929,    68,     0,  -213,     0,   501,   502,
     503,   504,   505,   506,   507,   508,   509,   510,   511,   512,
       0,   714,    70,    71,    72,     0,    74,    75,    76,     0,
       0,     0,   931,   932,   933,     0,    77,    78,    79,     0,
      80,    81,    82,    83,    84,     0,     0,     0,     0,     0,
       0,     0,    85,   848,     0,     0,    89,    90,    91,    92,
      93,    94,    95,     0,     0,     0,     0,     0,     0,   495,
     496,   497,   498,   499,    96,   500,     0,     0,     0,    97,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   501,
     502,   503,   504,   505,   506,   507,   508,   509,   510,   511,
     512,   495,   496,   497,   498,   499,     0,   500,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,   501,   502,   503,   504,   505,   506,   507,   508,   509,
     510,   511,   512
};

static const yytype_int16 yycheck[] =
{
       1,     2,   164,    31,    32,   147,     5,   378,    70,    97,
      34,   148,     5,   235,   157,   585,   159,    85,     5,   621,
      38,    45,   602,   566,   624,    91,    97,    97,     5,    91,
      92,   779,     5,     5,     1,     2,    34,    97,    39,   399,
     902,     5,   190,     5,   618,    46,   219,     5,   861,     3,
     138,   750,   566,     5,   575,   803,   749,     3,    59,   406,
      40,   575,     5,     1,     2,   934,   713,   138,     5,    54,
     243,    41,     6,    62,     3,     5,   138,    45,    54,  1035,
       3,     5,   224,     1,    43,  1202,    45,     4,    41,     5,
       5,   188,    43,    43,    54,   163,   193,     4,     3,     6,
       6,    39,   190,     3,     6,     7,   203,     5,    47,    42,
       5,    40,   180,   181,    42,  1232,   258,     5,   103,   190,
     190,    59,    40,   151,   152,    54,     5,    59,    45,    58,
     190,   228,   150,    86,    88,    89,    43,   126,    45,    42,
      40,   117,    88,    89,   112,   169,   147,   117,    48,   246,
       0,   131,   153,   112,    60,   179,   136,   117,    58,    88,
      89,     3,   116,   164,   117,  1121,   120,     3,   310,    41,
     171,   169,   196,   112,    40,    48,   104,   779,  1134,   125,
     103,   179,   136,    88,    89,   119,  1048,   116,    88,    89,
       3,   120,   125,   126,  1063,     3,  1152,   164,    40,   128,
     224,   803,   131,   204,   205,   565,     5,   136,   115,   147,
    1166,   140,     5,   860,   814,   120,   116,    43,   280,    45,
     120,   222,   125,   126,   175,    42,   164,    68,   588,   876,
     231,   259,   260,   376,   235,   259,   260,    54,     6,   263,
     140,   378,   889,   590,   195,   195,    88,    89,     0,    90,
      47,     4,    88,    89,    95,   103,   128,   258,    43,   131,
     631,  1074,   128,    71,   136,   131,   204,   205,   235,    40,
     136,  1043,   204,   205,   116,    88,    89,    45,   120,     3,
      88,    89,   425,    86,   222,    93,   112,   104,     6,    86,
     222,    43,    45,   231,   896,   897,   995,   235,   140,   231,
     993,  1215,   330,   331,    54,     3,   119,   120,   116,   310,
      40,  1124,   120,   143,   117,   112,   859,  1179,   103,     6,
     258,  1235,   346,   324,    86,   899,   327,    45,   352,     6,
     398,   332,   394,     0,   476,   397,   337,  1109,   859,  1111,
     987,   862,    40,    86,   406,   859,   412,   188,   862,    40,
     412,   192,   193,   103,   352,   117,    47,   358,    88,    89,
      58,  1223,   203,     0,    88,    89,    43,    54,     3,   116,
     321,    73,   310,     3,    34,     3,    41,    42,   219,    43,
     602,    45,   604,     3,    43,    45,   324,   228,   229,   327,
      88,    89,   324,   555,  1142,   327,   120,    43,    54,    45,
     351,   242,   243,   118,   121,   246,    86,   109,   432,   433,
     434,    75,    40,     3,   255,    45,    75,    40,   116,    75,
     358,   112,   120,   783,   597,    89,   358,    86,   143,    75,
     128,    40,     3,   131,    54,   463,   464,   117,   136,     3,
      75,   442,   140,   585,   472,   473,     3,   448,     4,   196,
       6,   452,   453,    88,    89,   118,  1030,   103,    88,    89,
      88,    89,    49,    50,    51,    40,   608,   341,    88,    89,
     118,   568,    40,    52,    53,   476,    40,   224,   575,    52,
     143,   116,   356,    58,   485,   120,   116,   147,   116,    45,
     120,    70,   120,   636,   631,   143,   116,    70,    88,    89,
     120,  1075,    54,   250,   442,   252,     6,     7,   136,   169,
     442,   653,   140,    40,   452,    40,  1096,    88,    89,   179,
     452,   522,    40,    75,    88,    89,   527,    91,   590,   119,
     120,    88,    89,    58,   552,    40,     4,     1,     6,   910,
    1142,   128,   105,   106,   131,   116,    43,   485,    45,   120,
      40,    41,   116,   485,   555,    40,   120,    54,   559,   116,
     561,   585,    40,   120,   224,     6,    43,     3,    58,   570,
      48,  1141,    49,    50,    51,    43,   577,    45,    42,    43,
      58,    45,   128,   243,   522,   131,    54,   586,   555,   527,
     522,    40,   593,   586,   545,   527,  1196,   598,   258,   586,
     551,   602,   589,   604,    40,   606,  1100,   608,    40,   586,
     577,    40,    48,   586,   586,    43,    45,   555,    40,    41,
      48,   559,   586,   561,   586,    40,    58,   559,   586,   561,
      45,   598,   570,   103,   586,   602,    58,   604,   570,   577,
      40,   642,   784,   586,     4,   646,     6,   117,   118,   586,
     310,   128,    88,    89,   131,   593,   586,   658,   806,    40,
     598,   593,   586,    40,   602,    40,   604,    40,   606,  1163,
     586,   586,    40,   143,   606,   626,   128,    58,   815,   131,
     116,  1175,   632,    58,   120,    58,   346,    40,   586,  1183,
      58,   586,   352,    40,  1188,    40,    43,   759,   586,    40,
      41,     4,   653,     6,   140,    54,   707,   586,    40,    41,
     711,   458,   713,     3,    43,   375,    45,    58,   806,   881,
     117,   562,    40,    41,    86,   566,    58,   568,    41,   476,
      52,    53,   733,   574,   575,   734,   806,    88,    89,  1003,
      58,   734,  1006,    43,    79,    45,   806,   734,    70,    71,
      40,   752,    87,    88,    89,    48,   597,   734,   599,   758,
     761,   734,   734,    43,    43,   758,   863,   121,   609,    48,
     734,   758,   734,   910,    45,    54,   734,    43,   438,    45,
       6,   758,   734,    45,   785,   758,   758,   586,   789,    43,
      42,   734,   452,   586,   758,   733,   758,   734,    88,    89,
     758,   733,   117,   278,   734,   280,   758,   873,    86,  1180,
     734,   873,    41,   814,   885,   758,   476,   477,   734,   734,
     813,   758,   970,   761,    41,    40,   116,    40,   758,   761,
     120,   578,    40,   784,   758,    40,   734,    58,   585,   734,
      40,   117,   758,   758,   104,    42,   734,   990,     0,   911,
     140,   789,   122,   123,   124,   734,  1227,   789,    42,   860,
     758,   608,   609,   758,    41,   866,    54,    41,  1011,    42,
     758,    49,    50,    51,  1096,   876,    41,    41,   966,   758,
     881,    42,   970,   884,   835,   835,    54,     3,   889,   888,
       6,   890,  1035,    42,    41,   966,   966,   890,     1,     2,
     970,   888,    43,   890,   966,    43,   653,    41,   909,   750,
     970,   904,  1049,   890,   881,   888,   888,   890,   890,   760,
     136,   137,   138,    41,    40,   585,   890,  1015,   890,    41,
      41,    34,   890,    41,   103,   734,    39,    40,   890,    40,
      43,   734,    45,   881,  1015,  1015,   884,   890,   608,    52,
    1093,   104,   884,   890,  1025,  1015,    59,    42,   117,   758,
     890,    41,  1212,  1025,    43,   758,   890,    70,  1218,  1219,
    1220,   909,    88,    89,   890,   890,    75,   909,  1121,    45,
     117,  1231,    85,    86,    41,   117,   987,    45,    91,    92,
      43,  1134,   890,   653,    97,   890,    49,    50,    51,  1141,
     116,  1069,   890,   750,   120,   103,  1068,    40,     3,  1152,
      23,   890,   128,   116,     3,   131,     3,     3,   859,    41,
     136,   862,   863,  1166,   140,    41,    40,  1055,    72,    73,
      74,    44,  1094,    48,    43,   138,    43,   784,   134,   135,
     136,   137,   138,  1180,   147,    45,  1039,    41,   151,   152,
    1043,   154,  1053,    45,    91,    43,    46,    40,   161,    43,
      41,   164,   448,    76,    77,    78,   169,   453,    81,    43,
      83,    84,    40,    91,    41,   128,   179,    90,   131,    89,
      88,    77,     3,  1084,    75,     6,    41,   190,   111,    41,
    1227,   890,   195,   196,    41,  1096,    41,   890,    41,    48,
    1101,   204,   205,    54,   207,   208,   119,  1108,    41,   132,
     133,   134,   135,   136,   137,   138,  1109,  1141,  1111,   222,
      54,   224,    42,   870,   784,    43,  1127,    41,   231,  1096,
    1131,   234,   235,   236,   237,    41,  1164,   240,   143,   103,
     243,   244,   245,    23,    46,   248,    40,   250,   251,   252,
     253,   104,  1214,    92,   995,   258,   259,   260,  1096,    41,
     263,   127,    43,  1101,    44,   128,  1167,    88,    89,  1101,
    1171,   918,  1013,   103,    43,    62,    42,    45,    41,     3,
    1181,    41,     6,    41,   105,   106,    41,    41,    41,  1190,
    1191,  1192,    41,  1131,    41,  1196,    76,    77,    78,  1131,
      41,    81,    41,    83,    84,    43,  1207,   310,   311,   312,
    1211,  1212,    43,    41,   317,   126,    46,  1218,  1219,  1220,
      54,   324,    43,    75,   327,    45,   329,   330,   331,  1167,
    1231,    75,    75,  1171,   337,  1167,    46,    46,    75,  1171,
       3,    43,    43,   346,    41,   104,    54,   994,    43,   352,
      54,    42,  1190,  1191,  1192,   358,   642,    41,  1190,  1191,
    1192,     3,   365,   366,    88,    89,    43,    43,    75,    75,
      75,    43,   375,  1211,    43,     3,    75,    40,    43,  1211,
     383,   105,   106,    43,    70,    48,    49,    50,    51,    43,
      54,   394,   116,    42,   397,  1042,   120,   400,    40,    40,
      86,    48,    46,   406,   128,    43,    48,   131,   104,   412,
      41,    46,   136,    40,    40,  1062,    58,   132,   133,   134,
     135,   136,   137,   138,  1071,    88,    89,    41,    43,   432,
     433,   434,    43,    43,    41,   438,   439,   440,    40,   442,
     443,   444,   445,    48,   447,    41,    88,    89,    41,   452,
    1097,    41,    41,   116,    41,   458,   888,   120,    43,    45,
      88,    89,   465,  1174,   888,   128,   752,   604,   131,   888,
     956,   888,   139,   476,   116,    39,   555,   140,   120,   881,
     151,   152,   485,   626,    50,  1039,   128,  1038,   116,   131,
     161,   904,   120,   896,  1141,   641,   897,  1075,   140,   785,
     128,   922,   188,   131,  1056,   711,   192,   193,   136,  1196,
    1159,     3,     4,   163,     6,   201,   202,   203,   760,   522,
     523,    -1,    -1,    -1,   527,    -1,    -1,  1174,   814,    -1,
     216,    -1,    -1,   219,   537,    -1,    -1,    -1,   541,    -1,
      -1,    -1,   228,   546,   547,    -1,   549,    -1,    40,    -1,
      -1,    43,   555,    45,    -1,    -1,   559,   243,   561,    -1,
     246,    -1,    -1,    -1,    -1,   251,    -1,   570,  1128,    -1,
      -1,  1131,    -1,    -1,   577,   578,    -1,    -1,    -1,    -1,
     866,  1141,   585,    -1,    -1,    -1,    -1,   590,   259,   260,
     593,    -1,   263,    -1,   149,   598,    88,    89,    -1,   602,
       3,   604,    -1,   606,    -1,   608,   609,   610,    -1,   164,
      -1,   614,   615,   616,    -1,    -1,    -1,    -1,   621,    -1,
      -1,    -1,    -1,   115,   116,    -1,    -1,    -1,   120,   632,
      -1,    -1,    -1,    -1,    -1,    -1,   128,    40,    -1,   131,
      -1,    -1,     3,    -1,   136,    48,    -1,    -1,   140,    -1,
     653,    -1,   338,    -1,    -1,    58,    -1,    -1,    -1,   330,
     331,    -1,    -1,    24,    25,    26,    27,    28,    29,    30,
      31,    32,    33,    34,    35,    36,    37,    38,    39,    -1,
      -1,    -1,    -1,    -1,    -1,    88,    89,    -1,    49,    50,
      51,    52,    53,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   257,    -1,   707,    -1,    -1,    -1,    69,    70,
      71,    -1,    -1,   116,   717,    -1,   719,   120,    -1,    -1,
     723,   724,    -1,   278,    85,    86,     3,    88,    89,     3,
     733,   286,   287,   288,   289,   290,   291,   140,    -1,    -1,
     152,    -1,    -1,     3,    -1,    -1,    -1,   750,    -1,   161,
      -1,    -1,    -1,    -1,    -1,   116,   759,    -1,   761,   120,
     121,    -1,    -1,    40,    -1,    -1,    40,  1053,    -1,    -1,
     325,    48,    -1,   328,    48,    -1,   779,    -1,    -1,   140,
      40,   784,    -1,    -1,   787,    -1,   789,    -1,    48,    -1,
      -1,    -1,   463,   464,   465,    -1,    -1,    -1,  1084,    -1,
     803,   472,   473,   806,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    88,    89,    -1,    88,    89,    -1,    -1,    -1,    -1,
      -1,    -1,  1108,    -1,    -1,    -1,    -1,    -1,    88,    89,
      -1,    -1,   835,   245,    -1,    -1,   248,    -1,    -1,   116,
      -1,  1127,   116,   120,    -1,    -1,   120,    -1,    -1,   852,
     853,   128,   523,    -1,   131,    -1,   116,    -1,    -1,   136,
     120,    -1,    -1,   140,    -1,    -1,   140,   870,   128,    -1,
     873,   131,    -1,    -1,    -1,   546,     3,    -1,   881,     3,
     140,   884,   568,    -1,   887,    -1,    -1,    -1,    -1,   575,
      -1,    -1,    -1,   896,   897,  1181,    -1,    -1,    -1,   311,
      -1,    -1,    -1,    -1,    -1,   317,   909,    -1,   911,   595,
    1196,   597,    -1,    40,    -1,   918,    40,   329,   330,   331,
      -1,    48,    -1,   926,    48,   337,    -1,    54,    -1,     3,
      -1,    58,     3,    -1,    58,    -1,    -1,    -1,    -1,     3,
     495,   496,   497,   498,   499,   500,   501,   502,   503,   504,
     505,   506,   507,   508,   509,   510,   511,   512,     3,    -1,
      -1,    88,    89,   966,    88,    89,    40,   970,    42,    40,
      -1,    -1,    -1,   528,    48,   661,    40,    48,    -1,   650,
      54,    -1,    -1,    -1,    58,    49,    50,    51,    -1,   116,
      -1,   994,   116,   120,    58,    40,   120,    -1,    -1,     3,
     555,   128,    -1,    48,   131,    -1,    -1,    -1,  1011,   136,
      -1,  1014,  1015,   140,    88,    89,   140,    88,    89,    -1,
      -1,    -1,  1025,    -1,    88,    89,    -1,   439,   440,    -1,
     104,   443,   444,   445,    -1,   447,    40,     3,    -1,  1042,
      -1,    -1,   116,    88,    89,   116,   120,  1050,    -1,   120,
      -1,    -1,   116,    -1,   128,    -1,   120,   131,    -1,  1062,
      -1,    -1,   136,    -1,   128,  1068,   140,   131,  1071,   140,
      -1,   116,   136,   759,    40,   120,   140,    -1,    -1,    -1,
      -1,    -1,    48,   128,    88,    89,   131,    -1,    -1,    -1,
      -1,  1094,    58,  1096,  1097,   140,     3,    -1,  1101,   654,
     655,   656,   657,   658,    -1,   660,    -1,    -1,    -1,    -1,
      -1,   523,   116,    -1,    -1,     3,   120,    -1,    -1,    -1,
    1123,     3,    88,    89,   128,   537,    -1,   131,  1131,   541,
      -1,    -1,   136,    40,   546,   547,   140,   549,  1141,  1142,
      -1,    48,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     116,    58,    40,    -1,   120,    43,  1159,    -1,    40,     3,
      -1,    -1,   128,    -1,  1167,   131,    48,    -1,  1171,    -1,
     136,  1174,    -1,    -1,   140,    -1,    58,   863,    -1,    -1,
      -1,    88,    89,    -1,    -1,     3,    -1,  1190,  1191,  1192,
      -1,   877,   878,   879,    -1,    -1,    40,    -1,   610,    43,
      88,    89,   614,   615,   616,    -1,    88,    89,  1211,   116,
      -1,  1214,    -1,   120,    -1,    -1,    -1,    -1,    -1,    -1,
     906,   128,    40,    -1,   131,    43,    -1,    -1,   116,   136,
      -1,    -1,   120,   140,   116,   790,    -1,    -1,   120,    -1,
     128,    -1,    -1,   131,    88,    89,   128,    -1,   136,   131,
      -1,    -1,   140,    -1,   136,    -1,    -1,    -1,   140,    -1,
      -1,   816,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      88,    89,   116,    -1,    -1,    -1,   120,    -1,   833,   834,
      -1,   836,    -1,    -1,   128,    -1,    -1,   131,   843,    -1,
      -1,     3,   136,    -1,    -1,   707,   140,    -1,   116,    -1,
      -1,    -1,   120,    -1,    -1,   717,    -1,   719,    -1,    -1,
     128,   723,   724,   131,    -1,    -1,    -1,    -1,   136,    -1,
      -1,    -1,   140,    -1,    -1,    -1,   881,    -1,    40,    -1,
       1,    -1,     3,    -1,    -1,     6,     7,    49,    50,    51,
      11,    12,    13,    14,    15,    16,    17,    18,    19,    20,
      21,    22,  1038,    24,    25,    26,    27,    28,    29,    30,
      31,    32,    33,    34,    35,    36,    37,    38,    39,    40,
      -1,    49,    50,    51,    -1,   787,    88,    89,    49,    50,
      51,    52,    53,    -1,    55,    56,    -1,    58,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    69,    70,
      71,    79,    -1,    -1,   116,    -1,    -1,    -1,   120,    87,
      88,    89,    -1,    91,    85,    -1,    87,    88,    89,    -1,
      91,    -1,    -1,   978,   979,    -1,    -1,    -1,   140,    -1,
      -1,    -1,    -1,    -1,   105,   106,    -1,    -1,    -1,    -1,
     852,   853,    -1,    -1,    -1,   116,    -1,    -1,    -1,   120,
     128,    -1,    -1,   131,    -1,    -1,    -1,    -1,    -1,    -1,
     131,    -1,    -1,   134,   135,   136,     1,    -1,     3,   140,
     141,     6,     7,    -1,     3,    -1,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    -1,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    38,    39,    40,    -1,    49,    50,    51,
      45,    40,    -1,    -1,    49,    50,    51,    52,    53,    48,
      55,    56,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    58,
      -1,    -1,    -1,    -1,    69,    70,    71,    79,   107,   108,
     109,   110,   111,    -1,    -1,    87,    88,    89,    -1,    -1,
      85,  1106,    87,    88,    89,    -1,    91,    -1,    -1,    88,
      89,     3,   131,   132,   133,   134,   135,   136,   137,   138,
     105,   106,    -1,    -1,    -1,  1130,    -1,    -1,    -1,    -1,
      -1,   116,    -1,    -1,    -1,   120,   128,   116,    -1,   131,
      -1,   120,    -1,    -1,    -1,    -1,   131,    -1,    40,   134,
     135,   136,     1,    -1,     3,   140,   141,     6,     7,    -1,
      -1,   140,    11,    12,    13,    14,    15,    16,    17,    18,
      19,    20,    21,    22,    -1,    24,    25,    26,    27,    28,
      29,    30,    31,    32,    33,    34,    35,    36,    37,    38,
      39,    40,    -1,    -1,    -1,    -1,    88,    89,    -1,    -1,
      49,    50,    51,    52,    53,    -1,    55,    56,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      69,    70,    71,    -1,   116,    -1,    -1,    -1,   120,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    85,    -1,    87,    88,
      89,    -1,    91,    -1,   136,    -1,    -1,    -1,   140,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   105,   106,    -1,    -1,
       3,    -1,     3,    -1,    -1,     6,    -1,   116,    -1,    -1,
      -1,   120,    13,    14,    15,    16,    17,    18,    19,    20,
      21,    22,   131,    -1,    -1,   134,   135,   136,     1,    -1,
       3,   140,   141,     6,     7,    -1,    -1,    40,    11,    12,
      13,    14,    15,    16,    17,    18,    19,    20,    21,    22,
      -1,    24,    25,    26,    27,    28,    29,    30,    31,    32,
      33,    34,    35,    36,    37,    38,    39,    40,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    49,    50,    51,    52,
      53,    -1,    55,    56,    -1,    88,    89,    88,    89,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    69,    70,    71,    -1,
      -1,    -1,    -1,    -1,   105,   106,    -1,    -1,    -1,     3,
      -1,    -1,    85,   116,    87,    88,    89,   120,    91,    -1,
      -1,    -1,    -1,    -1,    -1,   128,    -1,    -1,   131,    -1,
      -1,    -1,    -1,   136,    -1,    -1,    -1,   140,    -1,    -1,
      -1,    -1,    -1,   116,    -1,    -1,    40,   120,     1,    -1,
       3,     4,    -1,    -1,    48,     8,     9,    10,   131,    -1,
      -1,   134,   135,   136,    58,    -1,    -1,   140,   141,    -1,
      23,    24,    25,    26,    27,    28,    29,    30,    31,    32,
      33,    34,    35,    36,    37,    38,    39,    -1,    -1,    -1,
      43,    44,    -1,    46,    88,    89,    49,    50,    51,    52,
      53,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    62,
      63,    64,    65,    66,    67,    68,    69,    70,    71,    72,
      73,    74,   116,    76,    77,    78,   120,    80,    81,    82,
      83,    84,    85,    86,   128,    88,    89,   131,    -1,    92,
      -1,    -1,   136,    96,    97,    98,    99,   100,   101,   102,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   114,    -1,   116,    -1,    -1,   119,   120,   121,    -1,
      -1,    -1,   125,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
       3,    -1,    -1,     6,     7,    -1,     3,   140,    11,    12,
      13,    14,    15,    16,    17,    18,    19,    20,    21,    22,
      -1,    24,    25,    26,    27,    28,    29,    30,    31,    32,
      33,    34,    35,    36,    37,    38,    39,    40,    -1,    -1,
      -1,    -1,    45,    40,    -1,    -1,    49,    50,    51,    52,
      53,    48,    55,    56,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    58,    -1,    -1,    -1,    -1,    69,    70,    71,    -1,
     107,   108,   109,   110,   111,    -1,    -1,    -1,    -1,   107,
     108,    -1,    85,   111,    87,    88,    89,    -1,    91,    -1,
      -1,    88,    89,   130,   131,   132,   133,   134,   135,   136,
     137,   138,   105,   106,   132,   133,   134,   135,   136,   137,
     138,    -1,    -1,   116,    -1,    -1,    -1,   120,    -1,   116,
      -1,    -1,    -1,   120,    -1,    -1,    -1,    -1,   131,    -1,
      -1,   134,   135,   136,    -1,    -1,     3,   140,   141,     6,
       7,    -1,     3,   140,    11,    12,    13,    14,    15,    16,
      17,    18,    19,    20,    21,    22,    -1,    24,    25,    26,
      27,    28,    29,    30,    31,    32,    33,    34,    35,    36,
      37,    38,    39,    40,    -1,    -1,    -1,    75,    -1,    40,
      -1,    48,    49,    50,    51,    52,    53,    48,    55,    56,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    69,    70,    71,    -1,    -1,    -1,    -1,   107,
     108,   109,   110,   111,    -1,   113,    -1,    -1,    85,    86,
      87,    88,    89,    -1,    91,    -1,    -1,    88,    89,   127,
     128,   129,   130,   131,   132,   133,   134,   135,   136,   137,
     138,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   116,
      -1,    -1,    -1,   120,    -1,   116,    -1,    -1,   125,   120,
      -1,    -1,    -1,    -1,   131,    -1,    -1,   134,   135,   136,
      -1,    -1,     3,   140,   141,     6,     7,    43,    -1,   140,
      11,    12,    13,    14,    15,    16,    17,    18,    19,    20,
      21,    22,    -1,    24,    25,    26,    27,    28,    29,    30,
      31,    32,    33,    34,    35,    36,    37,    38,    39,    40,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    49,    50,
      51,    52,    53,    -1,    55,    56,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    69,    70,
      71,   107,   108,   109,   110,   111,    -1,   113,    -1,    -1,
      -1,    -1,    -1,    -1,    85,    -1,    87,    88,    89,    -1,
      91,   127,   128,   129,   130,   131,   132,   133,   134,   135,
     136,   137,   138,    -1,   105,   106,    -1,    -1,     3,    -1,
      -1,    -1,    -1,     6,    -1,   116,    -1,    -1,    -1,   120,
      13,    14,    15,    16,    17,    18,    19,    20,    21,    22,
     131,    -1,    -1,   134,   135,   136,    -1,    -1,     3,   140,
     141,     6,     7,    -1,    -1,    40,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    -1,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    38,    39,    40,    41,    -1,    -1,    -1,
      -1,    -1,    -1,    48,    49,    50,    51,    52,    53,    -1,
      55,    56,    -1,    88,    89,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    69,    70,    71,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      85,   116,    87,    88,    89,   120,    91,    -1,    -1,    -1,
      -1,    -1,    -1,   128,    -1,    -1,   131,    -1,    -1,    -1,
      -1,   136,    -1,    -1,     3,   140,    -1,    -1,    -1,    -1,
      -1,   116,    -1,    -1,    -1,   120,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   131,    -1,    -1,   134,
     135,   136,    -1,    -1,     3,   140,   141,     6,     7,    -1,
       3,    40,    11,    12,    13,    14,    15,    16,    17,    18,
      19,    20,    21,    22,    -1,    24,    25,    26,    27,    28,
      29,    30,    31,    32,    33,    34,    35,    36,    37,    38,
      39,    40,    41,    -1,    -1,    -1,    -1,    40,    -1,    48,
      49,    50,    51,    52,    53,    48,    55,    56,    -1,    88,
      89,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      69,    70,    71,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    85,   116,    87,    88,
      89,   120,    91,    -1,    -1,    88,    89,    -1,    -1,   128,
      -1,    -1,   131,    -1,    -1,    -1,    -1,   136,    -1,    -1,
      -1,   140,    -1,    -1,    -1,    -1,    -1,   116,    -1,    -1,
      -1,   120,    -1,   116,    -1,    -1,    -1,   120,    -1,    -1,
      -1,    -1,   131,    -1,    -1,   134,   135,   136,    -1,    -1,
       3,   140,   141,     6,     7,    -1,     3,   140,    11,    12,
      13,    14,    15,    16,    17,    18,    19,    20,    21,    22,
      -1,    24,    25,    26,    27,    28,    29,    30,    31,    32,
      33,    34,    35,    36,    37,    38,    39,    40,    -1,    -1,
      -1,    -1,    -1,    40,    -1,    -1,    49,    50,    51,    52,
      53,    48,    55,    56,    -1,    -1,    59,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    69,    70,    71,    -1,
      -1,    -1,    -1,   107,   108,   109,   110,   111,    -1,   113,
      -1,    -1,    85,    -1,    87,    88,    89,    -1,    91,    -1,
      -1,    88,    89,   127,   128,   129,   130,   131,   132,   133,
     134,   135,   136,   137,   138,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   116,    -1,    -1,    -1,   120,    -1,   116,
      -1,    -1,    -1,   120,    -1,    -1,    -1,    -1,   131,    -1,
      -1,   134,   135,   136,    -1,    -1,     3,   140,   141,     6,
       7,    -1,    41,   140,    11,    12,    13,    14,    15,    16,
      17,    18,    19,    20,    21,    22,    -1,    24,    25,    26,
      27,    28,    29,    30,    31,    32,    33,    34,    35,    36,
      37,    38,    39,    40,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    49,    50,    51,    52,    53,    -1,    55,    56,
      -1,    -1,    59,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    69,    70,    71,   104,    -1,    -1,   107,   108,
     109,   110,   111,    -1,   113,    -1,    -1,    -1,    85,    -1,
      87,    88,    89,    -1,    91,    -1,    -1,    -1,   127,   128,
     129,   130,   131,   132,   133,   134,   135,   136,   137,   138,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   116,
      -1,    -1,    -1,   120,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   131,    -1,    -1,   134,   135,   136,
      -1,    -1,     3,   140,   141,     6,     7,    41,    -1,    -1,
      11,    12,    13,    14,    15,    16,    17,    18,    19,    20,
      21,    22,    -1,    24,    25,    26,    27,    28,    29,    30,
      31,    32,    33,    34,    35,    36,    37,    38,    39,    40,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    49,    50,
      51,    52,    53,    -1,    55,    56,    -1,    -1,    59,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    69,    70,
      71,    -1,    -1,   107,   108,   109,   110,   111,    -1,   113,
      -1,    -1,    -1,    -1,    85,    -1,    87,    88,    89,    -1,
      91,    -1,    -1,   127,   128,   129,   130,   131,   132,   133,
     134,   135,   136,   137,   138,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   116,    -1,    -1,    -1,   120,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     131,    -1,    -1,   134,   135,   136,    -1,    -1,     3,   140,
     141,     6,     7,    41,    -1,    -1,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    -1,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    38,    39,    40,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    48,    49,    50,    51,    52,    53,    -1,
      55,    56,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    69,    70,    71,    -1,    -1,   107,
     108,   109,   110,   111,    -1,   113,    -1,    -1,    -1,    -1,
      85,    -1,    87,    88,    89,    -1,    91,    -1,    -1,   127,
     128,   129,   130,   131,   132,   133,   134,   135,   136,   137,
     138,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   116,    -1,    -1,    -1,   120,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   131,    -1,    -1,   134,
     135,   136,    -1,    -1,     3,   140,   141,     6,     7,    41,
      -1,    -1,    11,    12,    13,    14,    15,    16,    17,    18,
      19,    20,    21,    22,    -1,    24,    25,    26,    27,    28,
      29,    30,    31,    32,    33,    34,    35,    36,    37,    38,
      39,    40,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    48,
      49,    50,    51,    52,    53,    -1,    55,    56,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      69,    70,    71,    -1,    -1,   107,   108,   109,   110,   111,
      -1,   113,    -1,    -1,    -1,    -1,    85,    -1,    87,    88,
      89,    -1,    91,    -1,    -1,   127,   128,   129,   130,   131,
     132,   133,   134,   135,   136,   137,   138,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   116,    -1,    -1,
      -1,   120,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   131,    -1,    -1,   134,   135,   136,    -1,    -1,
       3,   140,   141,     6,     7,    41,    -1,    -1,    11,    12,
      13,    14,    15,    16,    17,    18,    19,    20,    21,    22,
      -1,    24,    25,    26,    27,    28,    29,    30,    31,    32,
      33,    34,    35,    36,    37,    38,    39,    40,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    48,    49,    50,    51,    52,
      53,    -1,    55,    56,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    69,    70,    71,    -1,
      -1,   107,   108,   109,   110,   111,    -1,   113,    -1,    -1,
      -1,    -1,    85,    -1,    87,    88,    89,    -1,    91,    -1,
      -1,   127,   128,   129,   130,   131,   132,   133,   134,   135,
     136,   137,   138,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   116,    -1,    -1,    -1,   120,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   131,    -1,
      -1,   134,   135,   136,    -1,    -1,     3,   140,   141,     6,
       7,    -1,    -1,    -1,    11,    12,    13,    14,    15,    16,
      17,    18,    19,    20,    21,    22,    -1,    24,    25,    26,
      27,    28,    29,    30,    31,    32,    33,    34,    35,    36,
      37,    38,    39,    40,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    48,    49,    50,    51,    52,    53,    -1,    55,    56,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    69,    70,    71,   107,   108,   109,   110,   111,
      -1,    -1,   107,   108,   109,   110,   111,    -1,    85,    -1,
      87,    88,    89,    -1,    91,   127,   128,   129,   130,   131,
     132,   133,   134,   135,   136,   137,   138,   132,   133,   134,
     135,   136,   137,   138,    -1,    -1,    -1,    -1,    -1,   116,
      -1,    -1,    -1,   120,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   131,    -1,    -1,   134,   135,   136,
      -1,    -1,     3,   140,   141,     6,     7,    -1,    -1,    -1,
      11,    12,    13,    14,    15,    16,    17,    18,    19,    20,
      21,    22,    -1,    24,    25,    26,    27,    28,    29,    30,
      31,    32,    33,    34,    35,    36,    37,    38,    39,    40,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    48,    49,    50,
      51,    52,    53,    -1,    55,    56,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    69,    70,
      71,   107,   108,   109,   110,   111,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    85,    -1,    87,    88,    89,    -1,
      91,    -1,   128,   129,   130,   131,   132,   133,   134,   135,
     136,   137,   138,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   116,    -1,    -1,    -1,   120,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     131,    -1,    -1,   134,   135,   136,    -1,    -1,     3,   140,
     141,     6,     7,    -1,    -1,    -1,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    -1,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    38,    39,    40,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    48,    49,    50,    51,    52,    53,    -1,
      55,    56,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    69,    70,    71,   107,   108,   109,
     110,   111,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      85,    -1,    87,    88,    89,    -1,    91,    -1,    -1,   129,
     130,   131,   132,   133,   134,   135,   136,   137,   138,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   116,    -1,    -1,    -1,   120,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   131,    -1,    -1,   134,
     135,   136,    -1,    -1,     3,   140,   141,     6,     7,    -1,
      -1,    -1,    11,    12,    13,    14,    15,    16,    17,    18,
      19,    20,    21,    22,    -1,    24,    25,    26,    27,    28,
      29,    30,    31,    32,    33,    34,    35,    36,    37,    38,
      39,    40,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    48,
      49,    50,    51,    52,    53,    -1,    55,    56,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      69,    70,    71,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    85,    -1,    87,    88,
      89,    -1,    91,    24,    25,    26,    27,    28,    29,    30,
      31,    -1,    33,    -1,    35,    36,    37,    38,    39,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   116,    -1,    -1,
      -1,   120,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   131,    -1,    -1,   134,   135,   136,    -1,    -1,
       3,   140,   141,     6,     7,    -1,    -1,    -1,    11,    12,
      13,    14,    15,    16,    17,    18,    19,    20,    21,    22,
      -1,    24,    25,    26,    27,    28,    29,    30,    31,    32,
      33,    34,    35,    36,    37,    38,    39,    40,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    48,    49,    50,    51,    52,
      53,    -1,    55,    56,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    69,    70,    71,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    85,    -1,    87,    88,    89,    -1,    91,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   116,    -1,    -1,    -1,   120,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   131,    -1,
      -1,   134,   135,   136,    -1,    -1,     3,   140,   141,     6,
       7,    -1,    -1,    -1,    11,    12,    13,    14,    15,    16,
      17,    18,    19,    20,    21,    22,    -1,    24,    25,    26,
      27,    28,    29,    30,    31,    32,    33,    34,    35,    36,
      37,    38,    39,    40,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    48,    49,    50,    51,    52,    53,    -1,    55,    56,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    69,    70,    71,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    85,    -1,
      87,    88,    89,    -1,    91,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   116,
      -1,    -1,    -1,   120,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   131,    -1,    -1,   134,   135,   136,
      -1,    -1,     3,   140,   141,     6,     7,    -1,    -1,    -1,
      11,    12,    13,    14,    15,    16,    17,    18,    19,    20,
      21,    22,    -1,    24,    25,    26,    27,    28,    29,    30,
      31,    32,    33,    34,    35,    36,    37,    38,    39,    40,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    48,    49,    50,
      51,    52,    53,    -1,    55,    56,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    69,    70,
      71,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    85,    -1,    87,    88,    89,    -1,
      91,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   116,    -1,    -1,    -1,   120,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     131,    -1,    -1,   134,   135,   136,    -1,    -1,     3,   140,
     141,     6,     7,    -1,    -1,    -1,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    -1,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    38,    39,    40,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    48,    49,    50,    51,    52,    53,    -1,
      55,    56,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    69,    70,    71,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      85,    -1,    87,    88,    89,    -1,    91,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   116,    -1,    -1,    -1,   120,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   131,    -1,    -1,   134,
     135,   136,    -1,    -1,     3,   140,   141,     6,     7,    -1,
      -1,    -1,    11,    12,    13,    14,    15,    16,    17,    18,
      19,    20,    21,    22,    -1,    24,    25,    26,    27,    28,
      29,    30,    31,    32,    33,    34,    35,    36,    37,    38,
      39,    40,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    48,
      49,    50,    51,    52,    53,    -1,    55,    56,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      69,    70,    71,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    85,    -1,    87,    88,
      89,    -1,    91,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   116,    -1,    -1,
      -1,   120,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   131,    -1,    -1,   134,   135,   136,    -1,    -1,
       3,   140,   141,     6,     7,    -1,    -1,    -1,    11,    12,
      13,    14,    15,    16,    17,    18,    19,    20,    21,    22,
      -1,    24,    25,    26,    27,    28,    29,    30,    31,    32,
      33,    34,    35,    36,    37,    38,    39,    40,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    48,    49,    50,    51,    52,
      53,    -1,    55,    56,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    69,    70,    71,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    85,    -1,    87,    88,    89,    -1,    91,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   116,    -1,    -1,    -1,   120,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   131,    -1,
      -1,   134,   135,   136,    -1,    -1,     3,   140,   141,     6,
       7,    -1,    -1,    -1,    11,    12,    13,    14,    15,    16,
      17,    18,    19,    20,    21,    22,    -1,    24,    25,    26,
      27,    28,    29,    30,    31,    32,    33,    34,    35,    36,
      37,    38,    39,    40,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    48,    49,    50,    51,    52,    53,    -1,    55,    56,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    69,    70,    71,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    85,    -1,
      87,    88,    89,    -1,    91,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   116,
      -1,    -1,    -1,   120,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   131,    -1,    -1,   134,   135,   136,
      -1,    -1,     3,   140,   141,     6,     7,    -1,    -1,    -1,
      11,    12,    13,    14,    15,    16,    17,    18,    19,    20,
      21,    22,    -1,    24,    25,    26,    27,    28,    29,    30,
      31,    32,    33,    34,    35,    36,    37,    38,    39,    40,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    48,    49,    50,
      51,    52,    53,    -1,    55,    56,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    69,    70,
      71,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    85,    -1,    87,    88,    89,    -1,
      91,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   116,    -1,    -1,    -1,   120,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     131,    -1,    -1,   134,   135,   136,    -1,    -1,     3,   140,
     141,     6,     7,    -1,    -1,    -1,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    -1,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    38,    39,    40,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    48,    49,    50,    51,    52,    53,    -1,
      55,    56,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    69,    70,    71,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      85,    -1,    87,    88,    89,    -1,    91,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   116,    -1,    -1,    -1,   120,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   131,    -1,    -1,   134,
     135,   136,    -1,    -1,     3,   140,   141,     6,     7,    -1,
      -1,    -1,    11,    12,    13,    14,    15,    16,    17,    18,
      19,    20,    21,    22,    -1,    24,    25,    26,    27,    28,
      29,    30,    31,    32,    33,    34,    35,    36,    37,    38,
      39,    40,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      49,    50,    51,    52,    53,    -1,    55,    56,    -1,    -1,
      59,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      69,    70,    71,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    85,    -1,    87,    88,
      89,    -1,    91,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   116,    -1,    -1,
      -1,   120,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   131,    -1,    -1,   134,   135,   136,    -1,    -1,
       3,   140,   141,     6,     7,    -1,    -1,    -1,    11,    12,
      13,    14,    15,    16,    17,    18,    19,    20,    21,    22,
      -1,    24,    25,    26,    27,    28,    29,    30,    31,    32,
      33,    34,    35,    36,    37,    38,    39,    40,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    48,    49,    50,    51,    52,
      53,    -1,    55,    56,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    69,    70,    71,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    85,    -1,    87,    88,    89,    -1,    91,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   116,    -1,    -1,    -1,   120,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   131,    -1,
      -1,   134,   135,   136,    -1,    -1,     3,   140,   141,     6,
       7,    -1,    -1,    -1,    11,    12,    13,    14,    15,    16,
      17,    18,    19,    20,    21,    22,    -1,    24,    25,    26,
      27,    28,    29,    30,    31,    32,    33,    34,    35,    36,
      37,    38,    39,    40,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    48,    49,    50,    51,    52,    53,    -1,    55,    56,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    69,    70,    71,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    85,    -1,
      87,    88,    89,    -1,    91,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   116,
      -1,    -1,    -1,   120,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   131,    -1,    -1,   134,   135,   136,
      -1,    -1,     3,   140,   141,     6,     7,    -1,    -1,    -1,
      11,    12,    13,    14,    15,    16,    17,    18,    19,    20,
      21,    22,    -1,    24,    25,    26,    27,    28,    29,    30,
      31,    32,    33,    34,    35,    36,    37,    38,    39,    40,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    49,    50,
      51,    52,    53,    -1,    55,    56,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    69,    70,
      71,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    85,    -1,    87,    88,    89,    -1,
      91,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   116,    -1,    -1,    -1,   120,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     131,    -1,    -1,   134,   135,   136,    -1,    -1,     3,   140,
     141,     6,     7,    -1,    -1,    -1,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    -1,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    38,    39,    40,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    48,    49,    50,    51,    52,    53,    59,
      55,    56,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    69,    70,    71,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      85,    -1,    87,    88,    89,    -1,    91,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   107,   108,   109,
     110,   111,    -1,   113,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   116,    -1,    -1,    -1,   120,    -1,   127,   128,   129,
     130,   131,   132,   133,   134,   135,   136,   137,   138,   134,
     135,    -1,    -1,    -1,     3,   140,   141,     6,     7,    -1,
      -1,    -1,    11,    12,    13,    14,    15,    16,    17,    18,
      19,    20,    21,    22,    -1,    24,    25,    26,    27,    28,
      29,    30,    31,    32,    33,    34,    35,    36,    37,    38,
      39,    40,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      49,    50,    51,    52,    53,    -1,    55,    56,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      69,    70,    71,    -1,    -1,    -1,    -1,     3,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    85,    -1,    87,    88,
      89,    -1,    91,    -1,    -1,    -1,    -1,    -1,    24,    25,
      26,    27,    28,    29,    30,    31,    32,    33,    34,    35,
      36,    37,    38,    39,    40,    -1,    -1,   116,    -1,    -1,
      -1,   120,    48,    49,    50,    51,    52,    53,    -1,    -1,
      -1,    -1,    58,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   140,   141,    69,    70,    71,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    85,
      86,    -1,    88,    89,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     116,     3,    -1,    -1,   120,    -1,    -1,    -1,    -1,   125,
      -1,    -1,   128,    -1,    -1,   131,    -1,    -1,    -1,    -1,
     136,    -1,    24,    25,    26,    27,    28,    29,    30,    31,
      32,    33,    34,    35,    36,    37,    38,    39,    40,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    48,    49,    50,    51,
      52,    53,    -1,    -1,    -1,    -1,    58,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    69,    70,    71,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    85,    86,    -1,    88,    89,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   116,     3,    -1,    -1,   120,    -1,
      -1,    -1,    -1,   125,    -1,    -1,   128,    -1,    -1,   131,
      -1,    -1,    -1,    -1,   136,    -1,    24,    25,    26,    27,
      28,    29,    30,    31,    32,    33,    34,    35,    36,    37,
      38,    39,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      48,    49,    50,    51,    52,    53,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    69,    70,    71,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    85,    86,    -1,
      88,    89,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,     0,     1,   116,     3,
       4,    -1,   120,    -1,     8,     9,    10,   125,    -1,    -1,
     128,    -1,    -1,   131,    -1,    -1,    -1,    -1,   136,    23,
      24,    25,    26,    27,    28,    29,    30,    31,    32,    33,
      34,    35,    36,    37,    38,    39,    -1,    -1,    -1,    43,
      44,    -1,    -1,    -1,    -1,    49,    50,    51,    52,    53,
      -1,    -1,    -1,    57,    -1,    -1,    -1,    -1,    62,    63,
      64,    65,    66,    67,    68,    69,    70,    71,    -1,    -1,
      -1,    -1,    76,    77,    78,    -1,    80,    81,    82,    83,
      84,    85,    86,    -1,    88,    89,    -1,    -1,    92,    93,
      94,    95,    96,    97,    98,    99,   100,   101,   102,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     114,     1,   116,     3,     4,   119,   120,    -1,     8,     9,
      10,   125,   126,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    23,    24,    25,    26,    27,    28,    29,
      30,    31,    32,    33,    34,    35,    36,    37,    38,    39,
      -1,    -1,    -1,    43,    44,    -1,    46,    -1,    -1,    49,
      50,    51,    52,    53,    -1,    -1,    -1,    57,    -1,    -1,
      -1,    -1,    62,    63,    64,    65,    66,    67,    68,    69,
      70,    71,    -1,    -1,    -1,    -1,    76,    77,    78,    -1,
      80,    81,    82,    83,    84,    85,    86,    -1,    88,    89,
      -1,    -1,    92,    93,    94,    95,    96,    97,    98,    99,
     100,   101,   102,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   114,     1,   116,     3,     4,   119,
     120,    -1,     8,     9,    10,   125,   126,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    23,    24,    25,
      26,    27,    28,    29,    30,    31,    32,    33,    34,    35,
      36,    37,    38,    39,    -1,    -1,    -1,    43,    44,    -1,
      46,    -1,    -1,    49,    50,    51,    52,    53,    -1,    -1,
      -1,    57,    -1,    -1,    -1,    -1,    62,    63,    64,    65,
      66,    67,    68,    69,    70,    71,    -1,    -1,    -1,    -1,
      76,    77,    78,    -1,    80,    81,    82,    83,    84,    85,
      86,    -1,    88,    89,    -1,    -1,    92,    93,    94,    95,
      96,    97,    98,    99,   100,   101,   102,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   114,     1,
     116,     3,     4,   119,   120,    -1,     8,     9,    10,   125,
     126,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    23,    24,    25,    26,    27,    28,    29,    30,    31,
      32,    33,    34,    35,    36,    37,    38,    39,    -1,    -1,
      -1,    43,    44,    -1,    46,    -1,    -1,    49,    50,    51,
      52,    53,    -1,    -1,    -1,    57,    -1,    -1,    -1,    -1,
      62,    63,    64,    65,    66,    67,    68,    69,    70,    71,
      -1,    -1,    -1,    -1,    76,    77,    78,    -1,    80,    81,
      82,    83,    84,    85,    86,    -1,    88,    89,    -1,    -1,
      92,    93,    94,    95,    96,    97,    98,    99,   100,   101,
     102,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   114,     1,   116,     3,     4,   119,   120,    -1,
       8,     9,    10,   125,   126,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    23,    24,    25,    26,    27,
      28,    29,    30,    31,    32,    33,    34,    35,    36,    37,
      38,    39,    -1,    -1,    -1,    43,    44,    -1,    -1,    -1,
      -1,    49,    50,    51,    52,    53,    -1,    -1,    -1,    57,
      -1,    -1,    -1,    61,    62,    63,    64,    65,    66,    67,
      68,    69,    70,    71,    -1,    -1,    -1,    -1,    76,    77,
      78,    -1,    80,    81,    82,    83,    84,    85,    86,    -1,
      88,    89,    -1,    -1,    92,    93,    94,    95,    96,    97,
      98,    99,   100,   101,   102,    -1,     1,    -1,     3,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   114,    -1,   116,    -1,
      -1,   119,   120,    -1,    -1,    -1,    -1,   125,   126,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    38,    39,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    48,    49,    50,    51,    52,    53,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    69,    70,    71,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      85,    86,    -1,    88,    89,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,     1,    -1,
       3,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   116,    -1,    -1,    -1,   120,    -1,    -1,    -1,    -1,
     125,    24,    25,    26,    27,    28,    29,    30,    31,    32,
      33,    34,    35,    36,    37,    38,    39,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    48,    49,    50,    51,    52,
      53,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    69,    70,    71,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    85,    86,    -1,    88,    89,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,     3,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   116,    -1,    -1,    -1,   120,    -1,    -1,
      -1,    -1,   125,    24,    25,    26,    27,    28,    29,    30,
      31,    32,    33,    34,    35,    36,    37,    38,    39,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    48,    49,    50,
      51,    52,    53,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    69,    70,
      71,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    85,    86,    -1,    88,    89,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,     3,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   116,    13,    -1,    -1,   120,
      -1,    -1,    -1,    -1,   125,   126,    -1,    24,    25,    26,
      27,    28,    29,    30,    31,    32,    33,    34,    35,    36,
      37,    38,    39,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    48,    49,    50,    51,    52,    53,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    69,    70,    71,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    85,    86,
      -1,    88,    89,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,     3,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   116,
      -1,    -1,    -1,   120,    -1,    -1,    -1,    -1,   125,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    38,    39,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    48,    49,    50,    51,    52,    53,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    69,    70,    71,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      85,    86,    -1,    88,    89,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
       3,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   116,    -1,    -1,   119,   120,    -1,    -1,    -1,    -1,
     125,    24,    25,    26,    27,    28,    29,    30,    31,    32,
      33,    34,    35,    36,    37,    38,    39,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    48,    49,    50,    51,    52,
      53,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,     4,    69,    70,    71,     8,
       9,    10,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    85,    86,    23,    88,    89,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    43,    44,    -1,    46,    -1,    -1,
      -1,    -1,    -1,   116,    -1,    -1,    -1,   120,    -1,    -1,
      -1,    -1,   125,    62,    63,    64,    65,    66,    67,    68,
      -1,    -1,    -1,    72,    73,    74,    -1,    76,    77,    78,
      -1,    80,    81,    82,    83,    84,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    92,    -1,    -1,    -1,    96,    97,    98,
      99,   100,   101,   102,     1,    -1,     3,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   114,    -1,    -1,    -1,    -1,
     119,    -1,    -1,    -1,    -1,    -1,   125,    24,    25,    26,
      27,    28,    29,    30,    31,    32,    33,    34,    35,    36,
      37,    38,    39,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    49,    50,    51,    52,    53,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    69,    70,    71,    -1,    -1,    -1,     3,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    85,    -1,
      -1,    88,    89,    -1,    -1,    -1,    -1,    -1,    -1,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    38,    39,    -1,    -1,    -1,    -1,   116,
      -1,    -1,    -1,   120,    49,    50,    51,    52,    53,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    69,    70,    71,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      85,    86,    -1,    88,    89,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,     3,
      -1,   116,     6,     7,    -1,   120,   121,    11,    12,    13,
      14,    15,    16,    17,    18,    19,    20,    21,    22,    -1,
      24,    25,    26,    27,    28,    29,    30,    31,    32,    33,
      34,    35,    36,    37,    38,    39,    40,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    48,    49,    50,    51,    52,    53,
      -1,    55,    56,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    69,    70,    71,    -1,    -1,
      -1,    -1,     3,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    85,    -1,    87,    88,    89,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    24,    25,    26,    27,    28,    29,    30,
      31,    32,    33,    34,    35,    36,    37,    38,    39,    -1,
      -1,    -1,   116,    -1,    -1,    -1,   120,    48,    49,    50,
      51,    52,    53,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    69,    70,
      71,    -1,    -1,    -1,     3,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    85,    86,    -1,    88,    89,    -1,
      -1,    -1,    -1,    -1,    -1,    24,    25,    26,    27,    28,
      29,    30,    31,    32,    33,    34,    35,    36,    37,    38,
      39,    -1,    -1,    -1,    -1,   116,    -1,    -1,    -1,   120,
      49,    50,    51,    52,    53,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      69,    70,    71,    -1,    -1,    -1,     3,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    85,    86,    -1,    88,
      89,    -1,    -1,    -1,    -1,    -1,    -1,    24,    25,    26,
      27,    28,    29,    30,    31,    32,    33,    34,    35,    36,
      37,    38,    39,    40,    -1,    -1,    -1,   116,    -1,    -1,
      -1,   120,    49,    50,    51,    52,    53,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    69,    70,    71,    -1,    -1,    -1,     3,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    85,    -1,
      -1,    88,    89,    -1,    -1,    -1,    -1,    -1,    -1,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    38,    39,    -1,    -1,    -1,    -1,   116,
      -1,    -1,    -1,   120,    49,    50,    51,    52,    53,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    69,    70,    71,    -1,    -1,    -1,
       3,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      85,    86,    -1,    88,    89,    -1,    -1,    -1,    -1,    -1,
      -1,    24,    25,    26,    27,    28,    29,    30,    31,    32,
      33,    34,    35,    36,    37,    38,    39,    -1,    -1,    -1,
      -1,   116,    -1,    -1,    -1,   120,    49,    50,    51,    52,
      53,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    69,    70,    71,     3,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    85,    -1,    -1,    88,    89,    -1,    -1,    -1,
      24,    25,    26,    27,    28,    29,    30,    31,    32,    33,
      34,    35,    36,    37,    38,    39,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   116,    -1,    49,    -1,   120,    52,    53,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    40,    -1,    -1,    69,    70,    71,    -1,    -1,
      -1,    49,    50,    51,    -1,    -1,    54,    -1,    -1,    -1,
      -1,    85,    -1,    -1,    88,    89,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,     3,    -1,    -1,   103,
      -1,    79,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    87,
      88,    89,   116,    91,    -1,    -1,   120,    24,    25,    26,
      27,    28,    29,    30,    31,    32,    33,    34,    35,    36,
      37,    38,    39,    -1,   112,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    49,    -1,    -1,    52,    53,    -1,    -1,    -1,
     128,    -1,    -1,   131,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    69,    70,    71,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    85,    -1,
      -1,    88,    89,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,     3,    -1,    -1,   103,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   116,
      -1,    -1,    -1,   120,    24,    25,    26,    27,    28,    29,
      30,    31,    32,    33,    34,    35,    36,    37,    38,    39,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    49,
      -1,    -1,    52,    53,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    69,
      70,    71,     3,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    85,    -1,    -1,    88,    89,
      -1,    -1,    -1,    24,    25,    26,    27,    28,    29,    30,
      31,    32,    33,    34,    35,    36,    37,    38,    39,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   116,    -1,    -1,    -1,
     120,    52,    53,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    69,    70,
      71,     3,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    85,    -1,    -1,    88,    89,    -1,
      -1,    -1,    24,    25,    26,    27,    28,    29,    30,    31,
      32,    33,    34,    35,    36,    37,    38,    39,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   116,    -1,    49,    -1,   120,
      -1,    -1,    -1,     4,    -1,    -1,    -1,     8,     9,    10,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    69,    -1,    -1,
      -1,    -1,    23,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    85,    -1,    -1,    88,    89,    -1,    -1,
      -1,    -1,    43,    44,    -1,    46,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      59,    62,    63,    64,   116,    66,    67,    68,   120,    -1,
      -1,    72,    73,    74,    -1,    76,    77,    78,    -1,    80,
      81,    82,    83,    84,     4,    -1,    -1,    -1,     8,     9,
      10,    92,    -1,    -1,    -1,    96,    97,    98,    99,   100,
     101,   102,    -1,    23,    -1,    -1,    -1,    -1,   107,   108,
     109,   110,   111,   114,   113,    -1,    -1,    -1,   119,    -1,
      -1,    -1,    -1,    43,    44,    -1,    46,    -1,   127,   128,
     129,   130,   131,   132,   133,   134,   135,   136,   137,   138,
      -1,    59,    62,    63,    64,    -1,    66,    67,    68,    -1,
      -1,    -1,    72,    73,    74,    -1,    76,    77,    78,    -1,
      80,    81,    82,    83,    84,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    92,    59,    -1,    -1,    96,    97,    98,    99,
     100,   101,   102,    -1,    -1,    -1,    -1,    -1,    -1,   107,
     108,   109,   110,   111,   114,   113,    -1,    -1,    -1,   119,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   127,
     128,   129,   130,   131,   132,   133,   134,   135,   136,   137,
     138,   107,   108,   109,   110,   111,    -1,   113,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   127,   128,   129,   130,   131,   132,   133,   134,   135,
     136,   137,   138
};

/* YYSTOS[STATE-NUM] -- The symbol kind of the accessing symbol of
   state STATE-NUM.  */
static const yytype_int16 yystos[] =
{
       0,   122,   123,   124,   145,   146,     1,     3,    24,    25,
      26,    27,    28,    29,    30,    31,    32,    33,    34,    35,
      36,    37,    38,    39,    48,    49,    50,    51,    52,    53,
      69,    70,    71,    85,    86,    88,    89,   116,   120,   125,
     195,   240,   241,   256,   257,   259,   260,   261,   264,   265,
     266,   302,   303,   319,   322,   324,     1,   241,     1,    40,
       0,     1,     4,     8,     9,    10,    23,    43,    44,    57,
      62,    63,    64,    65,    66,    67,    68,    76,    77,    78,
      80,    81,    82,    83,    84,    92,    93,    94,    95,    96,
      97,    98,    99,   100,   101,   102,   114,   119,   125,   126,
     147,   148,   149,   151,   152,   153,   154,   157,   158,   160,
     161,   162,   163,   164,   165,   168,   169,   170,   173,   175,
     180,   181,   182,   183,   185,   189,   197,   198,   199,   200,
     201,   202,   206,   207,   214,   217,   228,   229,   235,   236,
     237,    52,    70,    48,   293,   293,    40,    40,    54,    58,
     120,   128,   131,   136,   140,   245,   246,   248,   250,   251,
     252,   253,   322,   143,   103,   318,   240,   322,     0,    86,
     257,   260,   322,    48,   246,   256,   265,   322,   318,    86,
     118,   143,   323,     0,   238,   239,   241,   121,    40,     6,
     119,   328,    40,   331,     1,   256,   258,   259,   319,   322,
     331,    40,   167,    40,    40,    40,    40,    71,    93,   215,
     216,   322,   324,    45,   319,   322,    40,     4,    45,    40,
       4,   328,    40,   179,   258,   177,   178,   179,    40,    40,
     328,    40,    32,    34,    49,   103,   188,   195,   261,   264,
     303,   322,   331,    40,   128,   131,   248,   250,   253,   322,
      86,   195,   258,   303,   322,    44,   237,   262,    40,   128,
     131,   238,   251,   253,   322,     7,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    40,    45,
      55,    56,    87,    91,   105,   106,   131,   134,   135,   136,
     140,   141,   258,   267,   268,   269,   270,   279,   280,   286,
     289,   290,   291,   292,   322,   328,   329,    59,   279,     3,
      40,    48,   140,   249,   252,   293,   322,    48,   249,   252,
     293,   256,   322,   245,    40,    58,   245,    40,    58,    48,
     128,   131,   136,   249,   252,   293,   322,   117,   119,   120,
     324,   325,   241,   242,   243,   244,   259,   279,   290,   322,
     246,   256,    86,   246,   324,   120,   325,    41,    42,   125,
     126,   268,   319,   320,   328,   188,   303,     6,    45,   320,
     332,   333,   320,     0,    43,    40,   248,   250,    54,    52,
      53,    70,   304,   305,   319,   319,   320,    13,   174,   238,
     238,   322,   322,    43,   121,    43,    48,    54,   143,   219,
      54,    45,   319,   176,   332,   238,    45,   247,   248,   250,
     251,    43,    42,   320,   321,   155,   156,   328,   238,   322,
     119,   211,   212,   213,   241,   302,   322,   322,   322,   128,
     131,   328,   128,   131,   253,   319,   322,   332,    40,    48,
      48,   320,    40,    48,   128,   131,   322,   117,   248,   322,
     271,   319,    40,   248,    75,   294,   295,   322,    86,   328,
       1,   263,   279,   128,   131,   253,   322,   250,   322,   250,
      41,    41,   128,   131,   250,   322,   117,   279,   289,    40,
      48,   258,   289,    40,    40,    40,   287,   279,   279,   279,
     279,   279,   279,    40,    58,   107,   108,   109,   110,   111,
     113,   127,   128,   129,   130,   131,   132,   133,   134,   135,
     136,   137,   138,    40,    47,   112,    47,   112,     7,     6,
       7,    59,    40,   253,   322,   249,   322,    40,    58,   249,
     238,    59,   279,   238,    59,   279,   249,    48,   249,   252,
     293,    48,   249,   252,   293,   256,   117,    48,   128,   131,
     249,   256,   319,   323,   104,    42,   246,   323,     0,   126,
     238,    42,    41,   322,   322,   184,    54,    41,    42,   245,
      40,   267,   322,    41,    54,    42,   172,    42,    41,    41,
      43,    48,    43,   258,    43,   258,   146,   322,   218,    41,
      41,    41,   177,    40,   179,    41,    41,    42,    45,    41,
     128,   131,   103,   104,    42,   245,    40,    60,   117,    41,
     253,   322,    43,   238,    48,    48,   117,    79,    87,    88,
      89,    91,   128,   131,   254,   255,   256,   307,   311,   312,
     313,    54,    75,   196,   238,   322,   313,   296,    45,    43,
      89,   310,   248,    41,    41,   322,   117,    41,    41,    41,
     117,   248,   251,   256,    41,   104,   128,   131,   136,   253,
     103,    40,   238,    45,   288,    48,   279,    48,   279,    48,
     279,    48,   279,   279,   279,    48,   279,    48,   279,    48,
     279,    48,   279,    48,   279,    48,   279,    48,   279,    48,
     279,    48,   279,    48,   279,    48,   279,    48,   279,     3,
       3,     3,     3,   238,   249,   322,    41,   117,   238,    59,
     279,    41,    59,    41,    59,   249,   249,    48,   128,   131,
     249,   252,   249,    48,    48,   249,   318,   244,   238,   238,
       4,    45,   328,    40,   146,   155,   291,   328,   334,   320,
      43,   238,    43,    45,     4,   166,   328,   320,   328,   334,
      41,   241,   248,    45,    43,   247,    46,    43,   146,   235,
     177,    40,    46,   238,   116,   120,   319,   326,    43,   332,
     241,     4,    43,    45,   115,   171,   328,   330,   211,    91,
     309,   213,   238,   159,   256,   248,   328,   117,    41,    40,
      40,   307,    89,    88,    40,   281,   282,   283,   284,   286,
     322,   311,   255,    91,    43,    45,   112,     1,    58,   190,
     267,   260,    43,    45,    41,    54,    75,   187,   245,    77,
     297,   298,   306,   204,   294,   313,    41,    41,   248,   251,
     279,    48,   279,    41,    41,   256,    41,   128,   131,    48,
     279,   319,    41,    75,    41,    41,   249,    41,    59,   312,
     254,   249,    48,    48,   249,   249,   249,   238,    46,    54,
      41,   150,    54,    42,   172,   171,   248,   313,    43,    46,
     258,   319,    43,    54,   330,   238,    41,   143,   118,   143,
     327,   103,    41,    46,    40,   104,   281,    92,   208,    41,
     146,   313,    43,   238,   279,   285,   127,   128,   281,   188,
      43,   103,   191,    43,   153,   272,   273,   274,   275,    40,
      54,   112,   311,   313,   314,     1,   279,     1,    42,    43,
      45,   186,    42,    72,    73,    74,   299,   301,     1,    43,
      65,    72,    73,    74,   125,   151,   152,   153,   154,   157,
     158,   162,   165,   168,   170,   173,   175,   180,   181,   182,
     183,   202,   206,   207,   214,   220,   221,   222,   223,   225,
     226,   227,   228,   230,   231,   233,   235,    45,    43,    45,
     112,    41,    41,    41,    41,   279,   279,   279,    41,    41,
      41,    41,    41,   279,    41,   249,   249,    41,   155,   334,
     254,   220,   328,   334,    41,   313,    43,   248,    43,   179,
      41,   254,   120,   319,   319,   120,   319,   242,     4,    45,
     238,   303,   322,    44,    90,   119,   185,   200,   202,   206,
     207,   209,   210,   225,   227,   235,    43,   254,    61,    43,
      41,    41,   283,   284,   307,   308,   309,   272,   125,   276,
     277,   319,    46,    42,   125,   126,   238,   267,   258,    54,
      75,   315,    43,   248,   298,   322,   300,    45,    75,    75,
      75,   222,    46,   125,   223,   126,    32,    34,   121,   140,
     234,   258,   264,   322,   203,   188,   279,   279,    43,   254,
     245,    46,   172,    43,   248,   171,    43,    43,   327,   327,
     104,    41,   245,   322,    54,   322,   103,    86,    43,   307,
     187,    40,    45,   192,   277,   273,    54,    43,   248,   126,
     274,    42,    41,    43,   309,   268,   316,   317,   322,    43,
      45,   313,   293,   306,   224,    43,   205,   248,   258,   324,
      75,    40,    43,   220,   308,    43,    43,   313,    43,    43,
     245,   258,    54,   211,   322,   186,   238,    40,    43,   193,
     278,   279,   313,   274,   274,    43,    45,    43,    43,    42,
      48,    40,    45,   187,   322,   220,   313,    40,   128,   131,
     253,    40,   279,   238,    46,   187,    43,   247,   281,   104,
      54,    41,   194,   187,   317,   186,   293,    46,   187,   238,
      40,    40,    40,   131,   238,    43,    41,   205,   186,    43,
      43,   309,   313,    43,   186,    48,   186,    41,   238,   238,
     238,    40,    41,   314,   112,   192,   232,   313,    41,    41,
      41,   238,   232,   258,   193,    43,    45,    54,   232,   232,
     232,    41,   309,   267,   232,   192,    43,   193
};

/* YYR1[RULE-NUM] -- Symbol kind of the left-hand side of rule RULE-NUM.  */
static const yytype_int16 yyr1[] =
{
       0,   144,   145,   145,   145,   145,   145,   145,   145,   146,
     146,   146,   146,   147,   147,   147,   147,   147,   147,   147,
     148,   148,   148,   148,   148,   148,   148,   148,   148,   148,
     148,   148,   148,   148,   148,   148,   148,   148,   148,   150,
     149,   151,   152,   153,   153,   153,   153,   153,   154,   154,
     155,   156,   156,   157,   157,   157,   159,   158,   160,   160,
     161,   161,   162,   162,   162,   162,   163,   164,   164,   165,
     165,   166,   166,   167,   167,   168,   168,   168,   169,   169,
     170,   170,   170,   170,   171,   171,   171,   172,   172,   173,
     174,   174,   175,   175,   175,   176,   177,   178,   178,   179,
     179,   179,   180,   181,   182,   183,   183,   183,   183,   184,
     183,   183,   183,   183,   183,   185,   185,   185,   185,   185,
     185,   185,   185,   185,   185,   186,   186,   186,   186,   187,
     187,   188,   188,   188,   188,   188,   188,   188,   188,   188,
     188,   189,   189,   189,   190,   191,   191,   192,   193,   194,
     193,   195,   195,   195,   196,   196,   197,   198,   198,   199,
     200,   201,   201,   201,   201,   201,   201,   203,   202,   204,
     202,   205,   205,   206,   208,   207,   207,   207,   207,   207,
     207,   207,   209,   209,   209,   209,   209,   209,   209,   209,
     210,   211,   211,   212,   212,   213,   213,   213,   213,   214,
     214,   214,   214,   214,   214,   215,   216,   218,   217,   219,
     217,   217,   220,   220,   220,   220,   220,   221,   221,   222,
     222,   222,   222,   222,   222,   222,   222,   222,   222,   222,
     222,   222,   222,   222,   222,   222,   222,   222,   223,   223,
     223,   224,   223,   225,   226,   227,   227,   227,   227,   227,
     228,   229,   230,   230,   230,   231,   231,   231,   231,   231,
     231,   231,   231,   231,   231,   232,   232,   232,   233,   234,
     234,   234,   234,   235,   235,   236,   236,   237,   237,   237,
     237,   237,   237,   237,   237,   237,   238,   239,   239,   239,
     239,   239,   239,   239,   240,   240,   240,   240,   240,   240,
     241,   241,   242,   242,   243,   243,   244,   244,   245,   245,
     245,   245,   246,   246,   246,   246,   247,   247,   247,   247,
     248,   248,   248,   248,   248,   248,   248,   248,   248,   248,
     248,   248,   248,   248,   248,   248,   248,   248,   248,   248,
     248,   249,   249,   249,   249,   249,   249,   249,   249,   250,
     250,   250,   250,   250,   250,   250,   250,   250,   250,   250,
     250,   250,   251,   251,   251,   251,   251,   251,   251,   251,
     251,   251,   251,   251,   251,   251,   251,   252,   252,   252,
     252,   252,   252,   252,   252,   253,   253,   253,   253,   254,
     254,   254,   255,   255,   256,   256,   257,   257,   257,   258,
     259,   259,   259,   259,   259,   260,   260,   260,   260,   260,
     260,   260,   262,   261,   263,   263,   264,   265,   265,   266,
     266,   266,   266,   266,   266,   266,   266,   266,   266,   266,
     266,   266,   266,   267,   267,   268,   268,   269,   270,   271,
     271,   272,   272,   273,   273,   274,   274,   274,   274,   274,
     274,   274,   275,   276,   276,   277,   277,   278,   279,   279,
     280,   280,   280,   280,   280,   280,   281,   282,   282,   283,
     283,   284,   285,   284,   284,   286,   287,   287,   288,   289,
     289,   289,   289,   289,   289,   289,   289,   289,   289,   289,
     290,   290,   290,   290,   290,   290,   290,   290,   290,   290,
     290,   290,   291,   291,   291,   291,   291,   291,   291,   291,
     291,   291,   292,   292,   292,   292,   292,   292,   292,   292,
     292,   292,   292,   292,   292,   292,   292,   292,   292,   292,
     292,   292,   292,   292,   292,   292,   292,   292,   292,   292,
     292,   292,   292,   292,   292,   292,   292,   292,   292,   292,
     292,   292,   292,   292,   293,   293,   294,   296,   295,   295,
     297,   297,   299,   298,   300,   298,   301,   301,   301,   302,
     302,   303,   303,   303,   304,   304,   304,   305,   305,   306,
     306,   307,   307,   307,   307,   308,   308,   309,   309,   310,
     310,   311,   311,   311,   311,   311,   311,   312,   312,   312,
     313,   313,   313,   313,   314,   314,   314,   314,   314,   314,
     315,   315,   316,   316,   316,   316,   317,   317,   318,   319,
     319,   319,   320,   320,   320,   321,   321,   322,   322,   322,
     322,   322,   322,   322,   323,   323,   323,   323,   324,   324,
     325,   325,   326,   326,   326,   326,   326,   326,   327,   327,
     327,   327,   328,   328,   329,   329,   329,   329,   330,   330,
     330,   331,   331,   332,   333,   333,   333,   333,   333,   333,
     334,   334
};

/* YYR2[RULE-NUM] -- Number of symbols on the right-hand side of rule RULE-NUM.  */
static const yytype_int8 yyr2[] =
{
       0,     2,     1,     3,     2,     3,     2,     5,     2,     2,
       2,     2,     0,     1,     1,     1,     1,     1,     1,     2,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     0,
       8,     5,     3,     5,     5,     9,     3,     3,     2,     2,
       4,     1,     1,     7,     7,     5,     0,     7,     1,     1,
       2,     2,     1,     5,     5,     5,     3,     7,     8,     5,
       3,     1,     1,     3,     0,     4,     7,     6,     1,     1,
       8,    10,     6,     8,     1,     1,     5,     5,     0,     7,
       1,     3,     6,     6,     8,     1,     1,     1,     3,     2,
       3,     6,     5,     9,     2,     1,     1,     1,     1,     0,
       6,     1,     6,    11,     1,     6,     7,    10,     9,     5,
       6,     5,     6,     6,     6,     1,     5,     1,     1,     1,
       2,     1,     1,     1,     2,     1,     2,     2,     3,     3,
       1,    13,    16,     9,     1,     1,     0,     1,     1,     0,
       3,     1,     2,     2,     2,     0,     5,     8,    11,     6,
       9,     1,     1,     1,     1,     1,     1,     0,    10,     0,
       8,     1,     4,     4,     0,     7,     3,     7,     8,     4,
       8,     9,     1,     1,     1,     1,     1,     1,     1,     1,
       5,     1,     0,     1,     3,     2,     7,     6,     1,     3,
       3,     4,     4,     5,     4,     3,     2,     0,     6,     0,
       5,     5,     1,     2,     0,     1,     1,     1,     2,     1,
       1,     1,     1,     1,     1,     1,     1,     3,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     2,
       2,     0,     5,     6,     7,     8,     8,     8,     9,     7,
       5,     2,     2,     2,     2,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     2,     4,     2,     5,     1,
       1,     1,     1,     1,     0,     1,     2,     1,     2,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     2,     2,
       3,     4,     4,     0,     2,     2,     3,     3,     4,     1,
       1,     2,     1,     0,     1,     3,     1,     1,     2,     3,
       2,     0,     2,     2,     1,     5,     1,     1,     5,     0,
       2,     3,     3,     1,     2,     2,     3,     4,     5,     4,
       3,     4,     4,     3,     3,     4,     5,     6,     6,     5,
       5,     1,     2,     3,     4,     5,     3,     4,     4,     1,
       2,     4,     4,     4,     5,     6,     5,     6,     3,     4,
       4,     5,     2,     2,     3,     3,     3,     3,     1,     2,
       2,     2,     2,     2,     3,     3,     4,     3,     4,     2,
       3,     3,     4,     5,     3,     3,     2,     2,     1,     1,
       2,     1,     1,     1,     1,     2,     1,     1,     1,     1,
       2,     1,     2,     3,     2,     1,     1,     1,     2,     1,
       2,     1,     0,     4,     2,     2,     1,     1,     2,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       0,     1,     2,     1,     0,     1,     2,     2,     3,     4,
       4,     1,     3,     1,     2,     1,     3,     1,     1,     1,
       3,     3,     3,     3,     2,     2,     1,     1,     3,     1,
       3,     1,     0,     2,     1,     3,     3,     0,     1,     1,
       1,     1,     1,     1,     1,     2,     2,     2,     5,     2,
       1,     1,     1,     3,     4,     5,     5,     5,     6,     6,
       2,     2,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     3,     3,     3,     3,     3,     3,     3,     3,
       3,     3,     3,     3,     3,     3,     5,     5,     3,     3,
       3,     3,     3,     3,     3,     3,     3,     3,     3,     3,
       3,     3,     3,     3,     5,     5,     3,     3,     3,     5,
       2,     2,     2,     2,     1,     0,     1,     0,     3,     0,
       1,     3,     0,     4,     0,     6,     1,     1,     1,     2,
       2,     1,     1,     1,     1,     1,     1,     1,     0,     1,
       0,     1,     1,     2,     2,     1,     0,     2,     0,     1,
       0,     4,     1,     1,     5,     2,     4,     1,     1,     2,
       1,     3,     2,     0,     3,     3,     4,     4,     3,     4,
       2,     0,     1,     3,     2,     4,     2,     2,     3,     1,
       1,     1,     1,     1,     1,     1,     0,     2,     4,     1,
       3,     1,     2,     3,     3,     2,     2,     2,     1,     2,
       1,     3,     2,     4,     1,     3,     1,     3,     3,     2,
       2,     2,     2,     1,     2,     2,     2,     1,     1,     1,
       1,     3,     0,     1,     3,     5,     1,     3,     3,     5,
       1,     1
};


enum { YYENOMEM = -2 };

#define yyerrok         (yyerrstatus = 0)
#define yyclearin       (yychar = YYEMPTY)

#define YYACCEPT        goto yyacceptlab
#define YYABORT         goto yyabortlab
#define YYERROR         goto yyerrorlab
#define YYNOMEM         goto yyexhaustedlab


#define YYRECOVERING()  (!!yyerrstatus)

#define YYBACKUP(Token, Value)                                    \
  do                                                              \
    if (yychar == YYEMPTY)                                        \
      {                                                           \
        yychar = (Token);                                         \
        yylval = (Value);                                         \
        YYPOPSTACK (yylen);                                       \
        yystate = *yyssp;                                         \
        goto yybackup;                                            \
      }                                                           \
    else                                                          \
      {                                                           \
        yyerror (YY_("syntax error: cannot back up")); \
        YYERROR;                                                  \
      }                                                           \
  while (0)

/* Backward compatibility with an undocumented macro.
   Use YYerror or YYUNDEF. */
#define YYERRCODE YYUNDEF


/* Enable debugging if requested.  */
#if YYDEBUG

# ifndef YYFPRINTF
#  include <stdio.h> /* INFRINGES ON USER NAME SPACE */
#  define YYFPRINTF fprintf
# endif

# define YYDPRINTF(Args)                        \
do {                                            \
  if (yydebug)                                  \
    YYFPRINTF Args;                             \
} while (0)




# define YY_SYMBOL_PRINT(Title, Kind, Value, Location)                    \
do {                                                                      \
  if (yydebug)                                                            \
    {                                                                     \
      YYFPRINTF (stderr, "%s ", Title);                                   \
      yy_symbol_print (stderr,                                            \
                  Kind, Value); \
      YYFPRINTF (stderr, "\n");                                           \
    }                                                                     \
} while (0)


/*-----------------------------------.
| Print this symbol's value on YYO.  |
`-----------------------------------*/

static void
yy_symbol_value_print (FILE *yyo,
                       yysymbol_kind_t yykind, YYSTYPE const * const yyvaluep)
{
  FILE *yyoutput = yyo;
  YY_USE (yyoutput);
  if (!yyvaluep)
    return;
  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  YY_USE (yykind);
  YY_IGNORE_MAYBE_UNINITIALIZED_END
}


/*---------------------------.
| Print this symbol on YYO.  |
`---------------------------*/

static void
yy_symbol_print (FILE *yyo,
                 yysymbol_kind_t yykind, YYSTYPE const * const yyvaluep)
{
  YYFPRINTF (yyo, "%s %s (",
             yykind < YYNTOKENS ? "token" : "nterm", yysymbol_name (yykind));

  yy_symbol_value_print (yyo, yykind, yyvaluep);
  YYFPRINTF (yyo, ")");
}

/*------------------------------------------------------------------.
| yy_stack_print -- Print the state stack from its BOTTOM up to its |
| TOP (included).                                                   |
`------------------------------------------------------------------*/

static void
yy_stack_print (yy_state_t *yybottom, yy_state_t *yytop)
{
  YYFPRINTF (stderr, "Stack now");
  for (; yybottom <= yytop; yybottom++)
    {
      int yybot = *yybottom;
      YYFPRINTF (stderr, " %d", yybot);
    }
  YYFPRINTF (stderr, "\n");
}

# define YY_STACK_PRINT(Bottom, Top)                            \
do {                                                            \
  if (yydebug)                                                  \
    yy_stack_print ((Bottom), (Top));                           \
} while (0)


/*------------------------------------------------.
| Report that the YYRULE is going to be reduced.  |
`------------------------------------------------*/

static void
yy_reduce_print (yy_state_t *yyssp, YYSTYPE *yyvsp,
                 int yyrule)
{
  int yylno = yyrline[yyrule];
  int yynrhs = yyr2[yyrule];
  int yyi;
  YYFPRINTF (stderr, "Reducing stack by rule %d (line %d):\n",
             yyrule - 1, yylno);
  /* The symbols being reduced.  */
  for (yyi = 0; yyi < yynrhs; yyi++)
    {
      YYFPRINTF (stderr, "   $%d = ", yyi + 1);
      yy_symbol_print (stderr,
                       YY_ACCESSING_SYMBOL (+yyssp[yyi + 1 - yynrhs]),
                       &yyvsp[(yyi + 1) - (yynrhs)]);
      YYFPRINTF (stderr, "\n");
    }
}

# define YY_REDUCE_PRINT(Rule)          \
do {                                    \
  if (yydebug)                          \
    yy_reduce_print (yyssp, yyvsp, Rule); \
} while (0)

/* Nonzero means print parse trace.  It is left uninitialized so that
   multiple parsers can coexist.  */
int yydebug;
#else /* !YYDEBUG */
# define YYDPRINTF(Args) ((void) 0)
# define YY_SYMBOL_PRINT(Title, Kind, Value, Location)
# define YY_STACK_PRINT(Bottom, Top)
# define YY_REDUCE_PRINT(Rule)
#endif /* !YYDEBUG */


/* YYINITDEPTH -- initial size of the parser's stacks.  */
#ifndef YYINITDEPTH
# define YYINITDEPTH 200
#endif

/* YYMAXDEPTH -- maximum size the stacks can grow to (effective only
   if the built-in stack extension method is used).

   Do not make this value too large; the results are undefined if
   YYSTACK_ALLOC_MAXIMUM < YYSTACK_BYTES (YYMAXDEPTH)
   evaluated with infinite-precision integer arithmetic.  */

#ifndef YYMAXDEPTH
# define YYMAXDEPTH 10000
#endif






/*-----------------------------------------------.
| Release the memory associated to this symbol.  |
`-----------------------------------------------*/

static void
yydestruct (const char *yymsg,
            yysymbol_kind_t yykind, YYSTYPE *yyvaluep)
{
  YY_USE (yyvaluep);
  if (!yymsg)
    yymsg = "Deleting";
  YY_SYMBOL_PRINT (yymsg, yykind, yyvaluep, yylocationp);

  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  YY_USE (yykind);
  YY_IGNORE_MAYBE_UNINITIALIZED_END
}


/* Lookahead token kind.  */
int yychar;

/* The semantic value of the lookahead symbol.  */
YYSTYPE yylval;
/* Number of syntax errors so far.  */
int yynerrs;




/*----------.
| yyparse.  |
`----------*/

int
yyparse (void)
{
    yy_state_fast_t yystate = 0;
    /* Number of tokens to shift before error messages enabled.  */
    int yyerrstatus = 0;

    /* Refer to the stacks through separate pointers, to allow yyoverflow
       to reallocate them elsewhere.  */

    /* Their size.  */
    YYPTRDIFF_T yystacksize = YYINITDEPTH;

    /* The state stack: array, bottom, top.  */
    yy_state_t yyssa[YYINITDEPTH];
    yy_state_t *yyss = yyssa;
    yy_state_t *yyssp = yyss;

    /* The semantic value stack: array, bottom, top.  */
    YYSTYPE yyvsa[YYINITDEPTH];
    YYSTYPE *yyvs = yyvsa;
    YYSTYPE *yyvsp = yyvs;

  int yyn;
  /* The return value of yyparse.  */
  int yyresult;
  /* Lookahead symbol kind.  */
  yysymbol_kind_t yytoken = YYSYMBOL_YYEMPTY;
  /* The variables used to return semantic value and location from the
     action routines.  */
  YYSTYPE yyval;



#define YYPOPSTACK(N)   (yyvsp -= (N), yyssp -= (N))

  /* The number of symbols on the RHS of the reduced rule.
     Keep to zero when no symbol should be popped.  */
  int yylen = 0;

  YYDPRINTF ((stderr, "Starting parse\n"));

  yychar = YYEMPTY; /* Cause a token to be read.  */

  goto yysetstate;


/*------------------------------------------------------------.
| yynewstate -- push a new state, which is found in yystate.  |
`------------------------------------------------------------*/
yynewstate:
  /* In all cases, when you get here, the value and location stacks
     have just been pushed.  So pushing a state here evens the stacks.  */
  yyssp++;


/*--------------------------------------------------------------------.
| yysetstate -- set current state (the top of the stack) to yystate.  |
`--------------------------------------------------------------------*/
yysetstate:
  YYDPRINTF ((stderr, "Entering state %d\n", yystate));
  YY_ASSERT (0 <= yystate && yystate < YYNSTATES);
  YY_IGNORE_USELESS_CAST_BEGIN
  *yyssp = YY_CAST (yy_state_t, yystate);
  YY_IGNORE_USELESS_CAST_END
  YY_STACK_PRINT (yyss, yyssp);

  if (yyss + yystacksize - 1 <= yyssp)
#if !defined yyoverflow && !defined YYSTACK_RELOCATE
    YYNOMEM;
#else
    {
      /* Get the current used size of the three stacks, in elements.  */
      YYPTRDIFF_T yysize = yyssp - yyss + 1;

# if defined yyoverflow
      {
        /* Give user a chance to reallocate the stack.  Use copies of
           these so that the &'s don't force the real ones into
           memory.  */
        yy_state_t *yyss1 = yyss;
        YYSTYPE *yyvs1 = yyvs;

        /* Each stack pointer address is followed by the size of the
           data in use in that stack, in bytes.  This used to be a
           conditional around just the two extra args, but that might
           be undefined if yyoverflow is a macro.  */
        yyoverflow (YY_("memory exhausted"),
                    &yyss1, yysize * YYSIZEOF (*yyssp),
                    &yyvs1, yysize * YYSIZEOF (*yyvsp),
                    &yystacksize);
        yyss = yyss1;
        yyvs = yyvs1;
      }
# else /* defined YYSTACK_RELOCATE */
      /* Extend the stack our own way.  */
      if (YYMAXDEPTH <= yystacksize)
        YYNOMEM;
      yystacksize *= 2;
      if (YYMAXDEPTH < yystacksize)
        yystacksize = YYMAXDEPTH;

      {
        yy_state_t *yyss1 = yyss;
        union yyalloc *yyptr =
          YY_CAST (union yyalloc *,
                   YYSTACK_ALLOC (YY_CAST (YYSIZE_T, YYSTACK_BYTES (yystacksize))));
        if (! yyptr)
          YYNOMEM;
        YYSTACK_RELOCATE (yyss_alloc, yyss);
        YYSTACK_RELOCATE (yyvs_alloc, yyvs);
#  undef YYSTACK_RELOCATE
        if (yyss1 != yyssa)
          YYSTACK_FREE (yyss1);
      }
# endif

      yyssp = yyss + yysize - 1;
      yyvsp = yyvs + yysize - 1;

      YY_IGNORE_USELESS_CAST_BEGIN
      YYDPRINTF ((stderr, "Stack size increased to %ld\n",
                  YY_CAST (long, yystacksize)));
      YY_IGNORE_USELESS_CAST_END

      if (yyss + yystacksize - 1 <= yyssp)
        YYABORT;
    }
#endif /* !defined yyoverflow && !defined YYSTACK_RELOCATE */


  if (yystate == YYFINAL)
    YYACCEPT;

  goto yybackup;


/*-----------.
| yybackup.  |
`-----------*/
yybackup:
  /* Do appropriate processing given the current state.  Read a
     lookahead token if we need one and don't already have one.  */

  /* First try to decide what to do without reference to lookahead token.  */
  yyn = yypact[yystate];
  if (yypact_value_is_default (yyn))
    goto yydefault;

  /* Not known => get a lookahead token if don't already have one.  */

  /* YYCHAR is either empty, or end-of-input, or a valid lookahead.  */
  if (yychar == YYEMPTY)
    {
      YYDPRINTF ((stderr, "Reading a token\n"));
      yychar = yylex ();
    }

  if (yychar <= END)
    {
      yychar = END;
      yytoken = YYSYMBOL_YYEOF;
      YYDPRINTF ((stderr, "Now at end of input.\n"));
    }
  else if (yychar == YYerror)
    {
      /* The scanner already issued an error message, process directly
         to error recovery.  But do not keep the error token as
         lookahead, it is too special and may lead us to an endless
         loop in error recovery. */
      yychar = YYUNDEF;
      yytoken = YYSYMBOL_YYerror;
      goto yyerrlab1;
    }
  else
    {
      yytoken = YYTRANSLATE (yychar);
      YY_SYMBOL_PRINT ("Next token is", yytoken, &yylval, &yylloc);
    }

  /* If the proper action on seeing token YYTOKEN is to reduce or to
     detect an error, take that action.  */
  yyn += yytoken;
  if (yyn < 0 || YYLAST < yyn || yycheck[yyn] != yytoken)
    goto yydefault;
  yyn = yytable[yyn];
  if (yyn <= 0)
    {
      if (yytable_value_is_error (yyn))
        goto yyerrlab;
      yyn = -yyn;
      goto yyreduce;
    }

  /* Count tokens shifted since error; after three, turn off error
     status.  */
  if (yyerrstatus)
    yyerrstatus--;

  /* Shift the lookahead token.  */
  YY_SYMBOL_PRINT ("Shifting", yytoken, &yylval, &yylloc);
  yystate = yyn;
  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  *++yyvsp = yylval;
  YY_IGNORE_MAYBE_UNINITIALIZED_END

  /* Discard the shifted token.  */
  yychar = YYEMPTY;
  goto yynewstate;


/*-----------------------------------------------------------.
| yydefault -- do the default action for the current state.  |
`-----------------------------------------------------------*/
yydefault:
  yyn = yydefact[yystate];
  if (yyn == 0)
    goto yyerrlab;
  goto yyreduce;


/*-----------------------------.
| yyreduce -- do a reduction.  |
`-----------------------------*/
yyreduce:
  /* yyn is the number of a rule to reduce with.  */
  yylen = yyr2[yyn];

  /* If YYLEN is nonzero, implement the default value of the action:
     '$$ = $1'.

     Otherwise, the following line sets YYVAL to garbage.
     This behavior is undocumented and Bison
     users should not rely upon it.  Assigning to YYVAL
     unconditionally makes the parser a bit smaller, and it avoids a
     GCC warning that YYVAL may be used uninitialized.  */
  yyval = yyvsp[1-yylen];


  YY_REDUCE_PRINT (yyn);
  switch (yyn)
    {
  case 2: /* program: interface  */
#line 2249 "CParse/parser.y"
                            {
                   if (!classes) classes = NewHash();
		   Setattr((yyvsp[0].node),"classes",classes); 
		   Setattr((yyvsp[0].node),"name",ModuleName);
		   
		   if ((!module_node) && ModuleName) {
		     module_node = new_node("module");
		     Setattr(module_node,"name",ModuleName);
		   }
		   Setattr((yyvsp[0].node),"module",module_node);
	           top = (yyvsp[0].node);
               }
#line 5898 "CParse/parser.c"
    break;

  case 3: /* program: PARSETYPE parm END  */
#line 2261 "CParse/parser.y"
                                    {
                 top = Copy(Getattr((yyvsp[-1].p),"type"));
		 Delete((yyvsp[-1].p));
               }
#line 5907 "CParse/parser.c"
    break;

  case 4: /* program: PARSETYPE error  */
#line 2265 "CParse/parser.y"
                                 {
                 top = 0;
               }
#line 5915 "CParse/parser.c"
    break;

  case 5: /* program: PARSEPARM parm END  */
#line 2268 "CParse/parser.y"
                                    {
                 top = (yyvsp[-1].p);
               }
#line 5923 "CParse/parser.c"
    break;

  case 6: /* program: PARSEPARM error  */
#line 2271 "CParse/parser.y"
                                 {
                 top = 0;
               }
#line 5931 "CParse/parser.c"
    break;

  case 7: /* program: PARSEPARMS LPAREN parms RPAREN END  */
#line 2274 "CParse/parser.y"
                                                    {
                 top = (yyvsp[-2].pl);
               }
#line 5939 "CParse/parser.c"
    break;

  case 8: /* program: PARSEPARMS error  */
#line 2277 "CParse/parser.y"
                                  {
                 top = 0;
               }
#line 5947 "CParse/parser.c"
    break;

  case 9: /* interface: interface declaration  */
#line 2282 "CParse/parser.y"
                                           {  
                   /* add declaration to end of linked list (the declaration isn't always a single declaration, sometimes it is a linked list itself) */
                   if (currentDeclComment != NULL) {
		     set_comment((yyvsp[0].node), currentDeclComment);
		     currentDeclComment = NULL;
                   }                                      
                   appendChild((yyvsp[-1].node),(yyvsp[0].node));
                   (yyval.node) = (yyvsp[-1].node);
               }
#line 5961 "CParse/parser.c"
    break;

  case 10: /* interface: interface DOXYGENSTRING  */
#line 2291 "CParse/parser.y"
                                             {
		   Delete(currentDeclComment);
                   currentDeclComment = (yyvsp[0].str); 
                   (yyval.node) = (yyvsp[-1].node);
               }
#line 5971 "CParse/parser.c"
    break;

  case 11: /* interface: interface DOXYGENPOSTSTRING  */
#line 2296 "CParse/parser.y"
                                                 {
                   Node *node = lastChild((yyvsp[-1].node));
                   if (node) {
                     set_comment(node, (yyvsp[0].str));
		   } else {
		     Delete((yyvsp[0].str));
		   }
                   (yyval.node) = (yyvsp[-1].node);
               }
#line 5985 "CParse/parser.c"
    break;

  case 12: /* interface: %empty  */
#line 2305 "CParse/parser.y"
                        {
                   (yyval.node) = new_node("top");
               }
#line 5993 "CParse/parser.c"
    break;

  case 16: /* declaration: SEMI  */
#line 2313 "CParse/parser.y"
                      { (yyval.node) = 0; }
#line 5999 "CParse/parser.c"
    break;

  case 17: /* declaration: error  */
#line 2314 "CParse/parser.y"
                       {
		  if (cparse_unknown_directive) {
		      Swig_error(cparse_file, cparse_line, "Unknown directive '%s'.\n", cparse_unknown_directive);
		  } else {
		      Swig_error(cparse_file, cparse_line, "Syntax error in input(1).\n");
		  }
		  Exit(EXIT_FAILURE);
               }
#line 6012 "CParse/parser.c"
    break;

  case 18: /* declaration: c_constructor_decl  */
#line 2323 "CParse/parser.y"
                                    { 
                  if ((yyval.node)) {
   		      add_symbols((yyval.node));
                  }
                  (yyval.node) = (yyvsp[0].node); 
	       }
#line 6023 "CParse/parser.c"
    break;

  case 19: /* declaration: error CONVERSIONOPERATOR  */
#line 2339 "CParse/parser.y"
                                          {
                  (yyval.node) = 0;
		  Delete((yyvsp[0].str));
                  skip_decl();
               }
#line 6033 "CParse/parser.c"
    break;

  case 39: /* $@1: %empty  */
#line 2375 "CParse/parser.y"
                                                             {
               Node *cls;
	       String *clsname;
	       extendmode = 1;
	       cplus_mode = CPLUS_PUBLIC;
	       if (!classes) classes = NewHash();
	       if (!classes_typedefs) classes_typedefs = NewHash();
	       clsname = make_class_name((yyvsp[-1].str));
	       cls = Getattr(classes,clsname);
	       if (!cls) {
	         cls = Getattr(classes_typedefs, clsname);
		 if (!cls) {
		   /* No previous definition. Create a new scope */
		   Node *am = Getattr(Swig_extend_hash(),clsname);
		   if (!am) {
		     Swig_symbol_newscope();
		     Swig_symbol_setscopename((yyvsp[-1].str));
		     prev_symtab = 0;
		   } else {
		     prev_symtab = Swig_symbol_setscope(Getattr(am,"symtab"));
		   }
		   current_class = 0;
		 } else {
		   /* Previous typedef class definition.  Use its symbol table.
		      Deprecated, just the real name should be used. 
		      Note that %extend before the class typedef never worked, only %extend after the class typedef. */
		   prev_symtab = Swig_symbol_setscope(Getattr(cls, "symtab"));
		   current_class = cls;
		   SWIG_WARN_NODE_BEGIN(cls);
		   Swig_warning(WARN_PARSE_EXTEND_NAME, cparse_file, cparse_line, "Deprecated %%extend name used - the %s name '%s' should be used instead of the typedef name '%s'.\n", Getattr(cls, "kind"), SwigType_namestr(Getattr(cls, "name")), (yyvsp[-1].str));
		   SWIG_WARN_NODE_END(cls);
		 }
	       } else {
		 /* Previous class definition.  Use its symbol table */
		 prev_symtab = Swig_symbol_setscope(Getattr(cls,"symtab"));
		 current_class = cls;
	       }
	       Classprefix = NewString((yyvsp[-1].str));
	       Namespaceprefix= Swig_symbol_qualifiedscopename(0);
	       Delete(clsname);
	     }
#line 6079 "CParse/parser.c"
    break;

  case 40: /* extend_directive: EXTEND options classkeyopt idcolon LBRACE $@1 cpp_members RBRACE  */
#line 2415 "CParse/parser.y"
                                  {
               String *clsname;
	       extendmode = 0;
               (yyval.node) = new_node("extend");
	       Setattr((yyval.node),"symtab",Swig_symbol_popscope());
	       if (prev_symtab) {
		 Swig_symbol_setscope(prev_symtab);
	       }
	       Namespaceprefix = Swig_symbol_qualifiedscopename(0);
               clsname = make_class_name((yyvsp[-4].str));
	       Setattr((yyval.node),"name",clsname);

	       mark_nodes_as_extend((yyvsp[-1].node));
	       if (current_class) {
		 /* We add the extension to the previously defined class */
		 appendChild((yyval.node), (yyvsp[-1].node));
		 appendChild(current_class,(yyval.node));
	       } else {
		 /* We store the extensions in the extensions hash */
		 Node *am = Getattr(Swig_extend_hash(),clsname);
		 if (am) {
		   /* Append the members to the previous extend methods */
		   appendChild(am, (yyvsp[-1].node));
		 } else {
		   appendChild((yyval.node), (yyvsp[-1].node));
		   Setattr(Swig_extend_hash(),clsname,(yyval.node));
		 }
	       }
	       current_class = 0;
	       Delete(Classprefix);
	       Delete(clsname);
	       Classprefix = 0;
	       prev_symtab = 0;
	       (yyval.node) = 0;

	     }
#line 6120 "CParse/parser.c"
    break;

  case 41: /* apply_directive: APPLY typemap_parm LBRACE tm_list RBRACE  */
#line 2457 "CParse/parser.y"
                                                           {
                    (yyval.node) = new_node("apply");
                    Setattr((yyval.node),"pattern",Getattr((yyvsp[-3].p),"pattern"));
		    appendChild((yyval.node),(yyvsp[-1].p));
               }
#line 6130 "CParse/parser.c"
    break;

  case 42: /* clear_directive: CLEAR tm_list SEMI  */
#line 2467 "CParse/parser.y"
                                     {
		 (yyval.node) = new_node("clear");
		 appendChild((yyval.node),(yyvsp[-1].p));
               }
#line 6139 "CParse/parser.c"
    break;

  case 43: /* constant_directive: CONSTANT identifier EQUAL definetype SEMI  */
#line 2481 "CParse/parser.y"
                                                                {
		 SwigType *type = NewSwigType((yyvsp[-1].dtype).type);
		 if (Len(type) > 0) {
		   (yyval.node) = new_node("constant");
		   Setattr((yyval.node), "name", (yyvsp[-3].id));
		   Setattr((yyval.node), "type", type);
		   Setattr((yyval.node), "value", (yyvsp[-1].dtype).val);
		   if ((yyvsp[-1].dtype).stringval) Setattr((yyval.node), "stringval", (yyvsp[-1].dtype).stringval);
		   if ((yyvsp[-1].dtype).numval) Setattr((yyval.node), "numval", (yyvsp[-1].dtype).numval);
		   Setattr((yyval.node), "storage", "%constant");
		   SetFlag((yyval.node), "feature:immutable");
		   add_symbols((yyval.node));
		   Delete(type);
		 } else {
		   Swig_warning(WARN_PARSE_UNSUPPORTED_VALUE, cparse_file, cparse_line, "Unsupported constant value (ignored)\n");
		   (yyval.node) = 0;
		 }
	       }
#line 6162 "CParse/parser.c"
    break;

  case 44: /* constant_directive: CONSTANT type declarator def_args SEMI  */
#line 2499 "CParse/parser.y"
                                                        {
		 SwigType_push((yyvsp[-3].type), (yyvsp[-2].decl).type);
		 /* Sneaky callback function trick */
		 if (SwigType_isfunction((yyvsp[-3].type))) {
		   SwigType_add_pointer((yyvsp[-3].type));
		 }
		 (yyval.node) = new_node("constant");
		 Setattr((yyval.node), "name", (yyvsp[-2].decl).id);
		 Setattr((yyval.node), "type", (yyvsp[-3].type));
		 Setattr((yyval.node), "value", (yyvsp[-1].dtype).val);
		 if ((yyvsp[-1].dtype).stringval) Setattr((yyval.node), "stringval", (yyvsp[-1].dtype).stringval);
		 if ((yyvsp[-1].dtype).numval) Setattr((yyval.node), "numval", (yyvsp[-1].dtype).numval);
		 Setattr((yyval.node), "storage", "%constant");
		 SetFlag((yyval.node), "feature:immutable");
		 add_symbols((yyval.node));
               }
#line 6183 "CParse/parser.c"
    break;

  case 45: /* constant_directive: CONSTANT type direct_declarator LPAREN parms RPAREN cv_ref_qualifier def_args SEMI  */
#line 2517 "CParse/parser.y"
                                                                                                    {
		 SwigType_add_function((yyvsp[-7].type), (yyvsp[-4].pl));
		 SwigType_push((yyvsp[-7].type), (yyvsp[-2].dtype).qualifier);
		 SwigType_push((yyvsp[-7].type), (yyvsp[-6].decl).type);
		 /* Sneaky callback function trick */
		 if (SwigType_isfunction((yyvsp[-7].type))) {
		   SwigType_add_pointer((yyvsp[-7].type));
		 }
		 (yyval.node) = new_node("constant");
		 Setattr((yyval.node), "name", (yyvsp[-6].decl).id);
		 Setattr((yyval.node), "type", (yyvsp[-7].type));
		 Setattr((yyval.node), "value", (yyvsp[-1].dtype).val);
		 if ((yyvsp[-1].dtype).stringval) Setattr((yyval.node), "stringval", (yyvsp[-1].dtype).stringval);
		 if ((yyvsp[-1].dtype).numval) Setattr((yyval.node), "numval", (yyvsp[-1].dtype).numval);
		 Setattr((yyval.node), "storage", "%constant");
		 SetFlag((yyval.node), "feature:immutable");
		 add_symbols((yyval.node));
	       }
#line 6206 "CParse/parser.c"
    break;

  case 46: /* constant_directive: CONSTANT error SEMI  */
#line 2535 "CParse/parser.y"
                                     {
		 Swig_warning(WARN_PARSE_BAD_VALUE,cparse_file,cparse_line,"Bad constant value (ignored).\n");
		 (yyval.node) = 0;
	       }
#line 6215 "CParse/parser.c"
    break;

  case 47: /* constant_directive: CONSTANT error END  */
#line 2539 "CParse/parser.y"
                                    {
		 Swig_error(cparse_file,cparse_line,"Missing semicolon (';') after %%constant.\n");
		 Exit(EXIT_FAILURE);
	       }
#line 6224 "CParse/parser.c"
    break;

  case 48: /* echo_directive: ECHO HBLOCK  */
#line 2550 "CParse/parser.y"
                             {
		 char temp[64];
		 Replace((yyvsp[0].str),"$file",cparse_file, DOH_REPLACE_ANY);
		 snprintf(temp, sizeof(temp),"%d", cparse_line);
		 Replace((yyvsp[0].str),"$line",temp,DOH_REPLACE_ANY);
		 Printf(stderr,"%s\n", (yyvsp[0].str));
		 Delete((yyvsp[0].str));
                 (yyval.node) = 0;
	       }
#line 6238 "CParse/parser.c"
    break;

  case 49: /* echo_directive: ECHO string  */
#line 2559 "CParse/parser.y"
                             {
		 char temp[64];
		 String *s = (yyvsp[0].str);
		 Replace(s,"$file",cparse_file, DOH_REPLACE_ANY);
		 snprintf(temp, sizeof(temp),"%d", cparse_line);
		 Replace(s,"$line",temp,DOH_REPLACE_ANY);
		 Printf(stderr,"%s\n", s);
		 Delete(s);
                 (yyval.node) = 0;
               }
#line 6253 "CParse/parser.c"
    break;

  case 50: /* stringtype: string LBRACE parm RBRACE  */
#line 2572 "CParse/parser.y"
                                          {		 
                 (yyval.node) = NewHash();
                 Setattr((yyval.node),"value",(yyvsp[-3].str));
		 Setattr((yyval.node),"type",Getattr((yyvsp[-1].p),"type"));
               }
#line 6263 "CParse/parser.c"
    break;

  case 51: /* fname: string  */
#line 2579 "CParse/parser.y"
                       {
                 (yyval.node) = NewHash();
                 Setattr((yyval.node),"value",(yyvsp[0].str));
              }
#line 6272 "CParse/parser.c"
    break;

  case 53: /* fragment_directive: FRAGMENT LPAREN fname COMMA kwargs RPAREN HBLOCK  */
#line 2594 "CParse/parser.y"
                                                                     {
                   Hash *p = (yyvsp[-2].node);
		   (yyval.node) = new_node("fragment");
		   Setattr((yyval.node),"value",Getattr((yyvsp[-4].node),"value"));
		   Setattr((yyval.node),"type",Getattr((yyvsp[-4].node),"type"));
		   Setattr((yyval.node),"section",Getattr(p,"name"));
		   Setattr((yyval.node),"kwargs",nextSibling(p));
		   Setattr((yyval.node),"code",(yyvsp[0].str));
		   Delete((yyvsp[0].str));
                 }
#line 6287 "CParse/parser.c"
    break;

  case 54: /* fragment_directive: FRAGMENT LPAREN fname COMMA kwargs RPAREN LBRACE  */
#line 2604 "CParse/parser.y"
                                                                    {
		   Hash *p = (yyvsp[-2].node);
		   String *code;
		   if (skip_balanced('{','}') < 0) Exit(EXIT_FAILURE);
		   (yyval.node) = new_node("fragment");
		   Setattr((yyval.node),"value",Getattr((yyvsp[-4].node),"value"));
		   Setattr((yyval.node),"type",Getattr((yyvsp[-4].node),"type"));
		   Setattr((yyval.node),"section",Getattr(p,"name"));
		   Setattr((yyval.node),"kwargs",nextSibling(p));
		   Delitem(scanner_ccode,0);
		   Delitem(scanner_ccode,DOH_END);
		   code = Copy(scanner_ccode);
		   Setattr((yyval.node),"code",code);
		   Delete(code);
                 }
#line 6307 "CParse/parser.c"
    break;

  case 55: /* fragment_directive: FRAGMENT LPAREN fname RPAREN SEMI  */
#line 2619 "CParse/parser.y"
                                                     {
		   (yyval.node) = new_node("fragment");
		   Setattr((yyval.node),"value",Getattr((yyvsp[-2].node),"value"));
		   Setattr((yyval.node),"type",Getattr((yyvsp[-2].node),"type"));
		   Setattr((yyval.node),"emitonly","1");
		 }
#line 6318 "CParse/parser.c"
    break;

  case 56: /* @2: %empty  */
#line 2632 "CParse/parser.y"
                                                             {
		     (yyval.loc).filename = Copy(cparse_file);
		     (yyval.loc).line = cparse_line;
		     scanner_set_location((yyvsp[-1].str),1);
                     if ((yyvsp[-2].node)) { 
		       String *maininput = Getattr((yyvsp[-2].node), "maininput");
		       if (maininput)
		         scanner_set_main_input_file(NewString(maininput));
		     }
               }
#line 6333 "CParse/parser.c"
    break;

  case 57: /* include_directive: includetype options string BEGINFILE @2 interface ENDOFFILE  */
#line 2641 "CParse/parser.y"
                                          {
                     String *mname = 0;
                     (yyval.node) = (yyvsp[-1].node);
		     scanner_set_location((yyvsp[-2].loc).filename, (yyvsp[-2].loc).line + 1);
		     Delete((yyvsp[-2].loc).filename);
		     switch ((yyvsp[-6].includetype)) {
		       case INCLUDE_INCLUDE:
			 set_nodeType((yyval.node), "include");
			 break;
		       case INCLUDE_IMPORT:
			 mname = (yyvsp[-5].node) ? Getattr((yyvsp[-5].node), "module") : 0;
			 set_nodeType((yyval.node), "import");
			 if (import_mode) --import_mode;
			 break;
		     }
		     
		     Setattr((yyval.node),"name",(yyvsp[-4].str));
		     /* Search for the module (if any) */
		     {
			 Node *n = firstChild((yyval.node));
			 while (n) {
			     if (Strcmp(nodeType(n),"module") == 0) {
			         if (mname) {
				   Setattr(n,"name", mname);
				   mname = 0;
				 }
				 Setattr((yyval.node),"module",Getattr(n,"name"));
				 break;
			     }
			     n = nextSibling(n);
			 }
			 if (mname) {
			   /* There is no module node in the import
			      node, ie, you imported a .h file
			      directly.  We are forced then to create
			      a new import node with a module node.
			   */			      
			   Node *nint = new_node("import");
			   Node *mnode = new_node("module");
			   Setattr(mnode,"name", mname);
                           Setattr(mnode,"options",(yyvsp[-5].node));
			   appendChild(nint,mnode);
			   Delete(mnode);
			   appendChild(nint,firstChild((yyval.node)));
			   (yyval.node) = nint;
			   Setattr((yyval.node),"module",mname);
			 }
		     }
		     Setattr((yyval.node),"options",(yyvsp[-5].node));
               }
#line 6388 "CParse/parser.c"
    break;

  case 58: /* includetype: INCLUDE  */
#line 2693 "CParse/parser.y"
                         { (yyval.includetype) = INCLUDE_INCLUDE; }
#line 6394 "CParse/parser.c"
    break;

  case 59: /* includetype: IMPORT  */
#line 2694 "CParse/parser.y"
                         { (yyval.includetype) = INCLUDE_IMPORT; ++import_mode;}
#line 6400 "CParse/parser.c"
    break;

  case 60: /* inline_directive: INLINE HBLOCK  */
#line 2701 "CParse/parser.y"
                                 {
                 String *cpps;
		 if (Namespaceprefix) {
		   Swig_error(cparse_file, cparse_start_line, "%%inline directive inside a namespace is disallowed.\n");
		   (yyval.node) = 0;
		 } else {
		   (yyval.node) = new_node("insert");
		   Setattr((yyval.node),"code",(yyvsp[0].str));
		   /* Need to run through the preprocessor */
		   Seek((yyvsp[0].str),0,SEEK_SET);
		   Setline((yyvsp[0].str),cparse_start_line);
		   Setfile((yyvsp[0].str),cparse_file);
		   cpps = Preprocessor_parse((yyvsp[0].str));
		   scanner_start_inline(cpps, cparse_start_line);
		   Delete(cpps);
		 }
		 Delete((yyvsp[0].str));
	       }
#line 6423 "CParse/parser.c"
    break;

  case 61: /* inline_directive: INLINE LBRACE  */
#line 2719 "CParse/parser.y"
                               {
                 String *cpps;
		 int start_line = cparse_line;
		 if (Namespaceprefix) {
		   Swig_error(cparse_file, cparse_start_line, "%%inline directive inside a namespace is disallowed.\n");
		 }
		 if (skip_balanced('{','}') < 0) Exit(EXIT_FAILURE);
		 if (Namespaceprefix) {
		   (yyval.node) = 0;
		 } else {
		   String *code;
                   (yyval.node) = new_node("insert");
		   Delitem(scanner_ccode,0);
		   Delitem(scanner_ccode,DOH_END);
		   code = Copy(scanner_ccode);
		   Setattr((yyval.node),"code", code);
		   Delete(code);		   
		   cpps=Copy(scanner_ccode);
		   scanner_start_inline(cpps, start_line);
		   Delete(cpps);
		 }
               }
#line 6450 "CParse/parser.c"
    break;

  case 62: /* insert_directive: HBLOCK  */
#line 2753 "CParse/parser.y"
                          {
                 (yyval.node) = new_node("insert");
		 Setattr((yyval.node),"code",(yyvsp[0].str));
		 Delete((yyvsp[0].str));
	       }
#line 6460 "CParse/parser.c"
    break;

  case 63: /* insert_directive: INSERT LPAREN idstring RPAREN string  */
#line 2758 "CParse/parser.y"
                                                      {
		 String *code = NewStringEmpty();
		 (yyval.node) = new_node("insert");
		 Setattr((yyval.node),"section",(yyvsp[-2].id));
		 Setattr((yyval.node),"code",code);
		 if (Swig_insert_file((yyvsp[0].str),code) < 0) {
		   Swig_error(cparse_file, cparse_line, "Couldn't find '%s'.\n", (yyvsp[0].str));
		   (yyval.node) = 0;
		 } 
               }
#line 6475 "CParse/parser.c"
    break;

  case 64: /* insert_directive: INSERT LPAREN idstring RPAREN HBLOCK  */
#line 2768 "CParse/parser.y"
                                                      {
		 (yyval.node) = new_node("insert");
		 Setattr((yyval.node),"section",(yyvsp[-2].id));
		 Setattr((yyval.node),"code",(yyvsp[0].str));
		 Delete((yyvsp[0].str));
               }
#line 6486 "CParse/parser.c"
    break;

  case 65: /* insert_directive: INSERT LPAREN idstring RPAREN LBRACE  */
#line 2774 "CParse/parser.y"
                                                      {
		 String *code;
		 if (skip_balanced('{','}') < 0) Exit(EXIT_FAILURE);
		 (yyval.node) = new_node("insert");
		 Setattr((yyval.node),"section",(yyvsp[-2].id));
		 Delitem(scanner_ccode,0);
		 Delitem(scanner_ccode,DOH_END);
		 code = Copy(scanner_ccode);
		 Setattr((yyval.node),"code", code);
		 Delete(code);
	       }
#line 6502 "CParse/parser.c"
    break;

  case 66: /* module_directive: MODULE options idstring  */
#line 2792 "CParse/parser.y"
                                          {
                 (yyval.node) = new_node("module");
		 if ((yyvsp[-1].node)) {
		   Setattr((yyval.node),"options",(yyvsp[-1].node));
		   if (Getattr((yyvsp[-1].node),"directors")) {
		     Wrapper_director_mode_set(1);
		     if (!cparse_cplusplus) {
		       Swig_error(cparse_file, cparse_line, "Directors are not supported for C code and require the -c++ option\n");
		     }
		   } 
		   if (Getattr((yyvsp[-1].node),"dirprot")) {
		     Wrapper_director_protected_mode_set(1);
		   } 
		   if (Getattr((yyvsp[-1].node),"allprotected")) {
		     Wrapper_all_protected_mode_set(1);
		   } 
		   if (Getattr((yyvsp[-1].node),"templatereduce")) {
		     template_reduce = 1;
		   }
		   if (Getattr((yyvsp[-1].node),"notemplatereduce")) {
		     template_reduce = 0;
		   }
		 }
		 if (!ModuleName) ModuleName = NewString((yyvsp[0].id));
		 if (!import_mode) {
		   /* first module included, we apply global
		      ModuleName, which can be modify by -module */
		   String *mname = Copy(ModuleName);
		   Setattr((yyval.node),"name",mname);
		   Delete(mname);
		 } else { 
		   /* import mode, we just pass the idstring */
		   Setattr((yyval.node),"name",(yyvsp[0].id));   
		 }		 
		 if (!module_node) module_node = (yyval.node);
	       }
#line 6543 "CParse/parser.c"
    break;

  case 67: /* native_directive: NATIVE LPAREN identifier RPAREN storage_class identifier SEMI  */
#line 2835 "CParse/parser.y"
                                                                                                  {
                 (yyval.node) = new_node("native");
		 Setattr((yyval.node),"name",(yyvsp[-4].id));
		 Setattr((yyval.node),"wrap:name",(yyvsp[-1].id));
		 Delete((yyvsp[-2].str));
	         add_symbols((yyval.node));
	       }
#line 6555 "CParse/parser.c"
    break;

  case 68: /* native_directive: NATIVE LPAREN identifier RPAREN storage_class type declarator SEMI  */
#line 2842 "CParse/parser.y"
                                                                                    {
		 if (!SwigType_isfunction((yyvsp[-1].decl).type)) {
		   Swig_error(cparse_file,cparse_line,"%%native declaration '%s' is not a function.\n", (yyvsp[-1].decl).id);
		   (yyval.node) = 0;
		 } else {
		     Delete(SwigType_pop_function((yyvsp[-1].decl).type));
		     /* Need check for function here */
		     SwigType_push((yyvsp[-2].type),(yyvsp[-1].decl).type);
		     (yyval.node) = new_node("native");
	             Setattr((yyval.node),"name",(yyvsp[-5].id));
		     Setattr((yyval.node),"wrap:name",(yyvsp[-1].decl).id);
		     Setattr((yyval.node),"type",(yyvsp[-2].type));
		     Setattr((yyval.node),"parms",(yyvsp[-1].decl).parms);
		     Setattr((yyval.node),"decl",(yyvsp[-1].decl).type);
		 }
		 Delete((yyvsp[-3].str));
	         add_symbols((yyval.node));
	       }
#line 6578 "CParse/parser.c"
    break;

  case 69: /* pragma_directive: PRAGMA pragma_lang identifier EQUAL pragma_arg  */
#line 2869 "CParse/parser.y"
                                                                  {
                 (yyval.node) = new_node("pragma");
		 Setattr((yyval.node),"lang",(yyvsp[-3].id));
		 Setattr((yyval.node),"name",(yyvsp[-2].id));
		 Setattr((yyval.node),"value",(yyvsp[0].str));
	       }
#line 6589 "CParse/parser.c"
    break;

  case 70: /* pragma_directive: PRAGMA pragma_lang identifier  */
#line 2875 "CParse/parser.y"
                                              {
		(yyval.node) = new_node("pragma");
		Setattr((yyval.node),"lang",(yyvsp[-1].id));
		Setattr((yyval.node),"name",(yyvsp[0].id));
	      }
#line 6599 "CParse/parser.c"
    break;

  case 73: /* pragma_lang: LPAREN identifier RPAREN  */
#line 2886 "CParse/parser.y"
                                         { (yyval.id) = (yyvsp[-1].id); }
#line 6605 "CParse/parser.c"
    break;

  case 74: /* pragma_lang: %empty  */
#line 2887 "CParse/parser.y"
                       { (yyval.id) = "swig"; }
#line 6611 "CParse/parser.c"
    break;

  case 75: /* rename_directive: rename_namewarn declarator idstring SEMI  */
#line 2894 "CParse/parser.y"
                                                            {
                SwigType *t = (yyvsp[-2].decl).type;
		Hash *kws = NewHash();
		String *fixname;
		fixname = feature_identifier_fix((yyvsp[-2].decl).id);
		Setattr(kws,"name",(yyvsp[-1].id));
		if (!Len(t)) t = 0;
		/* Special declarator check */
		if (t) {
		  if (SwigType_isfunction(t)) {
		    SwigType *decl = SwigType_pop_function(t);
		    if (SwigType_ispointer(t)) {
		      String *nname = NewStringf("*%s",fixname);
		      if ((yyvsp[-3].intvalue)) {
			Swig_name_rename_add(Namespaceprefix, nname,decl,kws,(yyvsp[-2].decl).parms);
		      } else {
			Swig_name_namewarn_add(Namespaceprefix,nname,decl,kws);
		      }
		      Delete(nname);
		    } else {
		      if ((yyvsp[-3].intvalue)) {
			Swig_name_rename_add(Namespaceprefix,(fixname),decl,kws,(yyvsp[-2].decl).parms);
		      } else {
			Swig_name_namewarn_add(Namespaceprefix,(fixname),decl,kws);
		      }
		    }
		    Delete(decl);
		  } else if (SwigType_ispointer(t)) {
		    String *nname = NewStringf("*%s",fixname);
		    if ((yyvsp[-3].intvalue)) {
		      Swig_name_rename_add(Namespaceprefix,(nname),0,kws,(yyvsp[-2].decl).parms);
		    } else {
		      Swig_name_namewarn_add(Namespaceprefix,(nname),0,kws);
		    }
		    Delete(nname);
		  }
		} else {
		  if ((yyvsp[-3].intvalue)) {
		    Swig_name_rename_add(Namespaceprefix,(fixname),0,kws,(yyvsp[-2].decl).parms);
		  } else {
		    Swig_name_namewarn_add(Namespaceprefix,(fixname),0,kws);
		  }
		}
                (yyval.node) = 0;
		scanner_clear_rename();
              }
#line 6662 "CParse/parser.c"
    break;

  case 76: /* rename_directive: rename_namewarn LPAREN kwargs RPAREN declarator cpp_const SEMI  */
#line 2940 "CParse/parser.y"
                                                                               {
		String *fixname;
		Hash *kws = (yyvsp[-4].node);
		SwigType *t = (yyvsp[-2].decl).type;
		fixname = feature_identifier_fix((yyvsp[-2].decl).id);
		if (!Len(t)) t = 0;
		/* Special declarator check */
		if (t) {
		  if ((yyvsp[-1].dtype).qualifier) SwigType_push(t,(yyvsp[-1].dtype).qualifier);
		  if (SwigType_isfunction(t)) {
		    SwigType *decl = SwigType_pop_function(t);
		    if (SwigType_ispointer(t)) {
		      String *nname = NewStringf("*%s",fixname);
		      if ((yyvsp[-6].intvalue)) {
			Swig_name_rename_add(Namespaceprefix, nname,decl,kws,(yyvsp[-2].decl).parms);
		      } else {
			Swig_name_namewarn_add(Namespaceprefix,nname,decl,kws);
		      }
		      Delete(nname);
		    } else {
		      if ((yyvsp[-6].intvalue)) {
			Swig_name_rename_add(Namespaceprefix,(fixname),decl,kws,(yyvsp[-2].decl).parms);
		      } else {
			Swig_name_namewarn_add(Namespaceprefix,(fixname),decl,kws);
		      }
		    }
		    Delete(decl);
		  } else if (SwigType_ispointer(t)) {
		    String *nname = NewStringf("*%s",fixname);
		    if ((yyvsp[-6].intvalue)) {
		      Swig_name_rename_add(Namespaceprefix,(nname),0,kws,(yyvsp[-2].decl).parms);
		    } else {
		      Swig_name_namewarn_add(Namespaceprefix,(nname),0,kws);
		    }
		    Delete(nname);
		  }
		} else {
		  if ((yyvsp[-6].intvalue)) {
		    Swig_name_rename_add(Namespaceprefix,(fixname),0,kws,(yyvsp[-2].decl).parms);
		  } else {
		    Swig_name_namewarn_add(Namespaceprefix,(fixname),0,kws);
		  }
		}
                (yyval.node) = 0;
		scanner_clear_rename();
              }
#line 6713 "CParse/parser.c"
    break;

  case 77: /* rename_directive: rename_namewarn LPAREN kwargs RPAREN string SEMI  */
#line 2986 "CParse/parser.y"
                                                                 {
		if ((yyvsp[-5].intvalue)) {
		  Swig_name_rename_add(Namespaceprefix,(yyvsp[-1].str),0,(yyvsp[-3].node),0);
		} else {
		  Swig_name_namewarn_add(Namespaceprefix,(yyvsp[-1].str),0,(yyvsp[-3].node));
		}
		(yyval.node) = 0;
		scanner_clear_rename();
              }
#line 6727 "CParse/parser.c"
    break;

  case 78: /* rename_namewarn: RENAME  */
#line 2997 "CParse/parser.y"
                         {
		    (yyval.intvalue) = 1;
                }
#line 6735 "CParse/parser.c"
    break;

  case 79: /* rename_namewarn: NAMEWARN  */
#line 3000 "CParse/parser.y"
                           {
                    (yyval.intvalue) = 0;
                }
#line 6743 "CParse/parser.c"
    break;

  case 80: /* feature_directive: FEATURE LPAREN idstring featattr RPAREN declarator cpp_const stringbracesemi  */
#line 3027 "CParse/parser.y"
                                                                                                 {
                    String *val = (yyvsp[0].str) ? NewString((yyvsp[0].str)) : NewString("1");
                    new_feature((yyvsp[-5].id), val, (yyvsp[-4].node), (yyvsp[-2].decl).id, (yyvsp[-2].decl).type, (yyvsp[-2].decl).parms, (yyvsp[-1].dtype).qualifier);
                    (yyval.node) = 0;
                    scanner_clear_rename();
                  }
#line 6754 "CParse/parser.c"
    break;

  case 81: /* feature_directive: FEATURE LPAREN idstring COMMA stringnum featattr RPAREN declarator cpp_const SEMI  */
#line 3033 "CParse/parser.y"
                                                                                                      {
                    String *val = Len((yyvsp[-5].str)) ? (yyvsp[-5].str) : 0;
                    new_feature((yyvsp[-7].id), val, (yyvsp[-4].node), (yyvsp[-2].decl).id, (yyvsp[-2].decl).type, (yyvsp[-2].decl).parms, (yyvsp[-1].dtype).qualifier);
                    (yyval.node) = 0;
                    scanner_clear_rename();
                  }
#line 6765 "CParse/parser.c"
    break;

  case 82: /* feature_directive: FEATURE LPAREN idstring featattr RPAREN stringbracesemi  */
#line 3041 "CParse/parser.y"
                                                                            {
                    String *val = (yyvsp[0].str) ? NewString((yyvsp[0].str)) : NewString("1");
                    new_feature((yyvsp[-3].id), val, (yyvsp[-2].node), 0, 0, 0, 0);
                    (yyval.node) = 0;
                    scanner_clear_rename();
                  }
#line 6776 "CParse/parser.c"
    break;

  case 83: /* feature_directive: FEATURE LPAREN idstring COMMA stringnum featattr RPAREN SEMI  */
#line 3047 "CParse/parser.y"
                                                                                 {
                    String *val = Len((yyvsp[-3].str)) ? (yyvsp[-3].str) : 0;
                    new_feature((yyvsp[-5].id), val, (yyvsp[-2].node), 0, 0, 0, 0);
                    (yyval.node) = 0;
                    scanner_clear_rename();
                  }
#line 6787 "CParse/parser.c"
    break;

  case 85: /* stringbracesemi: SEMI  */
#line 3056 "CParse/parser.y"
                       { (yyval.str) = 0; }
#line 6793 "CParse/parser.c"
    break;

  case 86: /* stringbracesemi: PARMS LPAREN parms RPAREN SEMI  */
#line 3057 "CParse/parser.y"
                                                 { (yyval.str) = (yyvsp[-2].pl); }
#line 6799 "CParse/parser.c"
    break;

  case 87: /* featattr: COMMA idstring EQUAL stringnum featattr  */
#line 3060 "CParse/parser.y"
                                                              {
		  (yyval.node) = NewHash();
		  Setattr((yyval.node),"name",(yyvsp[-3].id));
		  Setattr((yyval.node),"value",(yyvsp[-1].str));
		  if ((yyvsp[0].node)) set_nextSibling((yyval.node), (yyvsp[0].node));
		}
#line 6810 "CParse/parser.c"
    break;

  case 88: /* featattr: %empty  */
#line 3066 "CParse/parser.y"
                         {
		  (yyval.node) = 0;
		}
#line 6818 "CParse/parser.c"
    break;

  case 89: /* varargs_directive: VARARGS LPAREN varargs_parms RPAREN declarator cpp_const SEMI  */
#line 3073 "CParse/parser.y"
                                                                                  {
                 Parm *val;
		 String *name;
		 SwigType *t;
		 if (Namespaceprefix) name = NewStringf("%s::%s", Namespaceprefix, (yyvsp[-2].decl).id);
		 else name = NewString((yyvsp[-2].decl).id);
		 val = (yyvsp[-4].pl);
		 if ((yyvsp[-2].decl).parms) {
		   Setmeta(val,"parms",(yyvsp[-2].decl).parms);
		 }
		 t = (yyvsp[-2].decl).type;
		 if (!Len(t)) t = 0;
		 if (t) {
		   if ((yyvsp[-1].dtype).qualifier) SwigType_push(t,(yyvsp[-1].dtype).qualifier);
		   if (SwigType_isfunction(t)) {
		     SwigType *decl = SwigType_pop_function(t);
		     if (SwigType_ispointer(t)) {
		       String *nname = NewStringf("*%s",name);
		       Swig_feature_set(Swig_cparse_features(), nname, decl, "feature:varargs", val, 0);
		       Delete(nname);
		     } else {
		       Swig_feature_set(Swig_cparse_features(), name, decl, "feature:varargs", val, 0);
		     }
		     Delete(decl);
		   } else if (SwigType_ispointer(t)) {
		     String *nname = NewStringf("*%s",name);
		     Swig_feature_set(Swig_cparse_features(),nname,0,"feature:varargs",val, 0);
		     Delete(nname);
		   }
		 } else {
		   Swig_feature_set(Swig_cparse_features(),name,0,"feature:varargs",val, 0);
		 }
		 Delete(name);
		 (yyval.node) = 0;
              }
#line 6858 "CParse/parser.c"
    break;

  case 91: /* varargs_parms: NUM_INT COMMA parm  */
#line 3110 "CParse/parser.y"
                                     { 
		  int i;
		  int n;
		  Parm *p;
		  n = atoi(Char((yyvsp[-2].dtype).val));
		  if (n <= 0) {
		    Swig_error(cparse_file, cparse_line,"Argument count in %%varargs must be positive.\n");
		    (yyval.pl) = 0;
		  } else {
		    String *name = Getattr((yyvsp[0].p), "name");
		    (yyval.pl) = Copy((yyvsp[0].p));
		    if (name)
		      Setattr((yyval.pl), "name", NewStringf("%s%d", name, n));
		    for (i = 1; i < n; i++) {
		      p = Copy((yyvsp[0].p));
		      name = Getattr(p, "name");
		      if (name)
		        Setattr(p, "name", NewStringf("%s%d", name, n-i));
		      set_nextSibling(p,(yyval.pl));
		      Delete((yyval.pl));
		      (yyval.pl) = p;
		    }
		  }
                }
#line 6887 "CParse/parser.c"
    break;

  case 92: /* typemap_directive: TYPEMAP LPAREN typemap_type RPAREN tm_list stringbrace  */
#line 3144 "CParse/parser.y"
                                                                            {
		   (yyval.node) = 0;
		   if ((yyvsp[-3].tmap).method) {
		     String *code = 0;
		     (yyval.node) = new_node("typemap");
		     Setattr((yyval.node),"method",(yyvsp[-3].tmap).method);
		     if ((yyvsp[-3].tmap).kwargs) {
		       ParmList *kw = (yyvsp[-3].tmap).kwargs;
                       code = remove_block(kw, (yyvsp[0].str));
		       Setattr((yyval.node),"kwargs", (yyvsp[-3].tmap).kwargs);
		     }
		     code = code ? code : NewString((yyvsp[0].str));
		     Setattr((yyval.node),"code", code);
		     Delete(code);
		     appendChild((yyval.node),(yyvsp[-1].p));
		     Delete((yyvsp[-3].tmap).kwargs);
		     Delete((yyvsp[-3].tmap).method);
		   }
	       }
#line 6911 "CParse/parser.c"
    break;

  case 93: /* typemap_directive: TYPEMAP LPAREN typemap_type RPAREN tm_list SEMI  */
#line 3163 "CParse/parser.y"
                                                                 {
		 (yyval.node) = 0;
		 if ((yyvsp[-3].tmap).method) {
		   (yyval.node) = new_node("typemap");
		   Setattr((yyval.node),"method",(yyvsp[-3].tmap).method);
		   appendChild((yyval.node),(yyvsp[-1].p));
		   Delete((yyvsp[-3].tmap).method);
		 }
		 Delete((yyvsp[-3].tmap).kwargs);
	       }
#line 6926 "CParse/parser.c"
    break;

  case 94: /* typemap_directive: TYPEMAP LPAREN typemap_type RPAREN tm_list EQUAL typemap_parm SEMI  */
#line 3173 "CParse/parser.y"
                                                                                    {
		   (yyval.node) = 0;
		   if ((yyvsp[-5].tmap).method) {
		     (yyval.node) = new_node("typemapcopy");
		     Setattr((yyval.node),"method",(yyvsp[-5].tmap).method);
		     Setattr((yyval.node),"pattern", Getattr((yyvsp[-1].p),"pattern"));
		     appendChild((yyval.node),(yyvsp[-3].p));
		     Delete((yyvsp[-5].tmap).method);
		   }
		   Delete((yyvsp[-5].tmap).kwargs);
	       }
#line 6942 "CParse/parser.c"
    break;

  case 95: /* typemap_type: kwargs  */
#line 3188 "CParse/parser.y"
                        {
		 String *name = Getattr((yyvsp[0].node), "name");
		 Hash *p = nextSibling((yyvsp[0].node));
		 (yyval.tmap).method = name;
		 (yyval.tmap).kwargs = p;
		 if (Getattr((yyvsp[0].node), "value")) {
		   Swig_error(cparse_file, cparse_line,
			      "%%typemap method shouldn't have a value specified.\n");
		 }
		 while (p) {
		   if (!Getattr(p, "value")) {
		     Swig_error(cparse_file, cparse_line,
				"%%typemap attribute '%s' is missing its value.  If this is specifying the target language, that's no longer supported: use #ifdef SWIG<LANG> instead.\n",
				Getattr(p, "name"));
		     /* Set to empty value to avoid segfaults later. */
		     Setattr(p, "value", NewStringEmpty());
		   }
		   p = nextSibling(p);
		 }
                }
#line 6967 "CParse/parser.c"
    break;

  case 96: /* tm_list: tm_list_builder  */
#line 3210 "CParse/parser.y"
                                 {
		 (yyval.p) = (yyvsp[0].pbuilder).parms;
	       }
#line 6975 "CParse/parser.c"
    break;

  case 97: /* tm_list_builder: typemap_parm  */
#line 3215 "CParse/parser.y"
                              {
                 (yyval.pbuilder).parms = (yyval.pbuilder).last = (yyvsp[0].p);
	       }
#line 6983 "CParse/parser.c"
    break;

  case 98: /* tm_list_builder: tm_list_builder COMMA typemap_parm  */
#line 3218 "CParse/parser.y"
                                                        {
		 // Build a linked list in the order specified, but avoiding
		 // a right recursion rule because "Right recursion uses up
		 // space on the Bison stack in proportion to the number of
		 // elements in the sequence".
		 set_nextSibling((yyvsp[-2].pbuilder).last, (yyvsp[0].p));
		 (yyval.pbuilder).parms = (yyvsp[-2].pbuilder).parms;
		 (yyval.pbuilder).last = (yyvsp[0].p);
	       }
#line 6997 "CParse/parser.c"
    break;

  case 99: /* typemap_parm: type plain_declarator  */
#line 3229 "CParse/parser.y"
                                       {
                  Parm *parm;
		  SwigType_push((yyvsp[-1].type),(yyvsp[0].decl).type);
		  (yyval.p) = new_node("typemapitem");
		  parm = NewParmWithoutFileLineInfo((yyvsp[-1].type),(yyvsp[0].decl).id);
		  Setattr((yyval.p),"pattern",parm);
		  Setattr((yyval.p),"parms", (yyvsp[0].decl).parms);
		  Delete(parm);
		  /*		  $$ = NewParmWithoutFileLineInfo($type,$plain_declarator.id);
				  Setattr($$,"parms",$plain_declarator.parms); */
                }
#line 7013 "CParse/parser.c"
    break;

  case 100: /* typemap_parm: LPAREN parms RPAREN  */
#line 3240 "CParse/parser.y"
                                     {
                  (yyval.p) = new_node("typemapitem");
		  Setattr((yyval.p),"pattern",(yyvsp[-1].pl));
		  /*		  Setattr($$,"multitype",$parms); */
               }
#line 7023 "CParse/parser.c"
    break;

  case 101: /* typemap_parm: LPAREN parms RPAREN LPAREN parms RPAREN  */
#line 3245 "CParse/parser.y"
                                                                      {
		 (yyval.p) = new_node("typemapitem");
		 Setattr((yyval.p),"pattern", (yyvsp[-4].pl));
		 /*                 Setattr($$,"multitype",$in); */
		 Setattr((yyval.p),"parms",(yyvsp[-1].pl));
               }
#line 7034 "CParse/parser.c"
    break;

  case 102: /* types_directive: TYPES LPAREN parms RPAREN stringbracesemi  */
#line 3258 "CParse/parser.y"
                                                            {
                   (yyval.node) = new_node("types");
		   Setattr((yyval.node),"parms",(yyvsp[-2].pl));
                   if ((yyvsp[0].str))
		     Setattr((yyval.node),"convcode",NewString((yyvsp[0].str)));
               }
#line 7045 "CParse/parser.c"
    break;

  case 103: /* template_directive: SWIGTEMPLATE LPAREN idstringopt RPAREN idcolonnt LESSTHAN valparms GREATERTHAN SEMI  */
#line 3270 "CParse/parser.y"
                                                                                                        {
                  Parm *p;
		  Node *n = 0;
		  Node *outer_class = currentOuterClass;
		  Symtab *tscope = 0;
		  String *symname = (yyvsp[-6].id) ? NewString((yyvsp[-6].id)) : 0;
		  int errored_flag = 0;
		  String *idcolonnt;

		  (yyval.node) = 0;

		  tscope = Swig_symbol_current();          /* Get the current scope */

		  /* If the class name is qualified, we need to create or lookup namespace entries */
		  idcolonnt = resolve_create_node_scope((yyvsp[-4].str), 0, &errored_flag);

		  if (!errored_flag) {
		    if (nscope_inner && Strcmp(nodeType(nscope_inner), "class") == 0)
		      outer_class = nscope_inner;

		    /*
		      We use the new namespace entry 'nscope' only to
		      emit the template node. The template parameters are
		      resolved in the current 'tscope'.

		      This is closer to the C++ (typedef) behavior.
		    */
		    n = Swig_cparse_template_locate(idcolonnt, (yyvsp[-2].p), symname, tscope);
		  }

		  /* Patch the argument types to respect namespaces */
		  p = (yyvsp[-2].p);
		  while (p) {
		    SwigType *value = Getattr(p,"value");
		    if (!value) {
		      SwigType *ty = Getattr(p,"type");
		      if (ty) {
			SwigType *rty = 0;
			int reduce = template_reduce;
			if (reduce || !SwigType_ispointer(ty)) {
			  rty = Swig_symbol_typedef_reduce(ty,tscope);
			  if (!reduce) reduce = SwigType_ispointer(rty);
			}
			ty = reduce ? Swig_symbol_type_qualify(rty,tscope) : Swig_symbol_type_qualify(ty,tscope);
			Setattr(p,"type",ty);
			Delete(ty);
			Delete(rty);
		      }
		    } else {
		      value = Swig_symbol_type_qualify(value,tscope);
		      Setattr(p,"value",value);
		      Delete(value);
		    }

		    p = nextSibling(p);
		  }

		  /* Look for the template */
		  {
                    Node *nn = n;
                    Node *linklistend = 0;
                    Node *linkliststart = 0;
                    while (nn) {
                      Node *templnode = 0;
                      if (GetFlag(nn, "instantiate")) {
			Delattr(nn, "instantiate");
			{
			  int nnisclass = (Strcmp(Getattr(nn, "templatetype"), "class") == 0); /* class template not a classforward nor function template */
			  Parm *tparms = Getattr(nn, "templateparms");
			  int specialized = !tparms; /* fully specialized (an explicit specialization) */
			  String *tname = Copy(idcolonnt);
			  Node *primary_template = Swig_symbol_clookup(tname, 0);

			  /* Expand the template */
			  ParmList *temparms = Swig_cparse_template_parms_expand((yyvsp[-2].p), primary_template, nn);

                          templnode = copy_node(nn);
			  update_nested_classes(templnode); /* update classes nested within template */
                          /* We need to set the node name based on name used to instantiate */
                          Setattr(templnode,"name",tname);
			  Delete(tname);
                          if (!specialized) {
                            Delattr(templnode,"sym:typename");
                          } else {
                            Setattr(templnode,"sym:typename","1");
                          }
			  /* for now, nested %template is allowed only in the same scope as the template declaration */
                          if (symname && !(nnisclass && ((outer_class && (outer_class != Getattr(nn, "nested:outer")))
			    ||(extendmode && current_class && (current_class != Getattr(nn, "nested:outer")))))) {
			    /*
			       Comment this out for 1.3.28. We need to
			       re-enable it later but first we need to
			       move %ignore from using %rename to use
			       %feature(ignore).

			       String *symname = Swig_name_make(templnode, 0, symname, 0, 0);
			    */
                            Swig_cparse_template_expand(templnode, symname, temparms, tscope);
                            Setattr(templnode, "sym:name", symname);
                          } else {
                            static int cnt = 0;
                            String *nname = NewStringf("__dummy_%d__", cnt++);
                            Swig_cparse_template_expand(templnode,nname,temparms,tscope);
                            Setattr(templnode,"sym:name",nname);
                            SetFlag(templnode,"hidden");
			    Delete(nname);
                            Setattr(templnode,"feature:onlychildren", "typemap,typemapitem,typemapcopy,typedef,types,fragment,apply");
			    if (symname) {
			      Swig_warning(WARN_PARSE_NESTED_TEMPLATE, cparse_file, cparse_line, "Named nested template instantiations not supported. Processing as if no name was given to %%template().\n");
			    }
                          }
                          Delattr(templnode,"templatetype");
                          Setattr(templnode,"template",nn);
                          Setfile(templnode,cparse_file);
                          Setline(templnode,cparse_line);
                          Delete(temparms);
			  if (outer_class && nnisclass) {
			    SetFlag(templnode, "nested");
			    Setattr(templnode, "nested:outer", outer_class);
			  }
                          add_symbols_copy(templnode);

                          /* Warning 332 (WARN_PARSE_TEMPLATE_TYPE_CONSTRAINT_UNDEF) for any C++20 type-constraint in the
                           * template whose concept-id SWIG could not resolve during earlier parsing is intentionally
                           * disabled below.  SWIG's template substitution machinery (templ.c) is name based: a
                           * templateparm's name is replaced throughout the body by the valparm's value/type regardless
                           * of whether the templateparm was classified as 'typename T' or as a non-type parm.  The
                           * 'constraint:unresolved' remap of 'Concept T' to 'typename T' therefore has no observable
                           * effect on the generated wrapper. The warning would just result in unnecessary warnings about
                           * any missing typedef info for NNTP parameters, that wouldn't make any difference to the generated
                           * code if addressed.
                           *
                          {
                            Parm *tp = Getattr(nn, "templateparms");
                            SWIG_WARN_NODE_BEGIN(templnode);
                            while (tp) {
                              if (GetFlag(tp, "constraint:unresolved")) {
                                Node *atom = Getattr(tp, "constraint");
                                String *concept_name = atom ? Getattr(atom, "type") : 0;
                                concept_name = concept_name ? Copy(concept_name) : NewString("<unknown>");
                                Swig_warning(WARN_PARSE_TEMPLATE_TYPE_CONSTRAINT_UNDEF, cparse_file, cparse_line,
                                             "In instantiation of template '%s' with name '%s',\n",
                                             Swig_name_str(templnode), Getattr(templnode, "sym:name"));
                                Swig_warning(WARN_PARSE_TEMPLATE_TYPE_CONSTRAINT_UNDEF, Getfile(nn), Getline(nn),
                                             "nothing known about type-constraint '%s' - treated as 'typename'.\n",
                                             SwigType_str(concept_name, 0));
                                Delete(concept_name);
                              }
                              tp = nextSibling(tp);
                            }
                            SWIG_WARN_NODE_END(templnode);
                          }
                          */

			  if (Equal(nodeType(templnode), "classforward") && !(GetFlag(templnode, "feature:ignore") || GetFlag(templnode, "hidden"))) {
			    SWIG_WARN_NODE_BEGIN(templnode);
			    /* A full template class definition is required in order to wrap a template class as a proxy class so this %template is ineffective. */
			    if (GetFlag(templnode, "nested:forward"))
			      Swig_warning(WARN_PARSE_TEMPLATE_NESTED, cparse_file, cparse_line, "Unsupported template nested class '%s' cannot be used to instantiate a full template class with name '%s'.\n", Swig_name_decl(templnode), Getattr(templnode, "sym:name"));
			    else
			      Swig_warning(WARN_PARSE_TEMPLATE_FORWARD, cparse_file, cparse_line, "Template forward class '%s' cannot be used to instantiate a full template class with name '%s'.\n", Swig_name_decl(templnode), Getattr(templnode, "sym:name"));
			    SWIG_WARN_NODE_END(templnode);
			  } else if (GetFlag(templnode, "nested:ignore") && !GetFlag(templnode, "hidden")) {
			    /* A nested template class kept only as an ignored class (the target language does not
			       support nested classes) cannot be instantiated as a wrappable proxy class. */
			    SWIG_WARN_NODE_BEGIN(templnode);
			    Swig_warning(WARN_PARSE_TEMPLATE_NESTED, cparse_file, cparse_line, "Unsupported template nested class '%s' cannot be used to instantiate a full template class with name '%s'.\n", Swig_name_decl(templnode), symname);
			    SWIG_WARN_NODE_END(templnode);
			  }

                          if (Strcmp(nodeType(templnode),"class") == 0) {

                            /* Identify pure abstract methods */
                            Setattr(templnode,"abstracts", pure_abstracts(firstChild(templnode)));

                            /* Set up inheritance in symbol table */
                            {
                              Symtab  *csyms;
                              List *baselist = Getattr(templnode,"baselist");
                              csyms = Swig_symbol_current();
                              Swig_symbol_setscope(Getattr(templnode,"symtab"));
                              if (baselist) {
                                List *bases = Swig_make_inherit_list(Getattr(templnode,"name"),baselist, Namespaceprefix);
                                if (bases) {
                                  Iterator s;
                                  for (s = First(bases); s.item; s = Next(s)) {
                                    Symtab *st = Getattr(s.item,"symtab");
                                    if (st) {
				      Setfile(st,Getfile(s.item));
				      Setline(st,Getline(s.item));
                                      Swig_symbol_inherit(st);
                                    }
                                  }
				  Delete(bases);
                                }
                              }
                              Swig_symbol_setscope(csyms);
                            }

                            /* Merge in %extend methods for this class.
			       This only merges methods within %extend for a template specialized class such as
			         template<typename T> class K {}; %extend K<int> { ... }
			       The copy_node() call above has already added in the generic %extend methods such as
			         template<typename T> class K {}; %extend K { ... } */

			    /* !!! This may be broken.  We may have to add the
			       %extend methods at the beginning of the class */
                            {
                              String *stmp = 0;
                              String *clsname;
                              Node *am;
                              if (Namespaceprefix) {
                                clsname = stmp = NewStringf("%s::%s", Namespaceprefix, Getattr(templnode,"name"));
                              } else {
                                clsname = Getattr(templnode,"name");
                              }
                              am = Getattr(Swig_extend_hash(),clsname);
                              if (am) {
                                Symtab *st = Swig_symbol_current();
                                Swig_symbol_setscope(Getattr(templnode,"symtab"));
                                /*			    Printf(stdout,"%s: %s %p %p\n", Getattr(templnode,"name"), clsname, Swig_symbol_current(), Getattr(templnode,"symtab")); */
                                Swig_extend_merge(templnode,am);
                                Swig_symbol_setscope(st);
				Swig_extend_append_previous(templnode,am);
                                Delattr(Swig_extend_hash(),clsname);
                              }
			      if (stmp) Delete(stmp);
                            }

                            /* Add to classes hash */
			    if (!classes)
			      classes = NewHash();

			    if (Namespaceprefix) {
			      String *temp = NewStringf("%s::%s", Namespaceprefix, Getattr(templnode,"name"));
			      Setattr(classes,temp,templnode);
			      Delete(temp);
			    } else {
			      String *qs = Swig_symbol_qualifiedscopename(templnode);
			      Setattr(classes, qs,templnode);
			      Delete(qs);
			    }
                          }
                        }

                        /* all the overloaded function templates are added into a linked list */
                        if (!linkliststart)
                          linkliststart = templnode;
                        if (nscope_inner) {
                          /* non-global namespace */
                          if (templnode) {
                            appendChild(nscope_inner,templnode);
			    Delete(templnode);
                            if (nscope) (yyval.node) = nscope;
                          }
                        } else {
                          /* global namespace */
                          if (!linklistend) {
                            (yyval.node) = templnode;
                          } else {
                            set_nextSibling(linklistend,templnode);
			    Delete(templnode);
                          }
                          linklistend = templnode;
                        }
                      }
                      nn = Getattr(nn,"sym:nextSibling"); /* repeat for overloaded function templates. If a class template there will never be a sibling. */
                    }
                    update_defaultargs(linkliststart);
                    update_abstracts(linkliststart);
		  }
	          Swig_symbol_setscope(tscope);
		  Delete(Namespaceprefix);
		  Namespaceprefix = Swig_symbol_qualifiedscopename(0);
		  Delete(symname);
                }
#line 7326 "CParse/parser.c"
    break;

  case 104: /* warn_directive: WARN string  */
#line 3552 "CParse/parser.y"
                             {
		  Swig_warning(0,cparse_file, cparse_line,"%s\n", (yyvsp[0].str));
		  (yyval.node) = 0;
               }
#line 7335 "CParse/parser.c"
    break;

  case 105: /* c_declaration: c_decl  */
#line 3562 "CParse/parser.y"
                         {
                    (yyval.node) = (yyvsp[0].node); 
                    if ((yyval.node)) {
   		      add_symbols((yyval.node));
                      default_arguments((yyval.node));
   	            }
                }
#line 7347 "CParse/parser.c"
    break;

  case 109: /* $@3: %empty  */
#line 3575 "CParse/parser.y"
                                       {
		  if (Strcmp((yyvsp[-1].str),"C") == 0) {
		    cparse_externc = 1;
		  }
		}
#line 7357 "CParse/parser.c"
    break;

  case 110: /* c_declaration: EXTERN string LBRACE $@3 interface RBRACE  */
#line 3579 "CParse/parser.y"
                                   {
		  cparse_externc = 0;
		  if (Strcmp((yyvsp[-4].str),"C") == 0) {
		    Node *n = firstChild((yyvsp[-1].node));
		    (yyval.node) = new_node("extern");
		    Setattr((yyval.node),"name",(yyvsp[-4].str));
		    appendChild((yyval.node),n);
		    while (n) {
		      String *s = Getattr(n, "storage");
		      if (s) {
			if (Strstr(s, "thread_local")) {
			  Insert(s,0,"externc ");
			} else if (Strncmp(s, "static", 6) == 0) {
			  /* swig4ada: a declaration which is 'static' keeps its storage: it has no symbol, which 'extern "C"' does
			     not change, and a constant of it keeps its value ('static constexpr size_t AI_MAXLEN = 1024;', of
			     Assimp, was taken for a variable of the library). */
			} else if (!Equal(s, "typedef")) {
			  Setattr(n,"storage","externc");
			}
		      } else {
			Setattr(n,"storage","externc");
		      }
		      n = nextSibling(n);
		    }
		  } else {
		    if (!Equal((yyvsp[-4].str),"C++")) {
		      Swig_warning(WARN_PARSE_UNDEFINED_EXTERN,cparse_file, cparse_line,"Unrecognized extern type \"%s\".\n", (yyvsp[-4].str));
		    }
		    (yyval.node) = new_node("extern");
		    Setattr((yyval.node),"name",(yyvsp[-4].str));
		    appendChild((yyval.node),firstChild((yyvsp[-1].node)));
		  }
                }
#line 7395 "CParse/parser.c"
    break;

  case 111: /* c_declaration: cpp_lambda_decl  */
#line 3612 "CParse/parser.y"
                                  {
		  (yyval.node) = (yyvsp[0].node);
		  SWIG_WARN_NODE_BEGIN((yyval.node));
		  Swig_warning(WARN_CPP11_LAMBDA, cparse_file, cparse_line, "Lambda expressions and closures are not fully supported yet.\n");
		  SWIG_WARN_NODE_END((yyval.node));
		}
#line 7406 "CParse/parser.c"
    break;

  case 112: /* c_declaration: USING idcolon EQUAL type plain_declarator SEMI  */
#line 3618 "CParse/parser.y"
                                                                 {
		  /* Convert using statement to a typedef statement */
		  (yyval.node) = new_node("cdecl");
		  Setattr((yyval.node),"type",(yyvsp[-2].type));
		  Setattr((yyval.node),"storage","typedef");
		  Setattr((yyval.node),"name",(yyvsp[-4].str));
		  Setattr((yyval.node),"decl",(yyvsp[-1].decl).type);
		  SetFlag((yyval.node),"typealias");
		  add_symbols((yyval.node));
		}
#line 7421 "CParse/parser.c"
    break;

  case 113: /* c_declaration: TEMPLATE LESSTHAN template_parms GREATERTHAN requires_clause_opt USING idcolon EQUAL type plain_declarator SEMI  */
#line 3628 "CParse/parser.y"
                                                                                                                                  {
		  /* Convert alias template to a "template" typedef statement */
		  (yyval.node) = new_node("template");
		  Setattr((yyval.node),"type",(yyvsp[-2].type));
		  Setattr((yyval.node),"storage","typedef");
		  Setattr((yyval.node),"name",(yyvsp[-4].str));
		  Setattr((yyval.node),"decl",(yyvsp[-1].decl).type);
		  Setattr((yyval.node),"templateparms",(yyvsp[-8].tparms));
		  Setattr((yyval.node),"templatetype","cdecl");
		  SetFlag((yyval.node),"aliastemplate");
		  if ((yyvsp[-6].node))
		    Setattr((yyval.node), "constraint", (yyvsp[-6].node));
		  add_symbols((yyval.node));
		}
#line 7440 "CParse/parser.c"
    break;

  case 115: /* c_decl: storage_class type declarator cpp_const initializer c_decl_tail  */
#line 3649 "CParse/parser.y"
                                                                          {
	      String *decl = (yyvsp[-3].decl).type;
              (yyval.node) = new_node("cdecl");
	      if ((yyvsp[-2].dtype).qualifier)
	        decl = add_qualifier_to_declarator((yyvsp[-3].decl).type, (yyvsp[-2].dtype).qualifier);
	      Setattr((yyval.node),"refqualifier",(yyvsp[-2].dtype).refqualifier);
	      Setattr((yyval.node),"type",(yyvsp[-4].type));
	      Setattr((yyval.node),"storage",(yyvsp[-5].str));
	      Setattr((yyval.node),"name",(yyvsp[-3].decl).id);
	      Setattr((yyval.node),"decl",decl);
	      Setattr((yyval.node),"parms",(yyvsp[-3].decl).parms);
	      Setattr((yyval.node),"value",(yyvsp[-1].dtype).val);
	      if ((yyvsp[-1].dtype).stringval) Setattr((yyval.node), "stringval", (yyvsp[-1].dtype).stringval);
	      if ((yyvsp[-1].dtype).numval) Setattr((yyval.node), "numval", (yyvsp[-1].dtype).numval);
	      Setattr((yyval.node),"throws",(yyvsp[-2].dtype).throws);
	      Setattr((yyval.node),"throw",(yyvsp[-2].dtype).throwf);
	      Setattr((yyval.node),"noexcept",(yyvsp[-2].dtype).nexcept);
	      Setattr((yyval.node),"final",(yyvsp[-2].dtype).final);
              if ((yyvsp[-2].dtype).constraint_node)
                Setattr((yyval.node), "constraint", (yyvsp[-2].dtype).constraint_node);
	      if ((yyvsp[-1].dtype).val && (yyvsp[-1].dtype).type) {
		/* store initializer type as it might be different to the declared type */
		SwigType *valuetype = NewSwigType((yyvsp[-1].dtype).type);
		if (Len(valuetype) > 0) {
		  Setattr((yyval.node), "valuetype", valuetype);
		} else {
		  /* If we can't determine the initializer type use the declared type. */
		  Setattr((yyval.node), "valuetype", (yyvsp[-4].type));
		}
		Delete(valuetype);
	      }
	      if (!(yyvsp[0].node)) {
		if (Len(scanner_ccode)) {
		  String *code = Copy(scanner_ccode);
		  Setattr((yyval.node),"code",code);
		  Delete(code);
		}
	      } else {
		Node *n = (yyvsp[0].node);
		/* Inherit attributes */
		while (n) {
		  String *type = Copy((yyvsp[-4].type));
		  Setattr(n,"type",type);
		  Setattr(n,"storage",(yyvsp[-5].str));
		  n = nextSibling(n);
		  Delete(type);
		}
	      }
	      if ((yyvsp[-1].dtype).bitfield) {
		Setattr((yyval.node),"bitfield", (yyvsp[-1].dtype).bitfield);
	      }

	      if ((yyvsp[-3].decl).id) {
		/* Ignore all scoped declarations, could be 1. out of class function definition 2. friend function declaration 3. ... */
		String *p = Swig_scopename_prefix((yyvsp[-3].decl).id);
		if (p) {
		  /* This is a special case. If the scope name of the declaration exactly
		     matches that of the declaration, then we will allow it. Otherwise, delete. */
		  if ((Namespaceprefix && Strcmp(p, Namespaceprefix) == 0) ||
		      (Classprefix && Strcmp(p, Classprefix) == 0)) {
		    String *lstr = Swig_scopename_last((yyvsp[-3].decl).id);
		    Setattr((yyval.node), "name", lstr);
		    Delete(lstr);
		    set_nextSibling((yyval.node), (yyvsp[0].node));
		  } else {
		    Delete((yyval.node));
		    (yyval.node) = (yyvsp[0].node);
		  }
		  Delete(p);
		} else if (Strncmp((yyvsp[-3].decl).id, "::", 2) == 0) {
		  /* global scope declaration/definition ignored */
		  Delete((yyval.node));
		  (yyval.node) = (yyvsp[0].node);
		} else {
		  set_nextSibling((yyval.node), (yyvsp[0].node));
		}
	      } else {
		Swig_error(cparse_file, cparse_line, "Missing symbol name for global declaration\n");
		(yyval.node) = 0;
	      }

	      if ((yyvsp[-2].dtype).qualifier && (yyvsp[-5].str) && Strstr((yyvsp[-5].str), "static"))
		Swig_error(cparse_file, cparse_line, "Static function %s cannot have a qualifier.\n", Swig_name_decl((yyval.node)));
              /* C++20 abbreviated function template: any parm typed 'auto' becomes an invented type template parameter. */
              if ((yyval.node)) promote_abbreviated_template((yyval.node));
	      Delete((yyvsp[-5].str));
           }
#line 7532 "CParse/parser.c"
    break;

  case 116: /* c_decl: storage_class type declarator cpp_const EQUAL error SEMI  */
#line 3736 "CParse/parser.y"
                                                                      {
	      String *decl = (yyvsp[-4].decl).type;
	      (yyval.node) = new_node("cdecl");
	      if ((yyvsp[-3].dtype).qualifier)
	        decl = add_qualifier_to_declarator((yyvsp[-4].decl).type, (yyvsp[-3].dtype).qualifier);
	      Setattr((yyval.node), "refqualifier", (yyvsp[-3].dtype).refqualifier);
	      Setattr((yyval.node), "type", (yyvsp[-5].type));
	      Setattr((yyval.node), "storage", (yyvsp[-6].str));
	      Setattr((yyval.node), "name", (yyvsp[-4].decl).id);
	      Setattr((yyval.node), "decl", decl);
	      Setattr((yyval.node), "parms", (yyvsp[-4].decl).parms);

	      /* Set dummy value to avoid adding in code for handling missing value in later stages */
	      Setattr((yyval.node), "value", "*parse error*");
	      SetFlag((yyval.node), "valueignored");

	      Setattr((yyval.node), "throws", (yyvsp[-3].dtype).throws);
	      Setattr((yyval.node), "throw", (yyvsp[-3].dtype).throwf);
	      Setattr((yyval.node), "noexcept", (yyvsp[-3].dtype).nexcept);
	      Setattr((yyval.node), "final", (yyvsp[-3].dtype).final);

	      if ((yyvsp[-4].decl).id) {
		/* Ignore all scoped declarations, could be 1. out of class function definition 2. friend function declaration 3. ... */
		String *p = Swig_scopename_prefix((yyvsp[-4].decl).id);
		if (p) {
		  if ((Namespaceprefix && Strcmp(p, Namespaceprefix) == 0) ||
		      (Classprefix && Strcmp(p, Classprefix) == 0)) {
		    String *lstr = Swig_scopename_last((yyvsp[-4].decl).id);
		    Setattr((yyval.node), "name", lstr);
		    Delete(lstr);
		  } else {
		    Delete((yyval.node));
		    (yyval.node) = 0;
		  }
		  Delete(p);
		} else if (Strncmp((yyvsp[-4].decl).id, "::", 2) == 0) {
		  /* global scope declaration/definition ignored */
		  Delete((yyval.node));
		  (yyval.node) = 0;
		}
	      }

	      if ((yyvsp[-3].dtype).qualifier && (yyvsp[-6].str) && Strstr((yyvsp[-6].str), "static"))
		Swig_error(cparse_file, cparse_line, "Static function %s cannot have a qualifier.\n", Swig_name_decl((yyval.node)));
	      Delete((yyvsp[-6].str));
	   }
#line 7583 "CParse/parser.c"
    break;

  case 117: /* c_decl: storage_class idcolon AUTO declarator cpp_const ARROW cpp_alternate_rettype virt_specifier_seq_opt initializer c_decl_tail  */
#line 3787 "CParse/parser.y"
                                                                                                                                        {
              Node *atom;
              (yyval.node) = new_node("cdecl");
	      if ((yyvsp[-5].dtype).qualifier) SwigType_push((yyvsp[-6].decl).type, (yyvsp[-5].dtype).qualifier);
	      Setattr((yyval.node),"refqualifier",(yyvsp[-5].dtype).refqualifier);
	      Setattr((yyval.node),"type",(yyvsp[-3].type));
	      Setattr((yyval.node),"storage",(yyvsp[-9].str));
	      Setattr((yyval.node),"name",(yyvsp[-6].decl).id);
	      Setattr((yyval.node),"decl",(yyvsp[-6].decl).type);
	      Setattr((yyval.node),"parms",(yyvsp[-6].decl).parms);
	      Setattr((yyval.node),"throws",(yyvsp[-5].dtype).throws);
	      Setattr((yyval.node),"throw",(yyvsp[-5].dtype).throwf);
	      Setattr((yyval.node),"noexcept",(yyvsp[-5].dtype).nexcept);
	      Setattr((yyval.node),"final",(yyvsp[-5].dtype).final);
	      atom = Constraint_new_atom("concept-id");
	      Setattr(atom, "type", (yyvsp[-8].str));
	      Setattr((yyval.node), "constraint", atom);
	      if (!(yyvsp[0].node)) {
		if (Len(scanner_ccode)) {
		  String *code = Copy(scanner_ccode);
		  Setattr((yyval.node),"code",code);
		  Delete(code);
		}
	      } else {
		Node *n = (yyvsp[0].node);
		while (n) {
		  String *type = Copy((yyvsp[-3].type));
		  Setattr(n,"type",type);
		  Setattr(n,"storage",(yyvsp[-9].str));
		  n = nextSibling(n);
		  Delete(type);
		}
	      }

	      if ((yyvsp[-6].decl).id) {
		String *p = Swig_scopename_prefix((yyvsp[-6].decl).id);
		if (p) {
		  if ((Namespaceprefix && Strcmp(p, Namespaceprefix) == 0) ||
		      (Classprefix && Strcmp(p, Classprefix) == 0)) {
		    String *lstr = Swig_scopename_last((yyvsp[-6].decl).id);
		    Setattr((yyval.node),"name",lstr);
		    Delete(lstr);
		    set_nextSibling((yyval.node), (yyvsp[0].node));
		  } else {
		    Delete((yyval.node));
		    (yyval.node) = (yyvsp[0].node);
		  }
		  Delete(p);
		} else if (Strncmp((yyvsp[-6].decl).id, "::", 2) == 0) {
		  Delete((yyval.node));
		  (yyval.node) = (yyvsp[0].node);
		}
	      } else {
		set_nextSibling((yyval.node), (yyvsp[0].node));
	      }

	      if ((yyvsp[-5].dtype).qualifier && (yyvsp[-9].str) && Strstr((yyvsp[-9].str), "static"))
		Swig_error(cparse_file, cparse_line, "Static function %s cannot have a qualifier.\n", Swig_name_decl((yyval.node)));
              /* Promote any 'auto' / 'Concept auto' parm to an invented type template parameter. */
              if ((yyval.node)) promote_abbreviated_template((yyval.node));
	      Delete((yyvsp[-9].str));
           }
#line 7650 "CParse/parser.c"
    break;

  case 118: /* c_decl: storage_class AUTO declarator cpp_const ARROW cpp_alternate_rettype virt_specifier_seq_opt initializer c_decl_tail  */
#line 3851 "CParse/parser.y"
                                                                                                                                {
              (yyval.node) = new_node("cdecl");
	      if ((yyvsp[-5].dtype).qualifier) SwigType_push((yyvsp[-6].decl).type, (yyvsp[-5].dtype).qualifier);
	      Setattr((yyval.node),"refqualifier",(yyvsp[-5].dtype).refqualifier);
	      Setattr((yyval.node),"type",(yyvsp[-3].type));
	      Setattr((yyval.node),"storage",(yyvsp[-8].str));
	      Setattr((yyval.node),"name",(yyvsp[-6].decl).id);
	      Setattr((yyval.node),"decl",(yyvsp[-6].decl).type);
	      Setattr((yyval.node),"parms",(yyvsp[-6].decl).parms);
	      Setattr((yyval.node),"throws",(yyvsp[-5].dtype).throws);
	      Setattr((yyval.node),"throw",(yyvsp[-5].dtype).throwf);
	      Setattr((yyval.node),"noexcept",(yyvsp[-5].dtype).nexcept);
	      Setattr((yyval.node),"final",(yyvsp[-5].dtype).final);
	      if (!(yyvsp[0].node)) {
		if (Len(scanner_ccode)) {
		  String *code = Copy(scanner_ccode);
		  Setattr((yyval.node),"code",code);
		  Delete(code);
		}
	      } else {
		Node *n = (yyvsp[0].node);
		while (n) {
		  String *type = Copy((yyvsp[-3].type));
		  Setattr(n,"type",type);
		  Setattr(n,"storage",(yyvsp[-8].str));
		  n = nextSibling(n);
		  Delete(type);
		}
	      }

	      if ((yyvsp[-6].decl).id) {
		/* Ignore all scoped declarations, could be 1. out of class function definition 2. friend function declaration 3. ... */
		String *p = Swig_scopename_prefix((yyvsp[-6].decl).id);
		if (p) {
		  if ((Namespaceprefix && Strcmp(p, Namespaceprefix) == 0) ||
		      (Classprefix && Strcmp(p, Classprefix) == 0)) {
		    String *lstr = Swig_scopename_last((yyvsp[-6].decl).id);
		    Setattr((yyval.node),"name",lstr);
		    Delete(lstr);
		    set_nextSibling((yyval.node), (yyvsp[0].node));
		  } else {
		    Delete((yyval.node));
		    (yyval.node) = (yyvsp[0].node);
		  }
		  Delete(p);
		} else if (Strncmp((yyvsp[-6].decl).id, "::", 2) == 0) {
		  /* global scope declaration/definition ignored */
		  Delete((yyval.node));
		  (yyval.node) = (yyvsp[0].node);
		}
	      } else {
		set_nextSibling((yyval.node), (yyvsp[0].node));
	      }

	      if ((yyvsp[-5].dtype).qualifier && (yyvsp[-8].str) && Strstr((yyvsp[-8].str), "static"))
		Swig_error(cparse_file, cparse_line, "Static function %s cannot have a qualifier.\n", Swig_name_decl((yyval.node)));
              /* Promote any 'auto' / 'Concept auto' parm to an invented type template parameter. */
              if ((yyval.node)) promote_abbreviated_template((yyval.node));
	      Delete((yyvsp[-8].str));
           }
#line 7715 "CParse/parser.c"
    break;

  case 119: /* c_decl: storage_class AUTO declarator cpp_const LBRACE  */
#line 3918 "CParse/parser.y"
                                                            {
	      if (skip_balanced('{','}') < 0) Exit(EXIT_FAILURE);

              (yyval.node) = new_node("cdecl");
	      if ((yyvsp[-1].dtype).qualifier) SwigType_push((yyvsp[-2].decl).type, (yyvsp[-1].dtype).qualifier);
	      Setattr((yyval.node), "refqualifier", (yyvsp[-1].dtype).refqualifier);
	      Setattr((yyval.node), "type", NewString("auto"));
	      Setattr((yyval.node), "storage", (yyvsp[-4].str));
	      Setattr((yyval.node), "name", (yyvsp[-2].decl).id);
	      Setattr((yyval.node), "decl", (yyvsp[-2].decl).type);
	      Setattr((yyval.node), "parms", (yyvsp[-2].decl).parms);
	      Setattr((yyval.node), "throws", (yyvsp[-1].dtype).throws);
	      Setattr((yyval.node), "throw", (yyvsp[-1].dtype).throwf);
	      Setattr((yyval.node), "noexcept", (yyvsp[-1].dtype).nexcept);
	      Setattr((yyval.node), "final", (yyvsp[-1].dtype).final);

	      if ((yyvsp[-2].decl).id) {
		/* Ignore all scoped declarations, could be 1. out of class function definition 2. friend function declaration 3. ... */
		String *p = Swig_scopename_prefix((yyvsp[-2].decl).id);
		if (p) {
		  if ((Namespaceprefix && Strcmp(p, Namespaceprefix) == 0) ||
		      (Classprefix && Strcmp(p, Classprefix) == 0)) {
		    String *lstr = Swig_scopename_last((yyvsp[-2].decl).id);
		    Setattr((yyval.node), "name", lstr);
		    Delete(lstr);
		  } else {
		    Delete((yyval.node));
		    (yyval.node) = 0;
		  }
		  Delete(p);
		} else if (Strncmp((yyvsp[-2].decl).id, "::", 2) == 0) {
		  /* global scope declaration/definition ignored */
		  Delete((yyval.node));
		  (yyval.node) = 0;
		}
	      }

	      if ((yyvsp[-1].dtype).qualifier && (yyvsp[-4].str) && Strstr((yyvsp[-4].str), "static"))
		Swig_error(cparse_file, cparse_line, "Static function %s cannot have a qualifier.\n", Swig_name_decl((yyval.node)));
	      Delete((yyvsp[-4].str));
	   }
#line 7761 "CParse/parser.c"
    break;

  case 120: /* c_decl: storage_class idcolon AUTO declarator cpp_const LBRACE  */
#line 3964 "CParse/parser.y"
                                                                    {
	      Node *atom;
	      if (skip_balanced('{','}') < 0) Exit(EXIT_FAILURE);

              (yyval.node) = new_node("cdecl");
	      if ((yyvsp[-1].dtype).qualifier) SwigType_push((yyvsp[-2].decl).type, (yyvsp[-1].dtype).qualifier);
	      Setattr((yyval.node), "refqualifier", (yyvsp[-1].dtype).refqualifier);
	      Setattr((yyval.node), "type", NewString("auto"));
	      Setattr((yyval.node), "storage", (yyvsp[-5].str));
	      Setattr((yyval.node), "name", (yyvsp[-2].decl).id);
	      Setattr((yyval.node), "decl", (yyvsp[-2].decl).type);
	      Setattr((yyval.node), "parms", (yyvsp[-2].decl).parms);
	      Setattr((yyval.node), "throws", (yyvsp[-1].dtype).throws);
	      Setattr((yyval.node), "throw", (yyvsp[-1].dtype).throwf);
	      Setattr((yyval.node), "noexcept", (yyvsp[-1].dtype).nexcept);
	      Setattr((yyval.node), "final", (yyvsp[-1].dtype).final);
	      atom = Constraint_new_atom("concept-id");
	      Setattr(atom, "type", (yyvsp[-4].str));
	      Setattr((yyval.node), "constraint", atom);

	      if ((yyvsp[-2].decl).id) {
		String *p = Swig_scopename_prefix((yyvsp[-2].decl).id);
		if (p) {
		  if ((Namespaceprefix && Strcmp(p, Namespaceprefix) == 0) ||
		      (Classprefix && Strcmp(p, Classprefix) == 0)) {
		    String *lstr = Swig_scopename_last((yyvsp[-2].decl).id);
		    Setattr((yyval.node), "name", lstr);
		    Delete(lstr);
		  } else {
		    Delete((yyval.node));
		    (yyval.node) = 0;
		  }
		  Delete(p);
		} else if (Strncmp((yyvsp[-2].decl).id, "::", 2) == 0) {
		  Delete((yyval.node));
		  (yyval.node) = 0;
		}
	      }

	      if ((yyvsp[-1].dtype).qualifier && (yyvsp[-5].str) && Strstr((yyvsp[-5].str), "static"))
		Swig_error(cparse_file, cparse_line, "Static function %s cannot have a qualifier.\n", Swig_name_decl((yyval.node)));
	      Delete((yyvsp[-5].str));
	   }
#line 7809 "CParse/parser.c"
    break;

  case 121: /* c_decl: storage_class AUTO declarator cpp_const SEMI  */
#line 4011 "CParse/parser.y"
                                                          {
	      (yyval.node) = new_node("cdecl");
	      if ((yyvsp[-1].dtype).qualifier) SwigType_push((yyvsp[-2].decl).type, (yyvsp[-1].dtype).qualifier);
	      Setattr((yyval.node), "refqualifier", (yyvsp[-1].dtype).refqualifier);
	      Setattr((yyval.node), "type", NewString("auto"));
	      Setattr((yyval.node), "storage", (yyvsp[-4].str));
	      Setattr((yyval.node), "name", (yyvsp[-2].decl).id);
	      Setattr((yyval.node), "decl", (yyvsp[-2].decl).type);
	      Setattr((yyval.node), "parms", (yyvsp[-2].decl).parms);
	      Setattr((yyval.node), "throws", (yyvsp[-1].dtype).throws);
	      Setattr((yyval.node), "throw", (yyvsp[-1].dtype).throwf);
	      Setattr((yyval.node), "noexcept", (yyvsp[-1].dtype).nexcept);
	      Setattr((yyval.node), "final", (yyvsp[-1].dtype).final);

	      if ((yyvsp[-2].decl).id) {
		/* Ignore all scoped declarations, could be 1. out of class function definition 2. friend function declaration 3. ... */
		String *p = Swig_scopename_prefix((yyvsp[-2].decl).id);
		if (p) {
		  if ((Namespaceprefix && Strcmp(p, Namespaceprefix) == 0) ||
		      (Classprefix && Strcmp(p, Classprefix) == 0)) {
		    String *lstr = Swig_scopename_last((yyvsp[-2].decl).id);
		    Setattr((yyval.node), "name", lstr);
		    Delete(lstr);
		  } else {
		    Delete((yyval.node));
		    (yyval.node) = 0;
		  }
		  Delete(p);
		} else if (Strncmp((yyvsp[-2].decl).id, "::", 2) == 0) {
		  /* global scope declaration/definition ignored */
		  Delete((yyval.node));
		  (yyval.node) = 0;
		}
	      }

	      if ((yyvsp[-1].dtype).qualifier && (yyvsp[-4].str) && Strstr((yyvsp[-4].str), "static"))
		Swig_error(cparse_file, cparse_line, "Static function %s cannot have a qualifier.\n", Swig_name_decl((yyval.node)));
	      Delete((yyvsp[-4].str));
	   }
#line 7853 "CParse/parser.c"
    break;

  case 122: /* c_decl: storage_class idcolon AUTO declarator cpp_const SEMI  */
#line 4053 "CParse/parser.y"
                                                                  {
	      Node *atom;
	      (yyval.node) = new_node("cdecl");
	      if ((yyvsp[-1].dtype).qualifier) SwigType_push((yyvsp[-2].decl).type, (yyvsp[-1].dtype).qualifier);
	      Setattr((yyval.node), "refqualifier", (yyvsp[-1].dtype).refqualifier);
	      Setattr((yyval.node), "type", NewString("auto"));
	      Setattr((yyval.node), "storage", (yyvsp[-5].str));
	      Setattr((yyval.node), "name", (yyvsp[-2].decl).id);
	      Setattr((yyval.node), "decl", (yyvsp[-2].decl).type);
	      Setattr((yyval.node), "parms", (yyvsp[-2].decl).parms);
	      Setattr((yyval.node), "throws", (yyvsp[-1].dtype).throws);
	      Setattr((yyval.node), "throw", (yyvsp[-1].dtype).throwf);
	      Setattr((yyval.node), "noexcept", (yyvsp[-1].dtype).nexcept);
	      Setattr((yyval.node), "final", (yyvsp[-1].dtype).final);
	      atom = Constraint_new_atom("concept-id");
	      Setattr(atom, "type", (yyvsp[-4].str));
	      Setattr((yyval.node), "constraint", atom);

	      if ((yyvsp[-2].decl).id) {
		String *p = Swig_scopename_prefix((yyvsp[-2].decl).id);
		if (p) {
		  if ((Namespaceprefix && Strcmp(p, Namespaceprefix) == 0) ||
		      (Classprefix && Strcmp(p, Classprefix) == 0)) {
		    String *lstr = Swig_scopename_last((yyvsp[-2].decl).id);
		    Setattr((yyval.node), "name", lstr);
		    Delete(lstr);
		  } else {
		    Delete((yyval.node));
		    (yyval.node) = 0;
		  }
		  Delete(p);
		} else if (Strncmp((yyvsp[-2].decl).id, "::", 2) == 0) {
		  Delete((yyval.node));
		  (yyval.node) = 0;
		}
	      }

	      if ((yyvsp[-1].dtype).qualifier && (yyvsp[-5].str) && Strstr((yyvsp[-5].str), "static"))
		Swig_error(cparse_file, cparse_line, "Static function %s cannot have a qualifier.\n", Swig_name_decl((yyval.node)));
	      Delete((yyvsp[-5].str));
	   }
#line 7899 "CParse/parser.c"
    break;

  case 123: /* c_decl: storage_class AUTO idcolon EQUAL definetype SEMI  */
#line 4095 "CParse/parser.y"
                                                              {
	      SwigType *type = deduce_type(&(yyvsp[-1].dtype));
	      if (!type)
		type = NewString("auto");
	      (yyval.node) = new_node("cdecl");
	      Setattr((yyval.node), "type", type);
	      Setattr((yyval.node), "storage", (yyvsp[-5].str));
	      Setattr((yyval.node), "name", (yyvsp[-3].str));
	      Setattr((yyval.node), "decl", NewStringEmpty());
	      Setattr((yyval.node), "value", (yyvsp[-1].dtype).val);
	      if ((yyvsp[-1].dtype).stringval) Setattr((yyval.node), "stringval", (yyvsp[-1].dtype).stringval);
	      if ((yyvsp[-1].dtype).numval) Setattr((yyval.node), "numval", (yyvsp[-1].dtype).numval);
	      Setattr((yyval.node), "valuetype", type);
	      Delete((yyvsp[-5].str));
	      Delete(type);
	   }
#line 7920 "CParse/parser.c"
    break;

  case 124: /* c_decl: storage_class AUTO idcolon EQUAL error SEMI  */
#line 4112 "CParse/parser.y"
                                                         {
	      SwigType *type = NewString("auto");
	      (yyval.node) = new_node("cdecl");
	      Setattr((yyval.node), "type", type);
	      Setattr((yyval.node), "storage", (yyvsp[-5].str));
	      Setattr((yyval.node), "name", (yyvsp[-3].str));
	      Setattr((yyval.node), "decl", NewStringEmpty());
	      Setattr((yyval.node), "valuetype", type);
	      Delete((yyvsp[-5].str));
	      Delete(type);
	   }
#line 7936 "CParse/parser.c"
    break;

  case 125: /* c_decl_tail: SEMI  */
#line 4127 "CParse/parser.y"
                      { 
                   (yyval.node) = 0;
                   Clear(scanner_ccode); 
               }
#line 7945 "CParse/parser.c"
    break;

  case 126: /* c_decl_tail: COMMA declarator cpp_const initializer c_decl_tail  */
#line 4131 "CParse/parser.y"
                                                                        {
		 (yyval.node) = new_node("cdecl");
		 if ((yyvsp[-2].dtype).qualifier) SwigType_push((yyvsp[-3].decl).type,(yyvsp[-2].dtype).qualifier);
		 Setattr((yyval.node),"refqualifier",(yyvsp[-2].dtype).refqualifier);
		 Setattr((yyval.node),"name",(yyvsp[-3].decl).id);
		 Setattr((yyval.node),"decl",(yyvsp[-3].decl).type);
		 Setattr((yyval.node),"parms",(yyvsp[-3].decl).parms);
		 Setattr((yyval.node),"value",(yyvsp[-1].dtype).val);
		 if ((yyvsp[-1].dtype).stringval) Setattr((yyval.node), "stringval", (yyvsp[-1].dtype).stringval);
		 if ((yyvsp[-1].dtype).numval) Setattr((yyval.node), "numval", (yyvsp[-1].dtype).numval);
		 Setattr((yyval.node),"throws",(yyvsp[-2].dtype).throws);
		 Setattr((yyval.node),"throw",(yyvsp[-2].dtype).throwf);
		 Setattr((yyval.node),"noexcept",(yyvsp[-2].dtype).nexcept);
		 Setattr((yyval.node),"final",(yyvsp[-2].dtype).final);
		 if ((yyvsp[-1].dtype).bitfield) {
		   Setattr((yyval.node),"bitfield", (yyvsp[-1].dtype).bitfield);
		 }
		 if (!(yyvsp[0].node)) {
		   if (Len(scanner_ccode)) {
		     String *code = Copy(scanner_ccode);
		     Setattr((yyval.node),"code",code);
		     Delete(code);
		   }
		 } else {
		   set_nextSibling((yyval.node), (yyvsp[0].node));
		 }
	       }
#line 7977 "CParse/parser.c"
    break;

  case 127: /* c_decl_tail: LBRACE  */
#line 4158 "CParse/parser.y"
                        { 
                   if (skip_balanced('{','}') < 0) Exit(EXIT_FAILURE);
                   (yyval.node) = 0;
               }
#line 7986 "CParse/parser.c"
    break;

  case 128: /* c_decl_tail: error  */
#line 4162 "CParse/parser.y"
                       {
		   (yyval.node) = 0;
		   if (yychar == RPAREN) {
		       Swig_error(cparse_file, cparse_line, "Unexpected closing parenthesis (')').\n");
		   } else {
		       Swig_error(cparse_file, cparse_line, "Syntax error - possibly a missing semicolon (';').\n");
		   }
		   Exit(EXIT_FAILURE);
               }
#line 8000 "CParse/parser.c"
    break;

  case 130: /* initializer: COLON expr  */
#line 4174 "CParse/parser.y"
                           {
		(yyval.dtype) = default_dtype;
		(yyval.dtype).bitfield = (yyvsp[0].dtype).val;
	      }
#line 8009 "CParse/parser.c"
    break;

  case 134: /* cpp_alternate_rettype: c_enum_key idcolon  */
#line 4183 "CParse/parser.y"
                                   {
		(yyval.type) = (yyvsp[0].str);
		Insert((yyval.type), 0, "enum ");
	      }
#line 8018 "CParse/parser.c"
    break;

  case 135: /* cpp_alternate_rettype: idcolon  */
#line 4187 "CParse/parser.y"
                        { (yyval.type) = (yyvsp[0].str); }
#line 8024 "CParse/parser.c"
    break;

  case 136: /* cpp_alternate_rettype: idcolon AND  */
#line 4188 "CParse/parser.y"
                            {
                (yyval.type) = (yyvsp[-1].str);
                SwigType_add_reference((yyval.type));
              }
#line 8033 "CParse/parser.c"
    break;

  case 137: /* cpp_alternate_rettype: idcolon LAND  */
#line 4192 "CParse/parser.y"
                             {
                (yyval.type) = (yyvsp[-1].str);
                SwigType_add_rvalue_reference((yyval.type));
              }
#line 8042 "CParse/parser.c"
    break;

  case 138: /* cpp_alternate_rettype: CONST_QUAL idcolon AND  */
#line 4196 "CParse/parser.y"
                                       {
                (yyval.type) = (yyvsp[-1].str);
                SwigType_add_qualifier((yyval.type), "const");
                SwigType_add_reference((yyval.type));
              }
#line 8052 "CParse/parser.c"
    break;

  case 139: /* cpp_alternate_rettype: CONST_QUAL idcolon LAND  */
#line 4201 "CParse/parser.y"
                                        {
                (yyval.type) = (yyvsp[-1].str);
                SwigType_add_qualifier((yyval.type), "const");
                SwigType_add_rvalue_reference((yyval.type));
              }
#line 8062 "CParse/parser.c"
    break;

  case 141: /* cpp_lambda_decl: storage_class AUTO idcolon EQUAL lambda_introducer lambda_template requires_clause_opt LPAREN parms RPAREN cpp_const lambda_body lambda_tail  */
#line 4217 "CParse/parser.y"
                                                                                                                                                               {
		  (yyval.node) = new_node("lambda");
		  Setattr((yyval.node),"name",(yyvsp[-10].str));
		  Delete((yyvsp[-12].str));
		  add_symbols((yyval.node));
	        }
#line 8073 "CParse/parser.c"
    break;

  case 142: /* cpp_lambda_decl: storage_class AUTO idcolon EQUAL lambda_introducer lambda_template requires_clause_opt LPAREN parms RPAREN cpp_const ARROW type requires_clause_opt lambda_body lambda_tail  */
#line 4223 "CParse/parser.y"
                                                                                                                                                                                              {
		  (yyval.node) = new_node("lambda");
		  Setattr((yyval.node),"name",(yyvsp[-13].str));
		  Delete((yyvsp[-15].str));
		  add_symbols((yyval.node));
		}
#line 8084 "CParse/parser.c"
    break;

  case 143: /* cpp_lambda_decl: storage_class AUTO idcolon EQUAL lambda_introducer lambda_template requires_clause_opt lambda_body lambda_tail  */
#line 4229 "CParse/parser.y"
                                                                                                                                 {
		  (yyval.node) = new_node("lambda");
		  Setattr((yyval.node),"name",(yyvsp[-6].str));
		  Delete((yyvsp[-8].str));
		  add_symbols((yyval.node));
		}
#line 8095 "CParse/parser.c"
    break;

  case 144: /* lambda_introducer: LBRACKET  */
#line 4237 "CParse/parser.y"
                             {
		  if (skip_balanced('[',']') < 0) Exit(EXIT_FAILURE);
	        }
#line 8103 "CParse/parser.c"
    break;

  case 145: /* lambda_template: LESSTHAN  */
#line 4242 "CParse/parser.y"
                           {
		  if (skip_balanced('<','>') < 0) Exit(EXIT_FAILURE);
		}
#line 8111 "CParse/parser.c"
    break;

  case 147: /* lambda_body: LBRACE  */
#line 4248 "CParse/parser.y"
                     {
		  if (skip_balanced('{','}') < 0) Exit(EXIT_FAILURE);
		}
#line 8119 "CParse/parser.c"
    break;

  case 149: /* $@4: %empty  */
#line 4253 "CParse/parser.y"
                         {
		  if (skip_balanced('(',')') < 0) Exit(EXIT_FAILURE);
		}
#line 8127 "CParse/parser.c"
    break;

  case 150: /* lambda_tail: LPAREN $@4 SEMI  */
#line 4255 "CParse/parser.y"
                       {
		}
#line 8134 "CParse/parser.c"
    break;

  case 151: /* c_enum_key: ENUM  */
#line 4265 "CParse/parser.y"
                  {
		   (yyval.id) = "enum";
	      }
#line 8142 "CParse/parser.c"
    break;

  case 152: /* c_enum_key: ENUM CLASS  */
#line 4268 "CParse/parser.y"
                           {
		   (yyval.id) = "enum class";
	      }
#line 8150 "CParse/parser.c"
    break;

  case 153: /* c_enum_key: ENUM STRUCT  */
#line 4271 "CParse/parser.y"
                            {
		   (yyval.id) = "enum struct";
	      }
#line 8158 "CParse/parser.c"
    break;

  case 154: /* c_enum_inherit: COLON type_right  */
#line 4280 "CParse/parser.y"
                                  {
                   (yyval.type) = (yyvsp[0].type);
              }
#line 8166 "CParse/parser.c"
    break;

  case 155: /* c_enum_inherit: %empty  */
#line 4283 "CParse/parser.y"
                       { (yyval.type) = 0; }
#line 8172 "CParse/parser.c"
    break;

  case 156: /* c_enum_forward_decl: storage_class c_enum_key ename c_enum_inherit SEMI  */
#line 4290 "CParse/parser.y"
                                                                         {
		   SwigType *ty = 0;
		   int scopedenum = (yyvsp[-2].id) && !Equal((yyvsp[-3].id), "enum");
		   (yyval.node) = new_node("enumforward");
		   ty = NewStringf("enum %s", (yyvsp[-2].id));
		   Setattr((yyval.node),"enumkey",(yyvsp[-3].id));
		   if (scopedenum)
		     SetFlag((yyval.node), "scopedenum");
		   Setattr((yyval.node),"name",(yyvsp[-2].id));
		   Setattr((yyval.node), "enumbase", (yyvsp[-1].type));
		   Setattr((yyval.node),"type",ty);
		   Setattr((yyval.node),"sym:weak", "1");
		   Delete((yyvsp[-4].str));
		   add_symbols((yyval.node));
	      }
#line 8192 "CParse/parser.c"
    break;

  case 157: /* c_enum_decl: storage_class c_enum_key ename c_enum_inherit LBRACE enumlist RBRACE SEMI  */
#line 4313 "CParse/parser.y"
                                                                                         {
		  SwigType *ty = 0;
		  int scopedenum = (yyvsp[-5].id) && !Equal((yyvsp[-6].id), "enum");
		  (yyval.node) = new_enum_node((yyvsp[-4].type));
		  ty = NewStringf("enum %s", (yyvsp[-5].id));
		  Setattr((yyval.node),"enumkey",(yyvsp[-6].id));
		  if (scopedenum)
		    SetFlag((yyval.node), "scopedenum");
		  Setattr((yyval.node),"name",(yyvsp[-5].id));
		  Setattr((yyval.node),"type",ty);
		  appendChild((yyval.node),(yyvsp[-2].node));
		  add_symbols((yyval.node));      /* Add to tag space */

		  if (scopedenum) {
		    Swig_symbol_newscope();
		    Swig_symbol_setscopename((yyvsp[-5].id));
		    Delete(Namespaceprefix);
		    Namespaceprefix = Swig_symbol_qualifiedscopename(0);
		  }

		  add_symbols((yyvsp[-2].node));      /* Add enum values to appropriate enum or enum class scope */

		  if (scopedenum) {
		    Setattr((yyval.node),"symtab", Swig_symbol_popscope());
		    Delete(Namespaceprefix);
		    Namespaceprefix = Swig_symbol_qualifiedscopename(0);
		  }
		  Delete((yyvsp[-7].str));
               }
#line 8226 "CParse/parser.c"
    break;

  case 158: /* c_enum_decl: storage_class c_enum_key ename c_enum_inherit LBRACE enumlist RBRACE declarator cpp_const initializer c_decl_tail  */
#line 4342 "CParse/parser.y"
                                                                                                                                   {
		 Node *n;
		 SwigType *ty = 0;
		 String   *unnamed = 0;
		 int       unnamedinstance = 0;
		 int scopedenum = (yyvsp[-8].id) && !Equal((yyvsp[-9].id), "enum");

		 (yyval.node) = new_enum_node((yyvsp[-7].type));
		 Setattr((yyval.node),"enumkey",(yyvsp[-9].id));
		 if (scopedenum)
		   SetFlag((yyval.node), "scopedenum");
		 if ((yyvsp[-8].id)) {
		   Setattr((yyval.node),"name",(yyvsp[-8].id));
		   ty = NewStringf("enum %s", (yyvsp[-8].id));
		 } else if ((yyvsp[-3].decl).id) {
		   unnamed = make_unnamed();
		   ty = NewStringf("enum %s", unnamed);
		   Setattr((yyval.node),"unnamed",unnamed);
                   /* name is not set for unnamed enum instances, e.g. enum { foo } Instance; */
		   if ((yyvsp[-10].str) && Cmp((yyvsp[-10].str),"typedef") == 0) {
		     Setattr((yyval.node),"name",(yyvsp[-3].decl).id);
                   } else {
                     unnamedinstance = 1;
                   }
		   Setattr((yyval.node),"storage",(yyvsp[-10].str));
		 }
		 if ((yyvsp[-3].decl).id && Cmp((yyvsp[-10].str),"typedef") == 0) {
		   Setattr((yyval.node),"tdname",(yyvsp[-3].decl).id);
                   Setattr((yyval.node),"allows_typedef","1");
                 }
		 appendChild((yyval.node),(yyvsp[-5].node));
		 n = new_node("cdecl");
		 Setattr(n,"type",ty);
		 Setattr(n,"name",(yyvsp[-3].decl).id);
		 Setattr(n,"storage",(yyvsp[-10].str));
		 Setattr(n,"decl",(yyvsp[-3].decl).type);
		 Setattr(n,"parms",(yyvsp[-3].decl).parms);
		 Setattr(n,"unnamed",unnamed);

                 if (unnamedinstance) {
		   SwigType *cty = NewString("enum ");
		   Setattr((yyval.node),"type",cty);
		   SetFlag((yyval.node),"unnamedinstance");
		   SetFlag(n,"unnamedinstance");
		   Delete(cty);
                 }
		 if ((yyvsp[0].node)) {
		   Node *p = (yyvsp[0].node);
		   set_nextSibling(n,p);
		   while (p) {
		     SwigType *cty = Copy(ty);
		     Setattr(p,"type",cty);
		     Setattr(p,"unnamed",unnamed);
		     Setattr(p,"storage",(yyvsp[-10].str));
		     Delete(cty);
		     p = nextSibling(p);
		   }
		 } else {
		   if (Len(scanner_ccode)) {
		     String *code = Copy(scanner_ccode);
		     Setattr(n,"code",code);
		     Delete(code);
		   }
		 }

                 /* Ensure that typedef enum ABC {foo} XYZ; uses XYZ for sym:name, like structs.
                  * Note that class_rename/yyrename are bit of a mess so used this simple approach to change the name. */
                 if ((yyvsp[-3].decl).id && (yyvsp[-8].id) && Cmp((yyvsp[-10].str),"typedef") == 0) {
		   String *name = NewString((yyvsp[-3].decl).id);
                   Setattr((yyval.node), "parser:makename", name);
		   Delete(name);
                 }

		 add_symbols((yyval.node));       /* Add enum to tag space */
		 set_nextSibling((yyval.node),n);
		 Delete(n);

		 if (scopedenum) {
		   Swig_symbol_newscope();
		   Swig_symbol_setscopename((yyvsp[-8].id));
		   Delete(Namespaceprefix);
		   Namespaceprefix = Swig_symbol_qualifiedscopename(0);
		 }

		 add_symbols((yyvsp[-5].node));      /* Add enum values to appropriate enum or enum class scope */

		 if (scopedenum) {
		   Setattr((yyval.node),"symtab", Swig_symbol_popscope());
		   Delete(Namespaceprefix);
		   Namespaceprefix = Swig_symbol_qualifiedscopename(0);
		 }

	         add_symbols(n);
		 Delete((yyvsp[-10].str));
		 Delete(unnamed);
	       }
#line 8327 "CParse/parser.c"
    break;

  case 159: /* c_constructor_decl: storage_class type LPAREN parms RPAREN ctor_end  */
#line 4440 "CParse/parser.y"
                                                                     {
                   /* This is a sick hack.  If the ctor_end has parameters,
                      and the parms parameter only has 1 parameter, this
                      could be a declaration of the form:

                         type (id)(parms)

			 Otherwise it's an error. */
                    int err = 0;
                    (yyval.node) = 0;

		    if ((ParmList_len((yyvsp[-2].pl)) == 1) && (!Swig_scopename_check((yyvsp[-4].type)))) {
		      SwigType *ty = Getattr((yyvsp[-2].pl),"type");
		      String *name = Getattr((yyvsp[-2].pl),"name");
		      err = 1;
		      if (!name) {
			(yyval.node) = new_node("cdecl");
			Setattr((yyval.node),"type",(yyvsp[-4].type));
			Setattr((yyval.node),"storage",(yyvsp[-5].str));
			Setattr((yyval.node),"name",ty);

			if ((yyvsp[0].decl).have_parms) {
			  SwigType *decl = NewStringEmpty();
			  SwigType_add_function(decl,(yyvsp[0].decl).parms);
			  Setattr((yyval.node),"decl",decl);
			  Setattr((yyval.node),"parms",(yyvsp[0].decl).parms);
			  if (Len(scanner_ccode)) {
			    String *code = Copy(scanner_ccode);
			    Setattr((yyval.node),"code",code);
			    Delete(code);
			  }
			}
			if ((yyvsp[0].decl).defarg)
			  Setattr((yyval.node), "value", (yyvsp[0].decl).defarg);
			if ((yyvsp[0].decl).stringdefarg)
			  Setattr((yyval.node), "stringval", (yyvsp[0].decl).stringdefarg);
			if ((yyvsp[0].decl).numdefarg)
			  Setattr((yyval.node), "numval", (yyvsp[0].decl).numdefarg);
			Setattr((yyval.node),"throws",(yyvsp[0].decl).throws);
			Setattr((yyval.node),"throw",(yyvsp[0].decl).throwf);
			Setattr((yyval.node),"noexcept",(yyvsp[0].decl).nexcept);
			Setattr((yyval.node),"final",(yyvsp[0].decl).final);
			err = 0;
		      }
		    }
		    Delete((yyvsp[-5].str));
		    if (err) {
		      Swig_error(cparse_file,cparse_line,"Syntax error in input(2).\n");
		      Exit(EXIT_FAILURE);
		    }
                }
#line 8383 "CParse/parser.c"
    break;

  case 160: /* deduction_guide: storage_class type LPAREN parms RPAREN ARROW type requires_clause_opt SEMI  */
#line 4499 "CParse/parser.y"
                                                                                             {
                    (yyval.node) = 0;
                    Delete((yyvsp[-8].str));
                }
#line 8392 "CParse/parser.c"
    break;

  case 167: /* @5: %empty  */
#line 4523 "CParse/parser.y"
                                                                                            {
                   String *prefix;
                   List *bases = 0;
		   Node *scope = 0;
		   int errored_flag = 0;
		   String *code;
		   (yyval.node) = new_node("class");
		   Setattr((yyval.node),"kind",(yyvsp[-4].type));
		   if ((yyvsp[-1].bases)) {
		     Setattr((yyval.node),"baselist", Getattr((yyvsp[-1].bases),"public"));
		     Setattr((yyval.node),"protectedbaselist", Getattr((yyvsp[-1].bases),"protected"));
		     Setattr((yyval.node),"privatebaselist", Getattr((yyvsp[-1].bases),"private"));
		     Setattr((yyval.node),"virtualbaselist", Getattr((yyvsp[-1].bases),"virtual"));     /* swig4ada */
		   }
		   Setattr((yyval.node),"allows_typedef","1");
		   if (virtual_base_seen)
		     SetFlag((yyval.node), "has_virtual_base");
		   virtual_base_seen = 0;

		   /* Temporary unofficial symtab for use until add_symbols() adds "sym:symtab" */
		   Setattr((yyval.node), "unofficial:symtab", Swig_symbol_current());
		  
		   /* If the class name is qualified.  We need to create or lookup namespace/scope entries */
		   scope = resolve_create_node_scope((yyvsp[-3].str), 1, &errored_flag);
		   /* save nscope_inner to the class - it may be overwritten in nested classes*/
		   Setattr((yyval.node), "nested:innerscope", nscope_inner);
		   Setattr((yyval.node), "nested:nscope", nscope);
		   Setfile(scope,cparse_file);
		   Setline(scope,cparse_line);
		   Setattr((yyval.node), "name", scope);

		   if (currentOuterClass) {
		     SetFlag((yyval.node), "nested");
		     Setattr((yyval.node), "nested:outer", currentOuterClass);
		     set_access_mode((yyval.node));
		   }
		   Swig_features_get(Swig_cparse_features(), Namespaceprefix, Getattr((yyval.node), "name"), 0, (yyval.node));
		   /* save yyrename to the class attribute, to be used later in add_symbols()*/
		   Setattr((yyval.node), "class_rename", make_name((yyval.node), scope, 0));
		   Setattr((yyval.node), "Classprefix", scope);
		   Classprefix = NewString(scope);
		   /* Deal with inheritance  */
		   if ((yyvsp[-1].bases))
		     bases = Swig_make_inherit_list(scope, Getattr((yyvsp[-1].bases), "public"), Namespaceprefix);
		   prefix = SwigType_istemplate_templateprefix(scope);
		   if (prefix) {
		     String *fbase, *tbase;
		     if (Namespaceprefix) {
		       fbase = NewStringf("%s::%s", Namespaceprefix, scope);
		       tbase = NewStringf("%s::%s", Namespaceprefix, prefix);
		     } else {
		       fbase = Copy(scope);
		       tbase = Copy(prefix);
		     }
		     Swig_name_inherit(tbase,fbase);
		     Delete(fbase);
		     Delete(tbase);
		   }
                   if (Strcmp((yyvsp[-4].type), "class") == 0) {
		     cplus_mode = CPLUS_PRIVATE;
		   } else {
		     cplus_mode = CPLUS_PUBLIC;
		   }
		   if (!cparse_cplusplus) {
		     set_scope_to_global();
		   }
		   Swig_symbol_newscope();
		   Swig_symbol_setscopename(scope);
		   Swig_inherit_base_symbols(bases);
		   Delete(Namespaceprefix);
		   Namespaceprefix = Swig_symbol_qualifiedscopename(0);
		   cparse_start_line = cparse_line;

		   /* If there are active template parameters, we need to make sure they are
                      placed in the class symbol table so we can catch shadows */

		   if (template_parameters) {
		     Parm *tp = template_parameters;
		     while(tp) {
		       String *tpname = Copy(Getattr(tp,"name"));
		       Node *tn = new_node("templateparm");
		       Setattr(tn,"name",tpname);
		       Swig_symbol_cadd(tpname,tn);
		       tp = nextSibling(tp);
		       Delete(tpname);
		     }
		   }
		   Delete(prefix);
		   inclass = 1;
		   currentOuterClass = (yyval.node);
		   if (cparse_cplusplusout) {
		     /* save the structure declaration to declare it in global scope for C++ to see */
		     code = get_raw_text_balanced('{', '}');
		     Setattr((yyval.node), "code", code);
		     Delete(code);
		   }
               }
#line 8494 "CParse/parser.c"
    break;

  case 168: /* cpp_class_decl: storage_class cpptype idcolon class_virt_specifier_opt inherit LBRACE @5 cpp_members RBRACE cpp_opt_declarators  */
#line 4619 "CParse/parser.y"
                                                              {
		   Node *p;
		   SwigType *ty;
		   Symtab *cscope;
		   Node *am = 0;
		   String *scpname = 0;
		   (yyval.node) = currentOuterClass;
		   currentOuterClass = Getattr((yyval.node), "nested:outer");
		   nscope_inner = Getattr((yyval.node), "nested:innerscope");
		   nscope = Getattr((yyval.node), "nested:nscope");
		   Delattr((yyval.node), "nested:innerscope");
		   Delattr((yyval.node), "nested:nscope");
		   if (nscope_inner && Strcmp(nodeType(nscope_inner), "class") == 0) { /* actual parent class for this class */
		     Node* forward_declaration = Swig_symbol_clookup_no_inherit(Getattr((yyval.node),"name"), Getattr(nscope_inner, "symtab"));
		     if (forward_declaration) {
		       Setattr((yyval.node), "access", Getattr(forward_declaration, "access"));
		     }
		     Setattr((yyval.node), "nested:outer", nscope_inner);
		     SetFlag((yyval.node), "nested");
                   }
		   if (!currentOuterClass)
		     inclass = 0;
		   cscope = Getattr((yyval.node), "unofficial:symtab");
		   Delattr((yyval.node), "unofficial:symtab");
		   
		   /* Check for pure-abstract class */
		   Setattr((yyval.node),"abstracts", pure_abstracts((yyvsp[-2].node)));
		   
		   /* This bit of code merges in a previously defined %extend directive (if any) */
		   {
		     String *clsname = Swig_symbol_qualifiedscopename(0);
		     am = Getattr(Swig_extend_hash(), clsname);
		     if (am) {
		       Swig_extend_merge((yyval.node), am);
		       Delattr(Swig_extend_hash(), clsname);
		     }
		     Delete(clsname);
		   }
		   if (!classes) classes = NewHash();
		   scpname = Swig_symbol_qualifiedscopename(0);
		   Setattr(classes, scpname, (yyval.node));

		   appendChild((yyval.node), (yyvsp[-2].node));
		   
		   if (am) 
		     Swig_extend_append_previous((yyval.node), am);

		   p = (yyvsp[0].node);
		   if (p && !nscope_inner) {
		     if (!cparse_cplusplus && currentOuterClass)
		       appendChild(currentOuterClass, p);
		     else
		      appendSibling((yyval.node), p);
		   }
		   
		   if (nscope_inner) {
		     ty = NewString(scpname); /* if the class is declared out of scope, let the declarator use fully qualified type*/
		   } else if (cparse_cplusplus && !cparse_externc) {
		     ty = NewString(Getattr((yyvsp[-3].node), "name"));
		   } else {
		     ty = NewStringf("%s %s", (yyvsp[-8].type), Getattr((yyvsp[-3].node), "name"));
		   }
		   while (p) {
		     Setattr(p, "storage", (yyvsp[-9].str));
		     Setattr(p, "type" ,ty);
		     if (!cparse_cplusplus && currentOuterClass && (!Getattr(currentOuterClass, "name"))) {
		       SetFlag(p, "hasconsttype");
		     }
		     p = nextSibling(p);
		   }
		   if ((yyvsp[0].node) && Cmp((yyvsp[-9].str),"typedef") == 0)
		     add_typedef_name((yyval.node), (yyvsp[0].node), Getattr((yyvsp[-3].node), "name"), cscope, scpname);
		   Delete(scpname);

		   if (cplus_mode != CPLUS_PUBLIC) {
		   /* we 'open' the class at the end, to allow %template
		      to add new members */
		     Node *pa = new_node("access");
		     Setattr(pa, "kind", "public");
		     cplus_mode = CPLUS_PUBLIC;
		     appendChild((yyval.node), pa);
		     Delete(pa);
		   }
		   if (currentOuterClass)
		     restore_access_mode((yyval.node));
		   Setattr((yyval.node), "symtab", Swig_symbol_popscope());
		   Classprefix = Getattr((yyval.node), "Classprefix");
		   Delattr((yyval.node), "Classprefix");
		   Delete(Namespaceprefix);
		   Namespaceprefix = Swig_symbol_qualifiedscopename(0);
		   if (cplus_mode == CPLUS_PRIVATE && !cparse_keep_private_nested) {     /* swig4ada: unless it is kept. */
		     (yyval.node) = 0; /* skip private nested classes */
		   } else if (cparse_cplusplus && currentOuterClass && ignore_nested_classes && !GetFlag((yyval.node), "feature:flatnested")) {
		     /* Nested classes are not supported by this target language. Keep the fully parsed
		        class node but mark it to be ignored, rather than discarding it and substituting a
		        forward class declaration. This leaves the real class (with its symbol table and
		        members) available for name resolution while suppressing its wrapping. */
		     yyrename = Copy(Getattr((yyval.node), "class_rename"));
		     add_symbols((yyval.node));
		     add_symbols((yyvsp[0].node));
		     Delattr((yyval.node), "class_rename");
		     /* add_symbols() above applies any %ignore the user requested. */
		     {
		       int user_ignored = GetFlag((yyval.node), "feature:ignore");
		       /* Warn only if not already being ignored and this is the outermost unsupported nesting level. */
		       if (!user_ignored && (!currentOuterClass || !GetFlag(currentOuterClass, "nested"))) {
		         SWIG_WARN_NODE_BEGIN((yyval.node));
		         Swig_warning(WARN_PARSE_NAMED_NESTED_CLASS, cparse_file, cparse_line, "Nested %s not currently supported (%s ignored)\n", (yyvsp[-8].type), SwigType_namestr(Getattr((yyvsp[-3].node), "name")));
		         SWIG_WARN_NODE_END((yyval.node));
		       }
		       SetFlag((yyval.node), "feature:ignore");
		       /* Mark as auto-ignored (not via the user's %ignore) so that a %template attempt on a
		          nested template class can still be reported as unusable (Warning 331). */
		       if (!user_ignored)
		         SetFlag((yyval.node), "nested:ignore");
		       /* Apply the same flags to all members so a member (eg a nested enum) used in a wrapped
		          signature is ignored consistently, as it was when this class was a forward declaration. */
		       mark_nested_ignore((yyval.node), !user_ignored);
		     }
		   } else if (nscope_inner) {
		     /* this is tricky */
		     /* we add the declaration in the original namespace */
		     if (Strcmp(nodeType(nscope_inner), "class") == 0 && cparse_cplusplus && ignore_nested_classes && !GetFlag((yyval.node), "feature:flatnested"))
		       (yyval.node) = nested_forward_declaration((yyvsp[-9].str), (yyvsp[-8].type), Getattr((yyvsp[-3].node), "name"), Copy(Getattr((yyvsp[-3].node), "name")), (yyvsp[0].node));
		     appendChild(nscope_inner, (yyval.node));
		     Swig_symbol_setscope(Getattr(nscope_inner, "symtab"));
		     Delete(Namespaceprefix);
		     Namespaceprefix = Swig_symbol_qualifiedscopename(0);
		     yyrename = Copy(Getattr((yyval.node), "class_rename"));
		     add_symbols((yyval.node));
		     Delattr((yyval.node), "class_rename");
		     /* but the variable definition in the current scope */
		     Swig_symbol_setscope(cscope);
		     Delete(Namespaceprefix);
		     Namespaceprefix = Swig_symbol_qualifiedscopename(0);
		     add_symbols((yyvsp[0].node));
		     if (nscope) {
		       (yyval.node) = nscope; /* here we return recreated namespace tower instead of the class itself */
		       if ((yyvsp[0].node)) {
			 appendSibling((yyval.node), (yyvsp[0].node));
		       }
		     } else if (!SwigType_istemplate(ty) && template_parameters == 0) { /* for template we need the class itself */
		       (yyval.node) = (yyvsp[0].node);
		     }
		   } else {
		     Delete(yyrename);
		     yyrename = 0;
		     if (!cparse_cplusplus && currentOuterClass) { /* nested C structs go into global scope*/
		       Node *outer = currentOuterClass;
		       while (Getattr(outer, "nested:outer"))
			 outer = Getattr(outer, "nested:outer");
		       appendSibling(outer, (yyval.node));
		       Swig_symbol_setscope(cscope); /* declaration goes in the parent scope */
		       add_symbols((yyvsp[0].node));
		       set_scope_to_global();
		       Delete(Namespaceprefix);
		       Namespaceprefix = Swig_symbol_qualifiedscopename(0);
		       yyrename = Copy(Getattr((yyval.node), "class_rename"));
		       add_symbols((yyval.node));
		       if (!cparse_cplusplusout)
			 Delattr((yyval.node), "nested:outer");
		       Delattr((yyval.node), "class_rename");
		       (yyval.node) = 0;
		     } else {
		       yyrename = Copy(Getattr((yyval.node), "class_rename"));
		       add_symbols((yyval.node));
		       add_symbols((yyvsp[0].node));
		       Delattr((yyval.node), "class_rename");
		     }
		   }
		   Delete(ty);
		   Swig_symbol_setscope(cscope);
		   Delete(Namespaceprefix);
		   Namespaceprefix = Swig_symbol_qualifiedscopename(0);
		   Classprefix = currentOuterClass ? Getattr(currentOuterClass, "Classprefix") : 0;
		   Delete((yyvsp[-9].str));
	       }
#line 8676 "CParse/parser.c"
    break;

  case 169: /* @6: %empty  */
#line 4799 "CParse/parser.y"
                                                          {
	       String *unnamed;
	       String *code;
	       unnamed = make_unnamed();
	       (yyval.node) = new_node("class");
	       Setattr((yyval.node),"kind",(yyvsp[-2].type));
	       if ((yyvsp[-1].bases)) {
		 Setattr((yyval.node),"baselist", Getattr((yyvsp[-1].bases),"public"));
		 Setattr((yyval.node),"protectedbaselist", Getattr((yyvsp[-1].bases),"protected"));
		 Setattr((yyval.node),"privatebaselist", Getattr((yyvsp[-1].bases),"private"));
		 Setattr((yyval.node),"virtualbaselist", Getattr((yyvsp[-1].bases),"virtual"));     /* swig4ada */
	       }
	       Setattr((yyval.node),"storage",(yyvsp[-3].str));
	       Setattr((yyval.node),"unnamed",unnamed);
	       Setattr((yyval.node),"allows_typedef","1");
	       if (virtual_base_seen)
		 SetFlag((yyval.node), "has_virtual_base");
	       virtual_base_seen = 0;

	       /* Temporary unofficial symtab for use until add_symbols() adds "sym:symtab" */
	       Setattr((yyval.node), "unofficial:symtab", Swig_symbol_current());

	       if (currentOuterClass) {
		 SetFlag((yyval.node), "nested");
		 Setattr((yyval.node), "nested:outer", currentOuterClass);
		 set_access_mode((yyval.node));
	       }
	       Swig_features_get(Swig_cparse_features(), Namespaceprefix, 0, 0, (yyval.node));
	       /* save yyrename to the class attribute, to be used later in add_symbols()*/
	       Setattr((yyval.node), "class_rename", make_name((yyval.node),0,0));
	       if (Strcmp((yyvsp[-2].type), "class") == 0) {
		 cplus_mode = CPLUS_PRIVATE;
	       } else {
		 cplus_mode = CPLUS_PUBLIC;
	       }
	       Swig_symbol_newscope();
	       cparse_start_line = cparse_line;
	       currentOuterClass = (yyval.node);
	       inclass = 1;
	       Classprefix = 0;
	       Delete(Namespaceprefix);
	       Namespaceprefix = Swig_symbol_qualifiedscopename(0);
	       /* save the structure declaration to make a typedef for it later*/
	       code = get_raw_text_balanced('{', '}');
	       Setattr((yyval.node), "code", code);
	       Delete(code);
	     }
#line 8728 "CParse/parser.c"
    break;

  case 170: /* cpp_class_decl: storage_class cpptype inherit LBRACE @6 cpp_members RBRACE cpp_opt_declarators  */
#line 4845 "CParse/parser.y"
                                                            {
	       String *unnamed;
               List *bases = 0;
	       String *name = 0;
	       Node *n;
	       Symtab *cscope;
	       Classprefix = 0;
	       (void)(yyvsp[-3].node);
	       (yyval.node) = currentOuterClass;
	       currentOuterClass = Getattr((yyval.node), "nested:outer");
	       if (!currentOuterClass)
		 inclass = 0;
	       else
		 restore_access_mode((yyval.node));

	       cscope = Getattr((yyval.node), "unofficial:symtab");
	       Delattr((yyval.node), "unofficial:symtab");

	       unnamed = Getattr((yyval.node),"unnamed");
               /* Check for pure-abstract class */
	       Setattr((yyval.node),"abstracts", pure_abstracts((yyvsp[-2].node)));
	       n = (yyvsp[0].node);
	       /* swig4ada: a class with no name is dealt with here whether or not nested classes are flattened, as flattening
		  loses the members which are declared with it, and takes the members of an anonymous union for members of the
		  outer class. A typedef of such a class gives it a name, and is still flattened. */
	       if (cparse_cplusplus && currentOuterClass && (ignore_nested_classes || cparse_keep_unnamed_nested)
		   && (!(GetFlag((yyval.node), "feature:flatnested") || cparse_keep_unnamed_nested) || !((yyvsp[-7].str) && Equal((yyvsp[-7].str), "typedef")))) {
		 String *name;
		 /* swig4ada: the class is kept on the node of the outer class, with its members and the names of the members
		    which are declared with it, for a language module which lays the outer class out itself. */
		 {
		   List *kept = Getattr(currentOuterClass, "unnamed_nested");
		   List *declared = NewList();
		   String *line = NewStringf("%d", cparse_line);
		   Node *d = n;
		   if (!kept) {
		     kept = NewList();
		     Setattr(currentOuterClass, "unnamed_nested", kept);
		     Delete(kept);
		     kept = Getattr(currentOuterClass, "unnamed_nested");
		   }
		   while (d) {
		     String *decl = Getattr(d, "decl");
		     String *member = decl ? NewStringf("%s|%s", Getattr(d, "name"), decl) : NewStringf("%s|", Getattr(d, "name"));
		     Append(declared, member);
		     Delete(member);
		     d = nextSibling(d);
		   }
		   Setattr((yyval.node), "unnamed_nested:members", declared);
		   Setattr((yyval.node), "unnamed_nested:line", line);
		   Delete(declared);
		   Delete(line);
		   appendChild((yyval.node), (yyvsp[-2].node));
		   Append(kept, (yyval.node));
		 }
		 name = n ? Copy(Getattr(n, "name")) : 0;
		 (yyval.node) = nested_forward_declaration((yyvsp[-7].str), (yyvsp[-6].type), 0, name, n);
	       } else if (n) {
	         appendSibling((yyval.node),n);
		 /* If a proper typedef name was given, we'll use it to set the scope name */
		 name = try_to_find_a_name_for_unnamed_structure((yyvsp[-7].str), n);
		 if (name) {
		   String *scpname = 0;
		   SwigType *ty;
		   Setattr((yyval.node),"tdname",name);
		   Setattr((yyval.node),"name",name);
		   Swig_symbol_setscopename(name);
		   if ((yyvsp[-5].bases))
		     bases = Swig_make_inherit_list(name,Getattr((yyvsp[-5].bases),"public"),Namespaceprefix);
		   Swig_inherit_base_symbols(bases);

		     /* If a proper name was given, we use that as the typedef, not unnamed */
		   Clear(unnamed);
		   Append(unnamed, name);
		   if (cparse_cplusplus && !cparse_externc) {
		     ty = NewString(name);
		   } else {
		     ty = NewStringf("%s %s", (yyvsp[-6].type),name);
		   }
		   while (n) {
		     Setattr(n,"storage",(yyvsp[-7].str));
		     Setattr(n, "type", ty);
		     if (!cparse_cplusplus && currentOuterClass && (!Getattr(currentOuterClass, "name"))) {
		       SetFlag(n,"hasconsttype");
		     }
		     n = nextSibling(n);
		   }
		   n = (yyvsp[0].node);

		   /* Check for previous extensions */
		   {
		     String *clsname = Swig_symbol_qualifiedscopename(0);
		     Node *am = Getattr(Swig_extend_hash(),clsname);
		     if (am) {
		       /* Merge the extension into the symbol table */
		       Swig_extend_merge((yyval.node),am);
		       Swig_extend_append_previous((yyval.node),am);
		       Delattr(Swig_extend_hash(),clsname);
		     }
		     Delete(clsname);
		   }
		   if (!classes) classes = NewHash();
		   scpname = Swig_symbol_qualifiedscopename(0);
		   Setattr(classes,scpname,(yyval.node));
		   Delete(scpname);
		 } else { /* no suitable name was found for a struct */
		   Setattr((yyval.node), "nested:unnamed", Getattr(n, "name")); /* save the name of the first declarator for later use in name generation*/
		   while (n) { /* attach unnamed struct to the declarators, so that they would receive proper type later*/
		     Setattr(n, "nested:unnamedtype", (yyval.node));
		     Setattr(n, "storage", (yyvsp[-7].str));
		     n = nextSibling(n);
		   }
		   n = (yyvsp[0].node);
		   Swig_symbol_setscopename("<unnamed>");
		 }
		 appendChild((yyval.node),(yyvsp[-2].node));
		 /* Pop the scope */
		 Setattr((yyval.node),"symtab",Swig_symbol_popscope());
		 if (name) {
		   Delete(yyrename);
		   yyrename = Copy(Getattr((yyval.node), "class_rename"));
		   Delete(Namespaceprefix);
		   Namespaceprefix = Swig_symbol_qualifiedscopename(0);
		   add_symbols((yyval.node));
		   add_symbols(n);
		   Delattr((yyval.node), "class_rename");
		 } else if (cparse_cplusplus)
		   (yyval.node) = 0; /* ignore unnamed structs for C++ */
		   Delete(unnamed);
	       } else { /* unnamed struct without declarator*/
		 Swig_symbol_popscope();
	         Delete(Namespaceprefix);
		 Namespaceprefix = Swig_symbol_qualifiedscopename(0);
		 add_symbols((yyvsp[-2].node));
		 Delete((yyval.node));
		 (yyval.node) = (yyvsp[-2].node); /* pass member list to outer class/namespace (instead of self)*/
	       }
	       Swig_symbol_setscope(cscope);
	       Delete(Namespaceprefix);
	       Namespaceprefix = Swig_symbol_qualifiedscopename(0);
	       Classprefix = currentOuterClass ? Getattr(currentOuterClass, "Classprefix") : 0;
	       Delete((yyvsp[-7].str));
              }
#line 8876 "CParse/parser.c"
    break;

  case 171: /* cpp_opt_declarators: SEMI  */
#line 4990 "CParse/parser.y"
                            { (yyval.node) = 0; }
#line 8882 "CParse/parser.c"
    break;

  case 172: /* cpp_opt_declarators: declarator cpp_const initializer c_decl_tail  */
#line 4991 "CParse/parser.y"
                                                                    {
                        (yyval.node) = new_node("cdecl");
                        Setattr((yyval.node),"name",(yyvsp[-3].decl).id);
                        Setattr((yyval.node),"decl",(yyvsp[-3].decl).type);
                        Setattr((yyval.node),"parms",(yyvsp[-3].decl).parms);
			set_nextSibling((yyval.node), (yyvsp[0].node));
                    }
#line 8894 "CParse/parser.c"
    break;

  case 173: /* cpp_forward_class_decl: storage_class cpptype idcolon SEMI  */
#line 5003 "CParse/parser.y"
                                                            {
	      if ((yyvsp[-3].str) && Strstr((yyvsp[-3].str), "friend")) {
		/* Ignore */
                (yyval.node) = 0; 
	      } else {
		(yyval.node) = new_node("classforward");
		Setattr((yyval.node),"kind",(yyvsp[-2].type));
		Setattr((yyval.node),"name",(yyvsp[-1].str));
		Setattr((yyval.node),"sym:weak", "1");
		add_symbols((yyval.node));
	      }
	      Delete((yyvsp[-3].str));
             }
#line 8912 "CParse/parser.c"
    break;

  case 174: /* $@7: %empty  */
#line 5022 "CParse/parser.y"
                                                                                     {
		    if (currentOuterClass)
		      Setattr(currentOuterClass, "template_parameters", template_parameters);
		    template_parameters = (yyvsp[-2].tparms);
		    parsing_template_declaration = 1;
		  }
#line 8923 "CParse/parser.c"
    break;

  case 175: /* cpp_template_decl: TEMPLATE LESSTHAN template_parms GREATERTHAN requires_clause_opt $@7 cpp_template_possible  */
#line 5027 "CParse/parser.y"
                                          {
			String *tname = 0;
			int     error = 0;

			/* check if we get a namespace node with a class declaration, and retrieve the class */
			Symtab *cscope = Swig_symbol_current();
			Symtab *sti = 0;
			Node *ntop = (yyvsp[0].node);
			Node *ni = ntop;
			SwigType *ntype = ni ? nodeType(ni) : 0;
			while (ni && Strcmp(ntype,"namespace") == 0) {
			  sti = Getattr(ni,"symtab");
			  ni = firstChild(ni);
			  ntype = nodeType(ni);
			}
			if (sti) {
			  Swig_symbol_setscope(sti);
			  Delete(Namespaceprefix);
			  Namespaceprefix = Swig_symbol_qualifiedscopename(0);
			  (yyval.node) = ni;
			} else {
			  (yyval.node) = (yyvsp[0].node);
			}

			if ((yyval.node)) tname = Getattr((yyval.node),"name");
			
			/* Check if the class is a template specialization */
			if (((yyval.node)) && (Strchr(tname,'<')) && (!is_operator(tname))) {
			  /* If a specialization.  Check if defined. */
			  Node *tempn = 0;
			  {
			    String *tbase = SwigType_templateprefix(tname);
			    tempn = Swig_symbol_clookup_local(tbase,0);
			    if (!tempn || (Strcmp(nodeType(tempn),"template") != 0)) {
			      SWIG_WARN_NODE_BEGIN(tempn);
			      Swig_warning(WARN_PARSE_TEMPLATE_SP_UNDEF, Getfile((yyval.node)),Getline((yyval.node)),"Specialization of non-template '%s'.\n", tbase);
			      SWIG_WARN_NODE_END(tempn);
			      tempn = 0;
			      error = 1;
			    }
			    Delete(tbase);
			  }
			  Setattr((yyval.node),"specialization","1");
			  Setattr((yyval.node),"templatetype",nodeType((yyval.node)));
			  set_nodeType((yyval.node),"template");
			  /* Template partial specialization */
			  if (tempn && ((yyvsp[-4].tparms)) && ((yyval.node))) {
			    ParmList *primary_templateparms = Getattr(tempn, "templateparms");
			    String *targs = SwigType_templateargs(tname); /* tname contains name and specialized template parameters, for example: X<(p.T,TT)> */
			    List *tlist = SwigType_parmlist(targs);
			    int specialization_parms_len = Len(tlist);
			    if (!Getattr((yyval.node),"sym:weak")) {
			      Setattr((yyval.node),"sym:typename","1");
			    }
			    Setattr((yyval.node), "primarytemplate", tempn);
			    Setattr((yyval.node), "templateparms", (yyvsp[-4].tparms));
			    Delattr((yyval.node), "specialization");
			    Setattr((yyval.node), "partialspecialization", "1");
			    
			    if (specialization_parms_len > ParmList_len(primary_templateparms)) {
			      Swig_error(Getfile((yyval.node)), Getline((yyval.node)), "Template partial specialization has more arguments than primary template %d %d.\n", specialization_parms_len, ParmList_len(primary_templateparms));
			      
			    } else if (specialization_parms_len < ParmList_numrequired(primary_templateparms)) {
			      Swig_error(Getfile((yyval.node)), Getline((yyval.node)), "Template partial specialization has fewer arguments than primary template %d %d.\n", specialization_parms_len, ParmList_len(primary_templateparms));
			    } else {
			      /* Create a specialized name with template parameters replaced with $ variables, such as, X<(T1,p.T2) => X<($1,p.$2)> */
			      Parm *p = (yyvsp[-4].tparms);
			      String *fname = NewString(tname);
			      String *ffname = 0;
			      ParmList *partialparms = 0;

			      char   tmp[32];
			      int i = 0;
			      while (p) {
				String *name = Getattr(p,"name");
				++i;
				if (!name) {
				  p = nextSibling(p);
				  continue;
				}
				snprintf(tmp, sizeof(tmp), "$%d", i);
				Replaceid(fname, name, tmp);
				p = nextSibling(p);
			      }
			      /* Patch argument names with typedef */
			      {
				Iterator tt;
				Parm *parm_current = 0;
				List *tparms = SwigType_parmlist(fname);
				ffname = SwigType_templateprefix(fname);
				Append(ffname,"<(");
				for (tt = First(tparms); tt.item; ) {
				  SwigType *rtt = Swig_symbol_typedef_reduce(tt.item,0);
				  SwigType *ttr = Swig_symbol_type_qualify(rtt,0);

				  Parm *newp = NewParmWithoutFileLineInfo(ttr, 0);
				  if (partialparms)
				    set_nextSibling(parm_current, newp);
				  else
				    partialparms = newp;
				  parm_current = newp;

				  Append(ffname,ttr);
				  tt = Next(tt);
				  if (tt.item) Putc(',',ffname);
				  Delete(rtt);
				  Delete(ttr);
				}
				Delete(tparms);
				Append(ffname,")>");
			      }
			      {
				/* Replace each primary template parameter's name and value with $ variables, such as, class Y,class T=Y => class $1,class $2=$1 */
				ParmList *primary_templateparms_copy = CopyParmList(primary_templateparms);
				p = primary_templateparms_copy;
				i = 0;
				while (p) {
				  String *name = Getattr(p, "name");
				  Parm *pp = nextSibling(p);
				  ++i;
				  snprintf(tmp, sizeof(tmp), "$%d", i);
				  while (pp) {
				    Replaceid(Getattr(pp, "value"), name, tmp);
				    pp = nextSibling(pp);
				  }
				  Setattr(p, "name", NewString(tmp));
				  p = nextSibling(p);
				}
				/* Modify partialparms by adding in missing default values ($ variables) from primary template parameters */
				partialparms = Swig_cparse_template_partialargs_expand(partialparms, tempn, primary_templateparms_copy);
				Delete(primary_templateparms_copy);
			      }
			      {
				Node *new_partial = NewHash();
				String *partials = Getattr(tempn,"partials");
				if (!partials) {
				  partials = NewList();
				  Setattr(tempn,"partials",partials);
				  Delete(partials);
				}
				/*			      Printf(stdout,"partial: fname = '%s', '%s'\n", fname, Swig_symbol_typedef_reduce(fname,0)); */
				Setattr(new_partial, "partialparms", partialparms);
				Setattr(new_partial, "templcsymname", ffname);
				Append(partials, new_partial);
			      }
			      Setattr((yyval.node),"partialargs",ffname);
			      Swig_symbol_cadd(ffname,(yyval.node));
			    }
			    Delete(tlist);
			    Delete(targs);
			  } else {
			    /* An explicit template specialization */
			    /* add default args from primary (unspecialized) template */
			    String *ty = Swig_symbol_template_deftype(tname,0);
			    String *fname = Swig_symbol_type_qualify(ty,0);
			    Swig_symbol_cadd(fname,(yyval.node));
			    Delete(ty);
			    Delete(fname);
			  }
			} else if ((yyval.node)) {
			  ParmList *invented = Getattr((yyval.node), "templateparms");
			  if (invented && Equal(nodeType((yyval.node)), "template")) {
			    /* The inner cdecl was already promoted to a template by promote_abbreviated_template
			     * (its parms contain auto / Concept auto), so it already has templatetype, nodeType
			     * and a templateparms list of invented __dummy_auto_N__ parms.  Per C++20 [dcl.fct]/19
			     * the invented type template parameters are appended to the explicit template parameter
			     * list, so merge here rather than overwriting (which would orphan the invented parms
			     * and trigger an infinite recursion in cparse_template_expand).  The nodeType check
			     * keeps us out of this branch when the templateparms attribute was propagated from a
			     * matching forward declaration onto an out of line nested class definition - that case
			     * has nodeType "class", and the else branch correctly overwrites with $template_parms. */
			    Setattr((yyval.node), "templateparms", ParmList_join((yyvsp[-4].tparms), invented));
			  } else {
			    Setattr((yyval.node), "templatetype", nodeType((yyval.node)));
			    set_nodeType((yyval.node), "template");
			    Setattr((yyval.node), "templateparms", (yyvsp[-4].tparms));
			  }
			  if (!Getattr((yyval.node),"sym:weak")) {
			    Setattr((yyval.node),"sym:typename","1");
			  }
			  add_symbols((yyval.node));
			  default_arguments((yyval.node));
			  /* We also place a fully parameterized version in the symbol table */
			  {
			    Parm *p;
			    String *fname = NewStringf("%s<(", Getattr((yyval.node),"name"));
			    p = (yyvsp[-4].tparms);
			    while (p) {
			      String *n = Getattr(p,"name");
			      if (!n) n = Getattr(p,"type");
			      Append(fname,n);
			      p = nextSibling(p);
			      if (p) Putc(',',fname);
			    }
			    Append(fname,")>");
			    Swig_symbol_cadd(fname,(yyval.node));
			  }
			}
                        /* Attach prefix requires-clause subtree (e.g. 'template<T> requires C<T>') to the
                           inner template node's "constraint" attribute.  If a trailing requires-clause is
                           already present on the cdecl (set by c_decl), conjoin the two structurally into
                           a single op="and" constraint subtree per [temp.constr.decl]. */
                        if (ni && (yyvsp[-2].node)) {
                          Node *trailing = Getattr(ni, "constraint");
                          Node *combined;
                          if (trailing) {
                            Delattr(ni, "constraint");
                            combined = Constraint_combine("and", (yyvsp[-2].node), trailing);
                          } else {
                            combined = (yyvsp[-2].node);
                          }
                          Setattr(ni, "constraint", combined);
                        }
			(yyval.node) = ntop;
			Swig_symbol_setscope(cscope);
			Delete(Namespaceprefix);
			Namespaceprefix = Swig_symbol_qualifiedscopename(0);
			if (error || (nscope_inner && Strcmp(nodeType(nscope_inner), "class") == 0)) {
			  (yyval.node) = 0;
			}
			if (currentOuterClass)
			  template_parameters = Getattr(currentOuterClass, "template_parameters");
			else
			  template_parameters = 0;
			parsing_template_declaration = 0;
                }
#line 9154 "CParse/parser.c"
    break;

  case 176: /* cpp_template_decl: TEMPLATE cpptype idcolon  */
#line 5255 "CParse/parser.y"
                                           {
		  Swig_warning(WARN_PARSE_EXPLICIT_TEMPLATE, cparse_file, cparse_line, "Explicit template instantiation ignored.\n");
                  (yyval.node) = 0; 
		}
#line 9163 "CParse/parser.c"
    break;

  case 177: /* cpp_template_decl: TEMPLATE cpp_alternate_rettype idcolon LPAREN parms RPAREN SEMI  */
#line 5264 "CParse/parser.y"
                                                                                  {
			Swig_warning(WARN_PARSE_EXPLICIT_TEMPLATE, cparse_file, cparse_line, "Explicit template instantiation ignored.\n");
                  (yyval.node) = 0; 
		}
#line 9172 "CParse/parser.c"
    break;

  case 178: /* cpp_template_decl: TEMPLATE cpp_alternate_rettype idcolon LPAREN parms RPAREN cv_ref_qualifier SEMI  */
#line 5268 "CParse/parser.y"
                                                                                                   {
			Swig_warning(WARN_PARSE_EXPLICIT_TEMPLATE, cparse_file, cparse_line, "Explicit template instantiation ignored.\n");
                  (yyval.node) = 0; 
		}
#line 9181 "CParse/parser.c"
    break;

  case 179: /* cpp_template_decl: EXTERN TEMPLATE cpptype idcolon  */
#line 5274 "CParse/parser.y"
                                                  {
		  Swig_warning(WARN_PARSE_EXTERN_TEMPLATE, cparse_file, cparse_line, "Extern template ignored.\n");
                  (yyval.node) = 0; 
                }
#line 9190 "CParse/parser.c"
    break;

  case 180: /* cpp_template_decl: EXTERN TEMPLATE cpp_alternate_rettype idcolon LPAREN parms RPAREN SEMI  */
#line 5281 "CParse/parser.y"
                                                                                         {
			Swig_warning(WARN_PARSE_EXTERN_TEMPLATE, cparse_file, cparse_line, "Extern template ignored.\n");
                  (yyval.node) = 0; 
		}
#line 9199 "CParse/parser.c"
    break;

  case 181: /* cpp_template_decl: EXTERN TEMPLATE cpp_alternate_rettype idcolon LPAREN parms RPAREN cv_ref_qualifier SEMI  */
#line 5285 "CParse/parser.y"
                                                                                                          {
			Swig_warning(WARN_PARSE_EXTERN_TEMPLATE, cparse_file, cparse_line, "Extern template ignored.\n");
                  (yyval.node) = 0; 
		}
#line 9208 "CParse/parser.c"
    break;

  case 185: /* cpp_template_possible: cpp_template_decl  */
#line 5294 "CParse/parser.y"
                                    {
		  (yyval.node) = 0;
                }
#line 9216 "CParse/parser.c"
    break;

  case 190: /* cpp_concept_decl: CONCEPT idcolon EQUAL constraint SEMI  */
#line 5310 "CParse/parser.y"
                                                         {
                  (yyval.node) = new_node("concept");
                  Setattr((yyval.node), "name", (yyvsp[-3].str));
                  Setattr((yyval.node), "type", NewString("bool"));
                  Setattr((yyval.node), "constraint", (yyvsp[-1].node));
                }
#line 9227 "CParse/parser.c"
    break;

  case 191: /* template_parms: template_parms_builder  */
#line 5318 "CParse/parser.y"
                                        {
		 (yyval.tparms) = (yyvsp[0].pbuilder).parms;
	       }
#line 9235 "CParse/parser.c"
    break;

  case 192: /* template_parms: %empty  */
#line 5321 "CParse/parser.y"
                        {
		 (yyval.tparms) = 0;
	       }
#line 9243 "CParse/parser.c"
    break;

  case 193: /* template_parms_builder: templateparameter  */
#line 5326 "CParse/parser.y"
                                           {
		    (yyval.pbuilder).parms = (yyval.pbuilder).last = (yyvsp[0].p);
		  }
#line 9251 "CParse/parser.c"
    break;

  case 194: /* template_parms_builder: template_parms_builder COMMA templateparameter  */
#line 5329 "CParse/parser.y"
                                                                       {
		    // Build a linked list in the order specified, but avoiding
		    // a right recursion rule because "Right recursion uses up
		    // space on the Bison stack in proportion to the number of
		    // elements in the sequence".
		    set_nextSibling((yyvsp[-2].pbuilder).last, (yyvsp[0].p));
		    (yyval.pbuilder).parms = (yyvsp[-2].pbuilder).parms;
		    (yyval.pbuilder).last = (yyvsp[0].p);
		  }
#line 9265 "CParse/parser.c"
    break;

  case 195: /* templateparameter: templcpptype def_args  */
#line 5340 "CParse/parser.y"
                                          {
		    (yyval.p) = NewParmWithoutFileLineInfo((yyvsp[-1].type), 0);
		    Setfile((yyval.p), cparse_file);
		    Setline((yyval.p), cparse_line);
		    Setattr((yyval.p), "value", (yyvsp[0].dtype).val);
		    if ((yyvsp[0].dtype).stringval) Setattr((yyval.p), "stringval", (yyvsp[0].dtype).stringval);
		    if ((yyvsp[0].dtype).numval) Setattr((yyval.p), "numval", (yyvsp[0].dtype).numval);
		  }
#line 9278 "CParse/parser.c"
    break;

  case 196: /* templateparameter: TEMPLATE LESSTHAN template_parms GREATERTHAN cpptype idcolon def_args  */
#line 5348 "CParse/parser.y"
                                                                                          {
		    (yyval.p) = NewParmWithoutFileLineInfo(NewStringf("template< %s > %s %s", ParmList_str_defaultargs((yyvsp[-4].tparms)), (yyvsp[-2].type), (yyvsp[-1].str)), (yyvsp[-1].str));
		    Setfile((yyval.p), cparse_file);
		    Setline((yyval.p), cparse_line);
		    if ((yyvsp[0].dtype).val) {
		      Setattr((yyval.p), "value", (yyvsp[0].dtype).val);
		    }
		  }
#line 9291 "CParse/parser.c"
    break;

  case 197: /* templateparameter: TEMPLATE LESSTHAN template_parms GREATERTHAN cpptype def_args  */
#line 5356 "CParse/parser.y"
                                                                                  {
		    (yyval.p) = NewParmWithoutFileLineInfo(NewStringf("template< %s > %s", ParmList_str_defaultargs((yyvsp[-3].tparms)), (yyvsp[-1].type)), 0);
		    Setfile((yyval.p), cparse_file);
		    Setline((yyval.p), cparse_line);
		    if ((yyvsp[0].dtype).val) {
		      Setattr((yyval.p), "value", (yyvsp[0].dtype).val);
		    }
		  }
#line 9304 "CParse/parser.c"
    break;

  case 198: /* templateparameter: parm  */
#line 5364 "CParse/parser.y"
                         {
		    Parm *p = (yyvsp[0].p);
		    String *name = Getattr(p, "name");
		    (yyval.p) = (yyvsp[0].p);

		    /* Correct the 'type name' parameter string, split into the appropriate "name" and "type" attributes */
		    if (!name) {
		      String *type = Getattr(p, "type");
		      if ((Strncmp(type, "class ", 6) == 0) || (Strncmp(type, "typename ", 9) == 0)) {
			/* A 'class T' parameter */
			const char *t = Strchr(type, ' ');
			Setattr(p, "name", t + 1);
			Setattr(p, "type", NewStringWithSize(type, (int)(t - Char(type))));
		      } else if ((Strncmp(type, "v.class ", 8) == 0) || (Strncmp(type, "v.typename ", 11) == 0)) {
			/* Variadic template args */
			const char *t = Strchr(type, ' ');
			Setattr(p, "name", t + 1);
			Setattr(p, "type", NewStringWithSize(type, (int)(t - Char(type))));
		      }
                    } else {
                      /* C++20 type-constraint in template parameter list, e.g. 'Numeric T',
                       * 'std::floating_point T', 'Printable ...Ts'.  The 'parm' rule consumed
                       * the concept-id as an idcolon style rawtype; the classifier decides
                       * whether to remap to 'typename T' (or 'v.typename Ts...') plus a
                       * concept-id constraint atom on the parm's "constraint" attribute
                       * (the same parm representation promote_abbreviated_template() builds
                       * for 'Concept auto x'), to leave the parm as a non-type template
                       * parameter, or to flag the identifier as undeclared. */
                      SwigType *t = Getattr(p, "type");
                      int verdict = t ? classify_template_param_type(t) : TPC_KEEP;
                      if (verdict == TPC_REMAP || verdict == TPC_UNKNOWN) {
                        /* In keeping with SWIG's "best effort wrap on partial type information" policy,
                         * the unresolved (TPC_UNKNOWN) case is handled the same way as a confirmed concept
                         * (TPC_REMAP): rewrite the parm to 'typename T' and attach the captured concept-id
                         * as a constraint atom on the "constraint" attribute.  Reasoning:
                         *   - The wrapper SWIG eventually emits invokes the user's templated function
                         *     literally (e.g. 'cube< int >(arg1)') - whether SWIG saw the concept declaration
                         *     plays no part in that emission.  If the user's C++ build environment has the
                         *     concept visible the wrapper compiles; if not, the C++ compiler issues its own
                         *     clear "does not name a concept" error.
                         *   - In modern C++ a bare unknown identifier in template-parameter position is far
                         *     more likely a concept-id than a non-type template parameter type (NTTP) which
                         *     are almost always primitives or registered typedefs and reach TPC_KEEP via
                         *     SwigType_type / typedef resolution.  Defaulting to remap therefore has a
                         *     strictly smaller failure surface than rejecting outright.
                         * For TPC_UNKNOWN we additionally flag the parm with 'constraint:unresolved' so
                         * the %template instantiation path can warn about a missing concept-id, noting
                         * that an unused declaration that happens to reference an unparsed concept is silent. */
                        SwigType *new_type = NewString("typename");
                        String *concept_name = Copy(t);
                        Node *atom = Constraint_new_atom("concept-id");
                        if (SwigType_isvariadic(t)) {
                          SwigType_del_variadic(concept_name);
                          SwigType_add_variadic(new_type);
                        }
                        Setattr(atom, "type", concept_name);
                        Setattr(p, "constraint", atom);
                        Setattr(p, "type", new_type);
                        if (verdict == TPC_UNKNOWN)
                          SetFlag(p, "constraint:unresolved");
                        Delete(new_type);
                        Delete(concept_name);
                      }
                    }
                  }
#line 9374 "CParse/parser.c"
    break;

  case 199: /* cpp_using_decl: USING idcolon SEMI  */
#line 5433 "CParse/parser.y"
                                    {
                  String *uname = Swig_symbol_type_qualify((yyvsp[-1].str),0);
                  /* Possible TODO: In testcase using_member_multiple_inherit class Susing3, uname is "Susing1::usingmethod" instead of "Susing2::usingmethod" */
		  String *name = Swig_scopename_last((yyvsp[-1].str));
                  (yyval.node) = new_node("using");
		  Setattr((yyval.node),"uname",uname);
		  Setattr((yyval.node),"name", name);
		  Delete(uname);
		  Delete(name);
		  add_symbols((yyval.node));
             }
#line 9390 "CParse/parser.c"
    break;

  case 200: /* cpp_using_decl: USING using_conversion SEMI  */
#line 5444 "CParse/parser.y"
                                           {
                  /* Inherited conversion operator, e.g. "using Base::operator int;". */
                  String *uname = Swig_symbol_type_qualify((yyvsp[-1].str), 0);
                  String *name = Swig_scopename_last((yyvsp[-1].str));
                  (yyval.node) = new_node("using");
                  Setattr((yyval.node), "uname", uname);
                  Setattr((yyval.node), "name", name);
                  Delete(uname);
                  Delete(name);
                  add_symbols((yyval.node));
             }
#line 9406 "CParse/parser.c"
    break;

  case 201: /* cpp_using_decl: USING idcolon ELLIPSIS SEMI  */
#line 5455 "CParse/parser.y"
                                           {
                  /* C++17 pack expansion in a using-declaration, e.g. "using Ts::operator()...;" */
                  String *uname = Swig_symbol_type_qualify((yyvsp[-2].str), 0);
                  String *name  = Swig_scopename_last((yyvsp[-2].str));
                  (yyval.node) = new_node("using");
                  Setattr((yyval.node), "uname", uname);
                  Setattr((yyval.node), "name", name);
                  SetFlag((yyval.node), "pack");
                  Delete(uname);
                  Delete(name);
                  add_symbols((yyval.node));
             }
#line 9423 "CParse/parser.c"
    break;

  case 202: /* cpp_using_decl: USING TYPENAME idcolon SEMI  */
#line 5467 "CParse/parser.y"
                                           {
		  String *uname = Swig_symbol_type_qualify((yyvsp[-1].str),0);
		  String *name = Swig_scopename_last((yyvsp[-1].str));
		  (yyval.node) = new_node("using");
		  Setattr((yyval.node),"uname",uname);
		  Setattr((yyval.node),"name", name);
		  Delete(uname);
		  Delete(name);
		  add_symbols((yyval.node));
	     }
#line 9438 "CParse/parser.c"
    break;

  case 203: /* cpp_using_decl: USING TYPENAME idcolon ELLIPSIS SEMI  */
#line 5477 "CParse/parser.y"
                                                    {
                  /* C++17 member type pack expansion, e.g. "using typename Ts::type...;" */
                  String *uname = Swig_symbol_type_qualify((yyvsp[-2].str), 0);
                  String *name  = Swig_scopename_last((yyvsp[-2].str));
                  (yyval.node) = new_node("using");
                  Setattr((yyval.node), "uname", uname);
                  Setattr((yyval.node), "name", name);
                  SetFlag((yyval.node), "pack");
                  Delete(uname);
                  Delete(name);
                  add_symbols((yyval.node));
             }
#line 9455 "CParse/parser.c"
    break;

  case 204: /* cpp_using_decl: USING NAMESPACE idcolon SEMI  */
#line 5489 "CParse/parser.y"
                                            {
	       Node *n = Swig_symbol_clookup((yyvsp[-1].str),0);
	       if (!n) {
		 Swig_error(cparse_file, cparse_line, "Nothing known about namespace '%s'\n", SwigType_namestr((yyvsp[-1].str)));
		 (yyval.node) = 0;
	       } else {

		 while (Strcmp(nodeType(n),"using") == 0) {
		   n = Getattr(n,"node");
		 }
		 if (n) {
		   if (Strcmp(nodeType(n),"namespace") == 0) {
		     Symtab *current = Swig_symbol_current();
		     Symtab *symtab = Getattr(n,"symtab");
		     (yyval.node) = new_node("using");
		     Setattr((yyval.node),"node",n);
		     Setattr((yyval.node),"namespace", (yyvsp[-1].str));
		     if (current != symtab) {
		       Swig_symbol_inherit(symtab);
		     }
		   } else {
		     Swig_error(cparse_file, cparse_line, "'%s' is not a namespace.\n", SwigType_namestr((yyvsp[-1].str)));
		     (yyval.node) = 0;
		   }
		 } else {
		   (yyval.node) = 0;
		 }
	       }
             }
#line 9489 "CParse/parser.c"
    break;

  case 205: /* using_conversion: using_scope CONVERSIONOPERATOR type  */
#line 5524 "CParse/parser.y"
                                                       {
                  /* The conversion type was re-fed to the scanner and is reparsed here as 'type',
                     but it is already part of the CONVERSIONOPERATOR name, so it is discarded. */
                  (yyval.str) = NewStringf("%s%s", (yyvsp[-2].str), (yyvsp[-1].str));
                  Delete((yyvsp[-2].str));
                  Delete((yyvsp[-1].str));
                  Delete((yyvsp[0].type));
             }
#line 9502 "CParse/parser.c"
    break;

  case 206: /* using_scope: idtemplate DCOLON  */
#line 5534 "CParse/parser.y"
                                 {
                  (yyval.str) = NewStringf("%s::", (yyvsp[-1].str));
                  Delete((yyvsp[-1].str));
             }
#line 9511 "CParse/parser.c"
    break;

  case 207: /* @8: %empty  */
#line 5540 "CParse/parser.y"
                                                    {
                Hash *h;
		Node *parent_ns = 0;
		List *scopes = Swig_scopename_tolist((yyvsp[-1].str));
		int ilen = Len(scopes);
		int i;

/*
Printf(stdout, "==== Namespace %s creation...\n", $idcolon);
*/
		(yyval.node) = 0;
		for (i = 0; i < ilen; i++) {
		  Node *ns = new_node("namespace");
		  Symtab *current_symtab = Swig_symbol_current();
		  String *scopename = Getitem(scopes, i);
		  Setattr(ns, "name", scopename);
		  (yyval.node) = ns;
		  if (parent_ns)
		    appendChild(parent_ns, ns);
		  parent_ns = ns;
		  h = Swig_symbol_clookup(scopename, 0);
		  if (h && (current_symtab == Getattr(h, "sym:symtab")) && (Strcmp(nodeType(h), "namespace") == 0)) {
/*
Printf(stdout, "  Scope %s [found C++17 style]\n", scopename);
*/
		    if (Getattr(h, "alias")) {
		      h = Getattr(h, "namespace");
		      Swig_warning(WARN_PARSE_NAMESPACE_ALIAS, cparse_file, cparse_line, "Namespace alias '%s' not allowed here. Assuming '%s'\n",
				   scopename, Getattr(h, "name"));
		      scopename = Getattr(h, "name");
		    }
		    Swig_symbol_setscope(Getattr(h, "symtab"));
		  } else {
/*
Printf(stdout, "  Scope %s [creating single scope C++17 style]\n", scopename);
*/
		    h = Swig_symbol_newscope();
		    Swig_symbol_setscopename(scopename);
		  }
		  Delete(Namespaceprefix);
		  Namespaceprefix = Swig_symbol_qualifiedscopename(0);
		}
		Delete(scopes);
             }
#line 9560 "CParse/parser.c"
    break;

  case 208: /* cpp_namespace_decl: NAMESPACE idcolon LBRACE @8 interface RBRACE  */
#line 5583 "CParse/parser.y"
                                      {
		Node *n = (yyvsp[-2].node);
		Node *top_ns = 0;
		do {
		  Setattr(n, "symtab", Swig_symbol_popscope());
		  Delete(Namespaceprefix);
		  Namespaceprefix = Swig_symbol_qualifiedscopename(0);
		  add_symbols(n);
		  top_ns = n;
		  n = parentNode(n);
		} while(n);
		appendChild((yyvsp[-2].node), firstChild((yyvsp[-1].node)));
		Delete((yyvsp[-1].node));
		(yyval.node) = top_ns;
             }
#line 9580 "CParse/parser.c"
    break;

  case 209: /* @9: %empty  */
#line 5598 "CParse/parser.y"
                                      {
	       Hash *h;
	       (yyval.node) = Swig_symbol_current();
	       h = Swig_symbol_clookup("    ",0);
	       if (h && (Strcmp(nodeType(h),"namespace") == 0)) {
		 Swig_symbol_setscope(Getattr(h,"symtab"));
	       } else {
		 Swig_symbol_newscope();
		 /* we don't use "__unnamed__", but a long 'empty' name */
		 Swig_symbol_setscopename("    ");
	       }
	       Namespaceprefix = 0;
             }
#line 9598 "CParse/parser.c"
    break;

  case 210: /* cpp_namespace_decl: NAMESPACE LBRACE @9 interface RBRACE  */
#line 5610 "CParse/parser.y"
                                      {
	       (yyval.node) = (yyvsp[-1].node);
	       set_nodeType((yyval.node),"namespace");
	       Setattr((yyval.node),"unnamed","1");
	       Setattr((yyval.node),"symtab", Swig_symbol_popscope());
	       Swig_symbol_setscope((yyvsp[-2].node));
	       Delete(Namespaceprefix);
	       Namespaceprefix = Swig_symbol_qualifiedscopename(0);
	       add_symbols((yyval.node));
             }
#line 9613 "CParse/parser.c"
    break;

  case 211: /* cpp_namespace_decl: NAMESPACE identifier EQUAL idcolon SEMI  */
#line 5620 "CParse/parser.y"
                                                       {
	       /* Namespace alias */
	       Node *n;
	       (yyval.node) = new_node("namespace");
	       Setattr((yyval.node),"name",(yyvsp[-3].id));
	       Setattr((yyval.node),"alias",(yyvsp[-1].str));
	       n = Swig_symbol_clookup((yyvsp[-1].str),0);
	       if (!n) {
		 Swig_error(cparse_file, cparse_line, "Unknown namespace '%s'\n", SwigType_namestr((yyvsp[-1].str)));
		 (yyval.node) = 0;
	       } else {
		 if (Strcmp(nodeType(n),"namespace") != 0) {
		   Swig_error(cparse_file, cparse_line, "'%s' is not a namespace\n", SwigType_namestr((yyvsp[-1].str)));
		   (yyval.node) = 0;
		 } else {
		   while (Getattr(n,"alias")) {
		     n = Getattr(n,"namespace");
		   }
		   Setattr((yyval.node),"namespace",n);
		   add_symbols((yyval.node));
		   /* Set up a scope alias */
		   Swig_symbol_alias((yyvsp[-3].id),Getattr(n,"symtab"));
		 }
	       }
             }
#line 9643 "CParse/parser.c"
    break;

  case 212: /* cpp_members: cpp_members_builder  */
#line 5647 "CParse/parser.y"
                                  {
		 (yyval.node) = (yyvsp[0].nodebuilder).node;
	       }
#line 9651 "CParse/parser.c"
    break;

  case 213: /* cpp_members: cpp_members_builder DOXYGENSTRING  */
#line 5650 "CParse/parser.y"
                                                   {
		 /* Quietly ignore misplaced doxygen string after a member, like Doxygen does */
		 (yyval.node) = (yyvsp[-1].nodebuilder).node;
		 Delete((yyvsp[0].str));
	       }
#line 9661 "CParse/parser.c"
    break;

  case 214: /* cpp_members: %empty  */
#line 5655 "CParse/parser.y"
                        {
		 (yyval.node) = 0;
	       }
#line 9669 "CParse/parser.c"
    break;

  case 215: /* cpp_members: DOXYGENSTRING  */
#line 5658 "CParse/parser.y"
                               {
		 /* Quietly ignore misplaced doxygen string in empty class, like Doxygen does */
		 (yyval.node) = 0;
		 Delete((yyvsp[0].str));
	       }
#line 9679 "CParse/parser.c"
    break;

  case 216: /* cpp_members: error  */
#line 5663 "CParse/parser.y"
                       {
		 Swig_error(cparse_file, cparse_line, "Syntax error in input(3).\n");
		 Exit(EXIT_FAILURE);
	       }
#line 9688 "CParse/parser.c"
    break;

  case 217: /* cpp_members_builder: cpp_member  */
#line 5669 "CParse/parser.y"
                                 {
	     (yyval.nodebuilder).node = (yyval.nodebuilder).last = (yyvsp[0].node);
	   }
#line 9696 "CParse/parser.c"
    break;

  case 218: /* cpp_members_builder: cpp_members_builder cpp_member  */
#line 5672 "CParse/parser.y"
                                                {
	     // Build a linked list in the order specified, but avoiding
	     // a right recursion rule because "Right recursion uses up
	     // space on the Bison stack in proportion to the number of
	     // elements in the sequence".
	     if ((yyvsp[0].node)) {
	       if ((yyvsp[-1].nodebuilder).node) {
		 Node *last = (yyvsp[-1].nodebuilder).last;
		 /* Advance to the last sibling. */
		 for (Node *p = last; p; p = nextSibling(p)) {
		   last = p;
		 }
		 set_nextSibling(last, (yyvsp[0].node));
		 set_previousSibling((yyvsp[0].node), last);
		 (yyval.nodebuilder).node = (yyvsp[-1].nodebuilder).node;
	       } else {
		 (yyval.nodebuilder).node = (yyval.nodebuilder).last = (yyvsp[0].node);
	       }
	     } else {
	       (yyval.nodebuilder) = (yyvsp[-1].nodebuilder);
	     }
	   }
#line 9723 "CParse/parser.c"
    break;

  case 220: /* cpp_member_no_dox: cpp_constructor_decl  */
#line 5703 "CParse/parser.y"
                                    { 
                 (yyval.node) = (yyvsp[0].node); 
		 if (extendmode && current_class) {
		   String *symname;
		   symname= make_name((yyval.node),Getattr((yyval.node),"name"), Getattr((yyval.node),"decl"));
		   if (Strcmp(symname,Getattr((yyval.node),"name")) == 0) {
		     /* No renaming operation.  Set name to class name */
		     Delete(yyrename);
		     yyrename = NewString(Getattr(current_class,"sym:name"));
		   } else {
		     Delete(yyrename);
		     yyrename = symname;
		   }
		 }
		 add_symbols((yyval.node));
                 default_arguments((yyval.node));
             }
#line 9745 "CParse/parser.c"
    break;

  case 227: /* cpp_member_no_dox: storage_class idcolon SEMI  */
#line 5726 "CParse/parser.y"
                                          { (yyval.node) = 0; Delete((yyvsp[-2].str)); }
#line 9751 "CParse/parser.c"
    break;

  case 234: /* cpp_member_no_dox: anonymous_bitfield  */
#line 5733 "CParse/parser.y"
                                  { (yyval.node) = 0; }
#line 9757 "CParse/parser.c"
    break;

  case 237: /* cpp_member_no_dox: SEMI  */
#line 5736 "CParse/parser.y"
                    { (yyval.node) = 0; }
#line 9763 "CParse/parser.c"
    break;

  case 239: /* cpp_member: DOXYGENSTRING cpp_member_no_dox  */
#line 5739 "CParse/parser.y"
                                               {
	         (yyval.node) = (yyvsp[0].node);
		 set_comment((yyvsp[0].node), (yyvsp[-1].str));
	     }
#line 9772 "CParse/parser.c"
    break;

  case 240: /* cpp_member: cpp_member_no_dox DOXYGENPOSTSTRING  */
#line 5743 "CParse/parser.y"
                                                   {
	         (yyval.node) = (yyvsp[-1].node);
		 set_comment((yyvsp[-1].node), (yyvsp[0].str));
	     }
#line 9781 "CParse/parser.c"
    break;

  case 241: /* $@10: %empty  */
#line 5747 "CParse/parser.y"
                             {
	       extendmode = 1;
	       if (cplus_mode != CPLUS_PUBLIC) {
		 Swig_error(cparse_file,cparse_line,"%%extend can only be used in a public section\n");
	       }
	     }
#line 9792 "CParse/parser.c"
    break;

  case 242: /* cpp_member: EXTEND LBRACE $@10 cpp_members RBRACE  */
#line 5752 "CParse/parser.y"
                                  {
	       extendmode = 0;
	       (yyval.node) = new_node("extend");
	       mark_nodes_as_extend((yyvsp[-1].node));
	       appendChild((yyval.node), (yyvsp[-1].node));
	     }
#line 9803 "CParse/parser.c"
    break;

  case 243: /* cpp_constructor_decl: storage_class type LPAREN parms RPAREN ctor_end  */
#line 5766 "CParse/parser.y"
                                                                       {
	      /* Cannot be a constructor declaration/definition if parsed as a friend destructor/constructor
	         or a badly declared friend function without return type */
	      int isfriend = Strstr((yyvsp[-5].str), "friend") != NULL;
	      if (!isfriend && (inclass || extendmode)) {
	        String *name = SwigType_templateprefix((yyvsp[-4].type)); /* A constructor can optionally be declared with template parameters before C++20, strip these off */
		SwigType *decl = NewStringEmpty();
		(yyval.node) = new_node("constructor");
		Setattr((yyval.node),"storage",(yyvsp[-5].str));
		Setattr((yyval.node), "name", name);
		Setattr((yyval.node),"parms",(yyvsp[-2].pl));
		SwigType_add_function(decl,(yyvsp[-2].pl));
		Setattr((yyval.node),"decl",decl);
		Setattr((yyval.node),"throws",(yyvsp[0].decl).throws);
		Setattr((yyval.node),"throw",(yyvsp[0].decl).throwf);
		Setattr((yyval.node),"noexcept",(yyvsp[0].decl).nexcept);
		Setattr((yyval.node),"final",(yyvsp[0].decl).final);
		if ((yyvsp[0].decl).constraint_node)
		  Setattr((yyval.node), "constraint", (yyvsp[0].decl).constraint_node);
		if (Len(scanner_ccode)) {
		  String *code = Copy(scanner_ccode);
		  Setattr((yyval.node),"code",code);
		  Delete(code);
		}
		SetFlag((yyval.node),"feature:new");
		if ((yyvsp[0].decl).defarg)
		  Setattr((yyval.node), "value", (yyvsp[0].decl).defarg);
		if ((yyvsp[0].decl).stringdefarg)
		  Setattr((yyval.node), "stringval", (yyvsp[0].decl).stringdefarg);
		if ((yyvsp[0].decl).numdefarg)
		  Setattr((yyval.node), "numval", (yyvsp[0].decl).numdefarg);
	      } else {
		(yyval.node) = 0;
              }
	      Delete((yyvsp[-5].str));
              }
#line 9844 "CParse/parser.c"
    break;

  case 244: /* cpp_destructor_decl: storage_class NOT idtemplate LPAREN parms RPAREN cpp_vend  */
#line 5806 "CParse/parser.y"
                                                                                {
	       String *name = SwigType_templateprefix((yyvsp[-4].str)); /* A destructor can optionally be declared with template parameters before C++20, strip these off */
	       Insert(name, 0, "~");
	       (yyval.node) = new_node("destructor");
	       Setattr((yyval.node), "storage", (yyvsp[-6].str));
	       Setattr((yyval.node), "name", name);
	       Delete(name);
	       if (Len(scanner_ccode)) {
		 String *code = Copy(scanner_ccode);
		 Setattr((yyval.node), "code", code);
		 Delete(code);
	       }
	       {
		 String *decl = NewStringEmpty();
		 SwigType_add_function(decl, (yyvsp[-2].pl));
		 Setattr((yyval.node), "decl", decl);
		 Delete(decl);
	       }
	       Setattr((yyval.node), "throws", (yyvsp[0].dtype).throws);
	       Setattr((yyval.node), "throw", (yyvsp[0].dtype).throwf);
	       Setattr((yyval.node), "noexcept", (yyvsp[0].dtype).nexcept);
	       Setattr((yyval.node), "final", (yyvsp[0].dtype).final);
	       if ((yyvsp[0].dtype).val) {
		 if (Equal((yyvsp[0].dtype).val, "0")) {
		   if (!Strstr((yyvsp[-6].str), "virtual"))
		     Swig_error(cparse_file, cparse_line, "Destructor %s uses a pure specifier but is not virtual.\n", Swig_name_decl((yyval.node)));
		 } else if (!(Equal((yyvsp[0].dtype).val, "delete") || Equal((yyvsp[0].dtype).val, "default"))) {
		   Swig_error(cparse_file, cparse_line, "Destructor %s has an invalid pure specifier, only = 0 is allowed.\n", Swig_name_decl((yyval.node)));
		 }
		 Setattr((yyval.node), "value", (yyvsp[0].dtype).val);
	       }
	       /* TODO: check all storage decl-specifiers are valid */
	       if ((yyvsp[0].dtype).qualifier)
		 Swig_error(cparse_file, cparse_line, "Destructor %s %s cannot have a qualifier.\n", Swig_name_decl((yyval.node)), SwigType_str((yyvsp[0].dtype).qualifier, 0));
	       add_symbols((yyval.node));
	       Delete((yyvsp[-6].str));
	      }
#line 9886 "CParse/parser.c"
    break;

  case 245: /* cpp_conversion_operator: storage_class CONVERSIONOPERATOR type pointer LPAREN parms RPAREN cpp_vend  */
#line 5847 "CParse/parser.y"
                                                                                                     {
                 (yyval.node) = new_node("cdecl");
                 Setattr((yyval.node),"type",(yyvsp[-5].type));
		 Setattr((yyval.node),"name",(yyvsp[-6].str));
		 Setattr((yyval.node),"storage",(yyvsp[-7].str));

		 SwigType_add_function((yyvsp[-4].type),(yyvsp[-2].pl));
		 if ((yyvsp[0].dtype).qualifier) {
		   SwigType_push((yyvsp[-4].type),(yyvsp[0].dtype).qualifier);
		 }
		 if ((yyvsp[0].dtype).val) {
		   Setattr((yyval.node),"value",(yyvsp[0].dtype).val);
		 }
		 Setattr((yyval.node),"refqualifier",(yyvsp[0].dtype).refqualifier);
		 Setattr((yyval.node),"decl",(yyvsp[-4].type));
		 Setattr((yyval.node),"parms",(yyvsp[-2].pl));
		 Setattr((yyval.node),"conversion_operator","1");
		 add_symbols((yyval.node));
		 Delete((yyvsp[-6].str));
		 Delete((yyvsp[-7].str));
              }
#line 9912 "CParse/parser.c"
    break;

  case 246: /* cpp_conversion_operator: storage_class CONVERSIONOPERATOR type AND LPAREN parms RPAREN cpp_vend  */
#line 5868 "CParse/parser.y"
                                                                                        {
		 SwigType *decl;
                 (yyval.node) = new_node("cdecl");
                 Setattr((yyval.node),"type",(yyvsp[-5].type));
		 Setattr((yyval.node),"name",(yyvsp[-6].str));
		 Setattr((yyval.node),"storage",(yyvsp[-7].str));
		 decl = NewStringEmpty();
		 SwigType_add_reference(decl);
		 SwigType_add_function(decl,(yyvsp[-2].pl));
		 if ((yyvsp[0].dtype).qualifier) {
		   SwigType_push(decl,(yyvsp[0].dtype).qualifier);
		 }
		 if ((yyvsp[0].dtype).val) {
		   Setattr((yyval.node),"value",(yyvsp[0].dtype).val);
		 }
		 Setattr((yyval.node),"refqualifier",(yyvsp[0].dtype).refqualifier);
		 Setattr((yyval.node),"decl",decl);
		 Setattr((yyval.node),"parms",(yyvsp[-2].pl));
		 Setattr((yyval.node),"conversion_operator","1");
		 add_symbols((yyval.node));
		 Delete((yyvsp[-6].str));
		 Delete((yyvsp[-7].str));
	       }
#line 9940 "CParse/parser.c"
    break;

  case 247: /* cpp_conversion_operator: storage_class CONVERSIONOPERATOR type LAND LPAREN parms RPAREN cpp_vend  */
#line 5891 "CParse/parser.y"
                                                                                         {
		 SwigType *decl;
                 (yyval.node) = new_node("cdecl");
                 Setattr((yyval.node),"type",(yyvsp[-5].type));
		 Setattr((yyval.node),"name",(yyvsp[-6].str));
		 Setattr((yyval.node),"storage",(yyvsp[-7].str));
		 decl = NewStringEmpty();
		 SwigType_add_rvalue_reference(decl);
		 SwigType_add_function(decl,(yyvsp[-2].pl));
		 if ((yyvsp[0].dtype).qualifier) {
		   SwigType_push(decl,(yyvsp[0].dtype).qualifier);
		 }
		 if ((yyvsp[0].dtype).val) {
		   Setattr((yyval.node),"value",(yyvsp[0].dtype).val);
		 }
		 Setattr((yyval.node),"refqualifier",(yyvsp[0].dtype).refqualifier);
		 Setattr((yyval.node),"decl",decl);
		 Setattr((yyval.node),"parms",(yyvsp[-2].pl));
		 Setattr((yyval.node),"conversion_operator","1");
		 add_symbols((yyval.node));
		 Delete((yyvsp[-6].str));
		 Delete((yyvsp[-7].str));
	       }
#line 9968 "CParse/parser.c"
    break;

  case 248: /* cpp_conversion_operator: storage_class CONVERSIONOPERATOR type pointer AND LPAREN parms RPAREN cpp_vend  */
#line 5915 "CParse/parser.y"
                                                                                                {
		 SwigType *decl;
                 (yyval.node) = new_node("cdecl");
                 Setattr((yyval.node),"type",(yyvsp[-6].type));
		 Setattr((yyval.node),"name",(yyvsp[-7].str));
		 Setattr((yyval.node),"storage",(yyvsp[-8].str));
		 decl = NewStringEmpty();
		 SwigType_add_pointer(decl);
		 SwigType_add_reference(decl);
		 SwigType_add_function(decl,(yyvsp[-2].pl));
		 if ((yyvsp[0].dtype).qualifier) {
		   SwigType_push(decl,(yyvsp[0].dtype).qualifier);
		 }
		 if ((yyvsp[0].dtype).val) {
		   Setattr((yyval.node),"value",(yyvsp[0].dtype).val);
		 }
		 Setattr((yyval.node),"refqualifier",(yyvsp[0].dtype).refqualifier);
		 Setattr((yyval.node),"decl",decl);
		 Setattr((yyval.node),"parms",(yyvsp[-2].pl));
		 Setattr((yyval.node),"conversion_operator","1");
		 add_symbols((yyval.node));
		 Delete((yyvsp[-7].str));
		 Delete((yyvsp[-8].str));
	       }
#line 9997 "CParse/parser.c"
    break;

  case 249: /* cpp_conversion_operator: storage_class CONVERSIONOPERATOR type LPAREN parms RPAREN cpp_vend  */
#line 5940 "CParse/parser.y"
                                                                                   {
		String *t = NewStringEmpty();
		(yyval.node) = new_node("cdecl");
		Setattr((yyval.node),"type",(yyvsp[-4].type));
		Setattr((yyval.node),"name",(yyvsp[-5].str));
		 Setattr((yyval.node),"storage",(yyvsp[-6].str));
		SwigType_add_function(t,(yyvsp[-2].pl));
		if ((yyvsp[0].dtype).qualifier) {
		  SwigType_push(t,(yyvsp[0].dtype).qualifier);
		}
		if ((yyvsp[0].dtype).val) {
		  Setattr((yyval.node),"value",(yyvsp[0].dtype).val);
		}
		Setattr((yyval.node),"refqualifier",(yyvsp[0].dtype).refqualifier);
		Setattr((yyval.node),"decl",t);
		Setattr((yyval.node),"parms",(yyvsp[-2].pl));
		Setattr((yyval.node),"conversion_operator","1");
		add_symbols((yyval.node));
		Delete((yyvsp[-5].str));
		Delete((yyvsp[-6].str));
              }
#line 10023 "CParse/parser.c"
    break;

  case 250: /* cpp_catch_decl: CATCH LPAREN parms RPAREN LBRACE  */
#line 5965 "CParse/parser.y"
                                                  {
                 if (skip_balanced('{','}') < 0) Exit(EXIT_FAILURE);
                 (yyval.node) = 0;
               }
#line 10032 "CParse/parser.c"
    break;

  case 251: /* cpp_static_assert: STATIC_ASSERT LPAREN  */
#line 5973 "CParse/parser.y"
                                         {
                if (skip_balanced('(',')') < 0) Exit(EXIT_FAILURE);
                (yyval.node) = 0;
              }
#line 10041 "CParse/parser.c"
    break;

  case 252: /* cpp_protection_decl: PUBLIC COLON  */
#line 5980 "CParse/parser.y"
                                   { 
                (yyval.node) = new_node("access");
		Setattr((yyval.node),"kind","public");
                cplus_mode = CPLUS_PUBLIC;
              }
#line 10051 "CParse/parser.c"
    break;

  case 253: /* cpp_protection_decl: PRIVATE COLON  */
#line 5987 "CParse/parser.y"
                              { 
                (yyval.node) = new_node("access");
                Setattr((yyval.node),"kind","private");
		cplus_mode = CPLUS_PRIVATE;
	      }
#line 10061 "CParse/parser.c"
    break;

  case 254: /* cpp_protection_decl: PROTECTED COLON  */
#line 5995 "CParse/parser.y"
                                { 
		(yyval.node) = new_node("access");
		Setattr((yyval.node),"kind","protected");
		cplus_mode = CPLUS_PROTECTED;
	      }
#line 10071 "CParse/parser.c"
    break;

  case 265: /* cpp_vend: cpp_const SEMI  */
#line 6018 "CParse/parser.y"
                                { 
                     Clear(scanner_ccode);
                     (yyval.dtype) = (yyvsp[-1].dtype);
               }
#line 10080 "CParse/parser.c"
    break;

  case 266: /* cpp_vend: cpp_const EQUAL definetype SEMI  */
#line 6022 "CParse/parser.y"
                                                 { 
                     Clear(scanner_ccode);
                     (yyval.dtype) = (yyvsp[-3].dtype);
                     (yyval.dtype).val = (yyvsp[-1].dtype).val;
               }
#line 10090 "CParse/parser.c"
    break;

  case 267: /* cpp_vend: cpp_const LBRACE  */
#line 6027 "CParse/parser.y"
                                  { 
                     if (skip_balanced('{','}') < 0) Exit(EXIT_FAILURE);
                     (yyval.dtype) = (yyvsp[-1].dtype);
               }
#line 10099 "CParse/parser.c"
    break;

  case 268: /* anonymous_bitfield: storage_class anon_bitfield_type COLON expr SEMI  */
#line 6034 "CParse/parser.y"
                                                                       {
                   /* swig4ada: A bit-field with no name takes part in the layout of its class, so its line, width
                      and type are noted on the class, for a language module which lays the class out itself. */
                   if (currentOuterClass) {
                     List *fields = Getattr(currentOuterClass, "anonymous_bitfields");
                     String *field = NewStringf("%d|%s|%s", cparse_line, (yyvsp[-1].dtype).val, (yyvsp[-3].type));
                     if (!fields) {
                       fields = NewList();
                       Setattr(currentOuterClass, "anonymous_bitfields", fields);
                       Delete(fields);
                       fields = Getattr(currentOuterClass, "anonymous_bitfields");
                     }
                     Append(fields, field);
                     Delete(field);
                   }
                   Delete((yyvsp[-4].str));
                 }
#line 10121 "CParse/parser.c"
    break;

  case 272: /* anon_bitfield_type: idcolon  */
#line 6057 "CParse/parser.y"
                         { (yyval.type) = (yyvsp[0].str); }
#line 10127 "CParse/parser.c"
    break;

  case 273: /* storage_class: storage_class_list  */
#line 6063 "CParse/parser.y"
                                    {
		 String *r = NewStringEmpty();

		 /* Check for invalid combinations. */
		 if (multiple_bits_set((yyvsp[0].intvalue) & (SWIG_STORAGE_CLASS_EXTERN |
					     SWIG_STORAGE_CLASS_STATIC))) {
		   Swig_error(cparse_file, cparse_line, "Storage class can't be both 'static' and 'extern'");
		 }
		 if (multiple_bits_set((yyvsp[0].intvalue) & (SWIG_STORAGE_CLASS_EXTERNC |
					     SWIG_STORAGE_CLASS_EXTERN |
					     SWIG_STORAGE_CLASS_EXTERNCPP))) {
		   Swig_error(cparse_file, cparse_line, "Declaration can only be one of 'extern', 'extern \"C\"' and 'extern \"C++\"'");
		 }

		 if ((yyvsp[0].intvalue) & SWIG_STORAGE_CLASS_TYPEDEF) {
		   Append(r, "typedef ");
		 } else {
		   if ((yyvsp[0].intvalue) & SWIG_STORAGE_CLASS_EXTERNC)
		     Append(r, "externc ");
		   if ((yyvsp[0].intvalue) & (SWIG_STORAGE_CLASS_EXTERN|SWIG_STORAGE_CLASS_EXTERNCPP))
		     Append(r, "extern ");
		   if ((yyvsp[0].intvalue) & SWIG_STORAGE_CLASS_STATIC)
		     Append(r, "static ");
		 }
		 if ((yyvsp[0].intvalue) & SWIG_STORAGE_CLASS_VIRTUAL)
		   Append(r, "virtual ");
		 if ((yyvsp[0].intvalue) & SWIG_STORAGE_CLASS_FRIEND)
		   Append(r, "friend ");
		 if ((yyvsp[0].intvalue) & SWIG_STORAGE_CLASS_EXPLICIT)
		   Append(r, "explicit ");
		 if ((yyvsp[0].intvalue) & SWIG_STORAGE_CLASS_CONSTEXPR)
		   Append(r, "constexpr ");
		 if ((yyvsp[0].intvalue) & SWIG_STORAGE_CLASS_THREAD_LOCAL)
		   Append(r, "thread_local ");
		 if (Len(r) == 0) {
		   Delete(r);
		   (yyval.str) = 0;
		 } else {
		   Chop(r);
		   (yyval.str) = r;
		 }
	       }
#line 10174 "CParse/parser.c"
    break;

  case 274: /* storage_class: %empty  */
#line 6105 "CParse/parser.y"
                        { (yyval.str) = 0; }
#line 10180 "CParse/parser.c"
    break;

  case 276: /* storage_class_list: storage_class_list storage_class_raw  */
#line 6109 "CParse/parser.y"
                                                          {
		  if ((yyvsp[-1].intvalue) & (yyvsp[0].intvalue)) {
		    Swig_error(cparse_file, cparse_line, "Repeated storage class or type specifier '%s'\n", storage_class_string((yyvsp[0].intvalue)));
		  }
		  (yyval.intvalue) = (yyvsp[-1].intvalue) | (yyvsp[0].intvalue);
	       }
#line 10191 "CParse/parser.c"
    break;

  case 277: /* storage_class_raw: EXTERN  */
#line 6117 "CParse/parser.y"
                            { (yyval.intvalue) = SWIG_STORAGE_CLASS_EXTERN; }
#line 10197 "CParse/parser.c"
    break;

  case 278: /* storage_class_raw: EXTERN string  */
#line 6118 "CParse/parser.y"
                               {
		   if (Strcmp((yyvsp[0].str),"C") == 0) {
		     (yyval.intvalue) = SWIG_STORAGE_CLASS_EXTERNC;
		   } else if (Strcmp((yyvsp[0].str),"C++") == 0) {
		     (yyval.intvalue) = SWIG_STORAGE_CLASS_EXTERNCPP;
		   } else {
		     Swig_warning(WARN_PARSE_UNDEFINED_EXTERN,cparse_file, cparse_line,"Unrecognized extern type \"%s\".\n", (yyvsp[0].str));
		     (yyval.intvalue) = 0;
		   }
	       }
#line 10212 "CParse/parser.c"
    break;

  case 279: /* storage_class_raw: STATIC  */
#line 6128 "CParse/parser.y"
                        { (yyval.intvalue) = SWIG_STORAGE_CLASS_STATIC; }
#line 10218 "CParse/parser.c"
    break;

  case 280: /* storage_class_raw: TYPEDEF  */
#line 6129 "CParse/parser.y"
                         { (yyval.intvalue) = SWIG_STORAGE_CLASS_TYPEDEF; }
#line 10224 "CParse/parser.c"
    break;

  case 281: /* storage_class_raw: VIRTUAL  */
#line 6130 "CParse/parser.y"
                         { (yyval.intvalue) = SWIG_STORAGE_CLASS_VIRTUAL; }
#line 10230 "CParse/parser.c"
    break;

  case 282: /* storage_class_raw: FRIEND  */
#line 6131 "CParse/parser.y"
                        { (yyval.intvalue) = SWIG_STORAGE_CLASS_FRIEND; }
#line 10236 "CParse/parser.c"
    break;

  case 283: /* storage_class_raw: EXPLICIT  */
#line 6132 "CParse/parser.y"
                          { (yyval.intvalue) = SWIG_STORAGE_CLASS_EXPLICIT; }
#line 10242 "CParse/parser.c"
    break;

  case 284: /* storage_class_raw: CONSTEXPR  */
#line 6133 "CParse/parser.y"
                           { (yyval.intvalue) = SWIG_STORAGE_CLASS_CONSTEXPR; }
#line 10248 "CParse/parser.c"
    break;

  case 285: /* storage_class_raw: THREAD_LOCAL  */
#line 6134 "CParse/parser.y"
                              { (yyval.intvalue) = SWIG_STORAGE_CLASS_THREAD_LOCAL; }
#line 10254 "CParse/parser.c"
    break;

  case 286: /* parms: rawparms  */
#line 6141 "CParse/parser.y"
                          {
                 Parm *p;
		 (yyval.pl) = (yyvsp[0].pl);
		 p = (yyvsp[0].pl);
                 while (p) {
		   Replace(Getattr(p,"type"),"typename ", "", DOH_REPLACE_ANY);
		   p = nextSibling(p);
                 }
               }
#line 10268 "CParse/parser.c"
    break;

  case 287: /* rawparms: parm  */
#line 6153 "CParse/parser.y"
                       { (yyval.pl) = (yyvsp[0].p); }
#line 10274 "CParse/parser.c"
    break;

  case 288: /* rawparms: parm DOXYGENPOSTSTRING  */
#line 6154 "CParse/parser.y"
                                         {
		  set_comment((yyvsp[-1].p), (yyvsp[0].str));
		  (yyval.pl) = (yyvsp[-1].p);
		}
#line 10283 "CParse/parser.c"
    break;

  case 289: /* rawparms: parm DOXYGENSTRING  */
#line 6158 "CParse/parser.y"
                                     {
		  /* Misplaced doxygen string, attach it to previous parameter, like Doxygen does */
		  set_comment((yyvsp[-1].p), (yyvsp[0].str));
		  (yyval.pl) = (yyvsp[-1].p);
		}
#line 10293 "CParse/parser.c"
    break;

  case 290: /* rawparms: parm COMMA parms  */
#line 6163 "CParse/parser.y"
                                   {
		  if ((yyvsp[0].pl)) {
		    set_nextSibling((yyvsp[-2].p), (yyvsp[0].pl));
		  }
		  (yyval.pl) = (yyvsp[-2].p);
		}
#line 10304 "CParse/parser.c"
    break;

  case 291: /* rawparms: parm DOXYGENPOSTSTRING COMMA parms  */
#line 6169 "CParse/parser.y"
                                                     {
		  if ((yyvsp[0].pl)) {
		    set_nextSibling((yyvsp[-3].p), (yyvsp[0].pl));
		  }
		  set_comment((yyvsp[-3].p), (yyvsp[-2].str));
		  (yyval.pl) = (yyvsp[-3].p);
		}
#line 10316 "CParse/parser.c"
    break;

  case 292: /* rawparms: parm COMMA DOXYGENPOSTSTRING parms  */
#line 6176 "CParse/parser.y"
                                                     {
		  if ((yyvsp[0].pl)) {
		    set_nextSibling((yyvsp[-3].p), (yyvsp[0].pl));
		  }
		  set_comment((yyvsp[-3].p), (yyvsp[-1].str));
		  (yyval.pl) = (yyvsp[-3].p);
		}
#line 10328 "CParse/parser.c"
    break;

  case 293: /* rawparms: %empty  */
#line 6183 "CParse/parser.y"
                         {
		  (yyval.pl) = 0;
		}
#line 10336 "CParse/parser.c"
    break;

  case 294: /* parm_no_dox: rawtype parameter_declarator  */
#line 6188 "CParse/parser.y"
                                               {
                   SwigType_push((yyvsp[-1].type),(yyvsp[0].decl).type);
		   (yyval.p) = NewParmWithoutFileLineInfo((yyvsp[-1].type),(yyvsp[0].decl).id);
		   Setfile((yyval.p),cparse_file);
		   Setline((yyval.p),cparse_line);
		   if ((yyvsp[0].decl).defarg)
		     Setattr((yyval.p), "value", (yyvsp[0].decl).defarg);
		   if ((yyvsp[0].decl).stringdefarg)
		     Setattr((yyval.p), "stringval", (yyvsp[0].decl).stringdefarg);
		   if ((yyvsp[0].decl).numdefarg)
		     Setattr((yyval.p), "numval", (yyvsp[0].decl).numdefarg);
		}
#line 10353 "CParse/parser.c"
    break;

  case 295: /* parm_no_dox: AUTO parameter_declarator  */
#line 6200 "CParse/parser.y"
                                            {
                   /* C++14 generic lambda / C++20 abbreviated function template parm, e.g. 'auto x'.  Placed in parm_no_dox
                    * rather than type_right so it does not collide with the 'storage_class AUTO declarator ...' rules. */
                   SwigType *t = NewString("auto");
                   SwigType_push(t, (yyvsp[0].decl).type);
                   (yyval.p) = NewParmWithoutFileLineInfo(t, (yyvsp[0].decl).id);
                   Setfile((yyval.p), cparse_file);
                   Setline((yyval.p), cparse_line);
                   if ((yyvsp[0].decl).defarg)
                     Setattr((yyval.p), "value", (yyvsp[0].decl).defarg);
                   if ((yyvsp[0].decl).stringdefarg)
                     Setattr((yyval.p), "stringval", (yyvsp[0].decl).stringdefarg);
                   if ((yyvsp[0].decl).numdefarg)
                     Setattr((yyval.p), "numval", (yyvsp[0].decl).numdefarg);
                }
#line 10373 "CParse/parser.c"
    break;

  case 296: /* parm_no_dox: idcolon AUTO parameter_declarator  */
#line 6215 "CParse/parser.y"
                                                    {
                   /* C++20 abbreviated function template with concept type-constraint, e.g. 'Numeric auto x'. */
                   SwigType *t = NewStringf("c(%s)", (yyvsp[-2].str));
                   SwigType_push(t, "auto.");
                   SwigType_push(t, (yyvsp[0].decl).type);
                   (yyval.p) = NewParmWithoutFileLineInfo(t, (yyvsp[0].decl).id);
                   Setfile((yyval.p), cparse_file);
                   Setline((yyval.p), cparse_line);
                   if ((yyvsp[0].decl).defarg)
                     Setattr((yyval.p), "value", (yyvsp[0].decl).defarg);
                   if ((yyvsp[0].decl).stringdefarg)
                     Setattr((yyval.p), "stringval", (yyvsp[0].decl).stringdefarg);
                   if ((yyvsp[0].decl).numdefarg)
                     Setattr((yyval.p), "numval", (yyvsp[0].decl).numdefarg);
                }
#line 10393 "CParse/parser.c"
    break;

  case 297: /* parm_no_dox: type_qualifier AUTO parameter_declarator  */
#line 6230 "CParse/parser.y"
                                                           {
                   /* C++20 abbreviated function template with a CV-qualifier on the auto placeholder, e.g.
                    * 'const auto x', 'const auto& x', 'volatile auto* x'. */
                   SwigType *t = NewString("auto");
                   SwigType_push(t, (yyvsp[-2].str));
                   SwigType_push(t, (yyvsp[0].decl).type);
                   (yyval.p) = NewParmWithoutFileLineInfo(t, (yyvsp[0].decl).id);
                   Setfile((yyval.p), cparse_file);
                   Setline((yyval.p), cparse_line);
                   if ((yyvsp[0].decl).defarg)
                     Setattr((yyval.p), "value", (yyvsp[0].decl).defarg);
                   if ((yyvsp[0].decl).stringdefarg)
                     Setattr((yyval.p), "stringval", (yyvsp[0].decl).stringdefarg);
                   if ((yyvsp[0].decl).numdefarg)
                     Setattr((yyval.p), "numval", (yyvsp[0].decl).numdefarg);
                }
#line 10414 "CParse/parser.c"
    break;

  case 298: /* parm_no_dox: type_qualifier idcolon AUTO parameter_declarator  */
#line 6246 "CParse/parser.y"
                                                                   {
                   /* C++20 abbreviated function template with a CV-qualified type-constraint, e.g. 'const Numeric auto& x'. */
                   SwigType *t = NewStringf("c(%s)", (yyvsp[-2].str));
                   SwigType_push(t, "auto.");
                   SwigType_push(t, (yyvsp[-3].str));
                   SwigType_push(t, (yyvsp[0].decl).type);
                   (yyval.p) = NewParmWithoutFileLineInfo(t, (yyvsp[0].decl).id);
                   Setfile((yyval.p), cparse_file);
                   Setline((yyval.p), cparse_line);
                   if ((yyvsp[0].decl).defarg)
                     Setattr((yyval.p), "value", (yyvsp[0].decl).defarg);
                   if ((yyvsp[0].decl).stringdefarg)
                     Setattr((yyval.p), "stringval", (yyvsp[0].decl).stringdefarg);
                   if ((yyvsp[0].decl).numdefarg)
                     Setattr((yyval.p), "numval", (yyvsp[0].decl).numdefarg);
                }
#line 10435 "CParse/parser.c"
    break;

  case 299: /* parm_no_dox: ELLIPSIS  */
#line 6262 "CParse/parser.y"
                           {
		  SwigType *t = NewString("v(...)");
		  (yyval.p) = NewParmWithoutFileLineInfo(t, 0);
		  Setfile((yyval.p),cparse_file);
		  Setline((yyval.p),cparse_line);
		}
#line 10446 "CParse/parser.c"
    break;

  case 301: /* parm: DOXYGENSTRING parm_no_dox  */
#line 6271 "CParse/parser.y"
                                            {
		  (yyval.p) = (yyvsp[0].p);
		  set_comment((yyvsp[0].p), (yyvsp[-1].str));
		}
#line 10455 "CParse/parser.c"
    break;

  case 302: /* valparms: valparms_builder  */
#line 6277 "CParse/parser.y"
                            {
		 (yyval.p) = (yyvsp[0].pbuilder).parms;
                 for (Parm *p = (yyval.p); p; p = nextSibling(p)) {
		   if (Getattr(p,"type")) {
		     Replace(Getattr(p,"type"),"typename ", "", DOH_REPLACE_ANY);
		   }
                 }
	       }
#line 10468 "CParse/parser.c"
    break;

  case 303: /* valparms: %empty  */
#line 6285 "CParse/parser.y"
                        {
		 (yyval.p) = 0;
	       }
#line 10476 "CParse/parser.c"
    break;

  case 304: /* valparms_builder: valparm  */
#line 6290 "CParse/parser.y"
                           {
		    (yyval.pbuilder).parms = (yyval.pbuilder).last = (yyvsp[0].p);
		  }
#line 10484 "CParse/parser.c"
    break;

  case 305: /* valparms_builder: valparms_builder COMMA valparm  */
#line 6293 "CParse/parser.y"
                                                       {
		    // Build a linked list in the order specified, but avoiding
		    // a right recursion rule because "Right recursion uses up
		    // space on the Bison stack in proportion to the number of
		    // elements in the sequence".
		    set_nextSibling((yyvsp[-2].pbuilder).last, (yyvsp[0].p));
		    (yyval.pbuilder).parms = (yyvsp[-2].pbuilder).parms;
		    (yyval.pbuilder).last = (yyvsp[0].p);
		  }
#line 10498 "CParse/parser.c"
    break;

  case 306: /* valparm: parm  */
#line 6304 "CParse/parser.y"
                      {
		  (yyval.p) = (yyvsp[0].p);
		  {
		    /* We need to make a possible adjustment for integer parameters. */
		    SwigType *type;
		    Node     *n = 0;

		    while (!n) {
		      type = Getattr((yyvsp[0].p),"type");
		      n = Swig_symbol_clookup(type,0);     /* See if we can find a node that matches the typename */
		      if ((n) && (Strcmp(nodeType(n),"cdecl") == 0)) {
			SwigType *decl = Getattr(n,"decl");
			if (!SwigType_isfunction(decl)) {
			  String *value = Getattr(n,"value");
			  if (value) {
			    String *v = Copy(value);
			    Setattr((yyvsp[0].p),"type",v);
			    Delete(v);
			    n = 0;
			  }
			}
		      } else {
			break;
		      }
		    }
		  }

               }
#line 10531 "CParse/parser.c"
    break;

  case 307: /* valparm: valexpr  */
#line 6332 "CParse/parser.y"
                         {
                  (yyval.p) = NewParmWithoutFileLineInfo(0,0);
                  Setfile((yyval.p),cparse_file);
		  Setline((yyval.p),cparse_line);
		  Setattr((yyval.p),"value",(yyvsp[0].dtype).val);
		  if ((yyvsp[0].dtype).stringval) Setattr((yyval.p), "stringval", (yyvsp[0].dtype).stringval);
		  if ((yyvsp[0].dtype).numval) Setattr((yyval.p), "numval", (yyvsp[0].dtype).numval);
               }
#line 10544 "CParse/parser.c"
    break;

  case 308: /* def_args: EQUAL definetype  */
#line 6342 "CParse/parser.y"
                                  { 
                 (yyval.dtype) = (yyvsp[0].dtype);
               }
#line 10552 "CParse/parser.c"
    break;

  case 309: /* def_args: EQUAL definetype LBRACKET  */
#line 6345 "CParse/parser.y"
                                           {
		 if (skip_balanced('[', ']') < 0) Exit(EXIT_FAILURE);
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).type = T_UNKNOWN;
		 (yyval.dtype).val = (yyvsp[-1].dtype).val;
		 Append((yyval.dtype).val, scanner_ccode);
		 Clear(scanner_ccode);
               }
#line 10565 "CParse/parser.c"
    break;

  case 310: /* def_args: EQUAL LBRACE  */
#line 6353 "CParse/parser.y"
                              {
		 if (skip_balanced('{','}') < 0) Exit(EXIT_FAILURE);
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewString(scanner_ccode);
		 (yyval.dtype).type = T_UNKNOWN;
	       }
#line 10576 "CParse/parser.c"
    break;

  case 311: /* def_args: %empty  */
#line 6359 "CParse/parser.y"
                        {
		 (yyval.dtype) = default_dtype;
                 (yyval.dtype).type = T_UNKNOWN;
               }
#line 10585 "CParse/parser.c"
    break;

  case 312: /* parameter_declarator: declarator def_args  */
#line 6365 "CParse/parser.y"
                                           {
                 (yyval.decl) = (yyvsp[-1].decl);
		 (yyval.decl).defarg = (yyvsp[0].dtype).val;
		 (yyval.decl).stringdefarg = (yyvsp[0].dtype).stringval;
		 (yyval.decl).numdefarg = (yyvsp[0].dtype).numval;
            }
#line 10596 "CParse/parser.c"
    break;

  case 313: /* parameter_declarator: abstract_declarator def_args  */
#line 6371 "CParse/parser.y"
                                           {
	      (yyval.decl) = (yyvsp[-1].decl);
	      (yyval.decl).defarg = (yyvsp[0].dtype).val;
	      (yyval.decl).stringdefarg = (yyvsp[0].dtype).stringval;
	      (yyval.decl).numdefarg = (yyvsp[0].dtype).numval;
            }
#line 10607 "CParse/parser.c"
    break;

  case 314: /* parameter_declarator: def_args  */
#line 6377 "CParse/parser.y"
                       {
	      (yyval.decl) = default_decl;
	      (yyval.decl).defarg = (yyvsp[0].dtype).val;
	      (yyval.decl).stringdefarg = (yyvsp[0].dtype).stringval;
	      (yyval.decl).numdefarg = (yyvsp[0].dtype).numval;
            }
#line 10618 "CParse/parser.c"
    break;

  case 315: /* parameter_declarator: direct_declarator LPAREN parms RPAREN qualifiers_exception_specification  */
#line 6385 "CParse/parser.y"
                                                                                       {
	      SwigType *t;
	      (yyval.decl) = (yyvsp[-4].decl);
	      t = NewStringEmpty();
	      SwigType_add_function(t,(yyvsp[-2].pl));
	      if ((yyvsp[0].dtype).qualifier)
		SwigType_push(t, (yyvsp[0].dtype).qualifier);
	      if ((yyvsp[0].dtype).nexcept)
		SwigType_add_qualifier(t, "noexcept");
	      if (!(yyval.decl).have_parms) {
		(yyval.decl).parms = (yyvsp[-2].pl);
		(yyval.decl).have_parms = 1;
	      }
	      if (!(yyval.decl).type) {
		(yyval.decl).type = t;
	      } else {
		SwigType_push(t, (yyval.decl).type);
		Delete((yyval.decl).type);
		(yyval.decl).type = t;
	      }
	    }
#line 10644 "CParse/parser.c"
    break;

  case 316: /* plain_declarator: declarator  */
#line 6408 "CParse/parser.y"
                              {
                 (yyval.decl) = (yyvsp[0].decl);
		 if (SwigType_isfunction((yyvsp[0].decl).type)) {
		   Delete(SwigType_pop_function((yyvsp[0].decl).type));
		 } else if (SwigType_isarray((yyvsp[0].decl).type)) {
		   SwigType *ta = SwigType_pop_arrays((yyvsp[0].decl).type);
		   if (SwigType_isfunction((yyvsp[0].decl).type)) {
		     Delete(SwigType_pop_function((yyvsp[0].decl).type));
		   } else {
		     (yyval.decl).parms = 0;
		   }
		   SwigType_push((yyvsp[0].decl).type,ta);
		   Delete(ta);
		 } else {
		   (yyval.decl).parms = 0;
		 }
            }
#line 10666 "CParse/parser.c"
    break;

  case 317: /* plain_declarator: abstract_declarator  */
#line 6425 "CParse/parser.y"
                                  {
              (yyval.decl) = (yyvsp[0].decl);
	      if (SwigType_isfunction((yyvsp[0].decl).type)) {
		Delete(SwigType_pop_function((yyvsp[0].decl).type));
	      } else if (SwigType_isarray((yyvsp[0].decl).type)) {
		SwigType *ta = SwigType_pop_arrays((yyvsp[0].decl).type);
		if (SwigType_isfunction((yyvsp[0].decl).type)) {
		  Delete(SwigType_pop_function((yyvsp[0].decl).type));
		} else {
		  (yyval.decl).parms = 0;
		}
		SwigType_push((yyvsp[0].decl).type,ta);
		Delete(ta);
	      } else {
		(yyval.decl).parms = 0;
	      }
            }
#line 10688 "CParse/parser.c"
    break;

  case 318: /* plain_declarator: direct_declarator LPAREN parms RPAREN cv_ref_qualifier  */
#line 6444 "CParse/parser.y"
                                                                     {
	      SwigType *t;
	      (yyval.decl) = (yyvsp[-4].decl);
	      t = NewStringEmpty();
	      SwigType_add_function(t, (yyvsp[-2].pl));
	      if ((yyvsp[0].dtype).qualifier)
	        SwigType_push(t, (yyvsp[0].dtype).qualifier);
	      if (!(yyval.decl).have_parms) {
		(yyval.decl).parms = (yyvsp[-2].pl);
		(yyval.decl).have_parms = 1;
	      }
	      if (!(yyval.decl).type) {
		(yyval.decl).type = t;
	      } else {
		SwigType_push(t, (yyval.decl).type);
		Delete((yyval.decl).type);
		(yyval.decl).type = t;
	      }
	    }
#line 10712 "CParse/parser.c"
    break;

  case 319: /* plain_declarator: %empty  */
#line 6463 "CParse/parser.y"
                     {
	      (yyval.decl) = default_decl;
	    }
#line 10720 "CParse/parser.c"
    break;

  case 320: /* declarator: pointer notso_direct_declarator  */
#line 6468 "CParse/parser.y"
                                              {
              (yyval.decl) = (yyvsp[0].decl);
	      if ((yyval.decl).type) {
		SwigType_push((yyvsp[-1].type),(yyval.decl).type);
		Delete((yyval.decl).type);
	      }
	      (yyval.decl).type = (yyvsp[-1].type);
           }
#line 10733 "CParse/parser.c"
    break;

  case 321: /* declarator: pointer AND notso_direct_declarator  */
#line 6476 "CParse/parser.y"
                                                 {
              (yyval.decl) = (yyvsp[0].decl);
	      SwigType_add_reference((yyvsp[-2].type));
              if ((yyval.decl).type) {
		SwigType_push((yyvsp[-2].type),(yyval.decl).type);
		Delete((yyval.decl).type);
	      }
	      (yyval.decl).type = (yyvsp[-2].type);
           }
#line 10747 "CParse/parser.c"
    break;

  case 322: /* declarator: pointer LAND notso_direct_declarator  */
#line 6485 "CParse/parser.y"
                                                  {
              (yyval.decl) = (yyvsp[0].decl);
	      SwigType_add_rvalue_reference((yyvsp[-2].type));
              if ((yyval.decl).type) {
		SwigType_push((yyvsp[-2].type),(yyval.decl).type);
		Delete((yyval.decl).type);
	      }
	      (yyval.decl).type = (yyvsp[-2].type);
           }
#line 10761 "CParse/parser.c"
    break;

  case 323: /* declarator: direct_declarator  */
#line 6494 "CParse/parser.y"
                               {
              (yyval.decl) = (yyvsp[0].decl);
	      if (!(yyval.decl).type) (yyval.decl).type = NewStringEmpty();
           }
#line 10770 "CParse/parser.c"
    break;

  case 324: /* declarator: AND notso_direct_declarator  */
#line 6498 "CParse/parser.y"
                                         {
	     (yyval.decl) = (yyvsp[0].decl);
	     (yyval.decl).type = NewStringEmpty();
	     SwigType_add_reference((yyval.decl).type);
	     if ((yyvsp[0].decl).type) {
	       SwigType_push((yyval.decl).type,(yyvsp[0].decl).type);
	       Delete((yyvsp[0].decl).type);
	     }
           }
#line 10784 "CParse/parser.c"
    break;

  case 325: /* declarator: LAND notso_direct_declarator  */
#line 6507 "CParse/parser.y"
                                          {
	     /* Introduced in C++11, move operator && */
             /* Adds one S/R conflict */
	     (yyval.decl) = (yyvsp[0].decl);
	     (yyval.decl).type = NewStringEmpty();
	     SwigType_add_rvalue_reference((yyval.decl).type);
	     if ((yyvsp[0].decl).type) {
	       SwigType_push((yyval.decl).type,(yyvsp[0].decl).type);
	       Delete((yyvsp[0].decl).type);
	     }
           }
#line 10800 "CParse/parser.c"
    break;

  case 326: /* declarator: idcolon DSTAR notso_direct_declarator  */
#line 6518 "CParse/parser.y"
                                                   { 
	     SwigType *t = NewStringEmpty();

	     (yyval.decl) = (yyvsp[0].decl);
	     SwigType_add_memberpointer(t,(yyvsp[-2].str));
	     if ((yyval.decl).type) {
	       SwigType_push(t,(yyval.decl).type);
	       Delete((yyval.decl).type);
	     }
	     (yyval.decl).type = t;
	     }
#line 10816 "CParse/parser.c"
    break;

  case 327: /* declarator: pointer idcolon DSTAR notso_direct_declarator  */
#line 6529 "CParse/parser.y"
                                                           { 
	     SwigType *t = NewStringEmpty();
	     (yyval.decl) = (yyvsp[0].decl);
	     SwigType_add_memberpointer(t,(yyvsp[-2].str));
	     SwigType_push((yyvsp[-3].type),t);
	     if ((yyval.decl).type) {
	       SwigType_push((yyvsp[-3].type),(yyval.decl).type);
	       Delete((yyval.decl).type);
	     }
	     (yyval.decl).type = (yyvsp[-3].type);
	     Delete(t);
	   }
#line 10833 "CParse/parser.c"
    break;

  case 328: /* declarator: pointer idcolon DSTAR AND notso_direct_declarator  */
#line 6541 "CParse/parser.y"
                                                               { 
	     (yyval.decl) = (yyvsp[0].decl);
	     SwigType_add_memberpointer((yyvsp[-4].type),(yyvsp[-3].str));
	     SwigType_add_reference((yyvsp[-4].type));
	     if ((yyval.decl).type) {
	       SwigType_push((yyvsp[-4].type),(yyval.decl).type);
	       Delete((yyval.decl).type);
	     }
	     (yyval.decl).type = (yyvsp[-4].type);
	   }
#line 10848 "CParse/parser.c"
    break;

  case 329: /* declarator: idcolon DSTAR AND notso_direct_declarator  */
#line 6551 "CParse/parser.y"
                                                       { 
	     SwigType *t = NewStringEmpty();
	     (yyval.decl) = (yyvsp[0].decl);
	     SwigType_add_memberpointer(t,(yyvsp[-3].str));
	     SwigType_add_reference(t);
	     if ((yyval.decl).type) {
	       SwigType_push(t,(yyval.decl).type);
	       Delete((yyval.decl).type);
	     } 
	     (yyval.decl).type = t;
	   }
#line 10864 "CParse/parser.c"
    break;

  case 330: /* declarator: pointer ELLIPSIS notso_direct_declarator  */
#line 6565 "CParse/parser.y"
                                                       {
              (yyval.decl) = (yyvsp[0].decl);
	      if ((yyval.decl).type) {
		SwigType_push((yyvsp[-2].type),(yyval.decl).type);
		Delete((yyval.decl).type);
	      }
	      (yyval.decl).type = (yyvsp[-2].type);
	      SwigType_add_variadic((yyval.decl).type);
           }
#line 10878 "CParse/parser.c"
    break;

  case 331: /* declarator: pointer AND ELLIPSIS notso_direct_declarator  */
#line 6574 "CParse/parser.y"
                                                          {
              (yyval.decl) = (yyvsp[0].decl);
	      SwigType_add_reference((yyvsp[-3].type));
              if ((yyval.decl).type) {
		SwigType_push((yyvsp[-3].type),(yyval.decl).type);
		Delete((yyval.decl).type);
	      }
	      (yyval.decl).type = (yyvsp[-3].type);
	      SwigType_add_variadic((yyval.decl).type);
           }
#line 10893 "CParse/parser.c"
    break;

  case 332: /* declarator: pointer LAND ELLIPSIS notso_direct_declarator  */
#line 6584 "CParse/parser.y"
                                                           {
              (yyval.decl) = (yyvsp[0].decl);
	      SwigType_add_rvalue_reference((yyvsp[-3].type));
              if ((yyval.decl).type) {
		SwigType_push((yyvsp[-3].type),(yyval.decl).type);
		Delete((yyval.decl).type);
	      }
	      (yyval.decl).type = (yyvsp[-3].type);
	      SwigType_add_variadic((yyval.decl).type);
           }
#line 10908 "CParse/parser.c"
    break;

  case 333: /* declarator: AND ELLIPSIS notso_direct_declarator  */
#line 6594 "CParse/parser.y"
                                                  {
	     (yyval.decl) = (yyvsp[0].decl);
	     (yyval.decl).type = NewStringEmpty();
	     SwigType_add_reference((yyval.decl).type);
	     SwigType_add_variadic((yyval.decl).type);
	     if ((yyvsp[0].decl).type) {
	       SwigType_push((yyval.decl).type,(yyvsp[0].decl).type);
	       Delete((yyvsp[0].decl).type);
	     }
           }
#line 10923 "CParse/parser.c"
    break;

  case 334: /* declarator: LAND ELLIPSIS notso_direct_declarator  */
#line 6604 "CParse/parser.y"
                                                   {
	     /* Introduced in C++11, move operator && */
             /* Adds one S/R conflict */
	     (yyval.decl) = (yyvsp[0].decl);
	     (yyval.decl).type = NewStringEmpty();
	     SwigType_add_rvalue_reference((yyval.decl).type);
	     SwigType_add_variadic((yyval.decl).type);
	     if ((yyvsp[0].decl).type) {
	       SwigType_push((yyval.decl).type,(yyvsp[0].decl).type);
	       Delete((yyvsp[0].decl).type);
	     }
           }
#line 10940 "CParse/parser.c"
    break;

  case 335: /* declarator: idcolon DSTAR ELLIPSIS notso_direct_declarator  */
#line 6616 "CParse/parser.y"
                                                            {
	     SwigType *t = NewStringEmpty();

	     (yyval.decl) = (yyvsp[0].decl);
	     SwigType_add_memberpointer(t,(yyvsp[-3].str));
	     SwigType_add_variadic(t);
	     if ((yyval.decl).type) {
	       SwigType_push(t,(yyval.decl).type);
	       Delete((yyval.decl).type);
	     }
	     (yyval.decl).type = t;
	     }
#line 10957 "CParse/parser.c"
    break;

  case 336: /* declarator: pointer idcolon DSTAR ELLIPSIS notso_direct_declarator  */
#line 6628 "CParse/parser.y"
                                                                    {
	     SwigType *t = NewStringEmpty();
	     (yyval.decl) = (yyvsp[0].decl);
	     SwigType_add_memberpointer(t,(yyvsp[-3].str));
	     SwigType_add_variadic(t);
	     SwigType_push((yyvsp[-4].type),t);
	     if ((yyval.decl).type) {
	       SwigType_push((yyvsp[-4].type),(yyval.decl).type);
	       Delete((yyval.decl).type);
	     }
	     (yyval.decl).type = (yyvsp[-4].type);
	     Delete(t);
	   }
#line 10975 "CParse/parser.c"
    break;

  case 337: /* declarator: pointer idcolon DSTAR AND ELLIPSIS notso_direct_declarator  */
#line 6641 "CParse/parser.y"
                                                                        {
	     (yyval.decl) = (yyvsp[0].decl);
	     SwigType_add_memberpointer((yyvsp[-5].type),(yyvsp[-4].str));
	     SwigType_add_reference((yyvsp[-5].type));
	     SwigType_add_variadic((yyvsp[-5].type));
	     if ((yyval.decl).type) {
	       SwigType_push((yyvsp[-5].type),(yyval.decl).type);
	       Delete((yyval.decl).type);
	     }
	     (yyval.decl).type = (yyvsp[-5].type);
	   }
#line 10991 "CParse/parser.c"
    break;

  case 338: /* declarator: pointer idcolon DSTAR LAND ELLIPSIS notso_direct_declarator  */
#line 6652 "CParse/parser.y"
                                                                         {
	     (yyval.decl) = (yyvsp[0].decl);
	     SwigType_add_memberpointer((yyvsp[-5].type),(yyvsp[-4].str));
	     SwigType_add_rvalue_reference((yyvsp[-5].type));
	     SwigType_add_variadic((yyvsp[-5].type));
	     if ((yyval.decl).type) {
	       SwigType_push((yyvsp[-5].type),(yyval.decl).type);
	       Delete((yyval.decl).type);
	     }
	     (yyval.decl).type = (yyvsp[-5].type);
	   }
#line 11007 "CParse/parser.c"
    break;

  case 339: /* declarator: idcolon DSTAR AND ELLIPSIS notso_direct_declarator  */
#line 6663 "CParse/parser.y"
                                                                {
	     SwigType *t = NewStringEmpty();
	     (yyval.decl) = (yyvsp[0].decl);
	     SwigType_add_memberpointer(t,(yyvsp[-4].str));
	     SwigType_add_reference(t);
	     SwigType_add_variadic(t);
	     if ((yyval.decl).type) {
	       SwigType_push(t,(yyval.decl).type);
	       Delete((yyval.decl).type);
	     } 
	     (yyval.decl).type = t;
	   }
#line 11024 "CParse/parser.c"
    break;

  case 340: /* declarator: idcolon DSTAR LAND ELLIPSIS notso_direct_declarator  */
#line 6675 "CParse/parser.y"
                                                                 {
	     SwigType *t = NewStringEmpty();
	     (yyval.decl) = (yyvsp[0].decl);
	     SwigType_add_memberpointer(t,(yyvsp[-4].str));
	     SwigType_add_rvalue_reference(t);
	     SwigType_add_variadic(t);
	     if ((yyval.decl).type) {
	       SwigType_push(t,(yyval.decl).type);
	       Delete((yyval.decl).type);
	     } 
	     (yyval.decl).type = t;
	   }
#line 11041 "CParse/parser.c"
    break;

  case 341: /* notso_direct_declarator: idcolon  */
#line 6689 "CParse/parser.y"
                                  {
                /* Note: This is non-standard C.  Template declarator is allowed to follow an identifier */
		 (yyval.decl) = default_decl;
                 (yyval.decl).id = Char((yyvsp[0].str));
                  }
#line 11051 "CParse/parser.c"
    break;

  case 342: /* notso_direct_declarator: NOT idcolon  */
#line 6694 "CParse/parser.y"
                                {
		  (yyval.decl) = default_decl;
                  (yyval.decl).id = Char(NewStringf("~%s",(yyvsp[0].str)));
                  }
#line 11060 "CParse/parser.c"
    break;

  case 343: /* notso_direct_declarator: LPAREN idcolon RPAREN  */
#line 6700 "CParse/parser.y"
                                         {
		  (yyval.decl) = default_decl;
                  (yyval.decl).id = Char((yyvsp[-1].str));
                  }
#line 11069 "CParse/parser.c"
    break;

  case 344: /* notso_direct_declarator: LPAREN pointer notso_direct_declarator RPAREN  */
#line 6712 "CParse/parser.y"
                                                                      {
		    (yyval.decl) = (yyvsp[-1].decl);
		    if ((yyval.decl).type) {
		      SwigType_push((yyvsp[-2].type),(yyval.decl).type);
		      Delete((yyval.decl).type);
		    }
		    (yyval.decl).type = (yyvsp[-2].type);
                  }
#line 11082 "CParse/parser.c"
    break;

  case 345: /* notso_direct_declarator: LPAREN idcolon DSTAR notso_direct_declarator RPAREN  */
#line 6720 "CParse/parser.y"
                                                                            {
		    SwigType *t;
		    (yyval.decl) = (yyvsp[-1].decl);
		    t = NewStringEmpty();
		    SwigType_add_memberpointer(t,(yyvsp[-3].str));
		    if ((yyval.decl).type) {
		      SwigType_push(t,(yyval.decl).type);
		      Delete((yyval.decl).type);
		    }
		    (yyval.decl).type = t;
		    }
#line 11098 "CParse/parser.c"
    break;

  case 346: /* notso_direct_declarator: notso_direct_declarator LBRACKET RBRACKET  */
#line 6731 "CParse/parser.y"
                                                                  { 
		    SwigType *t;
		    (yyval.decl) = (yyvsp[-2].decl);
		    t = NewStringEmpty();
		    SwigType_add_array(t,"");
		    if ((yyval.decl).type) {
		      SwigType_push(t,(yyval.decl).type);
		      Delete((yyval.decl).type);
		    }
		    (yyval.decl).type = t;
                  }
#line 11114 "CParse/parser.c"
    break;

  case 347: /* notso_direct_declarator: notso_direct_declarator LBRACKET expr RBRACKET  */
#line 6742 "CParse/parser.y"
                                                                       { 
		    SwigType *t;
		    (yyval.decl) = (yyvsp[-3].decl);
		    t = NewStringEmpty();
		    SwigType_add_array(t,(yyvsp[-1].dtype).val);
		    if ((yyval.decl).type) {
		      SwigType_push(t,(yyval.decl).type);
		      Delete((yyval.decl).type);
		    }
		    (yyval.decl).type = t;
                  }
#line 11130 "CParse/parser.c"
    break;

  case 348: /* notso_direct_declarator: notso_direct_declarator LPAREN parms RPAREN  */
#line 6753 "CParse/parser.y"
                                                                    {
		    SwigType *t;
                    (yyval.decl) = (yyvsp[-3].decl);
		    t = NewStringEmpty();
		    SwigType_add_function(t,(yyvsp[-1].pl));
		    if (!(yyval.decl).have_parms) {
		      (yyval.decl).parms = (yyvsp[-1].pl);
		      (yyval.decl).have_parms = 1;
		    }
		    if (!(yyval.decl).type) {
		      (yyval.decl).type = t;
		    } else {
		      SwigType_push(t, (yyval.decl).type);
		      Delete((yyval.decl).type);
		      (yyval.decl).type = t;
		    }
		  }
#line 11152 "CParse/parser.c"
    break;

  case 349: /* direct_declarator: idcolon  */
#line 6772 "CParse/parser.y"
                            {
                /* Note: This is non-standard C.  Template declarator is allowed to follow an identifier */
		 (yyval.decl) = default_decl;
                 (yyval.decl).id = Char((yyvsp[0].str));
                  }
#line 11162 "CParse/parser.c"
    break;

  case 350: /* direct_declarator: NOT idcolon  */
#line 6778 "CParse/parser.y"
                                {
		  (yyval.decl) = default_decl;
                  (yyval.decl).id = Char(NewStringf("~%s",(yyvsp[0].str)));
                  }
#line 11171 "CParse/parser.c"
    break;

  case 351: /* direct_declarator: LPAREN pointer direct_declarator RPAREN  */
#line 6791 "CParse/parser.y"
                                                                {
		    (yyval.decl) = (yyvsp[-1].decl);
		    if ((yyval.decl).type) {
		      SwigType_push((yyvsp[-2].type),(yyval.decl).type);
		      Delete((yyval.decl).type);
		    }
		    (yyval.decl).type = (yyvsp[-2].type);
                  }
#line 11184 "CParse/parser.c"
    break;

  case 352: /* direct_declarator: LPAREN AND direct_declarator RPAREN  */
#line 6799 "CParse/parser.y"
                                                            {
                    (yyval.decl) = (yyvsp[-1].decl);
		    if (!(yyval.decl).type) {
		      (yyval.decl).type = NewStringEmpty();
		    }
		    SwigType_add_reference((yyval.decl).type);
                  }
#line 11196 "CParse/parser.c"
    break;

  case 353: /* direct_declarator: LPAREN LAND direct_declarator RPAREN  */
#line 6806 "CParse/parser.y"
                                                             {
                    (yyval.decl) = (yyvsp[-1].decl);
		    if (!(yyval.decl).type) {
		      (yyval.decl).type = NewStringEmpty();
		    }
		    SwigType_add_rvalue_reference((yyval.decl).type);
                  }
#line 11208 "CParse/parser.c"
    break;

  case 354: /* direct_declarator: LPAREN idcolon DSTAR declarator RPAREN  */
#line 6813 "CParse/parser.y"
                                                           {
		    SwigType *t;
		    (yyval.decl) = (yyvsp[-1].decl);
		    t = NewStringEmpty();
		    SwigType_add_memberpointer(t,(yyvsp[-3].str));
		    if ((yyval.decl).type) {
		      SwigType_push(t,(yyval.decl).type);
		      Delete((yyval.decl).type);
		    }
		    (yyval.decl).type = t;
		  }
#line 11224 "CParse/parser.c"
    break;

  case 355: /* direct_declarator: LPAREN idcolon DSTAR type_qualifier declarator RPAREN  */
#line 6824 "CParse/parser.y"
                                                                          {
		    SwigType *t;
		    (yyval.decl) = (yyvsp[-1].decl);
		    t = NewStringEmpty();
		    SwigType_add_memberpointer(t, (yyvsp[-4].str));
		    SwigType_push(t, (yyvsp[-2].str));
		    if ((yyval.decl).type) {
		      SwigType_push(t, (yyval.decl).type);
		      Delete((yyval.decl).type);
		    }
		    (yyval.decl).type = t;
		  }
#line 11241 "CParse/parser.c"
    break;

  case 356: /* direct_declarator: LPAREN idcolon DSTAR abstract_declarator RPAREN  */
#line 6836 "CParse/parser.y"
                                                                    {
		    SwigType *t;
		    (yyval.decl) = (yyvsp[-1].decl);
		    t = NewStringEmpty();
		    SwigType_add_memberpointer(t, (yyvsp[-3].str));
		    if ((yyval.decl).type) {
		      SwigType_push(t, (yyval.decl).type);
		      Delete((yyval.decl).type);
		    }
		    (yyval.decl).type = t;
		  }
#line 11257 "CParse/parser.c"
    break;

  case 357: /* direct_declarator: LPAREN idcolon DSTAR type_qualifier abstract_declarator RPAREN  */
#line 6847 "CParse/parser.y"
                                                                                   {
		    SwigType *t;
		    (yyval.decl) = (yyvsp[-1].decl);
		    t = NewStringEmpty();
		    SwigType_add_memberpointer(t, (yyvsp[-4].str));
		    SwigType_push(t, (yyvsp[-2].str));
		    if ((yyval.decl).type) {
		      SwigType_push(t, (yyval.decl).type);
		      Delete((yyval.decl).type);
		    }
		    (yyval.decl).type = t;
		  }
#line 11274 "CParse/parser.c"
    break;

  case 358: /* direct_declarator: direct_declarator LBRACKET RBRACKET  */
#line 6859 "CParse/parser.y"
                                                            { 
		    SwigType *t;
		    (yyval.decl) = (yyvsp[-2].decl);
		    t = NewStringEmpty();
		    SwigType_add_array(t,"");
		    if ((yyval.decl).type) {
		      SwigType_push(t,(yyval.decl).type);
		      Delete((yyval.decl).type);
		    }
		    (yyval.decl).type = t;
                  }
#line 11290 "CParse/parser.c"
    break;

  case 359: /* direct_declarator: direct_declarator LBRACKET expr RBRACKET  */
#line 6870 "CParse/parser.y"
                                                                 { 
		    SwigType *t;
		    (yyval.decl) = (yyvsp[-3].decl);
		    t = NewStringEmpty();
		    SwigType_add_array(t,(yyvsp[-1].dtype).val);
		    if ((yyval.decl).type) {
		      SwigType_push(t,(yyval.decl).type);
		      Delete((yyval.decl).type);
		    }
		    (yyval.decl).type = t;
                  }
#line 11306 "CParse/parser.c"
    break;

  case 360: /* direct_declarator: direct_declarator LPAREN parms RPAREN  */
#line 6881 "CParse/parser.y"
                                                              {
		    SwigType *t;
                    (yyval.decl) = (yyvsp[-3].decl);
		    t = NewStringEmpty();
		    SwigType_add_function(t,(yyvsp[-1].pl));
		    if (!(yyval.decl).have_parms) {
		      (yyval.decl).parms = (yyvsp[-1].pl);
		      (yyval.decl).have_parms = 1;
		    }
		    if (!(yyval.decl).type) {
		      (yyval.decl).type = t;
		    } else {
		      SwigType_push(t, (yyval.decl).type);
		      Delete((yyval.decl).type);
		      (yyval.decl).type = t;
		    }
		  }
#line 11328 "CParse/parser.c"
    break;

  case 361: /* direct_declarator: OPERATOR ID LPAREN parms RPAREN  */
#line 6903 "CParse/parser.y"
                                                   {
		    (yyval.decl) = default_decl;
		    SwigType *t;
		    Append((yyvsp[-4].str), (yyvsp[-3].id));
		    (yyval.decl).id = Char((yyvsp[-4].str));
		    t = NewStringEmpty();
		    SwigType_add_function(t,(yyvsp[-1].pl));
		    (yyval.decl).parms = (yyvsp[-1].pl);
		    (yyval.decl).have_parms = 1;
		    (yyval.decl).type = t;
		  }
#line 11344 "CParse/parser.c"
    break;

  case 362: /* abstract_declarator: pointer variadic_opt  */
#line 6916 "CParse/parser.y"
                                           {
		    (yyval.decl) = default_decl;
		    (yyval.decl).type = (yyvsp[-1].type);
		    if ((yyvsp[0].intvalue)) SwigType_add_variadic((yyval.decl).type);
                  }
#line 11354 "CParse/parser.c"
    break;

  case 363: /* abstract_declarator: pointer direct_abstract_declarator  */
#line 6921 "CParse/parser.y"
                                                       { 
                     (yyval.decl) = (yyvsp[0].decl);
                     SwigType_push((yyvsp[-1].type),(yyvsp[0].decl).type);
		     (yyval.decl).type = (yyvsp[-1].type);
		     Delete((yyvsp[0].decl).type);
                  }
#line 11365 "CParse/parser.c"
    break;

  case 364: /* abstract_declarator: pointer AND variadic_opt  */
#line 6927 "CParse/parser.y"
                                             {
		    (yyval.decl) = default_decl;
		    (yyval.decl).type = (yyvsp[-2].type);
		    SwigType_add_reference((yyval.decl).type);
		    if ((yyvsp[0].intvalue)) SwigType_add_variadic((yyval.decl).type);
		  }
#line 11376 "CParse/parser.c"
    break;

  case 365: /* abstract_declarator: pointer LAND variadic_opt  */
#line 6933 "CParse/parser.y"
                                              {
		    (yyval.decl) = default_decl;
		    (yyval.decl).type = (yyvsp[-2].type);
		    SwigType_add_rvalue_reference((yyval.decl).type);
		    if ((yyvsp[0].intvalue)) SwigType_add_variadic((yyval.decl).type);
		  }
#line 11387 "CParse/parser.c"
    break;

  case 366: /* abstract_declarator: pointer AND direct_abstract_declarator  */
#line 6939 "CParse/parser.y"
                                                           {
		    (yyval.decl) = (yyvsp[0].decl);
		    SwigType_add_reference((yyvsp[-2].type));
		    if ((yyval.decl).type) {
		      SwigType_push((yyvsp[-2].type),(yyval.decl).type);
		      Delete((yyval.decl).type);
		    }
		    (yyval.decl).type = (yyvsp[-2].type);
                  }
#line 11401 "CParse/parser.c"
    break;

  case 367: /* abstract_declarator: pointer LAND direct_abstract_declarator  */
#line 6948 "CParse/parser.y"
                                                            {
		    (yyval.decl) = (yyvsp[0].decl);
		    SwigType_add_rvalue_reference((yyvsp[-2].type));
		    if ((yyval.decl).type) {
		      SwigType_push((yyvsp[-2].type),(yyval.decl).type);
		      Delete((yyval.decl).type);
		    }
		    (yyval.decl).type = (yyvsp[-2].type);
                  }
#line 11415 "CParse/parser.c"
    break;

  case 369: /* abstract_declarator: AND direct_abstract_declarator  */
#line 6958 "CParse/parser.y"
                                                   {
		    (yyval.decl) = (yyvsp[0].decl);
		    (yyval.decl).type = NewStringEmpty();
		    SwigType_add_reference((yyval.decl).type);
		    if ((yyvsp[0].decl).type) {
		      SwigType_push((yyval.decl).type,(yyvsp[0].decl).type);
		      Delete((yyvsp[0].decl).type);
		    }
                  }
#line 11429 "CParse/parser.c"
    break;

  case 370: /* abstract_declarator: LAND direct_abstract_declarator  */
#line 6967 "CParse/parser.y"
                                                    {
		    (yyval.decl) = (yyvsp[0].decl);
		    (yyval.decl).type = NewStringEmpty();
		    SwigType_add_rvalue_reference((yyval.decl).type);
		    if ((yyvsp[0].decl).type) {
		      SwigType_push((yyval.decl).type,(yyvsp[0].decl).type);
		      Delete((yyvsp[0].decl).type);
		    }
                  }
#line 11443 "CParse/parser.c"
    break;

  case 371: /* abstract_declarator: AND variadic_opt  */
#line 6976 "CParse/parser.y"
                                     {
		    (yyval.decl) = default_decl;
                    (yyval.decl).type = NewStringEmpty();
		    SwigType_add_reference((yyval.decl).type);
		    if ((yyvsp[0].intvalue)) SwigType_add_variadic((yyval.decl).type);
                  }
#line 11454 "CParse/parser.c"
    break;

  case 372: /* abstract_declarator: LAND variadic_opt  */
#line 6982 "CParse/parser.y"
                                      {
		    (yyval.decl) = default_decl;
                    (yyval.decl).type = NewStringEmpty();
		    SwigType_add_rvalue_reference((yyval.decl).type);
		    if ((yyvsp[0].intvalue)) SwigType_add_variadic((yyval.decl).type);
                  }
#line 11465 "CParse/parser.c"
    break;

  case 373: /* abstract_declarator: idcolon DSTAR  */
#line 6988 "CParse/parser.y"
                                  { 
		    (yyval.decl) = default_decl;
		    (yyval.decl).type = NewStringEmpty();
                    SwigType_add_memberpointer((yyval.decl).type,(yyvsp[-1].str));
      	          }
#line 11475 "CParse/parser.c"
    break;

  case 374: /* abstract_declarator: idcolon DSTAR type_qualifier  */
#line 6993 "CParse/parser.y"
                                                 {
		    (yyval.decl) = default_decl;
		    (yyval.decl).type = NewStringEmpty();
		    SwigType_add_memberpointer((yyval.decl).type, (yyvsp[-2].str));
		    SwigType_push((yyval.decl).type, (yyvsp[0].str));
		  }
#line 11486 "CParse/parser.c"
    break;

  case 375: /* abstract_declarator: pointer idcolon DSTAR  */
#line 6999 "CParse/parser.y"
                                          { 
		    (yyval.decl) = default_decl;
		    SwigType *t = NewStringEmpty();
                    (yyval.decl).type = (yyvsp[-2].type);
		    SwigType_add_memberpointer(t,(yyvsp[-1].str));
		    SwigType_push((yyval.decl).type,t);
		    Delete(t);
                  }
#line 11499 "CParse/parser.c"
    break;

  case 376: /* abstract_declarator: pointer idcolon DSTAR direct_abstract_declarator  */
#line 7007 "CParse/parser.y"
                                                                     { 
		    (yyval.decl) = (yyvsp[0].decl);
		    SwigType_add_memberpointer((yyvsp[-3].type),(yyvsp[-2].str));
		    if ((yyval.decl).type) {
		      SwigType_push((yyvsp[-3].type),(yyval.decl).type);
		      Delete((yyval.decl).type);
		    }
		    (yyval.decl).type = (yyvsp[-3].type);
                  }
#line 11513 "CParse/parser.c"
    break;

  case 377: /* direct_abstract_declarator: direct_abstract_declarator LBRACKET RBRACKET  */
#line 7018 "CParse/parser.y"
                                                                              { 
		    SwigType *t;
		    (yyval.decl) = (yyvsp[-2].decl);
		    t = NewStringEmpty();
		    SwigType_add_array(t,"");
		    if ((yyval.decl).type) {
		      SwigType_push(t,(yyval.decl).type);
		      Delete((yyval.decl).type);
		    }
		    (yyval.decl).type = t;
                  }
#line 11529 "CParse/parser.c"
    break;

  case 378: /* direct_abstract_declarator: direct_abstract_declarator LBRACKET expr RBRACKET  */
#line 7029 "CParse/parser.y"
                                                                          { 
		    SwigType *t;
		    (yyval.decl) = (yyvsp[-3].decl);
		    t = NewStringEmpty();
		    SwigType_add_array(t,(yyvsp[-1].dtype).val);
		    if ((yyval.decl).type) {
		      SwigType_push(t,(yyval.decl).type);
		      Delete((yyval.decl).type);
		    }
		    (yyval.decl).type = t;
                  }
#line 11545 "CParse/parser.c"
    break;

  case 379: /* direct_abstract_declarator: LBRACKET RBRACKET  */
#line 7040 "CParse/parser.y"
                                      { 
		    (yyval.decl) = default_decl;
		    (yyval.decl).type = NewStringEmpty();
		    SwigType_add_array((yyval.decl).type,"");
                  }
#line 11555 "CParse/parser.c"
    break;

  case 380: /* direct_abstract_declarator: LBRACKET expr RBRACKET  */
#line 7045 "CParse/parser.y"
                                           { 
		    (yyval.decl) = default_decl;
		    (yyval.decl).type = NewStringEmpty();
		    SwigType_add_array((yyval.decl).type,(yyvsp[-1].dtype).val);
		  }
#line 11565 "CParse/parser.c"
    break;

  case 381: /* direct_abstract_declarator: LPAREN abstract_declarator RPAREN  */
#line 7050 "CParse/parser.y"
                                                      {
                    (yyval.decl) = (yyvsp[-1].decl);
		  }
#line 11573 "CParse/parser.c"
    break;

  case 382: /* direct_abstract_declarator: direct_abstract_declarator LPAREN parms RPAREN  */
#line 7053 "CParse/parser.y"
                                                                       {
		    SwigType *t;
                    (yyval.decl) = (yyvsp[-3].decl);
		    t = NewStringEmpty();
                    SwigType_add_function(t,(yyvsp[-1].pl));
		    if (!(yyval.decl).type) {
		      (yyval.decl).type = t;
		    } else {
		      SwigType_push(t,(yyval.decl).type);
		      Delete((yyval.decl).type);
		      (yyval.decl).type = t;
		    }
		    if (!(yyval.decl).have_parms) {
		      (yyval.decl).parms = (yyvsp[-1].pl);
		      (yyval.decl).have_parms = 1;
		    }
		  }
#line 11595 "CParse/parser.c"
    break;

  case 383: /* direct_abstract_declarator: direct_abstract_declarator LPAREN parms RPAREN cv_ref_qualifier  */
#line 7070 "CParse/parser.y"
                                                                                        {
		    SwigType *t;
                    (yyval.decl) = (yyvsp[-4].decl);
		    t = NewStringEmpty();
                    SwigType_add_function(t,(yyvsp[-2].pl));
		    SwigType_push(t, (yyvsp[0].dtype).qualifier);
		    if (!(yyval.decl).type) {
		      (yyval.decl).type = t;
		    } else {
		      SwigType_push(t,(yyval.decl).type);
		      Delete((yyval.decl).type);
		      (yyval.decl).type = t;
		    }
		    if (!(yyval.decl).have_parms) {
		      (yyval.decl).parms = (yyvsp[-2].pl);
		      (yyval.decl).have_parms = 1;
		    }
		  }
#line 11618 "CParse/parser.c"
    break;

  case 384: /* direct_abstract_declarator: LPAREN parms RPAREN  */
#line 7088 "CParse/parser.y"
                                        {
		    (yyval.decl) = default_decl;
                    (yyval.decl).type = NewStringEmpty();
                    SwigType_add_function((yyval.decl).type,(yyvsp[-1].pl));
		    (yyval.decl).parms = (yyvsp[-1].pl);
		    (yyval.decl).have_parms = 1;
                  }
#line 11630 "CParse/parser.c"
    break;

  case 385: /* pointer: pointer STAR type_qualifier  */
#line 7098 "CParse/parser.y"
                                             {
	     (yyval.type) = (yyvsp[-2].type);
             SwigType_add_pointer((yyval.type));
	     SwigType_push((yyval.type),(yyvsp[0].str));
           }
#line 11640 "CParse/parser.c"
    break;

  case 386: /* pointer: pointer STAR  */
#line 7103 "CParse/parser.y"
                              {
	     (yyval.type) = (yyvsp[-1].type);
	     SwigType_add_pointer((yyval.type));
	   }
#line 11649 "CParse/parser.c"
    break;

  case 387: /* pointer: STAR type_qualifier  */
#line 7107 "CParse/parser.y"
                                 {
	     (yyval.type) = NewStringEmpty();
	     SwigType_add_pointer((yyval.type));
	     SwigType_push((yyval.type),(yyvsp[0].str));
           }
#line 11659 "CParse/parser.c"
    break;

  case 388: /* pointer: STAR  */
#line 7112 "CParse/parser.y"
                  {
	     (yyval.type) = NewStringEmpty();
	     SwigType_add_pointer((yyval.type));
           }
#line 11668 "CParse/parser.c"
    break;

  case 389: /* cv_ref_qualifier: type_qualifier  */
#line 7119 "CParse/parser.y"
                                  {
		  (yyval.dtype).qualifier = (yyvsp[0].str);
	       }
#line 11676 "CParse/parser.c"
    break;

  case 390: /* cv_ref_qualifier: type_qualifier ref_qualifier  */
#line 7122 "CParse/parser.y"
                                              {
		  (yyval.dtype).qualifier = (yyvsp[-1].str);
		  (yyval.dtype).refqualifier = (yyvsp[0].str);
		  SwigType_push((yyval.dtype).qualifier, (yyvsp[0].str));
	       }
#line 11686 "CParse/parser.c"
    break;

  case 391: /* cv_ref_qualifier: ref_qualifier  */
#line 7127 "CParse/parser.y"
                               {
		  (yyval.dtype).qualifier = NewStringEmpty();
		  (yyval.dtype).refqualifier = (yyvsp[0].str);
		  SwigType_push((yyval.dtype).qualifier, (yyvsp[0].str));
	       }
#line 11696 "CParse/parser.c"
    break;

  case 392: /* ref_qualifier: AND  */
#line 7134 "CParse/parser.y"
                    {
	          (yyval.str) = NewStringEmpty();
	          SwigType_add_reference((yyval.str));
	       }
#line 11705 "CParse/parser.c"
    break;

  case 393: /* ref_qualifier: LAND  */
#line 7138 "CParse/parser.y"
                      {
	          (yyval.str) = NewStringEmpty();
	          SwigType_add_rvalue_reference((yyval.str));
	       }
#line 11714 "CParse/parser.c"
    break;

  case 394: /* type_qualifier: type_qualifier_raw  */
#line 7144 "CParse/parser.y"
                                    {
	          (yyval.str) = NewStringEmpty();
	          if ((yyvsp[0].id)) SwigType_add_qualifier((yyval.str),(yyvsp[0].id));
               }
#line 11723 "CParse/parser.c"
    break;

  case 395: /* type_qualifier: type_qualifier type_qualifier_raw  */
#line 7148 "CParse/parser.y"
                                                       {
		  (yyval.str) = (yyvsp[-1].str);
	          if ((yyvsp[0].id)) SwigType_add_qualifier((yyval.str),(yyvsp[0].id));
               }
#line 11732 "CParse/parser.c"
    break;

  case 396: /* type_qualifier_raw: CONST_QUAL  */
#line 7154 "CParse/parser.y"
                                 { (yyval.id) = "const"; }
#line 11738 "CParse/parser.c"
    break;

  case 397: /* type_qualifier_raw: VOLATILE  */
#line 7155 "CParse/parser.y"
                               { (yyval.id) = "volatile"; }
#line 11744 "CParse/parser.c"
    break;

  case 398: /* type_qualifier_raw: REGISTER  */
#line 7156 "CParse/parser.y"
                               { (yyval.id) = 0; }
#line 11750 "CParse/parser.c"
    break;

  case 399: /* type: rawtype  */
#line 7162 "CParse/parser.y"
                                    {
                   (yyval.type) = (yyvsp[0].type);
                   Replace((yyval.type),"typename ","", DOH_REPLACE_ANY);
                }
#line 11759 "CParse/parser.c"
    break;

  case 400: /* rawtype: type_qualifier type_right  */
#line 7168 "CParse/parser.y"
                                           {
                   (yyval.type) = (yyvsp[0].type);
	           SwigType_push((yyval.type),(yyvsp[-1].str));
               }
#line 11768 "CParse/parser.c"
    break;

  case 402: /* rawtype: type_right type_qualifier  */
#line 7173 "CParse/parser.y"
                                           {
		  (yyval.type) = (yyvsp[-1].type);
	          SwigType_push((yyval.type),(yyvsp[0].str));
	       }
#line 11777 "CParse/parser.c"
    break;

  case 403: /* rawtype: type_qualifier type_right type_qualifier  */
#line 7177 "CParse/parser.y"
                                                                                            {
		  (yyval.type) = (yyvsp[-1].type);
	          SwigType_push((yyval.type),(yyvsp[0].str));
	          SwigType_push((yyval.type),(yyvsp[-2].str));
	       }
#line 11787 "CParse/parser.c"
    break;

  case 404: /* rawtype: rawtype ELLIPSIS  */
#line 7182 "CParse/parser.y"
                                      {
		  (yyval.type) = (yyvsp[-1].type);
		  SwigType_add_variadic((yyval.type));
	       }
#line 11796 "CParse/parser.c"
    break;

  case 408: /* type_right: c_enum_key idcolon  */
#line 7191 "CParse/parser.y"
                                    { (yyval.type) = NewStringf("enum %s", (yyvsp[0].str)); }
#line 11802 "CParse/parser.c"
    break;

  case 409: /* type_right: idcolon  */
#line 7193 "CParse/parser.y"
                                   {
		  (yyval.type) = (yyvsp[0].str);
               }
#line 11810 "CParse/parser.c"
    break;

  case 410: /* type_right: cpptype idcolon  */
#line 7196 "CParse/parser.y"
                                           {
		 (yyval.type) = NewStringf("%s %s", (yyvsp[-1].type), (yyvsp[0].str));
               }
#line 11818 "CParse/parser.c"
    break;

  case 412: /* @11: %empty  */
#line 7202 "CParse/parser.y"
                                      {
		 (yyval.str) = get_raw_text_balanced('(', ')');
	       }
#line 11826 "CParse/parser.c"
    break;

  case 413: /* decltype: DECLTYPE LPAREN @11 decltypeexpr  */
#line 7204 "CParse/parser.y"
                                    {
		 String *expr = (yyvsp[-1].str);
		 if ((yyvsp[0].type)) {
		   (yyval.type) = (yyvsp[0].type);
		 } else {
		   (yyval.type) = NewStringf("decltype%s", expr);
		   /* expr includes parentheses but don't include them in the warning message. */
		   Delitem(expr, 0);
		   Delitem(expr, DOH_END);
		   Swig_warning(WARN_CPP11_DECLTYPE, cparse_file, cparse_line, "Unable to deduce decltype for '%s'.\n", expr);
		 }
		 Delete(expr);
	       }
#line 11844 "CParse/parser.c"
    break;

  case 414: /* decltypeexpr: expr RPAREN  */
#line 7219 "CParse/parser.y"
                             {
		 (yyval.type) = deduce_type(&(yyvsp[-1].dtype));
	       }
#line 11852 "CParse/parser.c"
    break;

  case 415: /* decltypeexpr: error RPAREN  */
#line 7222 "CParse/parser.y"
                              {
		 /* Avoid a parse error if we can't parse the expression
		  * decltype() is applied to.
		  *
		  * Set $$ to 0 here to trigger the decltype rule above to
		  * issue a warning.
		  */
		 (yyval.type) = 0;
		 if (skip_balanced('(',')') < 0) Exit(EXIT_FAILURE);
		 Clear(scanner_ccode);
	       }
#line 11868 "CParse/parser.c"
    break;

  case 416: /* primitive_type: primitive_type_list  */
#line 7235 "CParse/parser.y"
                                     {
		 String *type = (yyvsp[0].ptype).type;
		 if (!type) type = NewString("int");
		 if ((yyvsp[0].ptype).us) {
		   (yyval.type) = NewStringf("%s %s", (yyvsp[0].ptype).us, type);
		   Delete((yyvsp[0].ptype).us);
                   Delete(type);
		 } else {
                   (yyval.type) = type;
		 }
		 if (Cmp((yyval.type),"signed int") == 0) {
		   Delete((yyval.type));
		   (yyval.type) = NewString("int");
                 } else if (Cmp((yyval.type),"signed long") == 0) {
		   Delete((yyval.type));
                   (yyval.type) = NewString("long");
                 } else if (Cmp((yyval.type),"signed short") == 0) {
		   Delete((yyval.type));
		   (yyval.type) = NewString("short");
		 } else if (Cmp((yyval.type),"signed long long") == 0) {
		   Delete((yyval.type));
		   (yyval.type) = NewString("long long");
		 }
               }
#line 11897 "CParse/parser.c"
    break;

  case 418: /* primitive_type_list: type_specifier primitive_type_list  */
#line 7262 "CParse/parser.y"
                                                        {
                    if ((yyvsp[-1].ptype).us && (yyvsp[0].ptype).us) {
		      Swig_error(cparse_file, cparse_line, "Extra %s specifier.\n", (yyvsp[0].ptype).us);
		    }
                    (yyval.ptype) = (yyvsp[0].ptype);
                    if ((yyvsp[-1].ptype).us) (yyval.ptype).us = (yyvsp[-1].ptype).us;
		    if ((yyvsp[-1].ptype).type) {
		      if (!(yyvsp[0].ptype).type) (yyval.ptype).type = (yyvsp[-1].ptype).type;
		      else {
			int err = 0;
			if ((Cmp((yyvsp[-1].ptype).type,"long") == 0)) {
			  if ((Cmp((yyvsp[0].ptype).type,"long") == 0) || (Strncmp((yyvsp[0].ptype).type,"double",6) == 0)) {
			    (yyval.ptype).type = NewStringf("long %s", (yyvsp[0].ptype).type);
			  } else if (Cmp((yyvsp[0].ptype).type,"int") == 0) {
			    (yyval.ptype).type = (yyvsp[-1].ptype).type;
			  } else {
			    err = 1;
			  }
			} else if ((Cmp((yyvsp[-1].ptype).type,"short")) == 0) {
			  if (Cmp((yyvsp[0].ptype).type,"int") == 0) {
			    (yyval.ptype).type = (yyvsp[-1].ptype).type;
			  } else {
			    err = 1;
			  }
			} else if (Cmp((yyvsp[-1].ptype).type,"int") == 0) {
			  (yyval.ptype).type = (yyvsp[0].ptype).type;
			} else if (Cmp((yyvsp[-1].ptype).type,"double") == 0) {
			  if (Cmp((yyvsp[0].ptype).type,"long") == 0) {
			    (yyval.ptype).type = NewString("long double");
			  } else if (Cmp((yyvsp[0].ptype).type,"_Complex") == 0) {
			    (yyval.ptype).type = NewString("double _Complex");
			  } else {
			    err = 1;
			  }
			} else if (Cmp((yyvsp[-1].ptype).type,"float") == 0) {
			  if (Cmp((yyvsp[0].ptype).type,"_Complex") == 0) {
			    (yyval.ptype).type = NewString("float _Complex");
			  } else {
			    err = 1;
			  }
			} else if (Cmp((yyvsp[-1].ptype).type,"_Complex") == 0) {
			  (yyval.ptype).type = NewStringf("%s _Complex", (yyvsp[0].ptype).type);
			} else {
			  err = 1;
			}
			if (err) {
			  Swig_error(cparse_file, cparse_line, "Extra %s specifier.\n", (yyvsp[-1].ptype).type);
			}
		      }
		    }
               }
#line 11953 "CParse/parser.c"
    break;

  case 419: /* type_specifier: TYPE_INT  */
#line 7316 "CParse/parser.y"
                          { 
		    (yyval.ptype).type = NewString("int");
                    (yyval.ptype).us = 0;
               }
#line 11962 "CParse/parser.c"
    break;

  case 420: /* type_specifier: TYPE_SHORT  */
#line 7320 "CParse/parser.y"
                            { 
                    (yyval.ptype).type = NewString("short");
                    (yyval.ptype).us = 0;
                }
#line 11971 "CParse/parser.c"
    break;

  case 421: /* type_specifier: TYPE_LONG  */
#line 7324 "CParse/parser.y"
                           { 
                    (yyval.ptype).type = NewString("long");
                    (yyval.ptype).us = 0;
                }
#line 11980 "CParse/parser.c"
    break;

  case 422: /* type_specifier: TYPE_CHAR  */
#line 7328 "CParse/parser.y"
                           { 
                    (yyval.ptype).type = NewString("char");
                    (yyval.ptype).us = 0;
                }
#line 11989 "CParse/parser.c"
    break;

  case 423: /* type_specifier: TYPE_WCHAR  */
#line 7332 "CParse/parser.y"
                            { 
                    (yyval.ptype).type = NewString("wchar_t");
                    (yyval.ptype).us = 0;
                }
#line 11998 "CParse/parser.c"
    break;

  case 424: /* type_specifier: TYPE_FLOAT  */
#line 7336 "CParse/parser.y"
                            { 
                    (yyval.ptype).type = NewString("float");
                    (yyval.ptype).us = 0;
                }
#line 12007 "CParse/parser.c"
    break;

  case 425: /* type_specifier: TYPE_DOUBLE  */
#line 7340 "CParse/parser.y"
                             { 
                    (yyval.ptype).type = NewString("double");
                    (yyval.ptype).us = 0;
                }
#line 12016 "CParse/parser.c"
    break;

  case 426: /* type_specifier: TYPE_SIGNED  */
#line 7344 "CParse/parser.y"
                             { 
                    (yyval.ptype).us = NewString("signed");
                    (yyval.ptype).type = 0;
                }
#line 12025 "CParse/parser.c"
    break;

  case 427: /* type_specifier: TYPE_UNSIGNED  */
#line 7348 "CParse/parser.y"
                               { 
                    (yyval.ptype).us = NewString("unsigned");
                    (yyval.ptype).type = 0;
                }
#line 12034 "CParse/parser.c"
    break;

  case 428: /* type_specifier: TYPE_COMPLEX  */
#line 7352 "CParse/parser.y"
                              { 
                    (yyval.ptype).type = NewString("_Complex");
                    (yyval.ptype).us = 0;
                }
#line 12043 "CParse/parser.c"
    break;

  case 429: /* type_specifier: TYPE_NON_ISO_INT8  */
#line 7356 "CParse/parser.y"
                                   { 
                    (yyval.ptype).type = NewString("__int8");
                    (yyval.ptype).us = 0;
                }
#line 12052 "CParse/parser.c"
    break;

  case 430: /* type_specifier: TYPE_NON_ISO_INT16  */
#line 7360 "CParse/parser.y"
                                    { 
                    (yyval.ptype).type = NewString("__int16");
                    (yyval.ptype).us = 0;
                }
#line 12061 "CParse/parser.c"
    break;

  case 431: /* type_specifier: TYPE_NON_ISO_INT32  */
#line 7364 "CParse/parser.y"
                                    { 
                    (yyval.ptype).type = NewString("__int32");
                    (yyval.ptype).us = 0;
                }
#line 12070 "CParse/parser.c"
    break;

  case 432: /* type_specifier: TYPE_NON_ISO_INT64  */
#line 7368 "CParse/parser.y"
                                    { 
                    (yyval.ptype).type = NewString("__int64");
                    (yyval.ptype).us = 0;
                }
#line 12079 "CParse/parser.c"
    break;

  case 437: /* deleted_definition: DELETE_KW  */
#line 7383 "CParse/parser.y"
                               {
		  (yyval.dtype) = default_dtype;
		  (yyval.dtype).val = NewString("delete");
		  (yyval.dtype).type = T_STRING;
		}
#line 12089 "CParse/parser.c"
    break;

  case 438: /* explicit_default: DEFAULT  */
#line 7391 "CParse/parser.y"
                           {
		  (yyval.dtype) = default_dtype;
		  (yyval.dtype).val = NewString("default");
		  (yyval.dtype).type = T_STRING;
		}
#line 12099 "CParse/parser.c"
    break;

  case 440: /* ename: %empty  */
#line 7401 "CParse/parser.y"
                         { (yyval.id) = 0; }
#line 12105 "CParse/parser.c"
    break;

  case 445: /* enumlist: enumlist_item  */
#line 7420 "CParse/parser.y"
                                {
		  Setattr((yyvsp[0].node),"_last",(yyvsp[0].node));
		  (yyval.node) = (yyvsp[0].node);
		}
#line 12114 "CParse/parser.c"
    break;

  case 446: /* enumlist: enumlist_item DOXYGENPOSTSTRING  */
#line 7424 "CParse/parser.y"
                                                  {
		  Setattr((yyvsp[-1].node),"_last",(yyvsp[-1].node));
		  set_comment((yyvsp[-1].node), (yyvsp[0].str));
		  (yyval.node) = (yyvsp[-1].node);
		}
#line 12124 "CParse/parser.c"
    break;

  case 447: /* enumlist: enumlist_item DOXYGENSTRING  */
#line 7429 "CParse/parser.y"
                                              {
		  Setattr((yyvsp[-1].node), "_last", (yyvsp[-1].node));
		  /* Misplaced doxygen string, attach it to previous parameter, like Doxygen does */
		  set_comment((yyvsp[-1].node), (yyvsp[0].str));
		  (yyval.node) = (yyvsp[-1].node);
		}
#line 12135 "CParse/parser.c"
    break;

  case 448: /* enumlist: enumlist_item COMMA enumlist  */
#line 7435 "CParse/parser.y"
                                                   {
		  if ((yyvsp[0].node)) {
		    set_nextSibling((yyvsp[-2].node), (yyvsp[0].node));
		    Setattr((yyvsp[-2].node),"_last",Getattr((yyvsp[0].node),"_last"));
		    Setattr((yyvsp[0].node),"_last",NULL);
		  } else {
		    Setattr((yyvsp[-2].node),"_last",(yyvsp[-2].node));
		  }
		  (yyval.node) = (yyvsp[-2].node);
		}
#line 12150 "CParse/parser.c"
    break;

  case 449: /* enumlist: enumlist_item DOXYGENPOSTSTRING COMMA enumlist  */
#line 7445 "CParse/parser.y"
                                                                     {
		  if ((yyvsp[0].node)) {
		    set_nextSibling((yyvsp[-3].node), (yyvsp[0].node));
		    Setattr((yyvsp[-3].node),"_last",Getattr((yyvsp[0].node),"_last"));
		    Setattr((yyvsp[0].node),"_last",NULL);
		  } else {
		    Setattr((yyvsp[-3].node),"_last",(yyvsp[-3].node));
		  }
		  set_comment((yyvsp[-3].node), (yyvsp[-2].str));
		  (yyval.node) = (yyvsp[-3].node);
		}
#line 12166 "CParse/parser.c"
    break;

  case 450: /* enumlist: enumlist_item COMMA DOXYGENPOSTSTRING enumlist  */
#line 7456 "CParse/parser.y"
                                                                     {
		  if ((yyvsp[0].node)) {
		    set_nextSibling((yyvsp[-3].node), (yyvsp[0].node));
		    Setattr((yyvsp[-3].node),"_last",Getattr((yyvsp[0].node),"_last"));
		    Setattr((yyvsp[0].node),"_last",NULL);
		  } else {
		    Setattr((yyvsp[-3].node),"_last",(yyvsp[-3].node));
		  }
		  set_comment((yyvsp[-3].node), (yyvsp[-1].str));
		  (yyval.node) = (yyvsp[-3].node);
		}
#line 12182 "CParse/parser.c"
    break;

  case 451: /* enumlist: optional_ignored_defines  */
#line 7467 "CParse/parser.y"
                                           {
		  (yyval.node) = 0;
		}
#line 12190 "CParse/parser.c"
    break;

  case 452: /* enumlist_item: optional_ignored_defines edecl_with_dox optional_ignored_defines  */
#line 7472 "CParse/parser.y"
                                                                                   {
		  (yyval.node) = (yyvsp[-1].node);
		}
#line 12198 "CParse/parser.c"
    break;

  case 454: /* edecl_with_dox: DOXYGENSTRING edecl  */
#line 7478 "CParse/parser.y"
                                      {
		  (yyval.node) = (yyvsp[0].node);
		  set_comment((yyvsp[0].node), (yyvsp[-1].str));
		}
#line 12207 "CParse/parser.c"
    break;

  case 455: /* edecl: identifier  */
#line 7484 "CParse/parser.y"
                             {
		   SwigType *type = NewSwigType(T_INT);
		   (yyval.node) = new_node("enumitem");
		   Setattr((yyval.node),"name",(yyvsp[0].id));
		   Setattr((yyval.node),"type",type);
		   SetFlag((yyval.node),"feature:immutable");
		   Delete(type);
		 }
#line 12220 "CParse/parser.c"
    break;

  case 456: /* edecl: identifier EQUAL etype  */
#line 7492 "CParse/parser.y"
                                          {
		   SwigType *type = NewSwigType((yyvsp[0].dtype).type == T_BOOL ? T_BOOL : ((yyvsp[0].dtype).type == T_CHAR ? T_CHAR : T_INT));
		   (yyval.node) = new_node("enumitem");
		   Setattr((yyval.node),"name",(yyvsp[-2].id));
		   Setattr((yyval.node),"type",type);
		   SetFlag((yyval.node),"feature:immutable");
		   Setattr((yyval.node),"enumvalue", (yyvsp[0].dtype).val);
		   if ((yyvsp[0].dtype).stringval) {
		     Setattr((yyval.node), "enumstringval", (yyvsp[0].dtype).stringval);
		   }
		   if ((yyvsp[0].dtype).numval) {
		     Setattr((yyval.node), "enumnumval", (yyvsp[0].dtype).numval);
		   }
		   Setattr((yyval.node),"value",(yyvsp[-2].id));
		   Delete(type);
                 }
#line 12241 "CParse/parser.c"
    break;

  case 457: /* etype: expr  */
#line 7510 "CParse/parser.y"
                        {
                   (yyval.dtype) = (yyvsp[0].dtype);
		   /* We get T_USER here for a typedef - unfortunately we can't
		    * currently resolve typedefs at this stage of parsing. */
		   if (((yyval.dtype).type != T_INT) && ((yyval.dtype).type != T_UINT) &&
		       ((yyval.dtype).type != T_LONG) && ((yyval.dtype).type != T_ULONG) &&
		       ((yyval.dtype).type != T_LONGLONG) && ((yyval.dtype).type != T_ULONGLONG) &&
		       ((yyval.dtype).type != T_SHORT) && ((yyval.dtype).type != T_USHORT) &&
		       ((yyval.dtype).type != T_SCHAR) && ((yyval.dtype).type != T_UCHAR) &&
		       ((yyval.dtype).type != T_CHAR) && ((yyval.dtype).type != T_BOOL) &&
		       ((yyval.dtype).type != T_UNKNOWN) && ((yyval.dtype).type != T_USER)) {
		     Swig_error(cparse_file,cparse_line,"Type error. Expecting an integral type\n");
		   }
                }
#line 12260 "CParse/parser.c"
    break;

  case 459: /* expr: type  */
#line 7529 "CParse/parser.y"
                      {
		 Node *n;
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = (yyvsp[0].type);
		 (yyval.dtype).type = T_UNKNOWN;
		 {
		   int code = SwigType_type((yyvsp[0].type));     /* swig4ada */
		   if (code != T_USER && code != T_UNKNOWN && code != T_VOID && code != T_STRING && code != T_WSTRING
		       && !SwigType_ispointer((yyvsp[0].type)) && !SwigType_isreference((yyvsp[0].type)) && !SwigType_isrvalue_reference((yyvsp[0].type))
		       && !SwigType_isarray((yyvsp[0].type)) && !SwigType_isqualifier((yyvsp[0].type)) && !SwigType_isfunction((yyvsp[0].type)))
		     (yyval.dtype).standard_type = code;
		 }
		 /* Check if value is in scope */
		 n = Swig_symbol_clookup((yyvsp[0].type),0);
		 if (n) {
                   /* A band-aid for enum values used in expressions. */
                   if (Strcmp(nodeType(n),"enumitem") == 0) {
                     String *q = Swig_symbol_qualified(n);
                     if (q) {
                       (yyval.dtype).val = NewStringf("%s::%s", q, Getattr(n,"name"));
		       (yyval.dtype).type = SwigType_type(Getattr(n, "type"));
                       Delete(q);
                     }
		   } else {
		     SwigType *type = Getattr(n, "type");
		     if (type) {
		       (yyval.dtype).type = SwigType_type(type);
		     }
		   }
		 }
               }
#line 12296 "CParse/parser.c"
    break;

  case 460: /* exprmem: idcolon ARROW ID  */
#line 7563 "CParse/parser.y"
                                  {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s->%s", (yyvsp[-2].str), (yyvsp[0].id));
	       }
#line 12305 "CParse/parser.c"
    break;

  case 461: /* exprmem: exprmem ARROW ID  */
#line 7567 "CParse/parser.y"
                                      {
		 (yyval.dtype) = (yyvsp[-2].dtype);
		 Printf((yyval.dtype).val, "->%s", (yyvsp[0].id));
	       }
#line 12314 "CParse/parser.c"
    break;

  case 462: /* exprmem: idcolon PERIOD ID  */
#line 7571 "CParse/parser.y"
                                   {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s.%s", (yyvsp[-2].str), (yyvsp[0].id));
	       }
#line 12323 "CParse/parser.c"
    break;

  case 463: /* exprmem: exprmem PERIOD ID  */
#line 7575 "CParse/parser.y"
                                       {
		 (yyval.dtype) = (yyvsp[-2].dtype);
		 Printf((yyval.dtype).val, ".%s", (yyvsp[0].id));
	       }
#line 12332 "CParse/parser.c"
    break;

  case 464: /* exprmem: exprmem LPAREN  */
#line 7579 "CParse/parser.y"
                                    {
		 if (skip_balanced('(', ')') < 0) Exit(EXIT_FAILURE);
		 (yyval.dtype) = (yyvsp[-1].dtype);
		 append_expr_from_scanner((yyval.dtype).val);
	       }
#line 12342 "CParse/parser.c"
    break;

  case 465: /* exprmem: type LPAREN  */
#line 7584 "CParse/parser.y"
                             {
		 (yyval.dtype) = default_dtype;
		 if (skip_balanced('(', ')') < 0) Exit(EXIT_FAILURE);

		 String *qty = Swig_symbol_type_qualify((yyvsp[-1].type), 0);
		 if (SwigType_istemplate(qty)) {
		   String *nstr = SwigType_namestr(qty);
		   Delete(qty);
		   qty = nstr;
		 }
		 /* Try to deduce the type - this could be a C++ "constructor
		  * cast" such as `double(4)` or a function call such as
		  * `some_func()`.  In the latter case we get T_USER, but that
		  * is wrong so we map it to T_UNKNOWN until we can actually
		  * deduce the return type of a function call (which is
		  * complicated because the return type can vary between
		  * overloaded forms).
		  */
		 (yyval.dtype).type = SwigType_type(qty);
		 if ((yyval.dtype).type == T_USER) (yyval.dtype).type = T_UNKNOWN;
		 (yyval.dtype).unary_arg_type = 0;

		 (yyval.dtype).val = qty;
		 append_expr_from_scanner((yyval.dtype).val);
	       }
#line 12372 "CParse/parser.c"
    break;

  case 468: /* constraint_or: constraint_or LOR constraint_and  */
#line 7636 "CParse/parser.y"
                                                  {
                    (yyval.node) = Constraint_combine("or", (yyvsp[-2].node), (yyvsp[0].node));
                 }
#line 12380 "CParse/parser.c"
    break;

  case 470: /* constraint_and: constraint_and LAND constraint_primary  */
#line 7642 "CParse/parser.y"
                                                        {
                    (yyval.node) = Constraint_combine("and", (yyvsp[-2].node), (yyvsp[0].node));
                 }
#line 12388 "CParse/parser.c"
    break;

  case 471: /* constraint_primary: idcolon  */
#line 7647 "CParse/parser.y"
                             {
                    /* idcolon's value is a SwigType encoded concept-id (e.g. 'AllNumeric<(T,v.Rest)>'),
                       so it lives on a "type" attribute, not "name". */
                    (yyval.node) = Constraint_new_atom("concept-id");
                    Setattr((yyval.node), "type", (yyvsp[0].str));
                 }
#line 12399 "CParse/parser.c"
    break;

  case 472: /* @12: %empty  */
#line 7653 "CParse/parser.y"
                              {
                    /* Parenthesised primary - opaque captured at the scanner
                     * level so the body can be any C++ expression, not only a
                     * constraint.  This handles forms like '(sizeof(T) <= 4)'
                     * that are valid constraint primaries but not constraint
                     * expressions, and avoids the LALR(1) conflict between
                     * 'LPAREN constraint RPAREN' and an expression alternative.
                     * The captured text retains its surrounding parens. */
                    String *captured;
                    if (skip_balanced('(', ')') < 0) Exit(EXIT_FAILURE);
                    captured = Copy(scanner_ccode);
                    (yyval.node) = Constraint_new_atom("expression");
                    Setattr((yyval.node), "value", captured);
                    Delete(captured);
                 }
#line 12419 "CParse/parser.c"
    break;

  case 473: /* constraint_primary: LPAREN @12  */
#line 7667 "CParse/parser.y"
                         {
                    (yyval.node) = (yyvsp[0].node);
                 }
#line 12427 "CParse/parser.c"
    break;

  case 474: /* constraint_primary: requires_expression  */
#line 7670 "CParse/parser.y"
                                     {
                    (yyval.node) = Constraint_new_atom("requires-expression");
                    appendChild((yyval.node), (yyvsp[0].node));
                 }
#line 12436 "CParse/parser.c"
    break;

  case 475: /* requires_expression: REQUIRES requirement_parameter_list_opt requirement_body  */
#line 7676 "CParse/parser.y"
                                                                               {
                    (yyval.node) = Constraint_new_requires_expression();
                    if ((yyvsp[-1].pl))
                      Setattr((yyval.node), "parms", (yyvsp[-1].pl));
                    {
                      Node *r = (yyvsp[0].node);
                      while (r) {
                        Node *next = nextSibling(r);
                        set_nextSibling(r, 0);
                        set_previousSibling(r, 0);
                        appendChild((yyval.node), r);
                        r = next;
                      }
                    }
                 }
#line 12456 "CParse/parser.c"
    break;

  case 476: /* requirement_parameter_list_opt: LPAREN parms RPAREN  */
#line 7693 "CParse/parser.y"
                                                     {
                    (yyval.pl) = (yyvsp[-1].pl);
                 }
#line 12464 "CParse/parser.c"
    break;

  case 477: /* requirement_parameter_list_opt: %empty  */
#line 7696 "CParse/parser.y"
                        {
                    (yyval.pl) = 0;
                 }
#line 12472 "CParse/parser.c"
    break;

  case 478: /* requirement_body: LBRACE  */
#line 7701 "CParse/parser.y"
                          {
                    if (skip_balanced('{', '}') < 0) Exit(EXIT_FAILURE);
                    (yyval.node) = parse_requirement_seq(scanner_ccode);
                 }
#line 12481 "CParse/parser.c"
    break;

  case 481: /* exprsimple: string  */
#line 7710 "CParse/parser.y"
                        {
		  (yyval.dtype) = default_dtype;
		  (yyval.dtype).stringval = (yyvsp[0].str);
		  (yyval.dtype).val = NewStringf("\"%(escape)s\"", (yyvsp[0].str));
		  (yyval.dtype).type = T_STRING;
	       }
#line 12492 "CParse/parser.c"
    break;

  case 482: /* exprsimple: wstring  */
#line 7716 "CParse/parser.y"
                         {
		  (yyval.dtype) = default_dtype;
		  (yyval.dtype).stringval = (yyvsp[0].str);
		  (yyval.dtype).val = NewStringf("L\"%(escape)s\"", (yyvsp[0].str));
		  (yyval.dtype).type = T_WSTRING;
	       }
#line 12503 "CParse/parser.c"
    break;

  case 483: /* exprsimple: CHARCONST  */
#line 7722 "CParse/parser.y"
                           {
		  (yyval.dtype) = default_dtype;
		  (yyval.dtype).val = NewStringf("'%(escape)s'", (yyvsp[0].str));
		  if (Len((yyvsp[0].str)) > 1) {
		    /* A multicharacter constant, e.g. 'ab', has type int per the C and
		     * C++ standards (unlike a single-character literal, which has type
		     * char in C++). Its value is implementation-defined. */
		    (yyval.dtype).type = T_INT;
		  } else {
		    (yyval.dtype).stringval = (yyvsp[0].str);
		    (yyval.dtype).type = T_CHAR;
		  }
	       }
#line 12521 "CParse/parser.c"
    break;

  case 484: /* exprsimple: WCHARCONST  */
#line 7735 "CParse/parser.y"
                            {
		  (yyval.dtype) = default_dtype;
		  (yyval.dtype).stringval = (yyvsp[0].str);
		  (yyval.dtype).val = NewStringf("L'%(escape)s'", (yyvsp[0].str));
		  (yyval.dtype).type = T_WCHAR;
	       }
#line 12532 "CParse/parser.c"
    break;

  case 485: /* exprsimple: SIZEOF LPAREN  */
#line 7747 "CParse/parser.y"
                               {
		  if (skip_balanced('(', ')') < 0) Exit(EXIT_FAILURE);
		  (yyval.dtype) = default_dtype;
		  (yyval.dtype).val = NewString("sizeof");
		  append_expr_from_scanner((yyval.dtype).val);
		  (yyval.dtype).type = T_ULONG;
               }
#line 12544 "CParse/parser.c"
    break;

  case 486: /* exprsimple: ALIGNOF LPAREN  */
#line 7755 "CParse/parser.y"
                                {
		  if (skip_balanced('(', ')') < 0) Exit(EXIT_FAILURE);
		  (yyval.dtype) = default_dtype;
		  (yyval.dtype).val = NewString("alignof");
		  append_expr_from_scanner((yyval.dtype).val);
		  (yyval.dtype).type = T_ULONG;
	       }
#line 12556 "CParse/parser.c"
    break;

  case 487: /* exprsimple: NOEXCEPT LPAREN  */
#line 7763 "CParse/parser.y"
                                 {
		  if (skip_balanced('(', ')') < 0) Exit(EXIT_FAILURE);
		  (yyval.dtype) = default_dtype;
		  (yyval.dtype).val = NewString("noexcept");
		  append_expr_from_scanner((yyval.dtype).val);
		  (yyval.dtype).type = T_BOOL;
	       }
#line 12568 "CParse/parser.c"
    break;

  case 488: /* exprsimple: SIZEOF ELLIPSIS LPAREN identifier RPAREN  */
#line 7770 "CParse/parser.y"
                                                          {
		  (yyval.dtype) = default_dtype;
		  (yyval.dtype).val = NewStringf("sizeof...(%s)", (yyvsp[-1].id));
		  (yyval.dtype).type = T_ULONG;
               }
#line 12578 "CParse/parser.c"
    break;

  case 489: /* exprsimple: SIZEOF exprsimple  */
#line 7780 "CParse/parser.y"
                                       {
		  (yyval.dtype) = default_dtype;
		  (yyval.dtype).val = NewStringf("sizeof(%s)", (yyvsp[0].dtype).val);
		  (yyval.dtype).type = T_ULONG;
	       }
#line 12588 "CParse/parser.c"
    break;

  case 492: /* valexpr: requires_expression  */
#line 7798 "CParse/parser.y"
                                     {
		    (yyval.dtype) = default_dtype;
		    (yyval.dtype).val = NewString("");
		    (yyval.dtype).type = T_BOOL;
		    Delete((yyvsp[0].node));
	       }
#line 12599 "CParse/parser.c"
    break;

  case 493: /* valexpr: LPAREN expr RPAREN  */
#line 7806 "CParse/parser.y"
                                                {
	            (yyval.dtype) = default_dtype;
		    (yyval.dtype).val = NewStringf("(%s)",(yyvsp[-1].dtype).val);
		    (yyval.dtype).stringval = Copy((yyvsp[-1].dtype).stringval);
		    (yyval.dtype).numval = Copy((yyvsp[-1].dtype).numval);
		    (yyval.dtype).type = (yyvsp[-1].dtype).type;
		    (yyval.dtype).standard_type = (yyvsp[-1].dtype).standard_type;     /* swig4ada */
	       }
#line 12612 "CParse/parser.c"
    break;

  case 494: /* valexpr: LPAREN expr RPAREN expr  */
#line 7817 "CParse/parser.y"
                                                              {
		 int cast_type_code = SwigType_type((yyvsp[-2].dtype).val);
		 (yyval.dtype) = (yyvsp[0].dtype);
		 (yyval.dtype).unary_arg_type = 0;
		 if ((yyvsp[0].dtype).type != T_STRING) {
		   switch ((yyvsp[-2].dtype).type) {
		     case T_FLOAT:
		     case T_DOUBLE:
		     case T_LONGDOUBLE:
		     case T_FLTCPLX:
		     case T_DBLCPLX:
		       (yyval.dtype).val = NewStringf("(%s)%s", (yyvsp[-2].dtype).val, (yyvsp[0].dtype).val); /* SwigType_str and decimal points don't mix! */
		       break;
		     default:
		       (yyval.dtype).val = NewStringf("(%s) %s", SwigType_str((yyvsp[-2].dtype).val,0), (yyvsp[0].dtype).val);
		       break;
		   }
		   (yyval.dtype).stringval = 0;
		   (yyval.dtype).numval = 0;
		 }
		 /* As well as C-style casts, this grammar rule currently also
		  * matches a binary operator with a LHS in parentheses for
		  * binary operators which also have an unary form, e.g.:
		  *
		  * (6)*7
		  * (6)&7
		  * (6)+7
		  * (6)-7
		  */
		 if (cast_type_code != T_USER && cast_type_code != T_UNKNOWN) {
		   /* $lhs is definitely a type so we know this is a cast. */
		   (yyval.dtype).type = cast_type_code;
		 } else if ((yyvsp[0].dtype).type == 0 || (yyvsp[0].dtype).unary_arg_type == 0) {
		   /* Not one of the cases above, so we know this is a cast. */
		   (yyval.dtype).type = cast_type_code;
		 } else {
		   (yyval.dtype).type = promote((yyvsp[-2].dtype).type, (yyvsp[0].dtype).unary_arg_type);
		 }
 	       }
#line 12656 "CParse/parser.c"
    break;

  case 495: /* valexpr: LPAREN expr pointer RPAREN expr  */
#line 7856 "CParse/parser.y"
                                                                      {
                 (yyval.dtype) = (yyvsp[0].dtype);
		 (yyval.dtype).unary_arg_type = 0;
		 if ((yyvsp[0].dtype).type != T_STRING) {
		   SwigType_push((yyvsp[-3].dtype).val,(yyvsp[-2].type));
		   (yyval.dtype).val = NewStringf("(%s) %s", SwigType_str((yyvsp[-3].dtype).val,0), (yyvsp[0].dtype).val);
		   (yyval.dtype).stringval = 0;
		   (yyval.dtype).numval = 0;
		 }
 	       }
#line 12671 "CParse/parser.c"
    break;

  case 496: /* valexpr: LPAREN expr AND RPAREN expr  */
#line 7866 "CParse/parser.y"
                                                                  {
                 (yyval.dtype) = (yyvsp[0].dtype);
		 (yyval.dtype).unary_arg_type = 0;
		 if ((yyvsp[0].dtype).type != T_STRING) {
		   SwigType_add_reference((yyvsp[-3].dtype).val);
		   (yyval.dtype).val = NewStringf("(%s) %s", SwigType_str((yyvsp[-3].dtype).val,0), (yyvsp[0].dtype).val);
		   (yyval.dtype).stringval = 0;
		   (yyval.dtype).numval = 0;
		 }
 	       }
#line 12686 "CParse/parser.c"
    break;

  case 497: /* valexpr: LPAREN expr LAND RPAREN expr  */
#line 7876 "CParse/parser.y"
                                                                   {
                 (yyval.dtype) = (yyvsp[0].dtype);
		 (yyval.dtype).unary_arg_type = 0;
		 if ((yyvsp[0].dtype).type != T_STRING) {
		   SwigType_add_rvalue_reference((yyvsp[-3].dtype).val);
		   (yyval.dtype).val = NewStringf("(%s) %s", SwigType_str((yyvsp[-3].dtype).val,0), (yyvsp[0].dtype).val);
		   (yyval.dtype).stringval = 0;
		   (yyval.dtype).numval = 0;
		 }
 	       }
#line 12701 "CParse/parser.c"
    break;

  case 498: /* valexpr: LPAREN expr pointer AND RPAREN expr  */
#line 7886 "CParse/parser.y"
                                                                          {
                 (yyval.dtype) = (yyvsp[0].dtype);
		 (yyval.dtype).unary_arg_type = 0;
		 if ((yyvsp[0].dtype).type != T_STRING) {
		   SwigType_push((yyvsp[-4].dtype).val,(yyvsp[-3].type));
		   SwigType_add_reference((yyvsp[-4].dtype).val);
		   (yyval.dtype).val = NewStringf("(%s) %s", SwigType_str((yyvsp[-4].dtype).val,0), (yyvsp[0].dtype).val);
		   (yyval.dtype).stringval = 0;
		   (yyval.dtype).numval = 0;
		 }
 	       }
#line 12717 "CParse/parser.c"
    break;

  case 499: /* valexpr: LPAREN expr pointer LAND RPAREN expr  */
#line 7897 "CParse/parser.y"
                                                                           {
                 (yyval.dtype) = (yyvsp[0].dtype);
		 (yyval.dtype).unary_arg_type = 0;
		 if ((yyvsp[0].dtype).type != T_STRING) {
		   SwigType_push((yyvsp[-4].dtype).val,(yyvsp[-3].type));
		   SwigType_add_rvalue_reference((yyvsp[-4].dtype).val);
		   (yyval.dtype).val = NewStringf("(%s) %s", SwigType_str((yyvsp[-4].dtype).val,0), (yyvsp[0].dtype).val);
		   (yyval.dtype).stringval = 0;
		   (yyval.dtype).numval = 0;
		 }
 	       }
#line 12733 "CParse/parser.c"
    break;

  case 500: /* valexpr: AND expr  */
#line 7908 "CParse/parser.y"
                          {
		 (yyval.dtype) = (yyvsp[0].dtype);
		 (yyval.dtype).val = NewStringf("&%s", (yyvsp[0].dtype).val);
		 (yyval.dtype).stringval = 0;
		 (yyval.dtype).numval = 0;
		 /* Record the type code for expr so we can properly handle
		  * cases such as (6)&7 which get parsed using this rule then
		  * the rule for a C-style cast.
		  */
		 (yyval.dtype).unary_arg_type = (yyvsp[0].dtype).type;
		 switch ((yyval.dtype).type) {
		   case T_CHAR:
		     (yyval.dtype).type = T_STRING;
		     break;
		   case T_WCHAR:
		     (yyval.dtype).type = T_WSTRING;
		     break;
		   default:
		     (yyval.dtype).type = T_POINTER;
		 }
	       }
#line 12759 "CParse/parser.c"
    break;

  case 501: /* valexpr: STAR expr  */
#line 7929 "CParse/parser.y"
                           {
		 (yyval.dtype) = (yyvsp[0].dtype);
		 (yyval.dtype).val = NewStringf("*%s", (yyvsp[0].dtype).val);
		 (yyval.dtype).stringval = 0;
		 (yyval.dtype).numval = 0;
		 /* Record the type code for expr so we can properly handle
		  * cases such as (6)*7 which get parsed using this rule then
		  * the rule for a C-style cast.
		  */
		 (yyval.dtype).unary_arg_type = (yyvsp[0].dtype).type;
		 switch ((yyval.dtype).type) {
		   case T_STRING:
		     (yyval.dtype).type = T_CHAR;
		     break;
		   case T_WSTRING:
		     (yyval.dtype).type = T_WCHAR;
		     break;
		   default:
		     (yyval.dtype).type = T_UNKNOWN;
		 }
	       }
#line 12785 "CParse/parser.c"
    break;

  case 512: /* exprcompound: expr PLUS expr  */
#line 7964 "CParse/parser.y"
                                          {
		 (yyval.dtype) = default_dtype;
		 if ((yyvsp[-2].dtype).val && Char((yyvsp[-2].dtype).val)[0] == '(' && (yyvsp[-2].dtype).standard_type) {
		   /* swig4ada: a standard type in brackets is a cast of the operand with its sign, of that type. */
		   (yyval.dtype).val = NewStringf("%s +%s", (yyvsp[-2].dtype).val, (yyvsp[0].dtype).val);
		   (yyval.dtype).type = (yyvsp[-2].dtype).standard_type;
		 } else {
		   (yyval.dtype).val = NewStringf("%s+%s", (yyvsp[-2].dtype).val, (yyvsp[0].dtype).val);
		   (yyval.dtype).type = promote((yyvsp[-2].dtype).type,(yyvsp[0].dtype).type);
		 }
	       }
#line 12801 "CParse/parser.c"
    break;

  case 513: /* exprcompound: expr MINUS expr  */
#line 7975 "CParse/parser.y"
                                           {
		 (yyval.dtype) = default_dtype;
		 if ((yyvsp[-2].dtype).val && Char((yyvsp[-2].dtype).val)[0] == '(' && (yyvsp[-2].dtype).standard_type) {
		   /* swig4ada: likewise. */
		   (yyval.dtype).val = NewStringf("%s -%s", (yyvsp[-2].dtype).val, (yyvsp[0].dtype).val);
		   (yyval.dtype).type = (yyvsp[-2].dtype).standard_type;
		 } else {
		   (yyval.dtype).val = NewStringf("%s-%s", (yyvsp[-2].dtype).val, (yyvsp[0].dtype).val);
		   (yyval.dtype).type = promote((yyvsp[-2].dtype).type,(yyvsp[0].dtype).type);
		 }
	       }
#line 12817 "CParse/parser.c"
    break;

  case 514: /* exprcompound: expr STAR expr  */
#line 7986 "CParse/parser.y"
                                          {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s*%s", (yyvsp[-2].dtype).val, (yyvsp[0].dtype).val);
		 (yyval.dtype).type = promote((yyvsp[-2].dtype).type,(yyvsp[0].dtype).type);
	       }
#line 12827 "CParse/parser.c"
    break;

  case 515: /* exprcompound: expr SLASH expr  */
#line 7991 "CParse/parser.y"
                                           {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s/%s", (yyvsp[-2].dtype).val, (yyvsp[0].dtype).val);
		 (yyval.dtype).type = promote((yyvsp[-2].dtype).type,(yyvsp[0].dtype).type);
	       }
#line 12837 "CParse/parser.c"
    break;

  case 516: /* exprcompound: expr MODULO expr  */
#line 7996 "CParse/parser.y"
                                            {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s%%%s", (yyvsp[-2].dtype).val, (yyvsp[0].dtype).val);
		 (yyval.dtype).type = promote((yyvsp[-2].dtype).type,(yyvsp[0].dtype).type);
	       }
#line 12847 "CParse/parser.c"
    break;

  case 517: /* exprcompound: expr AND expr  */
#line 8001 "CParse/parser.y"
                                         {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s&%s", (yyvsp[-2].dtype).val, (yyvsp[0].dtype).val);
		 (yyval.dtype).type = promote((yyvsp[-2].dtype).type,(yyvsp[0].dtype).type);
	       }
#line 12857 "CParse/parser.c"
    break;

  case 518: /* exprcompound: expr OR expr  */
#line 8006 "CParse/parser.y"
                                        {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s|%s", (yyvsp[-2].dtype).val, (yyvsp[0].dtype).val);
		 (yyval.dtype).type = promote((yyvsp[-2].dtype).type,(yyvsp[0].dtype).type);
	       }
#line 12867 "CParse/parser.c"
    break;

  case 519: /* exprcompound: expr XOR expr  */
#line 8011 "CParse/parser.y"
                                         {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s^%s", (yyvsp[-2].dtype).val, (yyvsp[0].dtype).val);
		 (yyval.dtype).type = promote((yyvsp[-2].dtype).type,(yyvsp[0].dtype).type);
	       }
#line 12877 "CParse/parser.c"
    break;

  case 520: /* exprcompound: expr LSHIFT expr  */
#line 8016 "CParse/parser.y"
                                            {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s << %s", (yyvsp[-2].dtype).val, (yyvsp[0].dtype).val);
		 (yyval.dtype).type = promote_type((yyvsp[-2].dtype).type);
	       }
#line 12887 "CParse/parser.c"
    break;

  case 521: /* exprcompound: expr RSHIFT expr  */
#line 8021 "CParse/parser.y"
                                            {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s >> %s", (yyvsp[-2].dtype).val, (yyvsp[0].dtype).val);
		 (yyval.dtype).type = promote_type((yyvsp[-2].dtype).type);
	       }
#line 12897 "CParse/parser.c"
    break;

  case 522: /* exprcompound: expr LAND expr  */
#line 8026 "CParse/parser.y"
                                          {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s&&%s", (yyvsp[-2].dtype).val, (yyvsp[0].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       }
#line 12907 "CParse/parser.c"
    break;

  case 523: /* exprcompound: expr LOR expr  */
#line 8031 "CParse/parser.y"
                                         {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s||%s", (yyvsp[-2].dtype).val, (yyvsp[0].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       }
#line 12917 "CParse/parser.c"
    break;

  case 524: /* exprcompound: expr EQUALTO expr  */
#line 8036 "CParse/parser.y"
                                             {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s==%s", (yyvsp[-2].dtype).val, (yyvsp[0].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       }
#line 12927 "CParse/parser.c"
    break;

  case 525: /* exprcompound: expr NOTEQUALTO expr  */
#line 8041 "CParse/parser.y"
                                                {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s!=%s", (yyvsp[-2].dtype).val, (yyvsp[0].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       }
#line 12937 "CParse/parser.c"
    break;

  case 526: /* exprcompound: LPAREN expr GREATERTHAN expr RPAREN  */
#line 8050 "CParse/parser.y"
                                                               {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("(%s > %s)", (yyvsp[-3].dtype).val, (yyvsp[-1].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       }
#line 12947 "CParse/parser.c"
    break;

  case 527: /* exprcompound: LPAREN exprsimple LESSTHAN expr RPAREN  */
#line 8061 "CParse/parser.y"
                                                                  {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("(%s < %s)", (yyvsp[-3].dtype).val, (yyvsp[-1].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       }
#line 12957 "CParse/parser.c"
    break;

  case 528: /* exprcompound: expr GREATERTHANOREQUALTO expr  */
#line 8066 "CParse/parser.y"
                                                          {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s >= %s", (yyvsp[-2].dtype).val, (yyvsp[0].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       }
#line 12967 "CParse/parser.c"
    break;

  case 529: /* exprcompound: expr LESSTHANOREQUALTO expr  */
#line 8071 "CParse/parser.y"
                                                       {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s <= %s", (yyvsp[-2].dtype).val, (yyvsp[0].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       }
#line 12977 "CParse/parser.c"
    break;

  case 530: /* exprcompound: expr PLUS ELLIPSIS  */
#line 8088 "CParse/parser.y"
                                         {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s+...", (yyvsp[-2].dtype).val);
		 (yyval.dtype).type = promote_type((yyvsp[-2].dtype).type);
	       }
#line 12987 "CParse/parser.c"
    break;

  case 531: /* exprcompound: expr MINUS ELLIPSIS  */
#line 8093 "CParse/parser.y"
                                          {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s-...", (yyvsp[-2].dtype).val);
		 (yyval.dtype).type = promote_type((yyvsp[-2].dtype).type);
	       }
#line 12997 "CParse/parser.c"
    break;

  case 532: /* exprcompound: expr STAR ELLIPSIS  */
#line 8098 "CParse/parser.y"
                                         {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s*...", (yyvsp[-2].dtype).val);
		 (yyval.dtype).type = promote_type((yyvsp[-2].dtype).type);
	       }
#line 13007 "CParse/parser.c"
    break;

  case 533: /* exprcompound: expr SLASH ELLIPSIS  */
#line 8103 "CParse/parser.y"
                                          {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s/...", (yyvsp[-2].dtype).val);
		 (yyval.dtype).type = promote_type((yyvsp[-2].dtype).type);
	       }
#line 13017 "CParse/parser.c"
    break;

  case 534: /* exprcompound: expr MODULO ELLIPSIS  */
#line 8108 "CParse/parser.y"
                                           {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s%%...", (yyvsp[-2].dtype).val);
		 (yyval.dtype).type = promote_type((yyvsp[-2].dtype).type);
	       }
#line 13027 "CParse/parser.c"
    break;

  case 535: /* exprcompound: expr AND ELLIPSIS  */
#line 8113 "CParse/parser.y"
                                        {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s&...", (yyvsp[-2].dtype).val);
		 (yyval.dtype).type = promote_type((yyvsp[-2].dtype).type);
	       }
#line 13037 "CParse/parser.c"
    break;

  case 536: /* exprcompound: expr OR ELLIPSIS  */
#line 8118 "CParse/parser.y"
                                       {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s|...", (yyvsp[-2].dtype).val);
		 (yyval.dtype).type = promote_type((yyvsp[-2].dtype).type);
	       }
#line 13047 "CParse/parser.c"
    break;

  case 537: /* exprcompound: expr XOR ELLIPSIS  */
#line 8123 "CParse/parser.y"
                                        {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s^...", (yyvsp[-2].dtype).val);
		 (yyval.dtype).type = promote_type((yyvsp[-2].dtype).type);
	       }
#line 13057 "CParse/parser.c"
    break;

  case 538: /* exprcompound: expr LSHIFT ELLIPSIS  */
#line 8128 "CParse/parser.y"
                                           {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s << ...", (yyvsp[-2].dtype).val);
		 (yyval.dtype).type = promote_type((yyvsp[-2].dtype).type);
	       }
#line 13067 "CParse/parser.c"
    break;

  case 539: /* exprcompound: expr RSHIFT ELLIPSIS  */
#line 8133 "CParse/parser.y"
                                           {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s >> ...", (yyvsp[-2].dtype).val);
		 (yyval.dtype).type = promote_type((yyvsp[-2].dtype).type);
	       }
#line 13077 "CParse/parser.c"
    break;

  case 540: /* exprcompound: expr LAND ELLIPSIS  */
#line 8138 "CParse/parser.y"
                                         {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s&&...", (yyvsp[-2].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       }
#line 13087 "CParse/parser.c"
    break;

  case 541: /* exprcompound: expr LOR ELLIPSIS  */
#line 8143 "CParse/parser.y"
                                        {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s||...", (yyvsp[-2].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       }
#line 13097 "CParse/parser.c"
    break;

  case 542: /* exprcompound: expr EQUALTO ELLIPSIS  */
#line 8148 "CParse/parser.y"
                                            {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s==...", (yyvsp[-2].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       }
#line 13107 "CParse/parser.c"
    break;

  case 543: /* exprcompound: expr NOTEQUALTO ELLIPSIS  */
#line 8153 "CParse/parser.y"
                                               {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s!=...", (yyvsp[-2].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       }
#line 13117 "CParse/parser.c"
    break;

  case 544: /* exprcompound: LPAREN expr GREATERTHAN ELLIPSIS RPAREN  */
#line 8162 "CParse/parser.y"
                                                              {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("(%s > ...)", (yyvsp[-3].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       }
#line 13127 "CParse/parser.c"
    break;

  case 545: /* exprcompound: LPAREN exprsimple LESSTHAN ELLIPSIS RPAREN  */
#line 8172 "CParse/parser.y"
                                                                 {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("(%s < %s)", (yyvsp[-3].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       }
#line 13137 "CParse/parser.c"
    break;

  case 546: /* exprcompound: expr GREATERTHANOREQUALTO ELLIPSIS  */
#line 8177 "CParse/parser.y"
                                                         {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s >= ...", (yyvsp[-2].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       }
#line 13147 "CParse/parser.c"
    break;

  case 547: /* exprcompound: expr LESSTHANOREQUALTO ELLIPSIS  */
#line 8182 "CParse/parser.y"
                                                      {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s <= ...", (yyvsp[-2].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       }
#line 13157 "CParse/parser.c"
    break;

  case 548: /* exprcompound: expr LESSEQUALGREATER expr  */
#line 8188 "CParse/parser.y"
                                                      {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s <=> %s", (yyvsp[-2].dtype).val, (yyvsp[0].dtype).val);
		 /* `<=>` returns one of `std::strong_ordering`,
		  * `std::partial_ordering` or `std::weak_ordering`.  The main
		  * thing to do with the return value in this context is to
		  * compare it with another ordering of the same type or
		  * with a literal 0.  We set .type = T_USER here which does
		  * what we want for the comparison operators, and also means
		  * that deduce_type() won't deduce a type for this (which is
		  * better than it deducing the wrong type).
		  */
		 (yyval.dtype).type = T_USER;
		 (yyval.dtype).unary_arg_type = 0;
	       }
#line 13177 "CParse/parser.c"
    break;

  case 549: /* exprcompound: expr QUESTIONMARK expr COLON expr  */
#line 8203 "CParse/parser.y"
                                                                                           {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s?%s:%s", (yyvsp[-4].dtype).val, (yyvsp[-2].dtype).val, (yyvsp[0].dtype).val);
		 /* This may not be exactly right, but is probably good enough
		  * for the purposes of parsing constant expressions. */
		 (yyval.dtype).type = promote((yyvsp[-2].dtype).type, (yyvsp[0].dtype).type);
	       }
#line 13189 "CParse/parser.c"
    break;

  case 550: /* exprcompound: MINUS expr  */
#line 8210 "CParse/parser.y"
                                             {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("-%s",(yyvsp[0].dtype).val);
		 if ((yyvsp[0].dtype).numval) {
		   switch ((yyvsp[0].dtype).type) {
		     case T_CHAR: // Unsigned on some architectures.
		     case T_UCHAR:
		     case T_USHORT:
		     case T_UINT:
		     case T_ULONG:
		     case T_ULONGLONG:
		       // Avoid negative numval with an unsigned type.
		       break;
		     default:
		       (yyval.dtype).numval = NewStringf("-%s", (yyvsp[0].dtype).numval);
		       break;
		   }
		   Delete((yyvsp[0].dtype).numval);
		 }
		 (yyval.dtype).type = promote_type((yyvsp[0].dtype).type);
		 /* Record the type code for expr so we can properly handle
		  * cases such as (6)-7 which get parsed using this rule then
		  * the rule for a C-style cast.
		  */
		 (yyval.dtype).unary_arg_type = (yyvsp[0].dtype).type;
	       }
#line 13220 "CParse/parser.c"
    break;

  case 551: /* exprcompound: PLUS expr  */
#line 8236 "CParse/parser.y"
                                            {
		 (yyval.dtype) = default_dtype;
                 (yyval.dtype).val = NewStringf("+%s",(yyvsp[0].dtype).val);
		 (yyval.dtype).numval = (yyvsp[0].dtype).numval;
		 (yyval.dtype).type = promote_type((yyvsp[0].dtype).type);
		 /* Record the type code for expr so we can properly handle
		  * cases such as (6)+7 which get parsed using this rule then
		  * the rule for a C-style cast.
		  */
		 (yyval.dtype).unary_arg_type = (yyvsp[0].dtype).type;
	       }
#line 13236 "CParse/parser.c"
    break;

  case 552: /* exprcompound: NOT expr  */
#line 8247 "CParse/parser.y"
                              {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("~%s",(yyvsp[0].dtype).val);
		 (yyval.dtype).type = promote_type((yyvsp[0].dtype).type);
	       }
#line 13246 "CParse/parser.c"
    break;

  case 553: /* exprcompound: LNOT expr  */
#line 8252 "CParse/parser.y"
                               {
		 (yyval.dtype) = default_dtype;
                 (yyval.dtype).val = NewStringf("!%s", (yyvsp[0].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       }
#line 13256 "CParse/parser.c"
    break;

  case 554: /* variadic_opt: ELLIPSIS  */
#line 8259 "CParse/parser.y"
                         {
		(yyval.intvalue) = 1;
	      }
#line 13264 "CParse/parser.c"
    break;

  case 555: /* variadic_opt: %empty  */
#line 8262 "CParse/parser.y"
                       {
	        (yyval.intvalue) = 0;
	      }
#line 13272 "CParse/parser.c"
    break;

  case 557: /* $@13: %empty  */
#line 8270 "CParse/parser.y"
                        { inherit_list = 1; }
#line 13278 "CParse/parser.c"
    break;

  case 558: /* raw_inherit: COLON $@13 base_list  */
#line 8270 "CParse/parser.y"
                                                        { (yyval.bases) = (yyvsp[0].bases); inherit_list = 0; }
#line 13284 "CParse/parser.c"
    break;

  case 559: /* raw_inherit: %empty  */
#line 8271 "CParse/parser.y"
                         { (yyval.bases) = 0; }
#line 13290 "CParse/parser.c"
    break;

  case 560: /* base_list: base_specifier  */
#line 8274 "CParse/parser.y"
                                {
		   Hash *list = NewHash();
		   Node *base = (yyvsp[0].node);
		   Node *name = Getattr(base,"name");
		   List *lpublic = NewList();
		   List *lprotected = NewList();
		   List *lprivate = NewList();
		   List *lvirtual = NewList();     /* swig4ada */
		   Setattr(list,"public",lpublic);
		   Setattr(list,"protected",lprotected);
		   Setattr(list,"private",lprivate);
		   Setattr(list,"virtual",lvirtual);
		   Delete(lpublic);
		   Delete(lprotected);
		   Delete(lprivate);
		   Delete(lvirtual);
		   Append(Getattr(list,Getattr(base,"access")),name);
		   if (Getattr(base,"virtual"))
		     Append(Getattr(list,"virtual"),name);
	           (yyval.bases) = list;
               }
#line 13316 "CParse/parser.c"
    break;

  case 561: /* base_list: base_list COMMA base_specifier  */
#line 8296 "CParse/parser.y"
                                                    {
		   Hash *list = (yyvsp[-2].bases);
		   Node *base = (yyvsp[0].node);
		   Node *name = Getattr(base,"name");
		   Append(Getattr(list,Getattr(base,"access")),name);
		   if (Getattr(base,"virtual"))     /* swig4ada */
		     Append(Getattr(list,"virtual"),name);
                   (yyval.bases) = list;
               }
#line 13330 "CParse/parser.c"
    break;

  case 562: /* @14: %empty  */
#line 8307 "CParse/parser.y"
                                       {
		 (yyval.intvalue) = cparse_line;
	       }
#line 13338 "CParse/parser.c"
    break;

  case 563: /* base_specifier: opt_virtual @14 idcolon variadic_opt  */
#line 8309 "CParse/parser.y"
                                            {
		 (yyval.node) = NewHash();
		 Setfile((yyval.node), cparse_file);
		 Setline((yyval.node), (yyvsp[-2].intvalue));
		 Setattr((yyval.node), "name", (yyvsp[-1].str));
		 Setfile((yyvsp[-1].str), cparse_file);
		 Setline((yyvsp[-1].str), (yyvsp[-2].intvalue));
                 if (last_cpptype && (Strcmp(last_cpptype,"struct") != 0)) {
		   Setattr((yyval.node),"access","private");
		   Swig_warning(WARN_PARSE_NO_ACCESS, Getfile((yyval.node)), Getline((yyval.node)), "No access specifier given for base class '%s' (ignored).\n", SwigType_namestr((yyvsp[-1].str)));
                 } else {
		   Setattr((yyval.node),"access","public");
		 }
		 if ((yyvsp[0].intvalue)) {
		   SwigType_add_variadic(Getattr((yyval.node), "name"));
		 }
		 if (this_base_virtual) {     /* swig4ada */
		   Setattr((yyval.node), "virtual", "1");
		   this_base_virtual = 0;
		 }
               }
#line 13364 "CParse/parser.c"
    break;

  case 564: /* @15: %empty  */
#line 8330 "CParse/parser.y"
                                                        {
		 (yyval.intvalue) = cparse_line;
	       }
#line 13372 "CParse/parser.c"
    break;

  case 565: /* base_specifier: opt_virtual access_specifier @15 opt_virtual idcolon variadic_opt  */
#line 8332 "CParse/parser.y"
                                                        {
		 (yyval.node) = NewHash();
		 Setfile((yyval.node), cparse_file);
		 Setline((yyval.node), (yyvsp[-3].intvalue));
		 Setattr((yyval.node), "name", (yyvsp[-1].str));
		 Setfile((yyvsp[-1].str), cparse_file);
		 Setline((yyvsp[-1].str), (yyvsp[-3].intvalue));
		 Setattr((yyval.node), "access", (yyvsp[-4].id));
		 if (Strcmp((yyvsp[-4].id), "public") != 0) {
		   Swig_warning(WARN_PARSE_PRIVATE_INHERIT, Getfile((yyval.node)), Getline((yyval.node)), "%s inheritance from base '%s' (ignored).\n", (yyvsp[-4].id), SwigType_namestr((yyvsp[-1].str)));
		 }
		 if ((yyvsp[0].intvalue)) {
		   SwigType_add_variadic(Getattr((yyval.node), "name"));
		 }
		 if (this_base_virtual) {     /* swig4ada */
		   Setattr((yyval.node), "virtual", "1");
		   this_base_virtual = 0;
		 }
               }
#line 13396 "CParse/parser.c"
    break;

  case 566: /* access_specifier: PUBLIC  */
#line 8353 "CParse/parser.y"
                           { (yyval.id) = "public"; }
#line 13402 "CParse/parser.c"
    break;

  case 567: /* access_specifier: PRIVATE  */
#line 8354 "CParse/parser.y"
                         { (yyval.id) = "private"; }
#line 13408 "CParse/parser.c"
    break;

  case 568: /* access_specifier: PROTECTED  */
#line 8355 "CParse/parser.y"
                           { (yyval.id) = "protected"; }
#line 13414 "CParse/parser.c"
    break;

  case 569: /* templcpptype: CLASS variadic_opt  */
#line 8358 "CParse/parser.y"
                                    {
                   (yyval.type) = NewString("class");
		   if (!inherit_list) last_cpptype = (yyval.type);
		   if ((yyvsp[0].intvalue)) SwigType_add_variadic((yyval.type));
               }
#line 13424 "CParse/parser.c"
    break;

  case 570: /* templcpptype: TYPENAME variadic_opt  */
#line 8363 "CParse/parser.y"
                                       {
                   (yyval.type) = NewString("typename");
		   if (!inherit_list) last_cpptype = (yyval.type);
		   if ((yyvsp[0].intvalue)) SwigType_add_variadic((yyval.type));
               }
#line 13434 "CParse/parser.c"
    break;

  case 572: /* cpptype: STRUCT  */
#line 8371 "CParse/parser.y"
                        {
                   (yyval.type) = NewString("struct");
		   if (!inherit_list) last_cpptype = (yyval.type);
               }
#line 13443 "CParse/parser.c"
    break;

  case 573: /* cpptype: UNION  */
#line 8375 "CParse/parser.y"
                       {
                   (yyval.type) = NewString("union");
		   if (!inherit_list) last_cpptype = (yyval.type);
               }
#line 13452 "CParse/parser.c"
    break;

  case 574: /* classkey: CLASS  */
#line 8381 "CParse/parser.y"
                       {
		   if (!inherit_list) last_cpptype = NewString("class");
               }
#line 13460 "CParse/parser.c"
    break;

  case 575: /* classkey: STRUCT  */
#line 8384 "CParse/parser.y"
                        {
		   if (!inherit_list) last_cpptype = NewString("struct");
               }
#line 13468 "CParse/parser.c"
    break;

  case 576: /* classkey: UNION  */
#line 8387 "CParse/parser.y"
                       {
		   if (!inherit_list) last_cpptype = NewString("union");
               }
#line 13476 "CParse/parser.c"
    break;

  case 579: /* opt_virtual: VIRTUAL  */
#line 8396 "CParse/parser.y"
                         { virtual_base_seen = 1; this_base_virtual = 1; }
#line 13482 "CParse/parser.c"
    break;

  case 581: /* virt_specifier_seq: OVERRIDE  */
#line 8400 "CParse/parser.y"
                              {
                   (yyval.str) = 0;
	       }
#line 13490 "CParse/parser.c"
    break;

  case 582: /* virt_specifier_seq: FINAL  */
#line 8403 "CParse/parser.y"
                       {
                   (yyval.str) = NewString("1");
	       }
#line 13498 "CParse/parser.c"
    break;

  case 583: /* virt_specifier_seq: FINAL OVERRIDE  */
#line 8406 "CParse/parser.y"
                                {
                   (yyval.str) = NewString("1");
	       }
#line 13506 "CParse/parser.c"
    break;

  case 584: /* virt_specifier_seq: OVERRIDE FINAL  */
#line 8409 "CParse/parser.y"
                                {
                   (yyval.str) = NewString("1");
	       }
#line 13514 "CParse/parser.c"
    break;

  case 586: /* virt_specifier_seq_opt: %empty  */
#line 8415 "CParse/parser.y"
                        {
                   (yyval.str) = 0;
               }
#line 13522 "CParse/parser.c"
    break;

  case 587: /* requires_clause_opt: REQUIRES constraint  */
#line 8427 "CParse/parser.y"
                                          {
                   (yyval.node) = (yyvsp[0].node);
               }
#line 13530 "CParse/parser.c"
    break;

  case 588: /* requires_clause_opt: %empty  */
#line 8430 "CParse/parser.y"
                        {
                   (yyval.node) = 0;
               }
#line 13538 "CParse/parser.c"
    break;

  case 589: /* class_virt_specifier_opt: FINAL  */
#line 8435 "CParse/parser.y"
                                 {
                   (yyval.str) = NewString("1");
               }
#line 13546 "CParse/parser.c"
    break;

  case 590: /* class_virt_specifier_opt: %empty  */
#line 8438 "CParse/parser.y"
                        {
                   (yyval.str) = 0;
               }
#line 13554 "CParse/parser.c"
    break;

  case 591: /* exception_specification: THROW LPAREN parms RPAREN  */
#line 8443 "CParse/parser.y"
                                                    {
		    (yyval.dtype) = default_dtype;
                    (yyval.dtype).throws = (yyvsp[-1].pl);
                    (yyval.dtype).throwf = NewString("1");
	       }
#line 13564 "CParse/parser.c"
    break;

  case 592: /* exception_specification: NOEXCEPT  */
#line 8448 "CParse/parser.y"
                          {
		    (yyval.dtype) = default_dtype;
                    (yyval.dtype).nexcept = NewString("true");
	       }
#line 13573 "CParse/parser.c"
    break;

  case 593: /* exception_specification: virt_specifier_seq  */
#line 8452 "CParse/parser.y"
                                    {
		    (yyval.dtype) = default_dtype;
                    (yyval.dtype).final = (yyvsp[0].str);
	       }
#line 13582 "CParse/parser.c"
    break;

  case 594: /* exception_specification: THROW LPAREN parms RPAREN virt_specifier_seq  */
#line 8456 "CParse/parser.y"
                                                              {
		    (yyval.dtype) = default_dtype;
                    (yyval.dtype).throws = (yyvsp[-2].pl);
                    (yyval.dtype).throwf = NewString("1");
                    (yyval.dtype).final = (yyvsp[0].str);
	       }
#line 13593 "CParse/parser.c"
    break;

  case 595: /* exception_specification: NOEXCEPT virt_specifier_seq  */
#line 8462 "CParse/parser.y"
                                             {
		    (yyval.dtype) = default_dtype;
                    (yyval.dtype).nexcept = NewString("true");
		    (yyval.dtype).final = (yyvsp[0].str);
	       }
#line 13603 "CParse/parser.c"
    break;

  case 596: /* exception_specification: NOEXCEPT LPAREN expr RPAREN  */
#line 8467 "CParse/parser.y"
                                             {
		    (yyval.dtype) = default_dtype;
                    (yyval.dtype).nexcept = (yyvsp[-1].dtype).val;
	       }
#line 13612 "CParse/parser.c"
    break;

  case 597: /* qualifiers_exception_specification: cv_ref_qualifier  */
#line 8473 "CParse/parser.y"
                                                      {
		    (yyval.dtype) = default_dtype;
                    (yyval.dtype).qualifier = (yyvsp[0].dtype).qualifier;
                    (yyval.dtype).refqualifier = (yyvsp[0].dtype).refqualifier;
               }
#line 13622 "CParse/parser.c"
    break;

  case 598: /* qualifiers_exception_specification: exception_specification  */
#line 8478 "CParse/parser.y"
                                         {
		    (yyval.dtype) = (yyvsp[0].dtype);
               }
#line 13630 "CParse/parser.c"
    break;

  case 599: /* qualifiers_exception_specification: cv_ref_qualifier exception_specification  */
#line 8481 "CParse/parser.y"
                                                          {
		    (yyval.dtype) = (yyvsp[0].dtype);
                    (yyval.dtype).qualifier = (yyvsp[-1].dtype).qualifier;
                    (yyval.dtype).refqualifier = (yyvsp[-1].dtype).refqualifier;
               }
#line 13640 "CParse/parser.c"
    break;

  case 601: /* cpp_const: qualifiers_exception_specification REQUIRES constraint  */
#line 8489 "CParse/parser.y"
                                                                        {
                 (yyval.dtype) = (yyvsp[-2].dtype);
                 (yyval.dtype).constraint_node = (yyvsp[0].node);
               }
#line 13649 "CParse/parser.c"
    break;

  case 602: /* cpp_const: REQUIRES constraint  */
#line 8493 "CParse/parser.y"
                                     {
                 (yyval.dtype) = default_dtype;
                 (yyval.dtype).constraint_node = (yyvsp[0].node);
               }
#line 13658 "CParse/parser.c"
    break;

  case 603: /* cpp_const: %empty  */
#line 8497 "CParse/parser.y"
                        {
                 (yyval.dtype) = default_dtype;
               }
#line 13666 "CParse/parser.c"
    break;

  case 604: /* ctor_end: cpp_const ctor_initializer SEMI  */
#line 8502 "CParse/parser.y"
                                                 {
                    Clear(scanner_ccode);
		    (yyval.decl) = default_decl;
		    (yyval.decl).throws = (yyvsp[-2].dtype).throws;
		    (yyval.decl).throwf = (yyvsp[-2].dtype).throwf;
		    (yyval.decl).nexcept = (yyvsp[-2].dtype).nexcept;
		    (yyval.decl).final = (yyvsp[-2].dtype).final;
		    (yyval.decl).constraint_node = (yyvsp[-2].dtype).constraint_node;
                    if ((yyvsp[-2].dtype).qualifier)
                      Swig_error(cparse_file, cparse_line, "Constructor cannot have a qualifier.\n");
               }
#line 13682 "CParse/parser.c"
    break;

  case 605: /* ctor_end: cpp_const ctor_initializer LBRACE  */
#line 8513 "CParse/parser.y"
                                                   {
                    if ((yyvsp[-2].dtype).qualifier)
                      Swig_error(cparse_file, cparse_line, "Constructor cannot have a qualifier.\n");
                    if (skip_balanced('{','}') < 0) Exit(EXIT_FAILURE);
		    (yyval.decl) = default_decl;
                    (yyval.decl).throws = (yyvsp[-2].dtype).throws;
                    (yyval.decl).throwf = (yyvsp[-2].dtype).throwf;
                    (yyval.decl).nexcept = (yyvsp[-2].dtype).nexcept;
                    (yyval.decl).final = (yyvsp[-2].dtype).final;
		    (yyval.decl).constraint_node = (yyvsp[-2].dtype).constraint_node;
               }
#line 13698 "CParse/parser.c"
    break;

  case 606: /* ctor_end: LPAREN parms RPAREN SEMI  */
#line 8524 "CParse/parser.y"
                                          { 
                    Clear(scanner_ccode); 
		    (yyval.decl) = default_decl;
                    (yyval.decl).parms = (yyvsp[-2].pl); 
                    (yyval.decl).have_parms = 1; 
               }
#line 13709 "CParse/parser.c"
    break;

  case 607: /* ctor_end: LPAREN parms RPAREN LBRACE  */
#line 8530 "CParse/parser.y"
                                            {
                    if (skip_balanced('{','}') < 0) Exit(EXIT_FAILURE);
		    (yyval.decl) = default_decl;
                    (yyval.decl).parms = (yyvsp[-2].pl); 
                    (yyval.decl).have_parms = 1; 
               }
#line 13720 "CParse/parser.c"
    break;

  case 608: /* ctor_end: EQUAL definetype SEMI  */
#line 8536 "CParse/parser.y"
                                       { 
		    (yyval.decl) = default_decl;
                    (yyval.decl).defarg = (yyvsp[-1].dtype).val; 
		    (yyval.decl).stringdefarg = (yyvsp[-1].dtype).stringval;
		    (yyval.decl).numdefarg = (yyvsp[-1].dtype).numval;
               }
#line 13731 "CParse/parser.c"
    break;

  case 609: /* ctor_end: exception_specification EQUAL default_delete SEMI  */
#line 8542 "CParse/parser.y"
                                                                   {
		    (yyval.decl) = default_decl;
                    (yyval.decl).defarg = (yyvsp[-1].dtype).val;
		    (yyval.decl).stringdefarg = (yyvsp[-1].dtype).stringval;
		    (yyval.decl).numdefarg = (yyvsp[-1].dtype).numval;
                    (yyval.decl).throws = (yyvsp[-3].dtype).throws;
                    (yyval.decl).throwf = (yyvsp[-3].dtype).throwf;
                    (yyval.decl).nexcept = (yyvsp[-3].dtype).nexcept;
                    (yyval.decl).final = (yyvsp[-3].dtype).final;
                    if ((yyvsp[-3].dtype).qualifier)
                      Swig_error(cparse_file, cparse_line, "Constructor cannot have a qualifier.\n");
               }
#line 13748 "CParse/parser.c"
    break;

  case 616: /* mem_initializer: idcolon LPAREN  */
#line 8566 "CParse/parser.y"
                                 {
		  if (skip_balanced('(',')') < 0) Exit(EXIT_FAILURE);
		  Clear(scanner_ccode);
		}
#line 13757 "CParse/parser.c"
    break;

  case 617: /* mem_initializer: idcolon LBRACE  */
#line 8578 "CParse/parser.y"
                                 {
		  if (skip_balanced('{','}') < 0) Exit(EXIT_FAILURE);
		  Clear(scanner_ccode);
		}
#line 13766 "CParse/parser.c"
    break;

  case 618: /* less_valparms_greater: LESSTHAN valparms GREATERTHAN  */
#line 8584 "CParse/parser.y"
                                                      {
                     String *s = NewStringEmpty();
                     SwigType_add_template(s,(yyvsp[-1].p));
		     (yyval.str) = s;
		     scanner_last_id(1);
                }
#line 13777 "CParse/parser.c"
    break;

  case 620: /* identifier: OVERRIDE  */
#line 8594 "CParse/parser.y"
                          { (yyval.id) = Swig_copy_string("override"); }
#line 13783 "CParse/parser.c"
    break;

  case 621: /* identifier: FINAL  */
#line 8595 "CParse/parser.y"
                       { (yyval.id) = Swig_copy_string("final"); }
#line 13789 "CParse/parser.c"
    break;

  case 623: /* idstring: default_delete  */
#line 8599 "CParse/parser.y"
                                { (yyval.id) = Char((yyvsp[0].dtype).val); }
#line 13795 "CParse/parser.c"
    break;

  case 624: /* idstring: string  */
#line 8600 "CParse/parser.y"
                        { (yyval.id) = Char((yyvsp[0].str)); }
#line 13801 "CParse/parser.c"
    break;

  case 626: /* idstringopt: %empty  */
#line 8604 "CParse/parser.y"
                        { (yyval.id) = 0; }
#line 13807 "CParse/parser.c"
    break;

  case 627: /* idcolon: idtemplate idcolontail  */
#line 8607 "CParse/parser.y"
                                        { 
		 (yyval.str) = NewStringf("%s%s", (yyvsp[-1].str), (yyvsp[0].str));
		 Delete((yyvsp[0].str));
               }
#line 13816 "CParse/parser.c"
    break;

  case 628: /* idcolon: NONID DCOLON idtemplatetemplate idcolontail  */
#line 8611 "CParse/parser.y"
                                                             {
		 (yyval.str) = NewStringf("::%s%s",(yyvsp[-1].str),(yyvsp[0].str));
                 Delete((yyvsp[0].str));
               }
#line 13825 "CParse/parser.c"
    break;

  case 629: /* idcolon: idtemplate  */
#line 8615 "CParse/parser.y"
                            {
		 (yyval.str) = NewString((yyvsp[0].str));
   	       }
#line 13833 "CParse/parser.c"
    break;

  case 630: /* idcolon: NONID DCOLON idtemplatetemplate  */
#line 8618 "CParse/parser.y"
                                                 {
		 (yyval.str) = NewStringf("::%s",(yyvsp[0].str));
               }
#line 13841 "CParse/parser.c"
    break;

  case 631: /* idcolon: OPERATOR  */
#line 8621 "CParse/parser.y"
                                    {
		 (yyval.str) = (yyvsp[0].str);
	       }
#line 13849 "CParse/parser.c"
    break;

  case 632: /* idcolon: OPERATOR less_valparms_greater  */
#line 8624 "CParse/parser.y"
                                                {
		 (yyval.str) = (yyvsp[-1].str);
		 Append((yyval.str), (yyvsp[0].str));
		 Delete((yyvsp[0].str));
	       }
#line 13859 "CParse/parser.c"
    break;

  case 633: /* idcolon: NONID DCOLON OPERATOR  */
#line 8629 "CParse/parser.y"
                                       {
		 (yyval.str) = (yyvsp[0].str);
		 Insert((yyval.str), 0, "::");
               }
#line 13868 "CParse/parser.c"
    break;

  case 634: /* idcolontail: DCOLON idtemplatetemplate idcolontail  */
#line 8635 "CParse/parser.y"
                                                           {
                   (yyval.str) = NewStringf("::%s%s",(yyvsp[-1].str),(yyvsp[0].str));
		   Delete((yyvsp[0].str));
               }
#line 13877 "CParse/parser.c"
    break;

  case 635: /* idcolontail: DCOLON idtemplatetemplate  */
#line 8639 "CParse/parser.y"
                                           {
                   (yyval.str) = NewStringf("::%s",(yyvsp[0].str));
               }
#line 13885 "CParse/parser.c"
    break;

  case 636: /* idcolontail: DCOLON OPERATOR  */
#line 8642 "CParse/parser.y"
                                 {
		   (yyval.str) = (yyvsp[0].str);
		   Insert((yyval.str), 0, "::");
               }
#line 13894 "CParse/parser.c"
    break;

  case 637: /* idcolontail: DCNOT idtemplate  */
#line 8646 "CParse/parser.y"
                                  {
		 (yyval.str) = NewStringf("::~%s",(yyvsp[0].str));
               }
#line 13902 "CParse/parser.c"
    break;

  case 638: /* idtemplate: identifier  */
#line 8652 "CParse/parser.y"
                           {
		(yyval.str) = NewString((yyvsp[0].id));
	      }
#line 13910 "CParse/parser.c"
    break;

  case 639: /* idtemplate: identifier less_valparms_greater  */
#line 8655 "CParse/parser.y"
                                                 {
		(yyval.str) = NewString((yyvsp[-1].id));
		Append((yyval.str), (yyvsp[0].str));
		Delete((yyvsp[0].str));
	      }
#line 13920 "CParse/parser.c"
    break;

  case 641: /* idtemplatetemplate: TEMPLATE identifier less_valparms_greater  */
#line 8663 "CParse/parser.y"
                                                          {
		(yyval.str) = NewString((yyvsp[-1].id));
		Append((yyval.str), (yyvsp[0].str));
		Delete((yyvsp[0].str));
	      }
#line 13930 "CParse/parser.c"
    break;

  case 642: /* idcolonnt: identifier idcolontailnt  */
#line 8671 "CParse/parser.y"
                                         {
		 (yyval.str) = NewStringf("%s%s", (yyvsp[-1].id), (yyvsp[0].str));
		 Delete((yyvsp[0].str));
               }
#line 13939 "CParse/parser.c"
    break;

  case 643: /* idcolonnt: NONID DCOLON identifier idcolontailnt  */
#line 8675 "CParse/parser.y"
                                                       {
		 (yyval.str) = NewStringf("::%s%s",(yyvsp[-1].id),(yyvsp[0].str));
                 Delete((yyvsp[0].str));
               }
#line 13948 "CParse/parser.c"
    break;

  case 644: /* idcolonnt: identifier  */
#line 8679 "CParse/parser.y"
                            {
		 (yyval.str) = NewString((yyvsp[0].id));
   	       }
#line 13956 "CParse/parser.c"
    break;

  case 645: /* idcolonnt: NONID DCOLON identifier  */
#line 8682 "CParse/parser.y"
                                         {
		 (yyval.str) = NewStringf("::%s",(yyvsp[0].id));
               }
#line 13964 "CParse/parser.c"
    break;

  case 646: /* idcolonnt: OPERATOR  */
#line 8685 "CParse/parser.y"
                          {
		 (yyval.str) = (yyvsp[0].str);
	       }
#line 13972 "CParse/parser.c"
    break;

  case 647: /* idcolonnt: NONID DCOLON OPERATOR  */
#line 8688 "CParse/parser.y"
                                       {
		 (yyval.str) = (yyvsp[0].str);
		 Insert((yyval.str), 0, "::");
               }
#line 13981 "CParse/parser.c"
    break;

  case 648: /* idcolontailnt: DCOLON identifier idcolontailnt  */
#line 8694 "CParse/parser.y"
                                                      {
                   (yyval.str) = NewStringf("::%s%s",(yyvsp[-1].id),(yyvsp[0].str));
		   Delete((yyvsp[0].str));
               }
#line 13990 "CParse/parser.c"
    break;

  case 649: /* idcolontailnt: DCOLON identifier  */
#line 8698 "CParse/parser.y"
                                   {
                   (yyval.str) = NewStringf("::%s",(yyvsp[0].id));
               }
#line 13998 "CParse/parser.c"
    break;

  case 650: /* idcolontailnt: DCOLON OPERATOR  */
#line 8701 "CParse/parser.y"
                                 {
		   (yyval.str) = (yyvsp[0].str);
		   Insert((yyval.str), 0, "::");
               }
#line 14007 "CParse/parser.c"
    break;

  case 651: /* idcolontailnt: DCNOT identifier  */
#line 8705 "CParse/parser.y"
                                  {
		 (yyval.str) = NewStringf("::~%s",(yyvsp[0].id));
               }
#line 14015 "CParse/parser.c"
    break;

  case 652: /* string: string STRING  */
#line 8711 "CParse/parser.y"
                                   { 
		   (yyval.str) = (yyvsp[-1].str);
		   Append((yyval.str), (yyvsp[0].str));
		   Delete((yyvsp[0].str));
	       }
#line 14025 "CParse/parser.c"
    break;

  case 654: /* wstring: wstring WSTRING  */
#line 8718 "CParse/parser.y"
                                     {
		   // Concatenated wide strings: L"str1" L"str2"
		   (yyval.str) = (yyvsp[-1].str);
		   Append((yyval.str), (yyvsp[0].str));
		   Delete((yyvsp[0].str));
	       }
#line 14036 "CParse/parser.c"
    break;

  case 655: /* wstring: wstring STRING  */
#line 8724 "CParse/parser.y"
                                    {
		   // Concatenated wide string and normal string literal: L"str1" "str2" (C++11).
		   (yyval.str) = (yyvsp[-1].str);
		   Append((yyval.str), (yyvsp[0].str));
		   Delete((yyvsp[0].str));
	       }
#line 14047 "CParse/parser.c"
    break;

  case 656: /* wstring: string WSTRING  */
#line 8730 "CParse/parser.y"
                                    {
		   // Concatenated normal string and wide string literal: "str1" L"str2" (C++11).
		   (yyval.str) = (yyvsp[-1].str);
		   Append((yyval.str), (yyvsp[0].str));
		   Delete((yyvsp[0].str));
	       }
#line 14058 "CParse/parser.c"
    break;

  case 659: /* stringbrace: LBRACE  */
#line 8740 "CParse/parser.y"
                        {
		  if (skip_balanced('{','}') < 0) Exit(EXIT_FAILURE);
		  (yyval.str) = NewString(scanner_ccode);
               }
#line 14067 "CParse/parser.c"
    break;

  case 661: /* options: LPAREN kwargs RPAREN  */
#line 8747 "CParse/parser.y"
                                      {
                  Hash *n;
                  (yyval.node) = NewHash();
                  n = (yyvsp[-1].node);
                  while(n) {
                     String *name, *value;
                     name = Getattr(n,"name");
                     value = Getattr(n,"value");
		     if (!value) value = (String *) "1";
                     Setattr((yyval.node),name, value);
		     n = nextSibling(n);
		  }
               }
#line 14085 "CParse/parser.c"
    break;

  case 662: /* options: %empty  */
#line 8760 "CParse/parser.y"
                        { (yyval.node) = 0; }
#line 14091 "CParse/parser.c"
    break;

  case 663: /* kwargs: kwargs_builder  */
#line 8764 "CParse/parser.y"
                                {
		 (yyval.node) = (yyvsp[0].nodebuilder).node;
	       }
#line 14099 "CParse/parser.c"
    break;

  case 664: /* kwargs_builder: idstring EQUAL stringnum  */
#line 8769 "CParse/parser.y"
                                          {
		 Node *n = NewHash();
		 Setattr(n, "name", (yyvsp[-2].id));
		 Setattr(n, "value", (yyvsp[0].str));
		 Delete((yyvsp[0].str));
		 (yyval.nodebuilder).node = (yyval.nodebuilder).last = n;
	       }
#line 14111 "CParse/parser.c"
    break;

  case 665: /* kwargs_builder: kwargs_builder COMMA idstring EQUAL stringnum  */
#line 8776 "CParse/parser.y"
                                                                   {
		 (yyval.nodebuilder) = (yyvsp[-4].nodebuilder);
		 Node *n = NewHash();
		 Setattr(n, "name", (yyvsp[-2].id));
		 Setattr(n, "value", (yyvsp[0].str));
		 Delete((yyvsp[0].str));
		 set_nextSibling((yyval.nodebuilder).last, n);
		 (yyval.nodebuilder).last = n;
	       }
#line 14125 "CParse/parser.c"
    break;

  case 666: /* kwargs_builder: idstring  */
#line 8785 "CParse/parser.y"
                          {
		 Node *n = NewHash();
		 Setattr(n, "name", (yyvsp[0].id));
		 (yyval.nodebuilder).node = (yyval.nodebuilder).last = n;
	       }
#line 14135 "CParse/parser.c"
    break;

  case 667: /* kwargs_builder: kwargs_builder COMMA idstring  */
#line 8790 "CParse/parser.y"
                                                   {
		 (yyval.nodebuilder) = (yyvsp[-2].nodebuilder);
		 Node *n = NewHash();
		 Setattr(n, "name", (yyvsp[0].id));
		 set_nextSibling((yyval.nodebuilder).last, n);
		 (yyval.nodebuilder).last = n;
	       }
#line 14147 "CParse/parser.c"
    break;

  case 668: /* kwargs_builder: idstring EQUAL stringtype  */
#line 8797 "CParse/parser.y"
                                           {
		 Node *n = (yyvsp[0].node);
		 Setattr(n, "name", (yyvsp[-2].id));
		 (yyval.nodebuilder).node = (yyval.nodebuilder).last = n;
	       }
#line 14157 "CParse/parser.c"
    break;

  case 669: /* kwargs_builder: kwargs_builder COMMA idstring EQUAL stringtype  */
#line 8802 "CParse/parser.y"
                                                                    {
		 (yyval.nodebuilder) = (yyvsp[-4].nodebuilder);
		 Node *n = (yyvsp[0].node);
		 Setattr(n, "name", (yyvsp[-2].id));
		 set_nextSibling((yyval.nodebuilder).last, n);
		 (yyval.nodebuilder).last = n;
	       }
#line 14169 "CParse/parser.c"
    break;

  case 671: /* stringnum: exprnum  */
#line 8812 "CParse/parser.y"
                         {
		 (yyval.str) = (yyvsp[0].dtype).val;
               }
#line 14177 "CParse/parser.c"
    break;


#line 14181 "CParse/parser.c"

      default: break;
    }
  /* User semantic actions sometimes alter yychar, and that requires
     that yytoken be updated with the new translation.  We take the
     approach of translating immediately before every use of yytoken.
     One alternative is translating here after every semantic action,
     but that translation would be missed if the semantic action invokes
     YYABORT, YYACCEPT, or YYERROR immediately after altering yychar or
     if it invokes YYBACKUP.  In the case of YYABORT or YYACCEPT, an
     incorrect destructor might then be invoked immediately.  In the
     case of YYERROR or YYBACKUP, subsequent parser actions might lead
     to an incorrect destructor call or verbose syntax error message
     before the lookahead is translated.  */
  YY_SYMBOL_PRINT ("-> $$ =", YY_CAST (yysymbol_kind_t, yyr1[yyn]), &yyval, &yyloc);

  YYPOPSTACK (yylen);
  yylen = 0;

  *++yyvsp = yyval;

  /* Now 'shift' the result of the reduction.  Determine what state
     that goes to, based on the state we popped back to and the rule
     number reduced by.  */
  {
    const int yylhs = yyr1[yyn] - YYNTOKENS;
    const int yyi = yypgoto[yylhs] + *yyssp;
    yystate = (0 <= yyi && yyi <= YYLAST && yycheck[yyi] == *yyssp
               ? yytable[yyi]
               : yydefgoto[yylhs]);
  }

  goto yynewstate;


/*--------------------------------------.
| yyerrlab -- here on detecting error.  |
`--------------------------------------*/
yyerrlab:
  /* Make sure we have latest lookahead translation.  See comments at
     user semantic actions for why this is necessary.  */
  yytoken = yychar == YYEMPTY ? YYSYMBOL_YYEMPTY : YYTRANSLATE (yychar);
  /* If not already recovering from an error, report this error.  */
  if (!yyerrstatus)
    {
      ++yynerrs;
      yyerror (YY_("syntax error"));
    }

  if (yyerrstatus == 3)
    {
      /* If just tried and failed to reuse lookahead token after an
         error, discard it.  */

      if (yychar <= END)
        {
          /* Return failure if at end of input.  */
          if (yychar == END)
            YYABORT;
        }
      else
        {
          yydestruct ("Error: discarding",
                      yytoken, &yylval);
          yychar = YYEMPTY;
        }
    }

  /* Else will try to reuse lookahead token after shifting the error
     token.  */
  goto yyerrlab1;


/*---------------------------------------------------.
| yyerrorlab -- error raised explicitly by YYERROR.  |
`---------------------------------------------------*/
yyerrorlab:
  /* Pacify compilers when the user code never invokes YYERROR and the
     label yyerrorlab therefore never appears in user code.  */
  if (0)
    YYERROR;
  ++yynerrs;

  /* Do not reclaim the symbols of the rule whose action triggered
     this YYERROR.  */
  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);
  yystate = *yyssp;
  goto yyerrlab1;


/*-------------------------------------------------------------.
| yyerrlab1 -- common code for both syntax error and YYERROR.  |
`-------------------------------------------------------------*/
yyerrlab1:
  yyerrstatus = 3;      /* Each real token shifted decrements this.  */

  /* Pop stack until we find a state that shifts the error token.  */
  for (;;)
    {
      yyn = yypact[yystate];
      if (!yypact_value_is_default (yyn))
        {
          yyn += YYSYMBOL_YYerror;
          if (0 <= yyn && yyn <= YYLAST && yycheck[yyn] == YYSYMBOL_YYerror)
            {
              yyn = yytable[yyn];
              if (0 < yyn)
                break;
            }
        }

      /* Pop the current state because it cannot handle the error token.  */
      if (yyssp == yyss)
        YYABORT;


      yydestruct ("Error: popping",
                  YY_ACCESSING_SYMBOL (yystate), yyvsp);
      YYPOPSTACK (1);
      yystate = *yyssp;
      YY_STACK_PRINT (yyss, yyssp);
    }

  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  *++yyvsp = yylval;
  YY_IGNORE_MAYBE_UNINITIALIZED_END


  /* Shift the error token.  */
  YY_SYMBOL_PRINT ("Shifting", YY_ACCESSING_SYMBOL (yyn), yyvsp, yylsp);

  yystate = yyn;
  goto yynewstate;


/*-------------------------------------.
| yyacceptlab -- YYACCEPT comes here.  |
`-------------------------------------*/
yyacceptlab:
  yyresult = 0;
  goto yyreturnlab;


/*-----------------------------------.
| yyabortlab -- YYABORT comes here.  |
`-----------------------------------*/
yyabortlab:
  yyresult = 1;
  goto yyreturnlab;


/*-----------------------------------------------------------.
| yyexhaustedlab -- YYNOMEM (memory exhaustion) comes here.  |
`-----------------------------------------------------------*/
yyexhaustedlab:
  yyerror (YY_("memory exhausted"));
  yyresult = 2;
  goto yyreturnlab;


/*----------------------------------------------------------.
| yyreturnlab -- parsing is finished, clean up and return.  |
`----------------------------------------------------------*/
yyreturnlab:
  if (yychar != YYEMPTY)
    {
      /* Make sure we have latest lookahead translation.  See comments at
         user semantic actions for why this is necessary.  */
      yytoken = YYTRANSLATE (yychar);
      yydestruct ("Cleanup: discarding lookahead",
                  yytoken, &yylval);
    }
  /* Do not reclaim the symbols of the rule whose action triggered
     this YYABORT or YYACCEPT.  */
  YYPOPSTACK (yylen);
  YY_STACK_PRINT (yyss, yyssp);
  while (yyssp != yyss)
    {
      yydestruct ("Cleanup: popping",
                  YY_ACCESSING_SYMBOL (+*yyssp), yyvsp);
      YYPOPSTACK (1);
    }
#ifndef yyoverflow
  if (yyss != yyssa)
    YYSTACK_FREE (yyss);
#endif

  return yyresult;
}

#line 8817 "CParse/parser.y"


SwigType *Swig_cparse_type(String *s) {
   String *ns;
   ns = NewString(s);
   Seek(ns,0,SEEK_SET);
   scanner_file(ns);
   top = 0;
   scanner_next_token(PARSETYPE);
   if (yyparse() == 2) {
      Swig_error(cparse_file, cparse_line, "Parser exceeded stack depth or ran out of memory\n");
      Exit(EXIT_FAILURE);
   }
   /*   Printf(stdout,"typeparse: '%s' ---> '%s'\n", s, top); */
   return (SwigType *)top;
}


Parm *Swig_cparse_parm(String *s) {
   String *ns;
   ns = NewString(s);
   Seek(ns,0,SEEK_SET);
   scanner_file(ns);
   top = 0;
   scanner_next_token(PARSEPARM);
   if (yyparse() == 2) {
      Swig_error(cparse_file, cparse_line, "Parser exceeded stack depth or ran out of memory\n");
      Exit(EXIT_FAILURE);
   }
   /*   Printf(stdout,"parmparse: '%s' ---> '%s'\n", s, top); */
   Delete(ns);
   return (Parm *)top;
}


ParmList *Swig_cparse_parms(String *s, Node *file_line_node) {
   String *ns;
   char *cs = Char(s);
   if (cs && cs[0] != '(') {
     ns = NewStringf("(%s)",s);
   } else {
     ns = NewString(s);
   }
   Setfile(ns, Getfile(file_line_node));
   Setline(ns, Getline(file_line_node));
   Seek(ns,0,SEEK_SET);
   scanner_file(ns);
   top = 0;
   scanner_next_token(PARSEPARMS);
   if (yyparse() == 2) {
      Swig_error(cparse_file, cparse_line, "Parser exceeded stack depth or ran out of memory\n");
      Exit(EXIT_FAILURE);
   }
   /*   Printf(stdout,"parmsparse: '%s' ---> '%s'\n", s, top); */
   return (ParmList *)top;
}

