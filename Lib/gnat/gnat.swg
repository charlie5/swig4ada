
/* -----------------------------------------------------------------------------
 * gnat.swg
 *
 * Gnat/Ada typemaps
 * ----------------------------------------------------------------------------- */


%include "gnathead.swg"

/*
%typemap (ctype_new)        void                                                          "void"
%typemap (adatype_new)      void                                                          "interfaces.c.extensions.void"

%typemap (ctype_new)        void*                                                         "void*"
%typemap (adatype_new)      void*                                                         "interfaces.c.extensions.void_ptr"

%typemap (ctype_new)        void**                                                        "void**"
%typemap (adatype_new)      void**                                                        "swig.void_ptr_Pointer"


%typemap (ctype_new)        int                                                           "int"
%typemap (adatype_new)      int                                                           "interfaces.c.int"

%typemap (ctype_new)        int*                                                          "int*"
%typemap (adatype_new)      int*                                                          "swig.int_Pointer"

%typemap (ctype_new)        int**                                                         "int**"
%typemap (adatype_new)      int**                                                         "swig.int_pointer_Pointer"


%typemap (adatype_new)      long                                                          "interfaces.c.long"
%typemap (adatype_new)      long*                                                         "swig.long_Pointer"
%typemap (adatype_new)      long**                                                        "swig.long_pointer_Pointer"


%typemap (adatype_new)      double                                                        "interfaces.c.double"
%typemap (adatype_new)      double*                                                       "swig.double_Pointer"
%typemap (adatype_new)      double**                                                      "swig.double_pointer_Pointer"



%typemap (ctype_new)        char                                                          "char"
%typemap (adatype_new)      char                                                          "interfaces.c.char"

%typemap (ctype_new)        char*                                                         "char*"
%typemap (adatype_new)      char*                                                         "interfaces.c.strings.chars_ptr"

%typemap (ctype_new)        char**                                                        "char**"
%typemap (adatype_new)      char**                                                        "swig.chars_ptr_Pointer"



%typemap (ctype_new)        unsigned int                                                  "unsigned int"
%typemap (adatype_new)      unsigned int                                                  "interfaces.c.unsigned"



%typemap (ctype_new)        unsigned char                                                 "unsigned char"
%typemap (adatype_new)      unsigned char                                                 "interfaces.c.unsigned_char"

%typemap (ctype_new)        signed char                                                   "signed char"
%typemap (adatype_new)      signed char                                                   "interfaces.c.signed_char"



%typemap (ctype_new)        short                                                         "short"
%typemap (adatype_new)      short                                                         "interfaces.c.short"


%typemap (ctype_new)        unsigned short                                                "unsigned short"
%typemap (adatype_new)      unsigned short                                                "interfaces.c.unsigned_short"


%typemap (ctype_new)        unsigned long                                                 "unsigned long"
%typemap (adatype_new)      unsigned long                                                 "interfaces.c.unsigned_long"


%typemap (ctype_new)        unsigned long long                                            "unsigned long long"
%typemap (adatype_new)      unsigned long long                                            "interfaces.c.extensions.unsigned_long_long"


%typemap (ctype_new)        float                                                         "float"
%typemap (adatype_new)      float                                                         "interfaces.c.c_float"



%typemap (ctype_new)        long long                                                     "long long"
%typemap (adatype_new)      long long                                                     "interfaces.c.extensions.long_long"


%typemap (ctype_new)        ptrdiff_t                                                     "ptrdiff_t"
%typemap (adatype_new)      ptrdiff_t                                                     "interfaces.c.ptrdiff_t"

*/






// old ...
//


// - the 'link_symbol_code' typemap defines the c++ linkage symbol code for a given C++ type.
// - is used to to construct the link symbol for pragma Import (C++, ...).


// primitive types
//
%typemap (link_symbol_code)      bool,                      const bool &                       "i"
%typemap (link_symbol_code)      char,                      const char &                       "c"

%typemap (link_symbol_code)      int8_t,                    const int8_t &                     "a"
%typemap (link_symbol_code)      signed char,               const signed char &                "a"

%typemap (link_symbol_code)      uint8_t,                   const uint8_t &                    "h"
%typemap (link_symbol_code)      unsigned char,             const unsigned char &              "h"

%typemap (link_symbol_code)      short,                     const short &                      "s"
%typemap (link_symbol_code)      unsigned short,            const unsigned short &             "t"

%typemap (link_symbol_code)      int16_t,                   const int16_t &                    "i"
%typemap (link_symbol_code)      int,                       const int &                        "i"

%typemap (link_symbol_code)      uint16_t,                  const uint16_t &                   "j"
%typemap (link_symbol_code)      unsigned int,              const unsigned int &               "j"

%typemap (link_symbol_code)      int32_t,                   const int32_t &                    "l"
%typemap (link_symbol_code)      long,                      const long &                       "l"

%typemap (link_symbol_code)      uint32_t,                  const uint32_t &                   "m"
%typemap (link_symbol_code)      unsigned long,             const unsigned long &              "m"

%typemap (link_symbol_code)      int64_t,                   const int64_t &                    "x"
%typemap (link_symbol_code)      long long,                 const long long &                  "x"

%typemap (link_symbol_code)      uint64_t,                  const uint64_t &                   "y"
%typemap (link_symbol_code)      unsigned long long,        const unsigned long long &         "y"

%typemap (link_symbol_code)      float,                     const float &                      "f"
%typemap (link_symbol_code)      double,                    const double &                     "d"
%typemap (link_symbol_code)      long double,               const long double &                "e"
%typemap (link_symbol_code)      void                                                          "v"



%typemap (link_symbol_code)      char               *,      const char               *         "Pc"

%typemap (link_symbol_code)      int8_t             *,      const int8_t             *         "Pa"
%typemap (link_symbol_code)      signed char        *,      const signed char        *         "Pa"

%typemap (link_symbol_code)      uint8_t            *,      const uint8_t            *         "Ph"
%typemap (link_symbol_code)      unsigned char      *,      const unsigned char      *         "Ph"

