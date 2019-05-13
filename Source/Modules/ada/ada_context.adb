with
     ada_Package,
     ada_type.a_subType,
     ada_type.elementary.an_access.to_type,
     ada_Utility;


package body ada_Context
is
   use ada_Utility;


   --  Globals
   --

   NL : constant String := new_line_Token;


   subtype subType_view is ada_Type.a_subType.view;



   type a_packages_withing_Requirements is
      record
         required_access_Types   : ada_Type.vector;
         required_tagged_Types   : ada_Type.vector;
         normal_With_is_required : Boolean        := False;
         --  limited_with_is_required : Boolean;
      end record;



   function to_Hash is new ada.unchecked_Conversion (ada_Package.view, ada.containers.Hash_type);

   package package_to_withing_requirements_Maps is new ada.containers.hashed_Maps (ada_Package.view,  a_packages_withing_Requirements,
                                                                                   to_Hash,           ada_Package."=");


   type internal_State is
      record
         package_withing_requirements_Map : package_to_withing_requirements_Maps.Map;
      end record;





   --  Forge
   --

   function to_Context return Item
   is
   begin
      return (a_required_Types => <>,
              State            => new internal_State);
   end to_Context;




   --  Attributes
   --

   function to_Source (Self             : in Item;
                       own_Package      : in ada_Package.view;
                       namespace_Prefix : in unbounded_String) return String
   is
      pragma Unreferenced (namespace_Prefix);

      use ada_type_Maps,
          ada_Type,
          ada_Package;


      null_Requirements : a_packages_withing_Requirements;


      use package_to_withing_requirements_Maps;

      the_package_withing_requirements_Map : package_to_withing_requirements_Maps.Map renames Self.State.package_withing_requirements_Map;
      the_Source                           : unbounded_String;

   begin
      declare
         Cursor                   : ada_type_set_Cursor            := First (Self.a_required_Types);
         the_required_Type        : ada_Type.view;
         the_withing_Requirements : a_packages_withing_Requirements;
--           limited_Needed           : Boolean;

         the_type_Info            : type_Info;

      begin

         while has_Element (Cursor)
         loop
            the_type_Info := Element (Cursor);

--              log ("required type name:      " & the_type_Info.my_Type.qualified_Name);
--              log ("required typed decl pkg: " & the_type_Info.my_Type.declaration_Package.qualified_Name);
--              log ("own_Package:             " & own_Package.qualified_Name);

            if the_type_Info.my_Type.declaration_Package /= own_Package
            then
               the_required_Type := the_type_Info.my_Type;

               --  Get existing 'with'ing requirements, if any.
               --
               if Contains (the_package_withing_requirements_Map,  ada_Package.view (the_required_Type.declaration_Package))
               then
                  the_withing_Requirements := Element (the_package_withing_requirements_Map,
                                                       key => ada_Package.view (the_required_Type.declaration_Package));
               else
                  the_withing_Requirements := null_Requirements;
               end if;


               if not the_withing_Requirements.normal_With_is_required
               then   -- No need to check, when 'normal With' already required.
