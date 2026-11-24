with
     yamlcpp.Binding,
     yamlcpp.Node,
     yamlcpp.Nodes,
     yamlcpp.Mark,
     yamlcpp.Emitter,

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
            Emitter.Pointer;

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
