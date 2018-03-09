-- This file is generated by SWIG. Please do *not* modify by hand.
--
with interfaces.c;
with swigg.Pointers;
with interfaces.C;
with System;
private with system.Address_To_Access_Conversions;



package swigg.Dispatcher is

   -- AccessMode
   -- 
   type AccessMode is (   PUBLIC,
   a_PRIVATE,
   a_PROTECTED);

   for AccessMode use (   PUBLIC => 0,
   a_PRIVATE => 1,
   a_PROTECTED => 2);

   pragma Convention (C, AccessMode);


   -- Item
   -- 

type Item is  tagged limited
      record
         cplus_mode : aliased swigg.Dispatcher.AccessMode;
      end record;



   -- Items
   -- 
   type Items is array (interfaces.C.Size_t range <>) of aliased swigg.Dispatcher.Item;

   type AccessMode_array is array (interfaces.C.Size_t range <>) of aliased swigg.Dispatcher.AccessMode;






   function  emit_one (Self : in swigg.Dispatcher.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  emit_children (Self : in swigg.Dispatcher.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  defaultHandler (Self : in swigg.Dispatcher.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  top (Self : in swigg.Dispatcher.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  applyDirective (Self : in swigg.Dispatcher.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  clearDirective (Self : in swigg.Dispatcher.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  constantDirective (Self : in swigg.Dispatcher.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  extendDirective (Self : in swigg.Dispatcher.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  fragmentDirective (Self : in swigg.Dispatcher.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  importDirective (Self : in swigg.Dispatcher.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  includeDirective (Self : in swigg.Dispatcher.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  insertDirective (Self : in swigg.Dispatcher.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  moduleDirective (Self : in swigg.Dispatcher.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  nativeDirective (Self : in swigg.Dispatcher.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  pragmaDirective (Self : in swigg.Dispatcher.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  typemapDirective (Self : in swigg.Dispatcher.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  typemapitemDirective (Self : in swigg.Dispatcher.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  typemapcopyDirective (Self : in swigg.Dispatcher.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  typesDirective (Self : in swigg.Dispatcher.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  cDeclaration (Self : in swigg.Dispatcher.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  externDeclaration (Self : in swigg.Dispatcher.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  enumDeclaration (Self : in swigg.Dispatcher.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  enumvalueDeclaration (Self : in swigg.Dispatcher.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  enumforwardDeclaration (Self : in swigg.Dispatcher.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  classDeclaration (Self : in swigg.Dispatcher.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  classforwardDeclaration (Self : in swigg.Dispatcher.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  constructorDeclaration (Self : in swigg.Dispatcher.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  destructorDeclaration (Self : in swigg.Dispatcher.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  accessDeclaration (Self : in swigg.Dispatcher.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  usingDeclaration (Self : in swigg.Dispatcher.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  namespaceDeclaration (Self : in swigg.Dispatcher.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  templateDeclaration (Self : in swigg.Dispatcher.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;





   -- Pointer
   -- 
   type Pointer is access all swigg.Dispatcher.Item;

   -- Pointers
   -- 
   type Pointers is array (interfaces.C.Size_t range <>) of aliased swigg.Dispatcher.Pointer;



   -- Pointer_Pointer
   -- 
   type Pointer_Pointer is access all swigg.Dispatcher.Pointer;



   -- AccessMode_Pointer
   -- 
   type AccessMode_Pointer is access all swigg.Dispatcher.AccessMode;

   -- AccessMode_Pointers
   -- 
   type AccessMode_Pointers is array (interfaces.C.Size_t range <>) of aliased swigg.Dispatcher.AccessMode_Pointer;



   -- AccessMode_Pointer_Pointer
   -- 
   type AccessMode_Pointer_Pointer is access all swigg.Dispatcher.AccessMode_Pointer;







private



   pragma cpp_Class (Entity => Item);





   pragma Import (CPP, emit_one, "Ada_Dispatcher_emit_one");
   pragma Import (CPP, emit_children, "Ada_Dispatcher_emit_children");
   pragma Import (CPP, defaultHandler, "Ada_Dispatcher_defaultHandler");
   pragma Import (CPP, top, "Ada_Dispatcher_top");
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
   pragma Import (CPP, typemapitemDirective, "Ada_Dispatcher_typemapitemDirective");
   pragma Import (CPP, typemapcopyDirective, "Ada_Dispatcher_typemapcopyDirective");
   pragma Import (CPP, typesDirective, "Ada_Dispatcher_typesDirective");
   pragma Import (CPP, cDeclaration, "Ada_Dispatcher_cDeclaration");
   pragma Import (CPP, externDeclaration, "Ada_Dispatcher_externDeclaration");
   pragma Import (CPP, enumDeclaration, "Ada_Dispatcher_enumDeclaration");
   pragma Import (CPP, enumvalueDeclaration, "Ada_Dispatcher_enumvalueDeclaration");
   pragma Import (CPP, enumforwardDeclaration, "Ada_Dispatcher_enumforwardDeclaration");
   pragma Import (CPP, classDeclaration, "Ada_Dispatcher_classDeclaration");
   pragma Import (CPP, classforwardDeclaration, "Ada_Dispatcher_classforwardDeclaration");
   pragma Import (CPP, constructorDeclaration, "Ada_Dispatcher_constructorDeclaration");
   pragma Import (CPP, destructorDeclaration, "Ada_Dispatcher_destructorDeclaration");
   pragma Import (CPP, accessDeclaration, "Ada_Dispatcher_accessDeclaration");
   pragma Import (CPP, usingDeclaration, "Ada_Dispatcher_usingDeclaration");
   pragma Import (CPP, namespaceDeclaration, "Ada_Dispatcher_namespaceDeclaration");
   pragma Import (CPP, templateDeclaration, "Ada_Dispatcher_templateDeclaration");


   package conversions is new System.Address_To_Access_Conversions (Item);




end swigg.Dispatcher;
