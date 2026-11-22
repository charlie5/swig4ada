package cpp_Mangling
--
-- Makes the symbol which a C++ compiler of the Itanium ABI (GCC, Clang) gives an entity, so that it may be
-- imported with no wrapper function: a destructor, a static member variable, a variable in a namespace.
--
-- The names which are dealt with are those of a class or variable within namespaces and classes, any of which
-- may be a template instance whose arguments are standard types, classes, pointers and references to either,
-- 'const' ones, and integers. A part which has been written already is not written again, but named by
-- its place (a 'substitution': 'Pair<Shape, Shape>' is '4PairI5ShapeS0_E'). The standard library, whose
-- names are abbreviated, is not dealt with.
--
is
   function Symbol (qualified_Name : in String;   Suffix : in String) return String;
   --
   -- 'qualified_Name' is the name as swig holds it ('geometry::solid::Box', 'Source<(int)>', 'Pair<(Shape,p.Shape)>'),
   -- and 'Suffix' ends the symbol by the kind of the entity: 'E' for a variable which the name is that of, 'D1Ev'
   -- for the complete object destructor of the class which it names, 'D0Ev' for the deleting one.
   --
   -- Returns "" where the symbol cannot be made.

end cpp_Mangling;
