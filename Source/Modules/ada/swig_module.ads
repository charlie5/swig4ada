with
     c_Module,
     c_Type,
     c_Function,
     c_Namespace,

     ada_Module,
     ada_Package,
     ada_Type,
     ada_Subprogram,

     ada.Strings.unbounded.Hash,
     ada.containers.hashed_maps,
     ada.Containers.Vectors,
     ada.Unchecked_Conversion;


package swig_Module
--
--  Contains the C and Ada declarations for a swig interface module.
--
is
   use ada.Strings.unbounded;


   type Item is tagged
      record
         Name      : unbounded_String;
         is_Import : Boolean         := False;

         C         :   c_Module.item;
         Ada       : ada_Module.item;
      end record;

   type swig_Module_view is access all Item'Class;


   procedure define (Self : in out Item;   Name                 : in unbounded_String;
                                           the_standard_Package : in ada_Package.view);


   --  Containers
   --

   package name_Maps_of_module is new ada.containers.hashed_maps (unbounded_String,
                                                                  swig_Module_view,
                                                                  ada.strings.Unbounded.Hash, "=");

   package module_Vectors is new ada.Containers.Vectors (Positive, swig_Module_view);



   function Hashed is new ada.Unchecked_Conversion (c_Type.view,  ada.Containers.Hash_Type);
   use type   c_Type.view,
            ada_Type.view;
   package c_type_Maps_of_ada_type is new ada.containers.hashed_maps (c_Type  .view,
                                                                      ada_Type.view,
                                                                      Hashed, "=");

   use type ada_Subprogram.view;
   package c_type_Maps_of_ada_subprogram is new ada.containers.hashed_maps (c_Type.view,
                                                                            ada_Subprogram.view,
                                                                            Hashed, "=");


   function Hashed is new ada.Unchecked_Conversion (ada_subProgram.view, ada.Containers.Hash_Type);
   use type c_Function.view;

   package ada_subprogram_Maps_of_c_function is new ada.containers.hashed_maps (ada_subProgram.view,
                                                                                c_Function.view,
                                                                                Hashed, "=");


   use type ada_Package.view,  c_Namespace.view;
   function Hashed is new ada.Unchecked_Conversion (c_Namespace.view,  ada.Containers.Hash_Type);

   package c_namespace_Maps_of_ada_Package is new ada.containers.hashed_maps (c_Namespace.view,
                                                                              ada_Package.view,
                                                                              Hashed, "=");

end swig_Module;
