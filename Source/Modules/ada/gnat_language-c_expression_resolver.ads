private
package gnat_Language.c_expression_Resolver
--
--
--
is
   --  Resolvers
   --

   function resolved_c_integer_Expression (Self            : access Item;
                                           the_Expression  : in     unbounded_String;
                                           known_Symbols   : in     gnat_Language.symbol_value_maps.Map;
                                           Namespace       : in     unbounded_String) return gmp.discrete.Integer;

   function resolved_sizeof_Expression    (Self            : access Item;
                                           expression_Type : in     unbounded_String;
                                           known_Symbols   : in     symbol_value_maps.Map;
                                           Namespace       : in     unbounded_String) return Natural;

end gnat_Language.c_expression_Resolver;
