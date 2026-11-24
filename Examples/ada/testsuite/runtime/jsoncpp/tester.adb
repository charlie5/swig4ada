with
     jsoncpp.Binding,
     jsoncpp.Value,
     jsoncpp.CharReaderBuilder,
     jsoncpp.CharReader,
     jsoncpp.StreamWriterBuilder,
     jsoncpp.FastWriter,
     jsoncpp.Reader,
     jsoncpp.ReaderErrors,
     jsoncpp.StructuredError,

     swig.std_Strings,
     interfaces.C.Strings,
     System.Storage_Elements,
     ada.unchecked_Conversion,
     ada.Strings.fixed,

     Checks;


procedure Tester
--
--  A binding to jsoncpp, made from its own headers: a class library which nobody wrote as a test. A value, whose
--  private members are of classes nested in it, is declared in Ada; documents are parsed by a reader which a builder
--  makes, and written out by writers.
--
is
   use jsoncpp,
       jsoncpp.Binding,
       swig.std_Strings,
       Checks;

   use type interfaces.C.int,
            interfaces.C.unsigned,
            interfaces.C.double,
            interfaces.C.size_t,
            interfaces.C.ptrdiff_t,
            swig.bool,
            System.Storage_Elements.Storage_Offset;

   subtype chars_ptr is interfaces.C.Strings.chars_ptr;     -- jsoncpp has an 'Int' and a 'char_array' of its own.

   function to_chars_ptr is new ada.unchecked_Conversion (System.Address, chars_ptr);
   function new_String   (Text : in String) return chars_ptr renames interfaces.C.Strings.new_String;
   procedure free        (Item : in out chars_ptr)          renames interfaces.C.Strings.free;

   Text : aliased jsoncpp.String;

