/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * main.cxx
 *
 * Main entry point to the SWIG core.
 * ----------------------------------------------------------------------------- */

char cvsroot_main_cxx[] = "$Id: main.cxx 10413 2008-05-03 11:38:48Z wsfulton $";

#include "swigconfig.h"

#if defined(_WIN32)
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#endif

#include "swigmod.h"

#include "swigwarn.h"
#include "cparse.h"
#include <ctype.h>
#include <limits.h>		// for INT_MAX

// Global variables

Language *lang;			// Language method
int CPlusPlus = 0;
int Extend = 0;			// Extend flag
int ForceExtern = 0;		// Force extern mode
int GenerateDefault = 1;	// Generate default constructors
int Verbose = 0;
int AddExtern = 0;
int NoExcept = 0;
int SwigRuntime = 0;		// 0 = no option, 1 = -c or -runtime, 2 = -noruntime

/* Suppress warning messages for private inheritance, preprocessor evaluation etc...
   WARN_PP_EVALUATION            202
   WARN_PARSE_PRIVATE_INHERIT    309
   WARN_TYPE_ABSTRACT            403
   WARN_LANG_OVERLOAD_CONST      512
   WARN_PARSE_BUILTIN_NAME       321
   WARN_PARSE_REDUNDANT          322
 */
#define EXTRA_WARNINGS "202,309,403,512,321,322"

extern "C" {
  extern String *ModuleName;
}

/* usage string split into multiple parts otherwise string is too big for some compilers */
/* naming conventions for commandline options - no underscores, no capital letters, join words together
 * except when using a common prefix, then use '-' to separate, eg the debug-xxx options */
static const char *usage1 = (const char *) "\
\nGeneral Options\n\
     -addextern      - Add extra extern declarations\n\
     -c++            - Enable C++ processing\n\
     -co <file>      - Check <file> out of the SWIG library\n\
     -copyctor       - Automatically generate copy constructors wherever possible\n\
     -cpperraswarn   - Treat the preprocessor #error statement as #warning (default)\n\
     -copyright      - Display copyright notices\n\
     -debug-classes  - Display information about the classes found in the interface\n\
     -debug-module <n>- Display module parse tree at stages 1-4, <n> is a csv list of stages\n\
     -debug-tags     - Display information about the tags found in the interface\n\
     -debug-template - Display information for debugging templates\n\
     -debug-top <n>  - Display entire parse tree at stages 1-4, <n> is a csv list of stages\n\
     -debug-typedef  - Display information about the types and typedefs in the interface\n\
     -debug-typemap  - Display information for debugging typemaps\n\
     -directors      - Turn on director mode for all the classes, mainly for testing\n\
     -dirprot        - Turn on wrapping of protected members for director classes (default)\n\
     -D<symbol>      - Define a symbol <symbol> (for conditional compilation)\n\
     -E              - Preprocess only, does not generate wrapper code\n\
     -external-runtime [file] - Export the SWIG runtime stack\n\
     -fakeversion <v>- Make SWIG fake the program version number to <v>\n\
     -fcompact       - Compile in compact mode\n\
     -features <list>- Set global features, where <list> is a comma separated list of\n\
                       features, eg -features directors,autodoc=1\n\
                       If no explicit value is given to the feature, a default of 1 is used\n\
";

static const char *usage2 = (const char *) "\
     -fastdispatch   - Enable fast dispatch mode to produce faster overload dispatcher code\n\
     -Fmicrosoft     - Display error/warning messages in Microsoft format\n\
     -Fstandard      - Display error/warning messages in commonly used format\n\
     -fvirtual       - Compile in virtual elimination mode\n\
     -help           - This output\n\
     -I-             - Don't search the current directory\n\
     -I<dir>         - Look for SWIG files in directory <dir>\n\
     -ignoremissing  - Ignore missing include files\n\
     -importall      - Follow all #include statements as imports\n\
     -includeall     - Follow all #include statements\n\
     -l<ifile>       - Include SWIG library file <ifile>\n\
     -macroerrors    - Report errors inside macros\n\
     -makedefault    - Create default constructors/destructors (the default)\n\
     -M              - List all dependencies\n\
     -MD             - Is equivalent to `-M -MF <file>', except `-E' is not implied\n\
     -MF <file>      - Generate dependencies into <file> and continue generating wrappers\n\
     -MM             - List dependencies, but omit files in SWIG library\n\
     -MMD            - Like `-MD', but omit files in SWIG library\n\
     -module <name>  - Set module name to <name>\n\
     -MT <target>    - Set the target of the rule emitted by dependency generation\n\
     -nocontract     - Turn off contract checking\n\
     -nocpperraswarn - Do not treat the preprocessor #error statement as #warning\n\
     -nodefault      - Do not generate default constructors nor default destructors\n\
     -nodefaultctor  - Do not generate implicit default constructors\n\
     -nodefaultdtor  - Do not generate implicit default destructors\n\
     -nodirprot      - Do not wrap director protected members\n\
     -noexcept       - Do not wrap exception specifiers\n\
     -nofastdispatch - Disable fast dispatch mode (default)\n\
     -nopreprocess   - Skip the preprocessor step\n\
";

