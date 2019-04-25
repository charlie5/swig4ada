with
--       swigg_c_import,
     swigg_module.Binding,

     ada.Strings.fixed,
     ada.Characters.handling,
     ada.text_IO,
     ada.streams.stream_io;


package body ada_Utility
is

   use GMP,
       GMP.discrete,

       ada.Strings,
       ada.Strings.fixed,
       ada.Characters.Handling,
       ada.text_IO;



   -----------
   --  Logging
   -----------

   log_Depth : Natural := 0;


   procedure indent_Log
   is
   begin
      log_Depth := log_Depth + 1;
   end indent_Log;



   procedure unindent_Log
   is
   begin
      log_Depth := log_Depth - 1;
   end unindent_Log;



   procedure log (the_Message : in String;
                  Level       : in Verbosity := Debug)
   is
      Pad : constant String (1 .. 3 * log_Depth) := (others => ' ');
   begin
      if verbosity_Level >= Level
      then
         put_Line (Pad & the_Message);
      end if;
   end log;



   procedure log (the_Message : in unbounded_String;   Level : in Verbosity := Debug)
   is
   begin
      log (to_String (the_Message), Level);
   end log;




   ---------
   --  Other
   ---------

   function portable_new_line_Token return String
   is
      the_Token     :          unbounded_String;
      temp_fileName : constant String          := "portable_new_line_Token.tmp";   -- tbd: delete temporary file when done.
   begin
      declare
         the_File : ada.text_IO.File_type;
      begin
         create   (the_File, out_File, temp_fileName);
         new_Line (the_File);
         close    (the_File);
      end;

      declare
         use ada.streams.stream_io;
         the_File    : ada.streams.stream_io.File_type;
         the_Stream  : ada.streams.stream_io.Stream_access;
      begin
         open (the_File, in_File, temp_fileName);
         the_Stream := Stream (the_File);

         while not end_of_File (the_File)
         loop
            append (the_Token, Character'Input (the_Stream));
         end loop;

         close (the_File);
      end;

      return to_String (the_Token);
   end portable_new_line_Token;



   procedure replace_All (Self       : in out ada.strings.unbounded.unbounded_String;
                          Token      : in String;
                          with_Token : in String)
   is
      token_Index : Natural := Index (Self, Token);
   begin
      if Token = with_Token then
         return;
      end if;

      while token_Index /= 0
      loop
         replace_Slice (Self,   token_Index,  token_Index + Token'Length - 1,  with_Token);
         token_Index := Index (Self,  Token,  from => token_Index + with_Token'Length);
      end loop;
   end replace_All;



   function class_Prefix_in (Self : in     unbounded_String) return unbounded_String
   is
      the_Index : constant Natural := Index (Self, "::", backward);
   begin
      if the_Index = 0
      then
         return null_unbounded_String;
      else
         return unbounded_Slice (Self,  1, the_Index - 1);
      end if;
   end class_Prefix_in;



   function identifier_Suffix_in (Self : in     unbounded_String) return unbounded_String
   is
      the_Index : constant Natural := Index (Self, "::", backward);
   begin
      if the_Index = 0
      then
         return Self;
      else
         return unbounded_Slice (Self,   the_Index + 2,  Length (Self));
      end if;
   end identifier_Suffix_in;




   function Text_before_first_dot (Self : in unbounded_String) return unbounded_String
   is
      first_dot_Index : constant Natural := Index (Self, ".");
   begin
      --  log (Self &  "    start: " & integer'image (self'First) & "    Last: " & integer'image (Index (Self, ".", backward) - 1));

      if first_dot_Index = 0
      then
         return Self;
      else
         return unbounded_Slice (Self,  1, first_dot_Index - 1);
      end if;
   end Text_before_first_dot;



   function Text_after_first_dot (Self : in unbounded_String) return unbounded_String
   is
      first_dot_Index : constant Natural := Index (Self, ".");
   begin
      --  log (Self &  "    start: " & integer'image (self'First) & "    Last: " & integer'image (Index (Self, ".", backward) - 1));

      if first_dot_Index = 0
      then
         return Self;
      else
         return unbounded_Slice (Self,  first_dot_Index + 1,  Length (Self));
      end if;
   end Text_after_first_dot;



   function Text_before_last_dot (Self : in String) return String
   is
      last_dot_Index : constant Natural := Index (Self, ".", backward);
   begin
      --  log (Self &  "    start: " & integer'image (self'First) & "    Last: " & integer'image (Index (Self, ".", backward) - 1));

      if last_dot_Index = 0
      then
         return "";
      else
         return Self (self'First .. last_dot_Index - 1);
      end if;

   end Text_before_last_dot;



   function Text_after_last_dot (Self : in String) return String
   is
      last_dot_Index : constant Natural := Index (Self,  ".", backward);
   begin
      if last_dot_Index = 0
      then
         return "";
      else
         return Self (last_dot_Index + 1  ..  self'Last);
      end if;
   end Text_after_last_dot;



   procedure strip_Namespaces (Self : in out unbounded_String)
   is
      namespace_Index : constant Natural := Index (Self, "::", backward);
   begin
      if namespace_Index = 0
      then
         return;
      end if;

      replace_Slice (Self,   1,  namespace_Index + 1,  "");
   end strip_Namespaces;



   procedure strip_const_Qualifiers (Self : in out unbounded_String)
   is
   begin
      replace_All (Self, "q(const).", "");
   end strip_const_Qualifiers;



   function to_Int (Self : in String) return discrete.Integer
   is
      Result      : discrete.Integer := to_Integer;
      is_Negative :          Boolean := False;
      hex_Index   : constant Natural := Index (Self, "0x");
   begin
--        log ("to_Int - Self: '" & Self & "'");

      if hex_Index = 0
      then
         for Each in self'Range
         loop
            case Self (Each)
            is
               when '-'        => is_Negative := True;
               when ' '        => null;                   -- Ignore spaces.
               when '('        => null;
               when ')'        => exit;
               when '0' .. '9' => Result := Result * to_Integer (10)  +  to_Integer (Long_Long_Integer'Value (Self (Each .. Each)));
               when others     => log ("bad numeric character: '" & Self (Each) & "'   '" & Self & "'");
                  raise Constraint_Error;
            end case;
         end loop;

--           log ("result: " & Image (result));

      else -- is a hex number
         --  for Each in self'First + 2 .. self'Last loop
         for Each in hex_Index + 2 .. self'Last
         loop
--              log ("hex ~ result: " & huge_Integer'image (to_huge_Integer (result)) & "    curr Char: '" & Self (Each) & "'");

            case Self (Each)
            is
               when '-'        => is_Negative := True;
               when ' '        => null;                   -- ignore spaces
               when '0' .. '9' => Result := Result * to_Integer (16) + to_Integer (Long_Long_Integer'Value (Self (Each .. Each)));
               when 'A' .. 'F' => Result := Result * to_Integer (16) + to_Integer (Character'Pos (Self (Each)) - Character'Pos ('A') + 10);
               when 'a' .. 'f' => Result := Result * to_Integer (16) + to_Integer (Character'Pos (Self (Each)) - Character'Pos ('a') + 10);
               when ')'        => exit;
               when others     => log ("bad hex character: '" & Self (Each) & "'   '" & Self & "'");
                  raise Constraint_Error;
            end case;
         end loop;
--           log ("hex ~ result: " & huge_Integer'image (to_huge_Integer (result)));
      end if;


      if is_Negative
      then   return -Result;
      else   return  Result;
      end if;
   end to_Int;



   function to_Int (Self : in unbounded_String)      return GMP.discrete.Integer
   is
   begin
      return to_Int (to_String (Self));
   end to_Int;



   function to_Lower (Self : in unbounded_String) return unbounded_String
   is
   begin
      return to_unbounded_String (to_Lower (to_String (Self)));
   end to_Lower;



   function Image (Self : in Integer) return String
   is
   begin
      return Trim (Integer'Image (Self), Left);
   end Image;



   function is_an_ada_Standard_Package_Identifier (Self : in unbounded_String) return Boolean
   is
      lowered_Self : constant String := to_Lower (to_String (Self));
   begin
      return    lowered_Self = "boolean"
        or else lowered_Self = "integer"
        or else lowered_Self = "natural"
        or else lowered_Self = "positive"
        or else lowered_Self = "float"
        or else lowered_Self = "character"
        or else lowered_Self = "wide_character"
        or else lowered_Self = "wide_wide_character"
        or else lowered_Self = "ascii"
        or else lowered_Self = "string"
        or else lowered_Self = "wide_string"
        or else lowered_Self = "wide_wide_string"
        or else lowered_Self = "duration"
        or else lowered_Self = "constraint_error"
        or else lowered_Self = "program_error"
        or else lowered_Self = "storage_error"
        or else lowered_Self = "tasking_error";
   end is_an_ada_Standard_Package_Identifier;



   function is_reserved_Word (Self : unbounded_String) return Boolean
   is
      lowcase_Word : constant String := to_Lower (to_String (Self));
   begin

      return    lowcase_Word = "abort"
        or else lowcase_Word = "abs"
        or else lowcase_Word = "abstract"
        or else lowcase_Word = "accept"
        or else lowcase_Word = "access"
        or else lowcase_Word = "aliased"
        or else lowcase_Word = "all"
        or else lowcase_Word = "and"
        or else lowcase_Word = "array"
        or else lowcase_Word = "at"
        or else lowcase_Word = "begin"
        or else lowcase_Word = "body"
        or else lowcase_Word = "case"
        or else lowcase_Word = "constant"
        or else lowcase_Word = "declare"
        or else lowcase_Word = "delay"
        or else lowcase_Word = "delta"
        or else lowcase_Word = "digits"
        or else lowcase_Word = "do"
        or else lowcase_Word = "else"
        or else lowcase_Word = "elsif"
        or else lowcase_Word = "end"
        or else lowcase_Word = "entry"
        or else lowcase_Word = "exception"
        or else lowcase_Word = "exit"
        or else lowcase_Word = "for"
        or else lowcase_Word = "function"
        or else lowcase_Word = "generic"
        or else lowcase_Word = "goto"
        or else lowcase_Word = "if"
        or else lowcase_Word = "in"
        or else lowcase_Word = "interface"
        or else lowcase_Word = "is"
        or else lowcase_Word = "limited"
        or else lowcase_Word = "loop"
        or else lowcase_Word = "mod"
        or else lowcase_Word = "new"
        or else lowcase_Word = "not"
        or else lowcase_Word = "null"
        or else lowcase_Word = "of"
        or else lowcase_Word = "or"
        or else lowcase_Word = "others"
        or else lowcase_Word = "out"
        or else lowcase_Word = "overriding"
        or else lowcase_Word = "package"
        or else lowcase_Word = "pragma"
        or else lowcase_Word = "private"
        or else lowcase_Word = "procedure"
        or else lowcase_Word = "protected"
        or else lowcase_Word = "raise"
        or else lowcase_Word = "range"
        or else lowcase_Word = "record"
        or else lowcase_Word = "rem"
        or else lowcase_Word = "renames"
        or else lowcase_Word = "requeue"
        or else lowcase_Word = "return"
        or else lowcase_Word = "reverse"
        or else lowcase_Word = "select"
        or else lowcase_Word = "separate"
        or else lowcase_Word = "subtype"
        or else lowcase_Word = "synchronized"
        or else lowcase_Word = "tagged"
        or else lowcase_Word = "task"
        or else lowcase_Word = "terminate"
        or else lowcase_Word = "then"
        or else lowcase_Word = "type"
        or else lowcase_Word = "until"
        or else lowcase_Word = "use"
        or else lowcase_Word = "when"
        or else lowcase_Word = "while"
        or else lowcase_Word = "with"
        or else lowcase_Word = "xor";
   end is_reserved_Word;




   function to_ada_Identifier (Self : in unbounded_String) return unbounded_String
   is
      the_Identifier : unbounded_String := Self;
   begin
--      log ("'to_ada_Identifier' ~   the_Identifier: '" & the_Identifier & "'");

      strip_Namespaces (the_Identifier);

--      log ("'to_ada_Identifier' ~   the_Identifier (rid namespace): '" & the_Identifier & "'");

      if is_reserved_Word (the_Identifier)
      then
         the_Identifier := "the_" & the_Identifier;
      end if;

      declare
         Start : Natural;
      begin
         loop
            Start := Index (the_Identifier,  "__");
            exit when Start = 0;                                                 -- loop repeatedly til there are no more '__' are left
            replace_Slice (the_Identifier,  Start,  Start + 1,   "_a_");
         end loop;
      end;

      if Head (the_Identifier, 1) = "_"
      then
         insert (the_Identifier,  1, "a");
      end if;

      if Tail (the_Identifier, 1) = "_"
      then
         append (the_Identifier,  "a");
      end if;

      if Tail (the_Identifier, 3) = "*[]"
      then
         replace_Slice (the_Identifier,  Length (the_Identifier) - 2,
                                         Length (the_Identifier),  "_Pointer_array");
      end if;

      if Tail (the_Identifier, 2) = "[]"
      then
         replace_Slice (the_Identifier,  Length (the_Identifier) - 1,
                                         Length (the_Identifier),  "_array");
      end if;

      if Tail (the_Identifier, 1) = "*"
      then
         replace_Slice (the_Identifier,  Length (the_Identifier),
                                         Length (the_Identifier),  "_pointer");
      end if;

      return the_Identifier;
   end to_ada_Identifier;


end ada_Utility;
