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
      return Self.accessed_subProgram;
   end accessed_subProgram;


   overriding
   function depends_on (Self : access Item;   a_Type : in ada_Type.view;
                                              Depth  : in Natural) return Boolean
   is
   begin
      return Self.accessed_subProgram.depends_on (a_Type, Depth + 1);
   end depends_on;


   overriding
   function depends_directly_on (Self : access Item;   a_Type : in ada_Type.view;
                                                        Depth : in Natural) return Boolean
   is
   begin
      return Self.accessed_subProgram.depends_directly_on (a_Type, Depth + 1);
   end depends_directly_on;


   overriding
   function depends_on (Self : access Item;   a_Package : access ada_Package.item'Class;
                                              Depth     : in     Natural) return Boolean
   is
   begin
      return Self.accessed_subProgram.depends_on (a_Package, Depth + 1);
   end depends_on;


   overriding
   function required_Types (Self : access Item) return ada_Type.views
   is
   begin
      return Self.accessed_subProgram.required_Types;
   end required_Types;


   overriding
   function  context_required_Types (Self : access Item) return ada_Type.views
   is
   begin
      return Self.accessed_subProgram.context_required_Types;
   end context_required_Types;


   overriding
   function resolved_Type (Self : access Item) return ada_Type.view
   is
   begin
      return Self.all'Access;
   end resolved_Type;


end ada_Type.elementary.an_access.to_subProgram;
