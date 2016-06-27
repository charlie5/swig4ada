
with ref_example.Binding;               use ref_example.Binding;
with ref_example.Vector;               use ref_example.Vector;
with ref_example.vectorArray;          use ref_example.vectorArray;

with interfaces.c.strings; use interfaces.c.strings;
                           use interfaces.C;
with ada.Text_IO;          use ada.Text_IO;
with system;





procedure Tester
is
   use ref_example;

   A : aliased Vector.item := construct ( 3.0,  4.0,  5.0);
   B : aliased Vector.item := construct (10.0, 11.0, 12.0);

   VA : aliased VectorArray.item := construct (10);
begin

   put_Line ("Vector A => " & Value (print (A)));
   put_Line ("Vector B => " & Value (print (B)));
--   put_Line ("Vector A => " & Value (print (A'access)));
--   put_Line ("Vector B => " & Value (print (B'access)));

   declare
      C : aliased Vector.item := addv (A'unchecked_access, B'unchecked_access);
      --C : aliased Vector.item := addv (A, B);
   begin
      put_Line ("Vector A + B => " & Value (print (C)));
--      put_Line ("Vector A + B => " & Value (print (C'access)));
   end;


   --set (VA'access,  0, A'unchecked_access);
   --set (VA'access,  1, B'unchecked_access);
   set (VA,  0, A'access);
   set (VA,  1, B'access);

   for each in 0 .. 5 loop
      declare
         --the_Item : access Vector.item := get (VA'access, Int (each));
         the_Item : access Vector.item := get (VA, Int (each));
      begin
         put_line ("VA (" & integer'image (Each) & ") => " & Value (print (the_Item.all)));
--         put_line ("VA (" & integer'image (Each) & ") => " & Value (print (the_Item)));
      end;
   end loop;


   for each in 0 .. 10_000_000 loop
     declare
        --D : access Vector.item := get (VA'access, Int (each mod 10));
        D : access Vector.item := get (VA, Int (each mod 10));
     begin
        null;
     end;
   end loop;


end Tester;




--// This example illustrates the manipulation of C++ references in C#.

--using System;

--public class runme {

--  public static void Main()
--  {
--    Console.WriteLine( "Creating some objects:" );
--    Vector a = new Vector(3,4,5);
--    Vector b = new Vector(10,11,12);

--    Console.WriteLine( "    Created " + a.print() );
--    Console.WriteLine( "    Created " + b.print() );

--    // ----- Call an overloaded operator -----

--    // This calls the wrapper we placed around
--    //
--    //      operator+(const Vector &a, const Vector &)
--    //
--    // It returns a new allocated object.

--    Console.WriteLine( "Adding a+b" );
--    Vector c = example.addv(a,b);
--    Console.WriteLine( "    a+b = " + c.print() );

--    // Note: Unless we free the result, a memory leak will occur if the -noproxy commandline
--    // is used as the proxy classes define finalizers which call the Dispose() method. When
--    // -noproxy is not specified the memory management is controlled by the garbage collector.
--    // You can still call Dispose(). It will free the c++ memory immediately, but not the
--    // C# memory! You then must be careful not to call any member functions as it will
--    // use a NULL c pointer on the underlying c++ object. We set the C# object to null
--    // which will then throw a C# exception should we attempt to use it again.
--    c.Dispose();
--    c = null;

--    // ----- Create a vector array -----

--    Console.WriteLine( "Creating an array of vectors" );
--    VectorArray va = new VectorArray(10);
--    Console.WriteLine( "    va = " + va.ToString() );

--    // ----- Set some values in the array -----

--    // These operators copy the value of Vector a and Vector b to the vector array
--    va.set(0,a);
--    va.set(1,b);

--    // This works, but it would cause a memory leak if -noproxy was used!

--    va.set(2,example.addv(a,b));


 --   // Get some values from the array

--    Console.WriteLine( "Getting some array values" );
--    for (int i=0; i<5; i++)
--        Console.WriteLine( "    va(" + i + ") = " + va.get(i).print() );
--
--    // Watch under resource meter to check on this
--    Console.WriteLine( "Making sure we don't leak memory." );
--    for (int i=0; i<1000000; i++)
--        c = va.get(i%10);

--    // ----- Clean up -----
--    // This could be omitted. The garbage collector would then clean up for us.
--    Console.WriteLine( "Cleaning up" );
--    va.Dispose();
--    a.Dispose();
--    b.Dispose();
--  }
--}
