--
-- This file was automatically generated by SWIG version 1.3.29 (http://www.swig.org).
--
-- Do not make changes to this file. Modify the SWIG interface file instead.
--


with ada.unchecked_Deallocation;
with swigg_c_import; use swigg_c_import;


package body Dispatcher is


   procedure free (Self : in out View)
   is
      procedure deallocate is new ada.unchecked_Deallocation (Item'Class, View);
   begin
      deallocate (Self);
   end;



   procedure define (Self       :    out Item;
                     cPtr       : in     system.Address;
                     cMemoryOwn : in     Boolean)
   is
   begin
      self.swigCPtr_Dispatcher := cPtr;
      set_swigCMemOwn (self, cMemoryOwn);
   end;



   function defined (cPtr       : in     system.Address;
                     cMemoryOwn : in     Boolean := true) return Item'class
   is
      the_Item : Item := (ada.finalization.Controlled with
                            swigCPtr_Dispatcher => system.null_Address,
                            swigCMemOwn         => cMemoryOwn,
                            construction_Depth  => 4,
                            reference_Count     => null);
   begin
      define (the_Item, cPtr, cMemoryOwn);
      add_Reference (the_Item);
      return the_Item;
   end;






   procedure adjust  (Self : in out Item)
   is
   begin
      set_construction_Depth (Self, get_construction_Depth (Self) - 1);
      add_Reference (Self);
   end;



   function new_Dispatcher (cPtr       : in     system.Address) return Item'class
   is
   begin
      return defined (cPtr, true);
   end;



   function getCPtr (Self : in Item) return system.Address
   is
   begin
      return self.swigCPtr_Dispatcher;
   end;





   procedure set_swigCMemOwn (Self :    out Item;
                              Now  : in     Boolean)
   is
   begin
      self.swigCMemOwn := Now;
   end;


   function  get_swigCMemOwn (Self : in     Item) return Boolean
   is
   begin
      return self.swigCMemOwn;
   end;




   procedure set_construction_Depth (Self :    out Item;
                                     Now  : in     Integer)
   is
   begin
      self.construction_Depth := Now;
   end;


   function  get_construction_Depth (Self : in     Item) return Integer
   is
   begin
      return self.construction_Depth;
   end;




   procedure add_Reference (Self : in out Item)
   is
   begin
      if self.reference_Count = null then
         self.reference_Count := new Natural'(0);
      end if;

      self.reference_Count.all := self.reference_Count.all + 1;
   end;


   procedure rid_Reference (Self : in out Item)
   is
   begin
      if self.reference_Count /= null then
         self.reference_Count.all := self.reference_Count.all - 1;
      end if;
   end;


   procedure destroy_reference_Count (Self : in out Item)
   is
      procedure free is new ada.unchecked_Deallocation (Natural, Natural_view);
   begin
      free (self.reference_Count);
   end;


   function  get_reference_Count (Self : in     Item) return Natural
   is
   begin
      return self.reference_Count.all;
   exception
      when constraint_Error => return 0;
   end;



   procedure finalize (Self : in out Item)
   is
   begin
      rid_Reference (Self);

      dispose (Self);
   end;



   procedure dispose (Self : in out Item)
   is
      use type system.Address;
   begin
      if          self.swigCPtr_Dispatcher /= system.null_Address
         and then get_swigCMemOwn (Self)
         and then get_reference_Count (Self) = 0
      then
         set_swigCMemOwn (Self, false);
         swigg_c_import.delete_Dispatcher (self.swigCPtr_Dispatcher);
         destroy_reference_Count (Self);
      end if;

      self.swigCPtr_Dispatcher := system.null_Address;

   end dispose;



   function null_Dispatcher return Item'class
   is
      the_Item : Item := (ada.finalization.Controlled with
                            swigCPtr_Dispatcher => system.null_Address,
                            swigCMemOwn         => false,
                            construction_Depth  => 0,
                            reference_Count     => null);
   begin
      define (the_Item, system.null_Address, false);
      return the_Item;
   end;



   function is_Null (Self : in Item) return Boolean
   is
      use type system.Address;
   begin
      return self.swigCPtr_Dispatcher = system.null_Address;
   end;



   procedure is_Construct (Self : in out Item)
   is
   begin
      set_construction_Depth (Self,  2);
   end;





   procedure initialize (Self : in out Item) 
   is
   begin
      
      null;
   end initialize;


   function construct return Dispatcher.item'Class
   is
      Self : Item := (ada.finalization.Controlled with
                        swigCPtr_Dispatcher => system.null_Address,
                        swigCMemOwn        => true,
                        construction_Depth =>    2,
                        reference_Count    =>    null);
   begin
      

      add_Reference (Self);
      define (Self,
             swigg_c_import.new_Dispatcher ,
              true);

      return Self;
   end construct;


   function emit_one (Self : access Item;
                          n : in swig_p_DOH.item'Class) return Integer
   is
   begin
      
  return Integer (swigg_c_import
      .Dispatcher_emit_one(self.swigCPtr_Dispatcher,
 standard.system.Address (getCPtr (n))));

   end emit_one;


   function emit_children (Self : access Item;
                          n : in swig_p_DOH.item'Class) return Integer
   is
   begin
      
  return Integer (swigg_c_import
      .Dispatcher_emit_children(self.swigCPtr_Dispatcher,
 standard.system.Address (getCPtr (n))));

   end emit_children;


   function defaultHandler (Self : access Item;
                          n : in swig_p_DOH.item'Class) return Integer
   is
   begin
      
  return Integer (swigg_c_import
      .Dispatcher_defaultHandler(self.swigCPtr_Dispatcher,
 standard.system.Address (getCPtr (n))));

   end defaultHandler;


   function top (Self : access Item;
                          n : in swig_p_DOH.item'Class) return Integer
   is
   begin
      
  return Integer (swigg_c_import
      .Dispatcher_top(self.swigCPtr_Dispatcher,
 standard.system.Address (getCPtr (n))));

   end top;


   function applyDirective (Self : access Item;
                          n : in swig_p_DOH.item'Class) return Integer
   is
   begin
      
  return Integer (swigg_c_import
      .Dispatcher_applyDirective(self.swigCPtr_Dispatcher,
 standard.system.Address (getCPtr (n))));

   end applyDirective;


   function clearDirective (Self : access Item;
                          n : in swig_p_DOH.item'Class) return Integer
   is
   begin
      
  return Integer (swigg_c_import
      .Dispatcher_clearDirective(self.swigCPtr_Dispatcher,
 standard.system.Address (getCPtr (n))));

   end clearDirective;


   function constantDirective (Self : access Item;
                          n : in swig_p_DOH.item'Class) return Integer
   is
   begin
      
  return Integer (swigg_c_import
      .Dispatcher_constantDirective(self.swigCPtr_Dispatcher,
 standard.system.Address (getCPtr (n))));

   end constantDirective;


   function extendDirective (Self : access Item;
                          n : in swig_p_DOH.item'Class) return Integer
   is
   begin
      
  return Integer (swigg_c_import
      .Dispatcher_extendDirective(self.swigCPtr_Dispatcher,
 standard.system.Address (getCPtr (n))));

   end extendDirective;


   function fragmentDirective (Self : access Item;
                          n : in swig_p_DOH.item'Class) return Integer
   is
   begin
      
  return Integer (swigg_c_import
      .Dispatcher_fragmentDirective(self.swigCPtr_Dispatcher,
 standard.system.Address (getCPtr (n))));

   end fragmentDirective;


   function importDirective (Self : access Item;
                          n : in swig_p_DOH.item'Class) return Integer
   is
   begin
      
  return Integer (swigg_c_import
      .Dispatcher_importDirective(self.swigCPtr_Dispatcher,
 standard.system.Address (getCPtr (n))));

   end importDirective;


   function includeDirective (Self : access Item;
                          n : in swig_p_DOH.item'Class) return Integer
   is
   begin
      
  return Integer (swigg_c_import
      .Dispatcher_includeDirective(self.swigCPtr_Dispatcher,
 standard.system.Address (getCPtr (n))));

   end includeDirective;


   function insertDirective (Self : access Item;
                          n : in swig_p_DOH.item'Class) return Integer
   is
   begin
      
  return Integer (swigg_c_import
      .Dispatcher_insertDirective(self.swigCPtr_Dispatcher,
 standard.system.Address (getCPtr (n))));

   end insertDirective;


   function moduleDirective (Self : access Item;
                          n : in swig_p_DOH.item'Class) return Integer
   is
   begin
      
  return Integer (swigg_c_import
      .Dispatcher_moduleDirective(self.swigCPtr_Dispatcher,
 standard.system.Address (getCPtr (n))));

   end moduleDirective;


   function nativeDirective (Self : access Item;
                          n : in swig_p_DOH.item'Class) return Integer
   is
   begin
      
  return Integer (swigg_c_import
      .Dispatcher_nativeDirective(self.swigCPtr_Dispatcher,
 standard.system.Address (getCPtr (n))));

   end nativeDirective;


   function pragmaDirective (Self : access Item;
                          n : in swig_p_DOH.item'Class) return Integer
   is
   begin
      
  return Integer (swigg_c_import
      .Dispatcher_pragmaDirective(self.swigCPtr_Dispatcher,
 standard.system.Address (getCPtr (n))));

   end pragmaDirective;


   function typemapDirective (Self : access Item;
                          n : in swig_p_DOH.item'Class) return Integer
   is
   begin
      
  return Integer (swigg_c_import
      .Dispatcher_typemapDirective(self.swigCPtr_Dispatcher,
 standard.system.Address (getCPtr (n))));

   end typemapDirective;


   function typemapitemDirective (Self : access Item;
                          n : in swig_p_DOH.item'Class) return Integer
   is
   begin
      
  return Integer (swigg_c_import
      .Dispatcher_typemapitemDirective(self.swigCPtr_Dispatcher,
 standard.system.Address (getCPtr (n))));

   end typemapitemDirective;


   function typemapcopyDirective (Self : access Item;
                          n : in swig_p_DOH.item'Class) return Integer
   is
   begin
      
  return Integer (swigg_c_import
      .Dispatcher_typemapcopyDirective(self.swigCPtr_Dispatcher,
 standard.system.Address (getCPtr (n))));

   end typemapcopyDirective;


   function typesDirective (Self : access Item;
                          n : in swig_p_DOH.item'Class) return Integer
   is
   begin
      
  return Integer (swigg_c_import
      .Dispatcher_typesDirective(self.swigCPtr_Dispatcher,
 standard.system.Address (getCPtr (n))));

   end typesDirective;


   function cDeclaration (Self : access Item;
                          n : in swig_p_DOH.item'Class) return Integer
   is
   begin
      
  return Integer (swigg_c_import
      .Dispatcher_cDeclaration(self.swigCPtr_Dispatcher,
 standard.system.Address (getCPtr (n))));

   end cDeclaration;


   function externDeclaration (Self : access Item;
                          n : in swig_p_DOH.item'Class) return Integer
   is
   begin
      
  return Integer (swigg_c_import
      .Dispatcher_externDeclaration(self.swigCPtr_Dispatcher,
 standard.system.Address (getCPtr (n))));

   end externDeclaration;


   function enumDeclaration (Self : access Item;
                          n : in swig_p_DOH.item'Class) return Integer
   is
   begin
      
  return Integer (swigg_c_import
      .Dispatcher_enumDeclaration(self.swigCPtr_Dispatcher,
 standard.system.Address (getCPtr (n))));

   end enumDeclaration;


   function enumvalueDeclaration (Self : access Item;
                          n : in swig_p_DOH.item'Class) return Integer
   is
   begin
      
  return Integer (swigg_c_import
      .Dispatcher_enumvalueDeclaration(self.swigCPtr_Dispatcher,
 standard.system.Address (getCPtr (n))));

   end enumvalueDeclaration;


   function enumforwardDeclaration (Self : access Item;
                          n : in swig_p_DOH.item'Class) return Integer
   is
   begin
      
  return Integer (swigg_c_import
      .Dispatcher_enumforwardDeclaration(self.swigCPtr_Dispatcher,
 standard.system.Address (getCPtr (n))));

   end enumforwardDeclaration;


   function classDeclaration (Self : access Item;
                          n : in swig_p_DOH.item'Class) return Integer
   is
   begin
      
  return Integer (swigg_c_import
      .Dispatcher_classDeclaration(self.swigCPtr_Dispatcher,
 standard.system.Address (getCPtr (n))));

   end classDeclaration;


   function classforwardDeclaration (Self : access Item;
                          n : in swig_p_DOH.item'Class) return Integer
   is
   begin
      
  return Integer (swigg_c_import
      .Dispatcher_classforwardDeclaration(self.swigCPtr_Dispatcher,
 standard.system.Address (getCPtr (n))));

   end classforwardDeclaration;


   function constructorDeclaration (Self : access Item;
                          n : in swig_p_DOH.item'Class) return Integer
   is
   begin
      
  return Integer (swigg_c_import
      .Dispatcher_constructorDeclaration(self.swigCPtr_Dispatcher,
 standard.system.Address (getCPtr (n))));

   end constructorDeclaration;


   function destructorDeclaration (Self : access Item;
                          n : in swig_p_DOH.item'Class) return Integer
   is
   begin
      
  return Integer (swigg_c_import
      .Dispatcher_destructorDeclaration(self.swigCPtr_Dispatcher,
 standard.system.Address (getCPtr (n))));

   end destructorDeclaration;


   function accessDeclaration (Self : access Item;
                          n : in swig_p_DOH.item'Class) return Integer
   is
   begin
      
  return Integer (swigg_c_import
      .Dispatcher_accessDeclaration(self.swigCPtr_Dispatcher,
 standard.system.Address (getCPtr (n))));

   end accessDeclaration;


   function usingDeclaration (Self : access Item;
                          n : in swig_p_DOH.item'Class) return Integer
   is
   begin
      
  return Integer (swigg_c_import
      .Dispatcher_usingDeclaration(self.swigCPtr_Dispatcher,
 standard.system.Address (getCPtr (n))));

   end usingDeclaration;


   function namespaceDeclaration (Self : access Item;
                          n : in swig_p_DOH.item'Class) return Integer
   is
   begin
      
  return Integer (swigg_c_import
      .Dispatcher_namespaceDeclaration(self.swigCPtr_Dispatcher,
 standard.system.Address (getCPtr (n))));

   end namespaceDeclaration;


   function templateDeclaration (Self : access Item;
                          n : in swig_p_DOH.item'Class) return Integer
   is
   begin
      
  return Integer (swigg_c_import
      .Dispatcher_templateDeclaration(self.swigCPtr_Dispatcher,
 standard.system.Address (getCPtr (n))));

   end templateDeclaration;


   procedure set_cplus_mode (Self : in Item;
                          cplus_mode : in Dispatcher.AccessMode.item) 
   is
   begin
      
      swigg_c_import
      .set_Dispatcher_cplus_mode(self.swigCPtr_Dispatcher,
 standard.interfaces.c.Int (standard.Dispatcher.AccessMode .to_c_Int (cplus_mode)));
   end set_cplus_mode;


   function get_cplus_mode (Self : in Item)  return Dispatcher.AccessMode.item
   is
   begin
      return Dispatcher.AccessMode.defined (swigg_c_import
      .get_Dispatcher_cplus_mode(self.swigCPtr_Dispatcher));
   end get_cplus_mode;


   -- Director support
   -- 


   function SwigDirector_Dispatcher_moduleDirective (Self : access Item'class;   n : system.Address) return interfaces.c.Int
   is
   begin
      return interfaces.c.Int (moduleDirective (Self, swig_p_DOH.defined (n, false)));
   end;



   function moduleDirective_is_overridden (Self : in Item) return Boolean
   is
   begin
      return false;
   end;


   function SwigDirector_Dispatcher_moduleDirective_is_overridden_dispatch (Self : access Item'class) return Boolean
   is
   begin
      return moduleDirective_is_overridden (Self.all);
   end;


   function SwigDirector_Dispatcher_insertDirective (Self : access Item'class;   n : system.Address) return interfaces.c.Int
   is
   begin
      return interfaces.c.Int (insertDirective (Self, swig_p_DOH.defined (n, false)));
   end;



   function insertDirective_is_overridden (Self : in Item) return Boolean
   is
   begin
      return false;
   end;


   function SwigDirector_Dispatcher_insertDirective_is_overridden_dispatch (Self : access Item'class) return Boolean
   is
   begin
      return insertDirective_is_overridden (Self.all);
   end;


   function SwigDirector_Dispatcher_includeDirective (Self : access Item'class;   n : system.Address) return interfaces.c.Int
   is
   begin
      return interfaces.c.Int (includeDirective (Self, swig_p_DOH.defined (n, false)));
   end;



   function includeDirective_is_overridden (Self : in Item) return Boolean
   is
   begin
      return false;
   end;


   function SwigDirector_Dispatcher_includeDirective_is_overridden_dispatch (Self : access Item'class) return Boolean
   is
   begin
      return includeDirective_is_overridden (Self.all);
   end;


   function SwigDirector_Dispatcher_importDirective (Self : access Item'class;   n : system.Address) return interfaces.c.Int
   is
   begin
      return interfaces.c.Int (importDirective (Self, swig_p_DOH.defined (n, false)));
   end;



   function importDirective_is_overridden (Self : in Item) return Boolean
   is
   begin
      return false;
   end;


   function SwigDirector_Dispatcher_importDirective_is_overridden_dispatch (Self : access Item'class) return Boolean
   is
   begin
      return importDirective_is_overridden (Self.all);
   end;


   function SwigDirector_Dispatcher_fragmentDirective (Self : access Item'class;   n : system.Address) return interfaces.c.Int
   is
   begin
      return interfaces.c.Int (fragmentDirective (Self, swig_p_DOH.defined (n, false)));
   end;



   function fragmentDirective_is_overridden (Self : in Item) return Boolean
   is
   begin
      return false;
   end;


   function SwigDirector_Dispatcher_fragmentDirective_is_overridden_dispatch (Self : access Item'class) return Boolean
   is
   begin
      return fragmentDirective_is_overridden (Self.all);
   end;


   function SwigDirector_Dispatcher_extendDirective (Self : access Item'class;   n : system.Address) return interfaces.c.Int
   is
   begin
      return interfaces.c.Int (extendDirective (Self, swig_p_DOH.defined (n, false)));
   end;



   function extendDirective_is_overridden (Self : in Item) return Boolean
   is
   begin
      return false;
   end;


   function SwigDirector_Dispatcher_extendDirective_is_overridden_dispatch (Self : access Item'class) return Boolean
   is
   begin
      return extendDirective_is_overridden (Self.all);
   end;


   function SwigDirector_Dispatcher_constantDirective (Self : access Item'class;   n : system.Address) return interfaces.c.Int
   is
   begin
      return interfaces.c.Int (constantDirective (Self, swig_p_DOH.defined (n, false)));
   end;



   function constantDirective_is_overridden (Self : in Item) return Boolean
   is
   begin
      return false;
   end;


   function SwigDirector_Dispatcher_constantDirective_is_overridden_dispatch (Self : access Item'class) return Boolean
   is
   begin
      return constantDirective_is_overridden (Self.all);
   end;


   function SwigDirector_Dispatcher_clearDirective (Self : access Item'class;   n : system.Address) return interfaces.c.Int
   is
   begin
      return interfaces.c.Int (clearDirective (Self, swig_p_DOH.defined (n, false)));
   end;



   function clearDirective_is_overridden (Self : in Item) return Boolean
   is
   begin
      return false;
   end;


   function SwigDirector_Dispatcher_clearDirective_is_overridden_dispatch (Self : access Item'class) return Boolean
   is
   begin
      return clearDirective_is_overridden (Self.all);
   end;


   function SwigDirector_Dispatcher_applyDirective (Self : access Item'class;   n : system.Address) return interfaces.c.Int
   is
   begin
      return interfaces.c.Int (applyDirective (Self, swig_p_DOH.defined (n, false)));
   end;



   function applyDirective_is_overridden (Self : in Item) return Boolean
   is
   begin
      return false;
   end;


   function SwigDirector_Dispatcher_applyDirective_is_overridden_dispatch (Self : access Item'class) return Boolean
   is
   begin
      return applyDirective_is_overridden (Self.all);
   end;


   function SwigDirector_Dispatcher_top (Self : access Item'class;   n : system.Address) return interfaces.c.Int
   is
   begin
      return interfaces.c.Int (top (Self, swig_p_DOH.defined (n, false)));
   end;



   function top_is_overridden (Self : in Item) return Boolean
   is
   begin
      return false;
   end;


   function SwigDirector_Dispatcher_top_is_overridden_dispatch (Self : access Item'class) return Boolean
   is
   begin
      return top_is_overridden (Self.all);
   end;


   function SwigDirector_Dispatcher_defaultHandler (Self : access Item'class;   n : system.Address) return interfaces.c.Int
   is
   begin
      return interfaces.c.Int (defaultHandler (Self, swig_p_DOH.defined (n, false)));
   end;



   function defaultHandler_is_overridden (Self : in Item) return Boolean
   is
   begin
      return false;
   end;


   function SwigDirector_Dispatcher_defaultHandler_is_overridden_dispatch (Self : access Item'class) return Boolean
   is
   begin
      return defaultHandler_is_overridden (Self.all);
   end;


   function SwigDirector_Dispatcher_emit_children (Self : access Item'class;   n : system.Address) return interfaces.c.Int
   is
   begin
      return interfaces.c.Int (emit_children (Self, swig_p_DOH.defined (n, false)));
   end;



   function emit_children_is_overridden (Self : in Item) return Boolean
   is
   begin
      return false;
   end;


   function SwigDirector_Dispatcher_emit_children_is_overridden_dispatch (Self : access Item'class) return Boolean
   is
   begin
      return emit_children_is_overridden (Self.all);
   end;


   function SwigDirector_Dispatcher_emit_one (Self : access Item'class;   n : system.Address) return interfaces.c.Int
   is
   begin
      return interfaces.c.Int (emit_one (Self, swig_p_DOH.defined (n, false)));
   end;



   function emit_one_is_overridden (Self : in Item) return Boolean
   is
   begin
      return false;
   end;


   function SwigDirector_Dispatcher_emit_one_is_overridden_dispatch (Self : access Item'class) return Boolean
   is
   begin
      return emit_one_is_overridden (Self.all);
   end;


   function SwigDirector_Dispatcher_nativeDirective (Self : access Item'class;   n : system.Address) return interfaces.c.Int
   is
   begin
      return interfaces.c.Int (nativeDirective (Self, swig_p_DOH.defined (n, false)));
   end;



   function nativeDirective_is_overridden (Self : in Item) return Boolean
   is
   begin
      return false;
   end;


   function SwigDirector_Dispatcher_nativeDirective_is_overridden_dispatch (Self : access Item'class) return Boolean
   is
   begin
      return nativeDirective_is_overridden (Self.all);
   end;


   function SwigDirector_Dispatcher_pragmaDirective (Self : access Item'class;   n : system.Address) return interfaces.c.Int
   is
   begin
      return interfaces.c.Int (pragmaDirective (Self, swig_p_DOH.defined (n, false)));
   end;



   function pragmaDirective_is_overridden (Self : in Item) return Boolean
   is
   begin
      return false;
   end;


   function SwigDirector_Dispatcher_pragmaDirective_is_overridden_dispatch (Self : access Item'class) return Boolean
   is
   begin
      return pragmaDirective_is_overridden (Self.all);
   end;


   function SwigDirector_Dispatcher_typemapDirective (Self : access Item'class;   n : system.Address) return interfaces.c.Int
   is
   begin
      return interfaces.c.Int (typemapDirective (Self, swig_p_DOH.defined (n, false)));
   end;



   function typemapDirective_is_overridden (Self : in Item) return Boolean
   is
   begin
      return false;
   end;


   function SwigDirector_Dispatcher_typemapDirective_is_overridden_dispatch (Self : access Item'class) return Boolean
   is
   begin
      return typemapDirective_is_overridden (Self.all);
   end;


   function SwigDirector_Dispatcher_typemapitemDirective (Self : access Item'class;   n : system.Address) return interfaces.c.Int
   is
   begin
      return interfaces.c.Int (typemapitemDirective (Self, swig_p_DOH.defined (n, false)));
   end;



   function typemapitemDirective_is_overridden (Self : in Item) return Boolean
   is
   begin
      return false;
   end;


   function SwigDirector_Dispatcher_typemapitemDirective_is_overridden_dispatch (Self : access Item'class) return Boolean
   is
   begin
      return typemapitemDirective_is_overridden (Self.all);
   end;


   function SwigDirector_Dispatcher_typemapcopyDirective (Self : access Item'class;   n : system.Address) return interfaces.c.Int
   is
   begin
      return interfaces.c.Int (typemapcopyDirective (Self, swig_p_DOH.defined (n, false)));
   end;



   function typemapcopyDirective_is_overridden (Self : in Item) return Boolean
   is
   begin
      return false;
   end;


   function SwigDirector_Dispatcher_typemapcopyDirective_is_overridden_dispatch (Self : access Item'class) return Boolean
   is
   begin
      return typemapcopyDirective_is_overridden (Self.all);
   end;


   function SwigDirector_Dispatcher_typesDirective (Self : access Item'class;   n : system.Address) return interfaces.c.Int
   is
   begin
      return interfaces.c.Int (typesDirective (Self, swig_p_DOH.defined (n, false)));
   end;



   function typesDirective_is_overridden (Self : in Item) return Boolean
   is
   begin
      return false;
   end;


   function SwigDirector_Dispatcher_typesDirective_is_overridden_dispatch (Self : access Item'class) return Boolean
   is
   begin
      return typesDirective_is_overridden (Self.all);
   end;


   function SwigDirector_Dispatcher_cDeclaration (Self : access Item'class;   n : system.Address) return interfaces.c.Int
   is
   begin
      return interfaces.c.Int (cDeclaration (Self, swig_p_DOH.defined (n, false)));
   end;



   function cDeclaration_is_overridden (Self : in Item) return Boolean
   is
   begin
      return false;
   end;


   function SwigDirector_Dispatcher_cDeclaration_is_overridden_dispatch (Self : access Item'class) return Boolean
   is
   begin
      return cDeclaration_is_overridden (Self.all);
   end;


   function SwigDirector_Dispatcher_externDeclaration (Self : access Item'class;   n : system.Address) return interfaces.c.Int
   is
   begin
      return interfaces.c.Int (externDeclaration (Self, swig_p_DOH.defined (n, false)));
   end;



   function externDeclaration_is_overridden (Self : in Item) return Boolean
   is
   begin
      return false;
   end;


   function SwigDirector_Dispatcher_externDeclaration_is_overridden_dispatch (Self : access Item'class) return Boolean
   is
   begin
      return externDeclaration_is_overridden (Self.all);
   end;


   function SwigDirector_Dispatcher_enumDeclaration (Self : access Item'class;   n : system.Address) return interfaces.c.Int
   is
   begin
      return interfaces.c.Int (enumDeclaration (Self, swig_p_DOH.defined (n, false)));
   end;



   function enumDeclaration_is_overridden (Self : in Item) return Boolean
   is
   begin
      return false;
   end;


   function SwigDirector_Dispatcher_enumDeclaration_is_overridden_dispatch (Self : access Item'class) return Boolean
   is
   begin
      return enumDeclaration_is_overridden (Self.all);
   end;


   function SwigDirector_Dispatcher_enumvalueDeclaration (Self : access Item'class;   n : system.Address) return interfaces.c.Int
   is
   begin
      return interfaces.c.Int (enumvalueDeclaration (Self, swig_p_DOH.defined (n, false)));
   end;



   function enumvalueDeclaration_is_overridden (Self : in Item) return Boolean
   is
   begin
      return false;
   end;


   function SwigDirector_Dispatcher_enumvalueDeclaration_is_overridden_dispatch (Self : access Item'class) return Boolean
   is
   begin
      return enumvalueDeclaration_is_overridden (Self.all);
   end;


   function SwigDirector_Dispatcher_enumforwardDeclaration (Self : access Item'class;   n : system.Address) return interfaces.c.Int
   is
   begin
      return interfaces.c.Int (enumforwardDeclaration (Self, swig_p_DOH.defined (n, false)));
   end;



   function enumforwardDeclaration_is_overridden (Self : in Item) return Boolean
   is
   begin
      return false;
   end;


   function SwigDirector_Dispatcher_enumforwardDeclaration_is_overridden_dispatch (Self : access Item'class) return Boolean
   is
   begin
      return enumforwardDeclaration_is_overridden (Self.all);
   end;


   function SwigDirector_Dispatcher_classDeclaration (Self : access Item'class;   n : system.Address) return interfaces.c.Int
   is
   begin
      return interfaces.c.Int (classDeclaration (Self, swig_p_DOH.defined (n, false)));
   end;



   function classDeclaration_is_overridden (Self : in Item) return Boolean
   is
   begin
      return false;
   end;


   function SwigDirector_Dispatcher_classDeclaration_is_overridden_dispatch (Self : access Item'class) return Boolean
   is
   begin
      return classDeclaration_is_overridden (Self.all);
   end;


   function SwigDirector_Dispatcher_classforwardDeclaration (Self : access Item'class;   n : system.Address) return interfaces.c.Int
   is
   begin
      return interfaces.c.Int (classforwardDeclaration (Self, swig_p_DOH.defined (n, false)));
   end;



   function classforwardDeclaration_is_overridden (Self : in Item) return Boolean
   is
   begin
      return false;
   end;


   function SwigDirector_Dispatcher_classforwardDeclaration_is_overridden_dispatch (Self : access Item'class) return Boolean
   is
   begin
      return classforwardDeclaration_is_overridden (Self.all);
   end;


   function SwigDirector_Dispatcher_constructorDeclaration (Self : access Item'class;   n : system.Address) return interfaces.c.Int
   is
   begin
      return interfaces.c.Int (constructorDeclaration (Self, swig_p_DOH.defined (n, false)));
   end;



   function constructorDeclaration_is_overridden (Self : in Item) return Boolean
   is
   begin
      return false;
   end;


   function SwigDirector_Dispatcher_constructorDeclaration_is_overridden_dispatch (Self : access Item'class) return Boolean
   is
   begin
      return constructorDeclaration_is_overridden (Self.all);
   end;


   function SwigDirector_Dispatcher_destructorDeclaration (Self : access Item'class;   n : system.Address) return interfaces.c.Int
   is
   begin
      return interfaces.c.Int (destructorDeclaration (Self, swig_p_DOH.defined (n, false)));
   end;



   function destructorDeclaration_is_overridden (Self : in Item) return Boolean
   is
   begin
      return false;
   end;


   function SwigDirector_Dispatcher_destructorDeclaration_is_overridden_dispatch (Self : access Item'class) return Boolean
   is
   begin
      return destructorDeclaration_is_overridden (Self.all);
   end;


   function SwigDirector_Dispatcher_accessDeclaration (Self : access Item'class;   n : system.Address) return interfaces.c.Int
   is
   begin
      return interfaces.c.Int (accessDeclaration (Self, swig_p_DOH.defined (n, false)));
   end;



   function accessDeclaration_is_overridden (Self : in Item) return Boolean
   is
   begin
      return false;
   end;


   function SwigDirector_Dispatcher_accessDeclaration_is_overridden_dispatch (Self : access Item'class) return Boolean
   is
   begin
      return accessDeclaration_is_overridden (Self.all);
   end;


   function SwigDirector_Dispatcher_usingDeclaration (Self : access Item'class;   n : system.Address) return interfaces.c.Int
   is
   begin
      return interfaces.c.Int (usingDeclaration (Self, swig_p_DOH.defined (n, false)));
   end;



   function usingDeclaration_is_overridden (Self : in Item) return Boolean
   is
   begin
      return false;
   end;


   function SwigDirector_Dispatcher_usingDeclaration_is_overridden_dispatch (Self : access Item'class) return Boolean
   is
   begin
      return usingDeclaration_is_overridden (Self.all);
   end;


   function SwigDirector_Dispatcher_namespaceDeclaration (Self : access Item'class;   n : system.Address) return interfaces.c.Int
   is
   begin
      return interfaces.c.Int (namespaceDeclaration (Self, swig_p_DOH.defined (n, false)));
   end;



   function namespaceDeclaration_is_overridden (Self : in Item) return Boolean
   is
   begin
      return false;
   end;


   function SwigDirector_Dispatcher_namespaceDeclaration_is_overridden_dispatch (Self : access Item'class) return Boolean
   is
   begin
      return namespaceDeclaration_is_overridden (Self.all);
   end;


   function SwigDirector_Dispatcher_templateDeclaration (Self : access Item'class;   n : system.Address) return interfaces.c.Int
   is
   begin
      return interfaces.c.Int (templateDeclaration (Self, swig_p_DOH.defined (n, false)));
   end;



   function templateDeclaration_is_overridden (Self : in Item) return Boolean
   is
   begin
      return false;
   end;


   function SwigDirector_Dispatcher_templateDeclaration_is_overridden_dispatch (Self : access Item'class) return Boolean
   is
   begin
      return templateDeclaration_is_overridden (Self.all);
   end;

   procedure swig_Director_disconnect (Self : in out Item) 
   is
   begin
      set_swigCMemOwn (Self, false);
      Dispose (Self);
   end;

   procedure swig_release_Ownership (Self : in out Item) 
   is
   begin
      set_swigCMemOwn (Self, false);
      swigg_c_import.Dispatcher_change_ownership (Self'address, self.swigCPtr_Dispatcher, false);
   end;

   procedure swig_take_Ownership (Self : in out Item) 
   is
   begin
      set_swigCMemOwn (Self, true);
      swigg_c_import.Dispatcher_change_ownership (Self'address, self.swigCPtr_Dispatcher, true);
   end;


   procedure swig_Director_connect (Self : in out Item)
   is
   begin
      
      --this($imcall, true);
      
    swigg_c_import.Dispatcher_director_connect (Self'address, self.swigCPtr_Dispatcher, get_swigCMemOwn (Self), true);
  
   end;





   procedure dummy_procedure is begin null; end;

end Dispatcher;