with
     ada.Text_IO,
     ada.Strings.fixed,
     ada.Environment_Variables,
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



   -------------
   --- Warnings.
   --

   the_File     : unbounded_String;
   the_Line     : Natural := 0;
   the_Filter   : unbounded_String;
   the_Reporter : Reporter;


   function Number (Kind : in warning_Kind) return Positive
   is
   begin
      return (case Kind is
                 when not_Bound   => 861,
                 when Layout      => 862,
                 when Value       => 863,
                 when Unsupported => 864);
   end Number;



   procedure locate (File : in String;   Line : in Natural;   Filter : in String := "")
   is
   begin
      the_File   := to_unbounded_String (File);
      the_Line   := Line;
      the_Filter := to_unbounded_String (Filter);
   end locate;



   function current_File return String
   is
   begin
      return to_String (the_File);
   end current_File;



   function current_Line return Natural
   is
   begin
      return the_Line;
   end current_Line;



   function current_Filter return String
   is
   begin
      return to_String (the_Filter);
   end current_Filter;



   procedure warn (Kind : in warning_Kind;   Message : in String;
                                             File    : in String;
                                             Line    : in Natural;
                                             Filter  : in String := "")
   is
   begin
      dlog ("Warning" & Positive'Image (Number (Kind)) & ": " & Message);

      if the_Reporter = null
      then
         put_Line (File & ":" & ada.Strings.fixed.Trim (Line'Image, ada.Strings.Left) & ": Warning" & Positive'Image (Number (Kind)) & ": " & Message);
      else
         the_Reporter (Number (Kind), File, Line, Message, Filter);
      end if;
   end warn;



   procedure warn (Kind : in warning_Kind;   Message : in String)
   is
   begin
      warn (Kind, Message, current_File, current_Line, current_Filter);
   end warn;



   procedure warn (Kind : in warning_Kind;   Message : in unbounded_String)
   is
   begin
      warn (Kind, to_String (Message));
   end warn;



   procedure Reporter_is (Now : in Reporter)
   is
   begin
      the_Reporter := Now;
   end Reporter_is;



   -----------------
   --- Debug logging.
   --

   debug_Log : File_type;
   log_Depth : Natural  := 0;


   procedure open_debug_Log
   is
   begin
      if not is_Open (debug_Log)
      then
         create (debug_Log, out_File, "swig4ada-debug.log");
      end if;
   end open_debug_Log;


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
      Indent : constant String (1 .. 3 * log_Depth) := [others => ' '];
   begin
      if is_Open (debug_Log)
      then
         put_Line (debug_Log, Indent & Message);
      end if;

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
      if is_Open (debug_Log)
      then
         close (debug_Log);
      end if;
   end Finalize;

   Closer : Closure with unreferenced;


begin
   if ada.Environment_Variables.exists ("SWIG4ADA_DEBUG")
   then
      open_debug_Log;
   end if;
end Logger;
