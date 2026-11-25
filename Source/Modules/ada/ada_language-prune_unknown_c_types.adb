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



   procedure keep_the_Storage (of_Class : in c_Type.view;
                               Index    : in Positive;
                               Words    : in Positive)
   --
   --  Makes the member at the index storage of so many addresses, as it is a smart pointer of the standard library
   --  whose type is not known. Such a member is most often the private pointer to the implementation of its class
   --  ('std::unique_ptr<FilePrivate> d;', in each class of TagLib), whose loss would leave the record smaller than
   --  the class, so that an object which Ada declares is too small for C++. The layout check of the class in the
   --  wrapper checks its size. (That the class is one which C++ constructs is noted by the class handler.)
   --
   is
      the_Member  : constant c_Variable.view := c_Variable.view (of_Class.Components (Index));
      the_Address : constant c_Type.view     := Self.name_Map_of_c_type.Element (+"void*");
   begin
      if the_Member.member_Name /= ""     -- A public member, which a program may have used.
      then
         c_Declarable.warn (of_Class, not_Bound,   "The member '" & the_Member.Name & "' of class '" & of_Class.Name
                                                 & "' is a smart pointer to a type which is not known, so it only reserves its storage.");
      end if;

      if not the_Member.is_ignored_Member
      then
         the_Member.Name              := the_Member.Name & "_storage";
         the_Member.is_ignored_Member := True;
      end if;

      the_Member.my_Type     := the_Address;
      the_Member.smart_Words := 0;     -- Which is done once: the prune step may pass over the classes again.

      for Each in 2 .. Words
      loop
         declare
            the_Word : constant c_Variable.view := c_Variable.new_c_Variable (the_Member.Name & "_" & ada.Strings.fixed.Trim (Integer'Image (Each),
                                                                                                                             ada.Strings.Left),
                                                                              the_Address);
         begin
            the_Word.is_ignored_Member := True;
            the_Word.Line              := the_Member.Line;
            of_Class.insert_Component (the_Word, Index => Index + Each - 1);
         end;
      end loop;
   end keep_the_Storage;

begin
   find_the_not_fully_known_Types;

   --  A member whose type is not known is left out, so that the class itself is still bound: its record then
   --  does not match the class, which is warned of, but its functions are there, and an object which C++ makes
   --  is used through a pointer as before. (A member which the interface file ignores only reserves its
   --  storage, and may well have been ignored because its type cannot be bound. Until 2026-11-23 only such a
   --  member was left out: any other took its class with it, and every function which used the class. LevelDB's
   --  'Iterator', which has a member of a private nested structure, was not bound at all.) A member which is a
   --  smart pointer of the standard library is kept as storage, as its size is known.
   --
   declare
      Dropped : Boolean := False;
      Warned  : c_Type.Vector;     -- The classes with virtual bases which have been warned of.
   begin
      for Each of Self.name_Map_of_c_type
      loop
         if Each.c_type_Kind = c_Class
         then
            for the_Base of Each.unknown_Bases
            loop
               c_Declarable.warn (Each, Layout,   "The base class '" & the_Base & "' of class '" & Each.Name & "' is not known, and is ignored."
                                                & " The layout of the record does not match that of the class."
                                                & Each.kind_is_a_Guess);
            end loop;

            Each.forget_unknown_Bases;     -- A class is in the map once for each of its names.

            --  A class with virtual functions and a base class which is inherited virtually is a tagged type. Where
            --  its parent is a base which it does not inherit virtually, GNAT lays the record out, and the virtual
            --  bases cannot be placed as C++ has them (see 'c_Type.virtual_Bases_are_followed'): each has storage of
            --  its size and alignment, so that the object is no smaller than the class.
            --
            if         Each.has_virtual_Bases
              and then Each.is_Virtual
              and then not Each.virtual_Bases_are_followed
              and then not Warned.contains (Each)
            then
               Warned.append (Each);
               c_Declarable.warn (Each, Layout,   "The class '" & Each.Name & "' has virtual functions, a base class which it does not"
                                                & " inherit virtually and one which it does, or a base which does: its record is a type extension which"
                                                & " GNAT lays out, with storage for each virtual base which is no less than C++ takes, and each is reached by"
                                                & " 'as_<base>' alone. The layout of its record does not match that of the class.");
               Each.lose_Layout;
            end if;

         end if;
      end loop;

      --  A member which is a smart pointer is kept as storage, in every class, before any member is left out: a class
      --  which has such a member is then known, and so is a member of another class which is of that class (jsoncpp's
      --  'Value' has one of its 'Comments', which has a 'std::unique_ptr'). Until 2026-11-24 the two were done in one
      --  pass over the classes, and such a member was left out where its class came first.
      --
      for Each of Self.name_Map_of_c_type
      loop
         if Each.c_type_Kind = c_Class
         then
            for i in reverse 1 .. Each.component_Count
            loop
               if         not_fully_known_Types.contains (Each.Components (i).my_Type)
                 and then Each.Components (i).my_Type /= Each     -- Not the class itself, where that is what is not known.
                 and then smart_Pointer_Words (to_String (Each.Components (i).my_Type.Name)) > 0
               then
                  keep_the_Storage (Each, i, smart_Pointer_Words (to_String (Each.Components (i).my_Type.Name)));
                  Dropped := True;     -- The class may now be known.

               --  One through a typedef, which the type may name as a class which is declared and never defined (the
               --  typedef of an instance of a template which SWIG is not shown).
               --
               elsif      c_Variable.view (Each.Components (i)).smart_Words > 0
                 and then Each.Components (i).my_Type.c_type_Kind /= c_Class
               then
                  keep_the_Storage (Each, i, c_Variable.view (Each.Components (i)).smart_Words);
                  Dropped := True;
               end if;
            end loop;
         end if;
      end loop;

      if Dropped
      then
         not_fully_known_Types.clear;
         find_the_not_fully_known_Types;
         Dropped := False;
      end if;

      for Each of Self.name_Map_of_c_type
      loop
         if Each.c_type_Kind = c_Class
         then
            for i in reverse 1 .. Each.component_Count
            loop
               if         not_fully_known_Types.contains (Each.Components (i).my_Type)
                 and then Each.Components (i).my_Type /= Each     -- Not the class itself, where that is what is not known.
               then
                  c_Declarable.warn (Each, Layout,   (if Each.Components (i).is_ignored_Member
                                                      then "The ignored member '" & Each.Components (i).Name & "' of class '" & Each.Name
                                                         & "' has a type which is not known, so its storage is left out."
                                                      else "The member '" & Each.Components (i).Name & "' of class '" & Each.Name
                                                         & "' has a type which is not known, so it is left out.")
                                                   & " The layout of the record does not match that of the class."
                                                   & Each.kind_is_a_Guess);
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
            if          (for all Letter of to_String (Each.Name) => Letter not in '*' | '[' | '&')     -- Not a pointer to, or an array of, such a type,
              and then smart_Pointer_Words (to_String (Each.Name)) = 0                            -- which would say the same again, nor a smart
            then                                                                                  -- pointer, of which a member is kept as storage.
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