%typemap (link_symbol_code)      short              *,      const short              *         "Ps"
%typemap (link_symbol_code)      unsigned short     *,      const unsigned short     *         "Pt"

%typemap (link_symbol_code)      int16_t            *,      const int16_t            *         "Pi"
%typemap (link_symbol_code)      int                *,      const int                *         "Pi"

%typemap (link_symbol_code)      uint16_t           *,      const uint16_t           *         "Pj"
%typemap (link_symbol_code)      unsigned           *,      const unsigned           *         "Pj"

%typemap (link_symbol_code)      int32_t            *,      const int32_t            *         "Pl"
%typemap (link_symbol_code)      long               *,      const long               *         "Pl"

%typemap (link_symbol_code)      uint32_t           *,      const uint32_t           *         "Pm"
%typemap (link_symbol_code)      unsigned long      *,      const unsigned long      *         "Pm"

%typemap (link_symbol_code)      int64_t            *,      const int64_t            *         "Px"
%typemap (link_symbol_code)      long long          *,      const long long          *         "Px"

%typemap (link_symbol_code)      uint64_t           *,      const uint64_t           *         "Py"
%typemap (link_symbol_code)      unsigned long long *,      const unsigned long long *         "Py"

%typemap (link_symbol_code)      bool               *,      const bool               *         "Pi"
%typemap (link_symbol_code)      float              *,      const float              *         "Pf"
%typemap (link_symbol_code)      double             *,      const double             *         "Pd"
%typemap (link_symbol_code)      long double        *,      const long double        *         "Pe"

// following are tbd ... 
//
%typemap (link_symbol_code)      signed char         [],      signed char        [ANY]         "signed char*"
%typemap (link_symbol_code)      unsigned char       [],      unsigned char      [ANY]         "unsigned char*"
%typemap (link_symbol_code)      short               [],      short              [ANY]         "short*"
%typemap (link_symbol_code)      unsigned short      [],      unsigned short     [ANY]         "unsigned short*"
%typemap (link_symbol_code)      int                 [],      int                [ANY]         "int*"
%typemap (link_symbol_code)      unsigned            [],      unsigned           [ANY]         "unsigned*"
%typemap (link_symbol_code)      long                [],      long               [ANY]         "long*"
%typemap (link_symbol_code)      unsigned long       [],      unsigned long      [ANY]         "unsigned long*"
%typemap (link_symbol_code)      long long           [],      long long          [ANY]         "long long*"
%typemap (link_symbol_code)      unsigned long long  [],      unsigned long long [ANY]         "unsigned long long*"
%typemap (link_symbol_code)      bool                [],      bool               [ANY]         "bool*"
%typemap (link_symbol_code)      double              [],      double             [ANY]         "double*"
%typemap (link_symbol_code)      float               [],      float              [ANY]         "float*"





// primitive c types
//


// - the ctype and adatype typemaps work together and so there should be one of each. 
//
// - the ctype   typemap contains the C   type used in the C/C++ code. 
// - the adatype typemap contains the Ada type used in the Ada proxy classes, type wrapper classes and module class.


// primitive types
//
%typemap (ctype)      FILE*                                                         "FILE*"


%typemap (ctype)      void                                                          "void"
%typemap (ctype)      void *                                                        "void*"


%typemap (ctype)      bool                                                          "unsigned int"
%typemap (ctype)      bool *,          const bool *                                 "bool*"
%typemap (ctype)      bool &,          const bool &                                 "bool*"
%typemap (ctype)      bool [],         bool [ANY]                                   "bool*"


%typemap (ctype)      size_t                                                        "size_t"
%typemap (ctype)      size_t *,       const size_t *                                "size_t*"
%typemap (ctype)      size_t &,       const size_t &                                "size_t*"
%typemap (ctype)      size_t [],      size_t [ANY]                                  "size_t*"


%typemap (ctype)      ptrdiff_t                                                        "ptrdiff_t"
%typemap (ctype)      ptrdiff_t *,       const ptrdiff_t *                             "ptrdiff_t*"
%typemap (ctype)      ptrdiff_t &,       const ptrdiff_t &                             "ptrdiff_t*"
%typemap (ctype)      ptrdiff_t [],      ptrdiff_t [ANY]                               "ptrdiff_t*"



%typemap (ctype)      char,                      const char &                       "char"



%typemap (ctype)      int8_t,               const int8_t &                "int8_t"
%typemap (ctype)      int8_t        *,      int8_t              *         "int8_t*"
%typemap (ctype)      int8_t         [],    int8_t        [ANY]           "int8_t*"

%typemap (ctype)      int16_t,               const int16_t &                "int16_t"
%typemap (ctype)      int16_t        *,      int16_t              *         "int16_t*"
%typemap (ctype)      int16_t         [],    int16_t        [ANY]           "int16_t*"

%typemap (ctype)      int32_t                                                       "int32_t"
%typemap (ctype)      int32_t *,              const int32_t *                       "int32_t*"
%typemap (ctype)      int32_t &,              const int32_t &                       "int32_t*"
%typemap (ctype)      int32_t [],             int32_t [ANY]                         "int32_t*"

%typemap (ctype)      int64_t                                                       "int64_t"
%typemap (ctype)      int64_t *,              const int64_t *                       "int64_t*"
%typemap (ctype)      int64_t &,              const int64_t &                       "int64_t*"
%typemap (ctype)      int64_t [],             int64_t [ANY]                         "int64_t*"



%typemap (ctype)      uint8_t,               const uint8_t &                "uint8_t"
%typemap (ctype)      uint8_t        *,      uint8_t              *         "uint8_t*"
%typemap (ctype)      uint8_t         [],    uint8_t        [ANY]           "uint8_t*"

%typemap (ctype)      uint16_t,               const uint16_t &                "uint16_t"
%typemap (ctype)      uint16_t        *,      uint16_t              *         "uint16_t*"
%typemap (ctype)      uint16_t         [],    uint16_t        [ANY]           "uint16_t*"

%typemap (ctype)      uint32_t,               const uint32_t &                "uint32_t"
%typemap (ctype)      uint32_t        *,      uint32_t              *         "uint32_t*"
%typemap (ctype)      uint32_t         [],    uint32_t        [ANY]           "uint32_t*"

