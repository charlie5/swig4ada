-- This file is generated by SWIG. Please do *not* modify by hand.
--
with Interfaces.C;
with Interfaces.C.Strings;
with Interfaces.C;

package preproc is

   -- MACROWITHARG
   --
   subtype MACROWITHARG is Interfaces.C.int;

   type MACROWITHARG_array is
     array (Interfaces.C.size_t range <>) of aliased preproc.MACROWITHARG;

   SLASHSLASH : aliased constant Interfaces.C.Strings.chars_ptr :=
     Interfaces.C.Strings.New_String ("//");
   a5 : aliased constant Interfaces.C.Strings.chars_ptr :=
     Interfaces.C.Strings.New_String ("helloworld");
   b5 : constant                                        := 3 + 4;
   d5 : constant                                        := 123;
   C1 : aliased constant Interfaces.C.Strings.chars_ptr :=
     Interfaces.C.Strings.New_String ("hello");
   ALONG_NAME : constant                                        := 42;
   C4         : aliased constant Interfaces.C.Strings.chars_ptr :=
     Interfaces.C.Strings.New_String ("Hello");
   a6                       : constant := (1 + 5);
   b6                       : constant := (1 * 5);
   c6                       : constant := ((1 + 5) * 5);
   d6                       : constant := ((1 + 5) * 5);
   EMBEDDED_DEFINE          : constant := 44;
   EMBEDDED_SWIG_CONSTANT   : constant := 55;
   A1                       : constant := 1 + 2;
   A2                       : constant := 3 - 4;
   A3                       : constant := 5 * 6;
   A4                       : constant := 7 / 8;
   A5_UC                    : constant := 1;
   A6_UC                    : constant := 45056;
   A7                       : constant := 12;
   A8                       : constant := 31;
   A9                       : constant := 3;
   A10                      : constant := 1;
   A11                      : constant := 1;
   A12                      : constant := -23;
   A13                      : constant := 0;
   a_a_GMP_HAVE_CONST       : constant := 0;
   a_a_GMP_HAVE_PROTOTYPES  : constant := 0;
   a_a_GMP_HAVE_TOKEN_PASTE : constant := 0;
   ONE_UC                   : constant := 1;
   two                      : constant := 2;
   three                    : constant := 3;
   endif                    : aliased Interfaces.C.int;
   define                   : aliased Interfaces.C.int;
   defined                  : aliased Interfaces.C.int;

private

   pragma Import (C, endif, "endif");
   pragma Import (C, define, "define");
   pragma Import (C, defined, "defined");

end preproc;
