private
package ada_Language.source_Generator
is

   procedure generate (Self : access ada_Language.item);

   function  layout_Checks (Self : access ada_Language.item) return String;
   --
   --  The text, for the wrapper file, of a check of the layout which each class is taken to have. Null when there is none.
   --
   --  Generates source files for all Ada package specs and bodies.

end ada_Language.source_Generator;


