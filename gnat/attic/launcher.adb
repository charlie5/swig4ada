with
     gnat_Language,
     Swig.Pointers,
     Interfaces.C,
     Ada.command_Line;

procedure Launcher
is
   use Interfaces;

   function swig_main (argc : in C.int;
                       argv : in Swig.Pointers.chars_ptr_Pointer) return C.int;
   pragma import (C, swig_main, "_Z9swig_mainiPPc");

   argv : Swig.Pointers.chars_ptr_Pointer;
   pragma import (C, argv, "gnat_argv");

   Status : C.int;
begin
   Status := swig_main (C.int (ada.Command_Line.Argument_Count),
                        argv); -- ada.Command_Line.Argument);
end Launcher;
