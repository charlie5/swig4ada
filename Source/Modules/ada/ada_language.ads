with
     swigMod.Language,

     c_Variable,
     c_Parameter,
     c_Function,
     c_Declarable,

     ada_Variable,
     ada_Parameter,
     ada_Subprogram,

     swig.Pointers,
     swig_Core.Pointers,

     doh_Support,

     ada.Strings.unbounded,
     interfaces.C;

private
with
     swig_Module,

     c_Type,
     c_nameSpace,

     ada_Type,
     ada_Package,

     gmp.Discrete,

     ada.Containers.hashed_Maps,
     ada.Containers.hashed_Sets,
     ada.Containers.indefinite_Vectors,
     ada.Strings.unbounded.Hash,

     System;


package ada_Language
--
-- Provides the derived Ada language class.
--
is
   use ada_Parameter,
       ada_Subprogram,

       doh_Support,
       swig_Core.Pointers,

       Interfaces,
       ada.Strings.unbounded;

   type Item is new swigMod.Language.item with private;
   type View is access all Item'class;


   ---------------
   --- Operations
   --

   overriding
   procedure main (Self : in out Item;
                   argC : in     C.int;
                   argV : in     swig.pointers.chars_ptr_Pointer);
   overriding
   function  top  (Self : access Item;
                   N    : in     Node_Pointer) return C.int;


   ----------------------------------------
   --- Handlers for Specific C Declarations
   --

   overriding
   function classForwardDeclaration     (Self : access Item;
                                         n    : in     Node_Pointer) return C.int;
   overriding
   function nativeDirective             (Self : access Item;
                                         n    : in     Node_Pointer) return C.int;
   overriding
   function functionWrapper             (Self : access Item;
                                         n    : in     Node_Pointer) return C.int;
   overriding
   function globalVariableHandler       (Self : access Item;
                                         n    : in     Node_Pointer) return C.int;
   overriding
   function enumDeclaration             (Self : access Item;
                                         n    : in     Node_Pointer) return C.int;
   overriding
   function enumValueDeclaration        (Self : access Item;
                                         n    : in     Node_Pointer) return C.int;
   overriding
   function constantWrapper             (Self : access Item;
                                         n    : in     Node_Pointer) return C.int;
   overriding
   function classHandler                (Self : access Item;
                                         n    : in     Node_Pointer) return C.int;
   overriding
   function usingDeclaration            (Self : access Item;
                                         n    : in     Node_Pointer) return C.int;
   overriding
   function memberFunctionHandler       (Self : access Item;
                                         n    : in     Node_Pointer) return C.int;
   overriding
   function staticMemberFunctionHandler (Self : access Item;
                                         n    : in     Node_Pointer) return C.int;
   overriding
   function constructorHandler          (Self : access Item;
                                         n    : in     Node_Pointer) return C.int;
   overriding
   function destructorHandler           (Self : access Item;
                                         n    : in     Node_Pointer) return C.int;
   overriding
   function memberVariableHandler       (Self : access Item;
                                         n    : in     Node_Pointer) return C.int;
   overriding
   function staticMembervariableHandler (Self : access Item;
                                         n    : in     Node_Pointer) return C.int;
   overriding
   function memberConstantHandler       (Self : access Item;
                                         n    : in     Node_Pointer) return C.int;
   overriding
   function typedefHandler              (Self : access Item;
                                         n    : in     Node_Pointer) return C.int;
   overriding
   function insertDirective             (Self : access Item;
                                         n    : in     Node_Pointer) return C.int;
   overriding
   function namespaceDeclaration        (Self : access Item;
                                         n    : in     Node_Pointer) return C.int;
   overriding
   function moduleDirective             (Self : access Item;
                                         n    : in     Node_Pointer) return C.int;
   overriding
   function includeDirective            (Self : access Item;
                                         n    : in     Node_Pointer) return C.int;
   overriding
   function typemapDirective            (Self : access Item;
                                         n    : in     Node_Pointer) return C.int;

   ------------
   ---  Utility
   --

   function to_ada_subProgram (Self : access Item;   the_c_Function   : in c_Function.view)    return ada_subProgram.view;
   function to_ada_Parameters (Self : access Item;   the_c_Parameters : in c_parameter.Vector) return ada_Parameter .vector;
   function to_ada_Variable   (Self : access Item;   the_c_Variable   : in c_Variable.view)    return ada_Variable  .view;
   function to_Descriptor     (Self : access Item;   swig_Type        : in doh_swigType)       return unbounded_String;

   Aborted : exception;



