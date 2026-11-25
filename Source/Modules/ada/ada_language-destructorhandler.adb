separate (ada_Language)


overriding
function destructorHandler (Self : access Item;
                            N    : in     Node_Pointer) return C.int
is
   the_Node : doh_Node renames N;

   Status        :          C.int with Unreferenced;
   is_Virtual    : constant Boolean := is_declared_Virtual (the_Node);
   is_Overriding :          Boolean := False;     -- It overrides that of the parent of the Ada type.
   by_a_Base     :          Boolean := False;     -- That of a base class is virtual, so it is.

   destruct_Symbol : unbounded_String;     -- The function of the wrapper which destructs an object, where there is one.
   delete_Symbol   : unbounded_String;     -- The function of the wrapper which destructs an object and frees it, likewise.
   class_cpp_Name  : constant String := (if Self.in_cpp_Mode then +DOH_Pointer (get_Attribute (Self.getCurrentClass, "name")) else "");

   function deletes_privately return Boolean
   --
   --  Whether the class declares an 'operator delete' which is not public, as one which is made only on the stack
   --  does (Bullet's 'btCollisionObjectWrapper', by 'BT_DECLARE_STACK_ONLY_OBJECT', which declares it and never
   --  defines it). An object of it is then not deleted, and the core's function of the wrapper which deletes one is
   --  not made: it would not link. The object is destructed in its place, by the function which the module makes.
   --
   is
      the_Child : Node_Pointer := first_Child (Self.getCurrentClass);
   begin
      while the_Child /= null
      loop
         if         Attribute (the_Child, "name") = "operator delete"
           and then Attribute (the_Child, "access") in "private" | "protected"
         then
            return True;
         end if;

         the_Child := next_Sibling (the_Child);
      end loop;

      return False;
   end deletes_privately;

