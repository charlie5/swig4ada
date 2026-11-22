separate (ada_Language)


procedure prune_unknown_C_Types (Self : in out Item)
is
   use c_Type;
   not_fully_known_Types : c_Type.Vector;
   Count                 : Natural := 0;


   procedure find_the_not_fully_known_Types
   is
   begin
      -- Build a list of all types which are unknown or which depend on types that are not fully known.
      --
      for Each of Self.name_Map_of_c_type
      loop
         if Each.c_type_Kind = Unknown
         then
            Count := Count + 1;
            not_fully_known_Types.append (Each);
         end if;
      end loop;

      while Count /= 0
      loop
         Count := 0;

         for Each of Self.name_Map_of_c_type
         loop
            if not not_fully_known_Types.contains (Each)
            then
               for i in 1 .. Integer (not_fully_known_Types.Length)
               loop
                  if Each.depends_directly_on (not_fully_known_Types.Element (i).all'Access)
                  then
                     Count := Count + 1;
                     not_fully_known_Types.append (Each);
                  end if;
               end loop;
            end if;
         end loop;
      end loop;
   end find_the_not_fully_known_Types;

begin
   find_the_not_fully_known_Types;

   --  A member which the interface file ignores only reserves its storage. Where its type is not known, the
   --  storage is given up, so that the class itself is still bound (the member may well have been ignored
   --  because its type cannot be bound).
   --
   declare
      Dropped : Boolean := False;
   begin
      for Each of Self.name_Map_of_c_type
      loop
         if Each.c_type_Kind = c_Class
         then
            for i in reverse 1 .. Each.component_Count
            loop
               if         Each.Components (i).is_ignored_Member
                 and then not_fully_known_Types.contains (Each.Components (i).my_Type)
               then
                  c_Declarable.warn (Each, Layout, "The ignored member '" & Each.Components (i).Name & "' of class '" & Each.Name
                                                 & "' has a type which is not known, so its storage is left out. The layout of the record does not match that of the class.");
                  Each.lose_Layout;
                  Each.remove_Component (i);
                  Dropped := True;
               end if;
            end loop;
         end if;
      end loop;

      if Dropped
      then
         not_fully_known_Types.clear;
         find_the_not_fully_known_Types;
      end if;
   end;

   -- Rid not fully known C types from top module.
   --
   log (+"");
   log (+"Pruning out unknown C types.");

   for Each of not_fully_known_Types
   loop
      declare
         use c_Type.Vectors;
         i : constant Natural := Self.Module_top.C.new_c_Types.find_Index (Each);
      begin
         if i /= no_Index
         then
            if (for all Letter of to_String (Each.Name) => Letter not in '*' | '[' | '&')     -- Not a pointer to, or an array of, such a type,
            then                                                                          -- which would say the same again.
               c_Declarable.warn (Each, not_Bound, "Unable to bind the type '" & to_String (Each.Name) & "', which is not known.");
            else
               dlog ("Unable to bind unknown C type: " & Each.Name);
            end if;

            Self.Module_top.C.new_c_Types.delete (i);
         end if;
      end;
   end loop;

   -- Rid variables from top module with not fully known C types.
   --
   log (+"");
   log (+"Pruning out C variables.");

   for i in reverse 1 .. Self.Module_top.C.new_c_Variables.last_Index
   loop
      declare
         Variable      : constant c_Variable.view := Self.Module_top.C.new_c_Variables.Element (i);
         variable_Type : constant c_Type    .view := Variable.my_Type;
      begin
         if not_fully_known_Types.contains (variable_Type)
         then
            c_Declarable.warn (Variable, not_Bound, "Unable to bind the variable '" & to_String (Variable.Name) & "', as its type '" & to_String (variable_Type.Name) & "' is not known.");
            Self.Module_top.C.new_c_Variables.delete (i);
         end if;
      end;
   end loop;

   -- Rid functions from top module whose parameters or return type are not fully known C types.
   --
   log (+"");
   log (+"Pruning out C functions.");

   for i in reverse 1 .. Self.Module_top.C.new_c_Functions.last_Index
   loop
      declare
         the_Function  : constant c_Function.view := Self.Module_top.C.new_c_Functions.Element (i);
         return_Type   : constant c_Type    .view := the_Function.return_Type;
      begin
         if not_fully_known_Types.contains (return_Type)
         then
            c_Declarable.warn (the_Function, not_Bound,   "Unable to bind the function '" & to_String (the_Function.Name) & "', as its result type '"
                                                        & to_String (return_Type.Name) & "' is not known.");
            Self.Module_top.C.new_c_Functions.delete (i);
         else
            for Each of the_Function.Parameters
            loop
               if not_fully_known_Types.contains (Each.my_Type)
               then
                  c_Declarable.warn (the_Function, not_Bound,   "Unable to bind the function '" & to_String (the_Function.Name) & "', as the type '"
                                                              & to_String (Each.my_Type.Name) & "' of its parameter '" & to_String (Each.Name) & "' is not known.");
                  Self.Module_top.C.new_c_Functions.delete (i);
                  exit;     -- The function is gone: a second such parameter would take the function which is now in its place.
               end if;
            end loop;
         end if;
      end;
   end loop;
end prune_unknown_C_Types;
