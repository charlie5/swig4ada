package body c_Parameter
is
   --  Forge
   --

   function construct (the_Name : in unbounded_String;
                       the_Type : in c_Type.view) return Item'Class
   is
   begin
      return Item' (name    => the_Name,
                    my_type => the_Type,

                    is_Pointer       => False,
                    link_symbol_Code => <>);
   end construct;



   function new_c_Parameter (the_Name : in unbounded_String;
                             the_Type : in c_Type.view) return View
   is
   begin
      return new Item' (Item (construct (the_Name, the_Type)));
   end new_c_Parameter;


   --  Attributes
   --

   function required_Types (Self : in c_Parameter.Vector) return c_Declarable.c_Type_views
   is
      use Vectors;
      the_Types : c_Declarable.c_Type_views (1 .. Natural (Length (Self)));
   begin
      for Each in 1 .. Natural (Length (Self))
      loop
         the_Types (Each) := Element (Self,  Each).my_Type.resolved_Type;
      end loop;

      return the_Types;
   end required_Types;



   function depended_on_Declarations (Self : in c_Parameter.Vector) return c_Declarable.views
   is
      use Vectors;
      the_Declarations : c_Declarable.views (1 .. 500);
      Count            : Natural := 0;
   begin
      for Each in 1 .. Natural (Length (Self))
      loop
         declare
            my_type_Dependencies : constant c_Declarable.views := Element (Self, Each).my_Type.depended_on_Declarations;
         begin
            the_Declarations (Count + 1 .. Count + my_type_Dependencies'Length) := my_type_Dependencies;
            Count := Count + my_type_Dependencies'Length;
         end;
      end loop;

      return the_Declarations (1 .. Count);
   end depended_on_Declarations;



   function depends_on (Self : in c_Parameter.Vector;   the_Declarable : in c_Declarable.view) return Boolean
   is
      use Vectors;
   begin
      for Each in 1 .. Natural (Length (Self))
      loop
         if        Element (Self, Each).my_Type.all'Access = the_Declarable
           or else Element (Self, Each).my_Type.depends_on (the_Declarable)
         then
            return True;
         end if;
      end loop;

      return False;
   end depends_on;



   function depends_directly_on (Self : in c_Parameter.Vector;   the_Declarable : in c_Declarable.view) return Boolean
   is
      use Vectors;
   begin
      for Each in 1 .. Natural (Length (Self))
      loop
         if Element (Self, Each).my_Type.all'Access = the_Declarable
         then
            return True;
         end if;
      end loop;

      return False;
   end depends_directly_on;



   function directly_depended_on_Declarations (Self : in c_Parameter.Vector) return c_Declarable.views
   is
      use Vectors;
      the_Declarations : c_Declarable.views (1 .. Natural (Length (Self)));
   begin
      for Each in the_Declarations'Range
      loop
         the_Declarations (Each) := Element (Self, Each).my_Type.all'Access;
      end loop;

      return the_Declarations;
   end directly_depended_on_Declarations;

end c_Parameter;
