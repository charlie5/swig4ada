-- This example illustrates how C++ classes can be used from Ada using SWIG.
-- The Ada class gets mapped onto the C++ class and behaves as if it is a C++ class.

with class_example.Shape;        use  class_example.Shape;
with class_example.Circle;       use  class_example.Circle;
with class_example.Square;       use  class_example.Square;

with interfaces.C; use interfaces.C;
with ada.text_IO;  use  ada.text_IO;



procedure Tester
is
   use class_example;
begin
   --delay 15.0;

   put_Line ("Creating some objects:");

   declare
      the_Square : aliased Square.item := construct (5.0);
      the_Circle : aliased Circle.item; -- := construct;
      --the_Circle2 : aliased Circle.item;
      --the_Circle3 : aliased Circle.item;
--      the_Square : aliased Square.item'Class := construct (10.0);
--      the_Circle : aliased Circle.item'Class := construct (10.0);
   begin
      --put_line("   A total of " & integer'image (shape.get_nShapes) & " shapes were created.");
--        put_line("   A total of " & int'Image (shape.nshapes) & " shapes were created.");
      --put_line("   A total of " & natural'Image (shape.nshapes) & " shapes were created.");

      the_Circle.X := 20.0;
      the_Circle.Y := 30.0;

      declare
         a_Shape : access Shape.item'Class := the_Square'access;
      begin
         a_Shape.X := -10.0;
         a_Shape.Y :=   5.0;
      end;

      new_Line;
      put_Line ("Here is their current position:");
      put_Line ("   Circle = (" & double'image (the_Circle.X)
                                & ","
                                & double'image (the_Circle.Y) & ")");
      put_Line ("   Square = (" & double'image (the_Square.X)
                                & ","
                                & double'image (the_Square.Y) & ")");


--        put_Line ("   circle perimeter (circle view):     " & double'Image (the_Circle.Perimeter));
--        put_Line ("   circle area      (circle view):     " & double'Image (the_Circle.Area));

      new_Line;
      put_Line ("Here are some properties of the shapes:");

      -- below fails when it trys to destruct (?!?) the shape during call to 'Area' function ...
      --
      declare
         the_Shapes : array (Positive range <>) of access Shape.item'Class := (the_Circle'Unchecked_Access,
                                                                               the_Square'Unchecked_Access);
      begin
         for each in the_Shapes'range loop
            put_Line ("Shape" & integer'Image (each) & ":");
            put_Line ("   area:     " & double'Image (the_Shapes (each).Area));
            put_Line ("   perimeter:" & double'Image (the_Shapes (each).Perimeter));
         end loop;
      end;


      new_Line;
      put_Line ("Guess I'll clean up now ...");

--        destruct (the_Circle);
--        destruct (the_Square);
   end;
   --
   -- note: end of scope causes auto-destruction of the_Circle and the_Square.

--     put_Line (int'Image (shape.nshapes) & " shapes remain.");

   put_Line ("Goodbye.");
end Tester;



-- C# version for comparison follows ...
--
--
--public class runme
--{
--    static void Main()
--    {
--        // ----- Object creation -----
--        Console.WriteLine( "Creating some objects:" );
--        using (Square s = new Square(10))
--        using (Circle c = new Circle(10))
--        {
--            Console.WriteLine( "    Created circle " + c );
--            Console.WriteLine( "    Created square " + s );
--            // ----- Access a static member -----
--            Console.WriteLine( "\nA total of " + Shape.nshapes + " shapes were created" );
--            // ----- Member data access -----
--            // Notice how we can do this using functions specific to
--            // the 'Circle' class.
--            c.x = 20;
--            c.y = 30;
--            // Now use the same functions in the base class
--            Shape shape = s;
--            shape.x = -10;
--            shape.y = 5;
--            Console.WriteLine( "\nHere is their current position:" );
--            Console.WriteLine( "    Circle = (" + c.x + " " + c.y + ")" );
--            Console.WriteLine( "    Square = (" + s.x + " " + s.y + ")" );
--            // ----- Call some methods -----
--            Console.WriteLine( "\nHere are some properties of the shapes:" );
--            Shape[] shapes = {c,s};
--            //            for (int i=0; i<shapes.Size; i++)
--            for (int i=0; i<2; i++)
--            {
--                Console.WriteLine( "   " + shapes[i].ToString() );
--                Console.WriteLine( "        area      = " + shapes[i].area() );
--                Console.WriteLine( "        perimeter = " + shapes[i].perimeter() );
--            }
--            // Notice how the area() and perimeter() functions really
--            // invoke the appropriate virtual method on each object.
--            // ----- Delete everything -----
--            Console.WriteLine( "\nGuess I'll clean up now" );
--        }
---        // Note: when this using scope is exited the C# Dispose() methods
--        // are called which in turn call the C++ destructors
--        Console.WriteLine( Shape.nshapes + " shapes remain" );
--        Console.WriteLine( "Goodbye" );
--    }
--}
