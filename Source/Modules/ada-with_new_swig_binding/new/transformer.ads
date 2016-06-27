with
     swig_Module,
     c_Module,
     ada_Module,

     c_Type,
     ada_Type,
     ada_Subprogram;

with gnat_Language;

package Transformer
--
--  Transforms a C module into an Ada moudle.
--
is

   procedure transform (From                                       : in     c_Module     .item;
                        Self                                       : in out gnat_Language.item;
                        name_Map_of_c_type                         : in out c_Type     .name_Maps_of_c_type    .Map;
                        name_Map_of_ada_type                       : in out ada_Type   .name_Maps_of_ada_type  .Map;
                        c_type_Map_of_ada_type                     : in out swig_Module.c_type_Maps_of_ada_type.Map;
                        incomplete_access_to_Type_i_c_pointer_List : in out ada_Type.Vector;
                        c_type_Map_of_ada_subprogram               : in out swig_Module.c_type_Maps_of_ada_subprogram.Map;
                        new_ada_subPrograms                        : in out ada_subProgram.vector;
                        the_ada_subprogram_Map_of_c_function       : in out swig_Module.ada_subprogram_Maps_of_c_function.Map;
                        c_namespace_Map_of_ada_Package             : in out swig_Module.c_namespace_Maps_of_ada_Package.Map;

                        Result                                     :    out ada_Module.item);

end Transformer;
