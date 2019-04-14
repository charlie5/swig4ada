-- This file is generated by SWIG. Please do *not* modify by hand.
--
with interfaces.c;
with swigg_module.Pointers;
with interfaces.C;
with System;
private with system.Address_To_Access_Conversions;

package swigg_module.Dispatcher is

   -- AccessMode
   --
   type AccessMode is (PUBLIC, a_PRIVATE, a_PROTECTED);

   for AccessMode use (PUBLIC => 0, a_PRIVATE => 1, a_PROTECTED => 2);

   pragma Convention (C, AccessMode);

   -- Item
   --

--     type Item is abstract tagged limited record
   type Item is tagged limited record
      cplus_mode : aliased swigg_module.Dispatcher.AccessMode;
   end record;

   pragma Import (CPP, Entity => Item);

   function construct return Item'Class;
   pragma Import (CPP, Entity => construct);
--     pragma Cpp_Constructor (construct);


   type AccessMode_array is
     array
       (interfaces.C.Size_t range <>) of aliased swigg_module.Dispatcher
       .AccessMode;

   procedure destruct_0 (Self : in out swigg_module.Dispatcher.Item);

   procedure destruct (Self : in out swigg_module.Dispatcher.Item);

   function emit_one (Self :    access swigg_module.Dispatcher.Item;
      n : in swigg_module.Pointers.Node_Pointer) return interfaces.c.int;

   function emit_children (Self :    access swigg_module.Dispatcher.Item;
      n : in swigg_module.Pointers.Node_Pointer) return interfaces.c.int;

   function defaultHandler (Self :    access swigg_module.Dispatcher.Item;
      n : in swigg_module.Pointers.Node_Pointer) return interfaces.c.int;

   function top (Self :    access swigg_module.Dispatcher.Item;
      n : in swigg_module.Pointers.Node_Pointer) return interfaces.c
     .int; -- is abstract;

   function applyDirective (Self :    access swigg_module.Dispatcher.Item;
      n : in swigg_module.Pointers.Node_Pointer) return interfaces.c.int;

   function clearDirective (Self :    access swigg_module.Dispatcher.Item;
      n : in swigg_module.Pointers.Node_Pointer) return interfaces.c.int;

   function constantDirective (Self :    access swigg_module.Dispatcher.Item;
      n : in swigg_module.Pointers.Node_Pointer) return interfaces.c.int;

   function extendDirective (Self :    access swigg_module.Dispatcher.Item;
      n : in swigg_module.Pointers.Node_Pointer) return interfaces.c.int;

   function fragmentDirective (Self :    access swigg_module.Dispatcher.Item;
      n : in swigg_module.Pointers.Node_Pointer) return interfaces.c.int;

   function importDirective (Self :    access swigg_module.Dispatcher.Item;
      n : in swigg_module.Pointers.Node_Pointer) return interfaces.c.int;

   function includeDirective (Self :    access swigg_module.Dispatcher.Item;
      n : in swigg_module.Pointers.Node_Pointer) return interfaces.c.int;

   function insertDirective (Self :    access swigg_module.Dispatcher.Item;
      n : in swigg_module.Pointers.Node_Pointer) return interfaces.c.int;

   function moduleDirective (Self :    access swigg_module.Dispatcher.Item;
      n : in swigg_module.Pointers.Node_Pointer) return interfaces.c.int;

   function nativeDirective (Self :    access swigg_module.Dispatcher.Item;
      n : in swigg_module.Pointers.Node_Pointer) return interfaces.c.int;

   function pragmaDirective (Self :    access swigg_module.Dispatcher.Item;
      n : in swigg_module.Pointers.Node_Pointer) return interfaces.c.int;

   function typemapDirective (Self :    access swigg_module.Dispatcher.Item;
      n : in swigg_module.Pointers.Node_Pointer) return interfaces.c.int;

   function typemapitemDirective (Self : access swigg_module.Dispatcher.Item;
      n : in swigg_module.Pointers.Node_Pointer) return interfaces.c.int;

   function typemapcopyDirective (Self : access swigg_module.Dispatcher.Item;
      n : in swigg_module.Pointers.Node_Pointer) return interfaces.c.int;

   function typesDirective (Self :    access swigg_module.Dispatcher.Item;
      n : in swigg_module.Pointers.Node_Pointer) return interfaces.c.int;

   function cDeclaration (Self :    access swigg_module.Dispatcher.Item;
      n : in swigg_module.Pointers.Node_Pointer) return interfaces.c.int;

   function externDeclaration (Self :    access swigg_module.Dispatcher.Item;
      n : in swigg_module.Pointers.Node_Pointer) return interfaces.c.int;

   function enumDeclaration (Self :    access swigg_module.Dispatcher.Item;
      n : in swigg_module.Pointers.Node_Pointer) return interfaces.c.int;

   function enumvalueDeclaration (Self : access swigg_module.Dispatcher.Item;
      n : in swigg_module.Pointers.Node_Pointer) return interfaces.c.int;

   function enumforwardDeclaration (Self : access swigg_module.Dispatcher.Item;
      n : in swigg_module.Pointers.Node_Pointer) return interfaces.c.int;

   function classDeclaration (Self :    access swigg_module.Dispatcher.Item;
      n : in swigg_module.Pointers.Node_Pointer) return interfaces.c.int;

   function classforwardDeclaration
     (Self :    access swigg_module.Dispatcher.Item;
      n    : in swigg_module.Pointers.Node_Pointer) return interfaces.c.int;

   function constructorDeclaration (Self : access swigg_module.Dispatcher.Item;
      n : in swigg_module.Pointers.Node_Pointer) return interfaces.c.int;

   function destructorDeclaration (Self : access swigg_module.Dispatcher.Item;
      n : in swigg_module.Pointers.Node_Pointer) return interfaces.c.int;

   function accessDeclaration (Self :    access swigg_module.Dispatcher.Item;
      n : in swigg_module.Pointers.Node_Pointer) return interfaces.c.int;

   function usingDeclaration (Self :    access swigg_module.Dispatcher.Item;
      n : in swigg_module.Pointers.Node_Pointer) return interfaces.c.int;

   function namespaceDeclaration (Self : access swigg_module.Dispatcher.Item;
      n : in swigg_module.Pointers.Node_Pointer) return interfaces.c.int;

   function templateDeclaration (Self :    access swigg_module.Dispatcher.Item;
      n : in swigg_module.Pointers.Node_Pointer) return interfaces.c.int;

   -- Pointer
   --
   type Pointer is access all swigg_module.Dispatcher.Item;

   -- Pointers
   --
   type Pointers is
     array
       (interfaces.C.Size_t range <>) of aliased swigg_module.Dispatcher
       .Pointer;

   -- Pointer_Pointer
   --
   type Pointer_Pointer is access all swigg_module.Dispatcher.Pointer;

   -- AccessMode_Pointer
   --
   type AccessMode_Pointer is access all swigg_module.Dispatcher.AccessMode;

   -- AccessMode_Pointers
   --
   type AccessMode_Pointers is
     array
       (interfaces.C.Size_t range <>) of aliased swigg_module.Dispatcher
       .AccessMode_Pointer;

   -- AccessMode_Pointer_Pointer
   --
   type AccessMode_Pointer_Pointer is
     access all swigg_module.Dispatcher.AccessMode_Pointer;

