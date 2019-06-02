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
      return Item' (Name      => the_Name,
                    my_Type   => the_Type,
                    Value     => Value,

                    bit_Field        => -1,
                    array_Bounds     => <>,
                    is_Pointer       => False,
                    is_class_pointer => False);
   end construct;



   function new_ada_Variable (the_Name : in unbounded_String;
                              the_Type : in ada_Type.view;
                              Value    : in unbounded_String := null_unbounded_String) return View
   is
   begin
      return new Item' (Item (construct (the_Name, the_Type, Value)));
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
                  replace_Slice (Self.Value,  e_Index, e_index,  ".0e");   -- Add in the missing '.0' to make it a float literal.
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
                  replace_Slice (Self.Value,  e_Index, e_index,  ".0E");   -- Add in the missing '.0' to make it a float literal.
               end if;
            end if;
         end;
      end if;
   end verify;

end ada_Variable;
