with
     assimp.ProgressHandler,
     assimp.LogStream,
     interfaces.C.Strings,
     swig;

package Listeners
--
-- A progress handler and a log stream which are declared in Ada and derived from those of Assimp, whose functions
-- Assimp calls through the vtable as it imports a scene. They are at library level, as Assimp calls them.
--
is
   use assimp;

   type Progress is new ProgressHandler.Item with
      record
         Calls : Natural              := 0;     -- How many times Assimp has told of its progress.
         Last  : interfaces.C.C_float := 0.0;   -- How far it said it was, the last time.
      end record;

   overriding
   function Update (Self : access Progress;   percentage : in interfaces.C.C_float) return swig.bool;
   pragma Convention (CPP, Update);


   type Log is new LogStream.Item with
      record
         Messages : Natural := 0;     -- How many messages Assimp has written to it.
      end record;

   overriding
   procedure write (Self : in out Log;   message : in interfaces.C.Strings.chars_ptr);
   pragma Convention (CPP, write);

end Listeners;
