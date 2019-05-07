-- This file is generated by SWIG. Please do *not* modify by hand.
--
with DOHs;
with interfaces.c;
with interfaces.c.strings;
with swig;
with interfaces.C;

package swigg_module is

   -- DohObjInfo
   --
   subtype DohObjInfo is swig.opaque_structure;

   type DohObjInfo_array is
     array (interfaces.C.Size_t range <>) of aliased swigg_module.DohObjInfo;

   -- String
   --
   subtype String is DOHs.DOH;

   type String_array is
     array (interfaces.C.Size_t range <>) of aliased swigg_module.String;

   -- Hash
   --
   subtype Hash is DOHs.DOH;

   type Hash_array is
     array (interfaces.C.Size_t range <>) of aliased swigg_module.Hash;

   -- List
   --
   subtype List is DOHs.DOH;

   type List_array is
     array (interfaces.C.Size_t range <>) of aliased swigg_module.List;

   -- String_or_char
   --
   subtype String_or_char is DOHs.DOH;

   type String_or_char_array is
     array
       (interfaces.C.Size_t range <>) of aliased swigg_module.String_or_char;

   -- File
   --
   subtype File is DOHs.DOH;

   type File_array is
     array (interfaces.C.Size_t range <>) of aliased swigg_module.File;

   -- Parm
   --
   subtype Parm is DOHs.DOH;

   type Parm_array is
     array (interfaces.C.Size_t range <>) of aliased swigg_module.Parm;

   -- ParmList
   --
   subtype ParmList is DOHs.DOH;

   type ParmList_array is
     array (interfaces.C.Size_t range <>) of aliased swigg_module.ParmList;

   -- Node
   --
   subtype Node is DOHs.DOH;

   type Node_array is
     array (interfaces.C.Size_t range <>) of aliased swigg_module.Node;

   -- Symtab
   --
   subtype Symtab is DOHs.DOH;

   type Symtab_array is
     array (interfaces.C.Size_t range <>) of aliased swigg_module.Symtab;

   -- Typetab
   --
   subtype Typetab is DOHs.DOH;

   type Typetab_array is
     array (interfaces.C.Size_t range <>) of aliased swigg_module.Typetab;

   -- SwigType
   --
   subtype SwigType is DOHs.DOH;

   type SwigType_array is
     array (interfaces.C.Size_t range <>) of aliased swigg_module.SwigType;

   -- ErrorMessageFormat
   --
   type ErrorMessageFormat is (EMF_STANDARD, EMF_MICROSOFT);

   for ErrorMessageFormat use (EMF_STANDARD => 0, EMF_MICROSOFT => 1);

   pragma Convention (C, ErrorMessageFormat);

   type ErrorMessageFormat_array is
     array
       (interfaces.C.Size_t range <>) of aliased swigg_module
       .ErrorMessageFormat;

   HAVE_INTTYPES_H  : constant                                        := 1;
   HAVE_LIBDL       : constant                                        := 1;
   HAVE_MEMORY_H    : constant                                        := 1;
   HAVE_PCRE        : constant                                        := 1;
   HAVE_POPEN       : constant                                        := 1;
   HAVE_STDINT_H    : constant                                        := 1;
   HAVE_STDLIB_H    : constant                                        := 1;
   HAVE_STRINGS_H   : constant                                        := 1;
   HAVE_STRING_H    : constant                                        := 1;
   HAVE_SYS_STAT_H  : constant                                        := 1;
   HAVE_SYS_TYPES_H : constant                                        := 1;
   HAVE_UNISTD_H    : constant                                        := 1;
   the_PACKAGE      : aliased constant interfaces.c.strings.chars_ptr :=
     interfaces.c.strings.new_String ("swig");
   PACKAGE_BUGREPORT : aliased constant interfaces.c.strings.chars_ptr :=
     interfaces.c.strings.new_String ("http://www.swig.org");
   PACKAGE_NAME : aliased constant interfaces.c.strings.chars_ptr :=
     interfaces.c.strings.new_String ("swig");
   PACKAGE_STRING : aliased constant interfaces.c.strings.chars_ptr :=
     interfaces.c.strings.new_String ("swig 4.0.0");
   PACKAGE_TARNAME : aliased constant interfaces.c.strings.chars_ptr :=
     interfaces.c.strings.new_String ("swig");
   PACKAGE_URL : aliased constant interfaces.c.strings.chars_ptr :=
     interfaces.c.strings.new_String ("\0");
   PACKAGE_VERSION : aliased constant interfaces.c.strings.chars_ptr :=
     interfaces.c.strings.new_String ("4.0.0");
   STDC_HEADERS : constant                                        := 1;
   SWIG_CXX     : aliased constant interfaces.c.strings.chars_ptr :=
     interfaces.c.strings.new_String ("g++");
   SWIG_LIB : aliased constant interfaces.c.strings.chars_ptr :=
     interfaces.c.strings.new_String ("/usr/local/share/swig/4.0.0");
   SWIG_LIB_WIN_UNIX : aliased constant interfaces.c.strings.chars_ptr :=
     interfaces.c.strings.new_String ("\0");
   SWIG_PLATFORM : aliased constant interfaces.c.strings.chars_ptr :=
     interfaces.c.strings.new_String ("x86_64-pc-linux-gnu");
   VERSION : aliased constant interfaces.c.strings.chars_ptr :=
     interfaces.c.strings.new_String ("4.0.0");
   WARN_NONE                               : constant := 0;
   WARN_DEPRECATED_EXTERN                  : constant := 101;
   WARN_DEPRECATED_VAL                     : constant := 102;
   WARN_DEPRECATED_OUT                     : constant := 103;
   WARN_DEPRECATED_DISABLEDOC              : constant := 104;
   WARN_DEPRECATED_ENABLEDOC               : constant := 105;
   WARN_DEPRECATED_DOCONLY                 : constant := 106;
   WARN_DEPRECATED_STYLE                   : constant := 107;
   WARN_DEPRECATED_LOCALSTYLE              : constant := 108;
   WARN_DEPRECATED_TITLE                   : constant := 109;
   WARN_DEPRECATED_SECTION                 : constant := 110;
   WARN_DEPRECATED_SUBSECTION              : constant := 111;
   WARN_DEPRECATED_SUBSUBSECTION           : constant := 112;
   WARN_DEPRECATED_ADDMETHODS              : constant := 113;
   WARN_DEPRECATED_READONLY                : constant := 114;
   WARN_DEPRECATED_READWRITE               : constant := 115;
   WARN_DEPRECATED_EXCEPT                  : constant := 116;
   WARN_DEPRECATED_NEW                     : constant := 117;
   WARN_DEPRECATED_EXCEPT_TM               : constant := 118;
   WARN_DEPRECATED_IGNORE_TM               : constant := 119;
   WARN_DEPRECATED_OPTC                    : constant := 120;
   WARN_DEPRECATED_NAME                    : constant := 121;
   WARN_DEPRECATED_NOEXTERN                : constant := 122;
   WARN_DEPRECATED_NODEFAULT               : constant := 123;
   WARN_DEPRECATED_TYPEMAP_LANG            : constant := 124;
   WARN_DEPRECATED_INPUT_FILE              : constant := 125;
   WARN_DEPRECATED_NESTED_WORKAROUND       : constant := 126;
   WARN_PP_MISSING_FILE                    : constant := 201;
   WARN_PP_EVALUATION                      : constant := 202;
   WARN_PP_INCLUDEALL_IMPORTALL            : constant := 203;
   WARN_PP_CPP_WARNING                     : constant := 204;
   WARN_PP_CPP_ERROR                       : constant := 205;
   WARN_PP_UNEXPECTED_TOKENS               : constant := 206;
   WARN_PARSE_CLASS_KEYWORD                : constant := 301;
   WARN_PARSE_REDEFINED                    : constant := 302;
   WARN_PARSE_EXTEND_UNDEF                 : constant := 303;
   WARN_PARSE_UNSUPPORTED_VALUE            : constant := 304;
   WARN_PARSE_BAD_VALUE                    : constant := 305;
   WARN_PARSE_PRIVATE                      : constant := 306;
   WARN_PARSE_BAD_DEFAULT                  : constant := 307;
   WARN_PARSE_NAMESPACE_ALIAS              : constant := 308;
   WARN_PARSE_PRIVATE_INHERIT              : constant := 309;
   WARN_PARSE_TEMPLATE_REPEAT              : constant := 310;
   WARN_PARSE_TEMPLATE_PARTIAL             : constant := 311;
   WARN_PARSE_UNNAMED_NESTED_CLASS         : constant := 312;
   WARN_PARSE_UNDEFINED_EXTERN             : constant := 313;
   WARN_PARSE_KEYWORD                      : constant := 314;
   WARN_PARSE_USING_UNDEF                  : constant := 315;
   WARN_PARSE_MODULE_REPEAT                : constant := 316;
   WARN_PARSE_TEMPLATE_SP_UNDEF            : constant := 317;
   WARN_PARSE_TEMPLATE_AMBIG               : constant := 318;
   WARN_PARSE_NO_ACCESS                    : constant := 319;
   WARN_PARSE_EXPLICIT_TEMPLATE            : constant := 320;
   WARN_PARSE_BUILTIN_NAME                 : constant := 321;
   WARN_PARSE_REDUNDANT                    : constant := 322;
   WARN_PARSE_REC_INHERITANCE              : constant := 323;
   WARN_PARSE_NESTED_TEMPLATE              : constant := 324;
   WARN_PARSE_NAMED_NESTED_CLASS           : constant := 325;
   WARN_PARSE_EXTEND_NAME                  : constant := 326;
   WARN_CPP11_LAMBDA                       : constant := 340;
   WARN_CPP11_ALIAS_DECLARATION            : constant := 341;
   WARN_CPP11_ALIAS_TEMPLATE               : constant := 342;
   WARN_CPP11_VARIADIC_TEMPLATE            : constant := 343;
   WARN_IGNORE_OPERATOR_NEW                : constant := 350;
   WARN_IGNORE_OPERATOR_DELETE             : constant := 351;
   WARN_IGNORE_OPERATOR_PLUS               : constant := 352;
   WARN_IGNORE_OPERATOR_MINUS              : constant := 353;
   WARN_IGNORE_OPERATOR_MUL                : constant := 354;
   WARN_IGNORE_OPERATOR_DIV                : constant := 355;
   WARN_IGNORE_OPERATOR_MOD                : constant := 356;
   WARN_IGNORE_OPERATOR_XOR                : constant := 357;
   WARN_IGNORE_OPERATOR_AND                : constant := 358;
   WARN_IGNORE_OPERATOR_OR                 : constant := 359;
   WARN_IGNORE_OPERATOR_NOT                : constant := 360;
   WARN_IGNORE_OPERATOR_LNOT               : constant := 361;
   WARN_IGNORE_OPERATOR_EQ                 : constant := 362;
   WARN_IGNORE_OPERATOR_LT                 : constant := 363;
   WARN_IGNORE_OPERATOR_GT                 : constant := 364;
   WARN_IGNORE_OPERATOR_PLUSEQ             : constant := 365;
   WARN_IGNORE_OPERATOR_MINUSEQ            : constant := 366;
   WARN_IGNORE_OPERATOR_MULEQ              : constant := 367;
   WARN_IGNORE_OPERATOR_DIVEQ              : constant := 368;
   WARN_IGNORE_OPERATOR_MODEQ              : constant := 369;
   WARN_IGNORE_OPERATOR_XOREQ              : constant := 370;
   WARN_IGNORE_OPERATOR_ANDEQ              : constant := 371;
   WARN_IGNORE_OPERATOR_OREQ               : constant := 372;
   WARN_IGNORE_OPERATOR_LSHIFT             : constant := 373;
   WARN_IGNORE_OPERATOR_RSHIFT             : constant := 374;
   WARN_IGNORE_OPERATOR_LSHIFTEQ           : constant := 375;
   WARN_IGNORE_OPERATOR_RSHIFTEQ           : constant := 376;
   WARN_IGNORE_OPERATOR_EQUALTO            : constant := 377;
   WARN_IGNORE_OPERATOR_NOTEQUAL           : constant := 378;
   WARN_IGNORE_OPERATOR_LTEQUAL            : constant := 379;
   WARN_IGNORE_OPERATOR_GTEQUAL            : constant := 380;
   WARN_IGNORE_OPERATOR_LAND               : constant := 381;
   WARN_IGNORE_OPERATOR_LOR                : constant := 382;
   WARN_IGNORE_OPERATOR_PLUSPLUS           : constant := 383;
   WARN_IGNORE_OPERATOR_MINUSMINUS         : constant := 384;
   WARN_IGNORE_OPERATOR_COMMA              : constant := 385;
   WARN_IGNORE_OPERATOR_ARROWSTAR          : constant := 386;
   WARN_IGNORE_OPERATOR_ARROW              : constant := 387;
   WARN_IGNORE_OPERATOR_CALL               : constant := 388;
   WARN_IGNORE_OPERATOR_INDEX              : constant := 389;
   WARN_IGNORE_OPERATOR_UPLUS              : constant := 390;
   WARN_IGNORE_OPERATOR_UMINUS             : constant := 391;
   WARN_IGNORE_OPERATOR_UMUL               : constant := 392;
   WARN_IGNORE_OPERATOR_UAND               : constant := 393;
   WARN_IGNORE_OPERATOR_NEWARR             : constant := 394;
   WARN_IGNORE_OPERATOR_DELARR             : constant := 395;
   WARN_IGNORE_OPERATOR_REF                : constant := 396;
   WARN_TYPE_UNDEFINED_CLASS               : constant := 401;
   WARN_TYPE_INCOMPLETE                    : constant := 402;
   WARN_TYPE_ABSTRACT                      : constant := 403;
   WARN_TYPE_REDEFINED                     : constant := 404;
   WARN_TYPE_RVALUE_REF_QUALIFIER_IGNORED  : constant := 405;
   WARN_TYPEMAP_SOURCETARGET               : constant := 450;
   WARN_TYPEMAP_CHARLEAK                   : constant := 451;
   WARN_TYPEMAP_SWIGTYPE                   : constant := 452;
   WARN_TYPEMAP_APPLY_UNDEF                : constant := 453;
   WARN_TYPEMAP_SWIGTYPELEAK               : constant := 454;
   WARN_TYPEMAP_IN_UNDEF                   : constant := 460;
   WARN_TYPEMAP_OUT_UNDEF                  : constant := 461;
   WARN_TYPEMAP_VARIN_UNDEF                : constant := 462;
   WARN_TYPEMAP_VAROUT_UNDEF               : constant := 463;
   WARN_TYPEMAP_CONST_UNDEF                : constant := 464;
   WARN_TYPEMAP_UNDEF                      : constant := 465;
   WARN_TYPEMAP_VAR_UNDEF                  : constant := 466;
   WARN_TYPEMAP_TYPECHECK                  : constant := 467;
   WARN_TYPEMAP_THROW                      : constant := 468;
   WARN_TYPEMAP_DIRECTORIN_UNDEF           : constant := 469;
   WARN_TYPEMAP_THREAD_UNSAFE              : constant := 470;
   WARN_TYPEMAP_DIRECTOROUT_UNDEF          : constant := 471;
   WARN_TYPEMAP_TYPECHECK_UNDEF            : constant := 472;
   WARN_TYPEMAP_DIRECTOROUT_PTR            : constant := 473;
   WARN_TYPEMAP_OUT_OPTIMAL_IGNORED        : constant := 474;
   WARN_TYPEMAP_OUT_OPTIMAL_MULTIPLE       : constant := 475;
   WARN_TYPEMAP_INITIALIZER_LIST           : constant := 476;
   WARN_TYPEMAP_DIRECTORTHROWS_UNDEF       : constant := 477;
   WARN_FRAGMENT_NOT_FOUND                 : constant := 490;
   WARN_LANG_OVERLOAD_DECL                 : constant := 501;
   WARN_LANG_OVERLOAD_CONSTRUCT            : constant := 502;
   WARN_LANG_IDENTIFIER                    : constant := 503;
   WARN_LANG_RETURN_TYPE                   : constant := 504;
   WARN_LANG_VARARGS                       : constant := 505;
   WARN_LANG_VARARGS_KEYWORD               : constant := 506;
   WARN_LANG_NATIVE_UNIMPL                 : constant := 507;
   WARN_LANG_DEREF_SHADOW                  : constant := 508;
   WARN_LANG_OVERLOAD_SHADOW               : constant := 509;
   WARN_LANG_FRIEND_IGNORE                 : constant := 510;
   WARN_LANG_OVERLOAD_KEYWORD              : constant := 511;
   WARN_LANG_OVERLOAD_CONST                : constant := 512;
   WARN_LANG_CLASS_UNNAMED                 : constant := 513;
   WARN_LANG_DIRECTOR_VDESTRUCT            : constant := 514;
   WARN_LANG_DISCARD_CONST                 : constant := 515;
   WARN_LANG_OVERLOAD_IGNORED              : constant := 516;
   WARN_LANG_DIRECTOR_ABSTRACT             : constant := 517;
   WARN_LANG_PORTABILITY_FILENAME          : constant := 518;
   WARN_LANG_TEMPLATE_METHOD_IGNORE        : constant := 519;
   WARN_LANG_SMARTPTR_MISSING              : constant := 520;
   WARN_LANG_ILLEGAL_DESTRUCTOR            : constant := 521;
   WARN_LANG_EXTEND_CONSTRUCTOR            : constant := 522;
   WARN_LANG_EXTEND_DESTRUCTOR             : constant := 523;
   WARN_LANG_EXPERIMENTAL                  : constant := 524;
   WARN_LANG_DIRECTOR_FINAL                : constant := 525;
   WARN_DOXYGEN_UNKNOWN_COMMAND            : constant := 560;
   WARN_DOXYGEN_UNEXPECTED_END_OF_COMMENT  : constant := 561;
   WARN_DOXYGEN_COMMAND_EXPECTED           : constant := 562;
   WARN_DOXYGEN_HTML_ERROR                 : constant := 563;
   WARN_DOXYGEN_COMMAND_ERROR              : constant := 564;
   WARN_DOXYGEN_UNKNOWN_CHARACTER          : constant := 565;
   WARN_D_TYPEMAP_CTYPE_UNDEF              : constant := 700;
   WARN_D_TYPEMAP_IMTYPE_UNDEF             : constant := 701;
   WARN_D_TYPEMAP_DTYPE_UNDEF              : constant := 702;
   WARN_D_MULTIPLE_INHERITANCE             : constant := 703;
   WARN_D_TYPEMAP_CLASSMOD_UNDEF           : constant := 704;
   WARN_D_TYPEMAP_DBODY_UNDEF              : constant := 705;
   WARN_D_TYPEMAP_DOUT_UNDEF               : constant := 706;
   WARN_D_TYPEMAP_DIN_UNDEF                : constant := 707;
   WARN_D_TYPEMAP_DDIRECTORIN_UNDEF        : constant := 708;
   WARN_D_TYPEMAP_DCONSTRUCTOR_UNDEF       : constant := 709;
   WARN_D_EXCODE_MISSING                   : constant := 710;
   WARN_D_CANTHROW_MISSING                 : constant := 711;
   WARN_D_NO_DIRECTORCONNECT_ATTR          : constant := 712;
   WARN_D_NAME_COLLISION                   : constant := 713;
   WARN_SCILAB_TRUNCATED_NAME              : constant := 720;
   WARN_PYTHON_INDENT_MISMATCH             : constant := 740;
   WARN_RUBY_WRONG_NAME                    : constant := 801;
   WARN_RUBY_MULTIPLE_INHERITANCE          : constant := 802;
   WARN_JAVA_TYPEMAP_JNI_UNDEF             : constant := 810;
   WARN_JAVA_TYPEMAP_JTYPE_UNDEF           : constant := 811;
   WARN_JAVA_TYPEMAP_JSTYPE_UNDEF          : constant := 812;
   WARN_JAVA_MULTIPLE_INHERITANCE          : constant := 813;
   WARN_JAVA_TYPEMAP_GETCPTR_UNDEF         : constant := 814;
   WARN_JAVA_TYPEMAP_CLASSMOD_UNDEF        : constant := 815;
   WARN_JAVA_TYPEMAP_JAVABODY_UNDEF        : constant := 816;
   WARN_JAVA_TYPEMAP_JAVAOUT_UNDEF         : constant := 817;
   WARN_JAVA_TYPEMAP_JAVAIN_UNDEF          : constant := 818;
   WARN_JAVA_TYPEMAP_JAVADIRECTORIN_UNDEF  : constant := 819;
   WARN_JAVA_TYPEMAP_JAVADIRECTOROUT_UNDEF : constant := 820;
   WARN_JAVA_TYPEMAP_INTERFACECODE_UNDEF   : constant := 821;
   WARN_JAVA_COVARIANT_RET                 : constant := 822;
   WARN_JAVA_TYPEMAP_JAVACONSTRUCT_UNDEF   : constant := 823;
   WARN_JAVA_TYPEMAP_DIRECTORIN_NODESC     : constant := 824;
   WARN_JAVA_NO_DIRECTORCONNECT_ATTR       : constant := 825;
   WARN_JAVA_NSPACE_WITHOUT_PACKAGE        : constant := 826;
   WARN_CSHARP_TYPEMAP_CTYPE_UNDEF         : constant := 830;
   WARN_CSHARP_TYPEMAP_CSTYPE_UNDEF        : constant := 831;
   WARN_CSHARP_TYPEMAP_CSWTYPE_UNDEF       : constant := 832;
   WARN_CSHARP_MULTIPLE_INHERITANCE        : constant := 833;
   WARN_CSHARP_TYPEMAP_GETCPTR_UNDEF       : constant := 834;
   WARN_CSHARP_TYPEMAP_CLASSMOD_UNDEF      : constant := 835;
   WARN_CSHARP_TYPEMAP_CSBODY_UNDEF        : constant := 836;
   WARN_CSHARP_TYPEMAP_CSOUT_UNDEF         : constant := 837;
   WARN_CSHARP_TYPEMAP_CSIN_UNDEF          : constant := 838;
   WARN_CSHARP_TYPEMAP_CSDIRECTORIN_UNDEF  : constant := 839;
   WARN_CSHARP_TYPEMAP_CSDIRECTOROUT_UNDEF : constant := 840;
   WARN_CSHARP_TYPEMAP_INTERFACECODE_UNDEF : constant := 841;
   WARN_CSHARP_COVARIANT_RET               : constant := 842;
   WARN_CSHARP_TYPEMAP_CSCONSTRUCT_UNDEF   : constant := 843;
   WARN_CSHARP_EXCODE                      : constant := 844;
   WARN_CSHARP_CANTHROW                    : constant := 845;
   WARN_CSHARP_NO_DIRECTORCONNECT_ATTR     : constant := 846;
   WARN_MODULA3_TYPEMAP_TYPE_UNDEF         : constant := 850;
   WARN_MODULA3_TYPEMAP_GETCPTR_UNDEF      : constant := 851;
   WARN_MODULA3_TYPEMAP_CLASSMOD_UNDEF     : constant := 852;
   WARN_MODULA3_TYPEMAP_PTRCONSTMOD_UNDEF  : constant := 853;
   WARN_MODULA3_TYPEMAP_MULTIPLE_RETURN    : constant := 854;
   WARN_MODULA3_MULTIPLE_INHERITANCE       : constant := 855;
   WARN_MODULA3_TYPECONSTRUCTOR_UNKNOWN    : constant := 856;
   WARN_MODULA3_UNKNOWN_PRAGMA             : constant := 857;
   WARN_MODULA3_BAD_ENUMERATION            : constant := 858;
   WARN_MODULA3_DOUBLE_ID                  : constant := 859;
   WARN_MODULA3_BAD_IMPORT                 : constant := 860;
   WARN_PHP_MULTIPLE_INHERITANCE           : constant := 870;
   WARN_PHP_UNKNOWN_PRAGMA                 : constant := 871;
   WARN_PHP_PUBLIC_BASE                    : constant := 872;
   WARN_GO_NAME_CONFLICT                   : constant := 890;
   SWIG_OK                                 : constant := 1;
   SWIG_ERROR                              : constant := 0;
   SWIG_NOWRAP                             : constant := 0;
   NSPACE_SEPARATOR : aliased constant interfaces.c.strings.chars_ptr :=
     interfaces.c.strings.new_String (".");
   NSPACE_TODO                  : constant := 0;
   T_BOOL                       : constant := 1;
   T_SCHAR                      : constant := 2;
   T_UCHAR                      : constant := 3;
   T_SHORT                      : constant := 4;
   T_USHORT                     : constant := 5;
   T_ENUM                       : constant := 6;
   T_INT                        : constant := 7;
   T_UINT                       : constant := 8;
   T_LONG                       : constant := 9;
   T_ULONG                      : constant := 10;
   T_LONGLONG                   : constant := 11;
   T_ULONGLONG                  : constant := 12;
   T_FLOAT                      : constant := 20;
   T_DOUBLE                     : constant := 21;
   T_LONGDOUBLE                 : constant := 22;
   T_FLTCPLX                    : constant := 23;
   T_DBLCPLX                    : constant := 24;
   T_NUMERIC                    : constant := 25;
   T_AUTO                       : constant := 26;
   T_COMPLEX                    : constant := 24;
   T_CHAR                       : constant := 29;
   T_WCHAR                      : constant := 30;
   T_USER                       : constant := 31;
   T_VOID                       : constant := 32;
   T_STRING                     : constant := 33;
   T_POINTER                    : constant := 34;
   T_REFERENCE                  : constant := 35;
   T_ARRAY                      : constant := 36;
   T_FUNCTION                   : constant := 37;
   T_MPOINTER                   : constant := 38;
   T_VARARGS                    : constant := 39;
   T_RVALUE_REFERENCE           : constant := 40;
   T_WSTRING                    : constant := 41;
   T_SYMBOL                     : constant := 98;
   T_ERROR                      : constant := 99;
   CWRAP_EXTEND                 : constant := 16#1#;
   CWRAP_SMART_POINTER          : constant := 16#2#;
   CWRAP_NATURAL_VAR            : constant := 16#4#;
   CWRAP_DIRECTOR_ONE_CALL      : constant := 16#8#;
   CWRAP_DIRECTOR_TWO_CALLS     : constant := 16#10#;
   CWRAP_ALL_PROTECTED_ACCESS   : constant := 16#20#;
   CWRAP_SMART_POINTER_OVERLOAD : constant := 16#40#;
   SWIG_FILE_DELIMITER : aliased constant interfaces.c.strings.chars_ptr :=
     interfaces.c.strings.new_String ("/");

end swigg_module;
