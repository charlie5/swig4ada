separate (ada_Language)


overriding
function classHandler (Self : access Item;
                       N    : in Node_Pointer) return C.int
is
   the_Node       :          Node_Pointer renames N;
   node_Type      : constant SwigType_Pointer :=  SwigType_Pointer (get_Attribute (the_Node, "name"));   -- TODO: Use sym:name ?
   class_Name_Doh : constant SwigType_Pointer :=  SwigType_Pointer (get_Attribute (the_Node, "sym:name"));
   class_Name     : constant String           := +DOH_Pointer (class_Name_Doh);
   new_c_Class    :          c_Type.view;
   Status         :          C.int with Unreferenced;
   use type C.int;
   procedure make_the_Class
   --
   --  Makes the class of the C model, or completes one which has been declared ahead.
   --
   is
      use type c_Type.a_c_type_Kind;

      --  A template instance may have been used, ahead of its '%template', by its name with the default arguments
      --  of its template given ('Two<(int,long)>' for 'Two<(int)>').
      --
      its_Form  : constant String := +DOH_Pointer (node_Type);
      full_Form : constant String := +doh_Item (Swig_symbol_template_deftype (node_Type, null));

      Known_as  : constant String := (if    Self.swig_type_Map_of_c_type.contains (+its_Form)  then its_Form
                                      elsif Self.swig_type_Map_of_c_type.contains (+full_Form) then full_Form
                                      else  "");


      procedure name_after_the_Class (Prefix : in String;   Suffix : in String)
      --
      --  Names a type which was made with the class when it was not known (its pointer, say) after the class.
      --
      is
         Key      : constant unbounded_String := +(Prefix & Known_as);
         the_Name : constant unbounded_String := +(class_Name & Suffix);
      begin
         if Self.swig_type_Map_of_c_type.contains (Key)
         then
            Self.swig_type_Map_of_c_type.Element (Key).Name_is (the_Name);

            if not Self.name_Map_of_c_type.contains (the_Name)
            then
               Self.name_Map_of_c_type.insert (the_Name, Self.swig_type_Map_of_c_type.Element (Key));
            end if;
         end if;
      end name_after_the_Class;

   begin
      if         Known_as /= ""
        and then Self.swig_type_Map_of_c_type.Element (+Known_as).c_type_Kind = c_Type.Unknown
      then
         --  The class has been used before it is declared (a template instance ahead of its '%template', say), and
         --  was then made a type which is not known, with its pointer and array types. It becomes the class, under
         --  the name by which the class is bound, and the types which were made with it are named after it.
         --
         new_c_Class     := Self.swig_type_Map_of_c_type.Element (+Known_as);
         new_c_Class.all := c_Type.c_Class_construct (Namespace => Self.current_c_Namespace,
                                                      Name      => +class_Name);
         name_after_the_Class ("a.",   "[]");
         name_after_the_Class ("p.",   "*");
         name_after_the_Class ("a.p.", "*[]");
         name_after_the_Class ("p.p.", "**");

         if not Self.name_Map_of_c_type.contains (+class_Name)
         then
            Self.name_Map_of_c_type.insert (+class_Name, new_c_Class);
         end if;

      elsif Self.swig_type_Map_of_c_type.contains (+DOH_Pointer (node_Type))
      then   -- The class has been 'forward' declared.
         new_c_Class     := Self.swig_type_Map_of_c_type.Element (+DOH_Pointer (node_Type));      -- Get the 'opaque' c type.
         new_c_Class.all := c_Type.c_Class_construct (Namespace => Self.current_c_Namespace,      -- Morph it to a c class.
                                                      Name      => new_c_Class.Name);

         --  A class may be declared in an imported module and defined in the module which imports it. It remains
         --  a class of the module which declared it, whose own binding knows it only as an incomplete class, so
         --  the specification of its package is generated along with those of the module which defines it.
         --
         declare
            use type swig_Module.swig_Module_view;
         begin
            if         Self.current_Module = Self.Module_top'Access
              and then not Self.Module_top.C.new_c_Types.contains (new_c_Class)
            then
               Self.imported_Classes_defined_here.append (new_c_Class);
               new_c_Class.is_defined_in_main_Module;
            end if;
         end;
      else
         new_c_Class := c_Type.new_c_Class (Namespace => Self.current_c_Namespace,
                                            Name      => +class_Name);
         Self.register (new_c_Class,
                        doh_SwigType (node_Type));
      end if;
   end make_the_Class;



   procedure note_its_virtual_Members
   --
   --  Whether the class has a virtual function.
   --
   is
   begin
      --  Note whether the class declares a virtual member, as the member functions
      --  of a class in an imported module are not collected.
      --
      declare
         the_Child : Node_Pointer := first_Child (the_Node);
      begin
         while the_Child /= null
         loop
            if is_declared_Virtual (the_Child)
            then
               new_c_Class.has_virtual_Members;
               exit;
            end if;

            the_Child := next_Sibling (the_Child);
         end loop;
      end;
   end note_its_virtual_Members;



   procedure note_its_virtual_Destructor
   --
   --  Whether the destructor of the class is virtual.
   --
   is
   begin
      --  Likewise whether its destructor is virtual, which a class derived from it in another module needs to know.
      --
      declare
         the_Child : Node_Pointer := first_Child (the_Node);
      begin
         while the_Child /= null
         loop
            if         Attribute (the_Child, "nodeType") = "destructor"
              and then is_declared_Virtual (the_Child)
            then
               new_c_Class.has_virtual_Destructor;
               exit;
            end if;

            the_Child := next_Sibling (the_Child);
         end loop;
      end;
   end note_its_virtual_Destructor;



   procedure note_its_template_Forms
   --
   --  The two names of a template instance.
   --
   is
   begin
      --  Note the form which the name of a template instance takes when the default arguments of its template are given.
      --
      declare
         full_Form : constant String := +doh_Item (Swig_symbol_template_deftype (node_Type, null));
         its_Form  : constant String := +DOH_Pointer (node_Type);
      begin
         if         full_Form /= its_Form
           and then not Self.template_full_Forms.contains (full_Form)
         then
            Self.template_full_Forms .append (full_Form);
            Self.template_plain_Forms.append (its_Form);
         end if;
      end;
   end note_its_template_Forms;



   procedure note_its_nontrivial_Members
   --
   --  Whether C++ constructs the class: whether it is 'not trivial for the purposes of calls', as the Itanium C++
   --  ABI has it. Such a class is passed and returned through a hidden pointer, and cannot be bound as a plain
   --  record; any other is passed and returned as a C structure is, in registers where it fits. A class is so
   --  where its destructor, or its copy or move constructor, is not trivial, or where it can be neither copied
   --  nor moved. (A base class or a member which is so makes it so too, which 'c_Type.is_constructed_by_Cpp'
   --  follows.)
   --
   --  The class is told by its own declarations. The core's notes ('allocate:has_destructor' and
   --  'allocate:has_copy_constructor') are wider, for the languages which call through them: they count a
   --  destructor or a constructor which '%extend' adds, one which is defaulted ('= default', which is trivial),
   --  a constructor which takes a pointer to the class ('X (X*)') and an instance of a constructor template.
   --  A class which was taken for the other kind had a constructor which left the object of the caller as it
   --  was (found by the case 'template_ns' of upstream's suite, and then by './check_calls', 2026-11-23).
   --
   is
      the_Name   : constant String := Attribute (the_Node, "name");
      the_Child  : Node_Pointer    := first_Child (the_Node);

      declares_a_Destructor : Boolean := False;     -- One which is not defaulted.
      declares_a_Copy       : Boolean := False;     -- A copy constructor which is neither defaulted nor deleted.
      declares_a_Move       : Boolean := False;     -- A move constructor, likewise.
      has_a_usable_Copy     : Boolean := False;     -- One which is declared and not deleted, defaulted or not.
      has_a_usable_Move     : Boolean := False;
      deletes_its_Copy      : Boolean := False;
      deletes_its_Move      : Boolean := False;
   begin
      if not Self.in_cpp_Mode
      then
         return;     -- In C, a destructor can only be one which the interface file adds.
      end if;

      while the_Child /= null
      loop
         declare
            Kind   : constant String := Attribute (the_Child, "nodeType");
            Value  : constant String := Attribute (the_Child, "value");
         begin
            if         Kind = "destructor"
              and then Attribute (the_Child, "feature:extend") = ""
              and then get_Attribute (the_Node, "allocate:implicit_destructor") = null     -- Not one which the core adds.
              and then Value /= "delete"                             -- An object of such a class is never passed or returned by value.
              and then (        Value /= "default"
                        or else is_declared_Virtual (the_Child))     -- A virtual one is never trivial.
            then
               declares_a_Destructor := True;

            elsif      Kind = "constructor"
              and then get_Attribute (the_Child, "template")     = null
              and then Attribute (the_Child, "feature:extend")   = ""
              and then get_Attribute (the_Child, "parms")       /= null
              and then next_Sibling (Node_Pointer (get_Attribute (the_Child, "parms"))) = null
            then
               declare
                  the_Type : constant String  := Attribute (Node_Pointer (get_Attribute (the_Child, "parms")), "type");
                  is_Copy  : constant Boolean :=          Attribute (the_Child, "copy_constructor") /= ""
                                                 and then get_Attribute (the_Node, "allocate:has_copy_constructor") /= null     -- Not one which the core adds ('%copyctor').
                                                 and then the_Type'Length >= 2
                                                 and then the_Type (the_Type'First .. the_Type'First + 1) = "r.";
                  is_deleted_Copy : constant Boolean :=          Value = "delete"
                                                        and then the_Type in "r.q(const)." & the_Name | "r." & the_Name;
                  is_Move  : constant Boolean := the_Type in "z." & the_Name | "z.q(const)." & the_Name;
               begin
                  if is_Copy or is_deleted_Copy
                  then
                     if    Value = "delete"  then deletes_its_Copy  := True;
                     elsif Value = "default" then has_a_usable_Copy := True;
                     else                         has_a_usable_Copy := True;
                                                  declares_a_Copy   := True;
                     end if;

                  elsif is_Move
                  then
                     if    Value = "delete"  then deletes_its_Move  := True;
                     elsif Value = "default" then has_a_usable_Move := True;
                     else                         has_a_usable_Move := True;
                                                  declares_a_Move   := True;
                     end if;
                  end if;
               end;
            end if;
         end;

         the_Child := next_Sibling (the_Child);
      end loop;

      --  A class which deletes its copy constructor has no move constructor unless it declares one, and one which
      --  deletes its move constructor has no copy constructor unless it declares one: it can then be neither
      --  copied nor moved.
      --
      if        declares_a_Destructor
        or else declares_a_Copy
        or else declares_a_Move
        or else get_Attribute (the_Node, "has_virtual_base") /= null     -- Whose place the constructors of the class must set.
        or else (deletes_its_Copy and not has_a_usable_Move)
        or else (deletes_its_Move and not has_a_usable_Copy)
      then
         new_c_Class.has_nontrivial_Members;
      end if;
   end note_its_nontrivial_Members;



   procedure warn_of_what_is_not_followed
   --
   --  Virtual inheritance, and a nested class with no name.
   --
   is
   begin
      --  A base class which is inherited virtually, or a member whose type is a nested class with no name (which the
      --  core leaves out), changes the layout of the class in a way which is not followed here. The parser notes both.
      --
      if Attribute (the_Node, "has_virtual_base") /= ""
      then
         warn (Unsupported, "The class '" & class_Name & "' inherits a base class virtually, which is not supported."
                          & " The layout of its record does not match that of the class.");
         new_c_Class.lose_Layout;
      end if;

      if         Attribute (the_Node, "has_unnamed_member") /= ""
        and then (        get_Attribute (the_Node, "unnamed_nested") = null
                  or else not Self.in_cpp_Mode)
      then
         warn (Layout, "The class '" & class_Name & "' has a nested class or union with no name, whose members are left out."
                     & " The layout of its record does not match that of the class.");
         new_c_Class.lose_Layout;
      end if;
   end warn_of_what_is_not_followed;



   procedure name_it_for_the_layout_Checks
   --
   --  The name by which the wrapper file knows the class.
   --
   is
   begin
      --  Note the name by which the wrapper file knows the class, for a check of its layout.
      --
      declare
         the_Name : constant String := Attribute (the_Node, "name");
      begin
         if        the_Name = ""
           or else ada.Strings.fixed.Index (the_Name, "$unnamed") /= 0
           or else Attribute (the_Node, "access") in "private" | "protected"
         then
            null;     -- It cannot be named there.

         elsif Self.in_cpp_Mode
         then
            new_c_Class.layout_Name_is (+String'(+doh_Item (SwigType_namestr (SwigType_Pointer (get_Attribute (the_Node, "name"))))));

         elsif Attribute (the_Node, "tdname") /= ""
         then
            new_c_Class.layout_Name_is (+Attribute (the_Node, "tdname"));
         else
            new_c_Class.layout_Name_is (+(Attribute (the_Node, "kind") & " " & the_Name));
         end if;
      end;
   end name_it_for_the_layout_Checks;



   procedure note_whether_it_is_a_plain_Structure
   --
   --  Whether a class derived from it may use its unused tail.
   --
   is
   begin
      --  Note whether the class is more than a plain structure, as C++ lays one out. A class derived from one which
      --  is may have members in its unused tail, where one derived from a plain structure begins after the whole of it.
      --  (These are the cases in which GCC does so.)
      --
      if Self.in_cpp_Mode
      then
         declare
            the_Child : Node_Pointer := first_Child (the_Node);
         begin
            if         get_Attribute (the_Node, "allbases") /= null
              and then DohLen (doh_List (get_Attribute (the_Node, "allbases"))) > 0
            then
               new_c_Class.is_not_layout_Pod;     -- It has a base class.
            end if;

            if get_Attribute (the_Node, "allocate:has_copy_constructor") /= null
            then
               new_c_Class.is_not_layout_Pod;     -- It declares a copy constructor.
            end if;

            while the_Child /= null
            loop
               declare
                  the_Kind    : constant String  := Attribute (the_Child, "nodeType");
                  is_Extended : constant Boolean := Attribute (the_Child, "feature:extend") /= "";
                  is_Given    : constant Boolean := Attribute (the_Child, "value") not in "default" | "delete";     -- Not left to the compiler.
               begin
                  if    (         the_Kind = "constructor"                                -- One which the class declares: the core
                         and then is_Given                                                -- adds those which the compiler provides.
                         and then not is_Extended
                         and then Attribute (the_Child, "default_constructor") = ""
                         and then Attribute (the_Child, "copy_constructor")    = "")

                     or (         the_Kind = "destructor"                                 -- Likewise.
                         and then is_Given
                         and then not is_Extended
                         and then get_Attribute (the_Node, "allocate:has_destructor")      /= null
                         and then get_Attribute (the_Node, "allocate:implicit_destructor")  = null)

                     or (         the_Kind = "cdecl"                                      -- An assignment operator.
                         and then Attribute (the_Child, "name") = "operator ="
                         and then is_Given
                         and then not is_Extended)

                     or (         the_Kind = "cdecl"                                      -- A member variable which is not public,
                         and then Attribute (the_Child, "kind") = "variable"              -- or has an initial value.
                         and then Attribute (the_Child, "storage") not in "static" | "typedef" | "friend" | "extern"
                         and then not is_Extended
                         and then (        Attribute (the_Child, "access") in "private" | "protected"
                                   or else Attribute (the_Child, "hasvalue") /= ""))

                     or (         the_Kind = "cdecl"                                      -- A virtual function.
                         and then is_declared_Virtual (the_Child))
                  then
                     new_c_Class.is_not_layout_Pod;
                  end if;
               end;

               the_Child := next_Sibling (the_Child);
            end loop;
         end;
      end if;
   end note_whether_it_is_a_plain_Structure;



   procedure add_its_base_Classes
   --
   --  Gives the class each of its base classes which is known.
   --
   is
   begin
      -- Handle base classes.
      --
      declare
         base_List : constant doh_List   := doh_List (get_Attribute (the_Node, "allbases"));
         Length    : constant C.int      := DohLen (base_List);
         the_Item  :          DOH_Pointer;
      begin
         for i in 1 .. Length
         loop
            the_Item := DohGetitem (base_List, i - 1);

            declare
               base_Name : constant String := Attribute (Node_Pointer (the_Item), "sym:name");
            begin
               --  The base class is sought by its full name first, as its plain name may be that of a class
               --  of another namespace ('A::C::Foo', where 'A::B::Foo' is also declared).
               --
               if         Self.swig_type_Map_of_c_type.contains (+Attribute (Node_Pointer (the_Item), "name"))
                 and then Self.swig_type_Map_of_c_type.Element  (+Attribute (Node_Pointer (the_Item), "name")).c_type_Kind in c_Type.c_Class
               then
                  Self.current_c_Class.add_Base (Self.swig_type_Map_of_c_type.Element (+Attribute (Node_Pointer (the_Item), "name")));

               elsif Self.name_Map_of_c_type.contains (+base_Name)
               then
                  Self.current_c_Class.add_Base (Self.name_Map_of_c_type.Element (+base_Name));
               else   -- Such as a base class which is ignored, or is a template which has not been instantiated.
                  warn (Layout, "The base class '" & base_Name & "' of class '" & class_Name & "' is not known, and is ignored.");
                  new_c_Class.lose_Layout;
                  new_c_Class.has_an_unknown_Base;
               end if;
            end;
         end loop;

         --  A base class which SWIG was never shown ('std::exception', with no library file for it) is not among
         --  those which the core gives, though it is among those which the class names.
         --
         declare
            use type DOH_Pointer;

            function named_Bases (Access_of : in String) return C.int
            is
               the_Names : constant DOH_Pointer := DOH_Pointer (get_Attribute (the_Node, Access_of & "baselist"));
            begin
               return (if the_Names = null then 0 else DohLen (the_Names));
            end named_Bases;
         begin
            if named_Bases ("") + named_Bases ("protected") + named_Bases ("private") > (if DOH_Pointer (base_List) = null then 0 else Length)
            then
               new_c_Class.has_an_unknown_Base;
            end if;
         end;
      end;
   end add_its_base_Classes;



   procedure collect_the_Members_of_an_imported_Class
   --
   --  The core hands on no member of a class of an imported module, as nothing of that module is wrapped here.
   --  Its member variables are needed all the same: a class of this module which is derived from it, or has a
   --  member of it, is laid out by the place and size of each. They are taken from the nodes of the class, as
   --  'memberVariableHandler' takes one which the core hands on. So are its virtual functions (below). (Until 2026-11-23 such a class was taken to
   --  have a layout which is not known, and a class derived from it was laid out as GNAT would.)
   --
   --
   --  A node which the core has not handed on is as the parser left it: its type is that of the declaration
   --  ('int', of 'int *p;' and of 'int f ();'), and its declarator is apart ('p.', 'f().'). The core joins
   --  them before it calls a handler, and so it is done here, for the time of the call.
   --
   is
      use type DOH_Pointer;

      the_Member : Node_Pointer := first_Child (the_Node);
      Status     : C.int with Unreferenced;
      Unused     : C.int with Unreferenced;
   begin
      while the_Member /= null
      loop
         declare
            Storage     : constant String      := Attribute (the_Member, "storage");
            the_Type    : constant DOH_Pointer := DOH_Pointer (get_Attribute (the_Member, "type"));
            the_Decl    : constant DOH_Pointer := DOH_Pointer (get_Attribute (the_Member, "decl"));
            is_Function : constant Boolean     :=          the_Decl /= null
                                                  and then SwigType_isFunction (SwigType_Pointer (the_Decl)) /= 0;
         begin
            if         Attribute (the_Member, "nodeType") = "cdecl"
              and then Attribute (the_Member, "sym:name") /= ""
              and then Attribute (the_Member, "feature:ignore") = ""     -- An ignored member is added with the hidden ones.
              and then Attribute (the_Member, "feature:extend") = ""
              and then the_Type /= null
              and then ada.Strings.fixed.Index (Storage, "static")  = 0
              and then ada.Strings.fixed.Index (Storage, "typedef") = 0
              and then ada.Strings.fixed.Index (Storage, "friend")  = 0
              and then ada.Strings.fixed.Index (Storage, "extern")  = 0
            then
               declare
                  the_whole_Type : constant SwigType_Pointer := SwigType_Pointer (doh_Copy (the_Type));
               begin
                  if the_Decl /= null
                  then
                     DohIncref (the_Decl);                                   -- It is taken from the node below, and put back.
                     SwigType_push (the_whole_Type, String_Pointer (the_Decl));
                  end if;

                  DohIncref (the_Type);

                  if not is_Function
                  then
                     Unused := DohSetattr (DOH_Pointer (the_Member), DOH_Pointer (to_Doh ("type")), DOH_Pointer (the_whole_Type));
                     Unused := DohDelattr (DOH_Pointer (the_Member), DOH_Pointer (to_Doh ("decl")));

                     Status := Self.memberVariableHandler (the_Member);

                     if the_Decl /= null
                     then
                        Unused := DohSetattr (DOH_Pointer (the_Member), DOH_Pointer (to_Doh ("decl")), the_Decl);
                     end if;

                  elsif is_declared_Virtual (the_Member)
                  then
                     --  A virtual function is collected too, with no function of the wrapper: a function of this module
                     --  which overrides it must have its parameter and result types, which may be written otherwise in
                     --  C++ and be the same (see the transformer). The other member functions are not needed here.
                     --
                     if SwigType_isqualifier (the_whole_Type) /= 0
                     then
                        declare
                           Qualifier : constant String_Pointer := SwigType_pop (the_whole_Type) with Unreferenced;
                        begin
                           null;
                        end;
                     end if;

                     declare
                        the_Function : constant SwigType_Pointer := SwigType_pop_function (the_whole_Type) with Unreferenced;
                     begin
                        null;
                     end;

                     Unused := DohSetattr (DOH_Pointer (the_Member), DOH_Pointer (to_Doh ("type")), DOH_Pointer (the_whole_Type));
                     Status := Self.memberFunctionHandler (the_Member);
                  end if;

                  Unused := DohSetattr (DOH_Pointer (the_Member), DOH_Pointer (to_Doh ("type")), the_Type);
               end;
            end if;
         end;

         the_Member := next_Sibling (the_Member);
      end loop;
   end collect_the_Members_of_an_imported_Class;



begin
   indent_Log;
   dlog (+"");
   dlog (+ "classHandler - '"
        & class_Name
        & "'    node_Type '"
        & String' (+DOH_Pointer (node_Type))
        & "'");

   Self.current_c_Node := doh_Node (the_Node);
   locate (doh_Node (the_Node));

   make_the_Class;

   if String' (+DOH_Pointer (get_Attribute (the_Node, "kind"))) = "union"
   then
      new_c_Class.is_Union;
   end if;

   note_its_virtual_Members;
   note_its_virtual_Destructor;
   note_its_template_Forms;
   note_its_nontrivial_Members;
   warn_of_what_is_not_followed;
   name_it_for_the_layout_Checks;
   note_whether_it_is_a_plain_Structure;

   if Self.in_cpp_Mode
   then
      bind_unnamed_nested_Classes (Self, the_Node,
                                   outer_Name => class_Name,
                                   cpp_Name   => +doh_Item (SwigType_namestr (SwigType_Pointer (get_Attribute (the_Node, "name")))));
   end if;

   Self.c_class_Stack    .append (new_C_Class);
   Self.c_namespace_Stack.append (new_C_Class.nameSpace.all'Access);

   new_c_Class.nameSpace.models_cpp_class_Type (new_c_Class);

   --  old ...
   --
   freshen_current_module_Package (Self, the_Node);

   if Self.addSymbol (-class_Name, the_Node) = 0
   then
      return SWIG_ERROR;
   end if;

   add_its_base_Classes;

   Self.virtuals_placed_upto := null;
   Self.destructor_is_Bound  := False;

   Status := swigMod.Language.item (Self.all).classHandler (the_Node);     -- Process all class members.

   declare
      use type swig_Module.swig_Module_view;
   begin
      if Self.current_Module /= Self.Module_top'Access
      then
         collect_the_Members_of_an_imported_Class;
      end if;
   end;

   add_hidden_Virtuals (Self, before => null);                             -- Those which follow the last member function.

   add_hidden_Members (Self, before => null);                              -- Those which follow the last member.

   bind_constructors_of_abstract_Class (Self, the_Node);
   bind_other_base_Classes             (Self, the_Node);

   --  new ...
   --
   Self.c_class_Stack    .delete_Last;
   Self.c_namespace_Stack.delete_Last;

   Self.prior_c_Declaration := new_c_Class.all'Access;

   unindent_Log;
   return SWIG_OK;
end classHandler;
