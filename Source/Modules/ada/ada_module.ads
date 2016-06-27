with
     ada_Package;


package ada_Module
--
--  Contains the Ada packages, types, variables and functions corresponding to those of a C module.
--
is

   type Item is tagged
      record
         Package_top              : ada_Package.view;       -- The top 'namespace' package    , in which all simple C types are placed.
         Package_binding          : ada_Package.view;       -- The 'Binding' package          , in which all (non-class) C functions are placed.
         Package_pointers         : ada_Package.view;       -- The 'Pointers' package         , in which all (non-class) C pointers are placed.
         Package_pointer_pointers : ada_Package.view;       -- The 'pointer_Pointers' package , in which all (non-class) C pointers to pointer are placed.

         new_Packages             : ada_Package.vector;     -- The 'new' packages             , in which all struct/class types are  placed.
      end record;

end ada_Module;
