-- This file is generated by SWIG. Please do not modify by hand.
--
with interfaces.c;
with swig;

package DOHs is

   -- DOH
   --
   subtype DOH is swig.void;

   type DOH_array is array (interfaces.C.Size_t range <>) of aliased DOHs.DOH;

   -- DohFuncPtr_t
   --
   subtype DohFuncPtr_t is swig.opaque_structure;

   type DohFuncPtr_t_array is
     array (interfaces.C.Size_t range <>) of aliased DOHs.DohFuncPtr_t;

   DOH_MAJOR_VERSION      : constant := 0;
   DOH_MINOR_VERSION      : constant := 1;
   DOH_BEGIN              : constant := -1;
   DOH_END                : constant := -2;
   DOH_CUR                : constant := -3;
   DOH_CURRENT            : constant := -3;
   DOH_REPLACE_ANY        : constant := 16#1#;
   DOH_REPLACE_NOQUOTE    : constant := 16#2#;
   DOH_REPLACE_ID         : constant := 16#4#;
   DOH_REPLACE_FIRST      : constant := 16#8#;
   DOH_REPLACE_ID_BEGIN   : constant := 16#10#;
   DOH_REPLACE_ID_END     : constant := 16#20#;
   DOH_REPLACE_NUMBER_END : constant := 16#40#;

end DOHs;
