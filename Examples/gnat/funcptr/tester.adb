
with fun_example.Binding; use fun_example.Binding;

with interfaces.C;   use interfaces.C;
with ada.Text_IO;    use ada.Text_IO;

with system;



procedure Tester
is
   A : Int := 37;
   B : Int := 42;

begin

   put_line ("A => 37");
   put_line ("B => 42");
      
   --put_Line ("ADD (A, B) = " & Int'image (do_op (A, B, jjj'access)));   -- ada callback function (prahma convention (C, ...) required.
   
   put_Line ("ADD (A, B) = " & Int'image (do_op (A, B, add'access)));
   put_Line ("SUB (A, B) = " & Int'image (do_op (A, B, sub'access)));
   put_Line ("MUL (A, B) = " & Int'image (do_op (A, B, mul'access)));
--   put_Line ("ADD (A, B) = " & Int'image (do_op (A, B, add'access)));
--   put_Line ("SUB (A, B) = " & Int'image (do_op (A, B, sub'access)));
--   put_Line ("MUL (A, B) = " & Int'image (do_op (A, B, mul'access)));
  
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