%typemap (ctype)      uint64_t,               const uint64_t &                "uint64_t"
%typemap (ctype)      uint64_t        *,      uint64_t              *         "uint64_t*"
%typemap (ctype)      uint64_t         [],    uint64_t        [ANY]           "uint64_t*"



%typemap (ctype)      signed char,               const signed char &                "signed char"
%typemap (ctype)      signed char        *,      signed char              *         "signed char*"
%typemap (ctype)      signed char         [],      signed char        [ANY]         "signed char*"


%typemap (ctype)      unsigned char,             const unsigned char &              "unsigned char"
%typemap (ctype)      unsigned char      *,      unsigned char            *         "unsigned char*"
%typemap (ctype)      unsigned char       [],      unsigned char      [ANY]         "unsigned char*"



%typemap (ctype)      short                                                         "short"
%typemap (ctype)      short *,      const short *                                   "short*"
%typemap (ctype)      short &,      const short &                                   "short*"
%typemap (ctype)      short [],     short [ANY]                                     "short*"


%typemap (ctype)      unsigned short                                                "unsigned short"
%typemap (ctype)      unsigned short *,       const unsigned short *                "unsigned short*"
%typemap (ctype)      unsigned short &,       const unsigned short &                "unsigned short*"
%typemap (ctype)      unsigned short [],      unsigned short [ANY]                  "unsigned short*"


%typemap (ctype)      int                                                           "int"
%typemap (ctype)      int *,              const int *                               "int*"
%typemap (ctype)      int &,              const int &                               "int*"
%typemap (ctype)      int [],             int [ANY]                                 "int*"


%typemap (ctype)      unsigned int                                                  "unsigned int"
%typemap (ctype)      unsigned int *,       const unsigned int *                    "unsigned int*"
%typemap (ctype)      unsigned int &,       const unsigned int &                    "unsigned int*"
%typemap (ctype)      unsigned int [],      unsigned int [ANY]                      "unsigned*"


%typemap (ctype)      long                                                          "long"
%typemap (ctype)      long *,               const long *                            "long*"
%typemap (ctype)      long &,               const long &                            "long*"
%typemap (ctype)      long [],              long [ANY]                              "long*"


%typemap (ctype)      unsigned long                                                 "unsigned long"
%typemap (ctype)      unsigned long *,      const unsigned long *                   "unsigned long*"
%typemap (ctype)      unsigned long &,      const unsigned long &                   "unsigned long*"
%typemap (ctype)      unsigned long [],     unsigned long [ANY]                     "unsigned long*"


%typemap (ctype)      long long                                                     "long long"
%typemap (ctype)      long long *,      const long long *                           "long long*"
%typemap (ctype)      long long &,      const long long &                           "long long*"
%typemap (ctype)      long long [],     long long [ANY]                             "long long*"


%typemap (ctype)      unsigned long long                                            "unsigned long long"
%typemap (ctype)      unsigned long long *,      const unsigned long long *         "unsigned long long*"
%typemap (ctype)      unsigned long long &,      const unsigned long long &         "unsigned long long*"
%typemap (ctype)      unsigned long long [],     unsigned long long [ANY]           "unsigned long long*"


%typemap (ctype)      float                                                         "float"
%typemap (ctype)      float *,           const float *                              "float*"
%typemap (ctype)      float &,           const float &                              "float*"
%typemap (ctype)      float [],          float [ANY]                                "float*"


%typemap (ctype)      double                                                        "double"
%typemap (ctype)      double *,           const double *                            "double*"
%typemap (ctype)      double &,           const double &                            "double*"
%typemap (ctype)      double [],          double [ANY]                              "double*"


%typemap (ctype)      long double                                                   "long double"
%typemap (ctype)      long double *,      const long double *                       "long double*"
%typemap (ctype)      long double &,      const long double &                       "long double*"
%typemap (ctype)      long double [],     long double [ANY]                         "long double*"





//%typemap (adatype)    FILE                                                            "interfaces.c.extensions.opaque_structure_def"
//%typemap (adatype)    FILE *                                                          "system.crtl.FILEs"


%typemap (adatype)    void                                                            "interfaces.c.extensions.void"
%typemap (adatype)    void *                                                          "interfaces.c.extensions.void_ptr"

%typemap (adatype)    void *[]                                                        "swig.void_ptr_Array"
%typemap (adatype)    void **                                                         "swig.void_ptr_Pointer"


%typemap (adatype)    bool                                                            "interfaces.c.extensions.bool"
%typemap (adatype)    bool &                                                          "swig.bool_Pointer"
%typemap (adatype)    bool *                                                          "swig.bool_Pointer"
%typemap (adatype)    bool []                                                         "swig.bool_Array"


//%typemap (adatype)    char                                                            "Character"
%typemap (adatype)    char                                                            "interfaces.c.char"
%typemap (adatype)    char &                                                          "interfaces.c.strings.chars_ptr"
%typemap (adatype)    char *                                                          "interfaces.c.strings.chars_ptr"
%typemap (adatype)    char []                                                         "interfaces.c.char_Array"

%typemap (adatype)    char *[]                                                        "interfaces.c.strings.chars_ptr_array"
%typemap (adatype)    char **                                                         "swig.chars_ptr_Pointer"


%typemap (adatype)    int8_t                                                     "interfaces.Integer_8"
%typemap (adatype)    int8_t &                                                   "swig.int8_t_Pointer"
%typemap (adatype)    int8_t *                                                   "swig.int8_t_Pointer"
%typemap (adatype)    int8_t []                                                  "swig.int8_t_Array"


%typemap (adatype)    int16_t                                                     "interfaces.Integer_16"
%typemap (adatype)    int16_t &                                                   "swig.int16_t_Pointer"
%typemap (adatype)    int16_t *                                                   "swig.int16_t_Pointer"
%typemap (adatype)    int16_t []                                                  "swig.int16_t_Array"

%typemap (adatype)    int32_t                                                     "interfaces.Integer_32"
%typemap (adatype)    int32_t &                                                   "swig.int32_t_Pointer"
%typemap (adatype)    int32_t *                                                   "swig.int32_t_Pointer"
%typemap (adatype)    int32_t []                                                  "swig.int32_t_Array"

