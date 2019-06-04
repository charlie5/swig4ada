package body swig_Module
is

   procedure define (Self : in out Item;   Name                 : in unbounded_String;
                                           the_standard_Package : in ada_Package.view)
   is
      use ada_Package;
   begin
      Self.Name                         := Name;
      Self.Ada.Package_top              := new_ada_Package (to_String (Name),     the_standard_Package);
      Self.Ada.Package_binding          := new_ada_Package ("Binding",            Self.Ada.Package_top);
      Self.Ada.Package_pointers         := new_ada_Package ("Pointers",           Self.Ada.Package_top);
      Self.Ada.Package_pointer_pointers := new_ada_Package ("pointer_Pointers",   Self.Ada.Package_top);

      Self.Ada.Package_top.is_global_Namespace;
   end define;

end swig_Module;
