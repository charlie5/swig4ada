with
     ada_Package,
     ada_type.elementary.an_access,
     ada_Utility;


package body ada_Subprogram
is
   use ada_Type,
       ada_parameter.Vectors,
       ada_Package,
       ada_Utility;



   --  Globals
   --

   NL : constant String := new_line_Token;





   --  Forge
   --

   function construct (the_Name    : in unbounded_String;
                       return_Type : in ada_Type.view) return item'Class
   is
   begin
      return Item'(name               => the_Name,
                   return_type        => return_Type,
                   Parameters         => ada_parameter.vectors.empty_Vector,
                   is_Constructor     => False,
                   is_Destructor      => False,
                   is_Virtual         => False,
                   is_Abstract        => False,
                   is_Overriding      => False,
                   is_to_view_Conversion    => False,
                   is_to_pointer_Conversion => False,
                   returns_an_Access        => False,
                   constructor_Symbol       => null_unbounded_String,
                   access_mode              => Unknown,
                   link_symbol              => <>
                  );
   end construct;



   function new_ada_Subprogram (the_Name  : in unbounded_String;
                                 return_Type  : in ada_Type.view) return View
   is
   begin
      return new Item'(Item (construct (the_Name, return_Type)));
   end new_ada_Subprogram;




   --  Attributes
   --

   function is_Procedure (Self : access Item) return Boolean
   is
   begin
      return qualified_Name (Self.return_Type) = "swig.void";
   end is_Procedure;



   function is_Function (Self : access Item) return Boolean
   is
   begin
      return not Self.is_Procedure;
   end is_Function;



   function required_Types (Self : access Item) return ada_Type.views
   is
      use ada_Parameter;
   begin
      if Self.is_Function
      then
         return   Self.return_Type
                & required_Types (Self.Parameters);
      else
         return   required_Types (Self.Parameters);
      end if;
   end required_Types;





   function context_required_Types (Self : access Item) return ada_Type.views
   is
      use ada_Parameter;
   begin
      if Self.is_Function
      then
         return   Self.return_Type
                & context_required_Types (Self.Parameters);
      else
         return   context_required_Types (Self.Parameters);
      end if;
   end context_required_Types;




   function depends_on             (Self : access Item;   a_Type      : in     ada_Type.view;
                                                          Depth       : in     Natural) return Boolean
   is
      use ada_Parameter;
   begin
--        log ("ada_subprogram.depends_on ~ Self.Name: '" & Self.name & "'     a_Type.Name: '" & a_Type.Name & "'");

      if Self.is_Function
      then
         if        Self.return_Type.all'Access = a_Type
           or else Self.return_Type.depends_on (a_Type, Depth + 1)
         then
            return True;
         end if;
      end if;

      return depends_on (Self.Parameters, a_Type, Depth + 1);
   end depends_on;




   function depends_directly_on (Self : access Item;   a_Type      : in     ada_Type.view;
                                                       Depth       : in     Natural)       return Boolean
   is
      use ada_Parameter;
   begin
--        log ("ada_subprogram.depends_directly_on ~ Self.Name: '" & Self.name & "'     a_Type.Name: '" & a_Type.Name & "'");

      if Self.is_Function
      then
         if Self.return_Type.all'Access = a_Type then
            return True;
         end if;
      end if;

      return depends_directly_on (Self.Parameters, a_Type, Depth + 1);
   end depends_directly_on;



   function depends_on (Self : access Item;   a_Package : access ada_Package.item'class;
                                              Depth     : in     Natural) return Boolean
   is
      use ada_Parameter;
   begin
