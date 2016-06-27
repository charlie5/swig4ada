with
     ada_Type.elementary.scalar.real;


package body ada_Variable
is
   use ada_Type;


   --  Forge
   --

   function construct (the_Name  : in unbounded_String;
                       the_Type  : in ada_Type.view;
                       Value     : in unbounded_String) return item'Class
   is
   begin
      return Item'(name      => the_Name,
                   my_type   => the_Type,
                   value     => Value,

                   bit_field        => -1,
                   array_Bounds     => <>,
--                     is_constant      => False,
                   is_pointer       => False,
                   is_class_pointer => False
                  );
   end construct;



   function new_ada_Variable (the_Name : in unbounded_String;
                              the_Type : in ada_Type.view;
                              Value    : in unbounded_String := null_unbounded_String) return View
   is
   begin
      return new Item'(Item (construct (the_Name, the_Type, Value)));
   end new_ada_Variable;




   --  Attributes
   --

   function is_Constant (Self : in Item'Class) return Boolean
   is
   begin
      return Self.Value /= null_unbounded_String;
   end is_Constant;




   --  Operations
   --

   procedure verify (Self : access Item)
   is
      use ada.Strings;
   begin

--        if        Self.my_Type.qualified_Name = "interfaces.c.c_Float"
--          or else Self.my_Type.qualified_Name = "interfaces.c.Double"
--          or else Self.my_Type.qualified_Name = "interfaces.c.long_Double"

--        if        Self.my_Type.resolved_Type.qualified_Name = "interfaces.c.c_Float"
--          or else Self.my_Type.resolved_Type.qualified_Name = "interfaces.c.Double"
--          or else Self.my_Type.resolved_Type.qualified_Name = "interfaces.c.long_Double"  then
      if Self.my_Type.all in ada_Type.elementary.Scalar.real.item'Class
      then
         declare
            e_Index   : constant Natural := Index (Self.Value, "e");
            dot_Index :          Natural;
         begin
            if e_Index /= 0
            then
               dot_Index := Index (Self.Value, ".", from => e_Index, going => Backward);

               if dot_Index = 0
               then    -- No dot is found (ie an integer literal has been used instead of a float literal).
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
               then    -- No dot is found (ie an integer literal has been used instead of a float literal).
                  replace_Slice (Self.Value,  e_Index, e_index,  ".0E");      -- add in the missing '.0' to make it a float literal.
               end if;
            end if;
         end;
      end if;

   end verify;


end ada_Variable;


--     function Index_non_white (Self : in unbounded_String;   From          : Positive;
--                                                             going_Forward : Boolean)
--     is
--     begin
--        if going_Forward then
--           for J in From + 1 .. Length (Self) loop
--              if         Source (J) /= ' '
--                and then Source (J) /= latin_1.HT
--                and then Source (J) /= latin_1.CR
--                and then Source (J) /= latin_1.LF
--              then
--                 return J;
--              end if;
--           end loop;
--
--        else -- Going = Backward
--           for J in reverse Source'Range loop
--              if Source (J) /= ' ' then
--                 return J;
--              end if;
--           end loop;
--        end if;
--
--        --  Fall through if no match
--
--        return 0;
--     end Index_non_white;

