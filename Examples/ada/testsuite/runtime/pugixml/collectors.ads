with
     pugixml.xml_tree_walker,
     pugixml.xml_writer,
     pugixml.xml_node,
     swig,
     interfaces.C,
     ada.Strings.unbounded;

package Collectors
--
-- Two classes which are declared in Ada and derived from abstract classes of pugixml, each of which pugixml
-- calls back: a walker, which is given every node of a tree, and a writer, which is given a document as text.
-- They are at library level, as pugixml calls their functions through the vtable of the class.
--
is
   use pugixml,
       interfaces.C,
       ada.Strings.unbounded;

   type Walker is new xml_tree_walker.Item with
      record
         Names : unbounded_String;     -- The name of each node which is met, in order.
      end record;

   overriding
   function for_each (Self : access Walker;   node : access xml_node.Item) return swig.bool;

   pragma Convention (CPP, for_each);


   type Writer is new xml_writer.Item with
      record
         Text : unbounded_String;      -- What has been written.
      end record;

   overriding
   procedure write (Self : in out Writer;   data : in swig.void_ptr;
                                            size : in size_t);
   pragma Convention (CPP, write);

end Collectors;
