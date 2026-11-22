separate (ada_Language)


overriding
function destructorHandler (Self : access Item;
                            N    : in     Node_Pointer) return C.int
is
   the_Node : doh_Node renames N;

   Status        :          C.int with Unreferenced;
   Storage       : constant String  := Attribute (the_Node, "storage");
   is_Virtual    : constant Boolean := Storage = "virtual";
   is_Overriding :          Boolean := False;

   destruct_Symbol : unbounded_String;     -- The function of the wrapper which destructs an object, where there is one.
   class_cpp_Name  : constant String := (if Self.in_cpp_Mode then +DOH_Pointer (get_Attribute (Self.getCurrentClass, "name")) else "");
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

   if is_Virtual
   then
      Self.current_c_Class.has_virtual_Destructor;
   end if;

   declare
      Bases : constant c_Type.Vector := Self.current_c_Class.base_Classes;
   begin
      for Each of Bases
      loop
         if Each.is_Virtual     -- Only the first virtual base class is the parent.
         then
            is_Overriding := Each.has_virtual_Destructor;
            exit;
         end if;
      end loop;
   end;

   Self.current_c_Node := doh_Node (the_Node);
   locate (doh_Node (the_Node));

   if not (   check_Attribute (the_Node, "access", "protected")
           or check_Attribute (the_Node, "access", "private"))
   then
      Status := swigMod.Language.item (Self.all).destructorHandler (the_node);
   end if;

   --  The destructor of a class which is not virtual is called through a function of the wrapper, as its C++
   --  symbol cannot be told from the name of the class alone (that of a template instance or of a class in a
   --  namespace, say). A virtual destructor is imported by its symbol, as it is a primitive of the tagged type.
   --
   if         not Self.current_c_Class.is_Virtual
     and then not is_Virtual
     and then not is_Overriding
     and then not (   check_Attribute (the_Node, "access", "protected")
                   or check_Attribute (the_Node, "access", "private"))
   then
      declare
         the_Class : constant String := +doh_Item (SwigType_namestr (SwigType_Pointer (get_Attribute (Self.getCurrentClass, "name"))));
      begin
         destruct_Symbol := wrapper_Symbol (Self, "ada_destruct_" & String'(+DOH_Pointer (get_Attribute (Self.getCurrentClass, "name"))));

         print_to (DOH_Pointer (Self.f_Ada),   "extern ""C"" void " & to_String (destruct_Symbol) & " (" & the_Class & " * self)" & NL
                                             & "{"                                                                              & NL
                                             & "  typedef " & the_Class & " swig_ada_class;"                                    & NL
                                             & "  self->~swig_ada_class ();"                                                    & NL
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
      the_Destructor.is_Virtual  := the_Destructor.is_Virtual or is_Overriding;     -- An implicit destructor is virtual when a base class destructor is.
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
      the_Destructor.is_Virtual  := the_Destructor.is_Virtual or is_Overriding;     -- An implicit destructor is virtual when a base class destructor is.
      the_Destructor.link_Symbol   := (if destruct_Symbol /= "" then destruct_Symbol
                                       else +cpp_Symbol (class_cpp_Name, Suffix => (if the_Destructor.is_Virtual then "D0Ev"      -- The deleting destructor.
                                                                                                                 else "D1Ev")));
      the_Destructor.is_in_Wrapper := destruct_Symbol /= "";
   end;

   unindent_Log;
   return SWIG_OK;
end destructorHandler;
