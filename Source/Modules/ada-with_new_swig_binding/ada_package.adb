--  with ada_Type.composite.a_record;
--
--  with gnat_Parameter;               use gnat_Parameter;
--  with package_Member;               use package_Member;
--  with gnat_Context;                 use gnat_Context;
--  with a_Namespace;                  use a_Namespace;
--
--  with swigg_Module;                 use swigg_Module;
--  with doh_Support;                  use doh_Support;
with ada_Utility;                 use ada_Utility;

--  with ada.strings.Maps.constants;   use ada.strings.Maps.constants;
with Ada.Characters.Handling;      use Ada.Characters.Handling;
--  with ada.text_IO;                  use ada.text_IO;


package body ada_Package
is

   use ada_subprogram.Vectors,
       ada_Package.Vectors,
       ada_variable.Vectors,
       ada_Type,
       ada_Type.composite.a_record;


   --  Forge
   --

   function new_ada_Package (Name   : in String;
                              Parent : in View  := null) return View
   is
   begin
      return new Item'(a_Kind                => Binding,
                       a_Parent              => Parent,
                       a_Name                => to_unbounded_String (Name),

                       a_is_Module           => False,
                       a_is_Import           => False,
                       a_is_Core             => False,
                       a_is_enum_Proxy       => False,
                       a_is_global_Namespace => False,
                       a_is_Unknown          => False,

                       a_Subprograms    => ada_subprogram.vectors.empty_Vector,
                       a_Variables      => ada_variable.Vectors.empty_Vector,
                       a_Types          => ada_type.vectors.empty_Vector,
                       a_cpp_class_Type => null);
   end new_ada_Package;






   --  Attributes
   --


   function Kind (Self : access Item) return a_Kind
   is
   begin
      return Self.a_Kind;
   end Kind;



   procedure Kind_is (Self : access Item;   Now : in a_Kind)
   is
   begin
      Self.a_Kind := Now;
   end Kind_is;







   function Name (Self : access Item) return unbounded_String
   is
   begin
      return Self.a_Name;
   end Name;






   function qualified_Name (Self : access Item) return unbounded_String
   is
   begin
--        log ("KKKKKKKKKKKKKKK  qualified_Name: '" & Self.Name & "'     parent: '" & Self.parent.Name & "'");

      if Self.Name = "standard" then
         return Self.Name;

      elsif Self.parent.Name = "standard" then
