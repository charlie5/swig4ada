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


   procedure log (Message : in unbounded_String)
   is
   begin
      log (to_String (Message));
   end log;


   function log (Message : in unbounded_String) return Boolean
   is
   begin
      log (to_String (Message));
      return True;
   end log;



   -----------------
   --- Debug logging.
   --

   debug_Log : File_type;
   log_Depth : Natural  := 0;


   procedure indent_Log
   is
   begin
      log_Depth := log_Depth + 1;
   end indent_Log;


   procedure unindent_Log
   is
   begin
      log_Depth := log_Depth - 1;
   end unindent_Log;


   procedure dlog (Message : in String)
   is
      Unused : Boolean := dlog (Message);
   begin
      null;
   end dlog;


   function dlog (Message : in String) return Boolean
   is
      Indent : constant String (1 .. 3 * log_Depth) := (others => ' ');
   begin
      put_Line (debug_Log, Indent & Message);
      return True;
   end dlog;


   procedure dlog (Message : in unbounded_String)
   is
   begin
      dlog (to_String (Message));
   end dlog;


   function dlog (Message : in unbounded_String) return Boolean
   is
   begin
      dlog (to_String (Message));
      return True;
   end dlog;


   ------------------------------------
   --- Initialisation and finalization.
   --

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
