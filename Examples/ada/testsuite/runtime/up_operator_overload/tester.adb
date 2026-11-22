with
     operator_overload.Binding,
     operator_overload.Op,

     swig,
     interfaces.C,

     Checks;


procedure Tester
--
--  The case 'operator_overload' of upstream's suite, after its Python test: a class which overloads
--  the operators of C++, as members and as friends. Each is a named subprogram in Ada ('Plus',
--  'EqualEqual', 'PlusEqual', 'Functor'), and one which returns an object gives it by 'Result'.
--
is
   use operator_overload,
       operator_overload.Binding,
       interfaces.C,
       Checks;

   use type swig.bool;

   function is_True (Value : in swig.bool) return Boolean
   is (Value /= swig.bool'Val (0));

   a  : aliased Op.Item := Op.Item (Op.construct);
   b  : aliased Op.Item := Op.Item (Op.construct (5));
   c  : aliased Op.Item := Op.Item (Op.construct (Op.Pointer'(b'unchecked_Access)));     -- A copy.
   d  : aliased Op.Item := Op.Item (Op.construct (2));
   e  : aliased Op.Item := Op.Item (Op.construct (3));
   f  : aliased Op.Item := Op.Item (Op.construct (1));
   g  : aliased Op.Item := Op.Item (Op.construct (1));

   Result : aliased Op.Item := Op.Item (Op.construct (0));

   function Same (Left : in Op.Pointer;   Value : in int) return Boolean
   is
      the_Value : aliased Op.Item := Op.Item (Op.construct (Value));
   begin
      return is_True (EqualEqual (Left, the_Value'unchecked_Access));
   end Same;

   Unused : Op.Pointer with Unreferenced;

begin
   Op.sanity_check;

   check (    is_True (NotEqual         (a'unchecked_Access, b'unchecked_Access)),     "a != b");
   check (    is_True (EqualEqual       (b'unchecked_Access, c'unchecked_Access)),     "b == c, its copy");
   check (    is_True (NotEqual         (a'unchecked_Access, d'unchecked_Access)),     "a != d");
   check (    is_True (LessThan         (a'unchecked_Access, b'unchecked_Access)),     "a < b");
   check (    is_True (LessThanEqual    (a'unchecked_Access, b'unchecked_Access)),     "a <= b");
   check (    is_True (LessThanEqual    (b'unchecked_Access, c'unchecked_Access)),     "b <= c");
   check (    is_True (GreaterThanEqual (b'unchecked_Access, c'unchecked_Access)),     "b >= c");
   check (    is_True (GreaterThan      (b'unchecked_Access, d'unchecked_Access)),     "b > d");
   check (not is_True (GreaterThan      (d'unchecked_Access, b'unchecked_Access)),     "and not d > b");

   Unused := Op.PlusEqual (e'Access, d'unchecked_Access);
   check (is_True (EqualEqual (e'unchecked_Access, b'unchecked_Access)),     "e += d");

   Unused := Op.MinusEqual (e'Access, c'unchecked_Access);
   check (is_True (EqualEqual (e'unchecked_Access, a'unchecked_Access)),     "e -= c");

   Unused := Op.Equal (e'Access, f'unchecked_Access);     -- Assignment.
   check (Same (e'unchecked_Access, 1),                                      "e = f");

   Unused := Op.MultiplyEqual (e'Access, b'unchecked_Access);
   check (is_True (EqualEqual (e'unchecked_Access, c'unchecked_Access)),     "e *= b");

   Unused := Op.DivideEqual (e'Access, d'unchecked_Access);
   check (is_True (EqualEqual (e'unchecked_Access, d'unchecked_Access)),     "e /= d");

   Unused := Op.PercentEqual (e'Access, c'unchecked_Access);
   check (is_True (EqualEqual (e'unchecked_Access, d'unchecked_Access)),     "e %= c");

   Plus (f'unchecked_Access, g'unchecked_Access, Result'unchecked_Access);
   check (Same (Result'unchecked_Access, 2),     "f + g, an operator which is a friend");

   Minus (f'unchecked_Access, g'unchecked_Access, Result'unchecked_Access);
   check (Same (Result'unchecked_Access, 0),     "f - g");

   Multiply (f'unchecked_Access, g'unchecked_Access, Result'unchecked_Access);
   check (Same (Result'unchecked_Access, 1),     "f * g");

   Divide (f'unchecked_Access, g'unchecked_Access, Result'unchecked_Access);
   check (Same (Result'unchecked_Access, 1),     "f / g");

   Percent (f'unchecked_Access, g'unchecked_Access, Result'unchecked_Access);
   check (Same (Result'unchecked_Access, 0),     "f % g");

   Op.Minus (a, Result'unchecked_Access);
   check (is_True (EqualEqual (Result'unchecked_Access, a'unchecked_Access)),     "-a, of zero");

   Op.Minus (b, Result'unchecked_Access);
   check (Same (Result'unchecked_Access, -5),    "-b");

   check (Op.Functor (b'Access)       = 5,       "the function call operator, with no argument");
   check (Op.Functor (b'Access, 1)    = 6,       "with one");
   check (Op.Functor (b'Access, 1, 2) = 8,       "with two");

   check (b.i = 5,                               "the member which holds the value");

   finish;
end Tester;
