with
     system.Address_to_Access_Conversions;

package body ada_Functions
is
   package int_Conversions is new system.Address_to_Access_Conversions (int);


   function weigh (the_Sample : in Sample.Pointer) return double
   is
   begin
      return the_Sample.value * 10.0;
   end weigh;



   procedure collect (Value : in int;   Context : in swig.void_ptr)
   is
      Total : constant int_Conversions.Object_Pointer := int_Conversions.to_Pointer (Context);
   begin
      Total.all := Total.all + Value;
   end collect;



   function length_of (Name : in Strings.chars_ptr) return int
   is
   begin
      return int (Strings.Strlen (Name));
   end length_of;



   function make (Id : in int) return Sample.Item
   is
   begin
      return (id    => Id,
              value => 0.5);
   end make;



   procedure tell (To : in Listener.Pointer;   What : in int)
   is
   begin
      To.hear (What);
   end tell;



   procedure reset (the_Sample : in Sample.Pointer)
   is
   begin
      the_Sample.id    := 0;
      the_Sample.value := 0.0;
   end reset;

end ada_Functions;
