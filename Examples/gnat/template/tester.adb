
with template_example.Binding; use template_example.Binding;

with template_example.vecInt;         use template_example.vecInt;
with template_example.vecDouble;      use template_example.vecDouble;

with interfaces.C;   use interfaces.C;
with ada.text_IO;    use ada.text_IO;



procedure Tester
is
   use template_example;

   Vector_integer : aliased vecInt.item    := construct (sz =>  100);
   Vector_double  : aliased vecDouble.item := construct (sz => 1000);
   
   Sum_integer : Int    := 0;
   Sum_double  : Double := 0.0;
begin

   put_Line ("maxInt    (   3,    7) => " & int'Image    (maxInt    (   3,    7)));
   put_Line ("maxDouble (3.14, 2.18) => " & double'Image (maxDouble (3.14, 2.18)));
   

   
   for each in Int range 0 .. 99 loop
      setItem (Vector_integer, each, 2 * each);
   end loop;
   
   for each in Int range 0 .. 99 loop
      Sum_integer := Sum_integer + getItem (Vector_integer, each);
   end loop;
   
   new_Line;
   put_line ("Sum_integer => " & int'Image (Sum_integer));
   

   declare
      check_Result : Double := 0.0;
   begin
      for each in Int range 0 .. 999 loop
         setItem (Vector_double, each, 1.0 / (Double (each + 1)));
         check_Result := check_Result + 1.0 / (Double (each + 1));
      end loop;
      
      for each in Int range 0 .. 999 loop
         Sum_double := Sum_double + getItem (Vector_double, each);
      end loop;
   
      put_line ("Sum_double  => " & double'Image (Sum_double)  & "   should be " & double'Image (check_Result));
      new_Line;
   end;
   
end Tester;


--// This example illustrates how C++ templates can be used from C#.

--using System;

--public class runme {

--  public static void Main() 
--  {
--    // Call some templated functions
--    Console.WriteLine(example.maxint(3,7));
--    Console.WriteLine(example.maxdouble(3.14,2.18));
    
--    // Create some class
    
--    vecint iv = new vecint(100);
--    vecdouble dv = new vecdouble(1000);
    
--    for (int i=0; i<100; i++)
--        iv.setitem(i,2*i);
    
--    for (int i=0; i<1000; i++)
--          dv.setitem(i, 1.0/(i+1));
    
--    {
--        int sum = 0;
--        for (int i=0; i<100; i++)
--            sum = sum + iv.getitem(i);

--        Console.WriteLine(sum);
--    }
    
--    {
--        double sum = 0.0;
--        for (int i=0; i<1000; i++)
---            sum = sum + dv.getitem(i);
--        Console.WriteLine(sum);
--    }
--  }
--}
