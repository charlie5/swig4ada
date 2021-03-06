-- This file is generated by SWIG. Please do not modify by hand.
--
with interfaces.c;
with swig_Core.Pointers;
with interfaces.C;
with interfaces.C.Pointers;
with System;
private with system.Address_To_Access_Conversions;

package swigmod.Dispatcher is

   -- AccessMode
   --
   type AccessMode is (PUBLIC, the_PRIVATE, the_PROTECTED);

   for AccessMode use (PUBLIC => 0, the_PRIVATE => 1, the_PROTECTED => 2);

   pragma Convention (C, AccessMode);

   -- Item
   --

   type Item is abstract tagged limited record
      cplus_mode : aliased swigmod.Dispatcher.AccessMode;
   end record;

   pragma Import (CPP, Entity => Item);

   type AccessMode_array is
     array
       (interfaces.C.Size_t range <>) of aliased swigmod.Dispatcher.AccessMode;

   procedure destruct_0 (Self : in out swigmod.Dispatcher.Item);

   procedure destruct (Self : in out swigmod.Dispatcher.Item);

   function emit_one (Self :    access swigmod.Dispatcher.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function emit_children (Self :    access swigmod.Dispatcher.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function defaultHandler (Self :    access swigmod.Dispatcher.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function top (Self :    access swigmod.Dispatcher.Item;
      n               : in swig_Core.Pointers.Node_Pointer) return interfaces.c
     .int is abstract;

   function applyDirective (Self :    access swigmod.Dispatcher.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function clearDirective (Self :    access swigmod.Dispatcher.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function constantDirective (Self :    access swigmod.Dispatcher.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function extendDirective (Self :    access swigmod.Dispatcher.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function fragmentDirective (Self :    access swigmod.Dispatcher.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function importDirective (Self :    access swigmod.Dispatcher.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function includeDirective (Self :    access swigmod.Dispatcher.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function insertDirective (Self :    access swigmod.Dispatcher.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function moduleDirective (Self :    access swigmod.Dispatcher.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function nativeDirective (Self :    access swigmod.Dispatcher.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function pragmaDirective (Self :    access swigmod.Dispatcher.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function typemapDirective (Self :    access swigmod.Dispatcher.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function typemapitemDirective (Self :    access swigmod.Dispatcher.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function typemapcopyDirective (Self :    access swigmod.Dispatcher.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function typesDirective (Self :    access swigmod.Dispatcher.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function cDeclaration (Self :    access swigmod.Dispatcher.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function externDeclaration (Self :    access swigmod.Dispatcher.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function enumDeclaration (Self :    access swigmod.Dispatcher.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function enumvalueDeclaration (Self :    access swigmod.Dispatcher.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function enumforwardDeclaration (Self :    access swigmod.Dispatcher.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function classDeclaration (Self :    access swigmod.Dispatcher.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function classforwardDeclaration (Self :    access swigmod.Dispatcher.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function constructorDeclaration (Self :    access swigmod.Dispatcher.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function destructorDeclaration (Self :    access swigmod.Dispatcher.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function accessDeclaration (Self :    access swigmod.Dispatcher.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function usingDeclaration (Self :    access swigmod.Dispatcher.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function namespaceDeclaration (Self :    access swigmod.Dispatcher.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function templateDeclaration (Self :    access swigmod.Dispatcher.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   function lambdaDeclaration (Self :    access swigmod.Dispatcher.Item;
      n : in swig_Core.Pointers.Node_Pointer) return interfaces.c.int;

   -- Pointer
   --
   type Pointer is access all swigmod.Dispatcher.Item;

   -- Pointer_Array
   --
   type Pointer_Array is
     array
       (interfaces.C.Size_t range <>) of aliased swigmod.Dispatcher.Pointer;

   -- Pointer_Pointer
   --
   package C_Pointer_Pointers is new interfaces.c.Pointers
     (Index => interfaces.c.size_t, Element => swigmod.Dispatcher.Pointer,
      element_Array      => swigmod.Dispatcher.Pointer_Array,
      default_Terminator => null);

   subtype Pointer_Pointer is C_Pointer_Pointers.Pointer;

   -- AccessMode_Pointer
   --
   package C_AccessMode_Pointers is new interfaces.c.Pointers
     (Index => interfaces.c.size_t, Element => swigmod.Dispatcher.AccessMode,
      element_Array      => swigmod.Dispatcher.AccessMode_Array,
      default_Terminator => swigmod.Dispatcher.AccessMode'Val (0));

   subtype AccessMode_Pointer is C_AccessMode_Pointers.Pointer;

   -- AccessMode_Pointer_Array
   --
   type AccessMode_Pointer_Array is
     array
       (interfaces.C.Size_t range <>) of aliased swigmod.Dispatcher
       .AccessMode_Pointer;

   -- AccessMode_Pointer_Pointer
   --
   package C_AccessMode_Pointer_Pointers is new interfaces.c.Pointers
     (Index              => interfaces.c.size_t,
      Element            => swigmod.Dispatcher.AccessMode_Pointer,
      element_Array      => swigmod.Dispatcher.AccessMode_Pointer_Array,
      default_Terminator => null);

   subtype AccessMode_Pointer_Pointer is C_AccessMode_Pointer_Pointers.Pointer;

private

   pragma Import (CPP, destruct_0, "_ZN10DispatcherD1Ev");
   pragma Import (CPP, destruct, "_ZN10DispatcherD1Ev");
   pragma Import (CPP, emit_one, "Ada_Dispatcher_emit_one");
   pragma Import (CPP, emit_children, "Ada_Dispatcher_emit_children");
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
   pragma Import (CPP, lambdaDeclaration, "Ada_Dispatcher_lambdaDeclaration");

end swigmod.Dispatcher;
