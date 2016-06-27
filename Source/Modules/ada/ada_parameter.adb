package body ada_Parameter
is

   --  Forge
   --

   function construct (the_Name : in unbounded_String;
                       the_Type : in ada_Type.view) return item'Class
   is
   begin
      return Item'(name      => the_Name,
                   my_type   => the_Type,

                   is_Pointer       => False,
                   link_symbol_Code => <>
                  );

--        return Item'(a_name_type_Pair.item (a_name_type_Pair.construct (the_Name, the_Type)) with
--                     is_Pointer       => False,
--                     link_symbol_Code => null_unbounded_String);
   end construct;



   function new_ada_Parameter (the_Name : in unbounded_String;
                                the_Type : in ada_Type.view) return View
   is
   begin
      return new Item'(Item (construct (the_Name, the_Type)));
   end new_ada_Parameter;






   --  Attributes
   --

   function required_Types (Self : in ada_Parameter.Vector) return ada_Type.views
   is
      use Vectors;
      the_Types : ada_Type.views (1 .. Natural (Length (Self)));
   begin
      for Each in 1 .. Natural (Length (Self))
      loop
         the_Types (Each) := Element (Self,  Each).my_Type;   -- .resolved_Type;
      end loop;

      return the_Types;
   end required_Types;



   function context_required_Types (Self : in ada_Parameter.Vector) return ada_Type.views
   is
      use Vectors;
      the_Types : ada_Type.views (1 .. Natural (Length (Self)));
   begin
      for Each in 1 .. Natural (Length (Self))
      loop
         the_Types (Each) := Element (Self,  Each).my_Type;  -- .resolved_Type;
      end loop;

      return the_Types;
   end context_required_Types;



   function depends_on (Self : in ada_Parameter.Vector;   the_Type  : in     ada_Type.view;
                                                          Depth     : in     Natural)          return Boolean
   is
      use Vectors;
   begin
      for Each in 1 .. Natural (Length (Self))
      loop
         if        Element (Self,  Each).my_Type.all'Access = the_Type
           or else Element (Self,  Each).my_Type.depends_on (the_Type, Depth + 1)
         then
            return True;
         end if;
      end loop;

      return False;
   end depends_on;



   function depends_directly_on (Self : in ada_Parameter.Vector;   the_Type  : in     ada_Type.view;
                                                                   Depth     : in     Natural) return Boolean
   is
      use Vectors;
   begin
      for Each in 1 .. Natural (Length (Self))
      loop
         if        Element (Self,  Each).my_Type.all'Access = the_Type
           or else Element (Self,  Each).my_Type.depends_directly_on (the_Type, Depth + 1)
         then
            return True;
         end if;
      end loop;

      return False;
   end depends_directly_on;



   function depends_on (Self : in ada_Parameter.Vector;   a_Package : access ada_Package.item'Class;
                                                          Depth     : in     Natural)                return Boolean
   is
      use Vectors;
   begin
      for Each in 1 .. Natural (Length (Self))
      loop
         if        Element (Self,  Each).my_Type.resolved_Type.declaration_Package = a_Package
           or else Element (Self,  Each).my_Type.resolved_Type.depends_on (a_Package, Depth + 1)
         then
            return True;
         end if;
      end loop;

      return False;
   end depends_on;


end ada_Parameter;