private

   use c_Declarable,

       GMP,
       GMP.discrete;


   --  Hook to swig_main (on the c-side).
   --
   function swig_ada return system.Address;
   pragma Export (C, swig_ada);


   ----------------------
   --- symbol_value_Maps
   --
   package symbol_value_Maps is new ada.Containers.hashed_Maps (unbounded_String,
                                                                discrete.Integer,
                                                                ada.Strings.unbounded.Hash,
                                                                "=");
   use symbol_value_maps;


   ------------------
   --- namespace_Sets
   --
   package namespace_Sets is new ada.Containers.hashed_Sets (unbounded_String,
                                                             ada.Strings.unbounded.Hash,
                                                             "=");
   use namespace_Sets;


   ----------------------------
   --- swig_type_Maps_of_c_type
   --
   subtype swig_Type is unbounded_String;

   use type c_Type.view;
   package swig_type_Maps_of_c_type is new ada.Containers.hashed_Maps (swig_Type,
                                                                       c_Type.view,
                                                                       ada.Strings.unbounded.Hash,
                                                                       "=");
   use swig_type_Maps_of_c_type;


   ------------------
   --- String Vectors
   --
   package String_Vectors is new ada.Containers.indefinite_Vectors (Positive, String);
   subtype String_Vector  is String_Vectors.Vector;


   ---------------------
   --- ada_Language Item
   --
   type Item is new swigMod.Language.item with
      record
         --  Maps
         --
         name_Map_of_c_type             : c_Type  .name_Maps_of_c_type  .Map;
         name_Map_of_ada_type           : ada_Type.name_Maps_of_ada_type.Map;

         swig_type_Map_of_c_type        : swig_type_Maps_of_c_type            .Map;
         c_type_Map_of_ada_type         : swig_Module.c_type_Maps_of_ada_type .Map;

         c_type_Map_of_ada_subprogram   : swig_Module.c_type_Maps_of_ada_subprogram  .Map;
         c_namespace_Map_of_ada_Package : swig_Module.c_namespace_Maps_of_ada_Package.Map;

         integer_symbol_value_Map       : aliased symbol_value_Maps.Map;

         --  Modules
         --
         name_Map_of_module :         swig_Module.name_Maps_of_module.Map;
         new_Modules        :         swig_Module.module_Vectors.Vector;
         Module_core        : aliased swig_Module.item;
         Module_top         : aliased swig_Module.item;

         --  C Namespaces
         --
         nameSpace_std     : c_nameSpace.view;
         c_namespace_Stack : c_nameSpace.Vector;
         a_Namespaces      : namespace_sets.Set;                 -- TODO: Make a hashed set, as length ordering is no longer important.

         --  'Standard' Ada Packages
         --
         Package_standard             : ada_Package.view;
         Package_system               : ada_Package.view;
         Package_interfaces           : ada_Package.view;
         Package_interfaces_c         : ada_Package.view;
         Package_interfaces_c_strings : ada_Package.view;
         Package_swig                 : ada_Package.view;
         Package_swig_pointers        : ada_Package.view;

         --  'current' Declarations
         --
         current_c_Node      : doh_Node;
         c_class_Stack       : c_Type.Vector;                    -- The last element is 'current_c_Class'.
         prior_c_Declaration : c_Declarable.view;

         --  Enums
         --
         current_c_Enum         : c_Type.view;
         last_c_enum_rep_value  : long_long_Integer := -1;
         anonymous_c_enum_Count : Natural           :=  0;
         anonymous_enum_Count   : Natural           :=  0;

         --  Flags
         --
         in_cpp_Mode                   : Boolean := False;
         native_function_Flag          : Boolean := False;
         enum_constant_Flag            : Boolean := False;       -- Flag for wrapping an enum or constant.
         static_flag                   : Boolean := False;       -- Flag for wrapping a static functions or member variables.
         wrapping_member_flag          : Boolean := False;       -- Flag for wrapping a member variable/enum/const.
         is_anonymous_Enum             : Boolean := False;
         variable_wrapper_flag         : Boolean := False;       -- Flag for wrapping a nonstatic member variable. TODO: possibly oboslete.
         have_default_constructor_flag : Boolean := False;       -- TODO: Possibly obsolete.
         enum_rep_clause_required      : Boolean := False;       -- TODO: Possibly obsolete.
         doing_constructorDeclaration  : Boolean := False;

         --  C Runtime
         --
         f_Runtime  : swig_Core.Pointers.File_Pointer;
         f_Header   : swig_Core.Pointers.File_Pointer;
         f_Wrappers : swig_Core.Pointers.File_Pointer;
         f_Init     : swig_Core.Pointers.File_Pointer;
         f_Ada      : swig_Core.Pointers.File_Pointer;           -- Contains Ada specific C++ declarations and code.

         current_linkage_Symbol : unbounded_String;
         current_lStr           : unbounded_String;

         incomplete_access_to_Type_i_c_pointer_List : ada_Type.Vector;
      end record;


   function  current_c_Namespace   (Self : access Item) return c_nameSpace.view;
   function  current_c_Class       (Self : access Item) return c_Type.view;       -- The class record curently being processed.

   function  new_c_Function        (Self : access Item;   the_Node       : in doh_Node;
                                                          function_Name  : in unbounded_String;
                                                          nameSpace      : in c_nameSpace.view;
                                                          is_Destructor  : in Boolean;
                                                          is_Constructor : in Boolean := False;
                                                          is_Overriding  : in Boolean := False) return c_Function.view;

   function  to_c_Parameters       (Self : access Item;   swig_Parameters : in doh_ParmList) return c_Parameter.Vector;

   procedure add_array_Bounds_to   (Self : access Item;   the_Variable    : in c_Variable.view;
                                                          from_swig_Type  : in doh_swigType);


   procedure register              (Self : access Item;   the_c_Type              : in     c_Type.view;
                                                          to_swig_Type            : in     doh_swigType;
                                                          is_core_C_type          : in     Boolean := False;
                                                          create_array_Type       : in     Boolean := True;
                                                          add_level_3_Indirection : in     Boolean := False);

   procedure prune_unknown_C_Types (Self : in out Item);
   procedure process_all_Modules   (Self : in out Item);


   ------------
   --- Utility
   --

   function  fetch_ada_Type    (Self : access Item;   Named     : in unbounded_String) return ada_Type.view;
   function  fetch_c_Type      (Self : access Item;   Named     : in unbounded_String) return   c_Type.view;
   function  demand_c_Type_for (Self : access Item;   swig_Type : in doh_swigType)     return   c_Type.view;
   procedure add_new_c_Type    (Self : access Item;   new_Type  : in c_Type.view);

   function  current_Module    (Self : access Item)                                    return swig_Module.swig_Module_view;
   function  demand_Module     (Self : access Item;   Named     : in unbounded_String) return swig_Module.swig_Module_view;

   function  my_stripped       (Self : access Item;   swig_Type : in doh_swigType)     return unbounded_String;

   procedure associate         (Self : access Item;   the_Ada   : in ada_Type.view;
                                                      with_C    : in   c_Type.view);

   procedure add_Namespace     (Self : access Item;   Named     : in unbounded_String);
   --
   --  The same namespace may safely be added twice (is add is ignored after the 1st)


   function  current_class_namespace_Prefix (Self : access Item) return unbounded_String;
   --
   --  Returns the c++ prefix of the current_Class, or an empty string if there is no current_Class.

   function  get_overloaded_Name (for_Node       : in doh_Node) return String;

   function  makeParameterName   (parameter_List : in doh_parmList;
                                  the_Parameter  : in doh_Parm;
                                  arg_Num        : in Integer) return String;

   function "+" (From : in String) return unbounded_String
                 renames to_unbounded_String;
end ada_Language;