static const char *usage3 = (const char *) "\
     -notemplatereduce - Disable reduction of the typedefs in templates\n\
     -O              - Enable the optimization options: \n\
                        -fastdispatch -fvirtual \n\
     -o <outfile>    - Set name of the output file to <outfile>\n\
     -oh <headfile>  - Set name of the output header file to <headfile>\n\
     -outdir <dir>   - Set language specific files output directory <dir>\n\
     -small          - Compile in virtual elimination & compact mode\n\
     -swiglib        - Report location of SWIG library and exit\n\
     -templatereduce - Reduce all the typedefs in templates\n\
     -v              - Run in verbose mode\n\
     -version        - Display SWIG version number\n\
     -Wall           - Remove all warning suppression, also implies -Wextra\n\
     -Wallkw         - Enable keyword warnings for all the supported languages\n\
     -Werror         - Treat warnings as errors\n\
     -Wextra         - Adds the following additional warnings: " EXTRA_WARNINGS "\n\
     -w<list>        - Suppress/add warning messages, eg -w401,+321 - see Warnings.html\n\
     -xmlout <file>  - Write XML version of the parse tree to <file> after normal processing\n\
\n\
Options can also be defined using the SWIG_FEATURES environment variable, for example:\n\
\n\
  $ SWIG_FEATURES=\"-Wall\"\n\
  $ export SWIG_FEATURES\n\
  $ swig -python interface.i\n\
\n\
is equivalent to: \n\
\n\
  $ swig -Wall -python interface.i \n\
\n\
\n";

// Local variables
static String *LangSubDir = 0;	// Target language library subdirectory
static char *SwigLib = 0;	// Library directory
static String *SwigLibWin = 0;	// Extra Library directory for Windows
static int freeze = 0;
static String *lang_config = 0;
static char *hpp_extension = (char *) "h";
static char *cpp_extension = (char *) "cxx";
static char *depends_extension = (char *) "d";
static String *outdir = 0;
static String *xmlout = 0;
static int help = 0;
static int checkout = 0;
static int cpp_only = 0;
static int no_cpp = 0;
static char *outfile_name = 0;
static char *outfile_name_h = 0;
static int tm_debug = 0;
static int dump_tags = 0;
static int dump_module = 0;
static int dump_top = 0;
static int dump_xml = 0;
static int browse = 0;
static int dump_typedef = 0;
static int dump_classes = 0;
static int werror = 0;
static int depend = 0;
static int depend_only = 0;
static int memory_debug = 0;
static int allkw = 0;
static DOH *libfiles = 0;
static DOH *cpps = 0;
static String *dependencies_file = 0;
static File *f_dependencies_file = 0;
static String *dependencies_target = 0;
static int external_runtime = 0;
static String *external_runtime_name = 0;
enum { STAGE1=1, STAGE2=2, STAGE3=4, STAGE4=8, STAGEOVERFLOW=16 };

// -----------------------------------------------------------------------------
// check_suffix(char *name)
//
// Checks the suffix of a file to see if we should emit extern declarations.
// -----------------------------------------------------------------------------

static int check_suffix(const char *name) {
  const char *c;
  if (!name)
    return 0;
  c = Swig_file_suffix(name);
  if ((strcmp(c, ".c") == 0) ||
      (strcmp(c, ".C") == 0) || (strcmp(c, ".cc") == 0) || (strcmp(c, ".cxx") == 0) || (strcmp(c, ".c++") == 0) || (strcmp(c, ".cpp") == 0)) {
    return 1;
  }
  return 0;
}

// -----------------------------------------------------------------------------
// install_opts(int argc, char *argv[])
// Install all command line options as preprocessor symbols
// ----------------------------------------------------------------------------- 

static void install_opts(int argc, char *argv[]) {
  int i;
  int noopt = 0;
  char *c;
  for (i = 1; i < (argc - 1); i++) {
    if (argv[i]) {
      if ((*argv[i] == '-') && (!isupper(*(argv[i] + 1)))) {
	String *opt = NewStringf("SWIGOPT%(upper)s", argv[i]);
	Replaceall(opt, "-", "_");
	c = Char(opt);
	noopt = 0;
	while (*c) {
	  if (!(isalnum(*c) || (*c == '_'))) {
	    noopt = 1;
	    break;
	  }
	  c++;
	}
	if (((i + 1) < (argc - 1)) && (argv[i + 1]) && (*argv[i + 1] != '-')) {
	  Printf(opt, " %s", argv[i + 1]);
	  i++;
	} else {
	  Printf(opt, " 1");
	}
	if (!noopt) {
	  /*      Printf(stdout,"%s\n", opt); */
	  Preprocessor_define(opt, 0);
	}
	Delete(opt);
      }
    }
  }
}

// -----------------------------------------------------------------------------
// decode_numbers_list(String *numlist)
// Decode comma separated list into a binary number of the inputs or'd together
// eg list="1,4" will return (2^0 || 2^3) = 0x1001
// ----------------------------------------------------------------------------- 

static unsigned int decode_numbers_list(String *numlist) {
  unsigned int decoded_number = 0;
  if (numlist) {
    List *numbers = Split(numlist, ',', INT_MAX);
    if (numbers && Len(numbers) > 0) {
      for (Iterator it = First(numbers); it.item; it = Next(it)) {
        String *numstring = it.item;
        // TODO: check that it is a number
        int number = atoi(Char(numstring));
        if (number > 0 && number <= 16) {
          decoded_number |= (1 << (number-1));
        }
      }
    }
  }
  return decoded_number;
}

// -----------------------------------------------------------------------------
// Sets the output directory for language specific (proxy) files if not set and 
// adds trailing file separator if necessary.
// ----------------------------------------------------------------------------- 

static void set_outdir(const String *c_wrapper_file_dir) {

  // Add file delimiter if not present in output directory name
  if (outdir && Len(outdir) != 0) {
    const char *outd = Char(outdir);
    if (strcmp(outd + strlen(outd) - strlen(SWIG_FILE_DELIMITER), SWIG_FILE_DELIMITER) != 0)
      Printv(outdir, SWIG_FILE_DELIMITER, NIL);
  }
  // Use the C wrapper file's directory if the output directory has not been set by user
  if (!outdir)
    outdir = NewString(c_wrapper_file_dir);
}

/* This function sets the name of the configuration file */
void SWIG_config_file(const String_or_char *filename) {
  lang_config = NewString(filename);
}

/* Sets the target language subdirectory name */
void SWIG_library_directory(const char *subdirectory) {
  LangSubDir = NewString(subdirectory);
}

