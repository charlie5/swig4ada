with
     c_Expressions;


package body ada_Language.c_expression_Resolver
is

   function resolved_c_integer_Expression (Self            : access Item;
                                           the_Expression  : in     unbounded_String;
                                           known_Symbols   : in     ada_Language.symbol_value_maps.Map;
                                           Namespace       : in     unbounded_String) return gmp.discrete.Integer
   is
      pragma Unreferenced (Self);
   begin
      return c_Expressions.Value_of (the_Expression, known_Symbols, Namespace);
   end resolved_c_integer_Expression;



   function resolved_sizeof_Expression (Self            : access Item;
                                        expression_Type : in     unbounded_String;
                                        known_Symbols   : in     symbol_value_maps.Map;
                                        Namespace       : in     unbounded_String) return Natural
   is
      pragma Unreferenced (Self);
   begin
      return c_Expressions.sizeof_Value (expression_Type, known_Symbols, Namespace);
   end resolved_sizeof_Expression;

end ada_Language.c_expression_Resolver;