begin
   values :
   declare
      Answer : aliased Value.Item := Value.construct (interfaces.C.int'(42));
      Pi     : aliased Value.Item := Value.construct (interfaces.C.double'(3.25));
      Name   :         chars_ptr  := new_String ("jsoncpp");
      Word   : aliased Value.Item := Value.construct (Name);
      List   : aliased Value.Item := Value.construct (arrayValue);
      Added  :         Value.Pointer;
   begin
      check (Value.Item'Size / 8 = size_of_value,                "a value has the size of its class, its private members of nested classes among them");
      check (Value.isInt (Answer) /= 0,                          "a value made from an integer");
      check (Value.asInt (Answer) = 42,                          "gives it back");
      check (Value.asDouble (Pi) = 3.25,                         "and one made from a real number");

      Value.asString (Word, Text'unchecked_Access);
      check (to_Ada (Text) = "jsoncpp",                          "and one made from a string, which is returned by value");

      Added := Value.append (List, Answer'unchecked_Access);
      Added := Value.append (List, Word'unchecked_Access);
      check (Value.size (List) = 2,                              "values are appended to an array");
      check (Value.isString (Added.all) /= 0,                    "which gives its own copy of each");

      free (Name);
      Value.destruct (List);
      Value.destruct (Word);
      Value.destruct (Pi);
      Value.destruct (Answer);
   end values;

   parsing_and_writing :
   declare
      Builder    : aliased CharReaderBuilder.Item;
      the_Reader : constant CharReader.Pointer := CharReaderBuilder.newCharReader (Builder'unchecked_Access);
      Document   : aliased interfaces.C.char_array := interfaces.C.to_C ("{""name"": ""ada"", ""list"": [1, 2, 3], ""deep"": {""yes"": true}}",
                                                        Append_Nul => False);
      Root       : aliased Value.Item;
      Member     : aliased Value.Item;
      Missing    : aliased Value.Item;
      Errors     : aliased jsoncpp.String;
      List_Key   :         chars_ptr := new_String ("list");
      Name_Key   :         chars_ptr := new_String ("name");
      Styled     : aliased StreamWriterBuilder.Item;
      Fast       : aliased FastWriter.Item;
   begin
      check (CharReader.parse (the_Reader,
                               to_chars_ptr (Document (Document'First)'Address),
                               to_chars_ptr (Document (Document'Last)'Address + 1),
                               Root'unchecked_Access,
                               Errors'unchecked_Access) /= 0,    "a document is parsed, by a reader which a builder makes, into a value which Ada declared");
      check (Value.isObject (Root) /= 0,                         "an object");
      check (Value.size (Root) = 3,                              "of three members");
      check (Value.isMember (Root, List_Key) /= 0,               "one of which is found by its name");

      Value.get (Root, List_Key, Missing'unchecked_Access, Member'unchecked_Access);
      check (Value.isArray (Member) /= 0,                        "and given by value");
      check (Value.size (Member) = 3,                            "with its elements");

      Value.get (Root, Name_Key, Missing'unchecked_Access, Member'unchecked_Access);
      Value.asString (Member, Text'unchecked_Access);
      check (to_Ada (Text) = "ada",                              "a member which is a string");

      writeString (Styled'unchecked_Access, Root'unchecked_Access, Text'unchecked_Access);
      check (ada.Strings.fixed.Index (to_Ada (Text), """name"" : ""ada""") /= 0,
             "the document is written out by a writer which a builder makes");

      FastWriter.write (Fast, Root'unchecked_Access, Text'unchecked_Access);
      check (to_Ada (Text) = "{""deep"":{""yes"":true},""list"":[1,2,3],""name"":""ada""}" & ASCII.LF,
             "and by a fast writer: " & to_Ada (Text));

      free (Name_Key);
      free (List_Key);
      CharReader.destruct (the_Reader.all);     -- Which C++ made, and frees.
      FastWriter.destruct_0 (Fast);
      StreamWriterBuilder.destruct_0 (Styled);
      CharReaderBuilder.destruct_0 (Builder);
      destruct (Errors);
      Value.destruct (Missing);
      Value.destruct (Member);
      Value.destruct (Root);
   end parsing_and_writing;


   reading_with_a_Reader :
   declare
      --  A reader which Ada declares, whose stack of values and whose errors are containers of the library
      --  ('std::stack' and 'std::deque'), and which gives its errors as a vector, by value.
      --
      the_Reader : aliased Reader.Item := Reader.construct;
      Good       : aliased interfaces.C.char_array := interfaces.C.to_C ("[1, [2, [3]], {""four"": 4}]", Append_Nul => False);
      Bad        : aliased interfaces.C.char_array := interfaces.C.to_C ("{""one"": 1,, }",               Append_Nul => False);
      Root       : aliased Value.Item;
      Errors     : aliased ReaderErrors.Item;
      Messages   : aliased jsoncpp.String;
   begin
      check (Reader.Item'Size / 8 = size_of_reader,              "a reader has the size of its class, its stack and its errors among its members");

      check (Reader.parse (the_Reader,
                           to_chars_ptr (Good (Good'First)'Address),
                           to_chars_ptr (Good (Good'Last)'Address + 1),
                           Root'unchecked_Access) /= 0,          "a document is parsed by a reader which Ada declared");
      check (Value.size (Root) = 3,                              "into an array of three elements");
      check (Reader.good (the_Reader) /= 0,                      "with no error");

      check (Reader.parse (the_Reader,
                           to_chars_ptr (Bad (Bad'First)'Address),
                           to_chars_ptr (Bad (Bad'Last)'Address + 1),
                           Root'unchecked_Access) = 0,           "a document which is not well formed is refused");
      check (Reader.good (the_Reader) = 0,                       "and the reader has an error");

      Reader.getStructuredErrors (the_Reader, Errors'unchecked_Access);
      check (ReaderErrors.size (Errors) >= 1,                    "which it gives in a vector, returned by value");
      check (ReaderErrors.get (Errors, 0).offset_start > 0,      "with the place of the error");
      check (to_Ada (ReaderErrors.get (Errors, 0).message) /= "", "and its message: " & to_Ada (ReaderErrors.get (Errors, 0).message));

      Reader.getFormattedErrorMessages (the_Reader, Messages'unchecked_Access);
      check (ada.Strings.fixed.Index (to_Ada (Messages), "Line 1") /= 0,
             "and as text, returned by value");

      destruct (Messages);
      ReaderErrors.destruct_0 (Errors);
      Value.destruct (Root);
      Reader.destruct_0 (the_Reader);
   end reading_with_a_Reader;

   destruct (Text);
   finish;
end Tester;
