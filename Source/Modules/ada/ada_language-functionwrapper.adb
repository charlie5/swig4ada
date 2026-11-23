separate (ada_Language)


overriding
function functionWrapper (Self : access Item;
                          N    : in     Node_Pointer) return C.int
--
--  Writes the wrapper function of a C or C++ function into the wrapper file, and makes its function of the C model.
--
--  The work is done by the steps which are declared below, in the order in which they are called at the end.
--
is
   the_Node : Node_Pointer renames N;
   use type C.int;
begin
   indent_Log;
   log  ("");
   log  (+"Binding function: '" & Attribute (the_Node, "sym:name") & "'");
   dlog (+"functionWrapper:  '" & Attribute (the_Node, "sym:name") & "'");

   Self.current_c_Node := doh_Node (the_Node);
   locate (doh_Node (the_Node));

   freshen_current_module_Package (Self, the_Node);

   if check_Attribute (the_Node, "access", "private")
   then     -- Skip private functions (tbd: still needed ?).
      dlog (+"Skipping private function.");
      unindent_Log;
      return SWIG_OK;
   end if;

   declare
      sym_Name   : constant String       := Attribute (the_Node, "sym:name");
      swig_Type  : constant doh_swigType := doh_swigType (get_Attribute (the_Node, "type"));
   begin
      if get_Attribute (the_Node, "sym:overloaded") = null
      then
         --  The name may be taken by another declaration: a protected member is bound, which no other language
         --  binds, so a '%rename' may give a public member the name of one ('%rename (s) Foo::p;' where 'Foo' has
         --  a protected 's'). The later of the two is left out. (Until 2026-11-23 the core's error ended the run.)
         --
         declare
            Other : constant Node_Pointer := Self.symbolLookup (String_Pointer (get_Attribute (the_Node, "sym:name")));
         begin
            if         Other /= null
              and then Other /= the_Node
            then
               warn (not_Bound, "Unable to bind the function '" & sym_Name & "', as another declaration is bound by that name.");
               unindent_Log;
               return SWIG_OK;
            end if;
         end;

         if Self.addSymbol (String_Pointer (get_Attribute (the_Node, "sym:name")),
                            the_Node) = 0
         then
            unindent_Log;
            return SWIG_ERROR;
         end if;
      end if;

      --  The rest of this function deals with generating the intermediary package wrapper function (which wraps
      --  a C/C++ function) and generating the C code. Each Ada wrapper function has a matching C function call.
      --
      declare
         the_function_Wrapper : constant Wrapper.Pointer  := newWrapper;
         wrapper_Def          : constant doh_String       := doh_String (the_function_Wrapper.Def);
         wrapper_Code         : constant doh_String       := doh_String (the_function_Wrapper.Code);

         overloaded_Name      : constant unbounded_String := to_unbounded_String (get_overloaded_Name (the_Node));
         wrapper_Name         : constant String           := +(doh_Item (Swig_name_wrapper (const_String (-overloaded_name))));

         the_Parameters       : constant ParmList_Pointer := ParmList_Pointer (get_Attribute (the_Node, "parms"));

         c_return_Type        :          unbounded_String := +doh_Item (Swig_typemap_lookup (const_String (-"ctype"),
                                                                                             the_Node,
                                                                                             const_String (-""),
                                                                                             null));
         --  A type which C++ constructs (a class which is virtual or not trivial, or a 'std::string') cannot be the result
         --  of an Ada function, as Ada takes the result of such a function to be a reference to an existing object, where
         --  C++ builds a new one in storage given by the caller. The wrapper therefore takes a pointer to an object of the
         --  caller as its last parameter, and replaces that object by the result.
         --
         result_by_Parameter : constant Boolean :=          Self.in_cpp_Mode
                                                   and then not Self.doing_constructorDeclaration
                                                   and then returns_a_cpp_constructed_Type (Self, the_Node);

         is_void_return  : constant Boolean := (c_return_Type = "void") or result_by_Parameter;
         returns_a_Class : constant Boolean := (c_return_Type = "$c_classname") and not result_by_Parameter;     -- A class, returned by value.
         has_Parameters  :          Boolean := False;
         built_in_Place  :          Boolean := False;     -- The result is constructed from the call itself, with no result variable.
         has_exception_Code : constant Boolean := get_Attribute (the_Node, "feature:except") /= null;

         Num_arguments   : Natural          := 0;
         Num_required    : Natural with Unreferenced;

         argout_Code     : unbounded_String;
         cleanup_Code    : unbounded_String;


         procedure begin_the_Definition
         --
         --  Declares the variable which holds the result, and begins the definition of the wrapper function.
         --
         is
         begin
            if c_return_Type /= ""
            then
               if result_by_Parameter
               then   -- The object of the caller is replaced, so a result which is constant ('const Foo f ();') is taken as one which is not.
                  replace_All (c_return_Type,
                               "$c_classname",
                               +doh_Item (SwigType_str (SwigType_Pointer (to_Doh (without_leading_Qualifiers (+swig_Type))), null)));
               end if;

               replace_All (c_return_Type, "$c_classname", +doh_Item (SwigType_str (SwigType_Pointer (swig_Type), null)));     -- As C++ source, not as swig holds it.
            else
               dlog (+"No ctype typemap defined for " & String'(+swig_Type));
            end if;

            if         returns_a_Class
              and then Self.in_cpp_Mode
            then   -- The class may have no default constructor or no assignment, so the result is held as the swig runtime holds such a value.
               Wrapper_add_local_2 (the_function_Wrapper,  String_or_char_Pointer (-"jresult"),
                                                           new_String ("SwigValueWrapper< " & to_String (c_return_Type) & " >"),
                                                           new_String ("jresult"));
            elsif not is_void_return
            then
               Wrapper_add_local_2 (the_function_Wrapper,  String_or_char_Pointer (-"jresult"),
                                                           new_String (to_String (c_return_Type)),
                                                           new_String ("jresult"));                     -- Was formerly "jresult = 0".
            end if;

            Print_to (wrapper_Def, to_String (" DllExport " & (if result_by_Parameter then +"void" else c_return_Type) & " SWIGSTDCALL " & wrapper_Name & " ("));

            Self.current_linkage_Symbol := to_unbounded_String (wrapper_Name);
         end begin_the_Definition;



         procedure construct_the_Result_in_Place
         --
         --  Changes the action of a function whose result C++ constructs, so that the result is built from the call.
         --
         is
         begin
            --  The core's action for a function is 'result = <call>;', which assigns to a variable of the result type. A
            --  class which C++ constructs is instead constructed from the call, and then moved (or copied) into the object
            --  of the caller. Its assignment is not used: one which the compiler generates is wrong for a class which
            --  manages a resource through its copy constructor and destructor alone.
            --
            if result_by_Parameter
            then
               declare
                  the_Action : constant String  := Attribute (the_Node, "wrap:action");
                  Prefix     : constant String  := "result = ";
                  First      : constant Natural := ada.Strings.fixed.Index (the_Action, Prefix);
                  Last       : constant Natural := ada.Strings.fixed.Index (the_Action, ";", going => ada.Strings.Backward);
               begin
                  if         First /= 0
                    and then Last   > First
                    and then ada.Strings.fixed.Trim (the_Action (the_Action'First .. First - 1), ada.Strings.Both) = ""
                    and then ada.Strings.fixed.Trim (the_Action (Last + 1 .. the_Action'Last),   ada.Strings.Both) = ""
                  then
                     --  The action is kept to one line, as an '%exception' may place it within other text.
                     --
                     set_Attribute (the_Node, "wrap:action",
                                    String'(  "{ typedef " & to_String (c_return_Type) & " swig_ada_result_type;"
                                            & "  swig_ada_result_type swig_ada_result = " & the_Action (First + Prefix'Length .. Last - 1) & ";"
                                            & "  swig_ada_replace (a_result, swig_ada_result);"
                                            & (if has_exception_Code then "  swig_ada_built = true; }" else " }")));
                     built_in_Place := True;

                     --  The code of an '%exception' need not hold the action, and may assign to the 'result' variable
                     --  itself. The wrapper therefore notes whether the action has run, and uses 'result' if it has not.
                     --
                     if has_exception_Code
                     then
                        Wrapper_add_local_2 (the_function_Wrapper,  String_or_char_Pointer (-"swig_ada_built"),
                                                                    new_String ("bool"),
                                                                    new_String ("swig_ada_built = false"));
                     end if;
                  end if;
               end;
            end if;
         end construct_the_Result_in_Place;



         procedure write_the_Parameters
         --
         --  Adds each parameter to the definition, and the code which takes its argument.
         --
         is
         begin
            --  Now walk the function parameter list and generate code to get arguments.
            --
            do_Parameters:
            declare
               the_Parameter : Node_Pointer := Node_Pointer (the_Parameters);
               gen_Comma     : Boolean      := False;
            begin
               for Each in 0 .. Num_arguments - 1
               loop
                  while check_Attribute (the_Parameter, "tmap:in:numinputs", "0")
                  loop   -- TODO: What is this for ?
                     the_Parameter := get_Attribute (the_Parameter, "tmap:in:next");
                  end loop;

                  declare
                     param_swigType : constant doh_swigType     :=  doh_swigType (get_Attribute (the_Parameter, "type"));
                     l_Name         : constant doh_String       :=  doh_String   (get_Attribute (the_Parameter, "lname"));
                     arg            : constant String           :=  "a_" & (+l_Name);
                     param_c_Type   :          unbounded_String := +Attribute (the_Parameter, "tmap:ctype");
                     declares_Name  :          Boolean          := False;     -- 'param_c_Type' holds the name of the parameter too.
                  begin
                     if param_c_Type = "$c_classname"
                     then   -- A class or structure passed by value. Ada passes a record to an imported subprogram by reference.
                        declare
                           pointer_Type : constant SwigType_Pointer := SwigType_Pointer (doh_Copy (doh_Item (param_swigType)));
                        begin
                           --  The type is written with the name of the parameter, which
                           --  does not simply follow it (as in 'int (*const *a_arg1)[10]').
                           --
                           param_c_Type  := +doh_Item (SwigType_str (SwigType_add_Pointer (pointer_Type), const_String (-arg)));
                           declares_Name := True;
                        end;

                     elsif param_c_Type /= ""
                     then
                        replace_All (param_c_Type,  "$c_classname", +doh_Item (SwigType_str (SwigType_Pointer (param_swigType), null)));
                        replace_All (param_c_Type,  "(", " ");        -- TODO: Hack to remove parentheses from template arguments.
                        replace_All (param_c_Type,  ")", " ");
                     else
                        dlog (+"No ctype typemap defined for " & String'(+param_swigType));
                     end if;

                     if gen_Comma
                     then
                        print_to (wrapper_Def, "," & NL);
                     end if;

                     print_to (wrapper_Def, to_String (if declares_Name then param_c_Type else param_c_Type & " " & arg));     -- Add parameter to C function.
                     gen_Comma      := True;
                     has_Parameters := True;

                     --  Get typemap for this argument.
                     --
                     declare
                        the_typeMap : unbounded_String := +Attribute (the_Parameter, "tmap:in");
                     begin
                        if the_typeMap /= ""
                        then
                           replace_All (the_typeMap,  "$source",  Arg);          -- Deprecated.
                           replace_All (the_typeMap,  "$target", +l_Name);       -- Deprecated.
                           replace_All (the_typeMap,  "$arg",     Arg);          -- Deprecated ?
                           replace_All (the_typeMap,  "$input",   Arg);          -- Deprecated.

                           set_Attribute (the_Parameter, "emit:input", Arg);

                           print_to (wrapper_Code, the_typeMap & NL);

                           the_Parameter := get_Attribute (the_Parameter, "tmap:in:next");
                        else
                           dlog (+"Unable to use type " & String'(+param_swigType) & " as a function argument.");
                           the_Parameter := next_Sibling (the_Parameter);
                        end if;
                     end;
                  end;
               end loop;
            end do_Parameters;
         end write_the_Parameters;



         procedure gather_the_cleanup_Code
         --
         --  The code which frees what the arguments were given ('freearg' typemaps).
         --
         is
         begin
            --  Insert cleanup code.
            --
            declare
               the_Parameter : Node_Pointer := Node_Pointer (the_Parameters);
            begin
               while the_Parameter /= null
               loop
                  declare
                     the_typeMap : unbounded_String := +Attribute (the_Parameter, "tmap:freearg");
                  begin
                     if the_typeMap /= ""
                     then
                        replace_All (the_typeMap,
                                     "$input",
                                     Attribute (the_Parameter, "emit:input"));
                        append (cleanup_Code,  the_typeMap & NL);
                        the_Parameter := get_Attribute (the_Parameter,  "tmap:freearg:next");
                     else
                        the_Parameter := next_Sibling (the_Parameter);
                     end if;
                  end;
               end loop;
            end;
         end gather_the_cleanup_Code;



         procedure gather_the_argout_Code
         --
         --  The code which gives values back through the arguments ('argout' typemaps).
         --
         is
         begin
            --  Insert argument output code.
            --
            declare
               the_Parameter : Node_Pointer := Node_Pointer (the_Parameters);
            begin
               while the_Parameter /= null
               loop
                  declare
                     the_typeMap : unbounded_String := +Attribute (the_Parameter, "tmap:argout");
                  begin
                     if the_typeMap /= ""
                     then
                        replace_All (the_typeMap, "$arg",    Attribute (the_Parameter, "emit:input"));     -- Deprecated ?
                        replace_All (the_typeMap, "$input",  Attribute (the_Parameter, "emit:input"));
                        replace_All (the_typeMap, "$result", "jresult");

                        append (argout_Code,  the_typeMap & NL);

                        the_Parameter := get_Attribute (the_Parameter, "tmap:argout:next");
                     else
                        the_Parameter := next_Sibling (the_Parameter);
                     end if;
                  end;
               end loop;
            end;
         end gather_the_argout_Code;



         procedure give_a_Constant_its_Action
         --
         --  A constant is wrapped as a function which returns its value.
         --
         is
         begin
            if String'(+node_Type (the_Node)) = "constant"
            then
               Swig_save_1 (to_C ("functionWrapper"), the_Node, to_C ("wrap:action"));      -- Wrapping a constant hack. (TODO: This is usual swig hack)

               declare      -- Below based on Swig_VargetToFunction().
                  use swigMod.Language;
                  the_Type : constant SwigType_Pointer := SwigType_Pointer (Swig_wrapped_var_type (SwigType_Pointer (get_Attribute (the_Node, "type")),
                                                                                                   Self.use_naturalVar_Mode (the_Node)));
               begin
                  set_Attribute (the_Node, "wrap:action",
                                           String' (  "result = ("
                                                    & (+doh_Item (SwigType_lstr (the_Type, null)))
                                                    & ") "
                                                    & Attribute (the_Node, "value")
                                                    & ";"
                                                    & NL));
               end;
            end if;
         end give_a_Constant_its_Action;



         procedure note_the_Type_for_a_Constructor
         --
         --  Keeps the type of the result, less a pointer, as C++ source: the construction functions are written with it.
         --
         is
         begin
            --  Determine C type (for contructors).  (TODO: Fix/remove this hack.)
            --
            declare
               void     : doh_Item with Unreferenced;
               the_Type : constant SwigType_Pointer := SwigType_Pointer (doh_copy (DOH_Pointer (get_Attribute (the_Node,
                                                                                                               "type"))));
            begin
               if SwigType_isPointer (the_Type) /= 0
               then
                  void := doh_Item (SwigType_del_Pointer (the_Type));
               end if;

               Self.current_lStr := +doh_copy (DOH_Pointer (SwigType_lStr (the_Type, null)));
            end;
         end note_the_Type_for_a_Constructor;



         procedure write_the_Call
         --
         --  Writes the call of the function, with whatever the interface file places about it ('%exception', a contract).
         --
         is
         begin
            if not Self.native_function_Flag
            then
               --  Now write code to make the function call.
               --
               declare
                  actionCode : constant String_Pointer := emit_action (N);
                  tm         :          doh_String   with Unreferenced;
                  Status     :          C.int        with Unreferenced;
               begin
                  tm := doh_String (Swig_typemap_lookup_out (const_String (-"out"),
                                                             N,
                                                             const_String (-"result"),
                                                             the_function_Wrapper,
                                                             actionCode));
               end;
            end if;
         end write_the_Call;



         procedure write_the_Result
         --
         --  Writes the code which gives the result to the caller.
         --
         is
         begin
            if not Self.native_function_Flag
            then     -- Return 'result' value, if necessary.
               declare
                  the_typeMap : unbounded_String := +doh_Item (Swig_typemap_lookup (const_String (-"out"),
                                                                                    the_Node,
                                                                                    const_String (-"result"),
                                                                                    null));
               begin
                  if         built_in_Place
                    and then has_exception_Code
                  then
                     print_to (wrapper_Code,   "  if (!swig_ada_built)"                                                                 & NL
                                             & "  {"                                                                                   & NL
                                             & "    typedef " & to_String (c_return_Type) & " swig_ada_result_type;"                   & NL
                                             & "    swig_ada_replace (a_result, *(&result));"                                          & NL
                                             & "  }"                                                                                   & NL);
                  elsif built_in_Place
                  then
                     null;     -- The action has done so.

                  elsif result_by_Parameter
                  then   -- Replace the object of the caller by the result.
                     print_to (wrapper_Code,   "  {"                                                                                     & NL
                                             & "    typedef " & to_String (c_return_Type) & " swig_ada_result_type;"                    & NL
                                             & "    a_result->~swig_ada_result_type ();"                                                 & NL
                                             & "    new (a_result) swig_ada_result_type (*(&result));"                                   & NL
                                             & "  }"                                                                                     & NL);
                  elsif the_typeMap /= ""
                  then
                     replace_All (the_typeMap, "$result", "jresult");

                     --  A pointer result is cast to the type which the wrapper returns, as the two differ where a typemap
                     --  has been applied to another type ('%apply char * { unsigned char * }'), or in their qualifiers.
                     --
                     if         Length (c_return_Type) > 0
                       and then Element (Trim (c_return_Type, ada.Strings.Both), Length (Trim (c_return_Type, ada.Strings.Both))) = '*'
                     then
                        declare
                           White    : constant ada.Strings.Maps.Character_Set := ada.Strings.Maps.to_Set (' ' & ASCII.LF & ASCII.CR & ASCII.HT);
                           the_Code : constant String := ada.Strings.fixed.Trim (to_String (the_typeMap), Left => White, Right => White);
                           Head     : constant String := "jresult = ";
                           Tail     : constant String := "result;";
                        begin
                           if         the_Code'Length >= Head'Length + Tail'Length
                             and then the_Code (the_Code'First .. the_Code'First + Head'Length - 1) = Head
                             and then the_Code (the_Code'Last - Tail'Length + 1 .. the_Code'Last)   = Tail
                           then
                              declare
                                 its_Cast : constant String := ada.Strings.fixed.Trim (the_Code (the_Code'First + Head'Length .. the_Code'Last - Tail'Length),
                                                                                       ada.Strings.Both);
                              begin
                                 if        its_Cast = ""
                                   or else (         its_Cast (its_Cast'First) = '('
                                            and then its_Cast (its_Cast'Last)  = ')'
                                            and then ada.Strings.fixed.Index (its_Cast, ";") = 0)
                                 then
                                    the_typeMap := +("  jresult = (" & to_String (c_return_Type) & ") result;");
                                 end if;
                              end;
                           end if;
                        end;
                     end if;

                     print_to (wrapper_Code, the_typeMap & NL);

                  elsif not is_Void_return
                  then
                     dlog (+ "Unable to use return type "
                          & String'(+swig_Type)
                          & " in function "
                          & Attribute (the_Node, "name")
                          & NL);
                  end if;
               end;
            end if;
         end write_the_Result;



         procedure write_the_remaining_Cleanup
         --
         --  The 'newfree' and 'ret' typemaps of the result.
         --
         is
         begin
            if get_Attribute (the_Node, "feature:new") /= null
            then   -- Look to see if there is any newfree cleanup code.
               declare
                  the_typeMap : constant unbounded_String := +doh_Item (Swig_typemap_lookup (const_String (-"newfree"),
                                                                                             the_Node,
                                                                                             const_String (-"result"),
                                                                                             null));
               begin
                  if the_typeMap /= ""
                  then
                     print_to (wrapper_Code, the_typeMap & NL);
                  end if;
               end;
            end if;


            if not Self.native_function_Flag
            then   -- See if there is any return cleanup code.
               declare
                  the_typeMap : constant unbounded_String := +doh_Item (Swig_typemap_lookup (const_String (-"ret"),
                                                                                             the_Node,
                                                                                             const_String (-"result"),
                                                                                             null));
               begin
                  if the_typeMap /= ""
                  then
                     dlog ("CLEANUP '" & (+the_typeMap) &  "'");
                  end if;
               end;
            end if;
         end write_the_remaining_Cleanup;



         procedure finish_the_Definition
         --
         --  Ends the definition, and gives each special variable of the code its value.
         --
         is
         begin
            --  Finish C function definitions.
            --
            if result_by_Parameter
            then
               print_to (wrapper_Def, to_String ((if has_Parameters then +("," & NL) else +"") & c_return_Type & " * a_result"));
            end if;

            print_to (wrapper_Def, ")" & NL & "{" & NL);

            if not is_Void_return
            then
               print_to (wrapper_Code, "    return jresult;" & NL);     -- TODO: Change 'jresult' to 'ada_result'.
            end if;

            print_to        (wrapper_Code, "}" & NL);
            doh_replace_All (wrapper_Code, -"$cleanup",               -cleanup_Code);                      -- Substitute the cleanup code.
            doh_replace_All (wrapper_Code, -"$isvoid",                -(if is_Void_return then "1" else "0"));     -- Whether the function returns nothing.
            doh_replace_All (wrapper_Code, -"$symname",               -sym_Name);                          -- And the name which the function is bound by.
            doh_replace_All (wrapper_Code, -"SWIG_contract_assert(",  -"SWIG_contract_assert($null, ");    -- Contract macro modification.

            if returns_a_Class
            then   -- A class or structure is returned: bytes of zero, as a value of the class may not be one which can be made.
               doh_replace_All (wrapper_Code, -"$null", -(if Self.in_cpp_Mode then "swig_ada_no_result< " & to_String (c_return_Type) & " > ()"
                                                                              else "(" & to_String (c_return_Type) & ") {0}"));
            elsif not is_Void_return
            then   doh_replace_All (wrapper_Code, -"$null", -"0");
            else   doh_replace_All (wrapper_Code, -"$null", -"");
            end if;
         end finish_the_Definition;



         procedure add_to_the_Model
         --
         --  Makes a function of the C model, unless it is a member of a class, which its own handler makes.
         --
         is
         begin
            if not (Self.is_wrapping_Class /= 0)   -- Ignore class member functions.
            then
               declare
                  the_new_Function : c_Function.view;
               begin
                  the_new_Function := Self.new_c_Function (the_Node,
                                                           +sym_Name,
                                                           Self.nameSpace_std,
                                                           is_Destructor => False);

                  Self.current_Module.C.new_c_Functions   .append (the_new_Function);
                  Self.current_Module.C.new_c_Declarations.append (the_new_Function.all'Access);

                  Self.prior_c_Declaration := the_new_Function.all'Access;
               end;
            end if;

            --  The 'get' or the 'set' function of a member variable (see 'memberVariableHandler').
            --
            if Self.accessor_member_Name /= ""
            then
               declare
                  the_Name     : constant String  := sym_Name;
                  is_Setter    : constant Boolean := the_Name'Length > 4 and then the_Name (the_Name'First .. the_Name'First + 3) = "set_";     -- The core names them 'set_<class>_<member>' and 'get_...'.
                  the_Accessor : c_Function.view;
               begin
                  the_Accessor := Self.new_c_Function (the_Node,
                                                       (if is_Setter then "set_" & Self.accessor_member_Name
                                                                     else Self.accessor_member_Name),
                                                       Self.current_c_Class.nameSpace.all'Access,
                                                       is_Destructor => False);
                  pragma Unreferenced (the_Accessor);
               end;
            end if;
         end add_to_the_Model;



      begin
         Swig_typemap_attach_parms (const_String (-"ctype"),  the_Parameters, the_function_Wrapper);  -- Attach the non-standard typemaps to the parameter list.
         Swig_typemap_attach_parms (const_String (-"imtype"), the_Parameters, the_function_Wrapper);

         begin_the_Definition;

         emit_parameter_variables (the_Parameters,
                                   the_function_Wrapper);        -- Emit all local variables for holding arguments.

         construct_the_Result_in_Place;

         if        not built_in_Place
           or else has_exception_Code
         then
            emit_return_variable  (the_Node,
                                   SwigType_Pointer (swig_Type),
                                   the_function_Wrapper);
         end if;
         emit_attach_parmMaps     (the_Parameters,
                                   the_function_Wrapper);        -- Attach the standard typemaps.

         --  Parameter overloading.
         --
         set_Attribute (the_Node, "wrap:parms", String_Pointer (the_Parameters));
         set_Attribute (the_Node, "wrap:name",  wrapper_Name);

         if get_Attribute (the_Node, "sym:overloaded") /= null
         then     -- Wrappers not wanted for some methods where the parameters cannot be overloaded in Ada.
            Swig_overload_check (the_Node);                      -- Emit warnings for the few cases that can't be overloaded in Ada and give up on generating wrapper.

            if get_Attribute (the_Node, "overload:ignore") /= null
            then
               unindent_Log;
               return SWIG_OK;
            end if;
         end if;

         --  Get number of required and total arguments.
         --
         num_arguments := Natural (emit_num_arguments (the_Parameters));
         num_required  := Natural (emit_num_required  (the_Parameters));

         write_the_Parameters;
         gather_the_cleanup_Code;
         gather_the_argout_Code;

         give_a_Constant_its_Action;
         note_the_Type_for_a_Constructor;
         write_the_Call;

         if String'(+node_Type (the_Node)) = "constant"
         then
            Swig_restore (the_Node);
         end if;

         write_the_Result;

         print_to (wrapper_Code, argOut_Code);       -- Output argument output code.
         print_to (wrapper_Code, cleanup_Code);      -- Output cleanup         code.

         write_the_remaining_Cleanup;
         finish_the_Definition;

         --  A protected member is given a wrapper too (the bindings to swig itself call some). Such a wrapper compiles
         --  only where access is opened to it: by '#define protected public' ahead of the class, as 'swigmod.i' does,
         --  or by the '-fno-access-control' switch of g++.
         --
         if    not Self.native_function_Flag
           and not Self.doing_constructorDeclaration
         then
            Wrapper_print (the_function_Wrapper, Self.f_Wrappers);      -- Dump the function out.
         end if;

         add_to_the_Model;

         delWrapper (the_function_Wrapper);
      end;
   end;

   dlog (+"end functionWrapper.");
   unindent_Log;
   return SWIG_OK;
end functionWrapper;
