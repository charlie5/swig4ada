package body ada_Type.elementary.an_access.to_subProgram
is
   use ada_subProgram;


   --  Forge
   --

   function new_Item (declaration_Package : access ada_Package.item'Class := null;
                      Name                : in     unbounded_String       := null_unbounded_String;
                      accessed_subProgram : in     ada_subProgram.view) return View
   is
   begin
      return new ada_Type.elementary.an_access.to_subProgram.item'(declaration_Package => declaration_Package,
                                                                   Name                => Name,
                                                                   accessed_subProgram => accessed_subProgram);
   end new_Item;




   --  Attributes
   --

   function accessed_subProgram (Self : in Item'Class) return ada_subProgram.view
   is
   begin
      return self.accessed_subProgram;
   end accessed_subProgram;



   overriding
   function depends_on (Self : access Item;   a_Type : in     ada_Type.view;
                                              Depth     : in     Natural) return Boolean
   is
   begin
--        log ("c_type.depends_on ~ Self.Name: '" & self.name & "'     a_Declarable.Name: '" & a_Declarable.Name & "'");

      return self.accessed_subProgram.depends_on (a_Type, Depth + 1);
   end depends_on;



   overriding
   function  depends_directly_on   (Self : access Item;   a_Type    : in     ada_Type.view;
                                                          Depth     : in     Natural) return Boolean
   is
   begin
--        log ("c_type.depends_on ~ Self.Name: '" & self.name & "'     a_Declarable.Name: '" & a_Declarable.Name & "'");

      return self.accessed_subProgram.depends_directly_on (a_Type, Depth + 1);
   end depends_directly_on;



   overriding
   function  depends_on             (Self : access Item;   a_Package : access ada_Package.item'Class;
                                                           Depth     : in     Natural) return Boolean
   is
   begin
      return self.accessed_subProgram.depends_on (a_Package, Depth + 1);
   end depends_on;



   overriding
   function  required_Types (Self : access Item) return ada_Type.views
   is
   begin
      return self.accessed_subProgram.required_Types;
   end required_Types;


   overriding
   function  context_required_Types (Self : access Item) return ada_Type.views
   is
   begin
      return self.accessed_subProgram.context_required_Types;
   end context_required_Types;



   overriding
   function resolved_Type (Self : access Item) return ada_Type.view   -- tbd: move this into 'Language' ... its app code !!
   is
   begin
      --  log ("'ultimate_base_Type' ~ c_type_Kind: '" & a_c_type_kind'Image (self.my.c_type_Kind) & "'");

--        if self.declaration_Package.Kind = header_Import then

      return Self.all'Access;

--        else
--           return Self.all'access;
--        end if;
   end resolved_Type;


end ada_Type.elementary.an_access.to_subProgram;