%typemap (adatype)    int64_t                                                     "interfaces.Integer_64"
%typemap (adatype)    int64_t &                                                   "swig.int64_t_Pointer"
%typemap (adatype)    int64_t *                                                   "swig.int64_t_Pointer"
%typemap (adatype)    int64_t []                                                  "swig.int64_t_Array"



%typemap (adatype)    uint8_t                                                     "interfaces.unSigned_8"
%typemap (adatype)    uint8_t &                                                   "swig.uint8_t_Pointer"
%typemap (adatype)    uint8_t *                                                   "swig.uint8_t_Pointer"
%typemap (adatype)    uint8_t []                                                  "swig.uint8_t_Array"

%typemap (adatype)    uint16_t                                                     "interfaces.unSigned_16"
%typemap (adatype)    uint16_t &                                                   "swig.uint16_t_Pointer"
%typemap (adatype)    uint16_t *                                                   "swig.uint16_t_Pointer"
%typemap (adatype)    uint16_t []                                                  "swig.uint16_t_Array"

%typemap (adatype)    uint32_t                                                     "interfaces.unSigned_32"
%typemap (adatype)    uint32_t &                                                   "swig.uint32_t_Pointer"
%typemap (adatype)    uint32_t *                                                   "swig.uint32_t_Pointer"
%typemap (adatype)    uint32_t []                                                  "swig.uint32_t_Array"

%typemap (adatype)    uint64_t                                                     "interfaces.unSigned_64"
%typemap (adatype)    uint64_t &                                                   "swig.uint64_t_Pointer"
%typemap (adatype)    uint64_t *                                                   "swig.uint64_t_Pointer"
%typemap (adatype)    uint64_t []                                                  "swig.uint64_t_Array"


%typemap (adatype)    signed char                                                     "interfaces.c.signed_Char"
%typemap (adatype)    signed char &                                                   "swig.signed_char_Pointer"
%typemap (adatype)    signed char *                                                   "swig.signed_char_Pointer"
%typemap (adatype)    signed char []                                                  "swig.signed_char_Array"

%typemap (adatype)    unsigned char                                                   "interfaces.c.unsigned_Char"
%typemap (adatype)    unsigned char &                                                 "swig.unsigned_char_Pointer"
%typemap (adatype)    unsigned char *                                                 "swig.unsigned_char_Pointer"
%typemap (adatype)    unsigned char []                                                "swig.unsigned_char_Array"


%typemap (adatype)    short                                                           "short_Integer"
%typemap (adatype)    short &                                                         "swig.short_Pointer"
%typemap (adatype)    short *                                                         "swig.short_Pointer"
%typemap (adatype)    short []                                                        "swig.short_Array"

%typemap (adatype)    unsigned short                                                  "interfaces.c.unsigned_Short"
%typemap (adatype)    unsigned short &                                                "swig.unsigned_short_Pointer"
%typemap (adatype)    unsigned short *                                                "swig.unsigned_short_Pointer"
%typemap (adatype)    unsigned short []                                               "swig.unsigned_short_Array"


%typemap (adatype)    int                                                             "interfaces.c.Int"
%typemap (adatype)    int &                                                           "swig.int_Pointer"
%typemap (adatype)    int *                                                           "swig.int_Pointer"
%typemap (adatype)    int []                                                          "swig.int_Array"



%typemap (adatype)    unsigned int                                                    "interfaces.c.Unsigned"
%typemap (adatype)    unsigned int &                                                  "swig.unsigned_Pointer"
%typemap (adatype)    unsigned     *                                                  "swig.unsigned_Pointer"
%typemap (adatype)    unsigned     []                                                 "swig.unsigned_Array"


%typemap (adatype)    long                                                            "interfaces.c.Long"
%typemap (adatype)    long &                                                          "swig.long_Pointer"
%typemap (adatype)    long *                                                          "swig.long_Pointer"
%typemap (adatype)    long []                                                         "swig.long_Array"

%typemap (adatype)    unsigned long                                                   "interfaces.c.unsigned_Long"
%typemap (adatype)    unsigned long &                                                 "swig.unsigned_long_Pointer"
%typemap (adatype)    unsigned long *                                                 "swig.unsigned_long_Pointer"
%typemap (adatype)    unsigned long []                                                "swig.unsigned_long_Array"

%typemap (adatype)    long long                                                       "interfaces.c.extensions.long_Long" 
%typemap (adatype)    long long &                                                     "swig.long_long_Pointer" 
%typemap (adatype)    long long *                                                     "swig.long_long_Pointer"
%typemap (adatype)    long long []                                                    "swig.long_long_Array"

%typemap (adatype)    unsigned long long                                              "interfaces.c.extensions.unsigned_long_Long"         
%typemap (adatype)    unsigned long long &                                            "swig.unsigned_long_long_Pointer"                    
%typemap (adatype)    unsigned long long *                                            "swig.unsigned_long_long_Pointer"
%typemap (adatype)    unsigned long long []                                           "swig.unsigned_long_long_Array"


%typemap (adatype)    size_t                                                          "interfaces.c.Size_t"
%typemap (adatype)    size_t &                                                        "swig.size_t_Pointer"
%typemap (adatype)    size_t *                                                        "swig.size_t_Pointer"
%typemap (adatype)    size_t []                                                       "swig.size_t_Array"


%typemap (adatype)    ptrdiff_t                                                          "interfaces.c.ptrdiff_t"
%typemap (adatype)    ptrdiff_t &                                                        "swig.ptrdiff_t_Pointer"
%typemap (adatype)    ptrdiff_t *                                                        "swig.ptrdiff_t_Pointer"
%typemap (adatype)    ptrdiff_t []                                                       "swig.ptrdiff_t_Array"


%typemap (adatype)    float                                                           "interfaces.c.c_float"
%typemap (adatype)    float &                                                         "swig.float_Pointer"
%typemap (adatype)    float *                                                         "swig.float_Pointer"
%typemap (adatype)    float []                                                        "swig.float_Array"

