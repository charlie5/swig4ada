-- This file is generated by SWIG. Please do *not* modify by hand.
--
with interfaces.c;
with swig;
with swig.pointers;
with swigg.Dispatcher;
with swigg.Pointers;
with interfaces.C;
with System;
private with system.Address_To_Access_Conversions;



package swigg.Language is

   -- Item
   -- 

type Item is new Dispatcher.item with
      record
         none_comparison : access swigg.String;
         director_ctor_code : access swigg.String;
         director_prot_ctor_code : access swigg.String;
         director_multiple_inheritance : aliased interfaces.c.int;
         director_language : aliased interfaces.c.int;
         symbols : access swigg.Hash;
         classtypes : access swigg.Hash;
         enumtypes : access swigg.Hash;
         overloading : aliased interfaces.c.int;
         protected_and_private_Members_allowed : aliased swig.bool;
         multiinput : aliased interfaces.c.int;
         cplus_runtime : aliased interfaces.c.int;
         directors : aliased interfaces.c.int;
      end record;



   -- Items
   -- 
   type Items is array (interfaces.C.Size_t range <>) of aliased swigg.Language.Item;






   function  construct  return swigg.Language.Item'Class;

   function  emit_one (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   procedure main (Self : in out swigg.Language.Item;
argc : in interfaces.c.int;
argv : in swig.pointers.chars_ptr_Pointer);

   function  top (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  applyDirective (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  clearDirective (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  constantDirective (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  extendDirective (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  fragmentDirective (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  importDirective (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  includeDirective (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  insertDirective (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  moduleDirective (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  nativeDirective (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  pragmaDirective (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  typemapDirective (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  typemapcopyDirective (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  typesDirective (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  cDeclaration (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  externDeclaration (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  enumDeclaration (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  enumvalueDeclaration (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  enumforwardDeclaration (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  classDeclaration (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  classforwardDeclaration (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  constructorDeclaration (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  destructorDeclaration (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  accessDeclaration (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  namespaceDeclaration (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  usingDeclaration (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  functionHandler (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  globalfunctionHandler (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  memberfunctionHandler (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  staticmemberfunctionHandler (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  callbackfunctionHandler (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  variableHandler (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  globalvariableHandler (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  membervariableHandler (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  staticmembervariableHandler (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  memberconstantHandler (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  constructorHandler (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  copyconstructorHandler (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  destructorHandler (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  classHandler (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  typedefHandler (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  constantWrapper (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  variableWrapper (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  functionWrapper (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  nativeWrapper (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  classDirector (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  classDirectorInit (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  classDirectorEnd (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  unrollVirtualMethods (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer;
parent : in swigg.Pointers.Node_Pointer;
vm : in swigg.Pointers.List_Pointer;
default_director : in interfaces.c.int;
virtual_destructor : in swig.pointers.int_Pointer;
protectedbase : in interfaces.c.int) return interfaces.c.int;

   function  unrollVirtualMethods (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer;
parent : in swigg.Pointers.Node_Pointer;
vm : in swigg.Pointers.List_Pointer;
default_director : in interfaces.c.int;
virtual_destructor : in swig.pointers.int_Pointer) return interfaces.c.int;

   function  classDirectorConstructor (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  classDirectorDefaultConstructor (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  classDirectorMethod (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer;
parent : in swigg.Pointers.Node_Pointer;
super : in swigg.Pointers.String_Pointer) return interfaces.c.int;

   function  classDirectorConstructors (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  classDirectorDestructor (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  classDirectorMethods (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  classDirectorDisown (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  validIdentifier (Self : access swigg.Language.Item;
s : in swigg.Pointers.String_Pointer) return interfaces.c.int;

   function  addSymbol (Self : access swigg.Language.Item;
s : in swigg.Pointers.String_Pointer;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  symbolLookup (Self : access swigg.Language.Item;
s : in swigg.Pointers.String_Pointer) return swigg.Pointers.Node_Pointer;

   function  classLookup (Self : access swigg.Language.Item;
s : in swigg.Pointers.SwigType_Pointer) return swigg.Pointers.Node_Pointer;

   function  enumLookup (Self : access swigg.Language.Item;
s : in swigg.Pointers.SwigType_Pointer) return swigg.Pointers.Node_Pointer;

   function  abstractClassTest (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  is_assignable (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  runtimeCode (Self : access swigg.Language.Item) return swigg.Pointers.String_Pointer;

   function  defaultExternalRuntimeFilename (Self : access swigg.Language.Item) return swigg.Pointers.String_Pointer;

   procedure enable_cplus_runtime_mode (Self : in out swigg.Language.Item);

   function  cplus_runtime_mode (Self : access swigg.Language.Item) return interfaces.c.int;

   procedure allow_protected_and_private_Members (Self : in out swigg.Language.Item);

   procedure allow_directors (Self : in out swigg.Language.Item;
val : in interfaces.c.int);

   procedure allow_directors (Self : in out swigg.Language.Item);

   function  directorsEnabled (Self : access swigg.Language.Item) return interfaces.c.int;

   procedure allow_dirprot (Self : in out swigg.Language.Item;
val : in interfaces.c.int);

   procedure allow_dirprot (Self : in out swigg.Language.Item);

   procedure allow_allprotected (Self : in out swigg.Language.Item;
val : in interfaces.c.int);

   procedure allow_allprotected (Self : in out swigg.Language.Item);

   function  dirprot_mode (Self : access swigg.Language.Item) return interfaces.c.int;

   function  need_nonpublic_ctor (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   function  need_nonpublic_member (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer) return interfaces.c.int;

   procedure setSubclassInstanceCheck (Self : in out swigg.Language.Item;
s : in swigg.Pointers.String_Pointer);

   procedure setOverloadResolutionTemplates (Self : in out swigg.Language.Item;
argc : in swigg.Pointers.String_Pointer;
argv : in swigg.Pointers.String_Pointer);

   procedure allow_multiple_input (Self : in out swigg.Language.Item;
val : in interfaces.c.int);

   procedure allow_multiple_input (Self : in out swigg.Language.Item);

   procedure allow_overloading (Self : in out swigg.Language.Item;
val : in interfaces.c.int);

   procedure allow_overloading (Self : in out swigg.Language.Item);

   function  is_wrapping_class (Self : access swigg.Language.Item) return interfaces.c.int;

   function  getCurrentClass (Self : access swigg.Language.Item) return swigg.Pointers.Node_Pointer;

   function  getClassName (Self : access swigg.Language.Item) return swigg.Pointers.String_Pointer;

   function  getClassHash (Self : access swigg.Language.Item) return swigg.Pointers.Hash_Pointer;

   function  getClassPrefix (Self : access swigg.Language.Item) return swigg.Pointers.String_Pointer;

   function  getClassType (Self : access swigg.Language.Item) return swigg.Pointers.String_Pointer;

   function  is_smart_pointer (Self : access swigg.Language.Item) return interfaces.c.int;

   function  extraDirectorProtectedCPPMethodsRequired (Self : access swigg.Language.Item) return swig.bool;





   -- Pointer
   -- 
   type Pointer is access all swigg.Language.Item;

   -- Pointers
   -- 
   type Pointers is array (interfaces.C.Size_t range <>) of aliased swigg.Language.Pointer;



   -- Pointer_Pointer
   -- 
   type Pointer_Pointer is access all swigg.Language.Pointer;







private



   pragma cpp_Class (Entity => Item);





   pragma cpp_Constructor (construct, "Ada_new_Language");
   pragma Import (CPP, emit_one, "Ada_Language_emit_one");
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
   pragma Import (CPP, typemapcopyDirective, "Ada_Language_typemapcopyDirective");
   pragma Import (CPP, typesDirective, "Ada_Language_typesDirective");
   pragma Import (CPP, cDeclaration, "Ada_Language_cDeclaration");
   pragma Import (CPP, externDeclaration, "Ada_Language_externDeclaration");
   pragma Import (CPP, enumDeclaration, "Ada_Language_enumDeclaration");
   pragma Import (CPP, enumvalueDeclaration, "Ada_Language_enumvalueDeclaration");
   pragma Import (CPP, enumforwardDeclaration, "Ada_Language_enumforwardDeclaration");
   pragma Import (CPP, classDeclaration, "Ada_Language_classDeclaration");
   pragma Import (CPP, classforwardDeclaration, "Ada_Language_classforwardDeclaration");
   pragma Import (CPP, constructorDeclaration, "Ada_Language_constructorDeclaration");
   pragma Import (CPP, destructorDeclaration, "Ada_Language_destructorDeclaration");
   pragma Import (CPP, accessDeclaration, "Ada_Language_accessDeclaration");
   pragma Import (CPP, namespaceDeclaration, "Ada_Language_namespaceDeclaration");
   pragma Import (CPP, usingDeclaration, "Ada_Language_usingDeclaration");
   pragma Import (CPP, functionHandler, "Ada_Language_functionHandler");
   pragma Import (CPP, globalfunctionHandler, "Ada_Language_globalfunctionHandler");
   pragma Import (CPP, memberfunctionHandler, "Ada_Language_memberfunctionHandler");
   pragma Import (CPP, staticmemberfunctionHandler, "Ada_Language_staticmemberfunctionHandler");
   pragma Import (CPP, callbackfunctionHandler, "Ada_Language_callbackfunctionHandler");
   pragma Import (CPP, variableHandler, "Ada_Language_variableHandler");
   pragma Import (CPP, globalvariableHandler, "Ada_Language_globalvariableHandler");
   pragma Import (CPP, membervariableHandler, "Ada_Language_membervariableHandler");
   pragma Import (CPP, staticmembervariableHandler, "Ada_Language_staticmembervariableHandler");
   pragma Import (CPP, memberconstantHandler, "Ada_Language_memberconstantHandler");
   pragma Import (CPP, constructorHandler, "Ada_Language_constructorHandler");
   pragma Import (CPP, copyconstructorHandler, "Ada_Language_copyconstructorHandler");
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

   function  unrollVirtualMethods_v1 (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer;
parent : in swigg.Pointers.Node_Pointer;
vm : in swigg.Pointers.List_Pointer;
default_director : in interfaces.c.int;
virtual_destructor : in swig.pointers.int_Pointer;
protectedbase : in interfaces.c.int) return interfaces.c.int;



   function  unrollVirtualMethods (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer;
parent : in swigg.Pointers.Node_Pointer;
vm : in swigg.Pointers.List_Pointer;
default_director : in interfaces.c.int;
virtual_destructor : in swig.pointers.int_Pointer;
protectedbase : in interfaces.c.int) return interfaces.c.int
   renames unrollVirtualMethods_v1;


   pragma Import (CPP, unrollVirtualMethods_v1, "Ada_Language_unrollVirtualMethods__SWIG_0");

   function  unrollVirtualMethods_v2 (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer;
parent : in swigg.Pointers.Node_Pointer;
vm : in swigg.Pointers.List_Pointer;
default_director : in interfaces.c.int;
virtual_destructor : in swig.pointers.int_Pointer) return interfaces.c.int;



   function  unrollVirtualMethods (Self : access swigg.Language.Item;
n : in swigg.Pointers.Node_Pointer;
parent : in swigg.Pointers.Node_Pointer;
vm : in swigg.Pointers.List_Pointer;
default_director : in interfaces.c.int;
virtual_destructor : in swig.pointers.int_Pointer) return interfaces.c.int
   renames unrollVirtualMethods_v2;


   pragma Import (CPP, unrollVirtualMethods_v2, "Ada_Language_unrollVirtualMethods__SWIG_1");
   pragma Import (CPP, classDirectorConstructor, "Ada_Language_classDirectorConstructor");
   pragma Import (CPP, classDirectorDefaultConstructor, "Ada_Language_classDirectorDefaultConstructor");
   pragma Import (CPP, classDirectorMethod, "Ada_Language_classDirectorMethod");
   pragma Import (CPP, classDirectorConstructors, "Ada_Language_classDirectorConstructors");
   pragma Import (CPP, classDirectorDestructor, "Ada_Language_classDirectorDestructor");
   pragma Import (CPP, classDirectorMethods, "Ada_Language_classDirectorMethods");
   pragma Import (CPP, classDirectorDisown, "Ada_Language_classDirectorDisown");
   pragma Import (CPP, validIdentifier, "Ada_Language_validIdentifier");
   pragma Import (CPP, addSymbol, "Ada_Language_addSymbol");
   pragma Import (CPP, symbolLookup, "Ada_Language_symbolLookup");
   pragma Import (CPP, classLookup, "Ada_Language_classLookup");
   pragma Import (CPP, enumLookup, "Ada_Language_enumLookup");
   pragma Import (CPP, abstractClassTest, "Ada_Language_abstractClassTest");
   pragma Import (CPP, is_assignable, "Ada_Language_is_assignable");
   pragma Import (CPP, runtimeCode, "Ada_Language_runtimeCode");
   pragma Import (CPP, defaultExternalRuntimeFilename, "Ada_Language_defaultExternalRuntimeFilename");
   pragma Import (CPP, enable_cplus_runtime_mode, "Ada_Language_enable_cplus_runtime_mode");
   pragma Import (CPP, cplus_runtime_mode, "Ada_Language_cplus_runtime_mode");
   pragma Import (CPP, allow_protected_and_private_Members, "Ada_Language_allow_protected_and_private_Members");

   procedure allow_directors_v1 (Self : in out swigg.Language.Item;
val : in interfaces.c.int);



   procedure allow_directors (Self : in out swigg.Language.Item;
val : in interfaces.c.int)
   renames allow_directors_v1;


   pragma Import (CPP, allow_directors_v1, "Ada_Language_allow_directors__SWIG_0");

   procedure allow_directors_v2 (Self : in out swigg.Language.Item);



   procedure allow_directors (Self : in out swigg.Language.Item)
   renames allow_directors_v2;


   pragma Import (CPP, allow_directors_v2, "Ada_Language_allow_directors__SWIG_1");
   pragma Import (CPP, directorsEnabled, "Ada_Language_directorsEnabled");

   procedure allow_dirprot_v1 (Self : in out swigg.Language.Item;
val : in interfaces.c.int);



   procedure allow_dirprot (Self : in out swigg.Language.Item;
val : in interfaces.c.int)
   renames allow_dirprot_v1;


   pragma Import (CPP, allow_dirprot_v1, "Ada_Language_allow_dirprot__SWIG_0");

   procedure allow_dirprot_v2 (Self : in out swigg.Language.Item);



   procedure allow_dirprot (Self : in out swigg.Language.Item)
   renames allow_dirprot_v2;


   pragma Import (CPP, allow_dirprot_v2, "Ada_Language_allow_dirprot__SWIG_1");

   procedure allow_allprotected_v1 (Self : in out swigg.Language.Item;
val : in interfaces.c.int);



   procedure allow_allprotected (Self : in out swigg.Language.Item;
val : in interfaces.c.int)
   renames allow_allprotected_v1;


   pragma Import (CPP, allow_allprotected_v1, "Ada_Language_allow_allprotected__SWIG_0");

   procedure allow_allprotected_v2 (Self : in out swigg.Language.Item);



   procedure allow_allprotected (Self : in out swigg.Language.Item)
   renames allow_allprotected_v2;


   pragma Import (CPP, allow_allprotected_v2, "Ada_Language_allow_allprotected__SWIG_1");
   pragma Import (CPP, dirprot_mode, "Ada_Language_dirprot_mode");
   pragma Import (CPP, need_nonpublic_ctor, "Ada_Language_need_nonpublic_ctor");
   pragma Import (CPP, need_nonpublic_member, "Ada_Language_need_nonpublic_member");
   pragma Import (CPP, setSubclassInstanceCheck, "Ada_Language_setSubclassInstanceCheck");
   pragma Import (CPP, setOverloadResolutionTemplates, "Ada_Language_setOverloadResolutionTemplates");

   procedure allow_multiple_input_v1 (Self : in out swigg.Language.Item;
val : in interfaces.c.int);



   procedure allow_multiple_input (Self : in out swigg.Language.Item;
val : in interfaces.c.int)
   renames allow_multiple_input_v1;


   pragma Import (CPP, allow_multiple_input_v1, "Ada_Language_allow_multiple_input__SWIG_0");

   procedure allow_multiple_input_v2 (Self : in out swigg.Language.Item);



   procedure allow_multiple_input (Self : in out swigg.Language.Item)
   renames allow_multiple_input_v2;


   pragma Import (CPP, allow_multiple_input_v2, "Ada_Language_allow_multiple_input__SWIG_1");

   procedure allow_overloading_v1 (Self : in out swigg.Language.Item;
val : in interfaces.c.int);



   procedure allow_overloading (Self : in out swigg.Language.Item;
val : in interfaces.c.int)
   renames allow_overloading_v1;


   pragma Import (CPP, allow_overloading_v1, "Ada_Language_allow_overloading__SWIG_0");

   procedure allow_overloading_v2 (Self : in out swigg.Language.Item);



   procedure allow_overloading (Self : in out swigg.Language.Item)
   renames allow_overloading_v2;


   pragma Import (CPP, allow_overloading_v2, "Ada_Language_allow_overloading__SWIG_1");
   pragma Import (CPP, is_wrapping_class, "Ada_Language_is_wrapping_class");
   pragma Import (CPP, getCurrentClass, "Ada_Language_getCurrentClass");
   pragma Import (CPP, getClassName, "Ada_Language_getClassName");
   pragma Import (CPP, getClassHash, "Ada_Language_getClassHash");
   pragma Import (CPP, getClassPrefix, "Ada_Language_getClassPrefix");
   pragma Import (CPP, getClassType, "Ada_Language_getClassType");
   pragma Import (CPP, is_smart_pointer, "Ada_Language_is_smart_pointer");
   pragma Import (CPP, extraDirectorProtectedCPPMethodsRequired, "Ada_Language_extraDirectorProtectedCPPMethodsRequired");


   package conversions is new System.Address_To_Access_Conversions (Item);




end swigg.Language;
