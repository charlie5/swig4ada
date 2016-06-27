
with vars_example.Binding;  use vars_example.Binding;
with vars_example.Point;   use vars_example.Point;

with interfaces.c.strings; use interfaces.C;
                           use interfaces.c.Strings;
with ada.Text_IO;          use ada.Text_IO;



procedure Tester
is
   use vars_example;

   use type interfaces.c.signed_Char;
begin

   ivar := 42;
   put_Line ("ivar => " & int'Image (ivar));
   
   svar := -31_000;
   put_Line ("svar => " & short_Integer'Image (svar));
   
   lvar := 65_537;
   put_Line ("lvar => " & long'Image (lvar));
   
   uivar := 123_456;
   put_Line ("uivar => " & interfaces.c.unsigned'Image (uivar));
   
   usvar := 61000;
   put_Line ("usvar => " & interfaces.c.unsigned_short'Image (usvar));
   
   ulvar := 654_321;
   put_Line ("ulvar => " & interfaces.c.unsigned_long'Image (ulvar));
   
   scvar := -13;
   put_Line ("scvar => " & interfaces.c.signed_Char'Image (scvar));
   
   ucvar := 251;
   put_Line ("ucvar => " & interfaces.c.unsigned_Char'Image (ucvar));
   
   cvar := 'S';
   put_Line ("cvar => " & cvar);
   
   fvar := 3.14159;
   put_Line ("fvar => " & c_float'Image (fvar));
   
   dvar := 2.1828;
   put_Line ("dvar => " & double'Image (dvar));
   
   strvar := new_String ("hello world");
   put_Line ("strvar => " & Value (strvar));

   put_Line ("cstrvar => " & to_Ada (cstrvar));
   put_Line ("done cstrvar");
   
    

   
   iptrvar := new_Int (37);
   put_Line ("iptrvar.all => " & int'Image (iptrvar.all));
   
   put_Line ("name => " & to_Ada (vars_example.Binding.name));
   
   ptptr := new Point.item'(37, 42);
   put_Line ("ptptr => " & Value (Point_print (ptptr)));
   
   put_Line ("pt => " & Value (Point_print (pt'access)));
   
   new_Line;
   put_Line ("... values printed from 'C' ...");
   new_Line;
   vars_example.Binding.print_Vars;
      
   pt := ptptr.all;
   
   put_Line ("Changed 'pt' => ");
   pt_print;

--    example.pt = example.ptptr;

--    Console.WriteLine( "The new value is" );
--    example.pt_print();
--    Console.WriteLine( "You should see the value" + example.Point_print(example.ptptr) );
--  }
      
end Tester;



-- This example illustrates global variable access from C#.

--using System;
--using System.Reflection;

--public class runme {

--  public static void Main() {

--    // Try to set the values of some global variables

--    example.ivar   =  42;
--    example.svar   = -31000;
--    example.lvar   =  65537;
--    example.uivar  =  123456;
--    example.usvar  =  61000;
--    example.ulvar  =  654321;
--    example.scvar  =  -13;
--    example.ucvar  =  251;
--    example.cvar   =  'S';
--    example.fvar   =  (float)3.14159;
--    example.dvar   =  2.1828;
--    example.strvar =  "Hello World";
--    example.iptrvar= example.new_int(37);
--    example.ptptr  = example.new_Point(37,42);
--    example.name   = "Bill";

--    // Now print out the values of the variables

--    Console.WriteLine( "Variables (values printed from C#)" );

--    Console.WriteLine( "ivar      =" + example.ivar );
--    Console.WriteLine( "svar      =" + example.svar );
--    Console.WriteLine( "lvar      =" + example.lvar );
--    Console.WriteLine( "uivar     =" + example.uivar );
--    Console.WriteLine( "usvar     =" + example.usvar );
--    Console.WriteLine( "ulvar     =" + example.ulvar );
--    Console.WriteLine( "scvar     =" + example.scvar );
--    Console.WriteLine( "ucvar     =" + example.ucvar );
--    Console.WriteLine( "fvar      =" + example.fvar );
--    Console.WriteLine( "dvar      =" + example.dvar );
--    Console.WriteLine( "cvar      =" + example.cvar );
--    Console.WriteLine( "strvar    =" + example.strvar );
--    Console.WriteLine( "cstrvar   =" + example.cstrvar );
--    Console.WriteLine( "iptrvar   =" + example.iptrvar );
--    Console.WriteLine( "name      =" + example.name );
--    Console.WriteLine( "ptptr     =" + example.ptptr + example.Point_print(example.ptptr) );
--    Console.WriteLine( "pt        =" + example.pt + example.Point_print(example.pt) );

--    Console.WriteLine( "\nVariables (values printed from C)" );

--    example.print_vars();

--    Console.WriteLine( "\nNow I'm going to try and modify some read only variables" );
--    Console.WriteLine( "\nChecking that the read only variables are readonly..." );

--    example ex = new example();
--    Type t = ex.GetType();

--    Console.WriteLine( "     'path'" );
--    PropertyInfo pi = t.GetProperty("path");
--    if (pi.CanWrite)
--      Console.WriteLine("Oh dear this variable is not read only\n");
--    else
--      Console.WriteLine("Good.");

--    Console.WriteLine( "     'status'" );
--    pi = t.GetProperty("status");
--    if (pi.CanWrite)
--      Console.WriteLine("Oh dear this variable is not read only");
--    else
--      Console.WriteLine("Good.");

--    Console.WriteLine( "\nI'm going to try and update a structure variable.\n" );

--    example.pt = example.ptptr;

--    Console.WriteLine( "The new value is" );
--    example.pt_print();
--    Console.WriteLine( "You should see the value" + example.Point_print(example.ptptr) );
--  }
--}
