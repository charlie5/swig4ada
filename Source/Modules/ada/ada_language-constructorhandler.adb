separate (ada_Language)


overriding
function constructorHandler (Self : access Item;
                             N    : in     Node_Pointer) return C.int
is
   the_Node : Node_Pointer renames N;
   Status   : C.int with Unreferenced;

   for_abstract_Class : constant Boolean := Self.Shim.Name /= "";
   extend_Function    : unbounded_String;     -- The function of the wrapper which is a constructor added by '%extend'.
   is_template_Instance : Boolean := False;     -- A constructor template which '%extend' names an instance of: a constructor of the class itself.
   procedure bind_the_C_Function
   --
   --  C has no constructors, but the interface file may add one with '%extend' (as '%array_class' does).
   --  It is bound as an ordinary function, 'new_<type>', which returns a pointer to a new object.
   --
   is
   begin
   if         Attribute (the_Node, "feature:extend") /= ""
     and then not Self.c_class_Stack.is_Empty
     and then Self.name_Map_of_c_type.contains (Self.current_c_Class.Name & "*")
   then
      Self.current_c_Node := doh_Node (the_Node);
      locate (doh_Node (the_Node));
      Status              := swigMod.Language.item (Self.all).constructorHandler (the_Node);

      declare
         use type C.int;

         the_Name       : constant String       := "new_" & to_String (Self.current_c_Class.Name);
         parameter_List :          doh_ParmList := doh_parmList (get_Attribute (the_Node, "parms"));
         the_Function   : constant c_Function.view
           := c_Function.new_c_Function (+the_Name,
                                         Self.name_Map_of_c_type.Element (Self.current_c_Class.Name & "*"));
      begin
         if         exists (parameter_List)
           and then SwigType_type (SwigType_Pointer (get_Attribute (Node_Pointer (parameter_List), "type"))) = T_VOID
         then
            parameter_List := doh_parmList (next_Sibling (Node_Pointer (parameter_List)));
         end if;

         the_Function.Parameters.append (Self.to_c_Parameters (parameter_List));
         the_Function.link_Symbol       := +("Ada_" & the_Name);
         the_Function.returns_an_Access := True;

         Self.current_Module.C.new_c_Functions   .append (the_Function);
         Self.current_Module.C.new_c_Declarations.append (the_Function.all'Access);
      end;
   end if;
   end bind_the_C_Function;



   procedure note_the_extend_Function
   --
   --  A constructor which was added by '%extend' is a function of the wrapper, which returns a new object.
   --  Its name is taken from the call which the core has made of it ('result = (Vec *)new_Vec(arg1,arg2);').
   --
   is
   begin
   if Attribute (the_Node, "feature:extend") /= ""
   then
      declare
         the_Action : constant String  := Attribute (the_Node, "wrap:action");
         Named      : constant Natural := ada.Strings.fixed.Index (the_Action, ")new_");     -- The function follows a cast of its result.
         Last       : constant Natural := (if Named /= 0 then ada.Strings.fixed.Index (the_Action, "(", from => Named + 1)     -- An argument may
                                                         else ada.Strings.fixed.Index (the_Action, "(", going => ada.Strings.Backward));   -- have brackets of its own.
         First      :          Natural := Last;
      begin
         while      First > the_Action'First
           and then the_Action (First - 1) in 'a' .. 'z' | 'A' .. 'Z' | '0' .. '9' | '_'
         loop
            First := First - 1;
         end loop;

         if         Last /= 0
           and then First < Last
         then
            extend_Function := +the_Action (First .. Last - 1);
         end if;

         if         Named = 0                                    -- The action makes the object itself ('new TConstructor1 (arg1)'):
           and then ada.Strings.fixed.Index (the_Action, "new ") /= 0     -- '%extend Class { %template (Class) Class<int>; }'.
         then
            extend_Function      := null_unbounded_String;
            is_template_Instance := True;
         end if;
      end;
   end if;
   end note_the_extend_Function;



   function is_deleted_by_a_Member return Boolean
   --
   --  Whether C++ deletes the default constructor which the core gives a class with none of its own: it does where
   --  the class has a member which is a reference, or a constant of a type which is no class, with no initial value
   --  (jsoncpp's 'MemberProxy', with a 'Value&'). The core does not tell, and the wrapper of the constructor did not
   --  compile.
   --
   is
      the_Child : Node_Pointer := first_Child (Self.getCurrentClass);
   begin
      while the_Child /= null
      loop
         if         Attribute (the_Child, "nodeType") = "cdecl"
           and then Attribute (the_Child, "storage") /= "static"
           and then Attribute (the_Child, "value") = ""
           and then (get_Attribute (the_Child, "decl") = null
                     or else C."=" (SwigType_isfunction (SwigType_Pointer (get_Attribute (the_Child, "decl"))), 0))
         then
            declare
               the_Decl : constant String := Attribute (the_Child, "decl");
               the_Type : constant String := Attribute (the_Child, "type");
            begin
               if        ada.Strings.fixed.Index (the_Decl, "r.") = 1
                 or else ada.Strings.fixed.Index (the_Decl, "z.") = 1
                 or else ada.Strings.fixed.Index (the_Decl, "q(const).") = 1     -- A constant pointer.
               then
                  return True;
               end if;

               if         the_Decl = ""
                 and then ada.Strings.fixed.Index (the_Type, "q(const).") = 1
               then
                  declare
                     Plain : constant String := the_Type (the_Type'First + 9 .. the_Type'Last);
                     Found : constant c_Type.view := (if Self.swig_type_Map_of_c_type.contains (+Plain) then Self.swig_type_Map_of_c_type.Element (+Plain)
                                                      else null);
                     use type c_Type.view;
                     use type c_Type.a_c_type_Kind;
                  begin
                     if        Found = null
                       or else Found.c_type_Kind /= c_Type.c_Class
                     then
                        if C."/=" (SwigType_type (SwigType_typedef_resolve_all (SwigType_Pointer (to_Doh (Plain)))), T_USER)     -- Such as a 'std::string'.
                        then
                           return True;
                        end if;
                     end if;
                  end;
               end if;
            end;
         end if;

         the_Child := next_Sibling (the_Child);
      end loop;

      return False;
   end is_deleted_by_a_Member;


begin
   if not Self.in_cpp_Mode
   then
      bind_the_C_Function;

      return SWIG_OK;
   end if;

   if         Attribute (the_Node, "default_constructor") /= ""
     and then is_deleted_by_a_Member
   then
      return SWIG_OK;     -- It is no constructor which can be called, and the class has none.
   end if;

   indent_Log;
   dlog (+"");
   dlog (+"'constructorHandler'");

   if check_Attribute (the_Node, "access", "private")
   then
      unindent_Log;
      return SWIG_OK;
   end if;

   Self.current_c_Node := doh_Node (the_Node);
   locate (doh_Node (the_Node));

   if not (   check_Attribute (the_Node, "access", "protected")
           or check_Attribute (the_Node, "access", "private")
           or for_abstract_Class)     -- The core's wrapper makes a new object of the class, which an abstract class cannot have.
   then
      Self.doing_constructorDeclaration := True;
      Status := swigMod.Language.item (Self.all).constructorHandler (the_Node);
      Self.doing_constructorDeclaration := False;

      note_the_extend_Function;
   end if;

   if get_Attribute (the_Node, "overload:ignore") /= null
   then   -- Wrappers not wanted for some methods where the parameters cannot be overloaded in Ada.
      unindent_Log;
      return SWIG_OK;
   end if;

   declare
      overloaded_name     : constant String := get_overloaded_Name (doh_Node (the_Node));

      constructor_Symbol  : unbounded_String;     -- We need to build our own 'c' construction call   (TODO: Move all this to functionWrapper.)
      construct_Call      : unbounded_String;     -- since the default swig constructor returns a pointer to class
      construct_call_Args : unbounded_String;     -- instead of an actual solid class object.
      plain_call_Args     : unbounded_String;     -- The parameters as they are named, for a call which takes them as this function does.

      parameter_List : constant ParmList_Pointer := ParmList_Pointer (get_Attribute (the_Node, "parms"));

      the_Parameter  : Node_Pointer := Node_Pointer (parameter_list);
      Index          : Natural      := 0;
      genComma       : Boolean      := False;

      parameters_First : Positive;     -- Where the parameters begin in 'construct_Call'.
      the_Parameters   : unbounded_String;     -- The parameters, as the construction function takes them.

      ignored_Code     : unbounded_String;   -- The code which gives a value to each parameter which the caller does not give.
      any_Argument     : Boolean := False;   -- The call of the constructor has an argument so far.

      function has_hidden_Destructor return Boolean
      --
      --  The construction function returns its object by value, which C++
      --  allows only for a class whose destructor is public.
      --
      is
         the_Child : Node_Pointer := first_Child (Self.getCurrentClass);
      begin
         if get_Attribute (Self.getCurrentClass, "allocate:deleted_default_destructor") /= null
         then
            return True;     -- The class, or a base class, has a destructor which is deleted ('~T () = delete;').
         end if;

         while the_Child /= null
         loop
            if         Attribute (the_Child, "nodeType") = "destructor"
              and then (        check_Attribute (the_Child, "access", "protected")
                        or else check_Attribute (the_Child, "access", "private"))
            then
               return True;
            end if;

            the_Child := next_Sibling (the_Child);
         end loop;

         return False;
      end has_hidden_Destructor;

      procedure name_the_Parameters
      --
      --  Each parameter is given the name of a local variable, which its 'in' typemap then assigns
      --  to. It is only used for a parameter which the caller does not give.
      --
      is
      begin
         declare
            Each  : Node_Pointer := Node_Pointer (parameter_List);
            Count : Natural      := 0;
         begin
            while Each /= null
            loop
               Count := Count + 1;
               set_Attribute (Each, "lname", "swig_ada_ignored_" & ada.Strings.fixed.Trim (Count'Image, ada.Strings.Left));
               Each  := next_Sibling (Each);
            end loop;
         end;
      end name_the_Parameters;



      procedure write_the_Parameters
      --
      --  Adds each parameter to the profile of the construction function, and to the call of the constructor.
      --
      is
      begin
         while the_Parameter /= null
         loop
            if check_Attribute (the_Parameter, "varargs:ignore", "1")
            then   -- Ignored varargs.
               the_Parameter := next_Sibling (the_Parameter);

            elsif check_Attribute (the_Parameter, "tmap:in:numinputs", "0")
            then   -- A parameter which the caller does not give: its 'in' typemap gives it a value, held in a local variable.
               declare
                  swig_Type : constant SwigType_Pointer := SwigType_Pointer (get_Attribute (the_Parameter, "type"));
                  the_Local : constant String           := Attribute (the_Parameter, "lname");
                  the_Code  : constant unbounded_String := +Attribute (the_Parameter, "tmap:in");
               begin

                  append (ignored_Code,   "  " & String'(+doh_Item (SwigType_lstr (swig_Type, const_String (-the_Local)))) & ";" & NL
                                        & "  " & to_String (the_Code) & NL);

                  if any_Argument
                  then
                     append (construct_call_Args,  ",   ");
                  end if;

                  append (construct_call_Args, the_Local);
                  append (plain_call_Args,     (if plain_call_Args = "" then "" else ",   ") & the_Local);
                  any_Argument  := True;
                  the_Parameter := get_Attribute (the_Parameter, "tmap:in:next");
               end;

            else
               declare
                  swig_Type  : constant SwigType_Pointer :=  SwigType_Pointer  (get_Attribute (the_Parameter, "type"));   -- TODO: Rename.
                  the_c_Type :          unbounded_String := +Attribute         (the_Parameter, "tmap:ctype");
                  Arg        : constant String           :=  makeParameterName (doh_parmList (parameter_List),
                                                                                doh_Parm (the_Parameter),
                                                                                Index);
               begin
                  if genComma
                  then
                     append (construct_Call,       ",   ");
                  end if;

                  if any_Argument
                  then
                     append (construct_call_Args,  ",   ");
                  end if;

                  any_Argument := True;
                  append (plain_call_Args, (if plain_call_Args = "" then "" else ",   ") & Arg);

                  if the_c_Type = "$c_classname"
                  then   -- A class or structure passed by value, which Ada passes by reference.
                     append (construct_Call,      String' (+doh_Item (SwigType_lstr (SwigType_add_Pointer (SwigType_Pointer (doh_Copy (doh_Item (swig_Type)))),
                                                                                    const_String (-Arg)))));

                     if Attribute (the_Parameter, "tmap:in:moves") /= ""
                     then   -- The interface file asks that the object be moved from, not copied: its 'in' typemap says so, by the
                            -- attribute 'moves' (the 'MOVE' typemap of 'swigmove.i', '%unique_ptr').
                        append (construct_call_Args, "SWIG_STD_MOVE (*" & Arg & ")");
                     else
                        append (construct_call_Args, "*" & Arg);
                     end if;

                  elsif the_c_Type /= ""
                  then
                     replace_All (the_c_Type, "$c_classname", +doh_Item (SwigType_str (swig_Type, null)));

                     append (construct_Call,      String' (+doh_Item (SwigType_lstr     (swig_Type, null))  &   "   "  &  Arg));
                     append (construct_call_Args, String' (+doh_Item (SwigType_rcaststr (swig_Type, const_String (-Arg)))));
                  else
                     dlog (+"no ctype typemap defined for "  &  String' (+doh_Item (swig_Type)));
                  end if;

                  genComma      := True;
                  the_Parameter := get_Attribute (the_Parameter, "tmap:in:next");
                  Index         := Index + 1;
               end;
            end if;
         end loop;
      end write_the_Parameters;



      procedure write_the_Body
      --
      --  Writes the body of the construction function, which makes the object.
      --
      is
      begin
         if for_abstract_Class
         then
            --  The function has the profile of a constructor: it is given the address of the storage, in which it
            --  constructs an object of the concrete class. Ada then makes the object one of its own derived type.
            --
            declare
               the_Class      : constant String := +doh_Item (SwigType_namestr (SwigType_Pointer (get_Attribute (Self.getCurrentClass, "name"))));
               the_Parameters : constant String := Slice (construct_Call, parameters_First, Length (construct_Call));
            begin
               append (Self.Shim.Constructors,
                         "  " & Self.Shim.Name & " (" & the_Parameters & ") : " & the_Class & " (" & construct_call_Args & ") {}" & NL);

               construct_Call := +(  "extern void " & to_String (constructor_Symbol) & " (" & the_Class & " * self"
                                   & (if the_Parameters = "" then "" else ",   " & the_Parameters) & ")"                   & NL
                                   & "{"                                                                                   & NL
                                   & to_String (ignored_Code)
                                   & "  new (self) " & to_String (Self.Shim.Name) & " (" & to_String (plain_call_Args) & ");" & NL     -- Its constructor takes what this function does.
                                   & "}"                                                                                   & NL);
            end;
         else
            append (construct_Call,  ")" & NL & "{" & NL);
            append (construct_Call,  ignored_Code);

            if extend_Function /= ""
            then   -- The function makes its object with 'new'. The object is copied, and then deleted.
               append (construct_Call,    "  " & Self.current_lStr & " * made = " & extend_Function & " (" & construct_call_Args & ");" & NL
                                        & "  " & Self.current_lStr & "   the_object (*made);"                                           & NL
                                        & "  delete made;"                                                                             & NL
                                        & "  return the_object;"                                                                       & NL);
            else
               append (construct_Call,  "  return "  &  Self.current_lStr  &  "("  &  construct_call_Args  &  ");"  & NL);
            end if;
            append (construct_Call,  "}" & NL);
         end if;
      end write_the_Body;



      procedure add_to_the_Model
      --
      --  Makes the 'construct' function of the C model.
      --
      is
      begin
         --  A class whose destructor is hidden has no construction function (see 'keep_the_Function'), so it has
         --  no constructor to import it.
         --
         if         not for_abstract_Class
           and then has_hidden_Destructor
         then
            return;
         end if;

         declare
            the_Constructor : constant c_Function.view := Self.new_c_Function (doh_Node (the_Node),
                                                                               to_unbounded_String ("construct"),
                                                                               Self.current_c_Class.Namespace.all'Access,
                                                                               is_Destructor  => False,
                                                                               is_Constructor => True);
         begin
            the_Constructor.is_Static          := True;
            the_Constructor.constructor_Symbol := constructor_Symbol;

            --  From which the construction function of the director of the class is made (see 'bind_the_Director').
            --
            the_Constructor.construction_Parameters := the_Parameters;
            the_Constructor.construction_Arguments  := construct_call_Args;
            the_Constructor.construction_Names      := plain_call_Args;
            the_Constructor.construction_Code       := ignored_Code;
         end;
      end add_to_the_Model;



      procedure keep_the_Function
      --
      --  Puts the construction function into the wrapper file, unless C++ could not compile it.
      --
      is
      begin
         if for_abstract_Class
         then   -- Written once the concrete class is complete (see 'classHandler').
            append (Self.Shim.Functions, construct_Call & NL);

         elsif not (    check_Attribute (the_Node, "access", "protected")
                    or  check_Attribute (the_Node, "access", "private")
                    or  has_hidden_Destructor
                    or  (         Attribute (the_Node, "feature:extend") /= ""     -- A constructor added by '%extend' is not one which
                         and then extend_Function = ""                             -- C++ can call, so the function of the wrapper is.
                         and then not is_template_Instance))
         then
            print_to (DOH_Pointer (Self.f_Ada), construct_Call & NL);
         end if;
      end keep_the_Function;



   begin
      append (constructor_Symbol, String'("ada_" & (+doh_Item (Swig_name_construct (const_String (-Self.current_c_Namespace.qualified_Name),
                                                                                    const_String (-overloaded_name))))));
      --  The name of a class in a namespace, or of a template instance, holds characters which a C identifier may not.
      --  Two constructors may also come out alike: those which are protected are in no overload chain, so the core
      --  gives them no suffix. A name which is taken is given a number.
      --
      constructor_Symbol := wrapper_Symbol (Self, to_String (constructor_Symbol));

      append (construct_Call, "extern "  & Self.current_lStr & "    " & constructor_Symbol & "(");
      parameters_First := Length (construct_Call) + 1;

      name_the_Parameters;

      Swig_typemap_attach_parms (const_String (-"ctype"), parameter_List, null);    -- Attach the non-standard typemaps to the parameter list.
      Swig_typemap_attach_parms (const_String (-"in"),    parameter_List, null);

      emit_mark_varArgs (parameter_List);

      write_the_Parameters;

      the_Parameters := unbounded_Slice (construct_Call, parameters_First, Length (construct_Call));

      write_the_Body;

      add_to_the_Model;

      keep_the_Function;
   end;

   unindent_Log;
   return SWIG_OK;
end constructorHandler;