%typemap (adatype)    double                                                          "interfaces.c.Double"
%typemap (adatype)    double &                                                        "swig.double_Pointer"
%typemap (adatype)    double *                                                        "swig.double_Pointer"
%typemap (adatype)    double []                                                       "swig.double_Array"

%typemap (adatype)    long double                                                     "interfaces.c.long_Double"
%typemap (adatype)    long double &                                                   "swig.long_double_Pointer"
%typemap (adatype)    long double *                                                   "swig.long_double_Pointer"
%typemap (adatype)    long double []                                                  "swig.long_double_Array"


%typemap (adatype)    std::string                                                     "swig.std_String"
%typemap (adatype)    std::string*                                                    "swig.std_String_view"
%typemap (adatype)    std::string&                                                    "swig.std_String_view"


%typemap (adatype)              dummy                                                 "system.Address"
//
// 'dummy' is used to force swig to recognise the Ada 'system.Address' type
// (tbd: find better way, in code)



// std::string
//


%typemap (ctype)      std::string                                                   "std::string"
%typemap (ctype)      std::string*                                                  "std::string*"
%typemap (ctype)      std::string&                                                  "std::string*"




%typemap (in)                                        std::string
%{ 
  $1 = ($1_ltype) $input; 
%}


%typemap (out)                                       std::string
%{ 
  $result = $1; 
%}




%typemap (in)                            std::string *, std::string &
%{ 
  $1 = ($1_ltype) $input;
%}


%typemap (out)                           std::string *, std::string &
%{ 
  $result = ($1_ltype) $1; 
%}





%typemap (adain)         std::string *, std::string &                    "$adainput"

%typemap (adaout)        std::string *, std::string &
%{
   return $imcall;
%}






// The 'record_component_array_adatype' typemap provides the array Ada type for use in a record.

%typemap (record_component_array_adatype)    char                                           "interfaces.c.char_Array"

%typemap (record_component_array_adatype)    int8_t                                         "swig.int8_t_Array"
%typemap (record_component_array_adatype)    int16_t                                        "swig.int16_t_Array"
%typemap (record_component_array_adatype)    int32_t                                        "swig.int32_t_Array"
%typemap (record_component_array_adatype)    int64_t                                        "swig.int64_t_Array"

%typemap (record_component_array_adatype)    uint8_t                                        "swig.uint8_t_Array"
%typemap (record_component_array_adatype)    uint16_t                                       "swig.uint16_t_Array"
%typemap (record_component_array_adatype)    uint32_t                                       "swig.uint32_t_Array"
%typemap (record_component_array_adatype)    uint64_t                                       "swig.uint64_t_Array"

%typemap (record_component_array_adatype)    signed char                                    "swig.signed_char_Array"
%typemap (record_component_array_adatype)    unsigned char                                  "swig.unsigned_char_Array"
%typemap (record_component_array_adatype)    short                                          "swig.short_Array"
%typemap (record_component_array_adatype)    unsigned short                                 "swig.unsigned_short_Array"
%typemap (record_component_array_adatype)    int                                            "swig.int_Array"
%typemap (record_component_array_adatype)    size_t                                         "swig.size_t_Array"
%typemap (record_component_array_adatype)    ptrdiff_t                                      "swig.ptrdiff_t_Array"
%typemap (record_component_array_adatype)    unsigned                                       "swig.unsigned_Array"
%typemap (record_component_array_adatype)    long                                           "swig.long_Array"
%typemap (record_component_array_adatype)    unsigned long                                  "swig.unsigned_long_Array"
%typemap (record_component_array_adatype)    long long                                      "swig.long_long_Array"
%typemap (record_component_array_adatype)    unsigned long long                             "swig.unsigned_long_long_Array"
%typemap (record_component_array_adatype)    bool                                           "swig.bool_Array"
%typemap (record_component_array_adatype)    double                                         "swig.double_Array"
%typemap (record_component_array_adatype)    long double                                    "swig.long_double_Array"
%typemap (record_component_array_adatype)    float                                          "swig.float_Array"

%typemap (record_component_array_adatype)    SWIGTYPE                                       "$adaclassname.items"
%typemap (record_component_array_adatype)    SWIGTYPE*                                      "$adaclassname.views"
%typemap (record_component_array_adatype)    SWIGTYPE[]                                     "$adaclassname.items"

%typemap (record_component_array_adatype)    std::string                                    "swig.std_String"
// tbd: check this above






// char * - treat as String 
//

%typemap (ctype)      char *, char[ANY], char[]                          "char *"

//%typemap (adatype)    char *                                             "interfaces.c.strings.chars_ptr"
//%typemap (adatype)    char[ANY], char[]                                  "interfaces.c.char_Array"


%typemap (in)         char *                                             %{ $1 = $input; %}
%typemap (out)        char *                                             %{ $result = $1; %}



// non primitive types

%typemap (ctype)               SWIGTYPE                   "$c_classname"
//%typemap (adatype)             SWIGTYPE                   "$&adaclassname"

%typemap (ctype)               SWIGTYPE []                "void *"
//%typemap (adatype)             SWIGTYPE []                "$adaclassname"

%typemap (ctype)               SWIGTYPE *                 "void *"
//%typemap (adatype)             SWIGTYPE *                 "$adaclassname"

%typemap (ctype)               SWIGTYPE &                 "void *"
//%typemap (adatype)             SWIGTYPE &                 "$adaclassname"



// pointer to a class member

%typemap (ctype)               SWIGTYPE (CLASS::*)         "int"
//%typemap (adatype)             SWIGTYPE (CLASS::*)         "$adaclassname"






// - the following are the in and out typemaps. 
//
// - these are the c/c++ code generating typemaps for converting from 
//   Ada to C and visa versa, in the c/c++ wrapper.


// primitive types
//

%typemap (in)                  bool
%{ 
  $1 = $input ? true : false; 
%}