begin
   if not Self.in_cpp_Mode
   then
      --  Likewise a destructor which the interface file adds is the function 'delete_<type>'.
      --
      if         Attribute (the_Node, "feature:extend") /= ""
        and then not Self.c_class_Stack.is_Empty
        and then Self.name_Map_of_c_type.contains (Self.current_c_Class.Name & "*")
        and then Self.name_Map_of_c_type.contains (+"void")
      then
         Self.current_c_Node := doh_Node (the_Node);
         locate (doh_Node (the_Node));
         Status              := swigMod.Language.item (Self.all).destructorHandler (the_Node);

         declare
            the_Name     : constant String := "delete_" & to_String (Self.current_c_Class.Name);
            the_Function : constant c_Function.view
              := c_Function.new_c_Function (+the_Name,
                                            Self.name_Map_of_c_type.Element (+"void"));
         begin
            the_Function.Parameters.append (c_Parameter.new_c_Parameter (the_Name => +"Self",
                                                                         the_Type => Self.name_Map_of_c_type.Element (Self.current_c_Class.Name & "*")));
            the_Function.link_Symbol := +("Ada_" & the_Name);

            Self.current_Module.C.new_c_Functions   .append (the_Function);
            Self.current_Module.C.new_c_Declarations.append (the_Function.all'Access);
         end;
      end if;

      return SWIG_OK;
   end if;

   indent_Log;
   dlog (+"");
   dlog (+"'destructorHandler':");

   add_hidden_Virtuals (Self, before => the_Node);

   if Self.destructor_is_Bound
   then   -- Its places are held already (a virtual destructor which is not public, then the one which the core adds).
      unindent_Log;
      return SWIG_OK;
   end if;

   Self.destructor_is_Bound := True;

   if is_Virtual
   then
      Self.current_c_Class.has_virtual_Destructor;
   end if;

   declare
      use type c_Type.view;
      the_Parent : constant c_Type.view := Self.current_c_Class.ada_Parent;     -- That of the Ada type.
   begin
      is_Overriding :=          the_Parent /= null
                       and then the_Parent.has_virtual_Destructor;

      --  The destructor is virtual where that of any base is, which need not be the parent of the Ada type (a base
      --  which the class inherits virtually is none), and then it has its place in the vtable of the class.
      --
      by_a_Base := (for some Each of Self.current_c_Class.base_Classes => Each.has_virtual_Destructor);
   end;

   if by_a_Base
   then
      --  The destructor of a class whose base has a virtual one is virtual, declared so or not, and so is that
      --  of a class which is derived from this one in turn. (Until 2026-11-23 this was noted of a destructor
      --  which is declared virtual alone, so a class two or more below one with a virtual destructor, with no
      --  destructor of its own, was given one which is not virtual, and which did not free the object.)
      --
      Self.current_c_Class.has_virtual_Destructor;
   end if;

   Self.current_c_Node := doh_Node (the_Node);
   locate (doh_Node (the_Node));

   if not (   check_Attribute (the_Node, "access", "protected")
           or check_Attribute (the_Node, "access", "private")
           or deletes_privately)
   then
      Status := swigMod.Language.item (Self.all).destructorHandler (the_node);
   end if;

   --  The destructor of a class which is not virtual is called through a function of the wrapper, as its C++
   --  symbol cannot be told from the name of the class alone (that of a template instance or of a class in a
   --  namespace, say). A virtual destructor is imported by its symbol, as it is a primitive of the tagged type.
   --
   if         not Self.current_c_Class.is_Virtual
     and then not is_Virtual
     and then not by_a_Base
     and then not (   check_Attribute (the_Node, "access", "protected")
                   or check_Attribute (the_Node, "access", "private"))
   then
      declare
         the_Class : constant String := +doh_Item (SwigType_namestr (SwigType_Pointer (get_Attribute (Self.getCurrentClass, "name"))));
      begin
         destruct_Symbol := wrapper_Symbol (Self, "ada_destruct_" & String'(+DOH_Pointer (get_Attribute (Self.getCurrentClass, "name"))));
         delete_Symbol   := destruct_Symbol;     -- There is no deleting variant.

         print_to (DOH_Pointer (Self.f_Ada),   "extern ""C"" void " & to_String (destruct_Symbol) & " (" & the_Class & " * self)" & NL
                                             & "{"                                                                              & NL
                                             & "  typedef " & the_Class & " swig_ada_class;"                                    & NL
                                             & "  self->~swig_ada_class ();"                                                    & NL
                                             & "}"                                                                              & NL & NL);
      end;

   --  The symbol of a virtual destructor cannot be made from the name of a template instance, which need not be
   --  the name by which C++ knows it: an argument may be a typedef, a default argument is left out, and the
   --  arguments of a variadic template are a pack. Such a destructor is two functions of the wrapper too. Each
   --  names the destructor of its own class, so that it is not a virtual call: the function is itself what the
   --  vtable of a type which is derived in Ada holds.
   --
   --  So is a destructor which is defined in its class ('virtual ~X () {}', '~X () override = default;') or which
   --  C++ gives the class: it is inline, and a library need have no symbol for it, as C++ makes it wherever it is
   --  used (jsoncpp's 'FastWriter', whose destructor the library does not export, so that a tester which declared one
   --  did not link). The wrapper's function makes it. A destructor which is declared alone is defined in the library.
   --
   elsif      (        ada.Strings.fixed.Index (class_cpp_Name, "<") /= 0
               or else get_Attribute (the_Node, "code") /= null
               or else Attribute (the_Node, "value") = "default"
               or else Attribute (Self.getCurrentClass, "allocate:implicit_destructor") /= "")
     and then not (   check_Attribute (the_Node, "access", "protected")
                   or check_Attribute (the_Node, "access", "private"))
   then
      declare
         the_Class : constant String := +doh_Item (SwigType_namestr (SwigType_Pointer (get_Attribute (Self.getCurrentClass, "name"))));
      begin
         destruct_Symbol := wrapper_Symbol (Self, "ada_destruct_" & class_cpp_Name);
         delete_Symbol   := wrapper_Symbol (Self, "ada_delete_"   & class_cpp_Name);

         print_to (DOH_Pointer (Self.f_Ada),   "extern ""C"" void " & to_String (destruct_Symbol) & " (" & the_Class & " * self)" & NL
                                             & "{"                                                                              & NL
                                             & "  typedef " & the_Class & " swig_ada_class;"                                    & NL
                                             & "  self->swig_ada_class::~swig_ada_class ();"                                    & NL
                                             & "}"                                                                              & NL & NL
                                             & "extern ""C"" void " & to_String (delete_Symbol) & " (" & the_Class & " * self)"   & NL
                                             & "{"                                                                              & NL
                                             & "  typedef " & the_Class & " swig_ada_class;"                                    & NL
                                             & "  self->swig_ada_class::~swig_ada_class ();"                                    & NL
                                             & "  ::operator delete (self);"                                                    & NL
                                             & "}"                                                                              & NL & NL);
      end;
   end if;

   -- Dummy hack destructor.
   --
   declare
      the_Destructor : constant c_Function.view := Self.new_c_Function (the_Node,
                                                                        to_unbounded_String ("destruct_0"),
                                                                        Self.current_c_Class.Namespace.all'Access,
                                                                        is_Destructor => True,
                                                                        is_Overriding => is_Overriding);
   begin
      the_Destructor.is_Static   := False;
      the_Destructor.is_Virtual  := the_Destructor.is_Virtual or by_a_Base;     -- An implicit destructor is virtual when a base class destructor is.
      the_Destructor.link_Symbol   := (if destruct_Symbol /= "" then destruct_Symbol
                                                                else +cpp_Symbol (class_cpp_Name, Suffix => "D1Ev"));     -- The complete object destructor.
      the_Destructor.is_in_Wrapper := destruct_Symbol /= "";
   end;

   declare
      the_Destructor : constant c_Function.view := Self.new_c_Function (the_Node,
                                                                        to_unbounded_String ("destruct"),
                                                                        Self.current_c_Class.Namespace.all'Access,
                                                                        is_Destructor => True,
                                                                        is_Overriding => is_Overriding);
   begin
      the_Destructor.is_Static   := False;
      the_Destructor.is_Virtual  := the_Destructor.is_Virtual or by_a_Base;     -- An implicit destructor is virtual when a base class destructor is.
      the_Destructor.link_Symbol   := (if destruct_Symbol /= "" then delete_Symbol
                                       else +cpp_Symbol (class_cpp_Name, Suffix => (if the_Destructor.is_Virtual then "D0Ev"      -- The deleting destructor.
                                                                                                                 else "D1Ev")));
      the_Destructor.is_in_Wrapper := destruct_Symbol /= "";
   end;

   unindent_Log;
   return SWIG_OK;
end destructorHandler;
