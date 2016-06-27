with
     ada.Strings.unbounded,
     ada.containers.Vectors;


package a_Namespace
--
--  Provides support for overloading resolution.
--
is
   use ada.Strings.unbounded;


   type Name is
      record
         Text           : unbounded_String;
         overload_Count : Natural         := 0;     -- Number of times this Name has been overloaded  (ie added to the namespace).
         used_Count     : Natural         := 0;     -- Number of times this Name has been used to construct a unique name.
      end record;

   type Name_view is access all Name;



   type Item is tagged private;

   procedure add_Name   (Self : in out Item;   name_Text : in unbounded_String);
   function  fetch_Name (Self : in     Item;   name_Text : in unbounded_String) return Name_view;




private

   package name_Vectors is new ada.containers.Vectors (Positive, Name_view);      -- tbd: use an ada.containers set

   subtype Names        is name_Vectors.Vector;
   subtype name_Cursor  is name_Vectors.Cursor;


   type Item is tagged
      record
         Names : a_namespace.Names;
      end record;

end a_Namespace;
