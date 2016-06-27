--  with ada_Type;
with ada_Utility;            use ada_Utility;

--  with ada.Strings.unbounded;   use ada.Strings.unbounded;
--  with ada.containers.hashed_Maps;


package body ada_Context
is

   --  Globals
   --

   NL : constant String := portable_new_line_Token;





   --  Attributes
   --

   function to_Source (Self             : in Item;
                       own_Package      : in ada_Package.view;               -- name of the package to which the context applies.
                       namespace_Prefix : in unbounded_String) return String
   is
      pragma Unreferenced (namespace_Prefix);
      use ada_type_Maps;
      use ada_Type;
      use ada_Package;


      type a_packages_withing_Requirements is
         record
            required_access_Types   : ada_Type.vector;
            required_tagged_Types   : ada_Type.vector;
            normal_With_is_required : Boolean         := False;
            --  limited_with_is_required : Boolean;
         end record;

      null_Requirements : a_packages_withing_Requirements;


      function to_Hash is new ada.unchecked_Conversion (ada_Package.view, ada.containers.Hash_type);

      package package_to_withing_requirements_Maps is new ada.containers.hashed_Maps (ada_Package.view,  a_packages_withing_Requirements,
                                                                                      to_Hash,
                                                                                      ada_Package."=");
      use package_to_withing_requirements_Maps;

      the_package_withing_requirements_Map : package_to_withing_requirements_Maps.Map;
      the_Source                           : unbounded_String;

   begin

      declare
         use ada_type.Vectors;
         Cursor                   : ada_type_set_Cursor           := First (self.a_required_Types);
         the_required_Type        : ada_Type.view;
         the_withing_Requirements : a_packages_withing_Requirements;
--           limited_Needed           : Boolean;

         the_type_Info : type_Info;
      begin

         while has_Element (Cursor) loop
            the_type_Info := Element (Cursor);

--              log ("required type name:      " & the_type_Info.my_Type.qualified_Name);
--              log ("required typed decl pkg: " & the_type_Info.my_Type.declaration_Package.qualified_Name);
--              log ("own_Package:             " & own_Package.qualified_Name);

            if the_type_Info.my_Type.declaration_Package /= own_Package
            then
               the_required_Type := the_type_Info.my_Type;

               --  get existing 'with'ing requirements, if any;
               --
               if contains (the_package_withing_requirements_Map,  ada_Package.view (the_required_Type.declaration_Package)) then
                  the_withing_Requirements := Element (the_package_withing_requirements_Map,  key => ada_Package.view (the_required_Type.declaration_Package));
               else
                  the_withing_Requirements := null_Requirements;
               end if;


               if not the_withing_Requirements.normal_With_is_required then   -- no need to check, when 'normal With' already required.

                  if not the_type_Info.is_accessed then
                     the_withing_Requirements.normal_With_is_required := True;
                  end if;

               end if;

               --  store the packages 'With'ing requirements
               --
               include (the_package_withing_requirements_Map,  ada_Package.view (the_required_Type.declaration_Package),
                        the_withing_Requirements);

            end if;

            next (Cursor);
         end loop;
      end;


      declare
         use ada_Type.Vectors, ada.Containers;

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

      begin

         while has_Element (Cursor) loop
            the_Package := Key (Cursor);

            if         the_Package /= own_Package                     -- do not with 'own' package
              and then not own_Package.has_Ancestor (the_Package)     -- or any of 'own' packages ancestors
            then
               the_withing_Requirements := Element (Cursor);

               if        the_withing_Requirements.normal_With_is_required
                 or else the_Package.is_Core
               --                or else (        Length (the_withing_Requirements.required_access_Types) > 0
               --                        and then Length (the_withing_Requirements.required_tagged_Types) > 0)
               then
                  append (the_Source,  "with " & the_Package.qualified_Name & ";" & NL);
                  --  append (the_Source,  "with " & the_namespace_Prefix & the_Package.qualified_Name & ";" & NL);
               else
                  append (the_Source,  "limited with " & the_Package.qualified_Name & ";" & NL);
                  --  append (the_Source,  "with " & the_Package.qualified_Name & ";" & NL);

               end if;

            end if;

            next (Cursor);
         end loop;
      end;


      return to_String (the_Source);
   end to_Source;






   --  Operations
   --


   procedure add (Self                     : in out Item;
                  required_Type            : in     ada_Type.view)
--                    is_Parameter   : in Boolean)
   is
      use ada_Type;
      use ada_type_Maps;
   begin
--        log (required_Type.qualified_Name);

      if required_Type.declaration_Package = null then
         log ("NULL");
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

--              if required_Type.c_type_Kind = ada_type.type_Pointer then
--                 the_required_Type := required_Type.context_required_Type;
--                 is_access         := True;
--              else
               the_required_Type := required_Type;
               is_access         := False;
--              end if;

            --               self.a_required_Types.include (the_required_Type, (the_required_Type,
            --                                                                  is_access));

            declare
               Cursor        : constant ada_type_set_Cursor := self.a_required_Types.find (the_required_Type);
               the_type_Info : type_Info;
            begin

               if has_Element (Cursor) then   -- already exists

                  the_type_Info := Element (Cursor);

                  if    the_type_Info.is_accessed
                    and not is_access
                  then
                     self.a_required_Types.include (the_required_Type, (the_required_type,
                                                                        is_accessed => False));

                  end if;


               else -- does not already exist
                  self.a_required_Types.insert (the_required_Type, (the_required_type,
                                                                    is_accessed => is_access));

               end if;

            end;

         end;


      end if;

   end add;




   procedure add (Self : in out Item;   required_Type : in ada_Type.view;
                                        is_access     : in Boolean)
   is

      use ada_Type;
      use ada_type_Maps;
   begin
      --  log ("***KKKMMM: " & required_Type.declaration_Package.qualified_Name);

      if required_Type.declaration_Package.qualified_Name /= "standard" then
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

            --               self.a_required_Types.include (the_required_Type, (the_required_Type,
            --                                                                  is_access));

            declare
               Cursor        : constant ada_type_set_Cursor := self.a_required_Types.find (required_Type);
               the_type_Info : type_Info;
            begin

               if has_Element (Cursor) then   -- already exists

                  the_type_Info := Element (Cursor);

                  if    the_type_Info.is_accessed
                    and not is_access
                  then
                     self.a_required_Types.include (required_Type, (required_type,
                                                                    is_accessed => False));

                  end if;


               else -- does not already exist
                  self.a_required_Types.insert (required_Type, (required_type,
                                                                is_accessed => is_access));

               end if;

            end;

         end;


      end if;


   end add;






   procedure add (Self : in out Item;   required_Types : in     ada_Type.views)
   is
   begin
      for Each in required_Types'Range loop
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
      function Hash_it is new ada.unchecked_Conversion (ada_Type.view,  ada.containers.Hash_type);
   begin
      return Hash_it (self.my_Type);
   end to_Hash;



end ada_Context;
