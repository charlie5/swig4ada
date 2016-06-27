with
     c_Declarable,
     c_Type,
     c_Variable,
     c_Function;

package c_Module
--
-- Contains the C declarations, types, variables and functions of a C module.
-- A C module correspondi to the declarations defined in a swig module.
--
is

   type Item is tagged
      record
         new_c_Declarations      : c_Declarable.vector;   -- contains all new types, variables and functions.
         new_c_Types             : c_Type      .vector;
         new_c_Variables         : c_Variable  .vector;
         new_c_Functions         : c_Function  .vector;
      end record;

end c_Module;
