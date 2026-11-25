with
     yamlcpp.Binding,
     yamlcpp.Node,
     yamlcpp.Nodes,
     yamlcpp.Mark,
     yamlcpp.Emitter,
     yamlcpp.const_value_iterator,
     yamlcpp.iterator_value,
     ada.Strings.unbounded,

     swig.std_Strings,
     swig.Exceptions,
     interfaces.C.Strings,
     ada.Strings.fixed,

     Checks;


procedure Tester
--
--  A binding to yaml-cpp, made from its own headers: a node, which holds a shared pointer to the memory of its document,
--  is loaded from text and written out again, an emitter writes a scalar, and a document which is not well formed is
--  refused by an exception of the library's, which is derived from 'std::runtime_error'.
--
is
   use yamlcpp,
       yamlcpp.Binding,
       swig.std_Strings,
       Checks;

   use type interfaces.C.int,
            interfaces.C.double,
            interfaces.C.size_t,
            swig.bool,
            Emitter.Pointer,
            Node.Pointer;

   subtype chars_ptr is interfaces.C.Strings.chars_ptr;

   function new_String (Text : in String)    return chars_ptr renames interfaces.C.Strings.new_String;
   procedure free      (Item : in out chars_ptr)          renames interfaces.C.Strings.free;
   function Value      (Item : in chars_ptr) return String renames interfaces.C.Strings.Value;