%typemap (in)                  char, 

                               int8_t, 
                               int16_t, 
                               int32_t, 
                               int64_t, 

                               uint8_t, 
                               uint16_t, 
                               uint32_t, 
                               uint64_t, 

                               signed char, 
                               unsigned char, 
                               short, 
                               unsigned short, 
                               int, 
                               size_t, 
                               ptrdiff_t, 
                               unsigned int, 
                               long, 
                               unsigned long, 
                               long long, 
                               unsigned long long, 
                               float, 
                               double,
                               long double
%{
  $1 = ($1_ltype) $input; 
%}




// tbd: use single typemap with multiple types
//
%typemap (out)                            bool                 %{ $result = $1; %}     
%typemap (out)                            char                 %{ $result = $1; %}

%typemap (out)                            int8_t               %{ $result = $1; %}
%typemap (out)                            int16_t              %{ $result = $1; %}
%typemap (out)                            int32_t              %{ $result = $1; %}
%typemap (out)                            int64_t              %{ $result = $1; %}

%typemap (out)                            uint8_t              %{ $result = $1; %}
%typemap (out)                            uint16_t             %{ $result = $1; %}
%typemap (out)                            uint32_t             %{ $result = $1; %}
%typemap (out)                            uint64_t             %{ $result = $1; %}

%typemap (out)                            signed char          %{ $result = $1; %}
%typemap (out)                            unsigned char        %{ $result = $1; %}
%typemap (out)                            short                %{ $result = $1; %}
%typemap (out)                            unsigned short       %{ $result = $1; %}
%typemap (out)                            int                  %{ $result = $1; %}
%typemap (out)                            size_t               %{ $result = $1; %}
%typemap (out)                            ptrdiff_t            %{ $result = $1; %}
%typemap (out)                            unsigned int         %{ $result = $1; %}
%typemap (out)                            long                 %{ $result = $1; %}
%typemap (out)                            unsigned long        %{ $result = $1; %}
%typemap (out)                            long long            %{ $result = $1; %}
%typemap (out)                            unsigned long long   %{ $result = $1; %}
%typemap (out)                            float                %{ $result = $1; %}
%typemap (out)                            double               %{ $result = $1; %}
%typemap (out)                            long double          %{ $result = $1; %}
%typemap (out)                            void                 ""



// primitive types by const reference
//

%typemap (in)                                        const bool &
%{ 
  $1 = ($1_ltype) $input; 
%}


//%typemap (in)                                        const bool & (bool temp)
//%{ 
//  temp = $input ? true : false; 
//  $1   = &temp; 
//%}




%typemap (in)                                        const char &                (char              temp), 

                                                     const int8_t &              (int8_t            temp), 
                                                     const int16_t &             (int16_t           temp), 
                                                     const int32_t &             (int32_t           temp), 
                                                     const int64_t &             (int64_t           temp), 

                                                     const uint8_t &             (uint8_t           temp), 
                                                     const uint16_t &            (uint16_t          temp), 
                                                     const uint32_t &            (uint32_t          temp), 
                                                     const uint64_t &            (uint64_t          temp), 

                                                     const signed char &         (signed char       temp), 
                                                     const unsigned char &       (unsigned char     temp), 
                                                     const short &               (short             temp), 
                                                     const unsigned short &      (unsigned short    temp), 
                                                     const int &                 (int               temp), 
                                                     const size_t &              (size_t            temp), 
                                                     const ptrdiff_t &           (ptrdiff_t         temp), 
                                                     const unsigned int &        (unsigned int      temp), 
                                                     const long &                (long              temp), 
                                                     const unsigned long &       (unsigned long     temp), 
                                                     const long long &           ($*1_ltype         temp), 
                                                     const unsigned long long &  ($*1_ltype         temp), 
                                                     const float &               (float             temp), 
                                                     const double &              (double            temp),
                                                     const long double &         (long double       temp)
%{
  temp = ($*1_ltype) *$input; 
  $1   = &temp; 
%}





//%typemap (out)                                        const bool &                                       %{ $result = *$1; %}
%typemap (out)                                        const bool &                                       %{ $result = $1; %}

%typemap (out)                                        const char &                                       %{ $result = *$1; %}

%typemap (out)                                        const int8_t &                                     %{ $result = *$1; %}
%typemap (out)                                        const int16_t &                                    %{ $result = *$1; %}
%typemap (out)                                        const int32_t &                                    %{ $result = *$1; %}
%typemap (out)                                        const int64_t &                                    %{ $result = *$1; %}

%typemap (out)                                        const uint8_t &                                    %{ $result = *$1; %}
%typemap (out)                                        const uint16_t &                                   %{ $result = *$1; %}
%typemap (out)                                        const uint32_t &                                   %{ $result = *$1; %}
%typemap (out)                                        const uint64_t &                                   %{ $result = *$1; %}

%typemap (out)                                        const signed char &                                %{ $result = *$1; %}
%typemap (out)                                        const unsigned char &                              %{ $result = *$1; %}
%typemap (out)                                        const short &                                      %{ $result = *$1; %}
%typemap (out)                                        const unsigned short &                             %{ $result = *$1; %}
%typemap (out)                                        const int &                                        %{ $result = *$1; %}
%typemap (out)                                        const size_t &                                     %{ $result = *$1; %}
%typemap (out)                                        const ptrdiff_t &                                  %{ $result = *$1; %}
%typemap (out)                                        const unsigned int &                               %{ $result = *$1; %}
%typemap (out)                                        const long &                                       %{ $result = *$1; %}
%typemap (out)                                        const unsigned long &                              %{ $result = *$1; %}
%typemap (out)                                        const long long &                                  %{ $result = *$1; %}
%typemap (out)                                        const unsigned long long &                         %{ $result = *$1; %}
%typemap (out)                                        const float &                                      %{ $result = $1; %}
%typemap (out)                                        const double &                                     %{ $result = *$1; %}
%typemap (out)                                        const long double &                                %{ $result = *$1; %}






// - default handling
// - object passed by value
// - convert to a pointer

%typemap (in)                       SWIGTYPE ($&1_type    argp)
%{ 
   argp = ($&1_ltype) &$input; 
   
   $1 = *argp; 
%}



