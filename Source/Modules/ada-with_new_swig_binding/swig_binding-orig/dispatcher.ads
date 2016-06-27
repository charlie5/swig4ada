--
-- This file was automatically generated by SWIG version 1.3.29
--(http://www.swig.org).
--
-- Do not make changes to this file. Modify the SWIG interface file instead.
--

with Swig;
with System;
with Interfaces.C.Strings;
with Ada.Unchecked_Conversion;
with Ada.Unchecked_Deallocation;
with Ada.Finalization;
with swig_p_DOH;                 use swig_p_DOH;
with swigg_c_import;

package Dispatcher is

   type Item is new Ada.Finalization.Controlled with private;

   type View is access all Item'Class;

   procedure free (Self : in out View);

   function null_Dispatcher return  Item'Class;

   function is_Null (Self : in Item) return Boolean;

   package AccessMode is

      type Item is (PUBLIC, a_PRIVATE, a_PROTECTED);

      for Item use (PUBLIC => 0, a_PRIVATE => 1, a_PROTECTED => 2);

      -- Swig support

      function to_c_Int is new Ada.Unchecked_Conversion (
         Item,
         Interfaces.C.int);
      function defined is new Ada.Unchecked_Conversion (
         Interfaces.C.int,
         Item);
   end AccessMode;

   procedure initialize (Self : in out Item);

   function construct return  Dispatcher.Item'Class;

   function emit_one
     (Self : access Item;
      n    : in swig_p_DOH.Item'Class)
      return Integer;

   function emit_children
     (Self : access Item;
      n    : in swig_p_DOH.Item'Class)
      return Integer;

   function defaultHandler
     (Self : access Item;
      n    : in swig_p_DOH.Item'Class)
      return Integer;

   function top
     (Self : access Item;
      n    : in swig_p_DOH.Item'Class)
      return Integer;

   function applyDirective
     (Self : access Item;
      n    : in swig_p_DOH.Item'Class)
      return Integer;

   function clearDirective
     (Self : access Item;
      n    : in swig_p_DOH.Item'Class)
      return Integer;

   function constantDirective
     (Self : access Item;
      n    : in swig_p_DOH.Item'Class)
      return Integer;

   function extendDirective
     (Self : access Item;
      n    : in swig_p_DOH.Item'Class)
      return Integer;

   function fragmentDirective
     (Self : access Item;
      n    : in swig_p_DOH.Item'Class)
      return Integer;

   function importDirective
     (Self : access Item;
      n    : in swig_p_DOH.Item'Class)
      return Integer;

   function includeDirective
     (Self : access Item;
      n    : in swig_p_DOH.Item'Class)
      return Integer;

   function insertDirective
     (Self : access Item;
      n    : in swig_p_DOH.Item'Class)
      return Integer;

   function moduleDirective
     (Self : access Item;
      n    : in swig_p_DOH.Item'Class)
      return Integer;

   function nativeDirective
     (Self : access Item;
      n    : in swig_p_DOH.Item'Class)
      return Integer;

   function pragmaDirective
     (Self : access Item;
      n    : in swig_p_DOH.Item'Class)
      return Integer;

   function typemapDirective
     (Self : access Item;
      n    : in swig_p_DOH.Item'Class)
      return Integer;

   function typemapitemDirective
     (Self : access Item;
      n    : in swig_p_DOH.Item'Class)
      return Integer;

   function typemapcopyDirective
     (Self : access Item;
      n    : in swig_p_DOH.Item'Class)
      return Integer;

   function typesDirective
     (Self : access Item;
      n    : in swig_p_DOH.Item'Class)
      return Integer;

   function cDeclaration
     (Self : access Item;
      n    : in swig_p_DOH.Item'Class)
      return Integer;

   function externDeclaration
     (Self : access Item;
      n    : in swig_p_DOH.Item'Class)
      return Integer;

   function enumDeclaration
     (Self : access Item;
      n    : in swig_p_DOH.Item'Class)
      return Integer;

   function enumvalueDeclaration
     (Self : access Item;
      n    : in swig_p_DOH.Item'Class)
      return Integer;

   function enumforwardDeclaration
     (Self : access Item;
      n    : in swig_p_DOH.Item'Class)
      return Integer;

   function classDeclaration
     (Self : access Item;
      n    : in swig_p_DOH.Item'Class)
      return Integer;

   function classforwardDeclaration
     (Self : access Item;
      n    : in swig_p_DOH.Item'Class)
      return Integer;

   function constructorDeclaration
     (Self : access Item;
      n    : in swig_p_DOH.Item'Class)
      return Integer;

   function destructorDeclaration
     (Self : access Item;
      n    : in swig_p_DOH.Item'Class)
      return Integer;

   function accessDeclaration
     (Self : access Item;
      n    : in swig_p_DOH.Item'Class)
      return Integer;

   function usingDeclaration
     (Self : access Item;
      n    : in swig_p_DOH.Item'Class)
      return Integer;

   function namespaceDeclaration
     (Self : access Item;
      n    : in swig_p_DOH.Item'Class)
      return Integer;

   function templateDeclaration
     (Self : access Item;
      n    : in swig_p_DOH.Item'Class)
      return Integer;

   procedure set_cplus_mode
     (Self       : in Item;
      cplus_mode : in Dispatcher.AccessMode.Item);

   function get_cplus_mode
     (Self : in Item)
      return Dispatcher.AccessMode.Item;

   -- Director support
   --

   function SwigDirector_Dispatcher_moduleDirective
     (Self : access Item'Class;
      n    : System.Address)
      return Interfaces.C.int;
   pragma Export
     (C,
      SwigDirector_Dispatcher_moduleDirective,
      "SwigDirector_Dispatcher_moduleDirective");

   function moduleDirective_is_overridden (Self : in Item) return Boolean;

   function SwigDirector_Dispatcher_moduleDirective_is_overridden_dispatch
     (Self : access Item'Class)
      return Boolean;

   pragma Export
     (C,
      SwigDirector_Dispatcher_moduleDirective_is_overridden_dispatch,
      "SwigDirector_Dispatcher_moduleDirective_is_overridden_dispatch");

   function SwigDirector_Dispatcher_insertDirective
     (Self : access Item'Class;
      n    : System.Address)
      return Interfaces.C.int;
   pragma Export
     (C,
      SwigDirector_Dispatcher_insertDirective,
      "SwigDirector_Dispatcher_insertDirective");

   function insertDirective_is_overridden (Self : in Item) return Boolean;

   function SwigDirector_Dispatcher_insertDirective_is_overridden_dispatch
     (Self : access Item'Class)
      return Boolean;

   pragma Export
     (C,
      SwigDirector_Dispatcher_insertDirective_is_overridden_dispatch,
      "SwigDirector_Dispatcher_insertDirective_is_overridden_dispatch");

   function SwigDirector_Dispatcher_includeDirective
     (Self : access Item'Class;
      n    : System.Address)
      return Interfaces.C.int;
   pragma Export
     (C,
      SwigDirector_Dispatcher_includeDirective,
      "SwigDirector_Dispatcher_includeDirective");

   function includeDirective_is_overridden (Self : in Item) return Boolean;

   function SwigDirector_Dispatcher_includeDirective_is_overridden_dispatch
     (Self : access Item'Class)
      return Boolean;

   pragma Export
     (C,
      SwigDirector_Dispatcher_includeDirective_is_overridden_dispatch,
      "SwigDirector_Dispatcher_includeDirective_is_overridden_dispatch");

   function SwigDirector_Dispatcher_importDirective
     (Self : access Item'Class;
      n    : System.Address)
      return Interfaces.C.int;
   pragma Export
     (C,
      SwigDirector_Dispatcher_importDirective,
      "SwigDirector_Dispatcher_importDirective");

   function importDirective_is_overridden (Self : in Item) return Boolean;

   function SwigDirector_Dispatcher_importDirective_is_overridden_dispatch
     (Self : access Item'Class)
      return Boolean;

   pragma Export
     (C,
      SwigDirector_Dispatcher_importDirective_is_overridden_dispatch,
      "SwigDirector_Dispatcher_importDirective_is_overridden_dispatch");

   function SwigDirector_Dispatcher_fragmentDirective
     (Self : access Item'Class;
      n    : System.Address)
      return Interfaces.C.int;
   pragma Export
     (C,
      SwigDirector_Dispatcher_fragmentDirective,
      "SwigDirector_Dispatcher_fragmentDirective");

   function fragmentDirective_is_overridden (Self : in Item) return Boolean;

   function SwigDirector_Dispatcher_fragmentDirective_is_overridden_dispatch
     (Self : access Item'Class)
      return Boolean;

   pragma Export
     (C,
      SwigDirector_Dispatcher_fragmentDirective_is_overridden_dispatch,
      "SwigDirector_Dispatcher_fragmentDirective_is_overridden_dispatch");

   function SwigDirector_Dispatcher_extendDirective
     (Self : access Item'Class;
      n    : System.Address)
      return Interfaces.C.int;
   pragma Export
     (C,
      SwigDirector_Dispatcher_extendDirective,
      "SwigDirector_Dispatcher_extendDirective");

   function extendDirective_is_overridden (Self : in Item) return Boolean;

   function SwigDirector_Dispatcher_extendDirective_is_overridden_dispatch
     (Self : access Item'Class)
      return Boolean;

   pragma Export
     (C,
      SwigDirector_Dispatcher_extendDirective_is_overridden_dispatch,
      "SwigDirector_Dispatcher_extendDirective_is_overridden_dispatch");

   function SwigDirector_Dispatcher_constantDirective
     (Self : access Item'Class;
      n    : System.Address)
      return Interfaces.C.int;
   pragma Export
     (C,
      SwigDirector_Dispatcher_constantDirective,
      "SwigDirector_Dispatcher_constantDirective");

   function constantDirective_is_overridden (Self : in Item) return Boolean;

   function SwigDirector_Dispatcher_constantDirective_is_overridden_dispatch
     (Self : access Item'Class)
      return Boolean;

   pragma Export
     (C,
      SwigDirector_Dispatcher_constantDirective_is_overridden_dispatch,
      "SwigDirector_Dispatcher_constantDirective_is_overridden_dispatch");

   function SwigDirector_Dispatcher_clearDirective
     (Self : access Item'Class;
      n    : System.Address)
      return Interfaces.C.int;
   pragma Export
     (C,
      SwigDirector_Dispatcher_clearDirective,
      "SwigDirector_Dispatcher_clearDirective");

   function clearDirective_is_overridden (Self : in Item) return Boolean;

   function SwigDirector_Dispatcher_clearDirective_is_overridden_dispatch
     (Self : access Item'Class)
      return Boolean;

   pragma Export
     (C,
      SwigDirector_Dispatcher_clearDirective_is_overridden_dispatch,
      "SwigDirector_Dispatcher_clearDirective_is_overridden_dispatch");

   function SwigDirector_Dispatcher_applyDirective
     (Self : access Item'Class;
      n    : System.Address)
      return Interfaces.C.int;
   pragma Export
     (C,
      SwigDirector_Dispatcher_applyDirective,
      "SwigDirector_Dispatcher_applyDirective");

   function applyDirective_is_overridden (Self : in Item) return Boolean;

   function SwigDirector_Dispatcher_applyDirective_is_overridden_dispatch
     (Self : access Item'Class)
      return Boolean;

   pragma Export
     (C,
      SwigDirector_Dispatcher_applyDirective_is_overridden_dispatch,
      "SwigDirector_Dispatcher_applyDirective_is_overridden_dispatch");

   function SwigDirector_Dispatcher_top
     (Self : access Item'Class;
      n    : System.Address)
      return Interfaces.C.int;
   pragma Export
     (C,
      SwigDirector_Dispatcher_top,
      "SwigDirector_Dispatcher_top");

   function top_is_overridden (Self : in Item) return Boolean;

   function SwigDirector_Dispatcher_top_is_overridden_dispatch
     (Self : access Item'Class)
      return Boolean;

   pragma Export
     (C,
      SwigDirector_Dispatcher_top_is_overridden_dispatch,
      "SwigDirector_Dispatcher_top_is_overridden_dispatch");

   function SwigDirector_Dispatcher_defaultHandler
     (Self : access Item'Class;
      n    : System.Address)
      return Interfaces.C.int;
   pragma Export
     (C,
      SwigDirector_Dispatcher_defaultHandler,
      "SwigDirector_Dispatcher_defaultHandler");

   function defaultHandler_is_overridden (Self : in Item) return Boolean;

   function SwigDirector_Dispatcher_defaultHandler_is_overridden_dispatch
     (Self : access Item'Class)
      return Boolean;

   pragma Export
     (C,
      SwigDirector_Dispatcher_defaultHandler_is_overridden_dispatch,
      "SwigDirector_Dispatcher_defaultHandler_is_overridden_dispatch");

   function SwigDirector_Dispatcher_emit_children
     (Self : access Item'Class;
      n    : System.Address)
      return Interfaces.C.int;
   pragma Export
     (C,
      SwigDirector_Dispatcher_emit_children,
      "SwigDirector_Dispatcher_emit_children");

   function emit_children_is_overridden (Self : in Item) return Boolean;

   function SwigDirector_Dispatcher_emit_children_is_overridden_dispatch
     (Self : access Item'Class)
      return Boolean;

   pragma Export
     (C,
      SwigDirector_Dispatcher_emit_children_is_overridden_dispatch,
      "SwigDirector_Dispatcher_emit_children_is_overridden_dispatch");

   function SwigDirector_Dispatcher_emit_one
     (Self : access Item'Class;
      n    : System.Address)
      return Interfaces.C.int;
   pragma Export
     (C,
      SwigDirector_Dispatcher_emit_one,
      "SwigDirector_Dispatcher_emit_one");

   function emit_one_is_overridden (Self : in Item) return Boolean;

   function SwigDirector_Dispatcher_emit_one_is_overridden_dispatch
     (Self : access Item'Class)
      return Boolean;

   pragma Export
     (C,
      SwigDirector_Dispatcher_emit_one_is_overridden_dispatch,
      "SwigDirector_Dispatcher_emit_one_is_overridden_dispatch");

   function SwigDirector_Dispatcher_nativeDirective
     (Self : access Item'Class;
      n    : System.Address)
      return Interfaces.C.int;
   pragma Export
     (C,
      SwigDirector_Dispatcher_nativeDirective,
      "SwigDirector_Dispatcher_nativeDirective");

   function nativeDirective_is_overridden (Self : in Item) return Boolean;

   function SwigDirector_Dispatcher_nativeDirective_is_overridden_dispatch
     (Self : access Item'Class)
      return Boolean;

   pragma Export
     (C,
      SwigDirector_Dispatcher_nativeDirective_is_overridden_dispatch,
      "SwigDirector_Dispatcher_nativeDirective_is_overridden_dispatch");

   function SwigDirector_Dispatcher_pragmaDirective
     (Self : access Item'Class;
      n    : System.Address)
      return Interfaces.C.int;
   pragma Export
     (C,
      SwigDirector_Dispatcher_pragmaDirective,
      "SwigDirector_Dispatcher_pragmaDirective");

   function pragmaDirective_is_overridden (Self : in Item) return Boolean;

   function SwigDirector_Dispatcher_pragmaDirective_is_overridden_dispatch
     (Self : access Item'Class)
      return Boolean;

   pragma Export
     (C,
      SwigDirector_Dispatcher_pragmaDirective_is_overridden_dispatch,
      "SwigDirector_Dispatcher_pragmaDirective_is_overridden_dispatch");

   function SwigDirector_Dispatcher_typemapDirective
     (Self : access Item'Class;
      n    : System.Address)
      return Interfaces.C.int;
   pragma Export
     (C,
      SwigDirector_Dispatcher_typemapDirective,
      "SwigDirector_Dispatcher_typemapDirective");

   function typemapDirective_is_overridden (Self : in Item) return Boolean;

   function SwigDirector_Dispatcher_typemapDirective_is_overridden_dispatch
     (Self : access Item'Class)
      return Boolean;

   pragma Export
     (C,
      SwigDirector_Dispatcher_typemapDirective_is_overridden_dispatch,
      "SwigDirector_Dispatcher_typemapDirective_is_overridden_dispatch");

   function SwigDirector_Dispatcher_typemapitemDirective
     (Self : access Item'Class;
      n    : System.Address)
      return Interfaces.C.int;
   pragma Export
     (C,
      SwigDirector_Dispatcher_typemapitemDirective,
      "SwigDirector_Dispatcher_typemapitemDirective");

   function typemapitemDirective_is_overridden
     (Self : in Item)
      return Boolean;

   function SwigDirector_Dispatcher_typemapitemDirective_is_overridden_dispatch
     (Self : access Item'Class)
      return Boolean;

   pragma Export
     (C,
      SwigDirector_Dispatcher_typemapitemDirective_is_overridden_dispatch,
      "SwigDirector_Dispatcher_typemapitemDirective_is_overridden_dispatch");

   function SwigDirector_Dispatcher_typemapcopyDirective
     (Self : access Item'Class;
      n    : System.Address)
      return Interfaces.C.int;
   pragma Export
     (C,
      SwigDirector_Dispatcher_typemapcopyDirective,
      "SwigDirector_Dispatcher_typemapcopyDirective");

   function typemapcopyDirective_is_overridden
     (Self : in Item)
      return Boolean;

   function SwigDirector_Dispatcher_typemapcopyDirective_is_overridden_dispatch
     (Self : access Item'Class)
      return Boolean;

   pragma Export
     (C,
      SwigDirector_Dispatcher_typemapcopyDirective_is_overridden_dispatch,
      "SwigDirector_Dispatcher_typemapcopyDirective_is_overridden_dispatch");

   function SwigDirector_Dispatcher_typesDirective
     (Self : access Item'Class;
      n    : System.Address)
      return Interfaces.C.int;
   pragma Export
     (C,
      SwigDirector_Dispatcher_typesDirective,
      "SwigDirector_Dispatcher_typesDirective");

   function typesDirective_is_overridden (Self : in Item) return Boolean;

   function SwigDirector_Dispatcher_typesDirective_is_overridden_dispatch
     (Self : access Item'Class)
      return Boolean;

   pragma Export
     (C,
      SwigDirector_Dispatcher_typesDirective_is_overridden_dispatch,
      "SwigDirector_Dispatcher_typesDirective_is_overridden_dispatch");

   function SwigDirector_Dispatcher_cDeclaration
     (Self : access Item'Class;
      n    : System.Address)
      return Interfaces.C.int;
   pragma Export
     (C,
      SwigDirector_Dispatcher_cDeclaration,
      "SwigDirector_Dispatcher_cDeclaration");

   function cDeclaration_is_overridden (Self : in Item) return Boolean;

   function SwigDirector_Dispatcher_cDeclaration_is_overridden_dispatch
     (Self : access Item'Class)
      return Boolean;

   pragma Export
     (C,
      SwigDirector_Dispatcher_cDeclaration_is_overridden_dispatch,
      "SwigDirector_Dispatcher_cDeclaration_is_overridden_dispatch");

   function SwigDirector_Dispatcher_externDeclaration
     (Self : access Item'Class;
      n    : System.Address)
      return Interfaces.C.int;
   pragma Export
     (C,
      SwigDirector_Dispatcher_externDeclaration,
      "SwigDirector_Dispatcher_externDeclaration");

   function externDeclaration_is_overridden (Self : in Item) return Boolean;

   function SwigDirector_Dispatcher_externDeclaration_is_overridden_dispatch
     (Self : access Item'Class)
      return Boolean;

   pragma Export
     (C,
      SwigDirector_Dispatcher_externDeclaration_is_overridden_dispatch,
      "SwigDirector_Dispatcher_externDeclaration_is_overridden_dispatch");

   function SwigDirector_Dispatcher_enumDeclaration
     (Self : access Item'Class;
      n    : System.Address)
      return Interfaces.C.int;
   pragma Export
     (C,
      SwigDirector_Dispatcher_enumDeclaration,
      "SwigDirector_Dispatcher_enumDeclaration");

   function enumDeclaration_is_overridden (Self : in Item) return Boolean;

   function SwigDirector_Dispatcher_enumDeclaration_is_overridden_dispatch
     (Self : access Item'Class)
      return Boolean;

   pragma Export
     (C,
      SwigDirector_Dispatcher_enumDeclaration_is_overridden_dispatch,
      "SwigDirector_Dispatcher_enumDeclaration_is_overridden_dispatch");

   function SwigDirector_Dispatcher_enumvalueDeclaration
     (Self : access Item'Class;
      n    : System.Address)
      return Interfaces.C.int;
   pragma Export
     (C,
      SwigDirector_Dispatcher_enumvalueDeclaration,
      "SwigDirector_Dispatcher_enumvalueDeclaration");

   function enumvalueDeclaration_is_overridden
     (Self : in Item)
      return Boolean;

   function SwigDirector_Dispatcher_enumvalueDeclaration_is_overridden_dispatch
     (Self : access Item'Class)
      return Boolean;

   pragma Export
     (C,
      SwigDirector_Dispatcher_enumvalueDeclaration_is_overridden_dispatch,
      "SwigDirector_Dispatcher_enumvalueDeclaration_is_overridden_dispatch");

   function SwigDirector_Dispatcher_enumforwardDeclaration
     (Self : access Item'Class;
      n    : System.Address)
      return Interfaces.C.int;
   pragma Export
     (C,
      SwigDirector_Dispatcher_enumforwardDeclaration,
      "SwigDirector_Dispatcher_enumforwardDeclaration");

   function enumforwardDeclaration_is_overridden
     (Self : in Item)
      return Boolean;

   function 
SwigDirector_Dispatcher_enumforwardDeclaration_is_overridden_dispatch
     (Self : access Item'Class)
      return Boolean;

   pragma Export
     (C,
      SwigDirector_Dispatcher_enumforwardDeclaration_is_overridden_dispatch,
      "SwigDirector_Dispatcher_enumforwardDeclaration_is_overridden_dispatch");

   function SwigDirector_Dispatcher_classDeclaration
     (Self : access Item'Class;
      n    : System.Address)
      return Interfaces.C.int;
   pragma Export
     (C,
      SwigDirector_Dispatcher_classDeclaration,
      "SwigDirector_Dispatcher_classDeclaration");

   function classDeclaration_is_overridden (Self : in Item) return Boolean;

   function SwigDirector_Dispatcher_classDeclaration_is_overridden_dispatch
     (Self : access Item'Class)
      return Boolean;

   pragma Export
     (C,
      SwigDirector_Dispatcher_classDeclaration_is_overridden_dispatch,
      "SwigDirector_Dispatcher_classDeclaration_is_overridden_dispatch");

   function SwigDirector_Dispatcher_classforwardDeclaration
     (Self : access Item'Class;
      n    : System.Address)
      return Interfaces.C.int;
   pragma Export
     (C,
      SwigDirector_Dispatcher_classforwardDeclaration,
      "SwigDirector_Dispatcher_classforwardDeclaration");

   function classforwardDeclaration_is_overridden
     (Self : in Item)
      return Boolean;

   function 
SwigDirector_Dispatcher_classforwardDeclaration_is_overridden_dispatch
     (Self : access Item'Class)
      return Boolean;

   pragma Export
     (C,
      SwigDirector_Dispatcher_classforwardDeclaration_is_overridden_dispatch,
      "SwigDirector_Dispatcher_classforwardDeclaration_is_overridden_dispatch")
;

   function SwigDirector_Dispatcher_constructorDeclaration
     (Self : access Item'Class;
      n    : System.Address)
      return Interfaces.C.int;
   pragma Export
     (C,
      SwigDirector_Dispatcher_constructorDeclaration,
      "SwigDirector_Dispatcher_constructorDeclaration");

   function constructorDeclaration_is_overridden
     (Self : in Item)
      return Boolean;

   function 
SwigDirector_Dispatcher_constructorDeclaration_is_overridden_dispatch
     (Self : access Item'Class)
      return Boolean;

   pragma Export
     (C,
      SwigDirector_Dispatcher_constructorDeclaration_is_overridden_dispatch,
      "SwigDirector_Dispatcher_constructorDeclaration_is_overridden_dispatch");

   function SwigDirector_Dispatcher_destructorDeclaration
     (Self : access Item'Class;
      n    : System.Address)
      return Interfaces.C.int;
   pragma Export
     (C,
      SwigDirector_Dispatcher_destructorDeclaration,
      "SwigDirector_Dispatcher_destructorDeclaration");

   function destructorDeclaration_is_overridden
     (Self : in Item)
      return Boolean;

   function 
SwigDirector_Dispatcher_destructorDeclaration_is_overridden_dispatch
     (Self : access Item'Class)
      return Boolean;

   pragma Export
     (C,
      SwigDirector_Dispatcher_destructorDeclaration_is_overridden_dispatch,
      "SwigDirector_Dispatcher_destructorDeclaration_is_overridden_dispatch");

   function SwigDirector_Dispatcher_accessDeclaration
     (Self : access Item'Class;
      n    : System.Address)
      return Interfaces.C.int;
   pragma Export
     (C,
      SwigDirector_Dispatcher_accessDeclaration,
      "SwigDirector_Dispatcher_accessDeclaration");

   function accessDeclaration_is_overridden (Self : in Item) return Boolean;

   function SwigDirector_Dispatcher_accessDeclaration_is_overridden_dispatch
     (Self : access Item'Class)
      return Boolean;

   pragma Export
     (C,
      SwigDirector_Dispatcher_accessDeclaration_is_overridden_dispatch,
      "SwigDirector_Dispatcher_accessDeclaration_is_overridden_dispatch");

   function SwigDirector_Dispatcher_usingDeclaration
     (Self : access Item'Class;
      n    : System.Address)
      return Interfaces.C.int;
   pragma Export
     (C,
      SwigDirector_Dispatcher_usingDeclaration,
      "SwigDirector_Dispatcher_usingDeclaration");

   function usingDeclaration_is_overridden (Self : in Item) return Boolean;

   function SwigDirector_Dispatcher_usingDeclaration_is_overridden_dispatch
     (Self : access Item'Class)
      return Boolean;

   pragma Export
     (C,
      SwigDirector_Dispatcher_usingDeclaration_is_overridden_dispatch,
      "SwigDirector_Dispatcher_usingDeclaration_is_overridden_dispatch");

   function SwigDirector_Dispatcher_namespaceDeclaration
     (Self : access Item'Class;
      n    : System.Address)
      return Interfaces.C.int;
   pragma Export
     (C,
      SwigDirector_Dispatcher_namespaceDeclaration,
      "SwigDirector_Dispatcher_namespaceDeclaration");

   function namespaceDeclaration_is_overridden
     (Self : in Item)
      return Boolean;

   function SwigDirector_Dispatcher_namespaceDeclaration_is_overridden_dispatch
     (Self : access Item'Class)
      return Boolean;

   pragma Export
     (C,
      SwigDirector_Dispatcher_namespaceDeclaration_is_overridden_dispatch,
      "SwigDirector_Dispatcher_namespaceDeclaration_is_overridden_dispatch");

   function SwigDirector_Dispatcher_templateDeclaration
     (Self : access Item'Class;
      n    : System.Address)
      return Interfaces.C.int;
   pragma Export
     (C,
      SwigDirector_Dispatcher_templateDeclaration,
      "SwigDirector_Dispatcher_templateDeclaration");

   function templateDeclaration_is_overridden
     (Self : in Item)
      return Boolean;

   function SwigDirector_Dispatcher_templateDeclaration_is_overridden_dispatch
     (Self : access Item'Class)
      return Boolean;

   pragma Export
     (C,
      SwigDirector_Dispatcher_templateDeclaration_is_overridden_dispatch,
      "SwigDirector_Dispatcher_templateDeclaration_is_overridden_dispatch");

   procedure swig_Director_disconnect (Self : in out Item);    -- for use by
                                                               --derived
                                                               --classes (ie
                                                               --treat as
                                                               --'protected').

   procedure swig_release_Ownership (Self : in out Item);

   procedure swig_take_Ownership (Self : in out Item);

   procedure swig_Director_connect (Self : in out Item);

   -- Swig support
   --

   procedure is_Construct (Self : in out Item);
   --
   -- Flags 'self' as a newly constructed object to prevent auto-destruction
   -- during return from a user-defined construction function.
   procedure define
     (Self       : out Item;
      cPtr       : in System.Address;
      cMemoryOwn : in Boolean);

   function defined
     (cPtr       : in System.Address;
      cMemoryOwn : in Boolean := True)
      return       Item'Class;

   function getCPtr (Self : in Item) return System.Address;

   procedure set_swigCMemOwn (Self : out Item; Now : in Boolean);

   function get_swigCMemOwn (Self : in Item) return Boolean;

   procedure set_construction_Depth (Self : out Item; Now : in Integer);

   function get_construction_Depth (Self : in Item) return Integer;

   procedure add_Reference (Self : in out Item);

   procedure rid_Reference (Self : in out Item);

   procedure destroy_reference_Count (Self : in out Item);

   function get_reference_Count (Self : in Item) return Natural;
   procedure dispose (Self : in out Item);

private

   type Natural_view is access all Natural;
   type Item is new Ada.Finalization.Controlled with record
      swigCPtr_Dispatcher : System.Address;
      swigCMemOwn         : Boolean;
      construction_Depth  : Integer := 0;
      reference_Count     : Natural_view;
   end record;

   procedure finalize (Self : in out Item);

   procedure adjust (Self : in out Item);

   function new_Dispatcher (cPtr : in System.Address) return Item'Class;

   pragma Export (C, new_Dispatcher, "SWIG_Ada_new_Dispatcher");

   procedure dummy_procedure;       -- Hack to make body legal, when no other
                                    --subprograms.

end Dispatcher;
