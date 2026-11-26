with
     fvirtual.Node,
     fvirtual.NodeSwitch,

     swig,
     interfaces.C,

     Checks;


procedure Tester
--
--  The case 'fvirtual' of upstream's suite, after its Python test: a derived class which overrides a virtual
--  function and adds an overload of it, which is virtual too.
--
is
   use fvirtual,
       interfaces.C,
       Checks;

   the_Switch : aliased NodeSwitch.Item := NodeSwitch.Item (NodeSwitch.construct);
   the_Node   : aliased Node      .Item := Node      .Item (Node      .construct);
   as_Node    : constant access Node.Item'Class := the_Switch'Access;
begin
   check (Node      .addChild (the_Node  'Access, the_Node'unchecked_Access)                    = 1,  "the function of the base");
   check (NodeSwitch.addChild (the_Switch'Access, the_Node'unchecked_Access)                    = 2,  "the function which overrides it");
   check (Node      .addChild (as_Node,           the_Node'unchecked_Access)                    = 2,  "through the base, by the vtable");
   check (NodeSwitch.addChild (the_Switch'Access, the_Node'unchecked_Access, swig.bool'Val (1)) = 3,  "and the overload which the derived class adds");

   finish;
end Tester;