--                    log ("the_type_Info.my_Type.declaration_Package is " & the_type_Info.my_Type.declaration_Package.qualified_Name);
--                    log (+Boolean'Image (the_type_Info.my_Type.declaration_Package.depends_on (own_Package, depth => 0)));

                  if        not the_type_Info.is_accessed
                    or else not the_type_Info.my_Type.declaration_Package.depends_on (own_Package, depth => 0)
                  then
                     the_withing_Requirements.normal_With_is_required := True;
                  end if;
               end if;

               --  Store the packages 'With'ing requirements
               --
               include (the_package_withing_requirements_Map,  ada_Package.view (the_required_Type.declaration_Package),
                                                               the_withing_Requirements);
            end if;

            next (Cursor);
         end loop;
      end;


      declare
         use ada_Package.Vectors,
             ada.Containers;

         the_Package              : ada_Package.view;
         the_withing_Requirements : a_packages_withing_Requirements;
         Cursor                   : package_to_withing_requirements_Maps.Cursor := First (the_package_withing_requirements_Map);

--           function the_namespace_Prefix return unbounded_String is
--           begin
--              if        the_Package.is_Core
--                or else namespace_Prefix = ""
--              then
--                 return null_unbounded_String;
--              else
--                 return namespace_Prefix;
--              end if;
--           end the_namespace_Prefix;


         function "<" (L, R : in ada_Package.view) return Boolean
         is
         begin
            return L.qualified_Name < R.qualified_Name;
         end "<";

         package Sorter is new ada_Package.Vectors.generic_Sorting ("<");


         normal_Withs  : ada_Package.Vector;
         limited_Withs : ada_Package.Vector;

      begin
         -- Sort into normal with's and limited with's.
         --
         while has_Element (Cursor)
         loop
            the_Package := Key (Cursor);

            if             the_Package /= own_Package                 -- Do not with 'own' package
              and then not own_Package.has_Ancestor (the_Package)     -- or any of 'own' packages ancestors.
            then
               the_withing_Requirements := Element (Cursor);

               if        the_withing_Requirements.normal_With_is_required
                 or else the_Package.is_Core
               then
                  append (normal_Withs,  the_Package);
               else
                  append (limited_Withs, the_Package);
               end if;
            end if;

            next (Cursor);
         end loop;


         -- Add all normal 'with's.
         --
         if not normal_Withs.is_Empty
         then
            declare
               Cursor : ada_Package.vector_Cursor;
            begin
               Sorter.sort (normal_Withs);

               Cursor := normal_Withs.First;
               while has_Element (Cursor)
               loop
                  the_Package := Element (Cursor);

                  append (the_Source,  "with " & the_Package.qualified_Name & ";" & NL);
                  next   (Cursor);
               end loop;
            end;
         end if;

         -- Add all limited 'with's.
         --
         if not limited_Withs.is_Empty
         then
            declare
               Cursor : ada_Package.vector_Cursor;
            begin
               Sorter.sort (normal_Withs);

               Cursor := limited_Withs.First;
               while has_Element (Cursor)
               loop
                  the_Package := Element (Cursor);

                  append (the_Source,  "limited with " & the_Package.qualified_Name & ";" & NL);
                  next   (Cursor);
               end loop;
            end;
         end if;
      end;


      return to_String (the_Source);
   end to_Source;



   function limited_Withs (Self : in Item;   the_Package : in ada_Package.view) return Boolean
   is
   begin
      if not Self.State.package_withing_requirements_Map.Contains (the_Package)
      then
         return False;
      end if;

      declare
         the_withing_Requiements : constant a_packages_withing_Requirements := Self.State.package_withing_requirements_Map.Element (the_Package);
      begin
         return not the_withing_Requiements.normal_With_is_required;
      end;
   end limited_Withs;




   --  Operations
   --


   procedure add (Self          : in out Item;   required_Type : in ada_Type.view)
--                    is_Parameter   : in Boolean)
   is
      use ada_Type,
          ada_type_Maps;
   begin