--        log ("ada_subprogram.depends_on ~ Self.Name: '" & Self.name & "'     a_Type.Name: '" & a_Type.Name & "'");

      if Self.is_Function
      then
         if        Self.return_Type.declaration_Package = a_Package
           or else Self.return_Type.depends_on (a_Package, Depth + 1)
         then
            return True;
         end if;
      end if;

      return depends_on (Self.Parameters, a_Package, Depth + 1);
   end depends_on;



   function depends_on_any_pointer  (Self : access Item) return Boolean
   is
      the_required_Types : constant ada_Type.views := Self.required_Types;
   begin
      for Each in the_required_Types'Range
      loop
         if the_required_Types (Each).resolved_type.all in ada_type.elementary.an_access.Item'Class
         then
            return True;
         end if;
      end loop;

      return False;
   end depends_on_any_pointer;



   function pragma_import_Source (Self                 : access Item;
                                  declaration_Package  : access ada_Package.item'class;
                                  unique_function_Name : in     unbounded_String;
                                  in_cpp_Mode          : in     Boolean)         return unbounded_String
   is
      use ada.Containers;
      the_Source  : unbounded_String;
      link_Symbol : unbounded_String;

   begin
      if Self.is_Abstract
      then
         return the_Source;
      end if;

      if Self.is_Constructor
      then
         link_Symbol := Self.member_function_link_Symbol_for (in_cpp_Mode);

         if --   Length (Self.Parameters) = 0 and    -- Non-default constructors (ie those with parameters) are not yet implemented in gnat.
            declaration_Package.models_a_virtual_cpp_Class
         then
            append (the_Source,  NL & NL & "   pragma cpp_Constructor (" & unique_function_Name &  ", """ & link_Symbol &  """);");
         else
            append (the_Source,  NL & NL & "   pragma Import (CPP, " & unique_function_Name & ", """ & link_Symbol & """);");
         end if;

      elsif Self.is_Destructor
      then
         link_Symbol := "_ZN" & Image (Length (declaration_Package.Name)) & declaration_Package.Name & "D1Ev";

--         append (the_Source,   NL & "   pragma cpp_Destructor (Entity => " & unique_function_Name & ");" & NL);
         append (the_Source,   NL & "   pragma Import (CPP, " & unique_function_Name & ", """ & link_Symbol & """);");

      else
         if declaration_Package.models_an_interface_Type
         then
            append (the_Source,  NL & "   pragma Convention (CPP, ");

         elsif declaration_Package.models_a_virtual_cpp_Class
         then
            if Self.is_Constructor
            then
               append (the_Source,  NL & "   pragma cpp_Constructor (");
            else
               append (the_Source,  NL & "   pragma Import (CPP, ");
            end if;

         else
            append (the_Source,  NL & "   pragma Import (C, ");
         end if;


         append (the_Source,  unique_function_Name);

         if not (   declaration_Package.models_an_interface_Type
                 or Self.is_Abstract)
         then
            append (the_Source,  ", """ & Self.member_function_link_Symbol_for (in_cpp_Mode) &  """");
         end if;

         append (the_Source,  ");");
      end if;

      return the_Source;
   end pragma_import_Source;



   function pragma_CPP_Constructor_Source (Self                 : access Item;
                                           declaration_Package  : access ada_Package.item'class;
                                           unique_function_Name : in     unbounded_String;
                                           in_cpp_Mode          : in     Boolean)         return unbounded_String
   is
      use ada.Containers;
      the_Source  : unbounded_String;
      link_Symbol : unbounded_String;

   begin
      --  'C' link name.
      --
      if not in_cpp_Mode
      then
         raise Constraint_Error with "Not in C++ mode";
      end if;

      --  'C++' link name.
      --
      if not Self.is_Constructor
      then
         raise Constraint_Error with "Not a constructor";
      end if;

      link_Symbol := Self.member_function_link_Symbol_for (in_cpp_Mode);
--        link_Symbol := "_ZN" & Image (Length (declaration_Package.Name)) & declaration_Package.Name & "C1Ev";

      if --   Length (Self.Parameters) = 0 and    -- ToDo this is no longer the case -> "Non-default constructors (ie those with parameters) are not yet implemented in gnat."
         declaration_Package.models_a_virtual_cpp_Class
      then
         append (the_Source,  NL & NL & "   pragma cpp_Constructor (" & unique_function_Name &  ", """ & link_Symbol &  """);");
      else
         append (the_Source,  NL & NL & "   pragma Import (CPP, " & unique_function_Name & ", """ & link_Symbol & """);");
      end if;

      return the_Source;
   end pragma_CPP_Constructor_Source;



   function member_function_link_Symbol_for (Self        : access Item;
                                             in_cpp_Mode : in     Boolean) return unbounded_String
   is
   begin
      --  'C' link name.
      --
      if not in_cpp_Mode
      then
         return Self.Name;
      end if;

      --  'C++' link name.
      --
      if Self.is_Constructor
      then
         return Self.constructor_Symbol;
--           return Self.link_Symbol;

      elsif Self.link_Symbol /= ""
      then
         return Self.link_Symbol;

      else
         return to_unbounded_String ("_Z(to_be_determined)");
      end if;
   end member_function_link_Symbol_for;




   --  Operations
   --

   procedure verify (Self : access Item)
   is
   begin
      Self.Name := to_ada_Identifier (Self.Name);
   end verify;


end ada_Subprogram;
