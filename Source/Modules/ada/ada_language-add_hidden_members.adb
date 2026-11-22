separate (ada_Language)


procedure add_hidden_Members (Self : access Item;   Before : in Node_Pointer;   of_Class : in Node_Pointer := null)
--
--  Three kinds of member take part in the layout of a class, but are not handed on by the core:
--
--    - A bit-field with no name ('unsigned : 2;'). The parser notes each one on the node of the class, by its line,
--      width and type. It becomes a component with no name of its own, which is given no declaration.
--
--    - A member variable which the interface file ignores ('%ignore Sensor::state;'). It becomes a component
--      named '<member>_storage', as without it every member which follows would be out of place.
--
--    - A member whose type is a nested class or union with no name, and the members of an anonymous union,
--      in C++ (see 'bind_unnamed_nested_Classes'). It becomes a component of the class made for that type.
--
--  Those of the class which come before the given member (or all of them, when it is null), and are not yet
--  components, are added to the current class. 'of_Class' is the node of that class, where the core does not
--  yet know of it.
--
is
   use type C.int;

   type a_Kind is (Ignored, Bits, Nested);

   type hidden_Member is
      record
         Kind     : a_Kind;
         Line     : Integer;
         the_Node : Node_Pointer;         -- The declaration of an ignored member, or the nested class.
         Width    : unbounded_String;
         the_Type : unbounded_String;
         Index    : Natural := 0;
      end record;

   package hidden_Vectors is new ada.Containers.Vectors (Positive, hidden_Member);

   function "<" (Left, Right : in hidden_Member) return Boolean
   is (Left.Line < Right.Line);

   package Sorting is new hidden_Vectors.generic_Sorting;

   the_Class   : constant Node_Pointer := (if of_Class /= null then of_Class else Self.getCurrentClass);
   before_Line : constant Integer      := (if Before = null then Integer'Last else Integer (DohGetline (DOH_Pointer (Before))));
   the_Hidden  :          hidden_Vectors.Vector;
   bits_Used   :          Natural      := 0;
   the_Child   :          Node_Pointer;
begin
   if the_Class = null
   then
      return;
   end if;

   --  The ignored members, in the order of their declaration, up to the given member.
   --
   the_Child := first_Child (the_Class);

   while the_Child /= null
     and then the_Child /= Before
   loop
      if         Attribute (the_Child, "nodeType") = "cdecl"
        and then Attribute (the_Child, "feature:ignore") /= ""
        and then Attribute (the_Child, "feature:extend")  = ""
        and then Attribute (the_Child, "ada:placed")      = ""
        and then Attribute (the_Child, "name")           /= ""
        and then Attribute (the_Child, "storage") not in "static" | "typedef" | "friend" | "extern"
        and then (        get_Attribute (the_Child, "decl") = null
                  or else SwigType_isfunction (SwigType_Pointer (get_Attribute (the_Child, "decl"))) = 0)
      then
         the_Hidden.append (hidden_Member'(Kind     => Ignored,
                                           Line     => Integer (DohGetline (DOH_Pointer (the_Child))),
                                           the_Node => the_Child,
                                           others   => <>));
      end if;

      the_Child := next_Sibling (the_Child);
   end loop;

   --  The bit-fields with no name, which are known by their lines alone.
   --
   if get_Attribute (the_Class, "anonymous_bitfields") /= null
   then
      for Each of Self.current_c_Class.Components
      loop
         if Each.is_anonymous_Bits
         then
            bits_Used := bits_Used + 1;
         end if;
      end loop;

      declare
         the_Fields : constant doh_List := doh_List (get_Attribute (the_Class, "anonymous_bitfields"));
      begin
         for i in C.int (bits_Used) + 1 .. DohLen (the_Fields)
         loop
            declare
               the_Field : constant String  := +DohGetitem (the_Fields, i - 1);     -- '<line>|<width>|<type>'
               Bar_1     : constant Natural := ada.Strings.fixed.Index (the_Field, "|");
               Bar_2     : constant Natural := ada.Strings.fixed.Index (the_Field, "|", from => Bar_1 + 1);
               the_Line  : constant Integer := Integer'Value (the_Field (the_Field'First .. Bar_1 - 1));
            begin
               if the_Line < before_Line
               then
                  the_Hidden.append (hidden_Member'(Kind     => Bits,
                                                    Line     => the_Line,
                                                    the_Node => null,
                                                    Width    => +the_Field (Bar_1 + 1 .. Bar_2 - 1),
                                                    the_Type => +the_Field (Bar_2 + 1 .. the_Field'Last),
                                                    Index    => Natural (i)));
               end if;
            end;
         end loop;
      end;
   end if;

   --  The nested classes with no name.
   --
   if get_Attribute (the_Class, "unnamed_nested") /= null
   then
      declare
         the_Nested : constant doh_List := doh_List (get_Attribute (the_Class, "unnamed_nested"));
      begin
         for i in 1 .. DohLen (the_Nested)
         loop
            declare
               the_Node : constant Node_Pointer := Node_Pointer (DohGetitem (the_Nested, i - 1));
               the_Line : constant Integer      := Integer'Value (Attribute (the_Node, "unnamed_nested:line"));
            begin
               if         the_Line < before_Line
                 and then Attribute (the_Node, "ada:placed") = ""
               then
                  the_Hidden.append (hidden_Member'(Kind     => Nested,
                                                    Line     => the_Line,
                                                    the_Node => the_Node,
                                                    Index    => Natural (i),
                                                    others   => <>));
               end if;
            end;
         end loop;
      end;
   end if;

   Sorting.sort (the_Hidden);

   for the_Member of the_Hidden
   loop
      case the_Member.Kind
      is
         when Bits =>
            declare
               new_Variable : constant c_Variable.view
                 := c_Variable.new_c_Variable (+("anonymous_bits_" & ada.Strings.fixed.Trim (Natural'Image (the_Member.Index), ada.Strings.Left)),
                                               Self.demand_c_Type_for (doh_swigType (to_Doh (to_String (the_Member.the_Type)))));
            begin
               new_Variable.is_anonymous_Bits := True;
               new_Variable.bit_Field         := Integer (Value (resolved_c_integer_Expression (Self, the_Member.Width,
                                                                                                      Self.integer_symbol_value_Map,
                                                                                                      Self.current_class_namespace_Prefix)));
               Self.current_c_Class.add_Component (new_Variable);
            end;

         when Ignored =>
            declare
               new_Variable : constant c_Variable.view
                 := member_Variable (Self, the_Member.the_Node, Attribute (the_Member.the_Node, "name") & "_storage");
            begin
               new_Variable.is_ignored_Member := True;
               set_Attribute (doh_Node (the_Member.the_Node), "ada:placed", "1");
               Self.current_c_Class.add_Component (new_Variable);
            end;

         when Nested =>
            declare
               the_type_Name : constant String   := Attribute (the_Member.the_Node, "ada:type_name");
               the_Declared  : constant doh_List := doh_List (get_Attribute (the_Member.the_Node, "unnamed_nested:members"));
               new_Variable  :          c_Variable.view;
            begin
               set_Attribute (doh_Node (the_Member.the_Node), "ada:placed", "1");

               if        the_type_Name = ""
                 or else not Self.name_Map_of_c_type.contains (+the_type_Name)
               then
                  Self.current_c_Class.lose_Layout;     -- The class for it could not be made.

               elsif DohLen (the_Declared) = 0
               then   -- An anonymous union or structure, whose members C++ takes as members of the outer class.
                  new_Variable := c_Variable.new_c_Variable (+("anonymous_" & ada.Strings.fixed.Trim (Natural'Image (the_Member.Index), ada.Strings.Left)),
                                                             Self.name_Map_of_c_type.Element (+the_type_Name));
                  Self.current_c_Class.add_Component (new_Variable);
               else
                  for i in 1 .. DohLen (the_Declared)
                  loop
                     declare
                        the_Entry : constant String  := +DohGetitem (the_Declared, i - 1);     -- '<name>|<declarator>'
                        the_Bar   : constant Natural := ada.Strings.fixed.Index (the_Entry, "|");
                        the_Name  : constant String  := the_Entry (the_Entry'First .. the_Bar - 1);
                        the_Decl  : constant String  := the_Entry (the_Bar + 1 .. the_Entry'Last);
                     begin
                        if the_Decl = ""
                        then
                           new_Variable := c_Variable.new_c_Variable (+the_Name, Self.name_Map_of_c_type.Element (+the_type_Name));
                           new_Variable.member_Name := +the_Name;
                           Self.current_c_Class.add_Component (new_Variable);

                        elsif      the_Decl = "p."
                          and then Self.name_Map_of_c_type.contains (+(the_type_Name & "*"))
                        then
                           new_Variable := c_Variable.new_c_Variable (+the_Name, Self.name_Map_of_c_type.Element (+(the_type_Name & "*")));
                           new_Variable.is_class_Pointer := True;
                           new_Variable.member_Name      := +the_Name;
                           Self.current_c_Class.add_Component (new_Variable);

                        elsif      the_Decl'Length > 2
                          and then the_Decl (the_Decl'First .. the_Decl'First + 1) = "a("
                          and then ada.Strings.fixed.Index (the_Decl, "p.") = 0
                          and then Self.name_Map_of_c_type.contains (+(the_type_Name & "[]"))
                        then
                           new_Variable := c_Variable.new_c_Variable (+the_Name, Self.name_Map_of_c_type.Element (+(the_type_Name & "[]")));
                           Self.add_array_Bounds_to (new_Variable, doh_SwigType (to_Doh (the_Decl & the_type_Name)));
                           new_Variable.member_Name := +the_Name;
                           Self.current_c_Class.add_Component (new_Variable);
                        else
                           warn (Layout, "Unable to bind the member '" & the_Name & "' of class '" & Self.current_c_Class.Name
                                       & "', whose type is a nested class with no name. The layout of the record does not match that of the class.");
                           Self.current_c_Class.lose_Layout;
                        end if;
                     end;
                  end loop;
               end if;
            end;
      end case;
   end loop;
end add_hidden_Members;