/* Original

%typemap (in)                       SWIGTYPE ($&1_type    argp)
%{ 
   argp = ($&1_ltype) &$input; 
   
   if (!argp) 
   {
     SWIG_AdaThrowException (SWIG_AdaNullReferenceException, "Attempt to dereference null $1_type");
   }
   
   $1 = *argp; 
%}

*/




%typemap (out)                                  SWIGTYPE 
#ifdef __cplusplus
%{
  $result = $1; 
  //$result = new $1_ltype (($1_ltype &) $1); 
%}
#else
{
  $result = $1; 
}
#endif



/* Original

%typemap (out)                                  SWIGTYPE 
#ifdef __cplusplus
%{
  $result = $1; 
  //$result = new $1_ltype (($1_ltype &) $1); 
%}
#else
{
  $&1_ltype       $1ptr = ($&1_ltype) malloc(sizeof($1_ltype));
  
  memmove ($1ptr, &$1, sizeof ($1_type));
  $result = $1ptr;
}
#endif
*/




// generic pointers and references 

%typemap (in)                                   SWIGTYPE *                 %{ $1 = ($1_ltype)$input; %}
%typemap (in)                                   SWIGTYPE (CLASS::*)        %{ $1 = *($&1_ltype)&$input; %}

%typemap (in)                                   SWIGTYPE & 
%{ 
  $1 = ($1_ltype)$input;
%}

/* Original

%typemap (in)                                   SWIGTYPE & 
%{ 
  $1 = ($1_ltype)$input;
  
  if (!$1) 
  {
    SWIG_AdaThrowException (SWIG_AdaNullReferenceException, "$1_type reference is null");
  }
%}

*/



%typemap (in)            double             *,     const double             *,     double             [],     double             [ANY],
                         long double        *,     const long double        *,     long double        [],     long double        [ANY],
                         float              *,     const float              *,     float              [],     float              [ANY],
                         short              *,     const short              *,     short              [],     short              [ANY],
                         unsigned short     *,     const unsigned short     *,     unsigned short     [],     unsigned short     [ANY],
                         int                *,     const int                *,     int                [],     int                [ANY],
                         size_t             *,     const size_t             *,     size_t             [],     size_t             [ANY],
                         ptrdiff_t          *,     const ptrdiff_t          *,     ptrdiff_t          [],     ptrdiff_t          [ANY],
                         unsigned           *,     const unsigned           *,     unsigned           [],     unsigned           [ANY],
                         long               *,     const long               *,     long               [],     long               [ANY],
                         unsigned long      *,     const unsigned long      *,     unsigned long      [],     unsigned long      [ANY],
                         long long          *,     const long long          *,     long long          [],     long long          [ANY],
                         unsigned long long *,     const unsigned long long *,     unsigned long long [],     unsigned long long [ANY],
                         bool               *,     const bool               *,     bool               [],     bool               [ANY],

                         int8_t             *,     const int8_t             *,     int8_t             [],     int8_t             [ANY],
                         int16_t            *,     const int16_t            *,     int16_t            [],     int16_t            [ANY],
                         int32_t            *,     const int32_t            *,     int32_t            [],     int32_t            [ANY],
                         int64_t            *,     const int64_t            *,     int64_t            [],     int64_t            [ANY],

                         uint8_t            *,     const uint8_t            *,     uint8_t            [],     uint8_t            [ANY],
                         uint16_t           *,     const uint16_t           *,     uint16_t           [],     uint16_t           [ANY],
                         uint32_t           *,     const uint32_t           *,     uint32_t           [],     uint32_t           [ANY],
                         uint64_t           *,     const uint64_t           *,     uint64_t           [],     uint64_t           [ANY],

                         signed char        *,     const signed char        *,     signed char        [],     signed char        [ANY],
                         unsigned char      *,     const unsigned char      *,     unsigned char      [],     unsigned char      [ANY],
                         FILE *
%{ 
  $1 = ($1_ltype) $input;
%}



%typemap (out)           double&,               const double&,               double             *,  const double             *,   double             [],  double             [ANY],
                         long double&,          const long double&,          long double        *,  const long double        *,   long double        [],  long double        [ANY],
                         float&,                const float&,                float              *,  const float              *,   float              [],  float              [ANY],
                         short&,                const short&,                short              *,  const short              *,   short              [],  short              [ANY],
                         unsigned short&,       const unsigned short&,       unsigned short     *,  const unsigned short     *,   unsigned short     [],  unsigned short     [ANY],
                         int&,                  const int&,                  int                *,  const int                *,   int                [],  int                [ANY],
                         size_t&,               const size_t&,               size_t             *,  const size_t             *,   size_t             [],  size_t             [ANY],
                         ptrdiff_t&,            const ptrdiff_t&,            ptrdiff_t          *,  const ptrdiff_t          *,   ptrdiff_t          [],  ptrdiff_t          [ANY],
                         unsigned&,             const unsigned&,             unsigned           *,  const unsigned           *,   unsigned           [],  unsigned           [ANY],
                         long&,                 const long&,                 long               *,  const long               *,   long               [],  long               [ANY],
                         unsigned long&,        const unsigned long&,        unsigned long      *,  const unsigned long      *,   unsigned long      [],  unsigned long      [ANY],
                         long long&,            const long long&,            long long          *,  const long long          *,   long long          [],  long long          [ANY],
                         unsigned long long &,  const unsigned long long &,  unsigned long long *,  const unsigned long long *,   unsigned long long [],  unsigned long long [ANY],
                         bool               &,  const bool               &,  bool               *,  const bool               *,   bool               [],  bool               [ANY],

                         int8_t             *,  const int8_t             *,     int8_t             [],     int8_t             [ANY],
                         int16_t            *,  const int16_t            *,     int16_t            [],     int16_t            [ANY],
                         int32_t            *,  const int32_t            *,     int32_t            [],     int32_t            [ANY],
                         int64_t            *,  const int64_t            *,     int64_t            [],     int64_t            [ANY],

                         uint8_t            *,  const uint8_t            *,     uint8_t            [],     uint8_t            [ANY],
                         uint16_t           *,  const uint16_t           *,     uint16_t           [],     uint16_t           [ANY],
                         uint32_t           *,  const uint32_t           *,     uint32_t           [],     uint32_t           [ANY],
                         uint64_t           *,  const uint64_t           *,     uint64_t           [],     uint64_t           [ANY],

                         signed char        *,  const signed char        *,     signed char        [],     signed char        [ANY],
                         unsigned char      *,  const unsigned char      *,     unsigned char      [],     unsigned char      [ANY],
                         FILE *
