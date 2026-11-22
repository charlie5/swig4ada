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


   function sizeof_Value (expression_Type : in unbounded_String;
                          known_Symbols   : in symbol_value_Maps.Map;
                          Namespace       : in unbounded_String) return Natural;
   --
   -- The size, in bytes, of a standard C type, or of an array of one, on the machine which generates the binding.

end c_Expressions;
