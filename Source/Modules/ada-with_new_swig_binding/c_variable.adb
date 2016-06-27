with c_Type; use c_Type;


package body c_Variable
is


   function construct (Name  : in     unbounded_String;
                       of_Type  : in c_Type.view) return item'Class
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
      return new Item'(Item (construct (Name, of_Type)));
   end new_c_Variable;



   --  Attributes
   --

   overriding
   function  required_Types (Self : access Item) return c_declarable.c_Type_views
   is
   begin
      return self.my_Type.required_Types;
   end required_Types;



   overriding
   function  depended_on_Declarations (Self : access Item) return c_Declarable.views
   is
   begin
      return self.my_Type.depended_on_Declarations;
   end depended_on_Declarations;



   overriding
   function  depends_on (Self : access Item;   a_Declarable : in     c_Declarable.view) return Boolean
   is
   begin
      return    self.my_Type.all'Access = a_Declarable
        or else self.my_Type.depends_on (a_Declarable);
   end depends_on;


   overriding
   function  depends_directly_on (Self : access Item;   a_Declarable : in     c_Declarable.view) return Boolean
   is
   begin
      return self.my_Type.all'Access = a_Declarable;
   end depends_directly_on;



   overriding
   function  directly_depended_on_Declarations (Self : access Item) return c_Declarable.views
   is
   begin
      return (1 => self.my_Type.all'Access);
   end directly_depended_on_Declarations;



   overriding
   function Name (Self : access Item) return ada.Strings.Unbounded.unbounded_String
   is
   begin
      return self.Name;
   end Name;




   --  Operations
   --

   procedure verify (Self : access Item)
   is
      use ada.Strings;
   begin

      --        if        self.my_Type.qualified_Name = "interfaces.c.c_Float"
      --          or else self.my_Type.qualified_Name = "interfaces.c.Double"
      --          or else self.my_Type.qualified_Name = "interfaces.c.long_Double"

      if        self.my_Type.resolved_Type.qualified_Name = "interfaces.c.c_Float"
        or else self.my_Type.resolved_Type.qualified_Name = "interfaces.c.Double"
        or else self.my_Type.resolved_Type.qualified_Name = "interfaces.c.long_Double"
      then
         declare
            e_Index   : constant Natural := Index (self.Value, "e");
            dot_Index : Natural;
         begin
            if e_Index /= 0 then
               dot_Index := Index (self.Value, ".", from => e_Index, going => Backward);

               if dot_Index = 0 then     -- no dot is found (ie an integer literal has been used instead of a float literal)
                  replace_Slice (self.Value,  e_Index, e_index,  ".0e");      -- add in the missing '.0' to make it a float literal.
               end if;
            end if;
         end;

         declare
            e_Index   : constant Natural := Index (self.Value, "E");
            dot_Index : Natural;
         begin
            if e_Index /= 0 then
               dot_Index := Index (self.Value, ".", from => e_Index, going => Backward);

               if dot_Index = 0 then     -- no dot is found (ie an integer literal has been used instead of a float literal)
                  replace_Slice (self.Value,  e_Index, e_index,  ".0E");      -- add in the missing '.0' to make it a float literal.
               end if;
            end if;
         end;
      end if;

   end verify;


end c_Variable;