%{ 
  $result = ($1_ltype) $1; 
%}




%typemap (out)               SWIGTYPE *,  SWIGTYPE &      %{ $result = (void *) $1;      %} 
%typemap (out)               SWIGTYPE (CLASS::*)          %{ *($&1_ltype) &$result = $1; %} 





// default array handling

%typemap (in)                SWIGTYPE []                  %{ $1      = ($1_ltype) $input; %}
%typemap (out)               SWIGTYPE []                  %{ $result = $1; %} 



// char arrays - treat as String

%typemap (in)                char[ANY], char[]            %{ $1 = $input; %}
%typemap (out)               char[ANY], char[]            %{ $result = $1; %}





// typecheck typemaps
//
// - the purpose of these is merely to issue a warning for overloaded C++ functions 
//   that cannot be overloaded in Ada as more than one C++ type maps to a single Ada type

%typecheck (SWIG_TYPECHECK_BOOL)        bool,
                                        const bool &                  ""

%typecheck (SWIG_TYPECHECK_CHAR)        char, 
                                        const char &                  ""

%typecheck (SWIG_TYPECHECK_INT8)        int8_t,
                                        signed char,
                                        const signed char &           ""

%typecheck (SWIG_TYPECHECK_UINT8)       uint8_t,
                                        unsigned char, 
                                        const unsigned char &         ""

%typecheck (SWIG_TYPECHECK_INT16)       short, 
                                        const short &                 ""

%typecheck (SWIG_TYPECHECK_UINT16)      uint16_t,
                                        unsigned short, 
                                        const unsigned short &        ""

%typecheck (SWIG_TYPECHECK_INT32)       int, 
                                        int32_t, 
                                        long, 
                                        const int &, 
                                        const long &                  ""

//%typecheck (SWIG_TYPECHECK_SIZE_T)      size_t, 
//                                        const size_t &                ""

%typecheck (SWIG_TYPECHECK_UINT32)      uint32_t,
                                        unsigned int, 
                                        unsigned long, 
                                        const unsigned int &, 
                                        const unsigned long &         ""

%typecheck (SWIG_TYPECHECK_INT64)       int64_t,
                                        long long, 
                                        const long long &             ""

%typecheck (SWIG_TYPECHECK_UINT64)      uint64_t,
                                        unsigned long long,
                                        const unsigned long long &    ""

%typecheck(SWIG_TYPECHECK_FLOAT)        float,
                                        const float &                 ""

%typecheck (SWIG_TYPECHECK_DOUBLE)      double,
                                        const double &                ""

//%typecheck (SWIG_TYPECHECK_LONG_DOUBLE) long double,
//                                        const long double &           ""

%typecheck (SWIG_TYPECHECK_STRING)      char *,
                                        char[ANY],
                                        char[]                        ""

%typecheck (SWIG_TYPECHECK_POINTER)     SWIGTYPE, 
                                        SWIGTYPE *, 
                                        SWIGTYPE &, 
                                        SWIGTYPE [],
                                        SWIGTYPE (CLASS::*)           ""




// exception handling  --- TBD

%typemap (throws)                       int, 
                                        long, 
                                        short, 
                                        unsigned int, 
                                        unsigned long, 
                                        unsigned short 
{
  char         error_msg [256];
  
  sprintf (error_msg,  "C++ $1_type exception thrown, value: %d", $1);
  SWIG_AdaThrowException (SWIG_AdaException, error_msg);
}



%typemap (throws)                       SWIGTYPE,  SWIGTYPE &,  SWIGTYPE *,  SWIGTYPE [ANY] 
%{
  (void) $1;
  SWIG_AdaThrowException (SWIG_AdaException, "C++ $1_type exception thrown");
%}



%typemap (throws)                       char * 
%{
  SWIG_AdaThrowException (SWIG_AdaException, $1);
%}






// Ada specific directives

#define %adaconst       (flag)               %feature ("ada:const",      "flag")
#define %adaconstvalue  (value)              %feature ("ada:constvalue", value)
#define %adaenum(wrapapproach)               %feature ("ada:enum",       "wrapapproach")    // tbd: whitespace bewtween %adaenum and (wrapapproach) breaks enums ?!? (core swig prob ?)
#define %adamethodmodifiers                  %feature ("ada:methodmodifiers")





// some ANSI C typemaps

//%apply unsigned long    { size_t };



// gnat ada keywords

%include "gnatkw.swg"



// default enum handling

%include "enums.swg"






// rename functions & class/struct members to guard reserved words and pre-underscored identifiers (tbd: better way ?)
// 

%rename (a_declare)      declare;
%rename (the_Declare)    Declare;

%rename (an_array)       array;
%rename (the_Array)      Array;
%rename (an_ARRAY)       ARRAY;

%rename (a_body)         body;
%rename (the_Body)       Body;

%rename (a_do)           do;
%rename (the_Do)         Do;

%rename (a_end)          end;
%rename (the_End)        End;

%rename (a_in)           in;
%rename (the_In)         In;

%rename (o_R)            oR;
//%rename (an_or)          or;             tbd: this causes an 'Error: Syntax error in input(1)' error, due to the 'or' part
%rename (the_Or)         Or;

%rename (a_raise)        raise;
%rename (the_Raise)      Raise;

//%rename (a_type)         type;
//%rename (the_Type)       Type;

//%rename (a_use)         use;
//%rename (the_Use)       Use;

%rename (an_id)          _id;
%rename (the_Id)         _Id;

%rename (a_p1)           _p1;
%rename (the_P1)         _P1;



// renames functions arguments to guard reserved words (and illegal identifiers) (tbd: fix identifers with leading '_' in code)
// (tbd: get rid of this)

//#define  Type      the_Type
//#define  array     the_array




// make typemaps from 'typemaps.i' available

//%include "typemaps.i"


