with
     moves.Binding,
     moves.Buffer,
     moves.Buffer_owner,
     moves.Holder,

     swig,
     interfaces.C,

     Checks;


procedure Tester
--
--  Objects which can be moved and not copied: a result which is moved to the caller, a parameter which
--  is moved from the object of the caller, and a pointer which owns its object.
--
is
   use moves,
       moves.Binding,
       interfaces.C,
       Checks;

   use type swig.bool,
            moves.Buffer.Pointer;

   function is_Empty (the_Buffer : in Buffer.item) return Boolean
   is (Buffer.is_empty (the_Buffer) /= swig.bool'Val (0));

begin
   check (buffers_alive = 0,                              "there are no buffers at the start");

   results :
   declare
      the_Buffer : aliased Buffer.item := Buffer.construct (1);
   begin
      check (buffers_alive = 1,                           "a buffer is made");

      make_buffer (4, the_Buffer'unchecked_Access);       -- A buffer which is returned by value, and so moved.

      check (Buffer.length (the_Buffer) = 4,              "a buffer which is returned by value replaces that of the caller");
      check (Buffer.sum    (the_Buffer) = 10,             "with its storage");
      check (buffers_alive = 1,                           "and the storage of the one it replaced is freed");

      check (peek (the_Buffer'unchecked_Access) = 4,      "an rvalue reference is passed");
      check (not is_Empty (the_Buffer),                   "and the buffer is left alone where the function does not move it");

      check (take (the_Buffer'unchecked_Access) = 10,     "a function moves from an rvalue reference");
      check (is_Empty (the_Buffer),                       "which leaves the buffer of the caller empty");
      check (buffers_alive = 0,                           "and its storage freed by the function");

      Buffer.destruct (the_Buffer);
      check (buffers_alive = 0,                           "an empty buffer is destructed");
   end results;

   parameters :
   declare
      the_Buffer : aliased Buffer.item := Buffer.construct (3);
   begin
      check (consume (the_Buffer) = 6,                    "a buffer is passed by value");
      check (is_Empty (the_Buffer),                       "which moves it from the buffer of the caller");
      check (buffers_alive = 0,                           "and its storage is freed when the function returns");

      Buffer.destruct (the_Buffer);
   end parameters;

   moving_constructor :
   declare
      First  : aliased Buffer.item := Buffer.construct (5);
      Second : aliased Buffer.item := Buffer.construct (First'unchecked_Access);     -- Moved from the first.
   begin
      check (Buffer.length (Second) = 5,                  "a buffer is constructed from another");
      check (is_Empty (First),                            "which is left empty");
      check (buffers_alive = 1,                           "so there is one buffer with storage");

      Buffer.destruct (Second);
      Buffer.destruct (First);
      check (buffers_alive = 0,                           "and none when both are destructed");
   end moving_constructor;

   holders :
   declare
      First      : aliased Buffer.item := Buffer.construct (2);
      Second     : aliased Buffer.item := Buffer.construct (7);
      the_Holder : aliased Holder.item := Holder.construct (First);     -- Which keeps the buffer.
   begin
      check (Holder.length (the_Holder) = 2,              "a class is constructed with a buffer, passed by value");
      check (is_Empty (First),                            "which it has moved from that of the caller");
      check (buffers_alive = 2,                           "so no buffer is made or lost");

      Holder.adopt (the_Holder, Second'unchecked_Access);

      check (Holder.length (the_Holder) = 7,              "a member function moves from an rvalue reference");
      check (is_Empty (Second),                           "which is left empty");
      check (buffers_alive = 1,                           "and the buffer which the class held before is freed");

      Holder.destruct (the_Holder);
      check (buffers_alive = 0,                           "the class frees its buffer when it is destructed");

      Buffer.destruct (Second);
      Buffer.destruct (First);
   end holders;

   owners :
   declare
      the_Owner : aliased Buffer_owner.item;     -- Which owns nothing, as C++ constructs it.
   begin
      check (owned_length (the_Owner'unchecked_Access) = -1,   "a pointer which owns nothing is made");

      make_owned (6, the_Owner'unchecked_Access);

      check (buffers_alive = 1,                           "a pointer which owns a buffer is returned by value");
      check (owned_length (the_Owner'unchecked_Access) = 6,    "and is passed by reference");
      check (Buffer.sum (Buffer_owner.get (the_Owner).all) = 21,   "the buffer is reached through it");

      check (take_owned (the_Owner) = 21,                 "the pointer is passed by value");
      check (Buffer_owner.get (the_Owner) = null,         "which moves it, so that the pointer of the caller owns nothing");
      check (buffers_alive = 0,                           "and the function has freed the buffer");

      make_owned (2, the_Owner'unchecked_Access);
      check (buffers_alive = 1,                           "the pointer is given another buffer");

      Buffer_owner.destruct (the_Owner);
      check (buffers_alive = 0,                           "which it frees when it is destructed");
   end owners;

   finish;
end Tester;
