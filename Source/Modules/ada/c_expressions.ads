with
     GMP.discrete,

     ada.Strings.unbounded.Hash,
     ada.Containers.hashed_Maps;


package c_Expressions
--
-- Works out the value of a C expression which is an integer: the value of a '#define', of an enumeration
-- item, of the length of an array or of the width of a bit-field.
--
-- An expression is made of numbers (decimal, octal, hexadecimal or binary, with or without a suffix), of
-- characters within quotes, of the names of values which are already known, of 'sizeof' a standard type, and of
-- the operators of C, which are applied as C applies them. 'Constraint_Error' is raised for an expression
-- which cannot be worked out.
--
is
   use GMP,
       GMP.discrete,
       ada.Strings.unbounded;

   package symbol_value_Maps is new ada.Containers.hashed_Maps (unbounded_String,
                                                                discrete.Integer,
                                                                ada.Strings.unbounded.Hash,
                                                                "=");
   --
   -- The values which are known, by name.


   function Value_of     (the_Expression  : in unbounded_String;
                          known_Symbols   : in symbol_value_Maps.Map;
                          Namespace       : in unbounded_String) return discrete.Integer;
   --
   -- A name is sought with the namespace ahead of it first, and then as it is written.


   package real_value_Maps is new ada.Containers.hashed_Maps (unbounded_String,
                                                              Long_Float,
                                                              ada.Strings.unbounded.Hash,
                                                              "=");
   --
   -- The values of the real constants which are known, by name.


   function real_Value_of (the_Expression : in String;
                           known_Reals    : in real_value_Maps  .Map;
                           known_Integers : in symbol_value_Maps.Map;
                           Namespace      : in unbounded_String) return Long_Float;
   --
   -- The value of an expression which is a real number: of numbers, of the names of values which are known, of the
   -- signs, of '+', '-', '*' and '/', and of brackets. The casts are removed first. A division of two integers is
   -- that of C, which truncates ('1 / 3' is 0, and '1.0 / 3' a third). 'Constraint_Error' is raised for an
   -- expression which cannot be worked out.


   function without_Casts (the_Expression : in String;
                           known_Symbols  : in symbol_value_Maps.Map;
                           Namespace      : in unbounded_String) return String;
   --
   -- The expression less its casts, which do not change the value of a constant: '(mytype) 10', 'static_cast< T >(10)'
   -- and 'int (10)' are each '10' (the last within its brackets).


   function sizeof_Value (expression_Type : in unbounded_String;
                          known_Symbols   : in symbol_value_Maps.Map;
                          Namespace       : in unbounded_String) return Natural;
   --
   -- The size, in bytes, of a standard C type, or of an array of one, on the machine which generates the binding.

end c_Expressions;
