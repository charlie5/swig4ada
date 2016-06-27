with c_Variable;                   use c_Variable;
with ada_Utility;                 use ada_Utility;
with Ada.Characters.Handling;      use Ada.Characters.Handling;


package body c_Namespace
is
   use c_Function.Vectors,
       c_nameSpace.Vectors,
       c_variable.Vectors,
       c_Type;


   --  Forge
   --

   function new_c_nameSpace (Name   : in String;
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

                       a_Subprograms    => <>,
                       a_Variables      => <>,
                       a_Types          => <>,
                       a_cpp_class_Type => null);
   end new_c_nameSpace;





   --  Attributes
   --


   function Kind (Self : access Item) return a_Kind
   is
   begin
      return self.a_Kind;
   end Kind;



   procedure Kind_is (Self : access Item;   Now : in a_Kind)
   is
   begin
      self.a_Kind := Now;
   end Kind_is;




   function Name (Self : access Item) return unbounded_String
   is
   begin
      return self.a_Name;
   end Name;





   function qualified_Name (Self : access Item) return unbounded_String
   is
   begin
      if self.Name = "std" then
         return self.Name;

      elsif self.parent.Name = "std" then

         if        is_reserved_Word                      (self.Name)
           or else is_an_ada_Standard_Package_Identifier (self.Name)
         then
            return "c_" & self.Name;     -- prevent clash
         else
            return self.Name;
         end if;

      else
         return self.parent.qualified_Name & "." & self.Name;
      end if;

--        if self.Name = "standard" then
--           return self.Name;
--
--        elsif self.parent.Name = "standard" then
--
--           if        is_reserved_Word                      (self.Name)
--             or else is_an_ada_Standard_Package_Identifier (self.Name)
--           then
--              return "c_" & self.Name;     -- prevent clash
--           else
--              return self.Name;
--           end if;
--
--        else
--           return self.parent.qualified_Name & "." & self.Name;
--        end if;
   end qualified_Name;




   function Parent (Self : access Item) return access Item
   is
   begin
      return self.a_Parent;
   end Parent;



   function has_Ancestor (Self : access Item;   possible_Ancestor : access c_nameSpace.item'Class) return Boolean
   is
      the_Parent : c_nameSpace.view := self.Parent.all'Access;
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
      return self.a_is_Module;
   end is_Module;



   procedure is_Module (Self : access Item)
   is
   begin
      self.a_is_Module := True;
   end is_Module;



   function  is_Core (Self : access Item) return Boolean
   is
   begin
      return self.a_is_Core;
   end is_Core;



   procedure is_Core (Self : access Item)
   is
   begin
      self.a_is_Core := True;
   end is_Core;



   procedure is_Unknown (Self : access Item)
   is
   begin
      self.a_is_Unknown := True;
   end is_Unknown;



   procedure Name_is (Self : access Item;   Now : in String)
   is
   begin
      self.a_Name := to_unbounded_String (Now);
   end Name_is;



   procedure add (Self           : access Item;
                  new_Subprogram : in     c_Function.view)
   is
   begin
      append (self.a_Subprograms,  new_Subprogram);
   end add;



   procedure add (Self         : access Item;
                  new_Variable : in c_Variable.view)
   is
   begin
      append (self.a_Variables,  new_Variable);
   end add;



   procedure add (Self     : access Item;
                  new_Type : in     c_Type.view)
   is
      use c_type.Vectors;
   begin
      append (self.a_Types, new_Type);
   end add;



   procedure rid (Self     : access Item;
                  the_Type : in     c_Type.view)
   is
      use c_type.Vectors;
   begin
      self.a_Types.delete (self.a_Types.find_Index (the_Type));
   end rid;



   procedure models_cpp_class_Type (Self      : access Item;
                                    new_Class : in     c_Type.view)
   is
   begin
      self.a_cpp_class_Type := new_Class;
   end models_cpp_class_Type;



   function Subprograms (Self : access Item) return c_Function.Vector
   is
   begin
      return self.a_Subprograms;
   end Subprograms;



   function Variables (Self : access Item) return c_variable.Vector
   is
   begin
      return self.a_Variables;
   end Variables;



   function Types (Self : access Item)  return c_type.Vector
   is
   begin
      return self.a_Types;
   end Types;



   function  is_global_Namespace        (Self : access Item) return Boolean
   is
   begin
      return self.a_is_global_Namespace;
   end is_global_Namespace;



   procedure is_enum_Proxy (Self : access Item)
   is
   begin
      self.a_is_enum_Proxy := True;
   end is_enum_Proxy;



   function models_a_virtual_cpp_Class (Self : access Item) return Boolean
   is
   begin
      if self.a_cpp_class_Type = null then   return False;  end if;

      return total_virtual_member_function_Count (self.a_cpp_class_Type) > 0;
   end models_a_virtual_cpp_Class;



   function models_an_interface_Type   (Self : access Item) return Boolean
   is
   begin
      if self.a_cpp_class_Type = null then   return False;  end if;

      return is_interface_Type (self.a_cpp_class_Type);
   end models_an_interface_Type;



   function  cpp_class_Type (Self : access Item) return c_Type.view
   is
   begin
      if self.a_cpp_class_Type = null then
         return null;
      else
         return self.a_cpp_class_Type;
      end if;
   end cpp_class_Type;




   procedure is_global_Namespace (Self : access Item)
   is
   begin
      self.a_is_global_Namespace := True;
   end is_global_Namespace;




   --  Operations
   --

   procedure verify (Self : access Item)
   is
      use c_Type.Vectors;
   begin
      self.a_Name := to_ada_Identifier (self.a_Name);

      for Each in 1 .. Natural (Length (self.a_Types)) loop      -- verify contained types
         Element (self.a_Types,  Each).verify;                   --
      end loop;                                                  --


      declare
         Cursor : c_function.Cursor := First (self.a_Subprograms);
      begin
         while has_Element (Cursor) loop
            Element (Cursor).verify;
            next    (Cursor);
         end loop;
      end;

   end verify;




   function type_name_needs_Standard_prefix (Self     : access Item'class;
                                             Name     : in     String;                          -- tbd: find better name for this parameter
                                             the_Type : in     c_Type.view) return Boolean
   is
      lowcase_Name    : constant String            := to_Lower (Name);
      lowcase_Type    : constant unbounded_String  := Text_before_first_Dot (to_unbounded_String (to_Lower (to_String (the_type.nameSpace.qualified_Name))));
      name_type_Clash : constant Boolean           := lowcase_Name = lowcase_Type;
   begin
--        log ("'type_name_needs_Standard_prefix' - name: '" & lowcase_Name & "'     type: '" & lowcase_Type & "'");


      if name_type_Clash then
         return True;
      end if;


      for Each in 1 .. Natural (Length (self.a_Variables)) loop

         if to_Lower (to_String (Element (self.a_Variables, Each).Name))  =  lowcase_Type then
            return True;
         end if;

      end loop;


      return False;
   end type_name_needs_Standard_prefix;


end c_Namespace;
