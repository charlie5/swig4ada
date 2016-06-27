with
     swigg.Language,
     swigg.Pointers,
     swig_Module,

     c_Type,
     c_Variable,
     c_Parameter,
     c_Function,

     ada_Type,
     ada_Variable,

     c_nameSpace,
     ada_Package,

     swig.Pointers,
     interfaces.C;


--  old ...
--

with doh_Support;
--  with swig_p_p_char;

with GMP.discrete;

with ada.containers.hashed_maps;
with ada.containers.hashed_sets;

with Ada.Strings.Unbounded.Hash;
with ada.Strings.unbounded;   use ada.Strings.unbounded;

with system;
with ada_Parameter; use ada_Parameter;
with ada_Subprogram; use ada_Subprogram;
with c_Declarable; use c_Declarable;


package gnat_Language
--
--
--
is
   use GMP,
       GMP.discrete;

   use doh_Support;


   type Item is new swigg.Language.item with private;
--     type View is access all Item'class;
--
--
--     --  Operations
--     --
--
--  --     overriding procedure main
--  --       (Self : in out Item;
--  --        argc : in Integer;
--  --        argv : in swig.Pointers.chars_ptr_Pointer);
--
--     overriding
--     procedure main
--       (Self : in out Item;
--        argc : in     Interfaces.C.int;
--        argv : in     Swig.Pointers.chars_ptr_Pointer);
--
--
--
--  --     overriding function top
--  --       (Self : access Item;
--  --        n    : in     doh_Node'Class) return Integer;
--
--
--     overriding
--     function top
--       (Self : in Item;
--        n    : in swigg.Pointers.Node_Pointer) return Interfaces.C.int;
--
--
--
--
--  --     overriding function classforwardDeclaration
--  --       (Self : access Item;
--  --        n    : in     doh_Node'Class) return Integer;
--
--     overriding
--     function classforwardDeclaration
--       (Self : in Item;
--        n    : in swigg.Pointers.Node_Pointer) return Interfaces.C.int;
--
--
--
--
--
--
--  --     overriding function nativeDirective
--  --       (Self : access Item;
--  --        n    : in     doh_Node'Class) return Integer;
--
--
--     overriding
--     function nativeDirective
--       (Self : in Item;
--        n    : in swigg.Pointers.Node_Pointer) return Interfaces.C.int;
--
--
--
--
--  --     overriding function functionWrapper
--  --       (Self : access Item;
--  --        n    : in     doh_Node'Class) return Integer;
--
--
--     overriding
--     function functionWrapper
--       (Self : in Item;
--        n    : in swigg.Pointers.Node_Pointer) return Interfaces.C.int;
--
--
--
--
--  --     overriding function globalvariableHandler
--  --       (Self : access Item;
--  --        n    : in doh_Node'Class) return Integer;
--
--     overriding
--     function globalvariableHandler
--       (Self : in Item;
--        n    : in swigg.Pointers.Node_Pointer) return Interfaces.C.int;
--
--
--
--
--  --     overriding function enumDeclaration
--  --       (Self : access Item;
--  --        n    : in     doh_Node'Class) return Integer;
--
--     overriding
--     function enumDeclaration
--       (Self : in Item;
--        n    : in swigg.Pointers.Node_Pointer) return Interfaces.C.int;
--
--
--  --     overriding function enumvalueDeclaration
--  --       (Self : access Item;
--  --        n    : in     doh_Node'Class) return Integer;
--
--     overriding
--     function enumvalueDeclaration
--       (Self : in Item;
--        n    : in swigg.Pointers.Node_Pointer) return Interfaces.C.int;
--
--
--
--
--  --     overriding function constantWrapper
--  --       (Self : access Item;
--  --        n    : in     doh_Node'Class) return Integer;
--
--     overriding
--     function constantWrapper
--       (Self : in Item;
--        n    : in swigg.Pointers.Node_Pointer) return Interfaces.C.int;
--
--
--  --     overriding function classHandler
--  --       (Self : access Item;
--  --        n    : in     doh_Node'Class) return Integer;
--
--     overriding
--     function classHandler
--       (Self : in Item;
--        n    : in swigg.Pointers.Node_Pointer) return Interfaces.C.int;
--
--
--
--
--  --     overriding function usingDeclaration
--  --       (Self : access Item;
--  --        n    : in     doh_Node'Class)
--  --        return Integer;
--
--     overriding
--     function usingDeclaration
--       (Self : in Item;
--        n    : in swigg.Pointers.Node_Pointer) return Interfaces.C.int;
--
--
--  --     overriding function memberfunctionHandler
--  --       (Self : access Item;
--  --        n    : in     doh_Node'Class) return Integer;
--
--     overriding
--     function memberfunctionHandler
--       (Self : in Item;
--        n    : in swigg.Pointers.Node_Pointer) return Interfaces.C.int;
--
--
--  --     overriding function staticmemberfunctionHandler
--  --       (Self : access Item;
--  --        n    : in doh_Node'Class) return Integer;
--
--     overriding
--     function staticmemberfunctionHandler
--       (Self : in Item;
--        n    : in swigg.Pointers.Node_Pointer) return Interfaces.C.int;
--
--
--  --     overriding function constructorHandler
--  --       (Self : access Item;
--  --        n    : in doh_Node'Class) return Integer;
--
--     overriding
--     function constructorHandler
--       (Self : in Item;
--        n    : in swigg.Pointers.Node_Pointer) return Interfaces.C.int;
--
--
--  --     overriding function destructorHandler
--  --       (Self : access Item;
--  --        n    : in doh_Node'Class) return Integer;
--
--     overriding
--     function destructorHandler
--       (Self : in Item;
--        n    : in swigg.Pointers.Node_Pointer) return Interfaces.C.int;
--
--
--  --     overriding function membervariableHandler
--  --       (Self : access Item;
--  --        n    : in doh_Node'Class) return Integer;
--
--     overriding
--     function membervariableHandler
--       (Self : in Item;
--        n    : in swigg.Pointers.Node_Pointer) return Interfaces.C.int;
--
--
--  --     overriding function staticmembervariableHandler
--  --       (Self : access Item;
--  --        n    : in     doh_Node'Class) return Integer;
--
--     overriding
--     function staticmembervariableHandler
--       (Self : in Item;
--        n    : in swigg.Pointers.Node_Pointer) return Interfaces.C.int;
--
--
--
--  --     overriding function memberconstantHandler
--  --       (Self : access Item;
--  --        n    : in doh_Node'Class) return Integer;
--
--
--     overriding
--     function memberconstantHandler
--       (Self : in Item;
--        n    : in swigg.Pointers.Node_Pointer) return Interfaces.C.int;
--
--
--
--  --     overriding function typedefHandler
--  --       (Self : access Item;
--  --        n    : in     doh_Node'Class) return Integer;
--
--     overriding
--     function typedefHandler
--       (Self : in Item;
--        n    : in swigg.Pointers.Node_Pointer) return Interfaces.C.int;
--
--
--  --     overriding function insertDirective
--  --       (Self : access Item;
--  --        n    : in doh_Node'Class) return Integer;
--
--     --  tbd: other directive functions !!
--
--
--     overriding
--     function insertDirective
--       (Self : in Item;
--        n    : in swigg.Pointers.Node_Pointer) return Interfaces.C.int;
--
--
--
--  --     overriding function namespaceDeclaration
--  --       (Self : access Item;
--  --        n    : in     doh_Node'Class) return Integer;
--
--     overriding
--     function namespaceDeclaration
--       (Self : in Item;
--        n    : in swigg.Pointers.Node_Pointer) return Interfaces.C.int;
--
--
--  --     overriding function moduleDirective
--  --       (Self : access Item;
--  --        n    : in     doh_Node'Class) return Integer;
--
--     overriding function moduleDirective
--       (Self : in Item;
--        n    : in swigg.Pointers.Node_Pointer) return Interfaces.C.int;
--
--
--  --     overriding function includeDirective
--  --       (Self : access Item;
--  --        n    : in     doh_Node'Class) return Integer;
--
--     overriding
--     function includeDirective
--       (Self : in Item;
--        n    : in swigg.Pointers.Node_Pointer) return Interfaces.C.int;
--
--
--
--  --     overriding function typemapDirective
--  --       (Self : access Item;
--  --        n    : in     doh_Node'Class) return Integer;
--
--     overriding
--     function typemapDirective
--       (Self : in Item;
--        n    : in swigg.Pointers.Node_Pointer) return Interfaces.C.int;
--
--
--     function to_ada_subProgram (Self : access Item;   the_c_Function   : in    c_Function.view)    return ada_subProgram.View;
--     function to_Descriptor     (Self : access Item;   swig_Type        : in    doh_swigType)       return unbounded_String;
--     function to_ada_Parameters (Self : access Item;   the_c_Parameters : in    c_parameter.Vector) return ada_Parameter.vector;
--     function to_ada_Variable   (Self : access Item;   the_c_Variable   : in    c_Variable.view)    return ada_Variable.view;
--
--
--
private
--
--     --  Hook to swig_main (on the c-side).
--     --
--     function swig_gnat return system.Address;
--     pragma Export (C, swig_gnat);
--
--
--
--
   --  symbol_value_Maps
   --
   package symbol_value_Maps is new ada.containers.hashed_maps (unbounded_String,
                                                                discrete.Integer,
                                                                Ada.Strings.Unbounded.Hash, "=");
--     use symbol_value_maps;



   --  namespace_Sets
   --
   --   function sort_by_large_to_small (Left, Right : in unbounded_String) return Boolean;
   --  package namespace_Sets is new ada.containers.ordered_Sets (unbounded_String, "<" => sort_by_large_to_small);
   package namespace_Sets is new ada.containers.hashed_Sets (unbounded_String, Ada.Strings.Unbounded.Hash, "=");
   use namespace_Sets;


   --  New ...
   --

   subtype swig_Type is unbounded_String;

   --  swig_type_Maps_of_c_type
   --
   use type c_Type.view;
   package swig_type_Maps_of_c_type is new ada.containers.hashed_maps (swig_Type,
                                                                       c_Type.view,
                                                                       ada.strings.Unbounded.Hash, "=");
   use swig_type_Maps_of_c_type;



   --  'gnat_Language' Item
   --
   type Item is new swigg.Language.item with
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
         --           Package_interfaces_c_extensions : ada_Package.view;

         Package_swig            :         ada_Package.view;
         Package_swig_pointers   :         ada_Package.view;

         incomplete_access_to_Type_i_c_pointer_List
                                 :         ada_Type.vector;

         symbol_value_Map        : aliased symbol_value_maps.Map;

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
         proxy_Flag              :         Boolean           := True;        -- Flag for generating proxy classes.
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

         --  C runtime
         --
         f_runtime               :         doh_File;
         f_header                :         doh_File;
         f_wrappers              :         doh_File;
         f_init                  :         doh_File;
         f_gnat                  :         doh_File;                         -- contains gnat specific c++ declarations and code

         current_linkage_Symbol  :         unbounded_String;
         current_lStr            :         unbounded_String;

         --  Old
         --

--           current_Node            :         doh_Node;

--           current_class_swig_classType,
--           current_class_swig_Type :         unbounded_String;

--           last_enum_rep_value     :         Long_Long_Integer := -1;

--           all_types_Container     :         gnat_Language.all_types_Container.view;

--           current_Package         :         gnat_Package.view;               -- the package currently being processed
--           current_class_Record    :         gnat_Type.view;                  -- the class record curently being processed
--           all_Packages            :         swig_type_package_Maps.Map;       -- all Ada packages

--           standard_Package        :         gnat_Package.view;
--           namespace_Package       :         gnat_Package.view;                -- the top 'namespace' package
--           binding_Package         :         gnat_Package.view;                -- the main 'Binding' package containing C functions as Ada
--           types_Package           :         gnat_Package.view;                -- contains binding to all simple C types
--           conversions_Package     :         gnat_Package.view;

--           current_Enum            :         gnat_Type.view;
      end record;



--     function current_c_Namespace  (Self : access Item) return c_nameSpace.view;
--     function current_c_Class      (Self : access Item) return c_Type.view;     -- the class record curently being processed
--
--     function new_c_Function       (Self : access Item;   the_Node          : in     doh_Node;
--                                                          function_name     : in     unbounded_String;
--                                                          nameSpace         : in     c_nameSpace.view;
--                                                          is_Constructor    : in     Boolean           := False) return c_Function.view;
--
--     function to_c_Parameters      (Self : access Item;   swig_Parameters   : in     doh_ParmList) return c_parameter.Vector;
--
--     procedure register            (Self : access Item;   the_c_Type        : in     c_Type.view;
--                                                          the_swig_Type     : in     doh_swigType;
--                                                          is_core_C_type    : in     Boolean           := False;
--                                                          create_array_Type : in     Boolean           := True;
--                                                          add_level_3_Indirection
--                                                                            : in     Boolean           := False);
--
--     procedure add_array_Bounds_to (Self : access Item;   the_Variable      : in     c_Variable.view;
--                                                          from_swig_Type    : in     doh_swigType);
--
--     --  convenience
--     --
--
--     function fetch_ada_Type       (Self : access Item;   Named : in unbounded_String) return ada_Type.view;
--     function fetch_c_Type         (Self : access Item;   Named : in unbounded_String) return   c_Type.view;
--
--     function demand_c_Type_for    (Self : access Item;  the_doh_swig_Type
--                                                             : in     doh_swigType) return c_Type.view;
--
--     function current_Module       (Self : access Item) return swig_Module.swig_Module_view;
--
--     function demand_Module        (Self : access Item;   Named : in unbounded_String) return swig_Module.swig_Module_view;
--
--     function owner_module_Name_of (the_Node : in doh_Node) return String;   -- tbd: make a Node class/package with this (andf others) in it.
--
--
--     --  old ...
--     --
--
--     function get_overloaded_Name    (Self : access Item;   for_Node       : in     doh_Node)  return String;
--
--
--     --  Support
--     --
--     procedure add_new_c_Type      (Self : access Item'Class;   the_new_Type : c_Type.view);
--
--
--     function  current_class_namespace_Prefix
--                                   (Self : access Item) return unbounded_String;
--     --
--     --  Returns the c++ prefix of the current_Class, or an empty string if there is no current_Class.
--
--
--     function my_stripped          (Self : access Item;   swig_Type       : in     doh_swigType) return unbounded_String;
--
--
--     procedure add_Namespace       (Self : access Item;   Named           : in     unbounded_String);
--     --
--     --  The same namespace may safely be added twice (is add is ignored after the 1st)
--
--
--     function makeParameterName    (Self : access Item;   parameter_List  : in     doh_parmList;
--                                                          the_Parameter   : in     doh_Parm;
--                                                          arg_num         : in     Integer)            return String;


--     procedure associate (Self : access Item;   the_ada_Type : in ada_Type.view;
--                                                with_c_Type  : in c_Type  .view);

   -----------
   --  Utility
   --

--     function "+" (Self : in String) return unbounded_String
--                   renames to_unbounded_String;


end gnat_Language;

--  old
--

--     function to_gnat_Parameters   (Self : access Item;   the_Node        : in     doh_Node    'Class;
--                                                          swig_Parameters : in     doh_ParmList'Class) return gnat_parameter.Vector;


   --     function to_enum_rep_Value (Self     : access Item;
   --                                 the_Text : in     unbounded_String) return Integer;

--     function  demand_Type         (Self : access Item;   for_Node      : in     doh_Node'Class;
--                                                          doh_swig_Type : in doh_swigType'Class)     return gnat_Type.view;
--
--     function  demand_Package      (Self : access Item;   swig_Type : in doh_swigType'Class)         return gnat_Package.view;
--     function  fetch_Package       (Self : access Item;   swig_Type : in doh_swigType'Class)         return gnat_Package.view;
--
--     function  old_demand_Package  (Self : access Item;   Named     : in String)                     return gnat_Package.view;
--     function  old_fetch_Package   (Self : access Item;   Named     : in String)                     return gnat_Package.view;

--     function  new_type_wrapper_Package
--                                   (Self : access Item;   the_Node      : in     doh_Node'Class;
--                                                          class_Name    : in     unbounded_String;
--                                                          doh_swig_Type : in     doh_swigType'Class) return gnat_Type.view;
--
--     procedure add_array_Bounds_to (Self : access Item;   the_Variable   : in     gnat_Variable.view;
--                                                          from_swig_Type : in     doh_swigType'Class);

--     function new_Function           (Self : access Item;   the_Node       : in     doh_Node'class;
--                                                            function_name  : in     unbounded_String;
--                                                            parent_Package : in     gnat_Package.view;
--                                                            is_Constructor : in     Boolean := False)
--                                                                                                     return gnat_Subprogram.view;

--     function current_module_Package (Self : access Item;   for_Node       : in     doh_Node'Class)  return gnat_Package.view;




   -----------------------
   --  all_types_Container
   -----------------------

--     package all_types_Container
--     --
--     --  Manages the 'swig_type'/'gnat_type' mapping for all known types.
--     --
--     is
--        type Item is tagged private;
--        type View is access all Item;
--
--        procedure Owner_is (Self : access Item;   Now : in gnat_Language.view);
--
--        --  type management
--        --
--        procedure add_primal_c_Type (Self                        : access Item;
--                                     new_Key                     : in     unbounded_String;
--                                     new_Type                    : in     gnat_Type.view);
--
--        procedure add        (Self      : access Item;
--                              swig_Type : in     doh_swigType'Class;
--                              ada_Type  : in     gnat_Type.view);
--
--        procedure add_Synonym (Self      : access Item;
--                               swig_Type : in     doh_swigType'Class;
--                               ada_Type  : in     gnat_Type.view);
--
--        function  fetch_Type (Self          : access Item;
--                              swig_Type : in     doh_swigType'Class) return gnat_Type.view;
--
--        function  fetch_Type (Self     : access Item;
--                              ada_Type : in     String) return gnat_Type.view;
--
--        function  contains   (Self : access Item;
--                              swig_Type : in doh_swigType'Class) return Boolean;
--
--        function all_Types (Self : access Item) return gnat_Type.Views;
--
--        --  Support
--        --
--        procedure log (Self : access Item);
--
--
--     private
--        package swig_type_gnat_type_Maps is new ada.containers.hashed_maps (unbounded_String,
--                                                                            gnat_Type.view,
--                                                                            Ada.Strings.Unbounded.Hash, "=");
--        use swig_type_gnat_type_Maps;
--
--        type Item is tagged
--           record
--              Owner       : gnat_Language.view;
--              a_all_Types : swig_type_gnat_type_maps.Map;
--           end record;
--
--        --  support
--        --
--        function stripped (Self      : access Item;
--                           swig_Type : in     doh_swigType'Class) return unbounded_String;
--     end all_types_Container;



--     --  swig_type_package_Maps
--     --
--     use     gnat_Package;
--     package swig_type_package_Maps is new ada.containers.hashed_maps (unbounded_String,
--                                                                       gnat_Package.view,
--                                                                       Ada.Strings.Unbounded.Hash, "=");
--     use swig_type_package_Maps;
