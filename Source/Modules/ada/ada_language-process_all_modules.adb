separate (ada_Language)


procedure process_all_Modules (Self : in out ada_Language.item)
is

   procedure resolve_function_Pointers (the_Module : in swig_Module.swig_Module_view)
   --
   --  Makes a function pointer type of each unknown type which is a pointer to a function (such as
   --  the type of the parameter in 'int do_op (int (*op)(int, int))', which has no typedef).
   --
   is
      use c_Type.Vectors;
      Cursor : c_Type.Cursor := the_Module.C.new_c_Types.First;

   begin
      while has_Element (Cursor)
      loop
         declare
            use c_Type;

            the_c_Type       : constant c_Type.view      := Element (Cursor);
            the_doh_swigType : constant doh_Swigtype     := doh_Swigtype (-to_String (the_c_Type.Name));
            Pad              :          SwigType_Pointer := SwigType_Pointer (doh_Copy (the_doh_swigType));
         begin
            if the_c_Type.is_Ignored
            then
               null;

            elsif the_c_Type.c_type_Kind = Unknown
            then
               if is_a_function_Pointer (the_doh_swigType)
               then
                  Pad := SwigType_del_Pointer (Pad);
                  declare
                     raw_swigType           : constant doh_SwigType := doh_Copy     (Doh_Pointer (Pad));
                     the_Function           : constant doh_SwigType := doh_SwigType (SwigType_pop_function (SwigType_Pointer (raw_swigType)));
                     function_return_Type   : constant doh_SwigType := doh_Copy     (raw_swigType);
                     function_Parameters    : constant doh_ParmList := doh_ParmList (SwigType_function_parms (SwigType_Pointer (the_Function),
                                                                                     null));
                     new_c_Function         : c_Function.view;
                     new_c_function_Pointer : c_Type.view;
                  begin
                     new_c_Function            := c_function.new_c_Function   (to_unbounded_String ("anonymous"),
                                                                               Self.swig_type_Map_of_c_type.Element (+function_return_Type));
                     new_c_Function.Parameters := Self.to_c_Parameters        (function_Parameters);
                     new_c_function_Pointer    := c_type.new_function_Pointer (Namespace         =>  Self.current_c_Namespace,
                                                                               Name              => +the_doh_swigType,
                                                                               accessed_Function =>  new_c_Function);
                     the_c_Type.all            := new_c_function_Pointer.all;
                  end;
               else
                  dlog ("Unable to transform unknown C type: " & the_c_Type.Name);
               end if;
            end if;
         end;

         next (Cursor);
      end loop;
   end resolve_function_Pointers;



   procedure process (the_Module : in swig_Module.swig_Module_view)
   is
      new_ada_subPrograms                  : ada_subProgram.vector;
      the_ada_subprogram_Map_of_c_function : swig_Module.ada_subprogram_Maps_of_c_function.Map;
   begin
      resolve_function_Pointers (the_Module);

      Transformer.transform (From                                       => the_Module.C,
                             Self                                       => Self,
                             name_Map_of_c_type                         => Self.name_Map_of_c_type,
                             name_Map_of_ada_type                       => Self.name_Map_of_ada_type,
                             c_type_Map_of_ada_type                     => Self.c_type_Map_of_ada_type,
                             incomplete_access_to_Type_i_c_pointer_List => Self.incomplete_access_to_Type_i_c_pointer_List,
                             c_type_Map_of_ada_subprogram               => Self.c_type_Map_of_ada_subprogram,
                             new_ada_subPrograms                        => new_ada_subPrograms,
                             the_ada_subprogram_Map_of_c_function       => the_ada_subprogram_Map_of_c_function,
                             c_namespace_Map_of_ada_Package             => Self.c_namespace_Map_of_ada_Package,

                             Result => the_Module.Ada);
   end process;

begin
   --  Process imported modules.
   --
   declare
      use swig_Module.module_Vectors;
      Cursor : swig_Module.module_vectors.Cursor := Self.new_Modules.First;
   begin
      while has_Element (Cursor)
      loop
         dlog ("Transforming module: '" & Element (Cursor).Name & "'");

         -- Set the 'std' C namespace mapping to this modules top level Ada package.
         --
         Self.c_namespace_Map_of_ada_Package.include (Self.nameSpace_std,
                                                      Element (Cursor).Ada.Package_top);
         process (Element (Cursor));
         next             (Cursor);
      end loop;
   end;

   --  The function pointers of the main module are resolved ahead of the pruning, which would otherwise
   --  remove them and the functions which use them.
   --
   resolve_function_Pointers (Self.Module_top'unchecked_Access);

   -- Prune out unknown C types and declarations which depend on such.
   --
   Self.prune_unknown_C_Types;

   --  Process the main module.
   --
   log (+"");
   log (+"");
   log (+"Transforming the main module.");

   -- Set the 'std' C namespace mapping to our top level module top Ada package.
   --
   Self.c_namespace_Map_of_ada_Package.include (Self.nameSpace_std,
                                                Self.Module_top.Ada.Package_top);
   process (Self.Module_top'unchecked_Access);
end process_all_Modules;
