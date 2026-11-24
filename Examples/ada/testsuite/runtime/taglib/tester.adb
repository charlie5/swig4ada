with
     taglib.Binding,
     taglib.String,
     taglib.StringList,
     taglib.StringList_base,
     taglib.PropertyMap,
     taglib.SimplePropertyMap,
     taglib.FileRef,
     taglib.FileTypeResolver,
     taglib.Tag,
     taglib.AudioProperties,
     taglib.File,

     Counting,

     swig.std_Strings,
     interfaces.C.Strings,

     Checks;


procedure Tester
--
--  A binding to TagLib, made from its own headers: a library of classes, most of which hold the pointer to their
--  implementation which C++ calls a 'pimpl'. A wave file is written, opened by a handle which is a value, read,
--  tagged and saved, and opened again, with a resolver of the types of files which is declared in Ada.
--
is
   use swig.std_Strings,
       interfaces.C,
       interfaces.C.Strings,
       Checks;

   use type swig.bool,
            taglib.Tag.Pointer,
            taglib.AudioProperties.Pointer,
            taglib.File.Pointer,
            taglib.StringList.Pointer,
            taglib.FileTypeResolver.Pointer;

   package Text renames taglib.String;


   function "+" (the_String : in Text.Item) return String
   is
      Bytes : aliased std_String;
   begin
      Text.to8Bit (the_String, Bytes'unchecked_Access);

      return Result : constant String := to_Ada (Bytes)
      do
         destruct (Bytes);
      end return;
   end "+";


   the_Resolver : aliased Counting.Item;
   Wave         : aliased std_String;
begin
   strings :
   declare
      Hello_Text : chars_ptr          := new_String ("Hello");
      Hello      : aliased Text.Item  := Text.construct (Hello_Text);
      Empty      : aliased Text.Item  := Text.construct;
      Upper      : aliased Text.Item;
      Number     : aliased Text.Item;
   begin
      free (Hello_Text);     -- The string of TagLib has a copy.

      check (Text.length (Hello) = 5 and +Hello = "Hello",                 "a string is made from a string of C, and has its characters");
      check (Text.isEmpty (Empty) /= 0 and Text.isEmpty (Hello) = 0,       "a string which Ada declares is constructed, and is empty");

      Text.upper (Hello, Upper'unchecked_Access);
      check (+Upper = "HELLO" and +Hello = "Hello",                        "a function returns a string, which replaces an object of the caller");

      Text.number (42, Number'unchecked_Access);
      check (+Number = "42" and Text.toInt (Number) = 42,                  "a static function returns one");

      Text.destruct (Number);
      Text.destruct (Upper);
      Text.destruct (Empty);
      Text.destruct (Hello);
   end strings;

   lists :
   declare
      One_Text   : chars_ptr                := new_String ("one");
      Two_Text   : chars_ptr                := new_String ("two");
      Comma_Text : chars_ptr                := new_String (", ");
      One        : aliased Text.Item        := Text.construct (One_Text);
      Two        : aliased Text.Item        := Text.construct (Two_Text);
      Comma      : aliased Text.Item        := Text.construct (Comma_Text);
      Joined     : aliased Text.Item;
      the_List   : aliased taglib.StringList.Item := taglib.StringList.construct;
      Same       :         taglib.StringList.Pointer;
   begin
      free (One_Text);
      free (Two_Text);
      free (Comma_Text);

      Same := taglib.StringList.append (the_List, One'unchecked_Access);
      check (Same = the_List'unchecked_Access,                             "a function returns a reference to the object which it is called on");
      Same := taglib.StringList.append (the_List, Two'unchecked_Access);

      check (taglib.StringList_base.size (taglib.StringList.as_StringList_base (the_List).all) = 2,
                                                                           "a list of strings is reached as the template instance which is its base");
      taglib.StringList.toString (the_List, Comma'unchecked_Access, Joined'unchecked_Access);
      check (+Joined = "one, two",                                         "and its strings are joined");

      taglib.StringList.destruct (the_List);
      Text.destruct (Joined);
      Text.destruct (Comma);
      Text.destruct (Two);
      Text.destruct (One);
   end lists;

   taglib.Binding.scratch_wave (44_100, 2, 1, Wave'unchecked_Access);
   check (to_Ada (Wave) /= "",                                             "a wave file is written: " & to_Ada (Wave));

   reading :
   declare
      Name       : chars_ptr                       := new_String (to_Ada (Wave));
      the_File   : aliased  taglib.FileRef.Item    := taglib.FileRef.construct (Name);
      Properties : constant taglib.AudioProperties.Pointer := taglib.FileRef.audioProperties (the_File);
   begin
      check (taglib.FileRef.isNull (the_File) = 0,                         "it is opened by a handle which Ada declares");
      check (taglib.FileRef.file (the_File) /= null
             and then taglib.FileRef.file (the_File).isValid /= 0,         "which holds a file that C++ made, of a class which TagLib chose");
      check (Properties /= null,                                           "and which has its audio properties");
      check (Properties.sampleRate = 44_100 and Properties.channels = 2,   "which are read through the vtable: the rate and the channels");
      check (Properties.lengthInMilliseconds = 1_000,                      "and the length");

      taglib.FileRef.destruct (the_File);
      free (Name);
   end reading;

   tagging :
   declare
      Name         : chars_ptr                    := new_String (to_Ada (Wave));
      the_File     : aliased taglib.FileRef.Item  := taglib.FileRef.construct (Name);
      the_Tag      : constant taglib.Tag.Pointer  := taglib.FileRef.tag (the_File);
      Title_Text   : chars_ptr                    := new_String ("Silence");
      Artist_Text  : chars_ptr                    := new_String ("swig4ada");
      Title        : aliased Text.Item            := Text.construct (Title_Text);
      Artist       : aliased Text.Item            := Text.construct (Artist_Text);
      Properties   : aliased taglib.PropertyMap.Item;
      Key_Text     : chars_ptr                    := new_String ("ARTIST");
      Key          : aliased Text.Item            := Text.construct (Key_Text);
   begin
      free (Title_Text);
      free (Artist_Text);
      free (Key_Text);

      check (the_Tag /= null and then the_Tag.isEmpty /= 0,                "a file has a tag, which is empty");

      the_Tag.setTitle  (Title 'unchecked_Access);     -- Pure virtual functions, called through the vtable.
      the_Tag.setArtist (Artist'unchecked_Access);
      the_Tag.setYear   (2026);
      the_Tag.setTrack  (7);
      check (the_Tag.isEmpty = 0 and the_Tag.year = 2026,                  "pure virtual functions of the tag are called on the object which C++ made");

      taglib.FileRef.properties (the_File, Properties'unchecked_Access);
      check (taglib.PropertyMap.contains (Properties, Key'unchecked_Access) /= 0,
                                                                           "its properties are returned as a map, which has the artist");
      check (taglib.SimplePropertyMap.size (taglib.PropertyMap.as_SimplePropertyMap (Properties).all) = 4,
                                                                           "and the title, the year and the track");

      check (taglib.FileRef.save (the_File) /= 0,                          "the file is saved");

      taglib.PropertyMap.destruct (Properties);
      Text.destruct (Key);
      Text.destruct (Artist);
      Text.destruct (Title);
      taglib.FileRef.destruct (the_File);
      free (Name);
   end tagging;

   reading_again :
   declare
      Previous : constant taglib.FileTypeResolver.Pointer := taglib.FileRef.addFileTypeResolver (the_Resolver'unchecked_Access);
      Name     : chars_ptr                    := new_String (to_Ada (Wave));
      the_File : aliased taglib.FileRef.Item  := taglib.FileRef.construct (Name);
      the_Tag  : constant taglib.Tag.Pointer  := taglib.FileRef.tag (the_File);
      Title    : aliased Text.Item;
      Artist   : aliased Text.Item;
   begin
      check (Previous = the_Resolver'unchecked_Access,                     "a resolver which is declared in Ada is given to TagLib");
      check (the_Resolver.Calls = 1,                                       "which calls it when a file is opened");
      check (taglib.FileRef.isNull (the_File) = 0,                         "and opens the file itself, as the resolver made none");

      the_Tag.title  (Title 'unchecked_Access);     -- Virtual functions which return a string, called through their wrappers.
      the_Tag.artist (Artist'unchecked_Access);
      check (+Title = "Silence" and +Artist = "swig4ada",                  "the tag which was saved is read again");
      check (the_Tag.year = 2026 and the_Tag.track = 7,                    "with its year and its track");

      taglib.FileRef.clearFileTypeResolvers;

      Text.destruct (Artist);
      Text.destruct (Title);
      taglib.FileRef.destruct (the_File);
      free (Name);
   end reading_again;

   taglib.Binding.remove_file (Wave'unchecked_Access);
   destruct (Wave);

   finish;
end Tester;
