with
     c_Declarable,
     c_Type,
     c_Variable,
     c_Function;


package c_Module
--
-- Contains the C declarations, types, variables and functions of a C module.
-- A C module corresponds to the declarations defined in a swig module.
--
is

   type Item is tagged
      record
         new_c_Declarations : c_Declarable.Vector;   -- Contains all new types, variables and functions.
         new_c_Types        : c_Type      .Vector;
         new_c_Variables    : c_Variable  .Vector;
         new_c_Functions    : c_Function  .Vector;
      end record;

end c_Module;