--           log ("KKKKKKKKKKKKKKK  qualified_Name: '" & Self.Name & "'     parent: '" & Self.parent.Name & "'");

         if        is_reserved_Word                      (Self.Name)
           or else is_an_ada_Standard_Package_Identifier (Self.Name)
         then
            return "c_" & Self.Name;     -- prevent clash
         else
            return Self.Name;
         end if;

      else
         return Self.parent.qualified_Name & "." & Self.Name;
      end if;
   end qualified_Name;





   function Parent (Self : access Item) return access Item
   is
   begin
      return Self.a_Parent;
   end Parent;




   function has_Ancestor (Self : access Item;   possible_Ancestor : access ada_Package.item'Class) return Boolean
   is
      the_Parent : ada_Package.view := Self.Parent.all'Access;
   begin
      loop
--           log (the_Parent.qualified_Name & "   " & possible_Ancestor.Name);

         if the_Parent = possible_Ancestor then
            return True;
         end if;

         exit when the_Parent.Parent = null;
         the_Parent := the_Parent.Parent.all'Access;
      end loop;

      return False;
   end has_Ancestor;





   function  is_Module (Self : access Item) return Boolean
   is
   begin
      return Self.a_is_Module;
   end is_Module;



   procedure is_Module (Self : access Item)
   is
   begin
      Self.a_is_Module := True;
   end is_Module;





   function  is_Core (Self : access Item) return Boolean
   is
   begin
      return Self.a_is_Core;
   end is_Core;



   procedure is_Core (Self : access Item)
   is
   begin
      Self.a_is_Core := True;
   end is_Core;




   procedure is_Unknown (Self : access Item)
   is
   begin
      Self.a_is_Unknown := True;
   end is_Unknown;






   procedure Name_is (Self : access Item;   Now : in String)
   is
   begin
      Self.a_Name := to_unbounded_String (Now);
   end Name_is;





   procedure add (Self           : access Item;
                  new_Subprogram : in     ada_Subprogram.view)
   is
   begin
      append (Self.a_Subprograms,  new_Subprogram);
   end add;




   procedure add (Self         : access Item;
                  new_Variable : in ada_Variable.view)
   is
   begin
      append (Self.a_Variables,  new_Variable);
   end add;



   procedure add (Self     : access Item;
                  new_Type : in     ada_Type.view)
   is
      use ada_type.Vectors;
   begin
      append (Self.a_Types, new_Type);
   end add;




   procedure rid (Self     : access Item;
                  the_Type : in     ada_Type.view)
   is
      use ada_type.Vectors;
   begin
      Self.a_Types.delete (Self.a_Types.find_Index (the_Type));
   end rid;



   procedure models_cpp_class_Type (Self      : access Item;
                                    new_Class : in     ada_Type.composite.a_record.view)   -- ada_Type.view)
   is
   begin
      Self.a_cpp_class_Type := new_Class;
   end models_cpp_class_Type;



   function Subprograms (Self : access Item) return ada_subprogram.Vector
   is
   begin
      return Self.a_Subprograms;
   end Subprograms;



   function Variables (Self : access Item) return ada_variable.Vector
   is
   begin
      return Self.a_Variables;
   end Variables;



   function Types (Self : access Item)  return ada_type.Vector
   is
   begin
      return Self.a_Types;
   end Types;



   function  is_global_Namespace        (Self : access Item) return Boolean
   is
   begin
      return Self.a_is_global_Namespace;
   end is_global_Namespace;



   procedure is_enum_Proxy (Self : access Item)
   is
   begin
      Self.a_is_enum_Proxy := True;
   end is_enum_Proxy;



   function models_a_virtual_cpp_Class (Self : access Item) return Boolean
   is
   begin
      if Self.a_cpp_class_Type = null then   return False;  end if;

      return Self.a_cpp_class_Type.total_virtual_member_function_Count > 0;
   end models_a_virtual_cpp_Class;



   function models_an_interface_Type   (Self : access Item) return Boolean
   is
   begin
      if Self.a_cpp_class_Type = null then   return False;  end if;

      return Self.a_cpp_class_Type.is_interface_Type;
   end models_an_interface_Type;



   function  cpp_class_Type (Self : access Item) return ada_Type.composite.a_record.view --                                            return ada_Type.view
   is
   begin
      if Self.a_cpp_class_Type = null then
         return null;
      else
         return Self.a_cpp_class_Type;
      end if;
   end cpp_class_Type;



   procedure is_global_Namespace (Self : access Item)
   is
   begin
      Self.a_is_global_Namespace := True;
   end is_global_Namespace;





   --  Operations
   --

   procedure verify (Self : access Item)
   is
      use ada_Type.Vectors;
   begin
      Self.a_Name := to_ada_Identifier (Self.a_Name);

      for Each in 1 .. Natural (Length (Self.a_Types)) loop      -- verify contained types
         Element (Self.a_Types,  Each).verify;                   --
      end loop;                                                  --


      declare
         Cursor : ada_subprogram.Cursor := First (Self.a_Subprograms);
      begin
         while has_Element (Cursor) loop
            Element (Cursor).verify;
            next    (Cursor);
         end loop;
      end;

   end verify;



   function type_name_needs_Standard_prefix (Self     : access Item'class;
                                             Name     : in     String;                          -- tbd: find better name for this parameter
                                             the_Type : in     ada_Type.view) return Boolean
   is
      lowcase_Name    : constant String            := to_Lower (Name);
      lowcase_Type    : constant unbounded_String  := Text_before_first_Dot (to_unbounded_String (to_Lower (to_String (the_type.declaration_package.qualified_Name))));
      name_type_Clash : constant Boolean           := lowcase_Name = lowcase_Type;
   begin
--        log ("'type_name_needs_Standard_prefix' - name: '" & lowcase_Name & "'     type: '" & lowcase_Type & "'");

      if name_type_Clash then
         return True;
      end if;


      for Each in 1 .. Natural (Length (Self.a_Variables))
      loop
         if to_Lower (to_String (Element (Self.a_Variables, Each).Name))  =  lowcase_Type then
            return True;
         end if;
      end loop;


      return False;
   end type_name_needs_Standard_prefix;



end ada_Package;
