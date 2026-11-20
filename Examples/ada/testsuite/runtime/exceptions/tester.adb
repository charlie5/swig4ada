with
     exceptions.Binding,

     interfaces.C.Strings,

     Checks;


procedure Tester
--
--  A C++ exception does not leave a wrapper. It is recorded, and may be examined from Ada.
--
is
   use exceptions.Binding,
       interfaces.C,
       Checks;

   --  The record of the pending exception, which is part of every wrapper file.
   --
   function  pending_Exception      return int                with Import, Convention => C, External_Name => "swig_ada_pending_exception";
   function  pending_exception_Text return Strings.chars_ptr  with Import, Convention => C, External_Name => "swig_ada_pending_exception_text";
   procedure clear_pending_Exception                          with Import, Convention => C, External_Name => "swig_ada_clear_pending_exception";

   Result : int;
begin
   check (pending_Exception = 0,                   "no exception is pending at the start");

   check (checked_divide (12, 4) = 3,              "a call which does not throw returns its result");
   check (pending_Exception = 0,                   "and leaves no exception pending");

   Result := checked_divide (1, 0);
   check (pending_Exception /= 0,                  "a call which throws leaves an exception pending");
   check (String'(Strings.Value (pending_exception_Text))'Length > 0,   "the pending exception has a message");

   clear_pending_Exception;
   check (pending_Exception = 0,                   "the pending exception is cleared");

   Result := require_positive (-5);
   check (pending_Exception /= 0,                  "a thrown integer leaves an exception pending");
   clear_pending_Exception;

   check (require_positive (5) = 5,                        "a later call works as usual");
   check (pending_Exception = 0,                   "and leaves no exception pending");

   pragma Unreferenced (Result);
   finish;
end Tester;
