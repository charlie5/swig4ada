with
     interfaces.C;

package body Operations
is
   use interfaces.C;


   function add (x, y : in typedef_funcptr.Integer) return typedef_funcptr.Integer
   is
   begin
      return x + y;
   end add;


   function subtract (x, y : in typedef_funcptr.Integer) return typedef_funcptr.Integer
   is
   begin
      return x - y;
   end subtract;

end Operations;
