with
     pugixml.xml_document,
     pugixml.xml_parse_result,
     pugixml.xml_node,
     pugixml.xml_node_range,
     pugixml.xml_node_iterator,
     pugixml.xml_attribute,
     pugixml.xml_text,
     pugixml.xpath_node,
     pugixml.xml_tree_walker,
     pugixml.xml_writer,

     Collectors,

     swig,
     interfaces.C.Strings,
     ada.Strings.fixed,
     ada.Strings.unbounded,

     Checks;


procedure Tester
--
--  A binding to pugixml, made from its own header: a class library which nobody wrote as a test. Its classes
--  are small handles which are passed and returned by value. A document is read from text, walked, searched
--  and changed, and is then walked and written out by classes which are declared in Ada.
--
is
   use pugixml,
       interfaces.C,
       Checks;

   use type swig.bool;

   --  A string of pugixml ('const char_t*', where 'typedef char char_t;') is a 'chars_ptr'.
   --
   function "+" (the_Text : in interfaces.C.Strings.chars_ptr) return String
   is (interfaces.C.Strings.Value (the_Text));

   function "+" (the_Text : access char_array) return interfaces.C.Strings.chars_ptr
   is (interfaces.C.Strings.to_chars_ptr (the_Text.all'unrestricted_Access));

   Source    : aliased char_array := to_C (  "<library>"
                                           &   "<book year=""1999""><title>Ada</title></book>"
                                           &   "<book year=""2012""><title>Rust</title></book>"
                                           & "</library>");
   Book      : aliased char_array := to_C ("book");
   Title     : aliased char_array := to_C ("title");
   Year      : aliased char_array := to_C ("year");
   Pages     : aliased char_array := to_C ("pages");
   Newer     : aliased char_array := to_C ("book[@year>2000]/title");
   Nothing   : aliased char_array := to_C ("");

   the_Document : aliased xml_document.Item;     -- Which C++ constructs.
begin
   check (parse_default = 116 and parse_full = 887,       "a constant whose value is made of other constants is worked out");

   reading :
   declare
      Outcome : constant xml_parse_result.Item := xml_document.load_string (the_Document, +Source'Access);
      Root    : constant xml_node.Item         := xml_document.document_element (the_Document);
      First   : constant xml_node.Item         := xml_node.child (Root, +Book'Access);
      Second  : constant xml_node.Item         := xml_node.next_sibling (First);
      Third   : constant xml_node.Item         := xml_node.next_sibling (Second);
   begin
      check (Outcome.status = status_ok,                   "a document is read from text, and the result of the reading is returned by value");
      check (String'(interfaces.C.Strings.Value (xml_parse_result.description (Outcome))) = "No error",   "which describes itself");

      check (+xml_node.name (Root) = "library",            "a node, which is a handle of one pointer, is returned by value");
      check (+xml_node.name (First) = "book",              "a child is found by its name");
      check (xml_attribute.as_int (xml_node.attribute (First, +Year'Access)) = 1999,   "an attribute, returned by value, gives its number");
      check (+xml_node.child_value (First, +Title'Access) = "Ada",                     "the text of a child");
      check (+xml_text.get (xml_node.text (xml_node.child (Second, +Title'Access))) = "Rust",   "a text handle, of the class which the node class names and which names it");
      check (xml_node.empty (Third) /= 0,                  "the node after the last is the empty handle");
      check (+xml_node.name (xml_node.parent (Second)) = "library",   "a node gives its parent");

      declare
         Children : constant xml_node_range.Item := xml_node.children (Root);
      begin
         check (xml_node_range.empty (Children) = 0,                                     "a node gives the range of its children, by value");
         check (+xml_node.name (xml_node_iterator.dereference (xml_node_range.the_begin (Children)).all) = "book",
                "whose first iterator reaches the first of them");
      end;
   end reading;

   searching :
   declare
      Root  : constant xml_node.Item   := xml_document.document_element (the_Document);
      Found : constant xpath_node.Item := xml_node.select_node (Root, +Newer'Access);
   begin
      check (+xml_node.child_value (xpath_node.node (Found)) = "Rust",   "a query finds a node, through three classes each of which uses the next by value");
   end searching;

   changing :
   declare
      Root   : constant xml_node.Item      := xml_document.document_element (the_Document);
      Added  : constant xml_node.Item      := xml_node.append_child (Root, +Book'Access);
      Count  : constant xml_attribute.Item := xml_node.append_attribute (Added, +Pages'Access);
      Number :          Natural            := 0;
      Each   :          xml_node.Item      := xml_node.first_child (Root);
   begin
      check (xml_attribute.set_value (Count, int'(320)) /= 0,          "an attribute is added to a node which is added, and set by the overload of an integer");
      check (xml_attribute.as_int (xml_node.attribute (Added, +Pages'Access)) = 320,   "and is read back from the document");
      check (xml_attribute.set_value (Count, double'(1.5)) /= 0 and xml_attribute.as_double (Count) = 1.5,   "the overload of a real number");

      while xml_node.empty (Each) = 0
      loop
         Number := Number + 1;
         Each   := xml_node.next_sibling (Each);
      end loop;

      check (Number = 3,                                               "the children of a node are walked by their handles");
      check (xml_node.remove_child (Root, Added'unrestricted_Access) /= 0,   "and one is removed");
   end changing;

   a_walker_declared_in_Ada :
   declare
      use ada.Strings.unbounded;
      the_Walker : aliased Collectors.Walker;     -- Its abstract parent is constructed by C++.
      Root       : constant xml_node.Item := xml_document.document_element (the_Document);
   begin
      check (xml_node.traverse (Root, the_Walker'Access) /= 0,         "a tree is walked by a walker which is declared in Ada");
      check (to_String (the_Walker.Names) = "book 0 title 1  2 book 0 title 1  2 ",   "whose function pugixml calls with each node, and its depth: " & to_String (the_Walker.Names));

      the_Walker.Names := null_unbounded_String;     -- GNAT does not finalise the components of a type which is derived from one of C++.
      xml_tree_walker.destruct_0 (xml_tree_walker.Item (the_Walker));
   end a_walker_declared_in_Ada;

   a_writer_declared_in_Ada :
   declare
      use ada.Strings.unbounded;
      the_Writer : aliased Collectors.Writer;
   begin
      xml_document.save (the_Document, the_Writer'unchecked_Access, +Nothing'Access, format_raw);

      check (ada.Strings.fixed.Index (to_String (the_Writer.Text), "<book year=""2012""><title>Rust</title></book></library>") /= 0,
             "the document is written out through a writer which is declared in Ada");

      the_Writer.Text := null_unbounded_String;
      xml_writer.destruct_0 (xml_writer.Item (the_Writer));
   end a_writer_declared_in_Ada;

   xml_document.destruct (the_Document);
   finish;
end Tester;
