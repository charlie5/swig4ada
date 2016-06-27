

package body c_Variable
is
   use c_Type;


   ---------
   --  Forge
   --

   function construct (Name    : in unbounded_String;
                       of_Type : in c_Type.view) return Item'Class
   is
   begin
      return Item'(c_Declarable.item with
                   name             => Name,
                   my_type          => of_Type,
                   value            => <>,
                   is_static        => <>,
                   is_class_Pointer => <>,
                   is_Pointer       => <>,
                   array_bounds     => <>,
                   bit_field        => <>);
   end construct;



   function new_c_Variable (Name  : in unbounded_String;
                            of_Type  : in c_Type.view) return View
   is
   begin
      return new Item' (Item (construct (Name, of_Type)));
   end new_c_Variable;



   --------------
   --  Attributes
   --

   overriding
   function  required_Types (Self : access Item) return c_declarable.c_Type_views
   is
   begin
      return Self.my_Type.required_Types;
   end required_Types;



   overriding
   function  depended_on_Declarations (Self : access Item) return c_Declarable.views
   is
   begin
      return Self.my_Type.depended_on_Declarations;
   end depended_on_Declarations;



   overriding
   function  depends_on (Self : access Item;   a_Declarable : in     c_Declarable.view) return Boolean
   is
   begin
      return    Self.my_Type.all'Access = a_Declarable
        or else Self.my_Type.depends_on (a_Declarable);
   end depends_on;


   overriding
   function  depends_directly_on (Self : access Item;   a_Declarable : in     c_Declarable.view) return Boolean
   is
   begin
      return Self.my_Type.all'Access = a_Declarable;
   end depends_directly_on;



   overriding
   function  directly_depended_on_Declarations (Self : access Item) return c_Declarable.views
   is
   begin
      return (1 => Self.my_Type.all'Access);
   end directly_depended_on_Declarations;



   overriding
   function Name (Self : access Item) return ada.Strings.Unbounded.unbounded_String
   is
   begin
      return Self.Name;
   end Name;




   --  Operations
   --

   procedure verify (Self : access Item)
   is
      use ada.Strings;
   begin

      --        if        Self.my_Type.qualified_Name = "interfaces.c.c_Float"
      --          or else Self.my_Type.qualified_Name = "interfaces.c.Double"
      --          or else Self.my_Type.qualified_Name = "interfaces.c.long_Double"

      if        Self.my_Type.resolved_Type.qualified_Name = "interfaces.c.c_Float"
        or else Self.my_Type.resolved_Type.qualified_Name = "interfaces.c.Double"
        or else Self.my_Type.resolved_Type.qualified_Name = "interfaces.c.long_Double"
      then
         declare
            e_Index   : constant Natural := Index (Self.Value, "e");
            dot_Index :          Natural;
         begin
            if e_Index /= 0
            then
               dot_Index := Index (Self.Value, ".", from => e_Index, going => Backward);

               if dot_Index = 0
               then   -- No dot is found (ie an integer literal has been used instead of a float literal).
                  replace_Slice (Self.Value,  e_Index, e_index,  ".0e");      -- add in the missing '.0' to make it a float literal.
               end if;
            end if;
         end;

         declare
            e_Index   : constant Natural := Index (Self.Value, "E");
            dot_Index :          Natural;
         begin
            if e_Index /= 0
            then
               dot_Index := Index (Self.Value, ".", from => e_Index, going => Backward);

               if dot_Index = 0
               then   -- No dot is found (ie an integer literal has been used instead of a float literal).
                  replace_Slice (Self.Value,  e_Index, e_index,  ".0E");      -- Add in the missing '.0' to make it a float literal.
               end if;
            end if;
         end;
      end if;
   end verify;


end c_Variable;
