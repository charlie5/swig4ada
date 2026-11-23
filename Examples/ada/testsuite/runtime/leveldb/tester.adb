with
     leveldb.Binding,
     leveldb.Slice,
     leveldb.Status,
     leveldb.Options,
     leveldb.ReadOptions,
     leveldb.WriteOptions,
     leveldb.WriteBatch,
     leveldb.Iterator,
     leveldb.Comparator,
     leveldb.DB,

     Reversed,

     swig.std_Strings,
     interfaces.C.Strings,
     ada.Strings.unbounded,

     Checks;


procedure Tester
--
--  A binding to LevelDB, made from its own headers: a class library which nobody wrote as a test. A database
--  is made in a folder of its own, written, read and walked, and then walked in the order of a comparator
--  which is declared in Ada.
--
is
   use leveldb,
       leveldb.Binding,
       swig.std_Strings,
       interfaces.C,
       interfaces.C.Strings,
       Checks;

   use type swig.bool,
            DB.Pointer,
            Iterator.Pointer;

   function "+" (the_Slice : in Slice.Item) return String
   is
      Text : aliased std_String;
   begin
      Slice.ToString (the_Slice, Text'unchecked_Access);

      return Result : constant String := to_Ada (Text)
      do
         destruct (Text);
      end return;
   end "+";


   function Text_of (the_Status : in Status.Item) return String
   is
      Text : aliased std_String;
   begin
      Status.ToString (the_Status, Text'unchecked_Access);

      return Result : constant String := to_Ada (Text)
      do
         destruct (Text);
      end return;
   end Text_of;


   function Keys_of (the_DB : in DB.Pointer) return String
   --
   --  The keys of a database, in the order in which an iterator gives them.
   --
   is
      the_Options : aliased  ReadOptions.Item := ReadOptions.construct;
      Cursor      : constant Iterator.Pointer := the_DB.NewIterator (the_Options'unchecked_Access);
      Keys        :          ada.Strings.unbounded.unbounded_String;
   begin
      Cursor.SeekToFirst;

      while Cursor.Valid /= 0
      loop
         ada.Strings.unbounded.append (Keys, +Cursor.key & " ");
         Cursor.Next;
      end loop;

      Iterator.destruct (Cursor.all);     -- The iterator was made by C++, with 'new'.
      return ada.Strings.unbounded.to_String (Keys);
   end Keys_of;


   Folder : aliased std_String;
begin
   slices :
   declare
      Hello  : chars_ptr := new_String ("hello");
      Help   : chars_ptr := new_String ("help");
      Hel    : chars_ptr := new_String ("hel");

      a      : aliased Slice.Item := Slice.construct (Hello);
      b      : aliased Slice.Item := Slice.construct (Help);
      Prefix : aliased Slice.Item := Slice.construct (Hel);
      Part   : aliased Slice.Item := Slice.construct (Hello, 2);
   begin
      check (Slice.size (a) = 5 and Slice.empty (a) = 0,              "a slice is made from a string of C");
      check (+a = "hello",                                            "and gives its characters as a string of C++");
      check (Slice.size (Part) = 2 and +Part = "he",                  "one is made from a part of a string");
      check (Slice.compare (a, b'unchecked_Access) < 0,               "slices are compared");
      check (Slice.starts_with (a, Prefix'unchecked_Access) /= 0,     "and one begins with another");

      Slice.remove_prefix (a, 3);
      check (+a = "lo",                                               "a function changes the slice which it is called on");

      free (Hello);
      free (Help);
      free (Hel);
   end slices;

   statuses :
   declare
      Reason : chars_ptr := new_String ("no such key");
      Detail : aliased Slice.Item := Slice.construct (Reason);
      Empty  : aliased Slice.Item := Slice.construct;
      Good   : aliased Status.Item;
      Bad    : aliased Status.Item;
   begin
      check (Status.ok (Good) /= 0,                                   "a status which Ada declares is constructed, and is that of success");

      Status.NotFound (Detail'unchecked_Access, Empty'unchecked_Access, Bad'unchecked_Access);
      check (Status.ok (Bad) = 0 and Status.IsNotFound (Bad) /= 0,    "a function returns a status, which replaces an object of the caller");
      check (Text_of (Bad) = "NotFound: no such key",                 "and which holds its message");

      Status.destruct (Bad);
      Status.destruct (Good);
      free (Reason);
   end statuses;

   scratch_folder (Folder'unchecked_Access);

   a_database :
   declare
      the_Options : aliased Options.Item      := Options.construct;
      Writing     : aliased WriteOptions.Item := WriteOptions.construct;
      Reading     : aliased ReadOptions.Item  := ReadOptions.construct;
      the_DB      : aliased DB.Pointer;
      Outcome     : aliased Status.Item;
      Found       : aliased std_String;

      procedure put (Key : in String;   Value : in String)
      is
         the_Key   : chars_ptr := new_String (Key);
         the_Value : chars_ptr := new_String (Value);
         k         : aliased Slice.Item := Slice.construct (the_Key);
         v         : aliased Slice.Item := Slice.construct (the_Value);
      begin
         the_DB.Put (Writing'unchecked_Access, k'unchecked_Access, v'unchecked_Access, Outcome'unchecked_Access);
         free (the_Key);
         free (the_Value);
      end put;

      function get (Key : in String) return String
      is
         the_Key : chars_ptr := new_String (Key);
         k       : aliased Slice.Item := Slice.construct (the_Key);
      begin
         the_DB.Get (Reading'unchecked_Access, k'unchecked_Access, Found'unchecked_Access, Outcome'unchecked_Access);
         free (the_Key);

         return (if Status.ok (Outcome) /= 0 then to_Ada (Found) else "<" & Text_of (Outcome) & ">");
      end get;

   begin
      check (the_Options.create_if_missing = 0 and the_Options.max_open_files = 1000,   "the options have the values which their constructor gives them");
      check (Writing.sync = 0 and Reading.fill_cache /= 0,            "as have those for writing and reading");

      the_Options.create_if_missing := 1;

      DB.Open (the_Options'unchecked_Access, Folder'unchecked_Access, the_DB'unchecked_Access, Outcome'unchecked_Access);
      check (Status.ok (Outcome) /= 0 and the_DB /= null,             "a database is opened: " & Text_of (Outcome));

      put ("cherry", "red");
      check (Status.ok (Outcome) /= 0,                                "a pure virtual function of the database is called, through the object which C++ made");
      put ("apple",  "green");
      put ("banana", "yellow");

      check (get ("apple") = "green" and get ("cherry") = "red",      "what was written is read");
      check (get ("durian") = "<NotFound: >",                         "and what was not is not found");

      a_write_Batch :
      declare
         the_Batch : aliased WriteBatch.Item;
         Apple     : chars_ptr := new_String ("apple");
         Elder     : chars_ptr := new_String ("elderberry");
         Black     : chars_ptr := new_String ("black");
         k1        : aliased Slice.Item := Slice.construct (Apple);
         k2        : aliased Slice.Item := Slice.construct (Elder);
         v2        : aliased Slice.Item := Slice.construct (Black);
      begin
         WriteBatch.Delete (the_Batch, k1'unchecked_Access);
         WriteBatch.Put    (the_Batch, k2'unchecked_Access, v2'unchecked_Access);

         the_DB.Write (Writing'unchecked_Access, the_Batch'unchecked_Access, Outcome'unchecked_Access);
         check (Status.ok (Outcome) /= 0,                             "a batch of changes is written");
         check (get ("apple") = "<NotFound: >" and get ("elderberry") = "black",   "each of which is made");

         WriteBatch.destruct (the_Batch);
         free (Apple);
         free (Elder);
         free (Black);
      end a_write_Batch;

      check (Keys_of (the_DB) = "banana cherry elderberry ",          "an iterator, which C++ makes, gives the keys in their order");

      DB.destruct (the_DB.all);     -- Closes the database, which was made by C++ with 'new'.

      DestroyDB (Folder'unchecked_Access, the_Options'unchecked_Access, Outcome'unchecked_Access);
      check (Status.ok (Outcome) /= 0,                                "the database is removed");

      destruct (Found);
      Status.destruct (Outcome);
   end a_database;

   a_comparator_declared_in_Ada :
   declare
      the_Order   : aliased Reversed.Item;     -- Its abstract parent is constructed by C++.
      the_Options : aliased Options.Item      := Options.construct;
      Writing     : aliased WriteOptions.Item := WriteOptions.construct;
      the_DB      : aliased DB.Pointer;
      Outcome     : aliased Status.Item;
   begin
      the_Options.create_if_missing := 1;
      the_Options.comparator        := Comparator.Item (the_Order)'unchecked_Access;

      DB.Open (the_Options'unchecked_Access, Folder'unchecked_Access, the_DB'unchecked_Access, Outcome'unchecked_Access);
      check (Status.ok (Outcome) /= 0 and the_DB /= null,             "a database is opened with a comparator which is declared in Ada: " & Text_of (Outcome));

      for Each of String'("bdac")
      loop
         declare
            the_Key : chars_ptr := new_String ((1 => Each));
            k       : aliased Slice.Item := Slice.construct (the_Key);
         begin
            the_DB.Put (Writing'unchecked_Access, k'unchecked_Access, k'unchecked_Access, Outcome'unchecked_Access);
            free (the_Key);
         end;
      end loop;

      check (Keys_of (the_DB) = "d c b a ",                           "whose order the iterator follows");
      check (the_Order.Calls > 0,                                     "as LevelDB has called the function of Ada to compare");

      DB.destruct (the_DB.all);

      DestroyDB (Folder'unchecked_Access, the_Options'unchecked_Access, Outcome'unchecked_Access);
      Status.destruct (Outcome);
      Comparator.destruct_0 (Comparator.Item (the_Order));
   end a_comparator_declared_in_Ada;

   remove_folder (Folder'unchecked_Access);
   destruct (Folder);

   finish;
end Tester;
