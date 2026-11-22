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

   if Self.swig_type_Map_of_c_type.contains (+DOH_Pointer (node_Type))
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

   if String' (+DOH_Pointer (get_Attribute (the_Node, "kind"))) = "union"
   then
      new_c_Class.is_Union;
   end if;

   --  Note whether the class declares a virtual member, as the member functions
   --  of a class in an imported module are not collected.
   --
   declare
      the_Child : Node_Pointer := first_Child (the_Node);
   begin
      while the_Child /= null
      loop
         if check_Attribute (the_Child, "storage", "virtual")
         then
            new_c_Class.has_virtual_Members;
            exit;
         end if;

         the_Child := next_Sibling (the_Child);
      end loop;
   end;

   --  Likewise whether its destructor is virtual, which a class derived from it in another module needs to know.
   --
   declare
      the_Child : Node_Pointer := first_Child (the_Node);
   begin
      while the_Child /= null
      loop
         if         Attribute (the_Child, "nodeType") = "destructor"
           and then check_Attribute (the_Child, "storage", "virtual")
         then
            new_c_Class.has_virtual_Destructor;
            exit;
         end if;

         the_Child := next_Sibling (the_Child);
      end loop;
   end;

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

   --  Note whether the class declares a destructor or a copy constructor. C++ passes and returns such a
   --  class by reference, so it cannot be bound as a plain record. (The core notes both on the class. It adds
   --  a destructor to a class which declares none, and then notes that too, as 'allocate:implicit_destructor'.)
   --
   if         Self.in_cpp_Mode     -- In C, a destructor can only be one which the interface file adds.
     and then (        (         get_Attribute (the_Node, "allocate:has_destructor")      /= null
                        and then get_Attribute (the_Node, "allocate:implicit_destructor")  = null)
               or else get_Attribute (the_Node, "allocate:has_copy_constructor") /= null)
   then
      new_c_Class.has_nontrivial_Members;
   end if;

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
                      and then Attribute (the_Child, "storage") = "virtual")
               then
                  new_c_Class.is_not_layout_Pod;
               end if;
            end;

            the_Child := next_Sibling (the_Child);
         end loop;
      end;
   end if;

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
            end if;
         end;
      end loop;
   end;

   Status := swigMod.Language.item (Self.all).classHandler (the_Node);     -- Process all class members.

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
