with
     ada_Utility,
     ada.Characters.handling;


package body c_Namespace
is
   use c_Function.Vectors,
       c_Variable,
       c_variable.Vectors,
       c_Type,
       ada_Utility,
       ada.Characters.handling;


   ---------
   --  Forge
   --
   function new_c_nameSpace (Name   : in String;
                             Parent : in View  := null) return View
   is
   begin
      return new Item'(a_Kind   => Binding,
                       a_Parent => Parent,
                       a_Name   => to_unbounded_String (Name),

                       a_is_Module     => False,
                       a_is_Import     => False,
                       a_is_Core       => False,
                       a_is_enum_Proxy => False,
                       a_is_Unknown    => False,

                       a_Subprograms     => <>,
                       a_Variables       => <>,
                       a_Types           => <>,
                       a_cpp_class_Type  => null);
   end new_c_nameSpace;



   --------------
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



   procedure Name_is (Self : access Item;   Now : in String)
   is
   begin
      Self.a_Name := to_unbounded_String (Now);
   end Name_is;


   function Name (Self : access Item) return unbounded_String
   is
   begin
      return Self.a_Name;
   end Name;


   function qualified_Name (Self : access Item) return unbounded_String
   is
   begin
      if Self.Name = "std"
      then
         return Self.Name;

      elsif Self.parent.Name = "std"
      then
         if        is_reserved_Word                      (Self.Name)
           or else is_an_ada_Standard_Package_Identifier (Self.Name)
         then
            return "c_" & Self.Name;     -- Prevent clash.
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



   function has_Ancestor (Self : access Item;   possible_Ancestor : access c_nameSpace.item'Class) return Boolean
   is
      the_Parent : c_nameSpace.view := Self.Parent.all'Access;
   begin
      loop
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



   procedure add (Self           : access Item;
                  new_Subprogram : in     c_Function.view)
   is
   begin
      append (Self.a_Subprograms, new_Subprogram);
   end add;



   procedure add (Self         : access Item;
                  new_Variable : in     c_Variable.view)
   is
   begin
      append (Self.a_Variables, new_Variable);
   end add;



   procedure add (Self     : access Item;
                  new_Type : in     c_Type.view)
   is
      use c_type.Vectors;
   begin
      append (Self.a_Types, new_Type);
   end add;



   procedure rid (Self     : access Item;
                  the_Type : in     c_Type.view)
   is
      use c_type.Vectors;
   begin
      Self.a_Types.delete (Self.a_Types.find_Index (the_Type));
   end rid;



   procedure models_cpp_class_Type (Self      : access Item;
                                    new_Class : in     c_Type.view)
   is
   begin
      Self.a_cpp_class_Type := new_Class;
   end models_cpp_class_Type;



   function Subprograms (Self : access Item) return c_Function.Vector
   is
   begin
      return Self.a_Subprograms;
   end Subprograms;



   function Variables (Self : access Item) return c_variable.Vector
   is
   begin
      return Self.a_Variables;
   end Variables;



   function Types (Self : access Item)  return c_type.Vector
   is
   begin
      return Self.a_Types;
   end Types;



   procedure is_enum_Proxy (Self : access Item)
   is
   begin
      Self.a_is_enum_Proxy := True;
   end is_enum_Proxy;



   function models_a_virtual_cpp_Class (Self : access Item) return Boolean
   is
   begin
      if Self.a_cpp_class_Type = null then
         return False;
      end if;

      return total_virtual_member_function_Count (Self.a_cpp_class_Type) > 0;
   end models_a_virtual_cpp_Class;



   function models_an_interface_Type (Self : access Item) return Boolean
   is
   begin
      if Self.a_cpp_class_Type = null then
         return False;
      end if;

      return is_interface_Type (Self.a_cpp_class_Type);
   end models_an_interface_Type;



   function  cpp_class_Type (Self : access Item) return c_Type.view
   is
   begin
      if Self.a_cpp_class_Type = null then
         return null;
      else
         return Self.a_cpp_class_Type;
      end if;
   end cpp_class_Type;


   --------------
   --  Operations
   --

   procedure verify (Self : access Item)
   is
      use c_Type.Vectors;
   begin
      Self.a_Name := to_ada_Identifier (Self.a_Name);

      for Each in 1 .. Natural (Length (Self.a_Types))
      loop -- Verify contained types.
         Element (Self.a_Types,  Each).verify;
      end loop;

      declare
         Cursor : c_function.Cursor := First (Self.a_Subprograms);
      begin
         while has_Element (Cursor)
         loop
            Element (Cursor).verify;
            next    (Cursor);
         end loop;
      end;
   end verify;



   function type_name_needs_Standard_prefix (Self     : access Item'class;
                                             Name     : in     String;
                                             the_Type : in     c_Type.view) return Boolean
   is
      lowcase_Name    : constant String           := to_Lower (Name);
      lowcase_Type    : constant unbounded_String := Text_before_first_Dot (+to_Lower (+the_type.nameSpace.qualified_Name));
      name_type_Clash : constant Boolean          := lowcase_Name = lowcase_Type;
   begin
      if name_type_Clash then
         return True;
      end if;

      for Each in 1 .. Natural (Length (Self.a_Variables))
      loop
         if to_Lower (to_String (Element (Self.a_Variables, Each).Name))  =  lowcase_Type
         then
            return True;
         end if;
      end loop;

      return False;
   end type_name_needs_Standard_prefix;

end c_Namespace;
