with
     ada.Text_IO,
     ada.Finalization;

package body Logger
is
   use ada.Text_IO;


   -----------------
   --- User logging.
   --

   procedure log (Message : in String)
   is
      Unused : Boolean := log (Message);
   begin
      null;
   end log;



   function log (Message : in String) return Boolean
   is
   begin
      put_Line (Message);
      dlog     (Message);

      return True;
   end log;



   -----------------
   --- Debug logging.
   --

   debug_Log : File_type;

   procedure dlog (Message : in String)
   is
      Unused : Boolean := dlog (Message);
   begin
      null;
   end dlog;



   function dlog (Message : in String) return Boolean
   is
   begin
      put_Line (Message);
      return True;
   end dlog;



   type Closure is new ada.Finalization.Controlled with null record;

   overriding
   procedure Finalize (Object : in out Closure)
   is
   begin
      close (debug_Log);
   end Finalize;

   Closer : Closure with unreferenced;


begin
   create (debug_Log, out_File, "swig4ada-debug.log");
end Logger;
