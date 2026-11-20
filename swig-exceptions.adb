with
     interfaces.C.Strings;

package body swig.Exceptions
is
   --  The functions of the wrapper file (see 'Lib/ada/adahead.swg').
   --
   function  pending_Code return C.int;
   function  pending_Text return C.Strings.chars_ptr;
   procedure clear_Pending;

   pragma Import (C, pending_Code,  "swig_ada_pending_exception");
   pragma Import (C, pending_Text,  "swig_ada_pending_exception_text");
   pragma Import (C, clear_Pending, "swig_ada_clear_pending_exception");



   function is_Pending return Boolean
   is
      use type C.int;
   begin
      return pending_Code /= 0;
   end is_Pending;



   function pending_Kind return Kind
   is
      the_Code : constant C.int := pending_Code;
   begin
      if the_Code in 0 .. Kind'Pos (Kind'Last)
      then
         return Kind'Val (the_Code);
      else
         return General;
      end if;
   end pending_Kind;



   function pending_Message return String
   is
   begin
      return C.Strings.Value (pending_Text);
   end pending_Message;



   procedure clear
   is
   begin
      clear_Pending;
   end clear;



   procedure check
   is
   begin
      if is_Pending
      then
         declare
            the_Message : constant String := pending_Message;
         begin
            clear_Pending;
            raise Error with the_Message;
         end;
      end if;
   end check;

end swig.Exceptions;