--        log (required_Type.qualified_Name & "   " & ada.tags.Expanded_Name (required_Type.all'Tag));

      if required_Type.declaration_Package = null
      then
         log (+"NULL");
      end if;

--        log ("required_Type.declaration_Package.qualified_Name: " & required_Type.declaration_Package.qualified_Name);

      if required_Type.declaration_Package.qualified_Name /= "standard"
      then
         declare
            the_required_Type : ada_Type.view;
            is_access         : Boolean;
         begin
--              log ("gnat_context.add (required_Type: '" & required_Type.qualified_Name
--                   & "', c_type_kind: " & gnat_type.a_c_type_Kind 'Image (required_Type.c_type_Kind));

--  --              if required_Type.c_type_Kind = ada_type.type_Pointer then
--  --                 the_required_Type := required_Type.context_required_Type;
--  --                 is_access         := True;
--  --              else
--                 the_required_Type := required_Type;
--                 is_access         := False;
--  --              end if;

            if   required_Type.all in ada_type.elementary.an_access.to_type.item'Class

              or (         required_Type.all in ada_type.a_subType.item'Class
                  and then subType_view (required_Type).base_Type.all in ada_type.elementary.an_access.to_type.item'Class)
            then
               the_required_Type := required_Type;
               is_access         := True;
            else
               the_required_Type := required_Type;
               is_access         := False;
            end if;

            --               Self.a_required_Types.include (the_required_Type, (the_required_Type,
            --                                                                  is_access));

            declare
               Cursor        : constant ada_type_set_Cursor := Self.a_required_Types.find (the_required_Type);
               the_type_Info :          type_Info;
            begin
               if has_Element (Cursor)
               then   -- Already exists.
                  the_type_Info := Element (Cursor);

                  if        the_type_Info.is_accessed
                    and not is_access
                  then
                     Self.a_required_Types.include (the_required_Type, (the_required_type,
                                                                        is_accessed => False));
                  end if;

               else   -- Does not already exist.
                  Self.a_required_Types.insert (the_required_Type, (the_required_type,
                                                                    is_accessed => is_access));
               end if;
            end;
         end;
      end if;

   end add;



   procedure add (Self : in out Item;   required_Type : in ada_Type.view;
                                        is_access     : in Boolean)
   is
      use ada_Type,
          ada_type_Maps;
   begin
--        log ("ada_Context.add ~ : " & required_Type.qualified_Name & "   in package " & required_Type.declaration_Package.qualified_Name);

      if required_Type.declaration_Package.qualified_Name /= "standard"
      then
         declare
--              the_required_Type : gnat_Type.view;
--              is_access         : Boolean;
         begin
--              log ("gnat_context.add (required_Type: '" & required_Type.qualified_Name
--                   & "', c_type_kind: " & gnat_type.a_c_type_Kind 'Image (required_Type.c_type_Kind));

--              if required_Type.c_type_Kind = gnat_type.type_Pointer then
--                 the_required_Type := required_Type.context_required_Type;
--                 is_access         := True;
--              else
--                 the_required_Type := required_Type;
--                 is_access         := False;
--              end if;

            --               Self.a_required_Types.include (the_required_Type, (the_required_Type,
            --                                                                  is_access));

            declare
               Cursor        : constant ada_type_set_Cursor := Self.a_required_Types.find (required_Type);
               the_type_Info :          type_Info;

            begin
               if has_Element (Cursor)
               then   -- Already exists.
                  the_type_Info := Element (Cursor);

                  if        the_type_Info.is_accessed
                    and not is_access
                  then
                     Self.a_required_Types.include (required_Type, (required_type,
                                                                    is_accessed => False));
                  end if;

               else   -- Does not already exist.
                  Self.a_required_Types.insert (required_Type, (required_type,
                                                                is_accessed => is_access));
               end if;
            end;
         end;
      end if;

   end add;



   procedure add (Self : in out Item;   required_Types : in ada_Type.views)
   is
   begin
      for Each in required_Types'Range
      loop
--           log ("required_Type ("  &  integer'image (Each) & "): '"  &  qualified_Name (required_Types (Each))  &  "'");
         add (Self,  required_Types (Each));
      end loop;
   end add;



--     function equivalent_Elements (Left, Right : in type_Info) return Boolean
--     is
--        use ada_Type;
--     begin
--        return left.my_Type = right.my_Type;
--     end equivalent_Elements;



   function to_Hash (Self : in type_Info) return ada.containers.Hash_type
   is
      function Hash_it is new ada.unchecked_Conversion (ada_Type.view,
                                                        ada.containers.Hash_type);
   begin
      return Hash_it (Self.my_Type);
   end to_Hash;


end ada_Context;
