-- This file is generated by SWIG. Please do not modify by hand.
--
with DOHs.const_String_or_char_ptr;
with interfaces.c;
with swig;
with swig.pointers;
with swig_Core;
with swig_Core.Pointers;
with swigmod.Dispatcher;
with interfaces.C;
with interfaces.C.Pointers;
with System;
private with system.Address_To_Access_Conversions;

package swigmod.Language is

   -- Item
   --

   type Item is new Dispatcher.Item with record
      none_comparison                       : access swig_Core.String;
      director_ctor_code                    : access swig_Core.String;
      director_prot_ctor_code               : access swig_Core.String;
      director_multiple_inheritance         : aliased interfaces.c.int;
      director_language                     : aliased interfaces.c.int;
      doxygenTranslator                     : access swigmod.DoxygenTranslator;
      symtabs                               : access swig_Core.Hash;
      overloading                           : aliased interfaces.c.int;
      protected_and_private_Members_allowed : aliased swig.bool;
      multiinput                            : aliased interfaces.c.int;
      cplus_runtime                         : aliased interfaces.c.int;
      directors                             : aliased interfaces.c.int;
   end record;

   pragma Import (CPP, Entity => Item);

   -- Item_Array
   --
   type Item_Array is
     array (interfaces.C.Size_t range <>) of aliased swigmod.Language.Item;

   -- NestedClassSupport
   --
   type NestedClassSupport is (NCS_None, NCS_Full, NCS_Unknown);

   for NestedClassSupport use (NCS_None => 0, NCS_Full => 1, NCS_Unknown => 2);

   pragma Convention (C, NestedClassSupport);

   type NestedClassSupport_array is
     array
       (interfaces.C.Size_t range <>) of aliased swigmod.Language
       .NestedClassSupport;

   function construct return swigmod.Language.Item'Class;

   overriding procedure destruct_0 (Self : in out swigmod.Language.Item);

   overriding procedure destruct (Self : in out swigmod.Language.Item);

   overriding function emit_one (Self :    access swigmod.Language.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function directorClassName (Self :    access swigmod.Language.Item'Class;
      n : in swig_Core.Pointers.Node_Pointer) return swig_Core.Pointers
     .String_Pointer;

   procedure main (Self : in out swigmod.Language.Item;
      argc : in interfaces.c.int; argv : in swig.pointers.chars_ptr_Pointer);

   overriding function top (Self :    access swigmod.Language.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   overriding function applyDirective (Self :    access swigmod.Language.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   overriding function clearDirective (Self :    access swigmod.Language.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   overriding function constantDirective (Self : access swigmod.Language.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   overriding function extendDirective (Self :    access swigmod.Language.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   overriding function fragmentDirective (Self : access swigmod.Language.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   overriding function importDirective (Self :    access swigmod.Language.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   overriding function includeDirective (Self : access swigmod.Language.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   overriding function insertDirective (Self :    access swigmod.Language.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   overriding function moduleDirective (Self :    access swigmod.Language.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   overriding function nativeDirective (Self :    access swigmod.Language.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   overriding function pragmaDirective (Self :    access swigmod.Language.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   overriding function typemapDirective (Self : access swigmod.Language.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   overriding function typemapcopyDirective
     (Self :    access swigmod.Language.Item;
      n    : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   overriding function typesDirective (Self :    access swigmod.Language.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   overriding function cDeclaration (Self :    access swigmod.Language.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   overriding function externDeclaration (Self : access swigmod.Language.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   overriding function enumDeclaration (Self :    access swigmod.Language.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   overriding function enumvalueDeclaration
     (Self :    access swigmod.Language.Item;
      n    : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   overriding function enumforwardDeclaration
     (Self :    access swigmod.Language.Item;
      n    : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   overriding function classDeclaration (Self : access swigmod.Language.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   overriding function classforwardDeclaration
     (Self :    access swigmod.Language.Item;
      n    : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   overriding function constructorDeclaration
     (Self :    access swigmod.Language.Item;
      n    : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   overriding function destructorDeclaration
     (Self :    access swigmod.Language.Item;
      n    : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   overriding function accessDeclaration (Self : access swigmod.Language.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   overriding function namespaceDeclaration
     (Self :    access swigmod.Language.Item;
      n    : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   overriding function usingDeclaration (Self : access swigmod.Language.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function functionHandler (Self :    access swigmod.Language.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function globalfunctionHandler (Self :    access swigmod.Language.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function memberfunctionHandler (Self :    access swigmod.Language.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function staticmemberfunctionHandler (Self : access swigmod.Language.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function callbackfunctionHandler (Self :    access swigmod.Language.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function variableHandler (Self :    access swigmod.Language.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function globalvariableHandler (Self :    access swigmod.Language.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function membervariableHandler (Self :    access swigmod.Language.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function staticmembervariableHandler (Self : access swigmod.Language.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function memberconstantHandler (Self :    access swigmod.Language.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function constructorHandler (Self :    access swigmod.Language.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function copyconstructorHandler (Self :    access swigmod.Language.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function destructorHandler (Self :    access swigmod.Language.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function classHandler (Self :    access swigmod.Language.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function typedefHandler (Self :    access swigmod.Language.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function constantWrapper (Self :    access swigmod.Language.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function variableWrapper (Self :    access swigmod.Language.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function functionWrapper (Self :    access swigmod.Language.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function nativeWrapper (Self :    access swigmod.Language.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function classDirector (Self :    access swigmod.Language.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function classDirectorInit (Self :    access swigmod.Language.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function classDirectorEnd (Self :    access swigmod.Language.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function unrollVirtualMethods (Self :    access swigmod.Language.Item;
      n                                : in swig_Core.Pointers.Node_Pointer;
      parent                           : in swig_Core.Pointers.Node_Pointer;
      vm                               : in swig_Core.Pointers.List_Pointer;
      default_director                 : in interfaces.c.int;
      virtual_destructor               : in swig.pointers.int_Pointer;
      protectedbase : in interfaces.c.int) return interfaces.c.int;

   function unrollVirtualMethods (Self :    access swigmod.Language.Item;
      n                                : in swig_Core.Pointers.Node_Pointer;
      parent                           : in swig_Core.Pointers.Node_Pointer;
      vm                               : in swig_Core.Pointers.List_Pointer;
      default_director                 : in interfaces.c.int;
      virtual_destructor : in swig.pointers.int_Pointer) return interfaces.c
     .int;

   function classDirectorConstructor (Self :    access swigmod.Language.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function classDirectorDefaultConstructor
     (Self :    access swigmod.Language.Item;
      n    : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function classDirectorMethod (Self :    access swigmod.Language.Item;
      n                               : in swig_Core.Pointers.Node_Pointer;
      parent                          : in swig_Core.Pointers.Node_Pointer;
      super : in swig_Core.Pointers.String_Pointer) return interfaces.c.int;

   function classDirectorConstructors (Self :    access swigmod.Language.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function classDirectorDestructor (Self :    access swigmod.Language.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function classDirectorMethods (Self :    access swigmod.Language.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function classDirectorDisown (Self :    access swigmod.Language.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function validIdentifier (Self :    access swigmod.Language.Item;
      s : in swig_Core.Pointers.String_Pointer) return interfaces.c.int;

   function addSymbol (Self :    access swigmod.Language.Item;
      s                     : in swig_Core.Pointers.String_Pointer;
      n                     : in swig_Core.Pointers.Node_Pointer;
      scope : in DOHs.const_String_or_char_ptr.Item) return interfaces.c.int;

   function addSymbol (Self :    access swigmod.Language.Item;
      s                     : in swig_Core.Pointers.String_Pointer;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function addInterfaceSymbol (Self :    access swigmod.Language.Item;
      interface_name                 : in swig_Core.Pointers.String_Pointer;
      n                              : in swig_Core.Pointers.Node_Pointer;
      scope : in DOHs.const_String_or_char_ptr.Item) return interfaces.c.int;

   function addInterfaceSymbol (Self :    access swigmod.Language.Item;
      interface_name                 : in swig_Core.Pointers.String_Pointer;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   procedure dumpSymbols (Self : in out swigmod.Language.Item);

   function symbolLookup (Self :    access swigmod.Language.Item;
      s                        : in swig_Core.Pointers.String_Pointer;
      scope : in DOHs.const_String_or_char_ptr.Item) return swig_Core.Pointers
     .Node_Pointer;

   function symbolLookup (Self :    access swigmod.Language.Item;
      s : in swig_Core.Pointers.String_Pointer) return swig_Core.Pointers
     .Node_Pointer;

   function symbolAddScope (Self :    access swigmod.Language.Item;
      scope : in DOHs.const_String_or_char_ptr.Item) return swig_Core.Pointers
     .Hash_Pointer;

   function symbolScopeLookup (Self :    access swigmod.Language.Item;
      scope : in DOHs.const_String_or_char_ptr.Item) return swig_Core.Pointers
     .Hash_Pointer;

   function symbolScopePseudoSymbolLookup (Self : access swigmod.Language.Item;
      scope : in DOHs.const_String_or_char_ptr.Item) return swig_Core.Pointers
     .Hash_Pointer;

   function abstractClassTest (Self :    access swigmod.Language.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function is_assignable (Self :    access swigmod.Language.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function runtimeCode
     (Self : access swigmod.Language.Item) return swig_Core.Pointers
     .String_Pointer;

   function defaultExternalRuntimeFilename
     (Self : access swigmod.Language.Item) return swig_Core.Pointers
     .String_Pointer;

   procedure replaceSpecialVariables (Self : in out swigmod.Language.Item;
      method : in     swig_Core.Pointers.String_Pointer;
      tm : in     swig_Core.Pointers.String_Pointer;
      parm : in     swig_Core.Pointers.Parm_Pointer);

   procedure enable_cplus_runtime_mode
     (Self : in out swigmod.Language.Item'Class);

   function cplus_runtime_mode
     (Self : access swigmod.Language.Item'Class) return interfaces.c.int;

   procedure allow_protected_and_private_Members
     (Self : in out swigmod.Language.Item'Class);

   procedure allow_directors (Self : in out swigmod.Language.Item'Class;
      val                          : in     interfaces.c.int);

   procedure allow_directors (Self : in out swigmod.Language.Item'Class);

   function directorsEnabled
     (Self : access swigmod.Language.Item'Class) return interfaces.c.int;

   procedure allow_dirprot (Self : in out swigmod.Language.Item'Class;
      val                        : in     interfaces.c.int);

   procedure allow_dirprot (Self : in out swigmod.Language.Item'Class);

   procedure allow_allprotected (Self : in out swigmod.Language.Item'Class;
      val                             : in     interfaces.c.int);

   procedure allow_allprotected (Self : in out swigmod.Language.Item'Class);

   function dirprot_mode
     (Self : access swigmod.Language.Item'Class) return interfaces.c.int;

   function need_nonpublic_ctor (Self :    access swigmod.Language.Item'Class;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function need_nonpublic_member (Self : access swigmod.Language.Item'Class;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   procedure setSubclassInstanceCheck
     (Self : in out swigmod.Language.Item'Class;
      s    : in     swig_Core.Pointers.String_Pointer);

   procedure setOverloadResolutionTemplates
     (Self : in out swigmod.Language.Item'Class;
      argc : in     swig_Core.Pointers.String_Pointer;
      argv : in     swig_Core.Pointers.String_Pointer);

   procedure allow_multiple_input (Self : in out swigmod.Language.Item'Class;
      val                               : in     interfaces.c.int);

   procedure allow_multiple_input (Self : in out swigmod.Language.Item'Class);

   procedure allow_overloading (Self : in out swigmod.Language.Item'Class;
      val                            : in     interfaces.c.int);

   procedure allow_overloading (Self : in out swigmod.Language.Item'Class);

   function is_wrapping_class
     (Self : access swigmod.Language.Item'Class) return interfaces.c.int;

   function getCurrentClass
     (Self : access swigmod.Language.Item'Class) return swig_Core.Pointers
     .Node_Pointer;

   function getNSpace
     (Self : access swigmod.Language.Item'Class) return swig_Core.Pointers
     .String_Pointer;

   function getClassName
     (Self : access swigmod.Language.Item'Class) return swig_Core.Pointers
     .String_Pointer;

   function getClassHash
     (Self : access swigmod.Language.Item'Class) return swig_Core.Pointers
     .Hash_Pointer;

   function getClassPrefix
     (Self : access swigmod.Language.Item'Class) return swig_Core.Pointers
     .String_Pointer;

   function getEnumClassPrefix
     (Self : access swigmod.Language.Item'Class) return swig_Core.Pointers
     .String_Pointer;

   function getClassType
     (Self : access swigmod.Language.Item'Class) return swig_Core.Pointers
     .String_Pointer;

   function is_smart_pointer
     (Self : access swigmod.Language.Item'Class) return interfaces.c.int;

   function makeParameterName (Self :    access swigmod.Language.Item;
      n                             : in swig_Core.Pointers.Node_Pointer;
      p : in swig_Core.Pointers.Parm_Pointer; arg_num : in interfaces.c.int;
      setter : in swig.bool) return swig_Core.Pointers.String_Pointer;

   function makeParameterName (Self :    access swigmod.Language.Item;
      n                             : in swig_Core.Pointers.Node_Pointer;
      p                             : in swig_Core.Pointers.Parm_Pointer;
      arg_num : in interfaces.c.int) return swig_Core.Pointers.String_Pointer;

   function extraDirectorProtectedCPPMethodsRequired
     (Self : access swigmod.Language.Item) return swig.bool;

   function nestedClassesSupport
     (Self : access swigmod.Language.Item) return swigmod.Language
     .NestedClassSupport;

   function kwargsSupport
     (Self : access swigmod.Language.Item) return swig.bool;

   function isNonVirtualProtectedAccess
     (Self :    access swigmod.Language.Item'Class;
      n    : in swig_Core.Pointers.Node_Pointer) return swig.bool;

   function use_naturalvar_mode (Self :    access swigmod.Language.Item'Class;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   -- Pointer
   --
   type Pointer is access all swigmod.Language.Item;

   -- Pointer_Array
   --
   type Pointer_Array is
     array (interfaces.C.Size_t range <>) of aliased swigmod.Language.Pointer;

   -- Pointer_Pointer
   --
   package C_Pointer_Pointers is new interfaces.c.Pointers
     (Index => interfaces.c.size_t, Element => swigmod.Language.Pointer,
      element_Array      => swigmod.Language.Pointer_Array,
      default_Terminator => null);

   subtype Pointer_Pointer is C_Pointer_Pointers.Pointer;

   -- NestedClassSupport_Pointer
   --
   package C_NestedClassSupport_Pointers is new interfaces.c.Pointers
     (Index              => interfaces.c.size_t,
      Element            => swigmod.Language.NestedClassSupport,
      element_Array      => swigmod.Language.NestedClassSupport_Array,
      default_Terminator => swigmod.Language.NestedClassSupport'Val (0));

   subtype NestedClassSupport_Pointer is C_NestedClassSupport_Pointers.Pointer;

   -- NestedClassSupport_Pointer_Array
   --
   type NestedClassSupport_Pointer_Array is
     array
       (interfaces.C.Size_t range <>) of aliased swigmod.Language
       .NestedClassSupport_Pointer;

   -- NestedClassSupport_Pointer_Pointer
   --
   package C_NestedClassSupport_Pointer_Pointers is new interfaces.c.Pointers
     (Index              => interfaces.c.size_t,
      Element            => swigmod.Language.NestedClassSupport_Pointer,
      element_Array      => swigmod.Language.NestedClassSupport_Pointer_Array,
      default_Terminator => null);

   subtype NestedClassSupport_Pointer_Pointer is
     C_NestedClassSupport_Pointer_Pointers.Pointer;

private

   pragma CPP_Constructor (construct, "ada_new_Language_Language");
   pragma Import (CPP, destruct_0, "_ZN8LanguageD1Ev");
   pragma Import (CPP, destruct, "_ZN8LanguageD1Ev");
   pragma Import (CPP, emit_one, "Ada_Language_emit_one");
   pragma Import (CPP, directorClassName, "Ada_Language_directorClassName");
   pragma Import (CPP, main, "Ada_Language_main");
   pragma Import (CPP, top, "Ada_Language_top");
   pragma Import (CPP, applyDirective, "Ada_Language_applyDirective");
   pragma Import (CPP, clearDirective, "Ada_Language_clearDirective");
   pragma Import (CPP, constantDirective, "Ada_Language_constantDirective");
   pragma Import (CPP, extendDirective, "Ada_Language_extendDirective");
   pragma Import (CPP, fragmentDirective, "Ada_Language_fragmentDirective");
   pragma Import (CPP, importDirective, "Ada_Language_importDirective");
   pragma Import (CPP, includeDirective, "Ada_Language_includeDirective");
   pragma Import (CPP, insertDirective, "Ada_Language_insertDirective");
   pragma Import (CPP, moduleDirective, "Ada_Language_moduleDirective");
   pragma Import (CPP, nativeDirective, "Ada_Language_nativeDirective");
   pragma Import (CPP, pragmaDirective, "Ada_Language_pragmaDirective");
   pragma Import (CPP, typemapDirective, "Ada_Language_typemapDirective");
   pragma Import (CPP, typemapcopyDirective,
      "Ada_Language_typemapcopyDirective");
   pragma Import (CPP, typesDirective, "Ada_Language_typesDirective");
   pragma Import (CPP, cDeclaration, "Ada_Language_cDeclaration");
   pragma Import (CPP, externDeclaration, "Ada_Language_externDeclaration");
   pragma Import (CPP, enumDeclaration, "Ada_Language_enumDeclaration");
   pragma Import (CPP, enumvalueDeclaration,
      "Ada_Language_enumvalueDeclaration");
   pragma Import (CPP, enumforwardDeclaration,
      "Ada_Language_enumforwardDeclaration");
   pragma Import (CPP, classDeclaration, "Ada_Language_classDeclaration");
   pragma Import (CPP, classforwardDeclaration,
      "Ada_Language_classforwardDeclaration");
   pragma Import (CPP, constructorDeclaration,
      "Ada_Language_constructorDeclaration");
   pragma Import (CPP, destructorDeclaration,
      "Ada_Language_destructorDeclaration");
   pragma Import (CPP, accessDeclaration, "Ada_Language_accessDeclaration");
   pragma Import (CPP, namespaceDeclaration,
      "Ada_Language_namespaceDeclaration");
   pragma Import (CPP, usingDeclaration, "Ada_Language_usingDeclaration");
   pragma Import (CPP, functionHandler, "Ada_Language_functionHandler");
   pragma Import (CPP, globalfunctionHandler,
      "Ada_Language_globalfunctionHandler");
   pragma Import (CPP, memberfunctionHandler,
      "Ada_Language_memberfunctionHandler");
   pragma Import (CPP, staticmemberfunctionHandler,
      "Ada_Language_staticmemberfunctionHandler");
   pragma Import (CPP, callbackfunctionHandler,
      "Ada_Language_callbackfunctionHandler");
   pragma Import (CPP, variableHandler, "Ada_Language_variableHandler");
   pragma Import (CPP, globalvariableHandler,
      "Ada_Language_globalvariableHandler");
   pragma Import (CPP, membervariableHandler,
      "Ada_Language_membervariableHandler");
   pragma Import (CPP, staticmembervariableHandler,
      "Ada_Language_staticmembervariableHandler");
   pragma Import (CPP, memberconstantHandler,
      "Ada_Language_memberconstantHandler");
   pragma Import (CPP, constructorHandler, "Ada_Language_constructorHandler");
   pragma Import (CPP, copyconstructorHandler,
      "Ada_Language_copyconstructorHandler");
   pragma Import (CPP, destructorHandler, "Ada_Language_destructorHandler");
   pragma Import (CPP, classHandler, "Ada_Language_classHandler");
   pragma Import (CPP, typedefHandler, "Ada_Language_typedefHandler");
   pragma Import (CPP, constantWrapper, "Ada_Language_constantWrapper");
   pragma Import (CPP, variableWrapper, "Ada_Language_variableWrapper");
   pragma Import (CPP, functionWrapper, "Ada_Language_functionWrapper");
   pragma Import (CPP, nativeWrapper, "Ada_Language_nativeWrapper");
   pragma Import (CPP, classDirector, "Ada_Language_classDirector");
   pragma Import (CPP, classDirectorInit, "Ada_Language_classDirectorInit");
   pragma Import (CPP, classDirectorEnd, "Ada_Language_classDirectorEnd");

   function unrollVirtualMethods_v1 (Self :    access swigmod.Language.Item;
      n                                   : in swig_Core.Pointers.Node_Pointer;
      parent                              : in swig_Core.Pointers.Node_Pointer;
      vm                                  : in swig_Core.Pointers.List_Pointer;
      default_director                    : in interfaces.c.int;
      virtual_destructor                  : in swig.pointers.int_Pointer;
      protectedbase : in interfaces.c.int) return interfaces.c.int;

   pragma Import (CPP, unrollVirtualMethods_v1,
      "Ada_Language_unrollVirtualMethods__SWIG_0");

   function unrollVirtualMethods (Self :    access swigmod.Language.Item;
      n                                : in swig_Core.Pointers.Node_Pointer;
      parent                           : in swig_Core.Pointers.Node_Pointer;
      vm                               : in swig_Core.Pointers.List_Pointer;
      default_director                 : in interfaces.c.int;
      virtual_destructor               : in swig.pointers.int_Pointer;
      protectedbase : in interfaces.c.int) return interfaces.c.int renames
     unrollVirtualMethods_v1;

   function unrollVirtualMethods_v2 (Self :    access swigmod.Language.Item;
      n                                   : in swig_Core.Pointers.Node_Pointer;
      parent                              : in swig_Core.Pointers.Node_Pointer;
      vm                                  : in swig_Core.Pointers.List_Pointer;
      default_director                    : in interfaces.c.int;
      virtual_destructor : in swig.pointers.int_Pointer) return interfaces.c
     .int;

   pragma Import (CPP, unrollVirtualMethods_v2,
      "Ada_Language_unrollVirtualMethods__SWIG_1");

   function unrollVirtualMethods (Self :    access swigmod.Language.Item;
      n                                : in swig_Core.Pointers.Node_Pointer;
      parent                           : in swig_Core.Pointers.Node_Pointer;
      vm                               : in swig_Core.Pointers.List_Pointer;
      default_director                 : in interfaces.c.int;
      virtual_destructor : in swig.pointers.int_Pointer) return interfaces.c
     .int renames
     unrollVirtualMethods_v2;

   pragma Import (CPP, classDirectorConstructor,
      "Ada_Language_classDirectorConstructor");
   pragma Import (CPP, classDirectorDefaultConstructor,
      "Ada_Language_classDirectorDefaultConstructor");
   pragma Import (CPP, classDirectorMethod,
      "Ada_Language_classDirectorMethod");
   pragma Import (CPP, classDirectorConstructors,
      "Ada_Language_classDirectorConstructors");
   pragma Import (CPP, classDirectorDestructor,
      "Ada_Language_classDirectorDestructor");
   pragma Import (CPP, classDirectorMethods,
      "Ada_Language_classDirectorMethods");
   pragma Import (CPP, classDirectorDisown,
      "Ada_Language_classDirectorDisown");
   pragma Import (CPP, validIdentifier, "Ada_Language_validIdentifier");

   function addSymbol_v1 (Self :    access swigmod.Language.Item;
      s                        : in swig_Core.Pointers.String_Pointer;
      n                        : in swig_Core.Pointers.Node_Pointer;
      scope : in DOHs.const_String_or_char_ptr.Item) return interfaces.c.int;

   pragma Import (CPP, addSymbol_v1, "Ada_Language_addSymbol__SWIG_0");

   function addSymbol (Self :    access swigmod.Language.Item;
      s                     : in swig_Core.Pointers.String_Pointer;
      n                     : in swig_Core.Pointers.Node_Pointer;
      scope : in DOHs.const_String_or_char_ptr.Item) return interfaces.c
     .int renames
     addSymbol_v1;

   function addSymbol_v2 (Self :    access swigmod.Language.Item;
      s                        : in swig_Core.Pointers.String_Pointer;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   pragma Import (CPP, addSymbol_v2, "Ada_Language_addSymbol__SWIG_1");

   function addSymbol (Self :    access swigmod.Language.Item;
      s                     : in swig_Core.Pointers.String_Pointer;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int renames
     addSymbol_v2;

   function addInterfaceSymbol_v1 (Self :    access swigmod.Language.Item;
      interface_name                    : in swig_Core.Pointers.String_Pointer;
      n                                 : in swig_Core.Pointers.Node_Pointer;
      scope : in DOHs.const_String_or_char_ptr.Item) return interfaces.c.int;

   pragma Import (CPP, addInterfaceSymbol_v1,
      "Ada_Language_addInterfaceSymbol__SWIG_0");

   function addInterfaceSymbol (Self :    access swigmod.Language.Item;
      interface_name                 : in swig_Core.Pointers.String_Pointer;
      n                              : in swig_Core.Pointers.Node_Pointer;
      scope : in DOHs.const_String_or_char_ptr.Item) return interfaces.c
     .int renames
     addInterfaceSymbol_v1;

   function addInterfaceSymbol_v2 (Self :    access swigmod.Language.Item;
      interface_name                    : in swig_Core.Pointers.String_Pointer;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   pragma Import (CPP, addInterfaceSymbol_v2,
      "Ada_Language_addInterfaceSymbol__SWIG_1");

   function addInterfaceSymbol (Self :    access swigmod.Language.Item;
      interface_name                 : in swig_Core.Pointers.String_Pointer;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int renames
     addInterfaceSymbol_v2;

   pragma Import (CPP, dumpSymbols, "Ada_Language_dumpSymbols");

   function symbolLookup_v1 (Self :    access swigmod.Language.Item;
      s                           : in swig_Core.Pointers.String_Pointer;
      scope : in DOHs.const_String_or_char_ptr.Item) return swig_Core.Pointers
     .Node_Pointer;

   pragma Import (CPP, symbolLookup_v1, "Ada_Language_symbolLookup__SWIG_0");

   function symbolLookup (Self :    access swigmod.Language.Item;
      s                        : in swig_Core.Pointers.String_Pointer;
      scope : in DOHs.const_String_or_char_ptr.Item) return swig_Core.Pointers
     .Node_Pointer renames
     symbolLookup_v1;

   function symbolLookup_v2 (Self :    access swigmod.Language.Item;
      s : in swig_Core.Pointers.String_Pointer) return swig_Core.Pointers
     .Node_Pointer;

   pragma Import (CPP, symbolLookup_v2, "Ada_Language_symbolLookup__SWIG_1");

   function symbolLookup (Self :    access swigmod.Language.Item;
      s : in swig_Core.Pointers.String_Pointer) return swig_Core.Pointers
     .Node_Pointer renames
     symbolLookup_v2;

   pragma Import (CPP, symbolAddScope, "Ada_Language_symbolAddScope");
   pragma Import (CPP, symbolScopeLookup, "Ada_Language_symbolScopeLookup");
   pragma Import (CPP, symbolScopePseudoSymbolLookup,
      "Ada_Language_symbolScopePseudoSymbolLookup");
   pragma Import (CPP, abstractClassTest, "Ada_Language_abstractClassTest");
   pragma Import (CPP, is_assignable, "Ada_Language_is_assignable");
   pragma Import (CPP, runtimeCode, "Ada_Language_runtimeCode");
   pragma Import (CPP, defaultExternalRuntimeFilename,
      "Ada_Language_defaultExternalRuntimeFilename");
   pragma Import (CPP, replaceSpecialVariables,
      "Ada_Language_replaceSpecialVariables");
   pragma Import (CPP, enable_cplus_runtime_mode,
      "Ada_Language_enable_cplus_runtime_mode");
   pragma Import (CPP, cplus_runtime_mode, "Ada_Language_cplus_runtime_mode");
   pragma Import (CPP, allow_protected_and_private_Members,
      "Ada_Language_allow_protected_and_private_Members");

   procedure allow_directors_v1 (Self : in out swigmod.Language.Item'Class;
      val                             : in     interfaces.c.int);

   pragma Import (CPP, allow_directors_v1,
      "Ada_Language_allow_directors__SWIG_0");

   procedure allow_directors (Self : in out swigmod.Language.Item'Class;
      val                          : in     interfaces.c.int) renames
     allow_directors_v1;

   procedure allow_directors_v2 (Self : in out swigmod.Language.Item'Class);

   pragma Import (CPP, allow_directors_v2,
      "Ada_Language_allow_directors__SWIG_1");

   procedure allow_directors
     (Self : in out swigmod.Language.Item'Class) renames
     allow_directors_v2;

   pragma Import (CPP, directorsEnabled, "Ada_Language_directorsEnabled");

   procedure allow_dirprot_v1 (Self : in out swigmod.Language.Item'Class;
      val                           : in     interfaces.c.int);

   pragma Import (CPP, allow_dirprot_v1, "Ada_Language_allow_dirprot__SWIG_0");

   procedure allow_dirprot (Self : in out swigmod.Language.Item'Class;
      val                        : in     interfaces.c.int) renames
     allow_dirprot_v1;

   procedure allow_dirprot_v2 (Self : in out swigmod.Language.Item'Class);

   pragma Import (CPP, allow_dirprot_v2, "Ada_Language_allow_dirprot__SWIG_1");

   procedure allow_dirprot (Self : in out swigmod.Language.Item'Class) renames
     allow_dirprot_v2;

   procedure allow_allprotected_v1 (Self : in out swigmod.Language.Item'Class;
      val                                : in     interfaces.c.int);

   pragma Import (CPP, allow_allprotected_v1,
      "Ada_Language_allow_allprotected__SWIG_0");

   procedure allow_allprotected (Self : in out swigmod.Language.Item'Class;
      val                             : in     interfaces.c.int) renames
     allow_allprotected_v1;

   procedure allow_allprotected_v2 (Self : in out swigmod.Language.Item'Class);

   pragma Import (CPP, allow_allprotected_v2,
      "Ada_Language_allow_allprotected__SWIG_1");

   procedure allow_allprotected
     (Self : in out swigmod.Language.Item'Class) renames
     allow_allprotected_v2;

   pragma Import (CPP, dirprot_mode, "Ada_Language_dirprot_mode");
   pragma Import (CPP, need_nonpublic_ctor,
      "Ada_Language_need_nonpublic_ctor");
   pragma Import (CPP, need_nonpublic_member,
      "Ada_Language_need_nonpublic_member");
   pragma Import (CPP, setSubclassInstanceCheck,
      "Ada_Language_setSubclassInstanceCheck");
   pragma Import (CPP, setOverloadResolutionTemplates,
      "Ada_Language_setOverloadResolutionTemplates");

   procedure allow_multiple_input_v1
     (Self : in out swigmod.Language.Item'Class; val : in interfaces.c.int);

   pragma Import (CPP, allow_multiple_input_v1,
      "Ada_Language_allow_multiple_input");

   procedure allow_multiple_input (Self : in out swigmod.Language.Item'Class;
      val                               : in     interfaces.c.int) renames
     allow_multiple_input_v1;

   procedure allow_multiple_input_v2
     (Self : in out swigmod.Language.Item'Class);

   pragma Import (CPP, allow_multiple_input_v2,
      "Ada_Language_allow_multiple_input");

   procedure allow_multiple_input
     (Self : in out swigmod.Language.Item'Class) renames
     allow_multiple_input_v2;

   procedure allow_overloading_v1 (Self : in out swigmod.Language.Item'Class;
      val                               : in     interfaces.c.int);

   pragma Import (CPP, allow_overloading_v1, "Ada_Language_allow_overloading");

   procedure allow_overloading (Self : in out swigmod.Language.Item'Class;
      val                            : in     interfaces.c.int) renames
     allow_overloading_v1;

   procedure allow_overloading_v2 (Self : in out swigmod.Language.Item'Class);

   pragma Import (CPP, allow_overloading_v2, "Ada_Language_allow_overloading");

   procedure allow_overloading
     (Self : in out swigmod.Language.Item'Class) renames
     allow_overloading_v2;

   pragma Import (CPP, is_wrapping_class, "Ada_Language_is_wrapping_class");
   pragma Import (CPP, getCurrentClass, "Ada_Language_getCurrentClass");
   pragma Import (CPP, getNSpace, "Ada_Language_getNSpace");
   pragma Import (CPP, getClassName, "Ada_Language_getClassName");
   pragma Import (CPP, getClassHash, "Ada_Language_getClassHash");
   pragma Import (CPP, getClassPrefix, "Ada_Language_getClassPrefix");
   pragma Import (CPP, getEnumClassPrefix, "Ada_Language_getEnumClassPrefix");
   pragma Import (CPP, getClassType, "Ada_Language_getClassType");
   pragma Import (CPP, is_smart_pointer, "Ada_Language_is_smart_pointer");

   function makeParameterName_v1 (Self :    access swigmod.Language.Item;
      n                                : in swig_Core.Pointers.Node_Pointer;
      p : in swig_Core.Pointers.Parm_Pointer; arg_num : in interfaces.c.int;
      setter : in swig.bool) return swig_Core.Pointers.String_Pointer;

   pragma Import (CPP, makeParameterName_v1, "Ada_Language_makeParameterName");

   function makeParameterName (Self :    access swigmod.Language.Item;
      n                             : in swig_Core.Pointers.Node_Pointer;
      p : in swig_Core.Pointers.Parm_Pointer; arg_num : in interfaces.c.int;
      setter : in swig.bool) return swig_Core.Pointers.String_Pointer renames
     makeParameterName_v1;

   function makeParameterName_v2 (Self :    access swigmod.Language.Item;
      n                                : in swig_Core.Pointers.Node_Pointer;
      p                                : in swig_Core.Pointers.Parm_Pointer;
      arg_num : in interfaces.c.int) return swig_Core.Pointers.String_Pointer;

   pragma Import (CPP, makeParameterName_v2, "Ada_Language_makeParameterName");

   function makeParameterName (Self :    access swigmod.Language.Item;
      n                             : in swig_Core.Pointers.Node_Pointer;
      p                             : in swig_Core.Pointers.Parm_Pointer;
      arg_num : in interfaces.c.int) return swig_Core.Pointers
     .String_Pointer renames
     makeParameterName_v2;

   pragma Import (CPP, extraDirectorProtectedCPPMethodsRequired,
      "Ada_Language_extraDirectorProtectedCPPMethodsRequired");
   pragma Import (CPP, nestedClassesSupport,
      "Ada_Language_nestedClassesSupport");
   pragma Import (CPP, kwargsSupport, "Ada_Language_kwargsSupport");
   pragma Import (CPP, isNonVirtualProtectedAccess,
      "Ada_Language_isNonVirtualProtectedAccess");
   pragma Import (CPP, use_naturalvar_mode,
      "Ada_Language_use_naturalvar_mode");

   package conversions is new System.Address_To_Access_Conversions (Item);

end swigmod.Language;
