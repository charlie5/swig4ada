with
     typedef_funcptr;

package Operations
--
--  Functions of Ada which C++ calls through pointers to functions. The constants 'addf' and 'subf' of the interface
--  file are left out of the binding, as they name functions which are not of the module.
--
is
   --  The typedef 'Integer' is named in full, as 'Standard.Integer' is directly visible and would be taken for it.
   --
   function add      (x, y : in typedef_funcptr.Integer) return typedef_funcptr.Integer with Convention => C;
   function subtract (x, y : in typedef_funcptr.Integer) return typedef_funcptr.Integer with Convention => C;

end Operations;
