with
     interfaces.C.Strings;

package body Notebooks
is
   use interfaces.C.Strings;


   function to_Ada (the_Slice : in Slice.Pointer) return String
   is
   begin
      return Value (Slice.data (the_Slice.all), Slice.size (the_Slice.all));
   end to_Ada;



   function Place (Self : in Item;   Key : in String) return Natural
   --
   --  Where the key is kept, or 0.
   --
   is
   begin
      for Each in Self.Pages'Range
      loop
         if         Self.Pages (Each).is_Used
           and then Self.Pages (Each).Key (1 .. Self.Pages (Each).Key_Last) = Key
         then
            return Each;
         end if;
      end loop;

      return 0;
   end Place;



   function free_Place (Self : in Item) return Natural
   is
   begin
      for Each in Self.Pages'Range
      loop
         if not Self.Pages (Each).is_Used
         then
            return Each;
         end if;
      end loop;

      return 0;
   end free_Place;



   procedure not_Found (Reason : in String;   Result : in Status.Pointer)
   --
   --  Gives the result a status of 'NotFound', with the reason.
   --
   is
      the_Text   : aliased char_array := to_C (Reason);
      the_Reason : aliased Slice.Item := Slice.construct (to_chars_ptr (the_Text'unchecked_Access));
   begin
      Status.NotFound (the_Reason'unchecked_Access, Result);
   end not_Found;



   overriding
   procedure Put (Self    : in out Item;   options : in WriteOptions.Pointer;
                                           key     : in Slice.Pointer;
                                           value   : in Slice.Pointer;
                                           Result  : in Status.Pointer)
   is
      pragma Unreferenced (options);

      the_Key   : constant String  := to_Ada (key);
      the_Value : constant String  := to_Ada (value);
      Found     :          Natural := Place (Self, the_Key);
   begin
      if Found = 0
      then
         Found := free_Place (Self);
      end if;

      if        Found = 0
        or else the_Key'Length   > Text'Length
        or else the_Value'Length > Text'Length
      then
         not_Found ("the notebook is full", Result);
         return;
      end if;

      Self.Pages (Found).Key        (1 .. the_Key'Length)   := the_Key;
      Self.Pages (Found).Key_Last   := the_Key'Length;
      Self.Pages (Found).Value      (1 .. the_Value'Length) := the_Value;
      Self.Pages (Found).Value_Last := the_Value'Length;
      Self.Pages (Found).is_Used    := True;

      Status.OK (Result);
   end Put;



   overriding
   procedure Delete (Self    : in out Item;   options : in WriteOptions.Pointer;
                                              key     : in Slice.Pointer;
                                              Result  : in Status.Pointer)
   is
      pragma Unreferenced (options);
      Found : constant Natural := Place (Self, to_Ada (key));
   begin
      if Found /= 0
      then
         Self.Pages (Found).is_Used := False;
      end if;

      Status.OK (Result);     -- As LevelDB has it: to delete a key which is not there is no fault.
   end Delete;



   overriding
   procedure Write (Self    : in out Item;   options : in WriteOptions.Pointer;
                                             updates : in WriteBatch.Pointer;
                                             Result  : in Status.Pointer)
   is
      pragma Unreferenced (Self, options, updates);
   begin
      not_Found ("a batch is not kept", Result);
   end Write;



   overriding
   procedure Get (Self    : in out Item;   options : in ReadOptions.Pointer;
                                           key     : in Slice.Pointer;
                                           value   : in std_string_Pointer;
                                           Result  : in Status.Pointer)
   is
      pragma Unreferenced (options);
      Found : constant Natural := Place (Self, to_Ada (key));
   begin
      if Found = 0
      then
         not_Found ("no such page", Result);
         return;
      end if;

      assign (value.all, to_C (Self.Pages (Found).Value (1 .. Self.Pages (Found).Value_Last)));
      Status.OK (Result);
   end Get;



   overriding
   function NewIterator (Self : access Item;   options : in ReadOptions.Pointer) return Iterator.Pointer
   is
      pragma Unreferenced (Self, options);
   begin
      return null;
   end NewIterator;


   overriding
   function GetSnapshot (Self : access Item) return Snapshot.Pointer
   is
      pragma Unreferenced (Self);
   begin
      return null;
   end GetSnapshot;


   overriding
   procedure ReleaseSnapshot (Self : in out Item;   snapshot : in leveldb.Snapshot.Pointer)
   is
      pragma Unreferenced (Self, snapshot);
   begin
      null;
   end ReleaseSnapshot;


   overriding
   function GetProperty (Self : access Item;   property : in Slice.Pointer;
                                               value    : in std_string_Pointer) return swig.bool
   is
      pragma Unreferenced (Self, property, value);
   begin
      return 0;
   end GetProperty;


   overriding
   procedure GetApproximateSizes (Self : in out Item;   the_range : in leveldb.the_Range.Pointer;
                                                        n         : in int;
                                                        sizes     : in swig.Pointers.uint64_t_Pointer)
   is
      pragma Unreferenced (Self, the_range, n, sizes);
   begin
      null;
   end GetApproximateSizes;


   overriding
   procedure CompactRange (Self : in out Item;   the_begin : in Slice.Pointer;
                                                 the_end   : in Slice.Pointer)
   is
      pragma Unreferenced (Self, the_begin, the_end);
   begin
      null;
   end CompactRange;

end Notebooks;
