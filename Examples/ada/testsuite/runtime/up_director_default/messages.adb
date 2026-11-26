with
     interfaces.C;

package body Messages
is
   use interfaces.C;


   overriding
   procedure Msg (Self   : in out Echo;
                  msg    : in     std_String;
                  Result : in     std_string_Pointer)
   is
      pragma Unreferenced (Self);
   begin
      assign (Result.all, to_C ("echo " & to_Ada (msg)));
   end Msg;

end Messages;
