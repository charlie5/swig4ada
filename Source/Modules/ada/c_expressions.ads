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


   type a_Real is
      record
         Value     : Long_Float;
         is_Single : Boolean;     -- Whether it is of C's 'float', in which an operation of two such is worked out.
      end record;

   package real_value_Maps is new ada.Containers.hashed_Maps (unbounded_String,
                                                              a_Real,
                                                              ada.Strings.unbounded.Hash,
                                                              "=");
   --
   -- The values of the real constants which are known, by name.


   type a_Cast is (not_a_Type, to_Integer, to_Boolean, to_Single, to_Double);
   --
   -- What a cast to a type does to a value, by the kind of the type: a name which is no type is 'not_a_Type'.

   function standard_Cast (type_Name : in String) return a_Cast;
   --
   -- That of a standard type of C ('float', 'unsigned long', 'size_t', ...).


   function real_Value_of (the_Expression : in String;
                           known_Reals    : in real_value_Maps  .Map;
                           known_Integers : in symbol_value_Maps.Map;
                           Namespace      : in unbounded_String;
                           Cast_to        : access function (type_Name : in String) return a_Cast := null) return a_Real;
   --
   -- A cast is applied as C applies it, to the operand which follows it ('(float) 1.0 / 3' is worked out in 'float'),
   -- in each of its forms: '(T) x', 'T (x)' and 'static_cast<T> (x)'. The kind of a type is given by 'Cast_to' (which
   -- may know the typedefs of the module), or by 'standard_Cast' where it is null or says 'not_a_Type'; a name in
   -- brackets ahead of an operand which neither knows is taken for a cast to a type which is not known, and leaves the
   -- value as it is.
   --
   -- The value of an expression which is a real number: of numbers, of the names of values which are known, of the
   -- signs, of '+', '-', '*' and '/', and of brackets. The casts are removed first. Each operation is worked out in
   -- the type in which C works it out (on a machine whose 'FLT_EVAL_METHOD' is 0, as x86-64 and AArch64 are): one of
   -- two integers in an integer, which truncates a division ('1 / 3' is 0, and '1.0 / 3' a third), one with a
   -- 'double' in 'double', and any other, which has a 'float' ('1.0f / 7', 'eps * 2' where 'eps' is a 'float'), in
   -- 'float'. 'Constraint_Error' is raised for an expression which cannot be worked out.


   function real_Image (the_Value : in Long_Float) return String;
   --
   -- The value as an Ada literal, of the fewest significant digits (15, 16 or 17) which give it back exactly: a
   -- constant of C's 'double' is so the same number in Ada.


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
