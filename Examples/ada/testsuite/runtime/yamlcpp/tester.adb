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
