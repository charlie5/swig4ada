with
     exceptions.Binding,
     exceptions.the_exception,
     exceptions.Failure,
     exceptions.Plain,

     swig.Exceptions,
     interfaces.C.Strings,
     ada.Exceptions,

     Checks;


procedure Tester
--
--  A C++ exception does not leave a wrapper. It is recorded, and the
--  program asks after a call whether one is pending.
--
is
   use exceptions.Binding,
       interfaces.C,
       Checks;

   Result : int;
begin
   check (not swig.Exceptions.is_Pending,          "no exception is pending at the start");

   check (checked_divide (12, 4) = 3,              "a call which does not throw returns its result");
   check (not swig.Exceptions.is_Pending,          "and leaves no exception pending");

   swig.Exceptions.check;                          -- Does nothing, as none is pending.

   Result := checked_divide (1, 0);
   check (swig.Exceptions.is_Pending,              "a call which throws leaves an exception pending");
   check (swig.Exceptions.pending_Message = "division by zero",   "the pending exception has the message of the C++ exception");

   swig.Exceptions.clear;
   check (not swig.Exceptions.is_Pending,          "the pending exception is cleared");

   raises_an_Ada_exception :
   declare
      use type swig.Exceptions.Kind;
      Raised : Boolean := False;
   begin
      Result := require_positive (-5);
      check (swig.Exceptions.pending_Kind /= swig.Exceptions.None,   "a thrown integer leaves an exception pending");

      begin
         swig.Exceptions.check;
      exception
         when swig.Exceptions.Error =>
            Raised := True;
      end;

      check (Raised,                               "the check raises an Ada exception");
      check (not swig.Exceptions.is_Pending,       "and forgets the pending exception");
   end raises_an_Ada_exception;

   the_kind_of_a_standard_exception :
   declare
      use type swig.Exceptions.Kind;
      Message_is_right : Boolean := False;
   begin
      check (element (1) = 20,                     "a call within range returns its result");

      Result := element (7);
      check (swig.Exceptions.pending_Kind = swig.Exceptions.Index_out_of_Range,   "a standard exception is recorded by its kind");

      begin
         swig.Exceptions.check;
      exception
         when E : swig.Exceptions.Error =>
            Message_is_right := ada.Exceptions.exception_Message (E) = "index is out of range";
      end;

      check (Message_is_right,                     "the Ada exception carries the message of the C++ exception");
   end the_kind_of_a_standard_exception;

   check (require_positive (5) = 5,                "a later call works as usual");
   check (not swig.Exceptions.is_Pending,          "and leaves no exception pending");

   classes_derived_from_standard_Exceptions :
   declare
      use exceptions,
          interfaces.C.Strings;

      Why         :         chars_ptr        := new_String ("disk full");
      the_Failure : aliased Failure.Item := Failure.construct (Why, 28);
      the_Plain   : aliased Plain.Item   := Plain.construct;

      function Text (From : in chars_ptr) return String renames interfaces.C.Strings.Value;
   begin
      --  A class which is derived from 'std::runtime_error' or 'std::exception' has the layout of its class, a pointer
      --  to its table and the message of the exception among it, and its virtual functions are in their places.
      --
      check (Failure.Item'Object_Size / 8 = size_of_failure,                       "a class derived from 'std::runtime_error' has the size of its class");
      check (Failure.code (the_Failure'Access) = 28,                              "and C++ finds its member, after the message of its base");
      check (Text (what_of (the_exception.Pointer'(the_Failure'unchecked_Access))) = "disk full",
                                                                                  "C++ calls 'what' through the vtable");
      check (Text (Failure.what (the_Failure'Access)) = "disk full",             "and so does Ada");
      check (Failure.level (the_Failure'Access) = 2,                              "and a virtual function of its own, after those of its bases");

      check (Plain.Item'Object_Size / 8 = size_of_plain,                          "a class derived from 'std::exception' has the size of its class");
      check (Plain.n (the_Plain'Access) = 7,                                      "and C++ finds its member, after the pointer to its table");
      check (Text (what_of (the_exception.Pointer'(the_Plain'unchecked_Access))) = "plain",
                                                                                  "and its own 'what', through the vtable");

      Plain.destruct_0   (the_Plain);
      Failure.destruct_0 (the_Failure);
      free (Why);
   end classes_derived_from_standard_Exceptions;

   pragma Unreferenced (Result);
   finish;
end Tester;
