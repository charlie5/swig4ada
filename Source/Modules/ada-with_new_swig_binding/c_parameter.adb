with ada.Text_IO;   use ada.Text_IO;

package body c_Parameter
is

   --  Forge
   --

   function construct (the_Name : in unbounded_String;
                       the_Type : in c_Type.view) return item'Class
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



   function new_c_Parameter (the_Name : in unbounded_String;
                                the_Type : in c_Type.view) return View
   is
   begin
      return new Item'(Item (construct (the_Name, the_Type)));
   end new_c_Parameter;







   --  Attributes
   --

   function required_Types (Self : in c_Parameter.Vector) return c_Declarable.c_Type_views
   is
      use Vectors;

      the_Types : c_Declarable.c_Type_views (1 .. Natural (Length (Self)));
   begin

      for Each in 1 .. Natural (Length (Self)) loop

--           the_Types (Each) := Element (Self,  Each).my_Type; -- .context_required_Type;


         the_Types (Each) := Element (Self,  Each).my_Type.resolved_Type;
         --  the_Types (Each) := Element (Self,  Each).my_Type;
      end loop;


      return the_Types;
   end required_Types;



   function depended_on_Declarations (Self : in c_Parameter.Vector) return c_Declarable.views
   is
      use Vectors;

      the_Declarations : c_Declarable.views (1 .. 500);
      Count            : Natural := 0;
   begin

      for Each in 1 .. Natural (Length (Self)) loop
         declare
            my_type_Dependencies : constant c_Declarable.views := Element (Self,  Each).my_Type.depended_on_Declarations;
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
      for Each in 1 .. Natural (Length (Self)) loop
         if        Element (Self,  Each).my_Type.all'Access = the_Declarable
           or else Element (Self,  Each).my_Type.depends_on (the_Declarable)
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
      for Each in 1 .. Natural (Length (Self)) loop
         if Element (Self,  Each).my_Type.all'Access = the_Declarable then
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
      put_Line ("c_parameter.directly_depended_on_Declarations: KKKKKKKKK");

      for Each in the_Declarations'Range loop
         the_Declarations (Each) := Element (Self,  Each).my_Type.all'Access;
         put_Line ("c_parameter.directly_depended_on_Declarations:  the_Declarations (Each): '" & to_String (the_Declarations (Each).Name) & "'");
      end loop;


      return the_Declarations;
   end directly_depended_on_Declarations;





--
--  String*
--  ada_Parameter::
--  Name ()
--  {
--    if (is_reserved_Word (_Name))
--    {
--      String*        the_Name = Copy (_Name);
--
--      Printv (the_Name,  "_arg", NIL);
--
--      return the_Name;
--    }
--
--
--    char        first_Char = *(Char (_Name));
--
--    if (first_Char == '_')
--      Delslice (_Name, 0, 1);
--
--
--    return _Name;
--  }


end c_Parameter;
