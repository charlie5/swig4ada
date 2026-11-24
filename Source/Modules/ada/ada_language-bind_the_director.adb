separate (ada_Language)


procedure bind_the_Director (Self : access Item;   the_Class : in Node_Pointer)
--
--  A virtual function which Ada cannot call through the vtable (one which returns, by value, a class that C++
--  constructs, or which takes a plain structure by value; see 'is_called_through_its_Wrapper') is no primitive of
--  the Ada type, and so cannot be overridden in Ada: C++ would call the Ada function with its arguments as C++
--  passes them, and where its ABI has them (the hidden pointer to the result is the first argument on x86-64, and
--  in a register of its own on AArch64).
--
--  For a class which the interface file marks '%feature ("director")', the wrapper is therefore given a class
--  which is derived from it (or from its concrete class, where it is abstract), the director, which overrides each
--  such function in C++. The override calls a further virtual function of the director, which takes what the
--  function of the wrapper does (the result by a pointer, a class or structure by a pointer to it), and whose
--  place is after those of the class. Ada can call it, and override it, through the vtable. What it does, unless
--  it is overridden, is what the function of the class does (it makes a call which is not virtual), or nothing
--  where that function is pure.
--
--  The director of the class is the type 'Item' of the child package 'Director' of its package (see the source
--  generator): a type which is derived from that of the class, with a primitive for each such function, which a
--  type derived from it in Ada overrides, and with the constructors of the class.
--
--  GNAT takes the vtable of a type which is derived from one of C++ from the C++ class itself, at its elaboration,
--  and not from the subprograms which the spec imports, so the override must be in C++: the place which the Ada
--  type holds for the function cannot be given another function by the spec.
--
is
   use type C.int;
   use type DOH_Pointer;
   use type swig_Module.swig_Module_view;
   use type c_Type.a_c_type_Kind;
   use type c_Function.view;

   the_cpp_Class : constant String := (if get_Attribute (the_Class, "name") = null then ""
                                       else +doh_Item (SwigType_namestr (SwigType_Pointer (get_Attribute (the_Class, "name")))));
   the_c_Class   : constant c_Type.view := Self.current_c_Class;

   the_Name      : unbounded_String;     -- That of the director.
   the_Base      : unbounded_String;     -- That of the class which the director is derived from.

   Constructors  : unbounded_String;     -- The parts of the class in C++.
   Overrides     : unbounded_String;
   Virtuals      : unbounded_String;
   Functions     : unbounded_String;     -- The functions of the wrapper which Ada imports.

   Count         : Natural := 0;         -- Of the functions which the director overrides.



   function str (the_Type : in String;   Name : in String) return String
   is (+doh_Item (SwigType_str (SwigType_Pointer (to_Doh (the_Type)), const_String (-Name))));


   function c_Type_of (the_Type : in String) return c_Type.view
   --
   --  The type of the C model which the swig type stands for, through any typedefs. Null where none is known.
   --
   is
      Plain    : constant String           := without_leading_Qualifiers (the_Type);
      Resolved : constant unbounded_String := +doh_Item (SwigType_typedef_resolve_all (SwigType_Pointer (to_Doh (Plain))));
      Found    :          c_Type.view      := (if    Self.swig_type_Map_of_c_type.contains (+Plain) then Self.swig_type_Map_of_c_type.Element (+Plain)
                                               elsif Self.swig_type_Map_of_c_type.contains (Resolved) then Self.swig_type_Map_of_c_type.Element (Resolved)
                                               else  null);
   begin
      while      Found /= null
        and then Found.c_type_Kind = c_Type.Typedef
      loop
         Found := Found.base_Type;
      end loop;

      return Found;
   end c_Type_of;


   function is_passed_by_Address (the_Type : in String) return Boolean
   --
   --  Whether the function of the wrapper takes a pointer to an argument of this type: a reference does, and so does
   --  a class or structure which is passed by value. A pointer, an array, a number and an enumeration are taken as
   --  they are.
   --
   is
      Pad : constant SwigType_Pointer := SwigType_Pointer (to_Doh (without_leading_Qualifiers (the_Type)));
   begin
      if        SwigType_isReference        (Pad) /= 0
        or else SwigType_isrvalue_reference (Pad) /= 0
      then
         return True;
      end if;

      if        SwigType_isPointer (Pad) /= 0
        or else SwigType_isArray   (Pad) /= 0
      then
         return False;
      end if;

      declare
         Found : constant c_Type.view := c_Type_of (the_Type);
      begin
         if Found /= null
         then
            return Found.c_type_Kind in c_Type.c_Class | c_Type.opaque_Struct | c_Type.incomplete_Class;
         end if;
      end;

      return SwigType_type (SwigType_typedef_resolve_all (Pad)) = T_USER;     -- Such as 'std::string', which a library file makes known.
   end is_passed_by_Address;


   function pointer_to (the_Type : in String) return String
   --
   --  The C++ type of a pointer to what the type is or refers to.
   --
   is
      Pad : constant SwigType_Pointer := SwigType_Pointer (doh_Copy (doh_Item (to_Doh (the_Type))));
      Unused : SwigType_Pointer with Unreferenced;
   begin
      if        SwigType_isReference        (Pad) /= 0
        or else SwigType_isrvalue_reference (Pad) /= 0
      then
         Unused := SwigType_del_reference (Pad);
      end if;

      Unused := SwigType_add_Pointer (Pad);
      return +doh_Item (SwigType_str (Pad, null));
   end pointer_to;


   function has_a_default_Constructor (the_Type : in String) return Boolean
   --
   --  The override of a function which returns a class by value makes the object which the function of Ada is
   --  given to replace, so the class must have a constructor which takes nothing.
   --
   is
      Found          : constant c_Type.view := c_Type_of (the_Type);
      has_any        :          Boolean     := False;
   begin
      if        Found = null
        or else Found.c_type_Kind /= c_Type.c_Class
      then
         return True;     -- Such as 'std::string', which a library file makes known.
      end if;

      for Each of c_nameSpace.view (Found.nameSpace).Subprograms
      loop
         if Each.is_Constructor
         then
            has_any := True;

            if Each.Parameters.is_Empty
            then
               return True;
            end if;
         end if;
      end loop;

      return not has_any;     -- The class has the default constructor which C++ gives it.
   end has_a_default_Constructor;


   function the_c_Function (link_Symbol : in String) return c_Function.view
   is
   begin
      for Each of c_nameSpace.view (the_c_Class.nameSpace).Subprograms
      loop
         if Each.link_Symbol = link_Symbol
         then
            return Each;
         end if;
      end loop;

      return null;
   end the_c_Function;


   function exception_Specification (the_Function : in Node_Pointer) return String
   --
   --  That of the function ('throw ()', 'throw (E)'), which an override must keep, or none.
   --
   is
      the_Type : Node_Pointer     := get_Attribute (the_Function, "throws");
      Types    : unbounded_String;
   begin
      if Attribute (the_Function, "throw") = ""
      then
         return "";
      end if;

      while the_Type /= null
      loop
         append (Types, (if Types = "" then "" else ", ") & str (Attribute (the_Type, "type"), ""));
         the_Type := next_Sibling (the_Type);
      end loop;

      return " throw (" & to_String (Types) & ")";
   end exception_Specification;


   procedure join_the_Declarator (the_Function : in Node_Pointer;   the_Type : out DOH_Pointer)
   --
   --  The type of a member function, as the parser leaves it, is that of the declaration ('std::string', of
   --  'const std::string& f ();'), and its declarator is apart ('f().r.q(const).'). The type is made the whole type
   --  of the result for the time of this step, as the core makes it for the time of its handler. Its own is given
   --  back, to be put back.
   --
   is
      Decl           : constant DOH_Pointer      := DOH_Pointer (get_Attribute (the_Function, "decl"));
      the_whole_Type : constant SwigType_Pointer := SwigType_Pointer (doh_Copy (doh_Item (get_Attribute (the_Function, "type"))));
      Unused         : C.int with Unreferenced;
   begin
      the_Type := DOH_Pointer (get_Attribute (the_Function, "type"));
      DohIncref (the_Type);

      if Decl /= null
      then
         SwigType_push (the_whole_Type, String_Pointer (doh_Copy (doh_Item (Decl))));
      end if;

      if SwigType_isqualifier (the_whole_Type) /= 0
      then
         declare
            Qualifier : constant String_Pointer := SwigType_pop (the_whole_Type) with Unreferenced;
         begin
            null;
         end;
      end if;

      if SwigType_isfunction (the_whole_Type) /= 0
      then
         declare
            the_Function_Part : constant SwigType_Pointer := SwigType_pop_function (the_whole_Type) with Unreferenced;
         begin
            null;
         end;
      end if;

      Unused := DohSetattr (DOH_Pointer (the_Function), DOH_Pointer (to_Doh ("type")), DOH_Pointer (the_whole_Type));
   end join_the_Declarator;


   function is_a_Director return Boolean
   is
   begin
      return          Attribute (the_Class, "feature:director")   /= ""
             and then Attribute (the_Class, "feature:director")   /= "0"
             and then Attribute (the_Class, "feature:nodirector") = "";
   end is_a_Director;



   procedure direct (the_Function : in Node_Pointer)
   --
   --  Adds the override of the function, and the virtual function which it calls, to the director.
   --
   is
      the_Decl  :          unbounded_String := +Attribute (the_Function, "decl");
      Qualifier :          unbounded_String;     -- That of the function itself, as in 'int f () const'.
      Reference :          unbounded_String;     -- Its reference qualifier, if any.
      Promise   : constant String           := (if Attribute (the_Function, "noexcept") = "true" then " noexcept" else "") & exception_Specification (the_Function);
      Name      :          unbounded_String := +Attribute (the_Function, "name");
      Result    : constant String           := Attribute (the_Function, "type");
      is_Pure   : constant Boolean          := check_Attribute (the_Function, "abstract", "1");

      by_Result : constant Boolean := returns_a_cpp_constructed_Type (Self, doh_Node (the_Function));     -- The result is given by a pointer to it.
      is_Void   : constant Boolean := SwigType_type (SwigType_Pointer (to_Doh (Result))) = T_VOID;
      by_Ref    : constant Boolean :=          SwigType_isReference        (SwigType_Pointer (to_Doh (Result))) /= 0
                                      or else SwigType_isrvalue_reference (SwigType_Pointer (to_Doh (Result))) /= 0;

      the_Model     : constant c_Function.view := the_c_Function (Attribute (the_Function, "wrap:name"));

      cpp_Parameters : unbounded_String;     -- Those of the function of the class, as C++ has them.
      ada_Parameters : unbounded_String;     -- Those of the virtual function which the override calls.
      to_Ada         : unbounded_String;     -- The arguments of the call of that function, from those of the override.
      to_Cpp         : unbounded_String;     -- The arguments of the call of the function of the class, from those of the other.
      Names          : unbounded_String;     -- The parameters of the virtual function by their names alone.

      the_Parameter : Node_Pointer := get_Attribute (the_Function, "parms");
      Place         : Natural      := 0;

      the_Virtual : unbounded_String;
      the_Symbol  : unbounded_String;

      procedure add (Text : in out unbounded_String;   More : in String)
      is
      begin
         append (Text, (if Text = "" then "" else ", ") & More);
      end add;

   begin
      if the_Model = null
      then
         return;     -- The function is not bound.
      end if;

      strip_Namespaces (Name);

      if by_Result
        and then not has_a_default_Constructor (without_leading_Qualifiers (Result))
      then
         c_Declarable.warn (the_Model, not_Bound,   "Unable to let Ada override the function '" & to_String (Name) & "' of class '"
                                                  & to_String (the_c_Class.Name) & "', as its result has no constructor which takes nothing.");
         return;
      end if;

      if Index (the_Decl, "r.") = 1          -- A function which is declared for an lvalue or for an rvalue alone.
      then
         Reference := +" &";
         the_Decl  := unbounded_Slice (the_Decl, 3, Length (the_Decl));

      elsif Index (the_Decl, "z.") = 1
      then
         Reference := +" &&";
         the_Decl  := unbounded_Slice (the_Decl, 3, Length (the_Decl));
      end if;

      if Index (the_Decl, "q(") = 1
      then
         Qualifier := " " & unbounded_Slice (the_Decl, 3, Index (the_Decl, ").") - 1);
      end if;

      --  The parameters.
      --
      if         the_Parameter /= null
        and then next_Sibling (the_Parameter) = null
        and then SwigType_type (SwigType_Pointer (get_Attribute (the_Parameter, "type"))) = T_VOID
      then
         the_Parameter := null;     -- '(void)'.
      end if;

      while the_Parameter /= null
      loop
         declare
            the_Type : constant String := Attribute (the_Parameter, "type");
            In_Cpp   : constant String := "swig_ada_p" & ada.Strings.fixed.Trim (Place'Image, ada.Strings.Left);
            In_Ada   : constant String := "swig_ada_a" & ada.Strings.fixed.Trim (Place'Image, ada.Strings.Left);
         begin
            if the_Type = "v(...)"
            then
               return;     -- A variadic function, which Ada does not override.
            end if;

            add (cpp_Parameters, str (the_Type, In_Cpp));
            add (Names,          In_Ada);

            if is_passed_by_Address (the_Type)
            then
               add (ada_Parameters, "void * " & In_Ada);
               add (to_Ada,         "(void *) &" & In_Cpp);

               if SwigType_isrvalue_reference (SwigType_Pointer (to_Doh (the_Type))) /= 0
               then
                  add (to_Cpp, "SWIG_STD_MOVE (*(" & pointer_to (the_Type) & ") " & In_Ada & ")");
               else
                  add (to_Cpp, "*(" & pointer_to (the_Type) & ") " & In_Ada);
               end if;
            else
               add (ada_Parameters, str (the_Type, In_Ada));
               add (to_Ada,         In_Cpp);
               add (to_Cpp,         In_Ada);
            end if;
         end;

         Place         := Place + 1;
         the_Parameter := next_Sibling (the_Parameter);
      end loop;

      if by_Result
      then
         add (ada_Parameters, "void * swig_ada_result");
         add (Names,          "swig_ada_result");
      end if;

      Count       := Count + 1;
      the_Virtual := +("swig_ada_" & to_String (wrapper_Symbol (Self, Attribute (the_Function, "sym:name"))));
      the_Symbol  := wrapper_Symbol (Self, to_String (the_Name) & "_" & Attribute (the_Function, "sym:name"));

      declare
         ada_Result : constant String := (if    by_Result or is_Void then "void"
                                          elsif by_Ref               then "void *"
                                          else                            str (Result, ""));
         the_Call   : constant String := "const_cast<" & to_String (the_Name) & " *> (this)->"     -- The function may be 'const'.
                                         & to_String (the_Virtual) & " (" & to_String (to_Ada) & ")";
         the_Own    : constant String := "this->" & the_cpp_Class & "::" & to_String (Name) & " (" & to_String (to_Cpp) & ")";
         Plain      : constant String := str (without_leading_Qualifiers (Result), "");
      begin
         --  The override, which calls the virtual function.
         --
         append (Overrides,   "  virtual " & str (Result, to_String (Name) & " (" & to_String (cpp_Parameters) & ")")
                            & Qualifier & Reference & Promise & NL
                            & "  {" & NL);

         if by_Result
         then
            append (Overrides,   "    " & Plain & " swig_ada_result;" & NL
                               & "    " & the_Call (the_Call'First .. the_Call'Last - 1)
                               &          (if to_Ada = "" then "" else ", ") & "(void *) &swig_ada_result);" & NL
                               & "    return swig_ada_result;" & NL);
         elsif is_Void
         then
            append (Overrides,   "    " & the_Call & ";" & NL);
         elsif by_Ref
         then
            append (Overrides,   "    return *(" & pointer_to (Result) & ") " & the_Call & ";" & NL);
         else
            append (Overrides,   "    return " & the_Call & ";" & NL);
         end if;

         append (Overrides, "  }" & NL);

         --  The virtual function, which does what the function of the class does. It is not 'const', so that Ada may
         --  change its object.
         --
         append (Virtuals,   "  virtual " & ada_Result & " " & to_String (the_Virtual) & " (" & to_String (ada_Parameters) & ")" & NL
                           & "  {" & NL);

         if is_Pure
         then
            append (Virtuals, "    abort ();" & NL);     -- Never reached: the director of a pure function is abstract in Ada.
         elsif by_Result
         then
            append (Virtuals,   "    " & Plain & " swig_ada_value (" & the_Own & ");" & NL
                              & "    swig_ada_replace ((" & Plain & " *) swig_ada_result, swig_ada_value);" & NL);
         elsif is_Void
         then
            append (Virtuals,   "    " & the_Own & ";" & NL);
         elsif by_Ref
         then
            append (Virtuals,   "    return (void *) &" & the_Own & ";" & NL);
         else
            append (Virtuals,   "    return " & the_Own & ";" & NL);
         end if;

         append (Virtuals, "  }" & NL);

         --  The function of the wrapper which Ada imports, which calls the virtual function of the director itself.
         --
         if not is_Pure
         then
            append (Functions,   "extern " & ada_Result & " " & to_String (the_Symbol) & " (" & to_String (the_Name) & " * self"
                               & (if ada_Parameters = "" then "" else ", " & to_String (ada_Parameters)) & ")" & NL
                               & "{" & NL
                               & "  " & (if ada_Result = "void" then "" else "return ")
                               &        "self->" & to_String (the_Name) & "::" & to_String (the_Virtual) & " (" & to_String (Names) & ");" & NL
                               & "}" & NL & NL);
         end if;
      end;

      the_Model.director_Symbol      := the_Symbol;
      the_Model.director_is_Abstract := is_Pure;
   end direct;



   procedure construct (the_Constructor : in c_Function.view)
   --
   --  Adds a constructor to the director, and the function of the wrapper which constructs one in the storage which
   --  it is given, as a constructor of a type which is derived in Ada must.
   --
   is
      the_Symbol : constant unbounded_String := wrapper_Symbol (Self, to_String (the_Name) & "_new");
      Arguments  : constant unbounded_String := (if the_Base = +the_cpp_Class then the_Constructor.construction_Arguments
                                                 else                                the_Constructor.construction_Names);     -- Those of the concrete class.
   begin
      append (Constructors,   "  " & the_Name & " (" & the_Constructor.construction_Parameters & ") : "
                            & the_Base & " (" & Arguments & ") {}" & NL);

      append (Functions,   "extern void " & the_Symbol & " (" & the_Name & " * self"
                         & (if the_Constructor.construction_Parameters = "" then +"" else ",   " & the_Constructor.construction_Parameters) & ")" & NL
                         & "{" & NL
                         & the_Constructor.construction_Code
                         & "  new (self) " & the_Name & " (" & the_Constructor.construction_Names & ");" & NL
                         & "}" & NL & NL);

      the_Constructor.director_Symbol := the_Symbol;
   end construct;



   the_Child : Node_Pointer;

begin
   Self.current_c_Node := doh_Node (the_Class);     -- Of which 'current_Module' is worked out. That of the concrete class of
   locate (doh_Node (the_Class));                   -- an abstract class was made by its step, and is of no module.

   if        not Self.in_cpp_Mode
     or else Self.current_Module /= Self.Module_top'Access                 -- The wrapper of an imported module is not written here.
     or else not is_a_Director
     or else the_c_Class.has_an_unknown_Base                               -- The places of its virtual functions are not known.
     or else get_Attribute (the_Class, "allocate:private_destructor") /= null
     or else get_Attribute (the_Class, "allocate:deleted_default_destructor") /= null
     or else Attribute (the_Class, "final") /= ""
   then
      return;
   end if;

   if         get_Attribute (the_Class, "abstracts") /= null
     and then DohLen (DOH_Pointer (get_Attribute (the_Class, "abstracts"))) > 0
   then
      if Self.Shim.Made = ""
      then
         return;     -- The class is abstract, and has no concrete class to be derived from.
      end if;

      the_Base := Self.Shim.Made;
   else
      the_Base := +the_cpp_Class;
   end if;

   the_Name := wrapper_Symbol (Self, "ada_director_" & Attribute (the_Class, "sym:name"));

   --  The functions which Ada cannot call through the vtable.
   --
   the_Child := first_Child (the_Class);

   while the_Child /= null
   loop
      if         Attribute (the_Child, "nodeType") = "cdecl"
        and then is_declared_Virtual (the_Child)
        and then not check_Attribute (the_Child, "access", "private")
        and then get_Attribute (the_Child, "defaultargs") = null           -- A form of a function with a default argument left out.
        and then Attribute (the_Child, "final") = ""
        and then Attribute (the_Child, "wrap:name") /= ""
        and then ada.Strings.fixed.Index (Attribute (the_Child, "name"), "operator ") = 0
      then
         declare
            its_Type : DOH_Pointer;
            Unused   : C.int with Unreferenced;
         begin
            join_the_Declarator (the_Child, its_Type);

            if is_called_through_its_Wrapper (Self, the_Child)
            then
               direct (the_Child);
            end if;

            Unused := DohSetattr (DOH_Pointer (the_Child), DOH_Pointer (to_Doh ("type")), its_Type);
         end;
      end if;

      the_Child := next_Sibling (the_Child);
   end loop;

   if Count = 0
   then
      return;     -- Ada overrides each virtual function of the class through its own type.
   end if;

   for Each of c_nameSpace.view (the_c_Class.nameSpace).Subprograms
   loop
      if Each.is_Constructor
      then
         construct (Each);
      end if;
   end loop;

   print_to (DOH_Pointer (Self.f_Ada),   "/* The director of '" & the_cpp_Class & "', from which Ada derives a type which overrides its functions"         & NL
                                       & "   that Ada cannot call through the vtable. */"                                                               & NL
                                       & "class " & to_String (the_Name) & " : public " & to_String (the_Base)                                      & NL
                                       & "{"                                                                                                         & NL
                                       & "public:"                                                                                                   & NL
                                       & to_String (Constructors)
                                       & to_String (Overrides)
                                       & to_String (Virtuals)
                                       & "};"                                                                                                        & NL & NL
                                       & to_String (Functions));
end bind_the_Director;
