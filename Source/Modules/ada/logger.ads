package Logger
is

   -- User log.
   --
   procedure log  (Message : in String);
   function  log  (Message : in String) return Boolean;

   -- Debug log.
   --
   procedure dlog (Message : in String);
   function  dlog (Message : in String) return Boolean;

end Logger;
