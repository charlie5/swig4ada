private
package ada_Language.c_expression_Resolver
--
-- Functions to reduce a C expression to a single value.
--
is
   function resolved_c_integer_Expression (Self            : access Item;
                                           the_Expression  : in     unbounded_String;
                                           known_Symbols   : in     ada_Language.symbol_value_maps.Map;
                                           Namespace       : in     unbounded_String) return gmp.discrete.Integer;

   function resolved_sizeof_Expression    (Self            : access Item;
                                           expression_Type : in     unbounded_String;
                                           known_Symbols   : in     symbol_value_maps.Map;
                                           Namespace       : in     unbounded_String) return Natural;
end ada_Language.c_expression_Resolver;
