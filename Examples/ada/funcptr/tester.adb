
with function_Example.Binding;
use  function_Example.Binding;

with interfaces.C;   use interfaces.C;
with ada.Text_IO;    use ada.Text_IO;

with system;



with ada.Command_Line;

procedure Tester
is
   Failures : Natural := 0;


   procedure check (Condition : in Boolean;   What : in String)
   --
   --  Notes a result which is not as it should be, so that the tester ends with a failure status.
   --
   is
   begin
      if not Condition
      then
         ada.Text_IO.put_Line ("   FAILED  " & What);
         Failures := Failures + 1;
      end if;
   end check;

   A : Int := 37;
   B : Int := 42;

begin

   put_line ("A => 37");
   put_line ("B => 42");
      
   --put_Line ("ADD (A, B) = " & Int'image (do_op (A, B, jjj'access)));   -- ada callback function (prahma convention (C, ...) required.
   
   put_Line ("ADD (A, B) = " & Int'image (do_op (A, B, add'access)));
   put_Line ("SUB (A, B) = " & Int'image (do_op (A, B, sub'access)));
   put_Line ("MUL (A, B) = " & Int'image (do_op (A, B, mul'access)));

   check (do_op (A, B, add'Access) =   79,   "C calls the function 'add' which it is given");
   check (do_op (A, B, sub'Access) =   -5,   "and 'sub'");
   check (do_op (A, B, mul'Access) = 1554,   "and 'mul'");
--   put_Line ("ADD (A, B) = " & Int'image (do_op (A, B, add'access)));
--   put_Line ("SUB (A, B) = " & Int'image (do_op (A, B, sub'access)));
--   put_Line ("MUL (A, B) = " & Int'image (do_op (A, B, mul'access)));
   if Failures /= 0
   then
      ada.Command_Line.set_exit_Status (ada.Command_Line.Failure);
   end if;
  
end Tester;




--using System;
--using System.Reflection;

--public class runme {

--  public static void Main(String[] args) {


--    int a = 37;
--    int b = 42;

--    // Now call our C function with a bunch of callbacks

--    Console.WriteLine( "Trying some C callback functions" );
--    Console.WriteLine( "    a        = " + a );
--    Console.WriteLine( "    b        = " + b );
--    Console.WriteLine( "    ADD(a,b) = " + example.do_op(a,b,example.ADD) );
--    Console.WriteLine( "    SUB(a,b) = " + example.do_op(a,b,example.SUB) );
--    Console.WriteLine( "    MUL(a,b) = " + example.do_op(a,b,example.MUL) );

--    Console.WriteLine( "Here is what the C callback function classes are called in C#" );
--    Console.WriteLine( "    ADD      = " + example.ADD.GetType() );
--    Console.WriteLine( "    SUB      = " + example.SUB.GetType() );
--    Console.WriteLine( "    MUL      = " + example.MUL.GetType() );
--  }
--}
