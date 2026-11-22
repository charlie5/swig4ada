with
     ada.Strings.fixed,
     ada.Strings.unbounded,
     ada.Containers.indefinite_Vectors;


package body cpp_Mangling
is
   use ada.Strings.unbounded;

   package String_Vectors is new ada.Containers.indefinite_Vectors (Positive, String);

   Unsupported : exception;


   function Image (Count : in Natural) return String
   is (ada.Strings.fixed.Trim (Count'Image, ada.Strings.Left));



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



   function Symbol (qualified_Name : in String;   Suffix : in String) return String
   is
      --  The parts which have been written so far, each of which is named by its place when it is met again:
      --  a namespace or class with those which hold it, a template, a template instance, and a pointer, a
      --  reference or a 'const' type. Each is kept as swig writes it.
      --
      Written : String_Vectors.Vector;


      function is_Written (the_Part : in String) return Boolean
      is (Written.contains (the_Part));


      function Substitution (the_Part : in String) return String
      --
      --  'S_' for the first part which was written, then 'S0_', 'S1_' and so on, the number being in base 36.
      --
      is
         Digit : constant String  := "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
         Place : constant Natural := Written.find_Index (the_Part) - 1;
      begin
         if Place = 0
         then
            return "S_";

         elsif Place <= 36
         then
            return "S" & Digit (Place) & "_";
         else
            raise Unsupported;
         end if;
      end Substitution;


      function mangled_Type (the_Type : in String) return String;


      function mangled_Name (Name : in String;   Wholly_substituted : out Boolean) return String
      --
      --  The name of a class, a namespace or a variable, with whatever holds it, and with no 'N' and 'E' about it.
      --  'Wholly_substituted' is True where the whole of the name had been written before.
      --
      is
         the_Components : constant String_Vectors.Vector := split (Name, "::");
         the_Result     : unbounded_String;
         so_Far         : unbounded_String;     -- The name up to the component in hand, which is what a substitution names.
      begin
         Wholly_substituted := False;

         for Each of the_Components
         loop
            declare
               Open       : constant Natural := ada.Strings.fixed.Index (Each, "<(");
               the_Base   : constant String  := (if Open = 0 then Each else Each (Each'First .. Open - 1));
               Outer      : constant String  := to_String (so_Far) & (if so_Far = "" then "" else "::");
               with_Args  : constant String  := Outer & Each;
               its_Plain  : constant String  := Outer & the_Base;     -- A template instance, less its arguments: the template.
            begin
               if        the_Base = ""
                 or else the_Base = "std"
                 or else (for some Char of the_Base => Char not in 'a' .. 'z' | 'A' .. 'Z' | '0' .. '9' | '_')
               then
                  raise Unsupported;
               end if;

               Wholly_substituted := False;

               if is_Written (with_Args)
               then   -- All of the name so far has been written: its place stands for it.
                  the_Result         := to_unbounded_String (Substitution (with_Args));
                  Wholly_substituted := True;

               else
                  if is_Written (its_Plain)     -- Which can only be the template of an instance, here.
                  then
                     the_Result := to_unbounded_String (Substitution (its_Plain));
                  else
                     append (the_Result, Image (the_Base'Length) & the_Base);
                     Written.append (its_Plain);
                  end if;

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
                     Written.append (with_Args);
                  end if;
               end if;

               so_Far := to_unbounded_String (with_Args);
            end;
         end loop;

         return to_String (the_Result);
      end mangled_Name;


      function mangled_Type (the_Type : in String) return String
      --
      --  'the_Type' is a swig type, such as 'int', 'p.q(const).char' or 'ns::Thing'.
      --
      is
         function Compound (Code : in String;   Prefix_length : in Positive) return String
         --
         --  A pointer, a reference or a 'const' type, which is a part that may be named again.
         --
         is
         begin
            if is_Written (the_Type)
            then
               return Substitution (the_Type);
            end if;

            return Result : constant String := Code & mangled_Type (the_Type (the_Type'First + Prefix_length .. the_Type'Last))
            do
               Written.append (the_Type);
            end return;
         end Compound;

      begin
         if    the_Type'Length > 2 and then the_Type (the_Type'First .. the_Type'First + 1) = "p."          then   return Compound ("P", 2);
         elsif the_Type'Length > 2 and then the_Type (the_Type'First .. the_Type'First + 1) = "r."          then   return Compound ("R", 2);
         elsif the_Type'Length > 2 and then the_Type (the_Type'First .. the_Type'First + 1) = "z."          then   return Compound ("O", 2);
         elsif the_Type'Length > 9 and then the_Type (the_Type'First .. the_Type'First + 8) = "q(const)."   then   return Compound ("K", 9);

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
         elsif the_Type = "wchar_t"             then   return "w";

         elsif (for all Each of the_Type => Each in '0' .. '9')
         then   -- An integer, which is taken to be an argument of type 'int'.
            return "Li" & the_Type & "E";

         else   -- A class, or what is not dealt with, which the name is found not to be made of.
            declare
               Wholly_substituted : Boolean;
               the_Name           : constant String  := mangled_Name (the_Type, Wholly_substituted);
               is_Nested          : constant Boolean := Natural (split (the_Type, "::").Length) > 1;
            begin
               return (if is_Nested and not Wholly_substituted then "N" & the_Name & "E"
                                                               else the_Name);
            end;
         end if;
      end mangled_Type;

      Unused : Boolean;

   begin
      if qualified_Name = ""
      then
         return "";
      end if;

      return "_ZN" & mangled_Name (qualified_Name, Unused) & Suffix;

   exception
      when Unsupported | Constraint_Error =>
         return "";
   end Symbol;

end cpp_Mangling;
