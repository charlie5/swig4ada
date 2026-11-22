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


   -- Warnings.
   --
   --  A warning is given through the swig core, as those of the core and of the other languages are: it has a
   --  number, by which it may be turned off ('-w861', '%warnfilter (861)'), and names the file and the line
   --  of the declaration which it is about.
   --
   type warning_Kind is (not_Bound,        -- 861: a declaration is left out of the binding.
                         Layout,           -- 862: a record may not have the layout of its class or structure.
                         Value,            -- 863: a value could not be worked out, and another is used.
                         Unsupported);     -- 864: a construct of C++ for which Ada has no counterpart is bound in part.

   function  Number (Kind : in warning_Kind) return Positive;

   procedure locate (File : in String;   Line : in Natural;   Filter : in String := "");
   --
   --  Notes where the declaration which is now being read is. A warning is about that place, unless it names another.
   --  'Filter' holds the warnings which the interface file has turned off for that declaration ('%warnfilter').

   function  current_File   return String;
   function  current_Line   return Natural;
   function  current_Filter return String;

   procedure warn (Kind : in warning_Kind;   Message : in String);
   procedure warn (Kind : in warning_Kind;   Message : in unbounded_String);
   procedure warn (Kind : in warning_Kind;   Message : in String;
                                             File    : in String;
                                             Line    : in Natural;
                                             Filter  : in String := "");

   type Reporter is access procedure (Number  : in Positive;
                                      File    : in String;
                                      Line    : in Natural;
                                      Message : in String;
                                      Filter  : in String);
   procedure Reporter_is (Now : in Reporter);
   --
   --  The procedure which gives a warning to the swig core. Until there is one, a warning is printed.


   -- Debug log.
   --
   --  A record of what the module does, written to 'swig4ada-debug.log' in the current folder. It is written
   --  only where it is asked for: by the option '-debug-log', or by the environment variable 'SWIG4ADA_DEBUG'
   --  (of any value), which also catches what is done before the options are read.
   --
   procedure open_debug_Log;

   procedure   indent_Log;
   procedure unindent_Log;

   procedure dlog (Message : in String);
   function  dlog (Message : in String) return Boolean;

   procedure dlog  (Message : in unbounded_String);
   function  dlog  (Message : in unbounded_String) return Boolean;

end Logger;