begin
   check (Node   .Item'Size / 8 = size_of_node,     "a node has the size of its class, its shared pointer among its members");
   check (Mark   .Item'Size / 8 = size_of_mark,     "and so has a mark");
   check (Emitter.Item'Size / 8 = size_of_emitter,  "and an emitter");

   loading :
   declare
      Text     :         chars_ptr := new_String ("name: ada" & ASCII.LF & "list: [1, 2, 3]" & ASCII.LF);
      Document : aliased Node.Item;
      Written  : aliased std_String;
   begin
      Load (Text, Document'unchecked_Access);
      check (not swig.Exceptions.is_Pending,         "a document is loaded from text, into a node which Ada declares");
      check (Node.IsMap (Document) /= 0,             "a map");
      check (Node.size (Document) = 2,               "of two members");
      check (Node.the_Type (Document) = Map,         "whose type is told by an enumeration of a namespace");
      check (Node.IsDefined (Document) /= 0,         "and which is defined");

      Dump (Document'unchecked_Access, Written'unchecked_Access);
      check (ada.Strings.fixed.Index (to_Ada (Written), "name: ada") /= 0,
             "the node is written out again, as text which is returned by value");

      destruct (Written);
      Node.destruct_0 (Document);
      free (Text);
   end loading;

   the_member_Templates :
   declare
      --  Instances of the member templates of a node, which the interface names: a child is found by its key or its
      --  index ('operator[]'), its value is read as a number or a string ('as'), a node is made from a value, and a
      --  value is appended to a sequence ('push_back').
      --
      Text     :         chars_ptr := new_String ("name: ada" & ASCII.LF & "list: [1, 2, 3]" & ASCII.LF & "pi: 3.5" & ASCII.LF);
      Document : aliased Node.Item;

      Name_Key : aliased std_String := to_std_String (interfaces.C.to_C ("name"));
      List_Key : aliased std_String := to_std_String (interfaces.C.to_C ("list"));
      Pi_Key   : aliased std_String := to_std_String (interfaces.C.to_C ("pi"));
      Index    : aliased interfaces.C.int := 1;
      Seven    : aliased interfaces.C.int := 7;
      Four     : aliased interfaces.C.int := 4;

      Name     : aliased Node.Item;
      List     : aliased Node.Item;
      Second   : aliased Node.Item;
      Pi       : aliased Node.Item;
      Again    : aliased Node.Item;
      Its_Text : aliased std_String;
      Built    : aliased Node.Item := Node.construct (Seven'unchecked_Access);
   begin
      Load (Text, Document'unchecked_Access);

      Node.child (Document, Name_Key'unchecked_Access, Name'unchecked_Access);
      Node.as_string (Name, Its_Text'unchecked_Access);
      check (to_Ada (Its_Text) = "ada",              "a child is found by its key, and read as a string, by instances of member templates");

      Node.child (Document, List_Key'unchecked_Access, List'unchecked_Access);
      Node.child (List, Index'unchecked_Access, Second'unchecked_Access);
      check (Node.as_int (Second) = 2,               "an element is found by its index, and read as a number");

      Node.child (Document, Pi_Key'unchecked_Access, Pi'unchecked_Access);
      check (Node.as_double (Pi) = 3.5,              "and as a real number");

      check (Node.as_int (Built) = 7,                "a node is made from a value, by an instance of its constructor template");

      Node.push_back (List, Four'unchecked_Access);
      Node.child (Document, List_Key'unchecked_Access, Again'unchecked_Access);
      check (Node.size (Again) = 4,                  "a value is appended to a sequence, which is a part of its document");

      iterating :
      declare
         --  A sequence is walked by its iterators, which C++ makes and Ada declares, and the elements are added up.
         --  The key of each element of a map is reached through the pair of nodes of which an 'iterator_value' is
         --  made.
         --
         use ada.Strings.unbounded;
         use type const_value_iterator.Pointer;

         First, Last : aliased const_value_iterator.Item;     -- Of the sequence.
         Key,   Done : aliased const_value_iterator.Item;     -- Of the map. (An iterator which is destructed is not used again:
                                                             -- 'the_begin' replaces the object which it is given.)
         Same        :         const_value_iterator.Pointer;
         Sum         :         interfaces.C.int := 0;
         Count       :         Natural          := 0;
         Keys        :         unbounded_String;
      begin
         Node.the_begin (Again, First'unchecked_Access);
         Node.a_end     (Again, Last 'unchecked_Access);

         while const_value_iterator.differs_from (First, Last'unchecked_Access) /= 0
         loop
            declare
               Element : aliased iterator_value.Item;
            begin
               const_value_iterator.current (First, Element'unchecked_Access);
               Sum   := Sum + Node.as_int (Element.Node);
               Count := Count + 1;
               iterator_value.destruct_0 (Element);
            end;

            Same := const_value_iterator.next (First);

            if Count = 1
            then
               check (Same = First'unchecked_Access, "the iterator advances, and gives itself back");
            end if;
         end loop;

         check (Count = 4 and Sum = 1 + 2 + 3 + 4,   "a sequence is walked by its iterators, which Ada declares");
         check (const_value_iterator.same_as (First, Last'unchecked_Access) /= 0,
                "until the first is the same as the last");

         const_value_iterator.destruct_0 (Last);
         const_value_iterator.destruct_0 (First);

         Node.the_begin (Document, Key 'unchecked_Access);
         Node.a_end     (Document, Done'unchecked_Access);

         while const_value_iterator.differs_from (Key, Done'unchecked_Access) /= 0
         loop
            declare
               Element : aliased iterator_value.Item;
            begin
               const_value_iterator.current (Key, Element'unchecked_Access);
               Node.as_string (Element.key_value.first, Its_Text'unchecked_Access);
               append (Keys, to_Ada (Its_Text) & " ");
               iterator_value.destruct_0 (Element);
            end;

            Same := const_value_iterator.next (Key);
         end loop;

         check (to_String (Keys) = "name list pi ",  "a map is walked, and the key of each element read: " & to_String (Keys));

         const_value_iterator.destruct_0 (Done);
         const_value_iterator.destruct_0 (Key);
      end iterating;

      assigning_through_an_Element :
      declare
         --  The overload of 'operator[]' which is not 'const' ('element') gives a node which is a part of its
         --  document, so that a value which is assigned to it ('assign', of 'operator=') changes the document.
         --
         Rust     : aliased std_String       := to_std_String (interfaces.C.to_C ("rust"));
         Year_Key : aliased std_String       := to_std_String (interfaces.C.to_C ("year"));
         Year     : aliased interfaces.C.int := 1983;
         Slot     : aliased Node.Item;
         New_Slot : aliased Node.Item;
         Read     : aliased Node.Item;
         Same     :         Node.Pointer;
      begin
         Node.element (Document, Name_Key'unchecked_Access, Slot'unchecked_Access);
         Same := Node.assign (Slot, Rust'unchecked_Access);
         check (Same = Slot'unchecked_Access,         "a value is assigned to the node which an element gives, which gives itself back");

         Node.child     (Document, Name_Key'unchecked_Access, Read'unchecked_Access);
         Node.as_string (Read, Its_Text'unchecked_Access);
         check (to_Ada (Its_Text) = "rust",           "and the document has it");

         Node.element (Document, Year_Key'unchecked_Access, New_Slot'unchecked_Access);
         Same := Node.assign (New_Slot, Year'unchecked_Access);
         check (Node.size (Document) = 4,             "an element of a key which the map has not is added to it");

         Node.destruct_0 (Read);
         Node.destruct_0 (New_Slot);
         Node.destruct_0 (Slot);
         destruct (Year_Key);
         destruct (Rust);
      end assigning_through_an_Element;

      destruct (Its_Text);
      destruct (Pi_Key);
      destruct (List_Key);
      destruct (Name_Key);
      Node.destruct_0 (Built);
      Node.destruct_0 (Again);
      Node.destruct_0 (Pi);
      Node.destruct_0 (Second);
      Node.destruct_0 (List);
      Node.destruct_0 (Name);
      Node.destruct_0 (Document);
      free (Text);
   end the_member_Templates;

   all_the_Documents :
   declare
      Text      :         chars_ptr := new_String ("a: 1" & ASCII.LF & "---" & ASCII.LF & "b: 2" & ASCII.LF);
      Documents : aliased Nodes.Item;
   begin
      LoadAll (Text, Documents'unchecked_Access);
      check (Nodes.size (Documents) = 2,             "each document of a stream is loaded, into a vector of nodes");
      check (Node.IsMap (Nodes.get (Documents, 1).all) /= 0,   "which are nodes");

      Nodes.destruct_0 (Documents);
      free (Text);
   end all_the_Documents;

   emitting :
   declare
      the_Emitter : aliased Emitter.Item := Emitter.construct;
      Word        : aliased std_String   := to_std_String (interfaces.C.to_C ("hello"));
      Same        : constant Emitter.Pointer := Emitter.Write (the_Emitter, Word'unchecked_Access);
   begin
      check (Same = the_Emitter'unchecked_Access,    "an emitter writes a scalar, and gives itself back");
      check (Value (Emitter.c_str (the_Emitter)) = "hello",   "as its text");
      check (Emitter.good (the_Emitter) /= 0,        "and is good");

      destruct (Word);
      Emitter.destruct_0 (the_Emitter);
   end emitting;

   refusing :
   declare
      Text     :         chars_ptr := new_String ("{ a: [1, 2");
      Document : aliased Node.Item;
   begin
      Load (Text, Document'unchecked_Access);
      check (swig.Exceptions.is_Pending,             "a document which is not well formed is refused by an exception, which is recorded");
      check (ada.Strings.fixed.Index (swig.Exceptions.pending_Message, "line 1") /= 0,
             "with the message of the library's exception: " & swig.Exceptions.pending_Message);
      swig.Exceptions.clear;

      Node.destruct_0 (Document);
      free (Text);
   end refusing;

   finish;
end Tester;
