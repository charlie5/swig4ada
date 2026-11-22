separate (ada_Language)


function new_c_Function (Self : access Item;   the_Node       : in doh_Node;
                                               function_Name  : in unbounded_String;
                                               nameSpace      : in c_nameSpace.view;
                                               is_Destructor  : in Boolean;
                                               is_Constructor : in Boolean := False;
                                               is_Overriding  : in Boolean := False) return c_Function.view
is
   use c_Parameter.Vectors;

   the_swigType    : SwigType_Pointer  := SwigType_Pointer (doh_Copy (doh_Item (get_Attribute (the_Node, "type"))));
   parameter_list  : doh_ParmList      := doh_parmList (get_Attribute (the_Node, "parms"));
   the_Parameters  : c_Parameter.Vector;

   the_return_Type : c_Type.view;

   use type C.int;
   return_by_Reference : constant Boolean :=        SwigType_isReference        (the_swigType) /= 0
                                             or else SwigType_isrvalue_reference (the_swigType) /= 0;
   return_by_Pointer   : constant Boolean := SwigType_isPointer   (the_swigType) /= 0;

begin
   Self.current_c_Node := the_Node;
   locate (the_Node);

   freshen_current_module_Package (Self, the_Node);

   if Attribute (the_Node, "overload:ignore") /= ""
   then
      return null;   -- Wrappers not wanted for some methods where the parameters cannot be overloaded in Ada.
   end if;

   --  The parameters.
   --
   if exists (parameter_list)
   then
      if SwigType_type (SwigType_Pointer (get_Attribute (Node_Pointer (parameter_list), "type"))) = T_VOID
      then
         parameter_list := doh_parmList (next_Sibling (Node_Pointer (parameter_list)));
      end if;
   end if;

   if         not Self.c_class_Stack.is_Empty
     and then     Self.c_class_Stack.last_Element.Name /= "std"
     and then not Self.static_Flag
     and then not is_Constructor
   then -- Add the class 'Self' controlling parameter.
      declare
         self_Parameter : constant c_Parameter.view := new_c_Parameter (the_name => to_unbounded_String ("Self"),
                                                                        the_type => Self.current_c_Class.all'Access);
      begin
         append (the_Parameters, self_Parameter);
      end;
   end if;

   append (the_Parameters, Self.to_c_Parameters (parameter_List));


   --  The return type.
   --
   if is_Constructor
   then
      the_return_Type := Self.current_c_Class.all'Access;

   elsif is_Destructor
   then
      the_return_Type := Self.swig_type_Map_of_c_type.Element (+"void");

   else
      declare
         use Swigg.Utility;
         virtualType : constant doh_swigType := doh_swigType (get_Attribute (the_Node, "virtual:type"));
      begin
         if exists (virtualType)
         then
            the_return_Type := Self.swig_type_Map_of_c_type.Element (+virtualType);
            dlog (+"covariant return types not supported in Ada ... proxy method will return "
                 & String'(+doh_Item (SwigType_str (SwigType_Pointer (virtualType), null))));     -- TODO: ?
         else
            strip_all_Qualifiers (doh_Item (the_swigType));

            if         Self.accessor_member_Name /= ""
              and then SwigType_isArray (the_swigType) /= 0
            then   -- The function which returns a member which is an array returns a pointer to its first element.
               declare
                  element_Type : unbounded_String := +doh_Item (the_swigType);
               begin
                  while Index (element_Type, "a(") = 1
                  loop
                     element_Type := unbounded_Slice (element_Type, Index (element_Type, ").") + 2, Length (element_Type));
                  end loop;

                  the_return_Type := Self.demand_c_Type_for (doh_swigType (to_Doh ("p." & to_String (element_Type))));
               end;
            else
               the_return_Type := Self.demand_c_Type_for (doh_Item (the_swigType));
            end if;
         end if;
      end;
   end if;

   --  A type which C++ constructs is not returned, but replaces an object of the caller (see 'functionWrapper').
   --
   if         Self.in_cpp_Mode
     and then not is_Constructor
     and then not is_Destructor
     and then returns_a_cpp_constructed_Type (Self, the_Node)
     and then Self.name_Map_of_c_type.contains (the_return_Type.Name & "*")
   then
      declare
         result_Parameter : constant c_Parameter.view := new_c_Parameter (the_Name => to_unbounded_String ("Result"),
                                                                          the_Type => Self.name_Map_of_c_type.Element (the_return_Type.Name & "*"));
      begin
         result_Parameter.is_Pointer := True;
         append (the_Parameters, result_Parameter);
      end;

      the_return_Type := Self.swig_type_Map_of_c_type.Element (+"void");
   end if;


   if not Self.wrapping_member_Flag
   then     -- There is no need for setter/getter functions, since the actual memeber variables are available.
      declare
         use c_nameSpace,
             c_Function;
         new_Function : constant c_Function.view := new_c_Function (function_Name,
                                                                    the_return_Type);
      begin
         new_Function.Parameters     := the_Parameters;
         new_Function.is_Overriding  := is_Overriding;
         new_Function.is_Constructor := is_Constructor;
         new_Function.is_Destructor  := is_Destructor;

         if is_Constructor
         then
            new_Function.link_Symbol := Self.current_linkage_Symbol;
         else
            new_Function.link_Symbol := Self.current_linkage_Symbol;
         end if;

         new_Function.returns_an_Access := return_by_Reference or return_by_Pointer;

         if    check_Attribute (the_Node, "access", "public")
         then
            new_Function.access_Mode := public_Access;

         elsif check_Attribute (the_Node, "access", "protected")
         then
            new_Function.access_Mode := protected_Access;

         elsif check_Attribute (the_Node, "access", "private")
         then
            new_Function.access_Mode := private_Access;

         else
            new_Function.access_Mode := unknown;
         end if;

         if nameSpace = Self.nameSpace_std
         then
            new_Function.is_Static   := True;
         else
            new_Function.is_Static   := Self.static_Flag;
            new_Function.is_Virtual  :=          check_Attribute (the_Node, "storage",  "virtual")
                                        and then C."=" (Self.is_smart_Pointer, 0);     -- A function of the class which a smart pointer points to
                                                                                       -- is no virtual function of the smart pointer.
            new_Function.is_Abstract := check_Attribute (the_Node, "abstract", "1");
         end if;

         nameSpace.add (new_Function.all'Access);
         return new_Function;
      end;
   else
      return null;
   end if;

end new_c_Function;
