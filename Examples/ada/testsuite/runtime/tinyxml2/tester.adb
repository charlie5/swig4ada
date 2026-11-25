with
     tinyxml2.Binding,
     tinyxml2.XMLDocument,
     tinyxml2.XMLElement,
     tinyxml2.XMLNode,
     tinyxml2.XMLPrinter,
     tinyxml2.XMLVisitor,

     Visitors,

     swig,
     interfaces.C.Strings,
     ada.Strings.fixed,
     ada.Strings.unbounded,

     Checks;


procedure Tester
--
--  A binding to tinyxml2, made from its own header: a document which owns its nodes, which are reached by pointer
--  and are of a hierarchy of classes with virtual functions. A document is parsed from text, read and changed, is
--  printed by a printer which Ada declares, and is walked by a visitor which is declared in Ada, which tinyxml2
--  calls back.
--
is
   use tinyxml2,
       tinyxml2.Binding,
       interfaces.C,
       Checks;

   use type swig.bool,
            XMLElement.Pointer,
            XMLNode.Pointer;

   --  A string of tinyxml2 is a 'chars_ptr'.
   --
   function "+" (the_Text : in interfaces.C.Strings.chars_ptr) return String
   is (interfaces.C.Strings.Value (the_Text));

   function "+" (the_Text : access char_array) return interfaces.C.Strings.chars_ptr
   is (interfaces.C.Strings.to_chars_ptr (the_Text.all'unrestricted_Access));

   Source  : aliased char_array := to_C (  "<library owner=""ada"">"
                                         &   "<book year=""1983"" pages=""300""><title>Ada</title></book>"
                                         &   "<book year=""2012""><title>Rust</title></book>"
                                         & "</library>");
   Broken  : aliased char_array := to_C ("<library><book></library>");
   Book    : aliased char_array := to_C ("book");
   Title   : aliased char_array := to_C ("title");
   Year    : aliased char_array := to_C ("year");
   Pages   : aliased char_array := to_C ("pages");
   Owner   : aliased char_array := to_C ("owner");
   Added   : aliased char_array := to_C ("added");
   Kind    : aliased char_array := to_C ("kind");
   Novel   : aliased char_array := to_C ("novel");

   the_Document : aliased XMLDocument.Item;     -- Which C++ constructs.
begin
   check (XMLDocument.Item'Object_Size / 8 = size_of_document,   "a document has the size of its class, its pools of nodes among its members");
   check (XMLPrinter .Item'Object_Size / 8 = size_of_printer,    "and so has a printer");
   check (XMLVisitor .Item'Object_Size / 8 = size_of_visitor,    "and a visitor");

   reading :
   declare
      Root   : constant XMLElement.Pointer := null;
      First  :          XMLElement.Pointer;
      Second :          XMLElement.Pointer;
      Year_1 : aliased  interfaces.C.int   := 0;
      pragma Unreferenced (Root);
   begin
      check (XMLDocument.Parse (the_Document'Access, +Source'Access) = XML_SUCCESS,
             "a document is parsed from text, into a document which Ada declares");

      declare
         the_Root : constant access XMLElement.Item'Class := XMLDocument.RootElement (the_Document'Access);
      begin
         check (+XMLElement.Name (the_Root) = "library",             "its root element is found, and named");
         check (+XMLElement.Attribute (the_Root, +Owner'Access) = "ada",
                                                                      "an attribute is read as text");
         check (XMLNode.ChildElementCount (the_Root) = 2,             "the root has two child elements");

         First  := XMLElement.Pointer (XMLNode.FirstChildElement  (the_Root, +Book'Access));
         Second := XMLElement.Pointer (XMLNode.NextSiblingElement (First,    +Book'Access));

         check (Second /= null,                                       "an element is found by its name, and its sibling too");
         check (XMLElement.IntAttribute (First, +Year'Access) = 1983,  "an attribute is read as a number");
         check (XMLElement.QueryIntAttribute (Second, +Year'Access, Year_1'unchecked_Access) = XML_SUCCESS
                and Year_1 = 2012,                                    "and queried into a variable");
         check (XMLElement.QueryIntAttribute (Second, +Pages'Access, Year_1'unchecked_Access) = XML_NO_ATTRIBUTE,
                                                                      "an attribute which is not there is told of by an enumeration");
         check (+XMLElement.GetText (XMLNode.FirstChildElement (Second, +Title'Access)) = "Rust",
                                                                      "the text of an element is read");
      end;
   end reading;

   changing :
   declare
      --  A result which is an anonymous access ('NewElement', whose package has a limited view of that of the
      --  element) is not converted to a named pointer type, whose accessibility GNAT checks at run time: the
      --  pointer is taken of the object.
      --
      the_Root    : constant access XMLElement.Item'Class := XMLDocument.RootElement (the_Document'Access);
      New_One     : constant access XMLElement.Item'Class := XMLDocument.NewElement  (the_Document'Access, +Added'Access);
      the_New_One : constant        XMLNode.Pointer       := New_One.all'unchecked_Access;
      Inserted    :                 XMLNode.Pointer;
   begin
      XMLElement.SetAttribute (New_One.all, +Kind'Access, +Novel'Access);
      Inserted := XMLNode.InsertEndChild (the_Root, the_New_One);

      check (Inserted = the_New_One,                                  "an element which the document makes is added to its root");
      check (XMLNode.ChildElementCount (the_Root) = 3,                "which then has three child elements");
   end changing;

   printing :
   declare
      the_Printer : aliased XMLPrinter.Item;     -- With no file: it prints into a buffer of its own.
      the_Text    : constant access String := null;
      pragma Unreferenced (the_Text);
   begin
      XMLDocument.Print (the_Document, the_Printer'Access);

      declare
         Printed : constant String := +XMLPrinter.CStr (the_Printer'Access);
      begin
         check (ada.Strings.fixed.Index (Printed, "<added kind=""novel""/>") /= 0,
                "the document is printed by a printer which Ada declares, which C++ calls through the vtable of a visitor");
         check (ada.Strings.fixed.Index (Printed, "<title>Ada</title>") /= 0,
                "with all that was parsed");
      end;

      XMLPrinter.destruct_0 (the_Printer);
   end printing;

   visiting :
   declare
      use ada.Strings.unbounded;
      the_Visitor : aliased Visitors.Counter;
   begin
      check (XMLDocument.the_Accept (the_Document'Access, the_Visitor'unchecked_Access) /= 0,
             "the document is walked by a visitor which is declared in Ada");
      check (the_Visitor.Elements = 6,                                "which is called back for each element, through the vtable");
      check (the_Visitor.Attributes = 4,                              "with its first attribute, where it has one");
      check (to_String (the_Visitor.Texts) = "Ada Rust ",             "and for each text, in order: " & to_String (the_Visitor.Texts));

      the_Visitor.Texts := null_unbounded_String;     -- GNAT does not finalise a component of a type derived from one of C++.
      XMLVisitor.destruct_0 (XMLVisitor.Item (the_Visitor));
   end visiting;

   refusing :
   declare
      Other : aliased XMLDocument.Item;
   begin
      check (XMLDocument.Parse (Other'Access, +Broken'Access) = XML_ERROR_MISMATCHED_ELEMENT,
             "a document which is not well formed is refused, by an enumeration of the error");
      check (+XMLDocument.ErrorName (Other'Access) = "XML_ERROR_MISMATCHED_ELEMENT",
             "which the library names");
      check (XMLDocument.ErrorLineNum (Other'Access) = 1,             "and on its line");

      XMLDocument.destruct_0 (Other);
   end refusing;

   XMLDocument.destruct_0 (the_Document);
   finish;
end Tester;
