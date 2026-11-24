with
     leveldb.DB.Director,
     leveldb.ReadOptions,
     leveldb.WriteOptions,
     leveldb.WriteBatch,
     leveldb.Slice,
     leveldb.Status,
     leveldb.Iterator,
     leveldb.Snapshot,
     leveldb.the_Range,
     swig.Pointers,
     swig.std_Strings,
     interfaces.C;

package Notebooks
--
-- A database which is declared in Ada: a few keys and their values, kept in memory. It is derived from the director
-- of LevelDB's abstract 'DB', so that it implements the functions which return a status, and C++ uses it as it uses
-- any database. LevelDB calls its functions through the vtable of the class, so the package is at library level.
--
is
   use leveldb,
       swig.std_Strings,
       interfaces.C;

   subtype Text is String (1 .. 16);

   type Page is
      record
         Key        : Text;
         Key_Last   : Natural := 0;
         Value      : Text;
         Value_Last : Natural := 0;
         is_Used    : Boolean := False;
      end record;

   type Pages is array (1 .. 4) of Page;

   type Item is new DB.Director.Item with
      record
         Pages : Notebooks.Pages;     -- No component is controlled, as GNAT does not finalise those of a type derived from C++.
      end record;

   --  The functions which return a status, through the director.
   --
   overriding
   procedure Put    (Self    : in out Item;   options : in WriteOptions.Pointer;
                                              key     : in Slice.Pointer;
                                              value   : in Slice.Pointer;
                                              Result  : in Status.Pointer);
   overriding
   procedure Delete (Self    : in out Item;   options : in WriteOptions.Pointer;
                                              key     : in Slice.Pointer;
                                              Result  : in Status.Pointer);
   overriding
   procedure Write  (Self    : in out Item;   options : in WriteOptions.Pointer;
                                              updates : in WriteBatch.Pointer;
                                              Result  : in Status.Pointer);
   overriding
   procedure Get    (Self    : in out Item;   options : in ReadOptions.Pointer;
                                              key     : in Slice.Pointer;
                                              value   : in std_string_Pointer;
                                              Result  : in Status.Pointer);

   --  The others, through the vtable of the class.
   --
   overriding
   function  NewIterator         (Self : access Item;   options  : in ReadOptions.Pointer) return Iterator.Pointer;
   overriding
   function  GetSnapshot         (Self : access Item) return Snapshot.Pointer;
   overriding
   procedure ReleaseSnapshot     (Self : in out Item;   snapshot : in leveldb.Snapshot.Pointer);
   overriding
   function  GetProperty         (Self : access Item;   property : in Slice.Pointer;
                                                        value    : in std_string_Pointer) return swig.bool;
   overriding
   procedure GetApproximateSizes (Self : in out Item;   the_range : in leveldb.the_Range.Pointer;
                                                        n         : in int;
                                                        sizes     : in swig.Pointers.uint64_t_Pointer);
   overriding
   procedure CompactRange        (Self : in out Item;   the_begin : in Slice.Pointer;
                                                        the_end   : in Slice.Pointer);

   pragma Convention (CPP, Put);
   pragma Convention (CPP, Delete);
   pragma Convention (CPP, Write);
   pragma Convention (CPP, Get);
   pragma Convention (CPP, NewIterator);
   pragma Convention (CPP, GetSnapshot);
   pragma Convention (CPP, ReleaseSnapshot);
   pragma Convention (CPP, GetProperty);
   pragma Convention (CPP, GetApproximateSizes);
   pragma Convention (CPP, CompactRange);

end Notebooks;
