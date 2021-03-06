with
     doh_Support;


package swigg.Utility
is
   use ada.Strings.unbounded,
       doh_Support;

   procedure replace_integer_with_float            (Self : in out Text);
   procedure strip_c_integer_literal_qualifiers_in (Self : in out Text);
   procedure strip_enum_Prefix                     (Self : in out Text);
   procedure strip_leading_global_namespace_Prefix (Self : in out Text);

   function  strip_array_Bounds   (Self : in     doh_SwigType) return Text;
   function  trim_Namespace       (Self : in     Text)         return Text;
   procedure strip_all_qualifiers (Self : in out Text);
   procedure strip_all_qualifiers (Self : in out doh_SwigType);

   function  resolved_c_left_shift_Operator (Self : in Text) return Integer;

   function  sibling_module_Name_of (the_Node : in doh_Node) return String;
   function  owner_module_Name_of   (the_Node : in doh_Node) return String;

end swigg.Utility;
