with
     leveldb.Comparator,
     leveldb.Slice,
     swig.std_Strings,
     interfaces.C.Strings;

package Reversed
--
-- A comparator which is declared in Ada, and derived from LevelDB's abstract 'Comparator': it orders the
-- keys of a database from the last to the first. LevelDB calls its functions through the vtable of the class,
-- so the package is at library level.
--
is
   use leveldb,
       interfaces.C;

   type Item is new Comparator.Item with
      record
         Calls : Natural := 0;     -- How often LevelDB has asked it to compare.
      end record;

   overriding
   function  Compare (Self : access Item;   a : in Slice.Pointer;
                                            b : in Slice.Pointer) return int;
   overriding
   function  Name    (Self : access Item) return interfaces.C.Strings.chars_ptr;

   overriding
   procedure FindShortestSeparator (Self : in out Item;   start : in swig.std_Strings.std_string_Pointer;
                                                          limit : in Slice.Pointer);
   overriding
   procedure FindShortSuccessor    (Self : in out Item;   key   : in swig.std_Strings.std_string_Pointer);

   pragma Convention (CPP, Compare);
   pragma Convention (CPP, Name);
   pragma Convention (CPP, FindShortestSeparator);
   pragma Convention (CPP, FindShortSuccessor);

end Reversed;
