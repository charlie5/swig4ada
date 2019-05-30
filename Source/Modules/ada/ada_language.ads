with
     swigMod.Language,
     swig_Module,

     c_Type,
     c_Variable,
     c_Parameter,
     c_Function,
     c_Declarable,
     c_nameSpace,

     ada_Type,
     ada_Variable,
     ada_Parameter,
     ada_Subprogram,
     ada_Package,

     gmp.Discrete,

     swig.Pointers,
     swig_Core.Pointers,

     doh_Support,

     ada.Containers.hashed_Maps,
     ada.Containers.hashed_Sets,

     ada.Strings.Unbounded.Hash,

     interfaces.C,

     System;


package ada_Language
--
-- Provides the derived Ada language class.
--
is
   use ada_Parameter,
       ada_Subprogram,

       c_Declarable,

       GMP,
       GMP.discrete,

       doh_Support,
       ada.Strings.unbounded;

   type Item is new swigMod.Language.item with private;
   type View is access all Item'class;


   ---  Operations
   --

   overriding
   procedure main (Self : in out Item;
                   argc : in     interfaces.c.int;
                   argv : in     swig.pointers.chars_ptr_Pointer);
   overriding
   function top (Self : access Item;
                 n    : in     swig_Core.Pointers.Node_Pointer) return interfaces.c.int;
   overriding
   function classforwardDeclaration (Self : access Item;
                                     n    : in     swig_Core.Pointers.Node_Pointer) return interfaces.c.int;
   overriding
   function nativeDirective (Self : access Item;
                             n    : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;
   overriding
   function functionWrapper (Self : access Item;
                             n    : in     swig_Core.Pointers.Node_Pointer) return interfaces.c.int;
   overriding
   function globalvariableHandler (Self : access Item;
                                   n    : in     swig_Core.Pointers.Node_Pointer) return interfaces.c.int;
   overriding
   function enumDeclaration (Self : access Item;
                             n    : in     swig_Core.Pointers.Node_Pointer) return interfaces.c.int;
   overriding
   function enumvalueDeclaration (Self : access Item;
                                  n    : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;
   overriding
   function constantWrapper (Self : access Item;
                             n    : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;
   overriding
   function classHandler (Self : access Item;
                          n    : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;
   overriding
   function usingDeclaration (Self : access Item;
                              n    : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;
   overriding
   function memberfunctionHandler (Self : access Item;
                                   n    : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;
   overriding
   function staticmemberfunctionHandler (Self : access Item;
                                         n    : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;
   overriding
   function constructorHandler (Self : access Item;
                                n    : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;
   overriding
   function destructorHandler (Self : access Item;
                               n    : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;
   overriding
   function membervariableHandler (Self : access Item;
                                   n    : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;
   overriding
   function staticmembervariableHandler (Self : access Item;
                                         n    : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;
   overriding
   function memberconstantHandler (Self : access Item;
                                   n    : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;
   overriding
   function typedefHandler (Self : access Item;
                            n    : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;
   overriding
   function insertDirective (Self : access Item;
                             n    : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;
   overriding
   function namespaceDeclaration (Self : access Item;
                                  n    : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;
   overriding
   function moduleDirective (Self : access Item;
                             n    : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;
   overriding
   function includeDirective (Self : access Item;
                              n    : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;
   overriding
   function typemapDirective (Self : access Item;
                              n    : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function to_ada_subProgram (Self : access Item;   the_c_Function   : in    c_Function.view)    return ada_subProgram.View;
   function to_Descriptor     (Self : access Item;   swig_Type        : in    doh_swigType)       return unbounded_String;
   function to_ada_Parameters (Self : access Item;   the_c_Parameters : in    c_parameter.Vector) return ada_Parameter.vector;
   function to_ada_Variable   (Self : access Item;   the_c_Variable   : in    c_Variable.view)    return ada_Variable.view;

   Aborted : exception;



private

   --  Hook to swig_main (on the c-side).
   --
   function swig_ada return system.Address;
   pragma Export (C, swig_ada);

   --  symbol_value_Maps
   --
   package symbol_value_Maps is new ada.containers.hashed_maps (unbounded_String,
                                                                discrete.Integer,
                                                                Ada.Strings.Unbounded.Hash, "=");
   use symbol_value_maps;


   --  namespace_Sets
   --
   package namespace_Sets is new ada.containers.hashed_Sets (unbounded_String, Ada.Strings.Unbounded.Hash, "=");
   use namespace_Sets;


   subtype swig_Type is unbounded_String;

   --  swig_type_Maps_of_c_type
   --
   use type c_Type.view;
   package swig_type_Maps_of_c_type is new ada.containers.hashed_maps (swig_Type,
                                                                       c_Type.view,
                                                                       ada.strings.Unbounded.Hash, "=");
   use swig_type_Maps_of_c_type;



   --  'ada_Language' Item
   --
   type Item is new swigMod.Language.item with
      record
         --  Maps
         --
         name_Map_of_c_type      :         c_Type  .name_Maps_of_c_type  .Map;
         name_Map_of_ada_type    :         ada_Type.name_Maps_of_ada_type.Map;

         swig_type_Map_of_c_type :         swig_type_Maps_of_c_type            .Map;
         c_type_Map_of_ada_type  :         swig_Module.c_type_Maps_of_ada_type .Map;

         c_type_Map_of_ada_subprogram
                                 :         swig_Module.c_type_Maps_of_ada_subprogram  .Map;
         c_namespace_Map_of_ada_Package
                                 :         swig_Module.c_namespace_Maps_of_ada_Package.Map;
         --  Modules
         --
         name_Map_of_module      :         swig_Module.name_Maps_of_module.Map;
         new_Modules             :         swig_Module.module_vectors.Vector;
         Module_core             : aliased swig_Module.item;
         Module_top              : aliased swig_Module.item;

         --  C Namespaces
         --
         nameSpace_std           :         c_nameSpace.view;
         c_namespace_Stack       :         c_nameSpace.vector;
         a_Namespaces            :         namespace_sets.Set;              -- tbd: Make a hashed set, as length ordering is no longer important.

         --  'standard' Ada Packages
         --
         Package_standard        :         ada_Package.view;
         Package_system          :         ada_Package.view;

         Package_interfaces      :         ada_Package.view;
         Package_interfaces_c    :         ada_Package.view;
         Package_interfaces_c_strings
                                 :         ada_Package.view;

         Package_swig            :         ada_Package.view;
         Package_swig_pointers   :         ada_Package.view;


         incomplete_access_to_Type_i_c_pointer_List
                                 :         ada_Type.vector;

         integer_symbol_value_Map : aliased symbol_value_maps.Map;

         --  'current' Declarations
         --
         current_c_Node          :         doh_Node;
         c_class_Stack           :         c_Type.vector;        -- The last element is 'current_c_Class'.
         prior_c_Declaration     :         c_Declarable.view;

         --  Enums
         --
         current_c_Enum          :         c_Type.view;
         last_c_enum_rep_value   :         Long_Long_Integer := -1;
         anonymous_c_enum_Count  :         Natural           := 0;
         anonymous_enum_Count    :         Natural           := 0;

         --  Flags
         --
         in_cpp_Mode             :         Boolean           := False;
         native_function_Flag    :         Boolean           := False;
         enum_constant_Flag      :         Boolean           := False;       -- Flag for wrapping an enum or constant.
         static_flag             :         Boolean           := False;       -- Flag for wrapping a static functions or member variables.
         wrapping_member_flag    :         Boolean           := False;       -- Flag for wrapping a member variable/enum/const.
         is_anonymous_Enum       :         Boolean           := False;

         variable_wrapper_flag   :         Boolean           := False;       -- Flag for wrapping a nonstatic member variable. tbd: possibly oboslete.
         have_default_constructor_flag
                                 :         Boolean           := False;       -- tbd: Possibly obsolete.
         enum_rep_clause_required
                                 :         Boolean           := False;       -- tbd: Possibly obsolete.
         doing_constructorDeclaration :    Boolean           := False;

         --  C Runtime
         --
         f_runtime               :         swig_Core.Pointers.File_Pointer;
         f_header                :         swig_Core.Pointers.File_Pointer;
         f_wrappers              :         swig_Core.Pointers.File_Pointer;
         f_init                  :         swig_Core.Pointers.File_Pointer;
         f_Ada                   :         swig_Core.Pointers.File_Pointer;     -- Contains Ada specific c++ declarations and code.

         current_linkage_Symbol  :         unbounded_String;
         current_lStr            :         unbounded_String;
      end record;


   function current_c_Namespace  (Self : access Item) return c_nameSpace.view;
   function current_c_Class      (Self : access Item) return c_Type.view;       -- The class record curently being processed.

   function new_c_Function (Self : access Item;   the_Node       : in     doh_Node;
                                                  function_name  : in     unbounded_String;
                                                  nameSpace      : in     c_nameSpace.view;
                                                  is_Destructor  : in     Boolean;
                                                  is_Constructor : in     Boolean := False;
                                                  is_Overriding  : in     Boolean := False) return c_function.view;

   function to_c_Parameters (Self : access Item;   swig_Parameters   : in     doh_ParmList) return c_parameter.Vector;

   procedure register (Self : access Item;   the_c_Type              : in     c_Type.view;
                                             to_swig_Type            : in     doh_swigType;
                                             is_core_C_type          : in     Boolean           := False;
                                             create_array_Type       : in     Boolean           := True;
                                             add_level_3_Indirection : in     Boolean           := False);

   procedure add_array_Bounds_to (Self : access Item;   the_Variable   : in     c_Variable.view;
                                                        from_swig_Type : in     doh_swigType);


   ---  Utility
   --

   function fetch_ada_Type       (Self : access Item;   Named             : in     unbounded_String)  return ada_Type.view;
   function fetch_c_Type         (Self : access Item;   Named             : in     unbounded_String)   return   c_Type.view;

   function demand_c_Type_for    (Self : access Item;   the_doh_swig_Type : in     doh_swigType) return c_Type.view;

   function current_Module       (Self : access Item)                                                  return swig_Module.swig_Module_view;
   function demand_Module        (Self : access Item;   Named             : in     unbounded_String)   return swig_Module.swig_Module_view;

   function get_overloaded_Name  (for_Node          : in     doh_Node)     return String;


   procedure add_new_c_Type      (Self : access Item'Class;
                                                        the_new_Type      : in     c_Type.view);

   function  current_class_namespace_Prefix
                                 (Self : access Item) return unbounded_String;
   --
   --  Returns the c++ prefix of the current_Class, or an empty string if there is no current_Class.


   function my_stripped          (Self : access Item;   swig_Type         : in     doh_swigType) return unbounded_String;

   procedure add_Namespace       (Self : access Item;   Named             : in     unbounded_String);
   --
   --  The same namespace may safely be added twice (is add is ignored after the 1st)

   function makeParameterName (parameter_List    : in     doh_parmList;
                               the_Parameter     : in     doh_Parm;
                               arg_num           : in     Integer) return String;

   procedure associate (Self : access Item;   the_ada_Type      : in     ada_Type.view;
                                              with_c_Type       : in     c_Type  .view);

   function "+" (From : in String) return unbounded_String
                 renames to_unbounded_String;
end ada_Language;
