with
     containers.Binding,
     containers.int_Vector,
     containers.int_List,
     containers.int_Deque,
     containers.int_Set,
     containers.int_double_Map,
     containers.int_double_Pair,

     swig,
     interfaces.C,

     Checks;


procedure Tester
--
--  The containers of the C++ standard library: each is made by Ada, has elements
--  added from Ada and from C++, and is read from both sides.
--
is
   use containers,
       containers.Binding,
       interfaces.C,
       Checks;

   use type swig.bool;

   function is_True (Value : in swig.bool) return Boolean
   is (Value /= swig.bool'Val (0));

   Unit : constant := interfaces.C.char'Size;

begin
   --  The size of each Ada type is that of the C++ type.
   --
   check (int_Vector     .Item'Size / Unit = Integer (size_of_vector), "the size of a vector");
   check (int_List       .Item'Size / Unit = Integer (size_of_list),   "the size of a list");
   check (int_Deque      .Item'Size / Unit = Integer (size_of_deque),  "the size of a deque");
   check (int_Set        .Item'Size / Unit = Integer (size_of_set),    "the size of a set");
   check (int_double_Map .Item'Size / Unit = Integer (size_of_map),    "the size of a map");
   check (int_double_Pair.Item'Size / Unit = Integer (size_of_pair),   "the size of a pair");

   vector :
   declare
      V : aliased int_Vector.Item;
      X : aliased int := 7;
   begin
      check (is_True (int_Vector.isEmpty (V)),  "a vector with no initial value is empty");

      int_Vector.add (V, X'unchecked_Access);
      check (int_Vector.size (V) = 1,           "an element added from Ada");
      check (int_Vector.get  (V, 0).all = 7,    "the element reads back");

      fill (int_Vector.Pointer'(V'unchecked_Access), 3);
      check (int_Vector.size (V) = 4,           "elements added by C++");
      check (int_Vector.get  (V, 3).all = 30,   "an element added by C++ reads back in Ada");
      check (sum (int_Vector.Pointer'(V'unchecked_Access)) = 67,   "C++ reads the whole vector");

      X := 99;
      int_Vector.set (V, 1, X'unchecked_Access);
      check (int_Vector.get (V, 1).all = 99,    "an element is replaced");

      int_Vector.clear (V);
      check (int_Vector.size (V) = 0,           "a vector is cleared");

      int_Vector.destruct (V);
   end vector;

   list :
   declare
      L : aliased int_List.Item;
      X : aliased int := 5;
   begin
      int_List.push_back  (L, X'unchecked_Access);
      X := 3;
      int_List.push_front (L, X'unchecked_Access);

      check (int_List.size  (L) = 2,            "two elements added to a list");
      check (int_List.front (L).all = 3,        "the front of the list");
      check (int_List.back  (L).all = 5,        "the back of the list");

      fill (int_List.Pointer'(L'unchecked_Access), 4);
      check (int_List.size (L) = 6,                             "elements added to the list by C++");
      check (sum (int_List.Pointer'(L'unchecked_Access)) = 18,  "C++ reads the whole list");

      int_List.the_reverse (L);
      check (int_List.front (L).all = 4,        "a list is reversed");

      int_List.pop_front (L);
      check (int_List.size (L) = 5,             "an element is removed from the list");

      int_List.destruct (L);
   end list;

   deque :
   declare
      D : aliased int_Deque.Item;
      X : aliased int := 11;
   begin
      int_Deque.push_back (D, X'unchecked_Access);
      fill (int_Deque.Pointer'(D'unchecked_Access), 100);     -- Enough to need more than one block.

      check (int_Deque.size  (D) = 101,         "elements added to a deque");
      check (int_Deque.front (D).all = 11,      "the front of the deque");
      check (int_Deque.back  (D).all = 100,     "the back of the deque");
      check (int_Deque.get   (D, 50).all = 50,  "an element in the middle of the deque");

      int_Deque.destruct (D);
   end deque;

   set :
   declare
      S : aliased int_Set.Item;
      X : aliased int := 42;
   begin
      fill (int_Set.Pointer'(S'unchecked_Access), 20);        -- The values 0 .. 4, many times over.
      check (int_Set.size (S) = 5,                              "a set holds each value once");

      int_Set.add (S, X'unchecked_Access);
      check (is_True (int_Set.contains (S, X'unchecked_Access)), "a set contains a value added from Ada");
      check (int_Set.size (S) = 6,                              "the set has grown by one");

      check (int_Set.erase (S, X'unchecked_Access) = 1,         "a value is erased");
      check (not is_True (int_Set.contains (S, X'unchecked_Access)), "the erased value is gone");

      int_Set.destruct (S);
   end set;

   map :
   declare
      M     : aliased int_double_Map.Item;
      Key   : aliased int    := 100;
      Value : aliased double := 2.5;
   begin
      check (is_True (int_double_Map.empty (M)),  "a map with no initial value is empty");

      fill (int_double_Map.Pointer'(M'unchecked_Access), 10);
      check (int_double_Map.size (M) = 10,        "entries added to a map by C++");

      int_double_Map.set (M, Key'unchecked_Access, Value'unchecked_Access);
      check (is_True (int_double_Map.has_key (M, Key'unchecked_Access)),  "an entry added from Ada");
      check (int_double_Map.get (M, Key'unchecked_Access).all = 2.5,      "the entry reads back in Ada");
      check (lookup (int_double_Map.Pointer'(M'unchecked_Access), 100) = 2.5,  "the entry reads back in C++");

      Key := 4;
      check (int_double_Map.get (M, Key'unchecked_Access).all = 6.0,      "an entry added by C++ reads back in Ada");

      int_double_Map.del (M, Key'unchecked_Access);
      check (int_double_Map.size (M) = 10,        "an entry is deleted");

      int_double_Map.destruct (M);
   end map;

   pair :
   declare
      P : constant int_double_Pair.Item := int_double_Pair.construct (3, 4.5);
      Q : constant int_double_Pair.Item := make_pair_of (8, 1.25);
   begin
      check (P.first = 3 and P.second = 4.5,      "a pair made by its constructor");
      check (Q.first = 8 and Q.second = 1.25,     "a pair returned by a function");
   end pair;

   finish;
end Tester;
