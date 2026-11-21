
with vars_example.Binding;  use vars_example.Binding;
with vars_example.Point;   use vars_example.Point;

with interfaces.c.strings; use interfaces.C;
                           use interfaces.c.Strings;
with ada.Text_IO;          use ada.Text_IO;



with ada.Command_Line;

procedure Tester
is
   use vars_example;

   use type interfaces.c.signed_Char;
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

begin

   ivar := 42;
   put_Line ("ivar => " & int'Image (ivar));
   
   svar := -31_000;
   put_Line ("svar => " & short'Image (svar));
   
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
   put_Line ("cvar => " & to_Ada (cvar));
   
   fvar := 3.14159;
   put_Line ("fvar => " & c_float'Image (fvar));
   
   dvar := 2.1828;
   put_Line ("dvar => " & double'Image (dvar));

   check (ivar = 42 and svar = -31_000 and lvar = 65_537,               "the signed integer variables hold what Ada gave them");
   check (uivar = 123_456 and usvar = 61_000 and ulvar = 654_321,       "and the unsigned ones");
   check (scvar = -13 and ucvar = 251 and cvar = 'S',                   "and those of the character types");
   check (fvar = 3.14159 and dvar = 2.1828,                             "and the real ones");
   
   strvar := new_String ("hello world");
   put_Line ("strvar => " & Value (strvar));

   put_Line ("cstrvar => " & to_Ada (cstrvar));
   put_Line ("done cstrvar");

   check (String'(Value (strvar)) = "hello world",                      "a string variable holds the string which Ada gave it");
   check (to_Ada (cstrvar) = "Goodbye",                                 "a constant array of characters has the text which C gave it");
   
    

   
   iptrvar := new_Int (37);
   put_Line ("iptrvar.all => " & int'Image (iptrvar.all));
   
   put_Line ("name => " & to_Ada (vars_example.name));
   
   ptptr := new Point.item'(37, 42);
   put_Line ("ptptr => " & Value (Point_print (ptptr)));
   
   put_Line ("pt => " & Value (Point_print (pt'access)));

   check (iptrvar.all = 37,                                             "a pointer variable points to the integer which C made");
   check (to_Ada (vars_example.name) = "Dave",                          "an array of characters has the text which C gave it");
   check (String'(Value (Point_print (ptptr)))     = "(37,42)",         "C reads a structure which Ada allocated");
   check (String'(Value (Point_print (pt'Access))) = "(10,20)",         "and the structure variable which C declares");
   
   new_Line;
   put_Line ("... values printed from 'C' ...");
   new_Line;
   vars_example.Binding.print_Vars;
      
   pt := ptptr.all;
   
   put_Line ("Changed 'pt' => ");
   pt_print;

   check (pt.x = 37 and pt.y = 42,                                      "a structure variable is assigned to");
   check (String'(Value (Point_print (pt'Access))) = "(37,42)",         "and C sees its new value");

--    example.pt = example.ptptr;

--    Console.WriteLine( "The new value is" );
--    example.pt_print();
--    Console.WriteLine( "You should see the value" + example.Point_print(example.ptptr) );
--  }
   if Failures /= 0
   then
      ada.Command_Line.set_exit_Status (ada.Command_Line.Failure);
   end if;
      
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
