separate (ada_Language)


function cpp_Symbol (qualified_Name : in String;   Suffix : in String) return String
--
--  The C++ symbol of an entity with the given name, as swig holds it ('geometry::solid::Box', 'Source<(int)>'),
--  and the suffix of its kind ('E' for a variable, 'D1Ev' for a destructor). Returns "" where the symbol
--  cannot be made: the mangling done here covers namespaces and the simpler template arguments only (a
--  standard type, a class, a pointer or reference to either, and an integer), and no substitutions.
--
is
   Unsupported : exception;


   function Image (Count : in Natural) return String
   is (ada.Strings.fixed.Trim (Count'Image, Left));


   function split (Text : in String;   Separator : in String) return String_Vectors.Vector
   --
   --  Splits the text at each separator which is not within the arguments of a template.
   --
   is
      the_Parts : String_Vectors.Vector;
      Depth     : Natural  := 0;
      First     : Positive := Text'First;
      Index     : Positive := Text'First;
   begin
      while Index <= Text'Last
      loop
         if         Index < Text'Last
           and then Text (Index .. Index + 1) = "<("
         then
            Depth := Depth + 1;
            Index := Index + 2;

         elsif      Index < Text'Last
           and then Text (Index .. Index + 1) = ")>"
         then
            Depth := Depth - 1;
            Index := Index + 2;

         elsif      Depth = 0
           and then Index + Separator'Length - 1 <= Text'Last
           and then Text (Index .. Index + Separator'Length - 1) = Separator
         then
            the_Parts.append (Text (First .. Index - 1));
            Index := Index + Separator'Length;
            First := Index;
         else
            Index := Index + 1;
         end if;
      end loop;

      the_Parts.append (Text (First .. Text'Last));
      return the_Parts;
   end split;


   function mangled_Name (Name : in String;   is_Nested : in Boolean) return String;


   function mangled_Type (the_Type : in String) return String
   --
   --  'the_Type' is a swig type, such as 'int', 'p.q(const).char' or 'ns::Thing'.
   --
   is
   begin
      if the_Type'Length > 2 and then the_Type (the_Type'First .. the_Type'First + 1) = "p."
      then
         return "P" & mangled_Type (the_Type (the_Type'First + 2 .. the_Type'Last));

      elsif the_Type'Length > 2 and then the_Type (the_Type'First .. the_Type'First + 1) = "r."
      then
         return "R" & mangled_Type (the_Type (the_Type'First + 2 .. the_Type'Last));

      elsif the_Type'Length > 9 and then the_Type (the_Type'First .. the_Type'First + 8) = "q(const)."
      then
         return "K" & mangled_Type (the_Type (the_Type'First + 9 .. the_Type'Last));

      elsif the_Type = "void"                then   return "v";
      elsif the_Type = "bool"                then   return "b";
      elsif the_Type = "char"                then   return "c";
      elsif the_Type = "signed char"         then   return "a";
      elsif the_Type = "unsigned char"       then   return "h";
      elsif the_Type = "short"               then   return "s";
      elsif the_Type = "unsigned short"      then   return "t";
      elsif the_Type = "int"                 then   return "i";
      elsif the_Type = "unsigned int"        then   return "j";
      elsif the_Type = "long"                then   return "l";
      elsif the_Type = "unsigned long"       then   return "m";
      elsif the_Type = "long long"           then   return "x";
      elsif the_Type = "unsigned long long"  then   return "y";
      elsif the_Type = "float"               then   return "f";
      elsif the_Type = "double"              then   return "d";
      elsif the_Type = "long double"         then   return "e";

      elsif (for all Each of the_Type => Each in '0' .. '9')
      then   -- An integer, which is taken to be an argument of type 'int'.
         return "Li" & the_Type & "E";

      elsif (for some Each of the_Type => Each in ' ' | '.' | '-')
      then
         raise Unsupported;
      else
         return mangled_Name (the_Type, is_Nested => False);
      end if;
   end mangled_Type;


   function mangled_Name (Name : in String;   is_Nested : in Boolean) return String
   --
   --  'is_Nested' is True where the name is already within 'N' and 'E'.
   --
   is
      the_Components : constant String_Vectors.Vector := split (Name, "::");
      the_Result     : unbounded_String;
   begin
      for Each of the_Components
      loop
         declare
            Open     : constant Natural := ada.Strings.fixed.Index (Each, "<(");
            the_Base : constant String  := (if Open = 0 then Each else Each (Each'First .. Open - 1));
         begin
            if        the_Base = ""
              or else the_Base = "std"
              or else (for some Char of the_Base => Char not in 'a' .. 'z' | 'A' .. 'Z' | '0' .. '9' | '_')
            then
               raise Unsupported;
            end if;

            append (the_Result, Image (the_Base'Length) & the_Base);

            if Open /= 0
            then
               if Each (Each'Last - 1 .. Each'Last) /= ")>"
               then
                  raise Unsupported;
               end if;

               append (the_Result, "I");

               for each_Argument of split (Each (Open + 2 .. Each'Last - 2), ",")
               loop
                  append (the_Result, mangled_Type (each_Argument));
               end loop;

               append (the_Result, "E");
            end if;
         end;
      end loop;

      if        is_Nested
        or else Natural (the_Components.Length) = 1
      then
         return to_String (the_Result);
      else
         return "N" & to_String (the_Result) & "E";
      end if;
   end mangled_Name;

begin
   if qualified_Name = ""
   then
      return "";
   end if;

   return "_ZN" & mangled_Name (qualified_Name, is_Nested => True) & Suffix;

exception
   when Unsupported | constraint_Error =>
      return "";
end cpp_Symbol;
