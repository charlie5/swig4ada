
with simple_example.Binding; use simple_example.Binding;

with ada.text_IO;    use ada.text_IO;
with interfaces.C;   use interfaces.C; 


procedure Tester 
is
begin

   put_Line ("Foo is " & double'Image (Foo));
   Foo := 5.0;
   put_Line ("Foo is " & double'Image (Foo));
   
   put_Line ("Greatest common denominator of 100 & 15 is " & int'Image (GCD (100, 15)));

end Tester;
