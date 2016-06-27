with
     System;

package body swigg_module
is
   use Language,
       swigg_c_import;

   --     function runtime_call_Depth return Integer
   --     is
   --     begin
   --
   --        return Integer (swigg_c_import.runtime_call_Depth);
   --
   --     end runtime_call_Depth;

   function String_in
     (the_string_Array : in swig_p_p_char.Item'Class;
      at_Index         : in Integer)
      return             Interfaces.C.Strings.chars_ptr
   is
   begin
      return swigg_c_import.String_in
               (System.Address (getCPtr (the_string_Array)),
                Interfaces.C.int (at_Index));

      --  exception
      --   when  interfaces.c.strings.Dereference_error =>
      --     return "";

   end String_in;

   function c_to_doh_String
     (c_String : in Interfaces.C.Strings.chars_ptr)
      return     swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.c_to_doh_String
              (Interfaces.C.Strings.chars_ptr (c_String));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end c_to_doh_String;

   function get_attribute
     (node : in swig_p_DOH.Item'Class;
      key  : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.get_attribute
              (System.Address (getCPtr (node)),
               System.Address (getCPtr (key)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end get_attribute;

   procedure set_attribute
     (node  : in swig_p_DOH.Item'Class;
      key   : in swig_p_DOH.Item'Class;
      value : in swig_p_DOH.Item'Class)
   is
   begin

      swigg_c_import.set_attribute
        (System.Address (getCPtr (node)),
         System.Address (getCPtr (key)),
         System.Address (getCPtr (value)));
   end set_attribute;

   function check_attribute
     (node  : in swig_p_DOH.Item'Class;
      key   : in swig_p_DOH.Item'Class;
      value : in swig_p_DOH.Item'Class)
      return  Boolean
   is
   begin

      return Boolean (swigg_c_import.check_attribute
                         (System.Address (getCPtr (node)),
                          System.Address (getCPtr (key)),
                          System.Address (getCPtr (value))));

   end check_attribute;

   function Node_to_CStr
     (node : in swig_p_DOH.Item'Class)
      return Interfaces.C.Strings.chars_ptr
   is
   begin

      return swigg_c_import.Node_to_CStr (System.Address (getCPtr (node)));

      --  exception
      --   when  interfaces.c.strings.Dereference_error =>
      --     return "";

   end Node_to_CStr;

   function node_Type
     (node : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.node_Type (System.Address (getCPtr (node)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end node_Type;

   function parent_Node
     (node : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.parent_Node (System.Address (getCPtr (node)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end parent_Node;

   function new_File
     (name : in swig_p_DOH.Item'Class;
      mode : in Interfaces.C.Strings.chars_ptr)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.new_File
              (System.Address (getCPtr (name)),
               Interfaces.C.Strings.chars_ptr (mode));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end new_File;

   procedure Print_to
     (Self     : in swig_p_DOH.Item'Class;
      the_Text : in Interfaces.C.Strings.chars_ptr)
   is
   begin

      swigg_c_import.Print_to
        (System.Address (getCPtr (Self)),
         Interfaces.C.Strings.chars_ptr (the_Text));
   end Print_to;

   procedure dump
     (from : in swig_p_DOH.Item'Class;
      to   : in swig_p_DOH.Item'Class)
   is
   begin

      swigg_c_import.dump
        (System.Address (getCPtr (from)),
         System.Address (getCPtr (to)));
   end dump;

   procedure close_File (Self : in swig_p_DOH.Item'Class) is
   begin

      swigg_c_import.close_File (System.Address (getCPtr (Self)));
   end close_File;

   procedure doh_replace_All
     (Self       : in swig_p_DOH.Item'Class;
      Pattern    : in swig_p_DOH.Item'Class;
      Substitute : in swig_p_DOH.Item'Class)
   is
   begin

      swigg_c_import.doh_replace_All
        (System.Address (getCPtr (Self)),
         System.Address (getCPtr (Pattern)),
         System.Address (getCPtr (Substitute)));
   end doh_replace_All;

   function doh_Copy
     (Self : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.doh_Copy (System.Address (getCPtr (Self)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end doh_Copy;

   procedure Swig_save_1
     (name_Space : in Interfaces.C.Strings.chars_ptr;
      the_Node   : in swig_p_DOH.Item'Class;
      Value      : in Interfaces.C.Strings.chars_ptr)
   is
   begin

      swigg_c_import.Swig_save_1
        (Interfaces.C.Strings.chars_ptr (name_Space),
         System.Address (getCPtr (the_Node)),
         Interfaces.C.Strings.chars_ptr (Value));
   end Swig_save_1;

   procedure Swig_require_2
     (name_Space : in Interfaces.C.Strings.chars_ptr;
      the_Node   : in swig_p_DOH.Item'Class;
      Value_1    : in swig_p_DOH.Item'Class;
      Value_2    : in swig_p_DOH.Item'Class)
   is
   begin

      swigg_c_import.Swig_require_2
        (Interfaces.C.Strings.chars_ptr (name_Space),
         System.Address (getCPtr (the_Node)),
         System.Address (getCPtr (Value_1)),
         System.Address (getCPtr (Value_2)));
   end Swig_require_2;

   procedure Wrapper_add_local_2
     (the_Wrapper : in Wrapper.Item'Class;
      Name        : in swig_p_DOH.Item'Class;
      Item_1      : in Interfaces.C.Strings.chars_ptr;
      Item_2      : in Interfaces.C.Strings.chars_ptr)
   is
   begin

      swigg_c_import.Wrapper_add_local_2
        (System.Address (getCPtr (the_Wrapper)),
         System.Address (getCPtr (Name)),
         Interfaces.C.Strings.chars_ptr (Item_1),
         Interfaces.C.Strings.chars_ptr (Item_2));
   end Wrapper_add_local_2;

   function first_Child
     (Self : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.first_Child (System.Address (getCPtr (Self)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end first_Child;

   function next_Sibling
     (Self : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.next_Sibling (System.Address (getCPtr (Self)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end next_Sibling;

   procedure exit_with_Fail is
   begin

      swigg_c_import.exit_with_Fail;
   end exit_with_Fail;

   function doh_First
     (obj  : in swig_p_DOH.Item'Class)
      return swig_p_DohIterator.Item'Class
   is
   begin

      declare
         the_Result : constant swig_p_DohIterator.Item'Class :=
           swig_p_DohIterator.defined
              (swigg_c_import.doh_First (System.Address (getCPtr (obj))),
               True);
      begin
         --$add_Reference
         return the_Result;
      end;

   end doh_First;

   function doh_Next
     (iter : in swig_p_DohIterator.Item'Class)
      return swig_p_DohIterator.Item'Class
   is
   begin

      declare
         the_Result : constant swig_p_DohIterator.Item'Class :=
           swig_p_DohIterator.defined
              (swigg_c_import.doh_Next (System.Address (getCPtr (iter))),
               True);
      begin
         --$add_Reference
         return the_Result;
      end;

   end doh_Next;

   function get_Item
     (Self : in swig_p_DohIterator.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.get_Item (System.Address (getCPtr (Self)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end get_Item;

   procedure do_base_top
     (Self : in Language.Item'Class;
      node : in swig_p_DOH.Item'Class)
   is
   begin

      swigg_c_import.do_base_top
        (System.Address (getCPtr (Self)),
         System.Address (getCPtr (node)));
   end do_base_top;

   procedure do_base_enumDeclaration
     (Self : in Language.Item'Class;
      node : in swig_p_DOH.Item'Class)
   is
   begin

      swigg_c_import.do_base_enumDeclaration
        (System.Address (getCPtr (Self)),
         System.Address (getCPtr (node)));
   end do_base_enumDeclaration;

   procedure do_base_classHandler
     (Self : in Language.Item'Class;
      node : in swig_p_DOH.Item'Class)
   is
   begin

      swigg_c_import.do_base_classHandler
        (System.Address (getCPtr (Self)),
         System.Address (getCPtr (node)));
   end do_base_classHandler;

   procedure do_base_memberfunctionHandler
     (Self : in Language.Item'Class;
      node : in swig_p_DOH.Item'Class)
   is
   begin

      swigg_c_import.do_base_memberfunctionHandler
        (System.Address (getCPtr (Self)),
         System.Address (getCPtr (node)));
   end do_base_memberfunctionHandler;

   procedure do_base_staticmemberfunctionHandler
     (Self : in Language.Item'Class;
      node : in swig_p_DOH.Item'Class)
   is
   begin

      swigg_c_import.do_base_staticmemberfunctionHandler
        (System.Address (getCPtr (Self)),
         System.Address (getCPtr (node)));
   end do_base_staticmemberfunctionHandler;

   procedure do_base_constructorHandler
     (Self : in Language.Item'Class;
      node : in swig_p_DOH.Item'Class)
   is
   begin

      swigg_c_import.do_base_constructorHandler
        (System.Address (getCPtr (Self)),
         System.Address (getCPtr (node)));
   end do_base_constructorHandler;

   procedure do_base_destructorHandler
     (Self : in Language.Item'Class;
      node : in swig_p_DOH.Item'Class)
   is
   begin

      swigg_c_import.do_base_destructorHandler
        (System.Address (getCPtr (Self)),
         System.Address (getCPtr (node)));
   end do_base_destructorHandler;

   procedure do_base_memberconstantHandler
     (Self : in Language.Item'Class;
      node : in swig_p_DOH.Item'Class)
   is
   begin

      swigg_c_import.do_base_memberconstantHandler
        (System.Address (getCPtr (Self)),
         System.Address (getCPtr (node)));
   end do_base_memberconstantHandler;

   function do_base_insertDirective
     (Self : in Language.Item'Class;
      node : in swig_p_DOH.Item'Class)
      return Integer
   is
   begin

      return Integer (swigg_c_import.do_base_insertDirective
                         (System.Address (getCPtr (Self)),
                          System.Address (getCPtr (node))));

   end do_base_insertDirective;

   function do_base_typemapDirective
     (Self : in Language.Item'Class;
      node : in swig_p_DOH.Item'Class)
      return Integer
   is
   begin

      return Integer (swigg_c_import.do_base_typemapDirective
                         (System.Address (getCPtr (Self)),
                          System.Address (getCPtr (node))));

   end do_base_typemapDirective;

   procedure do_base_namespaceDeclaration
     (Self : in Language.Item'Class;
      node : in swig_p_DOH.Item'Class)
   is
   begin

      swigg_c_import.do_base_namespaceDeclaration
        (System.Address (getCPtr (Self)),
         System.Address (getCPtr (node)));
   end do_base_namespaceDeclaration;

   procedure do_base_includeDirective
     (Self : in Language.Item'Class;
      node : in swig_p_DOH.Item'Class)
   is
   begin

      swigg_c_import.do_base_includeDirective
        (System.Address (getCPtr (Self)),
         System.Address (getCPtr (node)));
   end do_base_includeDirective;

   function NewSwigType
     (typecode : in Integer)
      return     swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.NewSwigType (Interfaces.C.int (typecode));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end NewSwigType;

   function SwigType_del_element
     (t    : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.SwigType_del_element
              (System.Address (getCPtr (t)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end SwigType_del_element;

   function SwigType_add_pointer
     (t    : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.SwigType_add_pointer
              (System.Address (getCPtr (t)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end SwigType_add_pointer;

   function SwigType_add_memberpointer
     (t    : in swig_p_DOH.Item'Class;
      qual : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.SwigType_add_memberpointer
              (System.Address (getCPtr (t)),
               System.Address (getCPtr (qual)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end SwigType_add_memberpointer;

   function SwigType_del_memberpointer
     (t    : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.SwigType_del_memberpointer
              (System.Address (getCPtr (t)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end SwigType_del_memberpointer;

   function SwigType_del_pointer
     (t    : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.SwigType_del_pointer
              (System.Address (getCPtr (t)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end SwigType_del_pointer;

   function SwigType_add_array
     (t    : in swig_p_DOH.Item'Class;
      size : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.SwigType_add_array
              (System.Address (getCPtr (t)),
               System.Address (getCPtr (size)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end SwigType_add_array;

   function SwigType_del_array
     (t    : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.SwigType_del_array (System.Address (getCPtr (t)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end SwigType_del_array;

   function SwigType_pop_arrays
     (t    : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.SwigType_pop_arrays
              (System.Address (getCPtr (t)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end SwigType_pop_arrays;

   function SwigType_add_reference
     (t    : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.SwigType_add_reference
              (System.Address (getCPtr (t)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end SwigType_add_reference;

   function SwigType_del_reference
     (t    : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.SwigType_del_reference
              (System.Address (getCPtr (t)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end SwigType_del_reference;

   function SwigType_add_qualifier
     (t    : in swig_p_DOH.Item'Class;
      qual : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.SwigType_add_qualifier
              (System.Address (getCPtr (t)),
               System.Address (getCPtr (qual)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end SwigType_add_qualifier;

   function SwigType_del_qualifier
     (t    : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.SwigType_del_qualifier
              (System.Address (getCPtr (t)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end SwigType_del_qualifier;

   function SwigType_add_function
     (t     : in swig_p_DOH.Item'Class;
      parms : in swig_p_DOH.Item'Class)
      return  swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.SwigType_add_function
              (System.Address (getCPtr (t)),
               System.Address (getCPtr (parms)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end SwigType_add_function;

   function SwigType_add_template
     (t     : in swig_p_DOH.Item'Class;
      parms : in swig_p_DOH.Item'Class)
      return  swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.SwigType_add_template
              (System.Address (getCPtr (t)),
               System.Address (getCPtr (parms)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end SwigType_add_template;

   function SwigType_pop_function
     (t    : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.SwigType_pop_function
              (System.Address (getCPtr (t)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end SwigType_pop_function;

   function SwigType_function_parms
     (t    : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.SwigType_function_parms
              (System.Address (getCPtr (t)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end SwigType_function_parms;

   function SwigType_split
     (t    : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.SwigType_split (System.Address (getCPtr (t)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end SwigType_split;

   function SwigType_pop
     (t    : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.SwigType_pop (System.Address (getCPtr (t)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end SwigType_pop;

   procedure SwigType_push
     (t : in swig_p_DOH.Item'Class;
      s : in swig_p_DOH.Item'Class)
   is
   begin

      swigg_c_import.SwigType_push
        (System.Address (getCPtr (t)),
         System.Address (getCPtr (s)));
   end SwigType_push;

   function SwigType_parmlist
     (p    : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.SwigType_parmlist (System.Address (getCPtr (p)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end SwigType_parmlist;

   function SwigType_parm
     (p    : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.SwigType_parm (System.Address (getCPtr (p)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end SwigType_parm;

   function SwigType_str
     (s    : in swig_p_DOH.Item'Class;
      id   : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.SwigType_str
              (System.Address (getCPtr (s)),
               System.Address (getCPtr (id)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end SwigType_str;

   function SwigType_lstr
     (s    : in swig_p_DOH.Item'Class;
      id   : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.SwigType_lstr
              (System.Address (getCPtr (s)),
               System.Address (getCPtr (id)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end SwigType_lstr;

   function SwigType_rcaststr
     (s    : in swig_p_DOH.Item'Class;
      id   : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.SwigType_rcaststr
              (System.Address (getCPtr (s)),
               System.Address (getCPtr (id)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end SwigType_rcaststr;

   function SwigType_lcaststr
     (s    : in swig_p_DOH.Item'Class;
      id   : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.SwigType_lcaststr
              (System.Address (getCPtr (s)),
               System.Address (getCPtr (id)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end SwigType_lcaststr;

   function SwigType_manglestr
     (t    : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.SwigType_manglestr (System.Address (getCPtr (t)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end SwigType_manglestr;

   function SwigType_ltype
     (t    : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.SwigType_ltype (System.Address (getCPtr (t)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end SwigType_ltype;

   function SwigType_ispointer
     (t    : in swig_p_DOH.Item'Class)
      return Integer
   is
   begin

      return Integer (swigg_c_import.SwigType_ispointer
                         (System.Address (getCPtr (t))));

   end SwigType_ispointer;

   function SwigType_ispointer_return
     (t    : in swig_p_DOH.Item'Class)
      return Integer
   is
   begin

      return Integer (swigg_c_import.SwigType_ispointer_return
                         (System.Address (getCPtr (t))));

   end SwigType_ispointer_return;

   function SwigType_isfunctionpointer
     (t    : in swig_p_DOH.Item'Class)
      return Integer
   is
   begin

      return Integer (swigg_c_import.SwigType_isfunctionpointer
                         (System.Address (getCPtr (t))));

   end SwigType_isfunctionpointer;

   function SwigType_ismemberpointer
     (t    : in swig_p_DOH.Item'Class)
      return Integer
   is
   begin

      return Integer (swigg_c_import.SwigType_ismemberpointer
                         (System.Address (getCPtr (t))));

   end SwigType_ismemberpointer;

   function SwigType_isreference
     (t    : in swig_p_DOH.Item'Class)
      return Integer
   is
   begin

      return Integer (swigg_c_import.SwigType_isreference
                         (System.Address (getCPtr (t))));

   end SwigType_isreference;

   function SwigType_isreference_return
     (t    : in swig_p_DOH.Item'Class)
      return Integer
   is
   begin

      return Integer (swigg_c_import.SwigType_isreference_return
                         (System.Address (getCPtr (t))));

   end SwigType_isreference_return;

   function SwigType_isarray (t : in swig_p_DOH.Item'Class) return Integer is
   begin

      return Integer (swigg_c_import.SwigType_isarray
                         (System.Address (getCPtr (t))));

   end SwigType_isarray;

   function SwigType_prefix_is_simple_1D_array
     (t    : in swig_p_DOH.Item'Class)
      return Integer
   is
   begin

      return Integer (swigg_c_import.SwigType_prefix_is_simple_1D_array
                         (System.Address (getCPtr (t))));

   end SwigType_prefix_is_simple_1D_array;

   function SwigType_isfunction
     (t    : in swig_p_DOH.Item'Class)
      return Integer
   is
   begin

      return Integer (swigg_c_import.SwigType_isfunction
                         (System.Address (getCPtr (t))));

   end SwigType_isfunction;

   function SwigType_isqualifier
     (t    : in swig_p_DOH.Item'Class)
      return Integer
   is
   begin

      return Integer (swigg_c_import.SwigType_isqualifier
                         (System.Address (getCPtr (t))));

   end SwigType_isqualifier;

   function SwigType_isconst (t : in swig_p_DOH.Item'Class) return Integer is
   begin

      return Integer (swigg_c_import.SwigType_isconst
                         (System.Address (getCPtr (t))));

   end SwigType_isconst;

   function SwigType_issimple (t : in swig_p_DOH.Item'Class) return Integer is
   begin

      return Integer (swigg_c_import.SwigType_issimple
                         (System.Address (getCPtr (t))));

   end SwigType_issimple;

   function SwigType_ismutable
     (t    : in swig_p_DOH.Item'Class)
      return Integer
   is
   begin

      return Integer (swigg_c_import.SwigType_ismutable
                         (System.Address (getCPtr (t))));

   end SwigType_ismutable;

   function SwigType_isvarargs
     (t    : in swig_p_DOH.Item'Class)
      return Integer
   is
   begin

      return Integer (swigg_c_import.SwigType_isvarargs
                         (System.Address (getCPtr (t))));

   end SwigType_isvarargs;

   function SwigType_istemplate
     (t    : in swig_p_DOH.Item'Class)
      return Integer
   is
   begin

      return Integer (swigg_c_import.SwigType_istemplate
                         (System.Address (getCPtr (t))));

   end SwigType_istemplate;

   function SwigType_isenum (t : in swig_p_DOH.Item'Class) return Integer is
   begin

      return Integer (swigg_c_import.SwigType_isenum
                         (System.Address (getCPtr (t))));

   end SwigType_isenum;

   function SwigType_check_decl
     (t    : in swig_p_DOH.Item'Class;
      decl : in swig_p_DOH.Item'Class)
      return Integer
   is
   begin

      return Integer (swigg_c_import.SwigType_check_decl
                         (System.Address (getCPtr (t)),
                          System.Address (getCPtr (decl))));

   end SwigType_check_decl;

   function SwigType_strip_qualifiers
     (t    : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.SwigType_strip_qualifiers
              (System.Address (getCPtr (t)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end SwigType_strip_qualifiers;

   function SwigType_functionpointer_decompose
     (t    : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.SwigType_functionpointer_decompose
              (System.Address (getCPtr (t)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end SwigType_functionpointer_decompose;

   function SwigType_base
     (t    : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.SwigType_base (System.Address (getCPtr (t)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end SwigType_base;

   function SwigType_namestr
     (t    : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.SwigType_namestr (System.Address (getCPtr (t)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end SwigType_namestr;

   function SwigType_templateprefix
     (t    : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.SwigType_templateprefix
              (System.Address (getCPtr (t)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end SwigType_templateprefix;

   function SwigType_templatesuffix
     (t    : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.SwigType_templatesuffix
              (System.Address (getCPtr (t)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end SwigType_templatesuffix;

   function SwigType_templateargs
     (t    : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.SwigType_templateargs
              (System.Address (getCPtr (t)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end SwigType_templateargs;

   function SwigType_prefix
     (t    : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.SwigType_prefix (System.Address (getCPtr (t)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end SwigType_prefix;

   function SwigType_array_ndim
     (t    : in swig_p_DOH.Item'Class)
      return Integer
   is
   begin

      return Integer (swigg_c_import.SwigType_array_ndim
                         (System.Address (getCPtr (t))));

   end SwigType_array_ndim;

   function SwigType_array_getdim
     (t    : in swig_p_DOH.Item'Class;
      n    : in Integer)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.SwigType_array_getdim
              (System.Address (getCPtr (t)),
               Interfaces.C.int (n));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end SwigType_array_getdim;

   procedure SwigType_array_setdim
     (t   : in swig_p_DOH.Item'Class;
      n   : in Integer;
      rep : in swig_p_DOH.Item'Class)
   is
   begin

      swigg_c_import.SwigType_array_setdim
        (System.Address (getCPtr (t)),
         Interfaces.C.int (n),
         System.Address (getCPtr (rep)));
   end SwigType_array_setdim;

   function SwigType_array_type
     (t    : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.SwigType_array_type
              (System.Address (getCPtr (t)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end SwigType_array_type;

   function SwigType_default
     (t    : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.SwigType_default (System.Address (getCPtr (t)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end SwigType_default;

   procedure SwigType_typename_replace
     (t   : in swig_p_DOH.Item'Class;
      pat : in swig_p_DOH.Item'Class;
      rep : in swig_p_DOH.Item'Class)
   is
   begin

      swigg_c_import.SwigType_typename_replace
        (System.Address (getCPtr (t)),
         System.Address (getCPtr (pat)),
         System.Address (getCPtr (rep)));
   end SwigType_typename_replace;

   function SwigType_alttype
     (t     : in swig_p_DOH.Item'Class;
      ltmap : in Integer)
      return  swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.SwigType_alttype
              (System.Address (getCPtr (t)),
               Interfaces.C.int (ltmap));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end SwigType_alttype;

   procedure SwigType_typesystem_init is
   begin

      swigg_c_import.SwigType_typesystem_init;
   end SwigType_typesystem_init;

   function SwigType_typedef
     (type_arg : in swig_p_DOH.Item'Class;
      name     : in swig_p_DOH.Item'Class)
      return     Integer
   is
   begin

      return Integer (swigg_c_import.SwigType_typedef
                         (System.Address (getCPtr (type_arg)),
                          System.Address (getCPtr (name))));

   end SwigType_typedef;

   function SwigType_typedef_class
     (name : in swig_p_DOH.Item'Class)
      return Integer
   is
   begin

      return Integer (swigg_c_import.SwigType_typedef_class
                         (System.Address (getCPtr (name))));

   end SwigType_typedef_class;

   function SwigType_typedef_using
     (qname : in swig_p_DOH.Item'Class)
      return  Integer
   is
   begin

      return Integer (swigg_c_import.SwigType_typedef_using
                         (System.Address (getCPtr (qname))));

   end SwigType_typedef_using;

   procedure SwigType_inherit
     (subclass       : in swig_p_DOH.Item'Class;
      baseclass      : in swig_p_DOH.Item'Class;
      cast           : in swig_p_DOH.Item'Class;
      conversioncode : in swig_p_DOH.Item'Class)
   is
   begin

      swigg_c_import.SwigType_inherit
        (System.Address (getCPtr (subclass)),
         System.Address (getCPtr (baseclass)),
         System.Address (getCPtr (cast)),
         System.Address (getCPtr (conversioncode)));
   end SwigType_inherit;

   function SwigType_issubtype
     (subtype_arg : in swig_p_DOH.Item'Class;
      basetype    : in swig_p_DOH.Item'Class)
      return        Integer
   is
   begin

      return Integer (swigg_c_import.SwigType_issubtype
                         (System.Address (getCPtr (subtype_arg)),
                          System.Address (getCPtr (basetype))));

   end SwigType_issubtype;

   procedure SwigType_scope_alias
     (aliasname : in swig_p_DOH.Item'Class;
      t         : in swig_p_DOH.Item'Class)
   is
   begin

      swigg_c_import.SwigType_scope_alias
        (System.Address (getCPtr (aliasname)),
         System.Address (getCPtr (t)));
   end SwigType_scope_alias;

   procedure SwigType_using_scope (t : in swig_p_DOH.Item'Class) is
   begin

      swigg_c_import.SwigType_using_scope (System.Address (getCPtr (t)));
   end SwigType_using_scope;

   procedure SwigType_new_scope (name : in swig_p_DOH.Item'Class) is
   begin

      swigg_c_import.SwigType_new_scope (System.Address (getCPtr (name)));
   end SwigType_new_scope;

   procedure SwigType_inherit_scope (scope : in swig_p_DOH.Item'Class) is
   begin

      swigg_c_import.SwigType_inherit_scope
        (System.Address (getCPtr (scope)));
   end SwigType_inherit_scope;

   function SwigType_pop_scope return  swig_p_DOH.Item'Class is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.SwigType_pop_scope;
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end SwigType_pop_scope;

   function SwigType_set_scope
     (h    : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.SwigType_set_scope (System.Address (getCPtr (h)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end SwigType_set_scope;

   procedure SwigType_print_scope (t : in swig_p_DOH.Item'Class) is
   begin

      swigg_c_import.SwigType_print_scope (System.Address (getCPtr (t)));
   end SwigType_print_scope;

   function SwigType_typedef_resolve
     (t    : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.SwigType_typedef_resolve
              (System.Address (getCPtr (t)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end SwigType_typedef_resolve;

   function SwigType_typedef_resolve_all
     (t    : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.SwigType_typedef_resolve_all
              (System.Address (getCPtr (t)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end SwigType_typedef_resolve_all;

   function SwigType_typedef_qualified
     (t    : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.SwigType_typedef_qualified
              (System.Address (getCPtr (t)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end SwigType_typedef_qualified;

   function SwigType_istypedef
     (t    : in swig_p_DOH.Item'Class)
      return Integer
   is
   begin

      return Integer (swigg_c_import.SwigType_istypedef
                         (System.Address (getCPtr (t))));

   end SwigType_istypedef;

   function SwigType_isclass (t : in swig_p_DOH.Item'Class) return Integer is
   begin

      return Integer (swigg_c_import.SwigType_isclass
                         (System.Address (getCPtr (t))));

   end SwigType_isclass;

   procedure SwigType_attach_symtab (syms : in swig_p_DOH.Item'Class) is
   begin

      swigg_c_import.SwigType_attach_symtab
        (System.Address (getCPtr (syms)));
   end SwigType_attach_symtab;

   procedure SwigType_remember (t : in swig_p_DOH.Item'Class) is
   begin

      swigg_c_import.SwigType_remember (System.Address (getCPtr (t)));
   end SwigType_remember;

   procedure SwigType_remember_clientdata
     (t          : in swig_p_DOH.Item'Class;
      clientdata : in swig_p_DOH.Item'Class)
   is
   begin

      swigg_c_import.SwigType_remember_clientdata
        (System.Address (getCPtr (t)),
         System.Address (getCPtr (clientdata)));
   end SwigType_remember_clientdata;

   procedure SwigType_remember_mangleddata
     (mangled    : in swig_p_DOH.Item'Class;
      clientdata : in swig_p_DOH.Item'Class)
   is
   begin

      swigg_c_import.SwigType_remember_mangleddata
        (System.Address (getCPtr (mangled)),
         System.Address (getCPtr (clientdata)));
   end SwigType_remember_mangleddata;

   function SwigType_remember_trace
     (tf   : in swig_p_f_p_DOH_p_DOH_p_DOH_ret_void.Item'Class)
      return swig_p_f_p_DOH_p_DOH_p_DOH_ret_void.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address :=
           swigg_c_import.SwigType_remember_trace
              (System.Address (getCPtr (tf)));
         the_Result : constant swig_p_f_p_DOH_p_DOH_p_DOH_ret_void.Item'Class
            :=
           swig_p_f_p_DOH_p_DOH_p_DOH_ret_void.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end SwigType_remember_trace;

   procedure SwigType_emit_type_table
     (f_headers : in swig_p_DOH.Item'Class;
      f_table   : in swig_p_DOH.Item'Class)
   is
   begin

      swigg_c_import.SwigType_emit_type_table
        (System.Address (getCPtr (f_headers)),
         System.Address (getCPtr (f_table)));
   end SwigType_emit_type_table;

   function SwigType_type (t : in swig_p_DOH.Item'Class) return Integer is
   begin

      return Integer (swigg_c_import.SwigType_type
                         (System.Address (getCPtr (t))));

   end SwigType_type;

   procedure Swig_symbol_init is
   begin

      swigg_c_import.Swig_symbol_init;
   end Swig_symbol_init;

   procedure Swig_symbol_setscopename (name : in swig_p_DOH.Item'Class) is
   begin

      swigg_c_import.Swig_symbol_setscopename
        (System.Address (getCPtr (name)));
   end Swig_symbol_setscopename;

   function Swig_symbol_getscopename return  swig_p_DOH.Item'Class is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_symbol_getscopename;
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_symbol_getscopename;

   function Swig_symbol_qualifiedscopename
     (symtab : in swig_p_DOH.Item'Class)
      return   swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_symbol_qualifiedscopename
              (System.Address (getCPtr (symtab)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_symbol_qualifiedscopename;

   function Swig_symbol_newscope return  swig_p_DOH.Item'Class is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_symbol_newscope;
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_symbol_newscope;

   function Swig_symbol_setscope
     (arg0 : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_symbol_setscope
              (System.Address (getCPtr (arg0)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_symbol_setscope;

   function Swig_symbol_getscope
     (symname : in swig_p_DOH.Item'Class)
      return    swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_symbol_getscope
              (System.Address (getCPtr (symname)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_symbol_getscope;

   function Swig_symbol_current return  swig_p_DOH.Item'Class is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_symbol_current;
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_symbol_current;

   function Swig_symbol_popscope return  swig_p_DOH.Item'Class is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_symbol_popscope;
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_symbol_popscope;

   function Swig_symbol_add
     (symname : in swig_p_DOH.Item'Class;
      node    : in swig_p_DOH.Item'Class)
      return    swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_symbol_add
              (System.Address (getCPtr (symname)),
               System.Address (getCPtr (node)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_symbol_add;

   procedure Swig_symbol_cadd
     (symname : in swig_p_DOH.Item'Class;
      node    : in swig_p_DOH.Item'Class)
   is
   begin

      swigg_c_import.Swig_symbol_cadd
        (System.Address (getCPtr (symname)),
         System.Address (getCPtr (node)));
   end Swig_symbol_cadd;

   function Swig_symbol_clookup
     (symname : in swig_p_DOH.Item'Class;
      tab     : in swig_p_DOH.Item'Class)
      return    swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_symbol_clookup
              (System.Address (getCPtr (symname)),
               System.Address (getCPtr (tab)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_symbol_clookup;

   function Swig_symbol_clookup_check
     (symname : in swig_p_DOH.Item'Class;
      tab     : in swig_p_DOH.Item'Class;
      check   : in swig_p_f_p_DOH_ret_int.Item'Class)
      return    swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_symbol_clookup_check
              (System.Address (getCPtr (symname)),
               System.Address (getCPtr (tab)),
               System.Address (getCPtr (check)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_symbol_clookup_check;

   function Swig_symbol_cscope
     (symname : in swig_p_DOH.Item'Class;
      tab     : in swig_p_DOH.Item'Class)
      return    swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_symbol_cscope
              (System.Address (getCPtr (symname)),
               System.Address (getCPtr (tab)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_symbol_cscope;

   function Swig_symbol_clookup_local
     (symname : in swig_p_DOH.Item'Class;
      tab     : in swig_p_DOH.Item'Class)
      return    swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_symbol_clookup_local
              (System.Address (getCPtr (symname)),
               System.Address (getCPtr (tab)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_symbol_clookup_local;

   function Swig_symbol_clookup_local_check
     (symname : in swig_p_DOH.Item'Class;
      tab     : in swig_p_DOH.Item'Class;
      check   : in swig_p_f_p_DOH_ret_int.Item'Class)
      return    swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_symbol_clookup_local_check
              (System.Address (getCPtr (symname)),
               System.Address (getCPtr (tab)),
               System.Address (getCPtr (check)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_symbol_clookup_local_check;

   function Swig_symbol_qualified
     (node : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_symbol_qualified
              (System.Address (getCPtr (node)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_symbol_qualified;

   function Swig_symbol_isoverloaded
     (node : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_symbol_isoverloaded
              (System.Address (getCPtr (node)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_symbol_isoverloaded;

   procedure Swig_symbol_remove (node : in swig_p_DOH.Item'Class) is
   begin

      swigg_c_import.Swig_symbol_remove (System.Address (getCPtr (node)));
   end Swig_symbol_remove;

   procedure Swig_symbol_alias
     (aliasname : in swig_p_DOH.Item'Class;
      tab       : in swig_p_DOH.Item'Class)
   is
   begin

      swigg_c_import.Swig_symbol_alias
        (System.Address (getCPtr (aliasname)),
         System.Address (getCPtr (tab)));
   end Swig_symbol_alias;

   procedure Swig_symbol_inherit (tab : in swig_p_DOH.Item'Class) is
   begin

      swigg_c_import.Swig_symbol_inherit (System.Address (getCPtr (tab)));
   end Swig_symbol_inherit;

   function Swig_symbol_type_qualify
     (ty   : in swig_p_DOH.Item'Class;
      tab  : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_symbol_type_qualify
              (System.Address (getCPtr (ty)),
               System.Address (getCPtr (tab)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_symbol_type_qualify;

   function Swig_symbol_string_qualify
     (s    : in swig_p_DOH.Item'Class;
      tab  : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_symbol_string_qualify
              (System.Address (getCPtr (s)),
               System.Address (getCPtr (tab)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_symbol_string_qualify;

   function Swig_symbol_typedef_reduce
     (ty   : in swig_p_DOH.Item'Class;
      tab  : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_symbol_typedef_reduce
              (System.Address (getCPtr (ty)),
               System.Address (getCPtr (tab)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_symbol_typedef_reduce;

   function Swig_symbol_template_defargs
     (parms  : in swig_p_DOH.Item'Class;
      targs  : in swig_p_DOH.Item'Class;
      tscope : in swig_p_DOH.Item'Class;
      tsdecl : in swig_p_DOH.Item'Class)
      return   swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_symbol_template_defargs
              (System.Address (getCPtr (parms)),
               System.Address (getCPtr (targs)),
               System.Address (getCPtr (tscope)),
               System.Address (getCPtr (tsdecl)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_symbol_template_defargs;

   function Swig_symbol_template_deftype
     (type_arg : in swig_p_DOH.Item'Class;
      tscope   : in swig_p_DOH.Item'Class)
      return     swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_symbol_template_deftype
              (System.Address (getCPtr (type_arg)),
               System.Address (getCPtr (tscope)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_symbol_template_deftype;

   function Swig_symbol_template_param_eval
     (p      : in swig_p_DOH.Item'Class;
      symtab : in swig_p_DOH.Item'Class)
      return   swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_symbol_template_param_eval
              (System.Address (getCPtr (p)),
               System.Address (getCPtr (symtab)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_symbol_template_param_eval;

   function ParmList_errorstr
     (arg0 : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.ParmList_errorstr
              (System.Address (getCPtr (arg0)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end ParmList_errorstr;

   function ParmList_is_compactdefargs
     (p    : in swig_p_DOH.Item'Class)
      return Integer
   is
   begin

      return Integer (swigg_c_import.ParmList_is_compactdefargs
                         (System.Address (getCPtr (p))));

   end ParmList_is_compactdefargs;

   procedure Swig_name_register
     (method : in swig_p_DOH.Item'Class;
      format : in swig_p_DOH.Item'Class)
   is
   begin

      swigg_c_import.Swig_name_register
        (System.Address (getCPtr (method)),
         System.Address (getCPtr (format)));
   end Swig_name_register;

   procedure Swig_name_unregister (method : in swig_p_DOH.Item'Class) is
   begin

      swigg_c_import.Swig_name_unregister
        (System.Address (getCPtr (method)));
   end Swig_name_unregister;

   function Swig_name_mangle
     (s    : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_name_mangle (System.Address (getCPtr (s)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_name_mangle;

   function Swig_name_wrapper
     (fname : in swig_p_DOH.Item'Class)
      return  swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_name_wrapper
              (System.Address (getCPtr (fname)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_name_wrapper;

   function Swig_name_member
     (classname : in swig_p_DOH.Item'Class;
      mname     : in swig_p_DOH.Item'Class)
      return      swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_name_member
              (System.Address (getCPtr (classname)),
               System.Address (getCPtr (mname)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_name_member;

   function Swig_name_get
     (vname : in swig_p_DOH.Item'Class)
      return  swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_name_get (System.Address (getCPtr (vname)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_name_get;

   function Swig_name_set
     (vname : in swig_p_DOH.Item'Class)
      return  swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_name_set (System.Address (getCPtr (vname)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_name_set;

   function Swig_name_construct
     (classname : in swig_p_DOH.Item'Class)
      return      swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_name_construct
              (System.Address (getCPtr (classname)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_name_construct;

   function Swig_name_copyconstructor
     (classname : in swig_p_DOH.Item'Class)
      return      swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_name_copyconstructor
              (System.Address (getCPtr (classname)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_name_copyconstructor;

   function Swig_name_destroy
     (classname : in swig_p_DOH.Item'Class)
      return      swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_name_destroy
              (System.Address (getCPtr (classname)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_name_destroy;

   function Swig_name_disown
     (classname : in swig_p_DOH.Item'Class)
      return      swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_name_disown
              (System.Address (getCPtr (classname)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_name_disown;

   procedure Swig_name_namewarn_add
     (prefix  : in swig_p_DOH.Item'Class;
      name    : in swig_p_DOH.Item'Class;
      decl    : in swig_p_DOH.Item'Class;
      namewrn : in swig_p_DOH.Item'Class)
   is
   begin

      swigg_c_import.Swig_name_namewarn_add
        (System.Address (getCPtr (prefix)),
         System.Address (getCPtr (name)),
         System.Address (getCPtr (decl)),
         System.Address (getCPtr (namewrn)));
   end Swig_name_namewarn_add;

   function Swig_name_namewarn_get
     (n      : in swig_p_DOH.Item'Class;
      prefix : in swig_p_DOH.Item'Class;
      name   : in swig_p_DOH.Item'Class;
      decl   : in swig_p_DOH.Item'Class)
      return   swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_name_namewarn_get
              (System.Address (getCPtr (n)),
               System.Address (getCPtr (prefix)),
               System.Address (getCPtr (name)),
               System.Address (getCPtr (decl)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_name_namewarn_get;

   procedure Swig_name_rename_add
     (prefix          : in swig_p_DOH.Item'Class;
      name            : in swig_p_DOH.Item'Class;
      decl            : in swig_p_DOH.Item'Class;
      namewrn         : in swig_p_DOH.Item'Class;
      declaratorparms : in swig_p_DOH.Item'Class)
   is
   begin

      swigg_c_import.Swig_name_rename_add
        (System.Address (getCPtr (prefix)),
         System.Address (getCPtr (name)),
         System.Address (getCPtr (decl)),
         System.Address (getCPtr (namewrn)),
         System.Address (getCPtr (declaratorparms)));
   end Swig_name_rename_add;

   procedure Swig_name_inherit
     (base    : in swig_p_DOH.Item'Class;
      derived : in swig_p_DOH.Item'Class)
   is
   begin

      swigg_c_import.Swig_name_inherit
        (System.Address (getCPtr (base)),
         System.Address (getCPtr (derived)));
   end Swig_name_inherit;

   function Swig_need_protected
     (n    : in swig_p_DOH.Item'Class)
      return Integer
   is
   begin

      return Integer (swigg_c_import.Swig_need_protected
                         (System.Address (getCPtr (n))));

   end Swig_need_protected;

   function Swig_need_name_warning
     (n    : in swig_p_DOH.Item'Class)
      return Integer
   is
   begin

      return Integer (swigg_c_import.Swig_need_name_warning
                         (System.Address (getCPtr (n))));

   end Swig_need_name_warning;

   function Swig_need_redefined_warn
     (a       : in swig_p_DOH.Item'Class;
      b       : in swig_p_DOH.Item'Class;
      InClass : in Integer)
      return    Integer
   is
   begin

      return Integer (swigg_c_import.Swig_need_redefined_warn
                         (System.Address (getCPtr (a)),
                          System.Address (getCPtr (b)),
                          Interfaces.C.int (InClass)));

   end Swig_need_redefined_warn;

   function Swig_name_make
     (n       : in swig_p_DOH.Item'Class;
      prefix  : in swig_p_DOH.Item'Class;
      cname   : in swig_p_DOH.Item'Class;
      decl    : in swig_p_DOH.Item'Class;
      oldname : in swig_p_DOH.Item'Class)
      return    swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_name_make
              (System.Address (getCPtr (n)),
               System.Address (getCPtr (prefix)),
               System.Address (getCPtr (cname)),
               System.Address (getCPtr (decl)),
               System.Address (getCPtr (oldname)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_name_make;

   function Swig_name_warning
     (n      : in swig_p_DOH.Item'Class;
      prefix : in swig_p_DOH.Item'Class;
      name   : in swig_p_DOH.Item'Class;
      decl   : in swig_p_DOH.Item'Class)
      return   swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_name_warning
              (System.Address (getCPtr (n)),
               System.Address (getCPtr (prefix)),
               System.Address (getCPtr (name)),
               System.Address (getCPtr (decl)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_name_warning;

   function Swig_name_decl
     (n    : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_name_decl (System.Address (getCPtr (n)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_name_decl;

   function Swig_name_fulldecl
     (n    : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_name_fulldecl (System.Address (getCPtr (n)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_name_fulldecl;

   procedure Swig_name_object_set
     (namehash : in swig_p_DOH.Item'Class;
      name     : in swig_p_DOH.Item'Class;
      decl     : in swig_p_DOH.Item'Class;
      object   : in swig_p_DOH.Item'Class)
   is
   begin

      swigg_c_import.Swig_name_object_set
        (System.Address (getCPtr (namehash)),
         System.Address (getCPtr (name)),
         System.Address (getCPtr (decl)),
         System.Address (getCPtr (object)));
   end Swig_name_object_set;

   function Swig_name_object_get
     (namehash : in swig_p_DOH.Item'Class;
      prefix   : in swig_p_DOH.Item'Class;
      name     : in swig_p_DOH.Item'Class;
      decl     : in swig_p_DOH.Item'Class)
      return     swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_name_object_get
              (System.Address (getCPtr (namehash)),
               System.Address (getCPtr (prefix)),
               System.Address (getCPtr (name)),
               System.Address (getCPtr (decl)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_name_object_get;

   procedure Swig_name_object_inherit
     (namehash : in swig_p_DOH.Item'Class;
      base     : in swig_p_DOH.Item'Class;
      derived  : in swig_p_DOH.Item'Class)
   is
   begin

      swigg_c_import.Swig_name_object_inherit
        (System.Address (getCPtr (namehash)),
         System.Address (getCPtr (base)),
         System.Address (getCPtr (derived)));
   end Swig_name_object_inherit;

   procedure Swig_features_get
     (features : in swig_p_DOH.Item'Class;
      prefix   : in swig_p_DOH.Item'Class;
      name     : in swig_p_DOH.Item'Class;
      decl     : in swig_p_DOH.Item'Class;
      n        : in swig_p_DOH.Item'Class)
   is
   begin

      swigg_c_import.Swig_features_get
        (System.Address (getCPtr (features)),
         System.Address (getCPtr (prefix)),
         System.Address (getCPtr (name)),
         System.Address (getCPtr (decl)),
         System.Address (getCPtr (n)));
   end Swig_features_get;

   procedure Swig_feature_set
     (features       : in swig_p_DOH.Item'Class;
      name           : in swig_p_DOH.Item'Class;
      decl           : in swig_p_DOH.Item'Class;
      featurename    : in swig_p_DOH.Item'Class;
      value          : in swig_p_DOH.Item'Class;
      featureattribs : in swig_p_DOH.Item'Class)
   is
   begin

      swigg_c_import.Swig_feature_set
        (System.Address (getCPtr (features)),
         System.Address (getCPtr (name)),
         System.Address (getCPtr (decl)),
         System.Address (getCPtr (featurename)),
         System.Address (getCPtr (value)),
         System.Address (getCPtr (featureattribs)));
   end Swig_feature_set;

   function Swig_copy_string
     (c    : in Interfaces.C.Strings.chars_ptr)
      return Interfaces.C.Strings.chars_ptr
   is
   begin

      return swigg_c_import.Swig_copy_string
               (Interfaces.C.Strings.chars_ptr (c));

      --  exception
      --   when  interfaces.c.strings.Dereference_error =>
      --     return "";

   end Swig_copy_string;

   procedure Swig_set_fakeversion
     (version : in Interfaces.C.Strings.chars_ptr)
   is
   begin

      swigg_c_import.Swig_set_fakeversion
        (Interfaces.C.Strings.chars_ptr (version));
   end Swig_set_fakeversion;

   function Swig_package_version return  Interfaces.C.Strings.chars_ptr is
   begin

      return swigg_c_import.Swig_package_version;

      --  exception
      --   when  interfaces.c.strings.Dereference_error =>
      --     return "";

   end Swig_package_version;

   procedure Swig_banner (f : in swig_p_DOH.Item'Class) is
   begin

      swigg_c_import.Swig_banner (System.Address (getCPtr (f)));
   end Swig_banner;

   function Swig_strip_c_comments
     (s    : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_strip_c_comments
              (System.Address (getCPtr (s)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_strip_c_comments;

   function Swig_string_escape
     (s    : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_string_escape (System.Address (getCPtr (s)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_string_escape;

   function Swig_string_mangle
     (s    : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_string_mangle (System.Address (getCPtr (s)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_string_mangle;

   procedure Swig_scopename_split
     (s      : in swig_p_DOH.Item'Class;
      prefix : in swig_p_p_DOH.Item'Class;
      last   : in swig_p_p_DOH.Item'Class)
   is
   begin

      swigg_c_import.Swig_scopename_split
        (System.Address (getCPtr (s)),
         System.Address (getCPtr (prefix)),
         System.Address (getCPtr (last)));
   end Swig_scopename_split;

   function Swig_scopename_prefix
     (s    : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_scopename_prefix
              (System.Address (getCPtr (s)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_scopename_prefix;

   function Swig_scopename_last
     (s    : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_scopename_last
              (System.Address (getCPtr (s)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_scopename_last;

   function Swig_scopename_first
     (s    : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_scopename_first
              (System.Address (getCPtr (s)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_scopename_first;

   function Swig_scopename_suffix
     (s    : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_scopename_suffix
              (System.Address (getCPtr (s)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_scopename_suffix;

   function Swig_scopename_check
     (s    : in swig_p_DOH.Item'Class)
      return Integer
   is
   begin

      return Integer (swigg_c_import.Swig_scopename_check
                         (System.Address (getCPtr (s))));

   end Swig_scopename_check;

   function Swig_string_lower
     (s    : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_string_lower (System.Address (getCPtr (s)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_string_lower;

   function Swig_string_upper
     (s    : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_string_upper (System.Address (getCPtr (s)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_string_upper;

   function Swig_string_title
     (s    : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_string_title (System.Address (getCPtr (s)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_string_title;

   procedure Swig_init is
   begin

      swigg_c_import.Swig_init;
   end Swig_init;

   procedure Swig_warn
     (filename : in Interfaces.C.Strings.chars_ptr;
      line     : in Integer;
      msg      : in Interfaces.C.Strings.chars_ptr)
   is
   begin

      swigg_c_import.Swig_warn
        (Interfaces.C.Strings.chars_ptr (filename),
         Interfaces.C.int (line),
         Interfaces.C.Strings.chars_ptr (msg));
   end Swig_warn;

   function Swig_value_wrapper_mode (mode : in Integer) return Integer is
   begin

      return Integer (swigg_c_import.Swig_value_wrapper_mode
                         (Interfaces.C.int (mode)));

   end Swig_value_wrapper_mode;

   procedure Swig_warning
     (num      : in Integer;
      filename : in swig_p_DOH.Item'Class;
      line     : in Integer;
      fmt      : in Interfaces.C.Strings.chars_ptr)
   is
   begin

      swigg_c_import.Swig_warning
        (Interfaces.C.int (num),
         System.Address (getCPtr (filename)),
         Interfaces.C.int (line),
         Interfaces.C.Strings.chars_ptr (fmt));
   end Swig_warning;

   procedure Swig_error_file
     (filename : in swig_p_DOH.Item'Class;
      line     : in Integer;
      fmt      : in Interfaces.C.Strings.chars_ptr)
   is
   begin

      swigg_c_import.Swig_error_file
        (System.Address (getCPtr (filename)),
         Interfaces.C.int (line),
         Interfaces.C.Strings.chars_ptr (fmt));
   end Swig_error_file;

   function Swig_error_count return Integer is
   begin

      return Integer (swigg_c_import.Swig_error_count);

   end Swig_error_count;

   procedure Swig_error_silent (s : in Integer) is
   begin

      swigg_c_import.Swig_error_silent (Interfaces.C.int (s));
   end Swig_error_silent;

   procedure Swig_warnfilter
     (wlist : in swig_p_DOH.Item'Class;
      val   : in Integer)
   is
   begin

      swigg_c_import.Swig_warnfilter
        (System.Address (getCPtr (wlist)),
         Interfaces.C.int (val));
   end Swig_warnfilter;

   procedure Swig_warnall is
   begin

      swigg_c_import.Swig_warnall;
   end Swig_warnall;

   function Swig_warn_count return Integer is
   begin

      return Integer (swigg_c_import.Swig_warn_count);

   end Swig_warn_count;

   procedure Swig_error_msg_format (format : in ErrorMessageFormat.Item) is
   begin

      swigg_c_import.Swig_error_msg_format
        (Interfaces.C.int (Standard.ErrorMessageFormat.to_c_Int (format)));
   end Swig_error_msg_format;

   function Swig_cparm_name
     (p    : in swig_p_DOH.Item'Class;
      i    : in Integer)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_cparm_name
              (System.Address (getCPtr (p)),
               Interfaces.C.int (i));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_cparm_name;

   function Swig_wrapped_var_type
     (t       : in swig_p_DOH.Item'Class;
      varcref : in Integer)
      return    swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_wrapped_var_type
              (System.Address (getCPtr (t)),
               Interfaces.C.int (varcref));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_wrapped_var_type;

   function Swig_cargs
     (w    : in Wrapper.Item'Class;
      l    : in swig_p_DOH.Item'Class)
      return Integer
   is
   begin

      return Integer (swigg_c_import.Swig_cargs
                         (System.Address (getCPtr (w)),
                          System.Address (getCPtr (l))));

   end Swig_cargs;

   function Swig_cresult
     (t    : in swig_p_DOH.Item'Class;
      name : in swig_p_DOH.Item'Class;
      decl : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_cresult
              (System.Address (getCPtr (t)),
               System.Address (getCPtr (name)),
               System.Address (getCPtr (decl)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_cresult;

   function Swig_cfunction_call
     (name  : in swig_p_DOH.Item'Class;
      parms : in swig_p_DOH.Item'Class)
      return  swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_cfunction_call
              (System.Address (getCPtr (name)),
               System.Address (getCPtr (parms)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_cfunction_call;

   function Swig_cconstructor_call
     (name : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_cconstructor_call
              (System.Address (getCPtr (name)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_cconstructor_call;

   function Swig_cppconstructor_call
     (name  : in swig_p_DOH.Item'Class;
      parms : in swig_p_DOH.Item'Class)
      return  swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_cppconstructor_call
              (System.Address (getCPtr (name)),
               System.Address (getCPtr (parms)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_cppconstructor_call;

   function Swig_unref_call
     (n    : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_unref_call (System.Address (getCPtr (n)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_unref_call;

   function Swig_ref_call
     (n     : in swig_p_DOH.Item'Class;
      lname : in swig_p_DOH.Item'Class)
      return  swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_ref_call
              (System.Address (getCPtr (n)),
               System.Address (getCPtr (lname)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_ref_call;

   function Swig_cdestructor_call
     (n    : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_cdestructor_call
              (System.Address (getCPtr (n)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_cdestructor_call;

   function Swig_cppdestructor_call
     (n    : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_cppdestructor_call
              (System.Address (getCPtr (n)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_cppdestructor_call;

   function Swig_cmemberset_call
     (name     : in swig_p_DOH.Item'Class;
      type_arg : in swig_p_DOH.Item'Class;
      self     : in swig_p_DOH.Item'Class;
      varcref  : in Integer)
      return     swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_cmemberset_call
              (System.Address (getCPtr (name)),
               System.Address (getCPtr (type_arg)),
               System.Address (getCPtr (self)),
               Interfaces.C.int (varcref));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_cmemberset_call;

   function Swig_cmemberget_call
     (name    : in swig_p_DOH.Item'Class;
      t       : in swig_p_DOH.Item'Class;
      self    : in swig_p_DOH.Item'Class;
      varcref : in Integer)
      return    swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_cmemberget_call
              (System.Address (getCPtr (name)),
               System.Address (getCPtr (t)),
               System.Address (getCPtr (self)),
               Interfaces.C.int (varcref));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_cmemberget_call;

   function Swig_add_extension_code
     (n             : in swig_p_DOH.Item'Class;
      function_name : in swig_p_DOH.Item'Class;
      parms         : in swig_p_DOH.Item'Class;
      return_type   : in swig_p_DOH.Item'Class;
      code          : in swig_p_DOH.Item'Class;
      cplusplus     : in Integer;
      self          : in swig_p_DOH.Item'Class)
      return          Integer
   is
   begin

      return Integer (swigg_c_import.Swig_add_extension_code
                         (System.Address (getCPtr (n)),
                          System.Address (getCPtr (function_name)),
                          System.Address (getCPtr (parms)),
                          System.Address (getCPtr (return_type)),
                          System.Address (getCPtr (code)),
                          Interfaces.C.int (cplusplus),
                          System.Address (getCPtr (self))));

   end Swig_add_extension_code;

   function Swig_MethodToFunction
     (n             : in swig_p_DOH.Item'Class;
      classname     : in swig_p_DOH.Item'Class;
      flags         : in Integer;
      director_type : in swig_p_DOH.Item'Class;
      is_director   : in Integer)
      return          Integer
   is
   begin

      return Integer (swigg_c_import.Swig_MethodToFunction
                         (System.Address (getCPtr (n)),
                          System.Address (getCPtr (classname)),
                          Interfaces.C.int (flags),
                          System.Address (getCPtr (director_type)),
                          Interfaces.C.int (is_director)));

   end Swig_MethodToFunction;

   function Swig_ConstructorToFunction
     (n               : in swig_p_DOH.Item'Class;
      classname       : in swig_p_DOH.Item'Class;
      none_comparison : in swig_p_DOH.Item'Class;
      director_ctor   : in swig_p_DOH.Item'Class;
      cplus           : in Integer;
      flags           : in Integer)
      return            Integer
   is
   begin

      return Integer (swigg_c_import.Swig_ConstructorToFunction
                         (System.Address (getCPtr (n)),
                          System.Address (getCPtr (classname)),
                          System.Address (getCPtr (none_comparison)),
                          System.Address (getCPtr (director_ctor)),
                          Interfaces.C.int (cplus),
                          Interfaces.C.int (flags)));

   end Swig_ConstructorToFunction;

   function Swig_DestructorToFunction
     (n         : in swig_p_DOH.Item'Class;
      classname : in swig_p_DOH.Item'Class;
      cplus     : in Integer;
      flags     : in Integer)
      return      Integer
   is
   begin

      return Integer (swigg_c_import.Swig_DestructorToFunction
                         (System.Address (getCPtr (n)),
                          System.Address (getCPtr (classname)),
                          Interfaces.C.int (cplus),
                          Interfaces.C.int (flags)));

   end Swig_DestructorToFunction;

   function Swig_MembersetToFunction
     (n         : in swig_p_DOH.Item'Class;
      classname : in swig_p_DOH.Item'Class;
      flags     : in Integer)
      return      Integer
   is
   begin

      return Integer (swigg_c_import.Swig_MembersetToFunction
                         (System.Address (getCPtr (n)),
                          System.Address (getCPtr (classname)),
                          Interfaces.C.int (flags)));

   end Swig_MembersetToFunction;

   function Swig_MembergetToFunction
     (n         : in swig_p_DOH.Item'Class;
      classname : in swig_p_DOH.Item'Class;
      flags     : in Integer)
      return      Integer
   is
   begin

      return Integer (swigg_c_import.Swig_MembergetToFunction
                         (System.Address (getCPtr (n)),
                          System.Address (getCPtr (classname)),
                          Interfaces.C.int (flags)));

   end Swig_MembergetToFunction;

   function Swig_VargetToFunction
     (n     : in swig_p_DOH.Item'Class;
      flags : in Integer)
      return  Integer
   is
   begin

      return Integer (swigg_c_import.Swig_VargetToFunction
                         (System.Address (getCPtr (n)),
                          Interfaces.C.int (flags)));

   end Swig_VargetToFunction;

   function Swig_VarsetToFunction
     (n     : in swig_p_DOH.Item'Class;
      flags : in Integer)
      return  Integer
   is
   begin

      return Integer (swigg_c_import.Swig_VarsetToFunction
                         (System.Address (getCPtr (n)),
                          Interfaces.C.int (flags)));

   end Swig_VarsetToFunction;

   function Swig_methodclass
     (n    : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_methodclass (System.Address (getCPtr (n)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_methodclass;

   function Swig_directorclass
     (n    : in swig_p_DOH.Item'Class)
      return Integer
   is
   begin

      return Integer (swigg_c_import.Swig_directorclass
                         (System.Address (getCPtr (n))));

   end Swig_directorclass;

   function Swig_directormap
     (n        : in swig_p_DOH.Item'Class;
      type_arg : in swig_p_DOH.Item'Class)
      return     swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_directormap
              (System.Address (getCPtr (n)),
               System.Address (getCPtr (type_arg)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_directormap;

   procedure Swig_typemap_init is
   begin

      swigg_c_import.Swig_typemap_init;
   end Swig_typemap_init;

   procedure Swig_typemap_register
     (op      : in swig_p_DOH.Item'Class;
      pattern : in swig_p_DOH.Item'Class;
      code    : in swig_p_DOH.Item'Class;
      locals  : in swig_p_DOH.Item'Class;
      kwargs  : in swig_p_DOH.Item'Class)
   is
   begin

      swigg_c_import.Swig_typemap_register
        (System.Address (getCPtr (op)),
         System.Address (getCPtr (pattern)),
         System.Address (getCPtr (code)),
         System.Address (getCPtr (locals)),
         System.Address (getCPtr (kwargs)));
   end Swig_typemap_register;

   function Swig_typemap_copy
     (op         : in swig_p_DOH.Item'Class;
      srcpattern : in swig_p_DOH.Item'Class;
      pattern    : in swig_p_DOH.Item'Class)
      return       Integer
   is
   begin

      return Integer (swigg_c_import.Swig_typemap_copy
                         (System.Address (getCPtr (op)),
                          System.Address (getCPtr (srcpattern)),
                          System.Address (getCPtr (pattern))));

   end Swig_typemap_copy;

   procedure Swig_typemap_clear
     (op      : in swig_p_DOH.Item'Class;
      pattern : in swig_p_DOH.Item'Class)
   is
   begin

      swigg_c_import.Swig_typemap_clear
        (System.Address (getCPtr (op)),
         System.Address (getCPtr (pattern)));
   end Swig_typemap_clear;

   function Swig_typemap_apply
     (srcpat  : in swig_p_DOH.Item'Class;
      destpat : in swig_p_DOH.Item'Class)
      return    Integer
   is
   begin

      return Integer (swigg_c_import.Swig_typemap_apply
                         (System.Address (getCPtr (srcpat)),
                          System.Address (getCPtr (destpat))));

   end Swig_typemap_apply;

   procedure Swig_typemap_clear_apply (pattern : in swig_p_DOH.Item'Class) is
   begin

      swigg_c_import.Swig_typemap_clear_apply
        (System.Address (getCPtr (pattern)));
   end Swig_typemap_clear_apply;

   procedure Swig_typemap_debug is
   begin

      swigg_c_import.Swig_typemap_debug;
   end Swig_typemap_debug;

   function Swig_typemap_search
     (op        : in swig_p_DOH.Item'Class;
      type_arg  : in swig_p_DOH.Item'Class;
      pname     : in swig_p_DOH.Item'Class;
      matchtype : in swig_p_p_DOH.Item'Class)
      return      swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_typemap_search
              (System.Address (getCPtr (op)),
               System.Address (getCPtr (type_arg)),
               System.Address (getCPtr (pname)),
               System.Address (getCPtr (matchtype)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_typemap_search;

   function Swig_typemap_search_multi
     (op     : in swig_p_DOH.Item'Class;
      parms  : in swig_p_DOH.Item'Class;
      nmatch : in Swig.Pointers.int_Pointer)
      return   swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_typemap_search_multi
              (System.Address (getCPtr (op)),
               System.Address (getCPtr (parms)),
               Swig.Pointers.int_Pointer (nmatch));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_typemap_search_multi;

   function Swig_typemap_lookup
     (op    : in swig_p_DOH.Item'Class;
      n     : in swig_p_DOH.Item'Class;
      lname : in swig_p_DOH.Item'Class;
      f     : in Wrapper.Item'Class)
      return  swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_typemap_lookup
              (System.Address (getCPtr (op)),
               System.Address (getCPtr (n)),
               System.Address (getCPtr (lname)),
               System.Address (getCPtr (f)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_typemap_lookup;

   function Swig_typemap_lookup_out
     (op         : in swig_p_DOH.Item'Class;
      n          : in swig_p_DOH.Item'Class;
      lname      : in swig_p_DOH.Item'Class;
      f          : in Wrapper.Item'Class;
      actioncode : in swig_p_DOH.Item'Class)
      return       swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_typemap_lookup_out
              (System.Address (getCPtr (op)),
               System.Address (getCPtr (n)),
               System.Address (getCPtr (lname)),
               System.Address (getCPtr (f)),
               System.Address (getCPtr (actioncode)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_typemap_lookup_out;

   procedure Swig_typemap_attach_kwargs
     (tm : in swig_p_DOH.Item'Class;
      op : in swig_p_DOH.Item'Class;
      p  : in swig_p_DOH.Item'Class)
   is
   begin

      swigg_c_import.Swig_typemap_attach_kwargs
        (System.Address (getCPtr (tm)),
         System.Address (getCPtr (op)),
         System.Address (getCPtr (p)));
   end Swig_typemap_attach_kwargs;

   procedure Swig_typemap_new_scope is
   begin

      swigg_c_import.Swig_typemap_new_scope;
   end Swig_typemap_new_scope;

   function Swig_typemap_pop_scope return  swig_p_DOH.Item'Class is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_typemap_pop_scope;
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_typemap_pop_scope;

   procedure Swig_typemap_attach_parms
     (op    : in swig_p_DOH.Item'Class;
      parms : in swig_p_DOH.Item'Class;
      f     : in Wrapper.Item'Class)
   is
   begin

      swigg_c_import.Swig_typemap_attach_parms
        (System.Address (getCPtr (op)),
         System.Address (getCPtr (parms)),
         System.Address (getCPtr (f)));
   end Swig_typemap_attach_parms;

   procedure Swig_fragment_register (fragment : in swig_p_DOH.Item'Class) is
   begin

      swigg_c_import.Swig_fragment_register
        (System.Address (getCPtr (fragment)));
   end Swig_fragment_register;

   procedure Swig_fragment_emit (name : in swig_p_DOH.Item'Class) is
   begin

      swigg_c_import.Swig_fragment_emit (System.Address (getCPtr (name)));
   end Swig_fragment_emit;

   function Swig_director_mode return Integer is
   begin

      return Integer (swigg_c_import.Swig_director_mode);

   end Swig_director_mode;

   function Swig_director_protected_mode return Integer is
   begin

      return Integer (swigg_c_import.Swig_director_protected_mode);

   end Swig_director_protected_mode;

   function Swig_all_protected_mode return Integer is
   begin

      return Integer (swigg_c_import.Swig_all_protected_mode);

   end Swig_all_protected_mode;

   procedure Wrapper_director_mode_set (arg0 : in Integer) is
   begin

      swigg_c_import.Wrapper_director_mode_set (Interfaces.C.int (arg0));
   end Wrapper_director_mode_set;

   procedure Wrapper_director_protected_mode_set (arg0 : in Integer) is
   begin

      swigg_c_import.Wrapper_director_protected_mode_set
        (Interfaces.C.int (arg0));
   end Wrapper_director_protected_mode_set;

   procedure Wrapper_all_protected_mode_set (arg0 : in Integer) is
   begin

      swigg_c_import.Wrapper_all_protected_mode_set (Interfaces.C.int (arg0));
   end Wrapper_all_protected_mode_set;

   procedure SwigType_template_init is
   begin

      swigg_c_import.SwigType_template_init;
   end SwigType_template_init;

   function Preprocessor_expr
     (s     : in swig_p_DOH.Item'Class;
      error : in Swig.Pointers.int_Pointer)
      return  Integer
   is
   begin

      return Integer (swigg_c_import.Preprocessor_expr
                         (System.Address (getCPtr (s)),
                          Swig.Pointers.int_Pointer (error)));

   end Preprocessor_expr;

   function Preprocessor_expr_error return  Interfaces.C.Strings.chars_ptr is
   begin

      return swigg_c_import.Preprocessor_expr_error;

      --  exception
      --   when  interfaces.c.strings.Dereference_error =>
      --     return "";

   end Preprocessor_expr_error;

   function Preprocessor_define
     (str       : in swig_p_DOH.Item'Class;
      swigmacro : in Integer)
      return      swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Preprocessor_define
              (System.Address (getCPtr (str)),
               Interfaces.C.int (swigmacro));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Preprocessor_define;

   procedure Preprocessor_undef (name : in swig_p_DOH.Item'Class) is
   begin

      swigg_c_import.Preprocessor_undef (System.Address (getCPtr (name)));
   end Preprocessor_undef;

   procedure Preprocessor_init is
   begin

      swigg_c_import.Preprocessor_init;
   end Preprocessor_init;

   procedure Preprocessor_delete is
   begin

      swigg_c_import.Preprocessor_delete;
   end Preprocessor_delete;

   function Preprocessor_parse
     (s    : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Preprocessor_parse (System.Address (getCPtr (s)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Preprocessor_parse;

   procedure Preprocessor_include_all (arg0 : in Integer) is
   begin

      swigg_c_import.Preprocessor_include_all (Interfaces.C.int (arg0));
   end Preprocessor_include_all;

   procedure Preprocessor_import_all (arg0 : in Integer) is
   begin

      swigg_c_import.Preprocessor_import_all (Interfaces.C.int (arg0));
   end Preprocessor_import_all;

   procedure Preprocessor_ignore_missing (arg0 : in Integer) is
   begin

      swigg_c_import.Preprocessor_ignore_missing (Interfaces.C.int (arg0));
   end Preprocessor_ignore_missing;

   procedure Preprocessor_error_as_warning (arg0 : in Integer) is
   begin

      swigg_c_import.Preprocessor_error_as_warning (Interfaces.C.int (arg0));
   end Preprocessor_error_as_warning;

   function Preprocessor_depend return  swig_p_DOH.Item'Class is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Preprocessor_depend;
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Preprocessor_depend;

   procedure Preprocessor_expr_init is
   begin

      swigg_c_import.Preprocessor_expr_init;
   end Preprocessor_expr_init;

   procedure Preprocessor_expr_delete is
   begin

      swigg_c_import.Preprocessor_expr_delete;
   end Preprocessor_expr_delete;

   function checkAttribute
     (obj   : in swig_p_DOH.Item'Class;
      name  : in swig_p_DOH.Item'Class;
      value : in swig_p_DOH.Item'Class)
      return  Integer
   is
   begin

      return Integer (swigg_c_import.checkAttribute
                         (System.Address (getCPtr (obj)),
                          System.Address (getCPtr (name)),
                          System.Address (getCPtr (value))));

   end checkAttribute;

   procedure appendChild
     (node  : in swig_p_DOH.Item'Class;
      child : in swig_p_DOH.Item'Class)
   is
   begin

      swigg_c_import.appendChild
        (System.Address (getCPtr (node)),
         System.Address (getCPtr (child)));
   end appendChild;

   procedure prependChild
     (node  : in swig_p_DOH.Item'Class;
      child : in swig_p_DOH.Item'Class)
   is
   begin

      swigg_c_import.prependChild
        (System.Address (getCPtr (node)),
         System.Address (getCPtr (child)));
   end prependChild;

   procedure removeNode (node : in swig_p_DOH.Item'Class) is
   begin

      swigg_c_import.removeNode (System.Address (getCPtr (node)));
   end removeNode;

   function copyNode
     (node : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.copyNode (System.Address (getCPtr (node)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end copyNode;

   procedure Swig_require
     (ns   : in Interfaces.C.Strings.chars_ptr;
      node : in swig_p_DOH.Item'Class)
   is
   begin

      swigg_c_import.Swig_require
        (Interfaces.C.Strings.chars_ptr (ns),
         System.Address (getCPtr (node)));
   end Swig_require;

   procedure Swig_save
     (ns   : in Interfaces.C.Strings.chars_ptr;
      node : in swig_p_DOH.Item'Class)
   is
   begin

      swigg_c_import.Swig_save
        (Interfaces.C.Strings.chars_ptr (ns),
         System.Address (getCPtr (node)));
   end Swig_save;

   procedure Swig_restore (node : in swig_p_DOH.Item'Class) is
   begin

      swigg_c_import.Swig_restore (System.Address (getCPtr (node)));
   end Swig_restore;

   procedure Swig_print_tags
     (obj  : in swig_p_DOH.Item'Class;
      root : in swig_p_DOH.Item'Class)
   is
   begin

      swigg_c_import.Swig_print_tags
        (System.Address (getCPtr (obj)),
         System.Address (getCPtr (root)));
   end Swig_print_tags;

   procedure Swig_print_tree (obj : in swig_p_DOH.Item'Class) is
   begin

      swigg_c_import.Swig_print_tree (System.Address (getCPtr (obj)));
   end Swig_print_tree;

   procedure Swig_print_node (obj : in swig_p_DOH.Item'Class) is
   begin

      swigg_c_import.Swig_print_node (System.Address (getCPtr (obj)));
   end Swig_print_node;

   function NewWrapper return  Wrapper.Item'Class is
   begin

      declare
         cPtr       : constant System.Address     :=
           swigg_c_import.NewWrapper;
         the_Result : constant Wrapper.Item'Class :=
           Wrapper.defined (cPtr, False);
      begin

         return the_Result;
      end;

   end NewWrapper;

   procedure DelWrapper (w : in Wrapper.Item'Class) is
   begin

      swigg_c_import.DelWrapper (System.Address (getCPtr (w)));
   end DelWrapper;

   procedure Wrapper_compact_print_mode_set (flag : in Integer) is
   begin

      swigg_c_import.Wrapper_compact_print_mode_set (Interfaces.C.int (flag));
   end Wrapper_compact_print_mode_set;

   procedure Wrapper_pretty_print
     (str : in swig_p_DOH.Item'Class;
      f   : in swig_p_DOH.Item'Class)
   is
   begin

      swigg_c_import.Wrapper_pretty_print
        (System.Address (getCPtr (str)),
         System.Address (getCPtr (f)));
   end Wrapper_pretty_print;

   procedure Wrapper_compact_print
     (str : in swig_p_DOH.Item'Class;
      f   : in swig_p_DOH.Item'Class)
   is
   begin

      swigg_c_import.Wrapper_compact_print
        (System.Address (getCPtr (str)),
         System.Address (getCPtr (f)));
   end Wrapper_compact_print;

   procedure Wrapper_print
     (w : in Wrapper.Item'Class;
      f : in swig_p_DOH.Item'Class)
   is
   begin

      swigg_c_import.Wrapper_print
        (System.Address (getCPtr (w)),
         System.Address (getCPtr (f)));
   end Wrapper_print;

   function Wrapper_add_local
     (w    : in Wrapper.Item'Class;
      name : in swig_p_DOH.Item'Class;
      decl : in swig_p_DOH.Item'Class)
      return Integer
   is
   begin

      return Integer (swigg_c_import.Wrapper_add_local
                         (System.Address (getCPtr (w)),
                          System.Address (getCPtr (name)),
                          System.Address (getCPtr (decl))));

   end Wrapper_add_local;

   function Wrapper_add_localv
     (w    : in Wrapper.Item'Class;
      name : in swig_p_DOH.Item'Class)
      return Integer
   is
   begin

      return Integer (swigg_c_import.Wrapper_add_localv
                         (System.Address (getCPtr (w)),
                          System.Address (getCPtr (name))));

   end Wrapper_add_localv;

   function Wrapper_check_local
     (w    : in Wrapper.Item'Class;
      name : in swig_p_DOH.Item'Class)
      return Integer
   is
   begin

      return Integer (swigg_c_import.Wrapper_check_local
                         (System.Address (getCPtr (w)),
                          System.Address (getCPtr (name))));

   end Wrapper_check_local;

   function Wrapper_new_local
     (w    : in Wrapper.Item'Class;
      name : in swig_p_DOH.Item'Class;
      decl : in swig_p_DOH.Item'Class)
      return Interfaces.C.Strings.chars_ptr
   is
   begin

      return swigg_c_import.Wrapper_new_local
               (System.Address (getCPtr (w)),
                System.Address (getCPtr (name)),
                System.Address (getCPtr (decl)));

      --  exception
      --   when  interfaces.c.strings.Dereference_error =>
      --     return "";

   end Wrapper_new_local;

   function Wrapper_new_localv
     (w    : in Wrapper.Item'Class;
      name : in swig_p_DOH.Item'Class)
      return Interfaces.C.Strings.chars_ptr
   is
   begin

      return swigg_c_import.Wrapper_new_localv
               (System.Address (getCPtr (w)),
                System.Address (getCPtr (name)));

      --  exception
      --   when  interfaces.c.strings.Dereference_error =>
      --     return "";

   end Wrapper_new_localv;

   procedure set_input_file
     (input_file : in Interfaces.C.Strings.chars_ptr)
   is
   begin

      swigg_c_import.set_input_file
        (Interfaces.C.Strings.chars_ptr (input_file));
   end set_input_file;

   function get_input_file return  Interfaces.C.Strings.chars_ptr is
   begin

      return swigg_c_import.get_input_file;

      --  exception
      --   when  interfaces.c.strings.Dereference_error =>
      --     return "";

   end get_input_file;

   procedure set_line_number (line_number : in Integer) is
   begin

      swigg_c_import.set_line_number (Interfaces.C.int (line_number));
   end set_line_number;

   function get_line_number return Integer is
   begin

      return Integer (swigg_c_import.get_line_number);

   end get_line_number;

   procedure set_CPlusPlus (CPlusPlus : in Integer) is
   begin

      swigg_c_import.set_CPlusPlus (Interfaces.C.int (CPlusPlus));
   end set_CPlusPlus;

   function get_CPlusPlus return Integer is
   begin

      return Integer (swigg_c_import.get_CPlusPlus);

   end get_CPlusPlus;

   procedure set_Extend (Extend : in Integer) is
   begin

      swigg_c_import.set_Extend (Interfaces.C.int (Extend));
   end set_Extend;

   function get_Extend return Integer is
   begin

      return Integer (swigg_c_import.get_Extend);

   end get_Extend;

   procedure set_Verbose (Verbose : in Integer) is
   begin

      swigg_c_import.set_Verbose (Interfaces.C.int (Verbose));
   end set_Verbose;

   function get_Verbose return Integer is
   begin

      return Integer (swigg_c_import.get_Verbose);

   end get_Verbose;

   procedure set_IsVirtual (IsVirtual : in Integer) is
   begin

      swigg_c_import.set_IsVirtual (Interfaces.C.int (IsVirtual));
   end set_IsVirtual;

   function get_IsVirtual return Integer is
   begin

      return Integer (swigg_c_import.get_IsVirtual);

   end get_IsVirtual;

   procedure set_ImportMode (ImportMode : in Integer) is
   begin

      swigg_c_import.set_ImportMode (Interfaces.C.int (ImportMode));
   end set_ImportMode;

   function get_ImportMode return Integer is
   begin

      return Integer (swigg_c_import.get_ImportMode);

   end get_ImportMode;

   procedure set_NoExcept (NoExcept : in Integer) is
   begin

      swigg_c_import.set_NoExcept (Interfaces.C.int (NoExcept));
   end set_NoExcept;

   function get_NoExcept return Integer is
   begin

      return Integer (swigg_c_import.get_NoExcept);

   end get_NoExcept;

   procedure set_Abstract (Abstract_arg : in Integer) is
   begin

      swigg_c_import.set_Abstract (Interfaces.C.int (Abstract_arg));
   end set_Abstract;

   function get_Abstract return Integer is
   begin

      return Integer (swigg_c_import.get_Abstract);

   end get_Abstract;

   procedure set_SmartPointer (SmartPointer : in Integer) is
   begin

      swigg_c_import.set_SmartPointer (Interfaces.C.int (SmartPointer));
   end set_SmartPointer;

   function get_SmartPointer return Integer is
   begin

      return Integer (swigg_c_import.get_SmartPointer);

   end get_SmartPointer;

   procedure set_SwigRuntime (SwigRuntime : in Integer) is
   begin

      swigg_c_import.set_SwigRuntime (Interfaces.C.int (SwigRuntime));
   end set_SwigRuntime;

   function get_SwigRuntime return Integer is
   begin

      return Integer (swigg_c_import.get_SwigRuntime);

   end get_SwigRuntime;

   procedure set_argv_template_string
     (argv_template_string : in swig_p_DOH.Item'Class)
   is
   begin

      swigg_c_import.set_argv_template_string
        (System.Address (getCPtr (argv_template_string)));
   end set_argv_template_string;

   function get_argv_template_string return  swig_p_DOH.Item'Class is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.get_argv_template_string;
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end get_argv_template_string;

   procedure set_argc_template_string
     (argc_template_string : in swig_p_DOH.Item'Class)
   is
   begin

      swigg_c_import.set_argc_template_string
        (System.Address (getCPtr (argc_template_string)));
   end set_argc_template_string;

   function get_argc_template_string return  swig_p_DOH.Item'Class is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.get_argc_template_string;
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end get_argc_template_string;

   function Lang_CurrentClass return  swig_p_DOH.Item'Class is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Lang_CurrentClass;
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Lang_CurrentClass;

   function Lang_ClassName return  swig_p_DOH.Item'Class is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Lang_ClassName;
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Lang_ClassName;

   function Lang_AddExtern return Integer is
   begin

      return Integer (swigg_c_import.Lang_AddExtern);

   end Lang_AddExtern;

   function Lang_ForceExtern return Integer is
   begin

      return Integer (swigg_c_import.Lang_ForceExtern);

   end Lang_ForceExtern;

   function Lang_first_nontemplate
     (n    : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Lang_first_nontemplate
              (System.Address (getCPtr (n)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Lang_first_nontemplate;

   function SWIG_main
     (arg0 : in Integer;
      arg1 : in swig_p_p_char.Item'Class;
      arg2 : in Language.Item'Class)
      return Integer
   is
   begin

      return Integer (swigg_c_import.SWIG_main
                         (Interfaces.C.int (arg0),
                          System.Address (getCPtr (arg1)),
                          System.Address (getCPtr (arg2))));

   end SWIG_main;

   procedure emit_parameter_variables
     (l : in swig_p_DOH.Item'Class;
      f : in Wrapper.Item'Class)
   is
   begin

      swigg_c_import.emit_parameter_variables
        (System.Address (getCPtr (l)),
         System.Address (getCPtr (f)));
   end emit_parameter_variables;

   procedure emit_return_variable
     (n  : in swig_p_DOH.Item'Class;
      rt : in swig_p_DOH.Item'Class;
      f  : in Wrapper.Item'Class)
   is
   begin

      swigg_c_import.emit_return_variable
        (System.Address (getCPtr (n)),
         System.Address (getCPtr (rt)),
         System.Address (getCPtr (f)));
   end emit_return_variable;

   procedure SWIG_exit (arg0 : in Integer) is
   begin

      swigg_c_import.SWIG_exit (Interfaces.C.int (arg0));
   end SWIG_exit;

   procedure SWIG_config_file (arg0 : in swig_p_DOH.Item'Class) is
   begin

      swigg_c_import.SWIG_config_file (System.Address (getCPtr (arg0)));
   end SWIG_config_file;

   function SWIG_output_directory return  swig_p_DOH.Item'Class is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.SWIG_output_directory;
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end SWIG_output_directory;

   procedure SWIG_config_cppext (ext : in Interfaces.C.Strings.chars_ptr) is
   begin

      swigg_c_import.SWIG_config_cppext
        (Interfaces.C.Strings.chars_ptr (ext));
   end SWIG_config_cppext;

   procedure SWIG_library_directory
     (arg0 : in Interfaces.C.Strings.chars_ptr)
   is
   begin

      swigg_c_import.SWIG_library_directory
        (Interfaces.C.Strings.chars_ptr (arg0));
   end SWIG_library_directory;

   function emit_num_arguments
     (arg0 : in swig_p_DOH.Item'Class)
      return Integer
   is
   begin

      return Integer (swigg_c_import.emit_num_arguments
                         (System.Address (getCPtr (arg0))));

   end emit_num_arguments;

   function emit_num_required
     (arg0 : in swig_p_DOH.Item'Class)
      return Integer
   is
   begin

      return Integer (swigg_c_import.emit_num_required
                         (System.Address (getCPtr (arg0))));

   end emit_num_required;

   function emit_isvarargs (arg0 : in swig_p_DOH.Item'Class) return Integer is
   begin

      return Integer (swigg_c_import.emit_isvarargs
                         (System.Address (getCPtr (arg0))));

   end emit_isvarargs;

   procedure emit_attach_parmmaps
     (arg0 : in swig_p_DOH.Item'Class;
      f    : in Wrapper.Item'Class)
   is
   begin

      swigg_c_import.emit_attach_parmmaps
        (System.Address (getCPtr (arg0)),
         System.Address (getCPtr (f)));
   end emit_attach_parmmaps;

   procedure emit_mark_varargs (l : in swig_p_DOH.Item'Class) is
   begin

      swigg_c_import.emit_mark_varargs (System.Address (getCPtr (l)));
   end emit_mark_varargs;

   function emit_action
     (n    : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.emit_action (System.Address (getCPtr (n)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end emit_action;

   function emit_action_code
     (n           : in swig_p_DOH.Item'Class;
      wrappercode : in swig_p_DOH.Item'Class;
      action      : in swig_p_DOH.Item'Class)
      return        Integer
   is
   begin

      return Integer (swigg_c_import.emit_action_code
                         (System.Address (getCPtr (n)),
                          System.Address (getCPtr (wrappercode)),
                          System.Address (getCPtr (action))));

   end emit_action_code;

   procedure Swig_overload_check (n : in swig_p_DOH.Item'Class) is
   begin

      swigg_c_import.Swig_overload_check (System.Address (getCPtr (n)));
   end Swig_overload_check;

   function Swig_overload_dispatch
     (n    : in swig_p_DOH.Item'Class;
      fmt  : in swig_p_DOH.Item'Class;
      arg2 : in Swig.Pointers.int_Pointer)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_overload_dispatch
              (System.Address (getCPtr (n)),
               System.Address (getCPtr (fmt)),
               Swig.Pointers.int_Pointer (arg2));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_overload_dispatch;

   function Swig_overload_dispatch_cast
     (n    : in swig_p_DOH.Item'Class;
      fmt  : in swig_p_DOH.Item'Class;
      arg2 : in Swig.Pointers.int_Pointer)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_overload_dispatch_cast
              (System.Address (getCPtr (n)),
               System.Address (getCPtr (fmt)),
               Swig.Pointers.int_Pointer (arg2));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_overload_dispatch_cast;

   function Swig_overload_dispatch_fast
     (n    : in swig_p_DOH.Item'Class;
      fmt  : in swig_p_DOH.Item'Class;
      arg2 : in Swig.Pointers.int_Pointer)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_overload_dispatch_fast
              (System.Address (getCPtr (n)),
               System.Address (getCPtr (fmt)),
               Swig.Pointers.int_Pointer (arg2));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_overload_dispatch_fast;

   function cplus_value_type
     (t    : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.cplus_value_type (System.Address (getCPtr (t)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end cplus_value_type;

   function Swig_csuperclass_call
     (base   : in swig_p_DOH.Item'Class;
      method : in swig_p_DOH.Item'Class;
      l      : in swig_p_DOH.Item'Class)
      return   swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_csuperclass_call
              (System.Address (getCPtr (base)),
               System.Address (getCPtr (method)),
               System.Address (getCPtr (l)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_csuperclass_call;

   function Swig_class_declaration
     (n    : in swig_p_DOH.Item'Class;
      name : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_class_declaration
              (System.Address (getCPtr (n)),
               System.Address (getCPtr (name)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_class_declaration;

   function Swig_class_name
     (n    : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_class_name (System.Address (getCPtr (n)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_class_name;

   function Swig_method_call
     (name  : in swig_p_DOH.Item'Class;
      parms : in swig_p_DOH.Item'Class)
      return  swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_method_call
              (System.Address (getCPtr (name)),
               System.Address (getCPtr (parms)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_method_call;

   function Swig_method_decl
     (rtype  : in swig_p_DOH.Item'Class;
      decl   : in swig_p_DOH.Item'Class;
      id     : in swig_p_DOH.Item'Class;
      args   : in swig_p_DOH.Item'Class;
      strip  : in Integer;
      values : in Integer)
      return   swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_method_decl
              (System.Address (getCPtr (rtype)),
               System.Address (getCPtr (decl)),
               System.Address (getCPtr (id)),
               System.Address (getCPtr (args)),
               Interfaces.C.int (strip),
               Interfaces.C.int (values));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_method_decl;

   function Swig_director_declaration
     (n    : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_director_declaration
              (System.Address (getCPtr (n)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_director_declaration;

   procedure Swig_director_emit_dynamic_cast
     (n : in swig_p_DOH.Item'Class;
      f : in Wrapper.Item'Class)
   is
   begin

      swigg_c_import.Swig_director_emit_dynamic_cast
        (System.Address (getCPtr (n)),
         System.Address (getCPtr (f)));
   end Swig_director_emit_dynamic_cast;

   procedure SWIG_typemap_lang (arg0 : in Interfaces.C.Strings.chars_ptr) is
   begin

      swigg_c_import.SWIG_typemap_lang
        (Interfaces.C.Strings.chars_ptr (arg0));
   end SWIG_typemap_lang;

   procedure Swig_register_module
     (name : in Interfaces.C.Strings.chars_ptr;
      fac  : in swig_p_f_void_ret_p_Language.Item'Class)
   is
   begin

      swigg_c_import.Swig_register_module
        (Interfaces.C.Strings.chars_ptr (name),
         System.Address (getCPtr (fac)));
   end Swig_register_module;

   function Swig_find_module
     (name : in Interfaces.C.Strings.chars_ptr)
      return swig_p_f_void_ret_p_Language.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address                          :=
           swigg_c_import.Swig_find_module
              (Interfaces.C.Strings.chars_ptr (name));
         the_Result : constant swig_p_f_void_ret_p_Language.Item'Class :=
           swig_p_f_void_ret_p_Language.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_find_module;

   function is_public (n : in swig_p_DOH.Item'Class) return Integer is
   begin

      return Integer (swigg_c_import.is_public
                         (System.Address (getCPtr (n))));

   end is_public;

   function is_private (n : in swig_p_DOH.Item'Class) return Integer is
   begin

      return Integer (swigg_c_import.is_private
                         (System.Address (getCPtr (n))));

   end is_private;

   function is_protected (n : in swig_p_DOH.Item'Class) return Integer is
   begin

      return Integer (swigg_c_import.is_protected
                         (System.Address (getCPtr (n))));

   end is_protected;

   function is_member_director
     (parentnode : in swig_p_DOH.Item'Class;
      member     : in swig_p_DOH.Item'Class)
      return       Integer
   is
   begin

      return Integer (swigg_c_import.is_member_director_SWIG_0
                         (System.Address (getCPtr (parentnode)),
                          System.Address (getCPtr (member))));

   end is_member_director;

   function is_member_director
     (member : in swig_p_DOH.Item'Class)
      return   Integer
   is
   begin

      return Integer (swigg_c_import.is_member_director_SWIG_1
                         (System.Address (getCPtr (member))));

   end is_member_director;

   function is_non_virtual_protected_access
     (n    : in swig_p_DOH.Item'Class)
      return Integer
   is
   begin

      return Integer (swigg_c_import.is_non_virtual_protected_access
                         (System.Address (getCPtr (n))));

   end is_non_virtual_protected_access;

   function use_naturalvar_mode
     (n    : in swig_p_DOH.Item'Class)
      return Integer
   is
   begin

      return Integer (swigg_c_import.use_naturalvar_mode
                         (System.Address (getCPtr (n))));

   end use_naturalvar_mode;

   procedure Wrapper_virtual_elimination_mode_set (arg0 : in Integer) is
   begin

      swigg_c_import.Wrapper_virtual_elimination_mode_set
        (Interfaces.C.int (arg0));
   end Wrapper_virtual_elimination_mode_set;

   procedure Wrapper_fast_dispatch_mode_set (arg0 : in Integer) is
   begin

      swigg_c_import.Wrapper_fast_dispatch_mode_set (Interfaces.C.int (arg0));
   end Wrapper_fast_dispatch_mode_set;

   procedure Wrapper_cast_dispatch_mode_set (arg0 : in Integer) is
   begin

      swigg_c_import.Wrapper_cast_dispatch_mode_set (Interfaces.C.int (arg0));
   end Wrapper_cast_dispatch_mode_set;

   procedure Wrapper_naturalvar_mode_set (arg0 : in Integer) is
   begin

      swigg_c_import.Wrapper_naturalvar_mode_set (Interfaces.C.int (arg0));
   end Wrapper_naturalvar_mode_set;

   procedure clean_overloaded (n : in swig_p_DOH.Item'Class) is
   begin

      swigg_c_import.clean_overloaded (System.Address (getCPtr (n)));
   end clean_overloaded;

   procedure Swig_contracts (n : in swig_p_DOH.Item'Class) is
   begin

      swigg_c_import.Swig_contracts (System.Address (getCPtr (n)));
   end Swig_contracts;

   procedure Swig_contract_mode_set (flag : in Integer) is
   begin

      swigg_c_import.Swig_contract_mode_set (Interfaces.C.int (flag));
   end Swig_contract_mode_set;

   function Swig_contract_mode_get return Integer is
   begin

      return Integer (swigg_c_import.Swig_contract_mode_get);

   end Swig_contract_mode_get;

   procedure Swig_browser (n : in swig_p_DOH.Item'Class; arg1 : in Integer) is
   begin

      swigg_c_import.Swig_browser
        (System.Address (getCPtr (n)),
         Interfaces.C.int (arg1));
   end Swig_browser;

   procedure Swig_default_allocators (n : in swig_p_DOH.Item'Class) is
   begin

      swigg_c_import.Swig_default_allocators (System.Address (getCPtr (n)));
   end Swig_default_allocators;

   procedure Swig_process_types (n : in swig_p_DOH.Item'Class) is
   begin

      swigg_c_import.Swig_process_types (System.Address (getCPtr (n)));
   end Swig_process_types;

   function Swig_add_directory
     (dirname : in swig_p_DOH.Item'Class)
      return    swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_add_directory
              (System.Address (getCPtr (dirname)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_add_directory;

   procedure Swig_push_directory (dirname : in swig_p_DOH.Item'Class) is
   begin

      swigg_c_import.Swig_push_directory
        (System.Address (getCPtr (dirname)));
   end Swig_push_directory;

   procedure Swig_pop_directory is
   begin

      swigg_c_import.Swig_pop_directory;
   end Swig_pop_directory;

   function Swig_last_file return  swig_p_DOH.Item'Class is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_last_file;
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_last_file;

   function Swig_search_path return  swig_p_DOH.Item'Class is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_search_path;
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_search_path;

   function Swig_open
     (name : in swig_p_DOH.Item'Class)
      return swig_p_FILE.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address         :=
           swigg_c_import.Swig_open (System.Address (getCPtr (name)));
         the_Result : constant swig_p_FILE.Item'Class :=
           swig_p_FILE.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_open;

   function Swig_read_file
     (f    : in swig_p_FILE.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_read_file (System.Address (getCPtr (f)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_read_file;

   function Swig_include
     (name : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_include (System.Address (getCPtr (name)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_include;

   function Swig_include_sys
     (name : in swig_p_DOH.Item'Class)
      return swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_include_sys
              (System.Address (getCPtr (name)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_include_sys;

   function Swig_insert_file
     (name    : in swig_p_DOH.Item'Class;
      outfile : in swig_p_DOH.Item'Class)
      return    Integer
   is
   begin

      return Integer (swigg_c_import.Swig_insert_file
                         (System.Address (getCPtr (name)),
                          System.Address (getCPtr (outfile))));

   end Swig_insert_file;

   procedure Swig_set_push_dir (dopush : in Integer) is
   begin

      swigg_c_import.Swig_set_push_dir (Interfaces.C.int (dopush));
   end Swig_set_push_dir;

   function Swig_get_push_dir return Integer is
   begin

      return Integer (swigg_c_import.Swig_get_push_dir);

   end Swig_get_push_dir;

   procedure Swig_register_filebyname
     (filename : in swig_p_DOH.Item'Class;
      outfile  : in swig_p_DOH.Item'Class)
   is
   begin

      swigg_c_import.Swig_register_filebyname
        (System.Address (getCPtr (filename)),
         System.Address (getCPtr (outfile)));
   end Swig_register_filebyname;

   function Swig_filebyname
     (filename : in swig_p_DOH.Item'Class)
      return     swig_p_DOH.Item'Class
   is
   begin

      declare
         cPtr       : constant System.Address        :=
           swigg_c_import.Swig_filebyname
              (System.Address (getCPtr (filename)));
         the_Result : constant swig_p_DOH.Item'Class :=
           swig_p_DOH.defined (cPtr, False);
      begin
         --$add_Reference
         return the_Result;
      end;

   end Swig_filebyname;

   function Swig_file_suffix
     (filename : in swig_p_DOH.Item'Class)
      return     Interfaces.C.Strings.chars_ptr
   is
   begin

      return swigg_c_import.Swig_file_suffix
               (System.Address (getCPtr (filename)));

      --  exception
      --   when  interfaces.c.strings.Dereference_error =>
      --     return "";

   end Swig_file_suffix;

   function Swig_file_basename
     (filename : in swig_p_DOH.Item'Class)
      return     Interfaces.C.Strings.chars_ptr
   is
   begin

      return swigg_c_import.Swig_file_basename
               (System.Address (getCPtr (filename)));

      --  exception
      --   when  interfaces.c.strings.Dereference_error =>
      --     return "";

   end Swig_file_basename;

   function Swig_file_filename
     (filename : in swig_p_DOH.Item'Class)
      return     Interfaces.C.Strings.chars_ptr
   is
   begin

      return swigg_c_import.Swig_file_filename
               (System.Address (getCPtr (filename)));

      --  exception
      --   when  interfaces.c.strings.Dereference_error =>
      --     return "";

   end Swig_file_filename;

   function Swig_file_dirname
     (filename : in swig_p_DOH.Item'Class)
      return     Interfaces.C.Strings.chars_ptr
   is
   begin

      return swigg_c_import.Swig_file_dirname
               (System.Address (getCPtr (filename)));

      --  exception
      --   when  interfaces.c.strings.Dereference_error =>
      --     return "";

   end Swig_file_dirname;

   procedure Swig_init_args
     (argc : in Integer;
      argv : in swig_p_p_char.Item'Class)
   is
   begin

      swigg_c_import.Swig_init_args
        (Interfaces.C.int (argc),
         System.Address (getCPtr (argv)));
   end Swig_init_args;

   procedure Swig_mark_arg (n : in Integer) is
   begin

      swigg_c_import.Swig_mark_arg (Interfaces.C.int (n));
   end Swig_mark_arg;

   function Swig_check_marked (n : in Integer) return Integer is
   begin

      return Integer (swigg_c_import.Swig_check_marked
                         (Interfaces.C.int (n)));

   end Swig_check_marked;

   procedure Swig_check_options (check_input : in Integer) is
   begin

      swigg_c_import.Swig_check_options (Interfaces.C.int (check_input));
   end Swig_check_options;

   procedure Swig_arg_error is
   begin

      swigg_c_import.Swig_arg_error;
   end Swig_arg_error;

   procedure dummy_procedure is
   begin
      null;
   end dummy_procedure;

end swigg_module;
