
with string_example.Binding;        use string_example.Binding;
with string_example.Aaa;            use string_example.Aaa;

with Swig;                  use Swig;
with std_String.Binding;    use std_String.Binding;

with interfaces.C;   use interfaces.C;
with ada.Text_IO;    use ada.Text_IO;
with system;



procedure Tester
is
   use string_example;

   a_View : swig.std_String_view := new_std_String;
   solid  : swig.std_String      := std_String_construct;

begin

   put_Line ("std_string_Size: " & int'image (std_string_Size));

   foo (a_View.all);
   foo (Solid);


   declare
      an_Aaa : Aaa.item := construct;
   begin
      foo (an_Aaa.Name);
   end;



end Tester;