private

   pragma Import (CPP, destruct_0, "_ZN10DispatcherD1Ev");
   pragma Import (CPP, destruct, "_ZN10DispatcherD1Ev");
   pragma Import (CPP, emit_one, "Ada_Dispatcher_emit_one");
   pragma Import (CPP, emit_children, "Ada_Dispatcher_emit_children");
   pragma Import (CPP, top, "Ada_Dispatcher_Top");
   pragma Import (CPP, defaultHandler, "Ada_Dispatcher_defaultHandler");
   pragma Import (CPP, applyDirective, "Ada_Dispatcher_applyDirective");
   pragma Import (CPP, clearDirective, "Ada_Dispatcher_clearDirective");
   pragma Import (CPP, constantDirective, "Ada_Dispatcher_constantDirective");
   pragma Import (CPP, extendDirective, "Ada_Dispatcher_extendDirective");
   pragma Import (CPP, fragmentDirective, "Ada_Dispatcher_fragmentDirective");
   pragma Import (CPP, importDirective, "Ada_Dispatcher_importDirective");
   pragma Import (CPP, includeDirective, "Ada_Dispatcher_includeDirective");
   pragma Import (CPP, insertDirective, "Ada_Dispatcher_insertDirective");
   pragma Import (CPP, moduleDirective, "Ada_Dispatcher_moduleDirective");
   pragma Import (CPP, nativeDirective, "Ada_Dispatcher_nativeDirective");
   pragma Import (CPP, pragmaDirective, "Ada_Dispatcher_pragmaDirective");
   pragma Import (CPP, typemapDirective, "Ada_Dispatcher_typemapDirective");
   pragma Import (CPP, typemapitemDirective,
      "Ada_Dispatcher_typemapitemDirective");
   pragma Import (CPP, typemapcopyDirective,
      "Ada_Dispatcher_typemapcopyDirective");
   pragma Import (CPP, typesDirective, "Ada_Dispatcher_typesDirective");
   pragma Import (CPP, cDeclaration, "Ada_Dispatcher_cDeclaration");
   pragma Import (CPP, externDeclaration, "Ada_Dispatcher_externDeclaration");
   pragma Import (CPP, enumDeclaration, "Ada_Dispatcher_enumDeclaration");
   pragma Import (CPP, enumvalueDeclaration,
      "Ada_Dispatcher_enumvalueDeclaration");
   pragma Import (CPP, enumforwardDeclaration,
      "Ada_Dispatcher_enumforwardDeclaration");
   pragma Import (CPP, classDeclaration, "Ada_Dispatcher_classDeclaration");
   pragma Import (CPP, classforwardDeclaration,
      "Ada_Dispatcher_classforwardDeclaration");
   pragma Import (CPP, constructorDeclaration,
      "Ada_Dispatcher_constructorDeclaration");
   pragma Import (CPP, destructorDeclaration,
      "Ada_Dispatcher_destructorDeclaration");
   pragma Import (CPP, accessDeclaration, "Ada_Dispatcher_accessDeclaration");
   pragma Import (CPP, usingDeclaration, "Ada_Dispatcher_usingDeclaration");
   pragma Import (CPP, namespaceDeclaration,
      "Ada_Dispatcher_namespaceDeclaration");
   pragma Import (CPP, templateDeclaration,
      "Ada_Dispatcher_templateDeclaration");

end swigg_module.Dispatcher;
