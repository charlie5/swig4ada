with
     director_default.Foo.Director,
     swig.std_Strings;

package Messages
--
--  A class which is declared in Ada and derived from the director of 'Foo', whose virtual function 'Msg' has a
--  default argument and returns a string by value, and which C++ calls.
--
is
   use director_default,
       swig.std_Strings;

   type Echo is new Foo.Director.Item with null record;

   overriding
   procedure Msg (Self   : in out Echo;
                  msg    : in     std_String;
                  Result : in     std_string_Pointer);

   pragma Convention (CPP, Msg);

end Messages;
