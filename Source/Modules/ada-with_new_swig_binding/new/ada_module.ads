with
     ada_Package;

package ada_Module
--
--  Contains the C declarations, types, variables and functions of a C module.
--  A C module correspondi to the declarations defined in a swig module.
--
is

   type Item is tagged
      record
         Package_top                     : ada_Package.view;               -- the top 'namespace' package    , in which all simple C types are placed
         Package_binding                 : ada_Package.view;               -- the 'Binding' package          , in which all (non-class) C functions are placed
         Package_pointers                : ada_Package.view;               -- the 'Pointers' package         , in which all (non-class) C pointers are placed
         Package_pointer_pointers        : ada_Package.view;               -- the 'pointer_Pointers' package , in which all (non-class) C pointers to pointer are placed

         new_Packages                    : ada_Package.vector;
      end record;

end ada_Module;
