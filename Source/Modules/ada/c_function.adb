with
     ada_Utility;


package body c_Function
is
   use c_Type,
       c_parameter.Vectors,
       ada_Utility;


   ---------
   --  Forge
   --
   function construct (the_Name    : in unbounded_String;
                       return_Type : in c_Type.view) return item'Class
   is
   begin
      return c_function.Item' (c_Declarable.Item with
                               name                     => the_Name,
                               return_type              => return_Type,
                               Parameters               => <>,
                               is_Constructor           => False,
                               is_Destructor            => False,
                               is_Static                => False,
                               is_Virtual               => False,
                               is_Abstract              => False,
                               is_Overriding            => False,
                               is_to_view_Conversion    => False,
                               is_to_pointer_Conversion => False,
                               returns_an_Access        => False,
                               constructor_Symbol       => null_unbounded_String,
                               access_mode              => Unknown,
                               link_symbol              => <>);
   end construct;



   function new_c_Function (the_Name     : in unbounded_String;
                            return_Type  : in c_Type.view) return View
   is
   begin
      return new Item' (Item (construct (the_Name, return_Type)));
   end new_c_Function;


   --------------
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



   overriding
   function required_Types (Self : access Item) return c_Declarable.c_Type_views
   is
      use c_Declarable,
          c_Parameter;
   begin
      if Self.is_Function
      then
         return   Self.return_Type.all'Access
                & required_Types (Self.Parameters);
      else
         return   required_Types (Self.Parameters);
      end if;
   end required_Types;


   overriding
   function  depended_on_Declarations (Self : access Item) return c_Declarable.views
   is
      use c_Declarable,
          c_Parameter;
   begin
      if Self.is_Function
      then
         return   Self.return_Type.all'Access
                & Self.return_Type.depended_on_Declarations
                & depended_on_Declarations (Self.Parameters);
      else
         return   depended_on_Declarations (Self.Parameters);
      end if;
   end depended_on_Declarations;


   overriding
   function depends_on (Self : access Item;   a_Declarable : in c_Declarable.view) return Boolean
   is
      use c_Parameter;
      use type c_Declarable.view;
   begin
      if Self.is_Function
      then
         if        Self.return_Type.all'Access = a_Declarable
           or else Self.return_Type.depends_on (a_Declarable)
         then
            return True;
         end if;
      end if;

      return depends_on (Self.Parameters, a_Declarable);
   end depends_on;


   overriding
   function depends_directly_on (Self : access Item;   a_Declarable : in c_Declarable.view) return Boolean
   is
      use c_Parameter;
      use type c_Declarable.view;
   begin
      if Self.is_Function
      then
         if Self.return_Type.all'Access = a_Declarable then
            return True;
         end if;
      end if;

      return depends_directly_on (Self.Parameters, a_Declarable);
   end depends_directly_on;


   overriding
   function  directly_depended_on_Declarations (Self : access Item) return c_Declarable.views
   is
      use c_Declarable,
          c_Parameter;
   begin
      if Self.is_Function
      then
         return   Self.return_Type.all'Access
                & directly_depended_on_Declarations (Self.Parameters);
      else
         return   directly_depended_on_Declarations (Self.Parameters);
      end if;
   end directly_depended_on_Declarations;


   overriding
   function Name (Self : access Item) return ada.Strings.Unbounded.unbounded_String
   is
   begin
      return Self.Name;
   end Name;


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

      elsif Self.link_Symbol /= ""
      then
         return Self.link_Symbol;

      else
         return to_unbounded_String ("_Z(to_be_determined)");
      end if;
   end member_function_link_Symbol_for;


   --------------
   --  Operations
   --

   procedure verify (Self : access Item)
   is
   begin
      Self.Name := to_ada_Identifier (Self.Name);
   end verify;

end c_Function;
