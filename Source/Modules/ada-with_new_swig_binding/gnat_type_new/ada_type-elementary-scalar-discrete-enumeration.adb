with
     ada_Utility,
     ada.characters.Handling;

package body ada_Type.elementary.scalar.discrete.enumeration
is

   --  Forge
   --


   function new_Item (declaration_Package : access ada_Package.item'class := null;
                      Name                : in     unbounded_String       := null_unbounded_String) return View
   is
   begin
      return new Item'(declaration_package => declaration_Package,
                       name                => Name,
                       others => <>);
   end new_Item;




   --  Attributes
   --

   procedure add_Literal (Self : access Item;   Name         : in unbounded_String;
                                                Value        : in gmp.discrete.Integer)

   is
      use enum_literal_Vectors;
   begin
      append (self.Literals,  (name => Name,
                               value => Value));
   end add_Literal;



   function contains_Literal (Self  : access Item;
                              Named : in     String) return Boolean
   is
      use enum_literal_Vectors;
      Cursor : enum_literal_Vectors.Cursor := First (self.Literals);
   begin

      while has_Element (Cursor) loop

         if Element (Cursor).Name = Named then
            return True;
         end if;

         next (Cursor);
      end loop;


      return False;
   end contains_Literal;



   procedure add_transformed_Literal (Self         : access Item;
                                      literal_Name : in     unbounded_String)
   is
   begin
      append (self.transformed_literals_Names,  literal_Name);
   end add_transformed_Literal;



   function contains_transformed_Literal (Self  : access Item;
                                          Named : in     unbounded_String)  return Boolean
   is
   begin
      return contains (self.transformed_literals_Names,  Named);
   end contains_transformed_Literal;



   function  Literals (Self : access Item) return enum_literal_vectors.Vector
   is
   begin
      return self.Literals;
   end Literals;



   overriding
   function context_required_Types (Self : access Item)  return ada_Type.views
   is
      pragma Unreferenced (Self);
   begin
      return (1 .. 0 => <>);
   end context_required_Types;






   --  Operations
   --

   overriding
   procedure verify (Self : access Item)
   is
      use enum_literal_Vectors, ada.characters.Handling;
--        use ada_Package;
   begin
      self.Name := ada_Utility.to_ada_Identifier (self.Name);


      for Each in 1 .. Natural (Length (self.Literals)) loop
         replace_Element (self.Literals,  Each, (name  => ada_Utility.to_ada_Identifier (Element (self.Literals,  Each).Name),
                                                    value => Element (self.Literals,  Each).Value));
      end loop;


      correct_any_name_Clash:
      declare
         Clash_found : Boolean := False;       -- occurs when any of an enun's literals matches its name (disregarding case).
      begin

         for Each in 1 .. Natural (Length (self.Literals)) loop
            if to_Lower (to_String (Element (self.Literals,  Each).Name))  =   to_Lower (to_String (self.Name)) then
               Clash_found := True;
            end if;
         end loop;

         if Clash_found then
            append (self.Name, "_enum");
         end if;
      end correct_any_name_Clash;


      sort_Literals:
      declare
         use gmp.discrete;
         function less_than (Left, Right : enum_Literal) return Boolean is begin   return left.Value < right.Value;   end less_than;

         package Sorter is new enum_literal_vectors.generic_Sorting ("<" => less_than);
      begin
         Sorter.sort (self.Literals);
      end sort_Literals;

   end verify;


end ada_Type.elementary.scalar.discrete.enumeration;