// Returns the directory for generating language specific files (non C/C++ files)
const String *SWIG_output_directory() {
  assert(outdir);
  return outdir;
}

void SWIG_config_cppext(const char *ext) {
  cpp_extension = (char *) ext;
}

void SWIG_setfeature(const char *cfeature, const char *cvalue) {
  Hash *features_hash = Swig_cparse_features();
  String *name = NewString("");
  String *fname = NewString(cfeature);
  String *fvalue = NewString(cvalue);
  Swig_feature_set(features_hash, name, 0, fname, fvalue, 0);
  Delete(name);
  Delete(fname);
  Delete(fvalue);
}


void SWIG_setfeatures(const char *c) {
  char feature[64];
  char *fb = feature;
  char *fe = fb + 63;
  Hash *features_hash = Swig_cparse_features();
  String *name = NewString("");
  /* Printf(stderr,"all features %s\n", c); */
  while (*c) {
    char *f = fb;
    String *fname = NewString("feature:");
    String *fvalue = NewString("");
    while ((f != fe) && *c != '=' && *c != ',' && *c) {
      *(f++) = *(c++);
    }
    *f = 0;
    Printf(fname, "%s", feature);
    if (*c && *(c++) == '=') {
      char value[64];
      char *v = value;
      char *ve = v + 63;
      while ((v != ve) && *c != ',' && *c && !isspace(*c)) {
	*(v++) = *(c++);
      }
      *v = 0;
      Printf(fvalue, "%s", value);
    } else {
      Printf(fvalue, "1");
    }
    /* Printf(stderr,"%s %s\n", fname, fvalue);  */
    Swig_feature_set(features_hash, name, 0, fname, fvalue, 0);
    Delete(fname);
    Delete(fvalue);
  }
  Delete(name);
}

/* This function handles the -external-runtime command option */
static void SWIG_dump_runtime() {
  String *outfile;
  File *runtime;
  String *s;

  outfile = external_runtime_name;
  if (!outfile) {
    outfile = lang->defaultExternalRuntimeFilename();
    if (!outfile) {
      Printf(stderr, "*** Please provide a filename for the external runtime\n");
      SWIG_exit(EXIT_FAILURE);
    }
  }

  runtime = NewFile(outfile, "w");
  if (!runtime) {
    FileErrorDisplay(outfile);
    SWIG_exit(EXIT_FAILURE);
  }

  Swig_banner(runtime);

  s = Swig_include_sys("swiglabels.swg");
  if (!s) {
    Printf(stderr, "*** Unable to open 'swiglabels.swg'\n");
    Close(runtime);
    SWIG_exit(EXIT_FAILURE);
  }
  Printf(runtime, "%s", s);
  Delete(s);

  s = Swig_include_sys("swigerrors.swg");
  if (!s) {
    Printf(stderr, "*** Unable to open 'swigerrors.swg'\n");
    Close(runtime);
    SWIG_exit(EXIT_FAILURE);
  }
  Printf(runtime, "%s", s);
  Delete(s);

  s = Swig_include_sys("swigerrors.swg");
  if (!s) {
    Printf(stderr, "*** Unable to open 'swigerrors.swg'\n");
    Close(runtime);
    SWIG_exit(EXIT_FAILURE);
  }
  Printf(runtime, "%s", s);
  s = Swig_include_sys("swigrun.swg");
  if (!s) {
    Printf(stderr, "*** Unable to open 'swigrun.swg'\n");
    Close(runtime);
    SWIG_exit(EXIT_FAILURE);
  }
  Printf(runtime, "%s", s);
  Delete(s);

  s = lang->runtimeCode();
  Printf(runtime, "%s", s);
  Delete(s);

  s = Swig_include_sys("runtime.swg");
  if (!s) {
    Printf(stderr, "*** Unable to open 'runtime.swg'\n");
    Close(runtime);
    SWIG_exit(EXIT_FAILURE);
  }
  Printf(runtime, "%s", s);
  Delete(s);

  Close(runtime);
  Delete(runtime);
  SWIG_exit(EXIT_SUCCESS);
}

