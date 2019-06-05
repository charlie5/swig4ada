with
     ada_Utility,
     ada.Characters.handling;


package body ada_Type.elementary.scalar.discrete.enumeration
is

   --  Forge
   --

   function new_Item (declaration_Package : access ada_Package.item'Class := null;
                      Name                : in     unbounded_String       := null_unbounded_String) return View
   is
   begin
      return new Item' (declaration_Package => declaration_Package,
                        Name                => Name,
                        others              => <>);
   end new_Item;



   --  Attributes
   --

   procedure add_Literal (Self : access Item;   Name  : in unbounded_String;
                                                Value : in gmp.discrete.Integer)
   is
      use enum_literal_Vectors;
   begin
      append (Self.Literals, (Name  => Name,
                              Value => Value));
   end add_Literal;



   function contains_Literal (Self  : access Item;
                              Named : in     String) return Boolean
   is
      use enum_literal_Vectors;
      Cursor : enum_literal_Vectors.Cursor := First (Self.Literals);
   begin

      while has_Element (Cursor)
      loop
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
      append (Self.transformed_literals_Names, literal_Name);
   end add_transformed_Literal;



   function contains_transformed_Literal (Self  : access Item;
                                          Named : in     unbounded_String)  return Boolean
   is
   begin
      return contains (Self.transformed_literals_Names, Named);
   end contains_transformed_Literal;



   function Literals (Self : access Item) return enum_literal_vectors.Vector
   is
   begin
      return Self.Literals;
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
      use enum_literal_Vectors,
          ada_Utility,
          ada.Characters.handling;
   begin
      Self.Name := to_ada_Identifier (Self.Name);

      for Each in 1 .. Natural (Length (Self.Literals))
      loop
         replace_Element (Self.Literals, Each, (Name  => to_ada_Identifier (Element (Self.Literals, Each).Name),
                                                Value => Element (Self.Literals, Each).Value));
      end loop;

      correct_any_name_Clash:
      declare
         Clash_found : Boolean := False;       -- Occurs when any of an enun's literals matches its name (disregarding case).
      begin
         for Each in 1 .. Natural (Length (Self.Literals))
         loop
            if to_Lower (+Element (Self.Literals, Each).Name) = to_Lower (+Self.Name)
            then
               Clash_found := True;
            end if;
         end loop;

         if Clash_found
         then
            append (Self.Name, "_enum");
         end if;
      end correct_any_name_Clash;

      sort_Literals:
      declare
         use gmp.discrete;

         function less_than (Left, Right : enum_Literal) return Boolean
         is begin
            return Left.Value < Right.Value;
         end less_than;

         package Sorter is new enum_literal_vectors.generic_Sorting ("<" => less_than);
      begin
         Sorter.sort (Self.Literals);
      end sort_Literals;
   end verify;


end ada_Type.elementary.scalar.discrete.enumeration;

