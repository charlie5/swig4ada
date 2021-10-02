with
     ada.Strings.unbounded;

package Logger
is
   use ada.Strings.unbounded;

   -- User log.
   --
   procedure log  (Message : in String);
   function  log  (Message : in String) return Boolean;

   procedure log  (Message : in unbounded_String);
   function  log  (Message : in unbounded_String) return Boolean;


   -- Debug log.
   --
   procedure   indent_Log;
   procedure unindent_Log;

   procedure dlog (Message : in String);
   function  dlog (Message : in String) return Boolean;

   procedure dlog  (Message : in unbounded_String);
   function  dlog  (Message : in unbounded_String) return Boolean;

end Logger;