void SWIG_getoptions(int argc, char *argv[]) {
  int i;
  // Get options
  for (i = 1; i < argc; i++) {
    if (argv[i] && !Swig_check_marked(i)) {
      if (strncmp(argv[i], "-I-", 3) == 0) {
	// Don't push/pop directories
	Swig_set_push_dir(0);
	Swig_mark_arg(i);
      } else if (strncmp(argv[i], "-I", 2) == 0) {
	// Add a new directory search path
	char *a = Swig_copy_string(argv[i] + 2);
	Swig_add_directory((DOH *) a);
	free(a);
	Swig_mark_arg(i);
      } else if (strncmp(argv[i], "-D", 2) == 0) {
	String *d = NewString(argv[i] + 2);
	Replace(d, (char *) "=", (char *) " ", DOH_REPLACE_ANY | DOH_REPLACE_FIRST);
	Preprocessor_define((DOH *) d, 0);
	Delete(d);
	// Create a symbol
	Swig_mark_arg(i);
      } else if (strcmp(argv[i], "-E") == 0) {
	cpp_only = 1;
	Swig_mark_arg(i);
      } else if (strcmp(argv[i], "-nopreprocess") == 0) {
	no_cpp = 1;
	Swig_mark_arg(i);
      } else if ((strcmp(argv[i], "-verbose") == 0) || (strcmp(argv[i], "-v") == 0)) {
	Verbose = 1;
	Swig_mark_arg(i);
      } else if (strcmp(argv[i], "-c++") == 0) {
	CPlusPlus = 1;
	Preprocessor_define((DOH *) "__cplusplus __cplusplus", 0);
	Swig_cparse_cplusplus(1);
	Swig_mark_arg(i);
      } else if (strcmp(argv[i], "-fcompact") == 0) {
	Wrapper_compact_print_mode_set(1);
	Swig_mark_arg(i);
      } else if (strcmp(argv[i], "-fvirtual") == 0) {
	Wrapper_virtual_elimination_mode_set(1);
	Swig_mark_arg(i);
      } else if (strcmp(argv[i], "-fastdispatch") == 0) {
	Wrapper_fast_dispatch_mode_set(1);
	Swig_mark_arg(i);
      } else if (strcmp(argv[i], "-nofastdispatch") == 0) {
	Wrapper_fast_dispatch_mode_set(0);
	Swig_mark_arg(i);
      } else if (strcmp(argv[i], "-naturalvar") == 0) {
	Wrapper_naturalvar_mode_set(1);
	Swig_mark_arg(i);
      } else if (strcmp(argv[i], "-nonaturalvar") == 0) {
	Wrapper_naturalvar_mode_set(0);
	Swig_mark_arg(i);
      } else if (strcmp(argv[i], "-directors") == 0) {
	SWIG_setfeature("feature:director", "1");
	Wrapper_director_mode_set(1);
	Swig_mark_arg(i);
      } else if (strcmp(argv[i], "-dirprot") == 0) {
	Wrapper_director_protected_mode_set(1);
	Swig_mark_arg(i);
      } else if (strcmp(argv[i], "-nodirprot") == 0) {
	Wrapper_director_protected_mode_set(0);
	Swig_mark_arg(i);
      } else if (strcmp(argv[i], "-small") == 0) {
	Wrapper_compact_print_mode_set(1);
	Wrapper_virtual_elimination_mode_set(1);
	Swig_mark_arg(i);
      } else if (strcmp(argv[i], "-runtime") == 0) {
	Swig_mark_arg(i);
	Swig_warning(WARN_DEPRECATED_OPTC, "SWIG", 1, "-c, -runtime, -noruntime command line options are deprecated.\n");
	SwigRuntime = 1;
      } else if ((strcmp(argv[i], "-c") == 0) || (strcmp(argv[i], "-noruntime") == 0)) {
	Swig_mark_arg(i);
	Swig_warning(WARN_DEPRECATED_OPTC, "SWIG", 1, "-c, -runtime, -noruntime command line options are deprecated.\n");
	SwigRuntime = 2;
      } else if (strcmp(argv[i], "-external-runtime") == 0) {
	external_runtime = 1;
	Swig_mark_arg(i);
	if (argv[i + 1]) {
	  external_runtime_name = NewString(argv[i + 1]);
	  Swig_mark_arg(i + 1);
	  i++;
	}
      } else if ((strcmp(argv[i], "-make_default") == 0) || (strcmp(argv[i], "-makedefault") == 0)) {
	GenerateDefault = 1;
	Swig_mark_arg(i);
      } else if ((strcmp(argv[i], "-no_default") == 0) || (strcmp(argv[i], "-nodefault") == 0)) {
	GenerateDefault = 0;
	Swig_warning(WARN_DEPRECATED_NODEFAULT, "SWIG", 1, "dangerous, use -nodefaultctor, -nodefaultdtor instead.\n");
	Swig_mark_arg(i);
      } else if ((strcmp(argv[i], "-nodefaultctor") == 0)) {
	SWIG_setfeature("feature:nodefaultctor", "1");
	Swig_mark_arg(i);
      } else if ((strcmp(argv[i], "-nodefaultdtor") == 0)) {
	SWIG_setfeature("feature:nodefaultdtor", "1");
	Swig_mark_arg(i);
      } else if ((strcmp(argv[i], "-copyctor") == 0)) {
	SWIG_setfeature("feature:copyctor", "1");
	Swig_mark_arg(i);
      } else if (strcmp(argv[i], "-noexcept") == 0) {
	NoExcept = 1;
	Swig_mark_arg(i);
      } else if (strcmp(argv[i], "-noextern") == 0) {
	Swig_warning(WARN_DEPRECATED_NOEXTERN, "SWIG", 1, "-noextern command line option is deprecated; extern is no longer generated by default.\n");
	AddExtern = 0;
	Swig_mark_arg(i);
      } else if (strcmp(argv[i], "-addextern") == 0) {
	AddExtern = 1;
	Swig_mark_arg(i);
      } else if ((strcmp(argv[i], "-debug-template") == 0) || (strcmp(argv[i], "-debug_template") == 0) || (strcmp(argv[i], "-show_templates") == 0)) {
	Swig_cparse_debug_templates(1);
	Swig_mark_arg(i);
      } else if (strcmp(argv[i], "-templatereduce") == 0) {
	SWIG_cparse_template_reduce(1);
	Swig_mark_arg(i);
      } else if (strcmp(argv[i], "-notemplatereduce") == 0) {
	SWIG_cparse_template_reduce(0);
	Swig_mark_arg(i);
      } else if (strcmp(argv[i], "-macroerrors") == 0) {
	Swig_cparse_follow_locators(1);
	Swig_mark_arg(i);
      } else if (strcmp(argv[i], "-swiglib") == 0) {
	if (SwigLibWin)
	  printf("%s\n", Char(SwigLibWin));
	printf("%s\n", SwigLib);
	SWIG_exit(EXIT_SUCCESS);
      } else if (strcmp(argv[i], "-o") == 0) {
	Swig_mark_arg(i);
	if (argv[i + 1]) {
	  outfile_name = Swig_copy_string(argv[i + 1]);
	  if (!outfile_name_h || !dependencies_file) {
	    char *ext = strrchr(outfile_name, '.');
	    String *basename = ext ? NewStringWithSize(outfile_name, ext - outfile_name) : NewString(outfile_name);
	    if (!dependencies_file) {
	      dependencies_file = NewStringf("%s.%s", basename, depends_extension);
	    }
	    if (!outfile_name_h) {
	      Printf(basename, ".%s", hpp_extension);
	      outfile_name_h = Swig_copy_string(Char(basename));
	    }
	    Delete(basename);
	  }
	  Swig_mark_arg(i + 1);
	  i++;
	} else {
	  Swig_arg_error();
	}
      } else if (strcmp(argv[i], "-oh") == 0) {
	Swig_mark_arg(i);
	if (argv[i + 1]) {
	  outfile_name_h = Swig_copy_string(argv[i + 1]);
	  Swig_mark_arg(i + 1);
	  i++;
	} else {
	  Swig_arg_error();
	}
      } else if (strcmp(argv[i], "-fakeversion") == 0) {
	Swig_mark_arg(i);
	if (argv[i + 1]) {
	  Swig_set_fakeversion(argv[i + 1]);
	  Swig_mark_arg(i + 1);
	  i++;
	} else {
	  Swig_arg_error();
	}
      } else if (strcmp(argv[i], "-version") == 0) {
	fprintf(stdout, "\nSWIG Version %s\n", Swig_package_version());
	fprintf(stdout, "\nCompiled with %s [%s]\n", SWIG_CXX, SWIG_PLATFORM);
	fprintf(stdout, "Please see %s for reporting bugs and further information\n", PACKAGE_BUGREPORT);
	SWIG_exit(EXIT_SUCCESS);
      } else if (strcmp(argv[i], "-copyright") == 0) {
	fprintf(stdout, "\nSWIG Version %s\n", Swig_package_version());
	fprintf(stdout, "Copyright (c) 1995-1998\n");
	fprintf(stdout, "University of Utah and the Regents of the University of California\n");
	fprintf(stdout, "Copyright (c) 1998-2005\n");
	fprintf(stdout, "University of Chicago\n");
	fprintf(stdout, "Copyright (c) 2005-2006\n");
	fprintf(stdout, "Arizona Board of Regents (University of Arizona)\n");
	SWIG_exit(EXIT_SUCCESS);
      } else if (strncmp(argv[i], "-l", 2) == 0) {
	// Add a new directory search path
	Append(libfiles, argv[i] + 2);
	Swig_mark_arg(i);
      } else if (strcmp(argv[i], "-co") == 0) {
	checkout = 1;
	Swig_mark_arg(i);
      } else if (strcmp(argv[i], "-features") == 0) {
	Swig_mark_arg(i);
	if (argv[i + 1]) {
	  SWIG_setfeatures(argv[i + 1]);
	  Swig_mark_arg(i + 1);
	} else {
	  Swig_arg_error();
	}
      } else if (strcmp(argv[i], "-freeze") == 0) {
	freeze = 1;
	Swig_mark_arg(i);
      } else if (strcmp(argv[i], "-includeall") == 0) {
	Preprocessor_include_all(1);
	Swig_mark_arg(i);
      } else if (strcmp(argv[i], "-importall") == 0) {
	Preprocessor_import_all(1);
	Swig_mark_arg(i);
      } else if (strcmp(argv[i], "-ignoremissing") == 0) {
	Preprocessor_ignore_missing(1);
	Swig_mark_arg(i);
      } else if (strcmp(argv[i], "-cpperraswarn") == 0) {
	Preprocessor_error_as_warning(1);
	Swig_mark_arg(i);
      } else if (strcmp(argv[i], "-nocpperraswarn") == 0) {
	Preprocessor_error_as_warning(0);
	Swig_mark_arg(i);
      } else if ((strcmp(argv[i], "-debug-typemap") == 0) || (strcmp(argv[i], "-debug_typemap") == 0) || (strcmp(argv[i], "-tm_debug") == 0)) {
	tm_debug = 1;
	Swig_mark_arg(i);
      } else if (strcmp(argv[i], "-module") == 0) {
	Swig_mark_arg(i);
	if (argv[i + 1]) {
	  ModuleName = NewString(argv[i + 1]);
	  Swig_mark_arg(i + 1);
	} else {
	  Swig_arg_error();
	}
      } else if (strcmp(argv[i], "-M") == 0) {
	depend = 1;
	depend_only = 1;
	Swig_mark_arg(i);
      } else if (strcmp(argv[i], "-MM") == 0) {
	depend = 2;
	depend_only = 1;
	Swig_mark_arg(i);
      } else if (strcmp(argv[i], "-MF") == 0) {
	Swig_mark_arg(i);
	if (argv[i + 1]) {
	  dependencies_file = NewString(argv[i + 1]);
	  Swig_mark_arg(i + 1);
	} else {
	  Swig_arg_error();
	}
      } else if (strcmp(argv[i], "-MD") == 0) {
	depend = 1;
	Swig_mark_arg(i);
      } else if (strcmp(argv[i], "-MMD") == 0) {
	depend = 2;
	Swig_mark_arg(i);
      } else if (strcmp(argv[i], "-MT") == 0) {
	Swig_mark_arg(i);
	if (argv[i + 1]) {
          if (!dependencies_target)
            dependencies_target = NewString(argv[i + 1]);
          else
            Printf(dependencies_target, " %s", argv[i + 1]);
	  Swig_mark_arg(i + 1);
	} else {
	  Swig_arg_error();
	}
      } else if (strcmp(argv[i], "-outdir") == 0) {
	Swig_mark_arg(i);
	if (argv[i + 1]) {
	  outdir = NewString(argv[i + 1]);
	  Swig_mark_arg(i + 1);
	} else {
	  Swig_arg_error();
	}
      } else if (strcmp(argv[i], "-Wall") == 0) {
	Swig_mark_arg(i);
	Swig_warnall();
      } else if (strcmp(argv[i], "-Wallkw") == 0) {
	allkw = 1;
	Swig_mark_arg(i);
      } else if (strcmp(argv[i], "-Werror") == 0) {
	werror = 1;
	Swig_mark_arg(i);
      } else if (strcmp(argv[i], "-Wextra") == 0) {
	Swig_mark_arg(i);
        Swig_warnfilter(EXTRA_WARNINGS, 0);
      } else if (strncmp(argv[i], "-w", 2) == 0) {
	Swig_mark_arg(i);
	Swig_warnfilter(argv[i] + 2, 1);
      } else if ((strcmp(argv[i], "-debug-tags") == 0) || (strcmp(argv[i], "-dump_tags") == 0)) {
	dump_tags = 1;
	Swig_mark_arg(i);
      } else if (strcmp(argv[i], "-debug-top") == 0) {
	Swig_mark_arg(i);
	if (argv[i + 1]) {
	  String *dump_list = NewString(argv[i + 1]);
	  dump_top = decode_numbers_list(dump_list);
          if (dump_top < STAGE1 || dump_top >= STAGEOVERFLOW)
            Swig_arg_error();
          else
            Swig_mark_arg(i + 1);
          Delete(dump_list);
	} else {
	  Swig_arg_error();
	}
      } else if (strcmp(argv[i], "-debug-module") == 0) {
	Swig_mark_arg(i);
	if (argv[i + 1]) {
	  String *dump_list = NewString(argv[i + 1]);
	  dump_module = decode_numbers_list(dump_list);
          if (dump_module < STAGE1 || dump_module >= STAGEOVERFLOW)
            Swig_arg_error();
          else
            Swig_mark_arg(i + 1);
          Delete(dump_list);
	} else {
	  Swig_arg_error();
	}
      } else if ((strcmp(argv[i], "-dump_tree") == 0) || (strcmp(argv[i], "-dump_top") == 0)) {
	dump_top |= STAGE4;
	Swig_mark_arg(i);
      } else if (strcmp(argv[i], "-dump_module") == 0) {
	dump_module |= STAGE4;
	Swig_mark_arg(i);
      } else if (strcmp(argv[i], "-dump_parse_module") == 0) {
	dump_module |= STAGE1;
	Swig_mark_arg(i);
      } else if (strcmp(argv[i], "-dump_parse_top") == 0) {
	dump_top |= STAGE1;
	Swig_mark_arg(i);
      } else if (strcmp(argv[i], "-dump_xml") == 0) {
	dump_xml = 1;
	Swig_mark_arg(i);
      } else if (strcmp(argv[i], "-xmlout") == 0) {
	dump_xml = 1;
	Swig_mark_arg(i);
	if (argv[i + 1]) {
	  xmlout = NewString(argv[i + 1]);
	  Swig_mark_arg(i + 1);
	} else {
	  Swig_arg_error();
	}
      } else if (strcmp(argv[i], "-nocontract") == 0) {
	Swig_mark_arg(i);
	Swig_contract_mode_set(0);
      } else if (strcmp(argv[i], "-browse") == 0) {
	browse = 1;
	Swig_mark_arg(i);
      } else if ((strcmp(argv[i], "-debug-typedef") == 0) || (strcmp(argv[i], "-dump_typedef") == 0)) {
	dump_typedef = 1;
	Swig_mark_arg(i);
      } else if ((strcmp(argv[i], "-debug-classes") == 0) || (strcmp(argv[i], "-dump_classes") == 0)) {
	dump_classes = 1;
	Swig_mark_arg(i);
      } else if ((strcmp(argv[i], "-debug-memory") == 0) || (strcmp(argv[i], "-dump_memory") == 0)) {
	memory_debug = 1;
	Swig_mark_arg(i);
      } else if (strcmp(argv[i], "-Fstandard") == 0) {
	Swig_error_msg_format(EMF_STANDARD);
	Swig_mark_arg(i);
      } else if (strcmp(argv[i], "-Fmicrosoft") == 0) {
	Swig_error_msg_format(EMF_MICROSOFT);
	Swig_mark_arg(i);
      } else if (strcmp(argv[i], "-O") == 0) {
	Wrapper_virtual_elimination_mode_set(1);
	Wrapper_fast_dispatch_mode_set(1);
	Swig_mark_arg(i);
      } else if (strcmp(argv[i], "-help") == 0) {
	fputs(usage1, stdout);
	fputs(usage2, stdout);
	fputs(usage3, stdout);
	Swig_mark_arg(i);
	help = 1;
      }
    }
  }
}





