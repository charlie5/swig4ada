with
     directors.Speaker.Director,
     directors.Voice.Director,
     directors.Talker.Director,
     directors.Label,
     directors.Point,
     swig.std_Strings,
     interfaces.C;

package Speakers
--
--  Two classes which are declared in Ada and derived from the directors of C++ classes, each of which overrides
--  functions that Ada cannot call through the vtable of its class, and which C++ calls.
--
is
   use directors,
       swig.std_Strings,
       interfaces.C;

   type Parrot is new Speaker.Director.Item with
      record
         Calls : Natural := 0;
      end record;

   overriding
   procedure speak  (Self   : in out Parrot;
                     word   : in     std_string_Pointer;
                     Result : in     std_string_Pointer);
   overriding
   procedure speak  (Self   : in out Parrot;
                     times  : in     int;
                     Result : in     std_string_Pointer);
   overriding
   procedure label  (Self   : in out Parrot;
                     Result : in     directors.Label.Pointer);
   overriding
   function  sum    (Self   : access Parrot;
                     p      : in     Point.Item) return int;
   overriding
   procedure secret (Self   : in out Parrot;
                     Result : in     std_string_Pointer);
   overriding
   function  level  (Self   : access Parrot) return int;     -- A virtual function which Ada calls through the vtable of the class.

   pragma Convention (CPP, speak);
   pragma Convention (CPP, label);
   pragma Convention (CPP, sum);
   pragma Convention (CPP, secret);
   pragma Convention (CPP, level);



   type Choir is new Voice.Director.Item with null record;     -- Of an abstract class.

   overriding
   procedure name  (Self   : in out Choir;
                    Result : in     std_string_Pointer);
   overriding
   function  pitch (Self   : access Choir) return int;

   pragma Convention (CPP, name);
   pragma Convention (CPP, pitch);



   type Chatter is new Talker.Director.Item with null record;     -- Of a class which inherits the functions of its director.

   overriding
   procedure speak  (Self   : in out Chatter;
                     word   : in     std_string_Pointer;
                     Result : in     std_string_Pointer);
   overriding
   procedure accent (Self   : in out Chatter;
                     Result : in     std_string_Pointer);

   pragma Convention (CPP, speak);
   pragma Convention (CPP, accent);

end Speakers;
