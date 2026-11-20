with
     interfaces.C.Pointers,
     interfaces.C.Strings;

package swig.std_Strings
--
-- The C++ 'std::string'.
--
-- C++ passes and returns a string through a hidden pointer, and only C++ can construct one, so the type is
-- limited and of convention CPP. An object declared with no initial value is an empty string.
--
-- The subprograms are imported from functions which are part of a wrapper file whose interface file includes
-- 'std_string.i'. A program which uses this package must therefore be linked with such a wrapper.
--
is
   use Interfaces;

   --  The layout is that of GNU libstdc++ since its C++11 ABI (GCC 5): a pointer to the characters,
   --  the length, and a buffer which holds a short string or else the capacity.
   --
   type std_String is limited
      record
         M_dataplus      : swig.void_ptr;
         M_string_length : C.size_t;
         M_local_buf     : C.char_array (0 .. 15);
      end record;

   pragma Import (CPP, Entity => std_String);

   function  to_std_String return std_String;
   pragma CPP_Constructor (to_std_String, "swig_ada_std_string_construct");

   function  to_std_String (From : in C.char_array) return std_String;     -- 'From' is nul terminated, as 'interfaces.C.to_C' gives.
   pragma CPP_Constructor (to_std_String, "swig_ada_std_string_construct_from_chars");


   type std_string_Array         is array (C.size_t range <>) of aliased std_String;

   type std_string_Pointer       is access all std_String;                 -- A limited type cannot be the element of an 'interfaces.C.Pointers'.
   pragma Convention (C, std_string_Pointer);

   type std_string_pointer_Array is array (C.size_t range <>) of aliased std_string_Pointer;

   package c_std_string_pointer_Pointers is new C.Pointers (Index              => C.size_t,
                                                            Element            => std_string_Pointer,
                                                            element_Array      => std_string_pointer_Array,
                                                            default_Terminator => null);
   subtype std_string_pointer_Pointer    is c_std_string_pointer_Pointers.Pointer;


   --------------
   --  Operations
   --

   function  c_str    (Self : in     std_String) return C.Strings.chars_ptr;     -- The characters remain the property of 'Self'.
   function  Length   (Self : in     std_String) return C.size_t;
   function  to_Ada   (Self : in     std_String) return String;

   procedure assign   (Self : in out std_String;   From : in C.char_array);      -- 'From' is nul terminated.

   procedure destruct (Self : in out std_String);
   --
   -- Ada does not call the destructor of a C++ object, so a string which has been constructed
   -- is destructed by this call, or else by a 'swig.Guards' guard.



private

   pragma Import (C, c_str,    "swig_ada_std_string_c_str");
   pragma Import (C, Length,   "swig_ada_std_string_length");
   pragma Import (C, assign,   "swig_ada_std_string_assign");
   pragma Import (C, destruct, "swig_ada_std_string_destruct");

   function to_Ada (Self : in std_String) return String
   is (C.Strings.Value (c_str (Self)));

end swig.std_Strings;