int SWIG_main(int argc, char *argv[], Language *l) {
  char *c;
  extern void Swig_print_xml(Node *obj, String *filename);

  /* Initialize the SWIG core */
  Swig_init();

  // Default warning suppression
  Swig_warnfilter(EXTRA_WARNINGS, 1);

  // Initialize the preprocessor
  Preprocessor_init();

  lang = l;

  // Set up some default symbols (available in both SWIG interface files
  // and C files)

  Preprocessor_define((DOH *) "SWIG 1", 0);
  Preprocessor_define((DOH *) "__STDC__", 0);
#ifdef MACSWIG
  Preprocessor_define((DOH *) "SWIGMAC 1", 0);
#endif
#ifdef SWIGWIN32
  Preprocessor_define((DOH *) "SWIGWIN32 1", 0);
#endif

  // Set the SWIG version value in format 0xAABBCC from package version expected to be in format A.B.C
  String *package_version = NewString(PACKAGE_VERSION); /* Note that the fakeversion has not been set at this point */
  char *token = strtok(Char(package_version), ".");
  String *vers = NewString("SWIG_VERSION 0x");
  int count = 0;
  while (token) {
    int len = strlen(token);
    assert(len == 1 || len == 2);
    Printf(vers, "%s%s", (len == 1) ? "0" : "", token);
    token = strtok(NULL, ".");
    count++;
  }
  Delete(package_version);
  assert(count == 3);		// Check version format is correct

  /* Turn on contracts */

  Swig_contract_mode_set(1);
  Preprocessor_define(vers, 0);

  /* Turn off directors mode */
  Wrapper_director_mode_set(0);
  Wrapper_director_protected_mode_set(1);

  // Create Library search directories

  // Check for SWIG_LIB environment variable
  if ((c = getenv("SWIG_LIB")) == (char *) 0) {
#if defined(_WIN32)
    char buf[MAX_PATH];
    char *p;
    if (!(GetModuleFileName(0, buf, MAX_PATH) == 0 || (p = strrchr(buf, '\\')) == 0)) {
      *(p + 1) = '\0';
      SwigLibWin = NewStringf("%sLib", buf);	// Native windows installation path
    }
    SwigLib = Swig_copy_string(SWIG_LIB_WIN_UNIX);	// Unix installation path using a drive letter (for msys/mingw)
#else
    SwigLib = Swig_copy_string(SWIG_LIB);
#endif
  } else {
    SwigLib = Swig_copy_string(c);
  }

  libfiles = NewList();

  /* Check for SWIG_FEATURES environment variable */

  SWIG_getoptions(argc, argv);

  // Define the __cplusplus symbol
  if (CPlusPlus)
    Preprocessor_define((DOH *) "__cplusplus __cplusplus", 0);

  // Parse language dependent options
  lang->main(argc, argv);

  if (help) {
    Printf(stdout, "\nNote: 'swig -<lang> -help' displays options for a specific target language.\n\n");
    SWIG_exit(EXIT_SUCCESS);	// Exit if we're in help mode
  }
  // Check all of the options to make sure we're cool.
  // Don't check for an input file if -external-runtime is passed
  Swig_check_options(external_runtime ? 0 : 1);

  install_opts(argc, argv);

  // Add language dependent directory to the search path
  {
    String *rl = NewString("");
    Printf(rl, ".%sswig_lib%s%s", SWIG_FILE_DELIMITER, SWIG_FILE_DELIMITER, LangSubDir);
    Swig_add_directory(rl);
    if (SwigLibWin) {
      rl = NewString("");
      Printf(rl, "%s%s%s", SwigLibWin, SWIG_FILE_DELIMITER, LangSubDir);
      Swig_add_directory(rl);
    }
    rl = NewString("");
    Printf(rl, "%s%s%s", SwigLib, SWIG_FILE_DELIMITER, LangSubDir);
    Swig_add_directory(rl);
  }

  Swig_add_directory((String *) "." SWIG_FILE_DELIMITER "swig_lib");
  if (SwigLibWin)
    Swig_add_directory((String *) SwigLibWin);
  Swig_add_directory((String *) SwigLib);

  if (Verbose) {
    printf("LangSubDir: %s\n", Char(LangSubDir));
    printf("Search paths:\n");
    List *sp = Swig_search_path();
    Iterator s;
    for (s = First(sp); s.item; s = Next(s)) {
      Printf(stdout, "   %s\n", s.item);
    }
  }
  // handle the -external-runtime argument
  if (external_runtime)
    SWIG_dump_runtime();

  // If we made it this far, looks good. go for it....

  input_file = argv[argc - 1];

  // If the user has requested to check out a file, handle that
  if (checkout) {
    DOH *s;
    char *outfile = input_file;
    if (outfile_name)
      outfile = outfile_name;

    if (Verbose)
      printf("Handling checkout...\n");

    s = Swig_include(input_file);
    if (!s) {
      fprintf(stderr, "Unable to locate '%s' in the SWIG library.\n", input_file);
    } else {
      FILE *f = fopen(outfile, "r");
      if (f) {
	fclose(f);
	fprintf(stderr, "File '%s' already exists. Checkout aborted.\n", outfile);
      } else {
	f = fopen(outfile, "w");
	if (!f) {
	  fprintf(stderr, "Unable to create file '%s'\n", outfile);
	} else {
	  if (Verbose)
	    fprintf(stdout, "'%s' checked out from the SWIG library.\n", input_file);
	  fputs(Char(s), f);
	  fclose(f);
	}
      }
    }
  } else {
    // Check the suffix for a .c file.  If so, we're going to
    // declare everything we see as "extern"

    ForceExtern = check_suffix(input_file);

    // Run the preprocessor
    if (Verbose)
      printf("Preprocessing...\n");

    {
      int i;
      String *fs = NewString("");
      FILE *df = Swig_open(input_file);
      if (!df) {
	char *cfile = Char(input_file);
	if (cfile && cfile[0] == '-') {
	  Printf(stderr, "Unable to find option or file '%s', ", input_file);
	  Printf(stderr, "use 'swig -help' for more information.\n");
	} else {
	  Printf(stderr, "Unable to find file '%s'.\n", input_file);
	}
	SWIG_exit(EXIT_FAILURE);
      }
      fclose(df);
      if (!no_cpp) {
	Printf(fs, "%%include <swig.swg>\n");
	if (allkw) {
	  Printf(fs, "%%include <allkw.swg>\n");
	}
	if (lang_config) {
	  Printf(fs, "\n%%include <%s>\n", lang_config);
	}
	Printf(fs, "%%include \"%s\"\n", Swig_last_file());
	for (i = 0; i < Len(libfiles); i++) {
	  Printf(fs, "\n%%include \"%s\"\n", Getitem(libfiles, i));
	}
	Seek(fs, 0, SEEK_SET);
	cpps = Preprocessor_parse(fs);
	Delete(fs);
      } else {
	df = Swig_open(input_file);
	cpps = NewFileFromFile(df);
      }
      if (Swig_error_count()) {
	SWIG_exit(EXIT_FAILURE);
      }
      if (cpp_only) {
	Printf(stdout, "%s", cpps);
	SWIG_exit(EXIT_SUCCESS);
      }
      if (depend) {
	String *outfile;
	if (!outfile_name) {
	  if (CPlusPlus || lang->cplus_runtime_mode()) {
	    outfile = NewStringf("%s_wrap.%s", Swig_file_basename(input_file), cpp_extension);
	  } else {
	    outfile = NewStringf("%s_wrap.c", Swig_file_basename(input_file));
	  }
	} else {
	  outfile = NewString(outfile_name);
	}
	if (dependencies_file && Len(dependencies_file) != 0) {
	  f_dependencies_file = NewFile(dependencies_file, "w");
	  if (!f_dependencies_file) {
	    FileErrorDisplay(dependencies_file);
	    SWIG_exit(EXIT_FAILURE);
	  }
	} else if (!depend_only) {
	  String *filename = NewStringf("%s_wrap.%s", Swig_file_basename(input_file), depends_extension);
	  f_dependencies_file = NewFile(filename, "w");
	  if (!f_dependencies_file) {
	    FileErrorDisplay(filename);
	    SWIG_exit(EXIT_FAILURE);
	  }
	} else
	  f_dependencies_file = stdout;
	if (dependencies_target) {
	  Printf(f_dependencies_file, "%s: ", dependencies_target);
	} else {
	  Printf(f_dependencies_file, "%s: ", outfile);
	}
	List *files = Preprocessor_depend();
	for (int i = 0; i < Len(files); i++) {
	  if ((depend != 2) || ((depend == 2) && (Strncmp(Getitem(files, i), SwigLib, Len(SwigLib)) != 0))) {
	    Printf(f_dependencies_file, "\\\n %s ", Getitem(files, i));
	  }
	}
	Printf(f_dependencies_file, "\n");
	if (f_dependencies_file != stdout)
	  Close(f_dependencies_file);
	if (depend_only)
	  SWIG_exit(EXIT_SUCCESS);
      }
      Seek(cpps, 0, SEEK_SET);
    }

    /* Register a null file with the file handler */
    Swig_register_filebyname("null", NewString(""));

    // Pass control over to the specific language interpreter
    if (Verbose) {
      fprintf(stdout, "Starting language-specific parse...\n");
      fflush(stdout);
    }

    Node *top = Swig_cparse(cpps);

    if (dump_top & STAGE1) {
      Printf(stdout, "debug-top stage 1\n");
      Swig_print_tree(top);
    }
    if (dump_module & STAGE1) {
      Printf(stdout, "debug-module stage 1\n");
      Swig_print_tree(Getattr(top, "module"));
    }

    if (Verbose) {
      Printf(stdout, "Processing types...\n");
    }
    Swig_process_types(top);

    if (dump_top & STAGE2) {
      Printf(stdout, "debug-top stage 2\n");
      Swig_print_tree(top);
    }
    if (dump_module & STAGE2) {
      Printf(stdout, "debug-module stage 2\n");
      Swig_print_tree(Getattr(top, "module"));
    }

    if (Verbose) {
      Printf(stdout, "C++ analysis...\n");
    }
    Swig_default_allocators(top);

    if (dump_top & STAGE3) {
      Printf(stdout, "debug-top stage 3\n");
      Swig_print_tree(top);
    }
    if (dump_module & STAGE3) {
      Printf(stdout, "debug-module stage 3\n");
      Swig_print_tree(Getattr(top, "module"));
    }

    if (Verbose) {
      Printf(stdout, "Generating wrappers...\n");
    }

    if (dump_classes) {
      Hash *classes = Getattr(top, "classes");
      if (classes) {
	Printf(stdout, "Classes\n");
	Printf(stdout, "------------\n");
	Iterator ki;
	for (ki = First(classes); ki.key; ki = Next(ki)) {
	  Printf(stdout, "%s\n", ki.key);
	}
      }
    }

    if (dump_typedef) {
      SwigType_print_scope(0);
    }

    if (dump_tags) {
      Swig_print_tags(top, 0);
    }
    if (top) {
      if (!Getattr(top, "name")) {
	Printf(stderr, "*** No module name specified using %%module or -module.\n");
	SWIG_exit(EXIT_FAILURE);
      } else {
	/* Set some filename information on the object */
	Setattr(top, "infile", input_file);
	if (!outfile_name) {
	  if (CPlusPlus || lang->cplus_runtime_mode()) {
	    Setattr(top, "outfile", NewStringf("%s_wrap.%s", Swig_file_basename(input_file), cpp_extension));
	  } else {
	    Setattr(top, "outfile", NewStringf("%s_wrap.c", Swig_file_basename(input_file)));
	  }
	} else {
	  Setattr(top, "outfile", outfile_name);
	}
	if (!outfile_name_h) {
	  Setattr(top, "outfile_h", NewStringf("%s_wrap.%s", Swig_file_basename(input_file), hpp_extension));
	} else {
	  Setattr(top, "outfile_h", outfile_name_h);
	}
	set_outdir(Swig_file_dirname(Getattr(top, "outfile")));
	if (Swig_contract_mode_get()) {
	  Swig_contracts(top);
	}
	lang->top(top);
	if (browse) {
	  Swig_browser(top, 0);
	}
      }
    }
    if (dump_top & STAGE4) {
      Printf(stdout, "debug-top stage 4\n");
      Swig_print_tree(top);
    }
    if (dump_module & STAGE4) {
      Printf(stdout, "debug-module stage 4\n");
      Swig_print_tree(Getattr(top, "module"));
    }
    if (dump_xml && top) {
      Swig_print_xml(top, xmlout);
    }
    Delete(top);
  }
  if (tm_debug)
    Swig_typemap_debug();
  if (memory_debug)
    DohMemoryDebug();

  // Deletes
  Delete(libfiles);
  Preprocessor_delete();

  while (freeze) {
  }

  if ((werror) && (Swig_warn_count())) {
    return Swig_warn_count();
  }
  return Swig_error_count();
}

// --------------------------------------------------------------------------
// SWIG_exit(int exit_code)
//
// Cleanup and either freeze or exit
// --------------------------------------------------------------------------

void SWIG_exit(int exit_code) {
  while (freeze) {
  }
  exit(exit_code);
}
