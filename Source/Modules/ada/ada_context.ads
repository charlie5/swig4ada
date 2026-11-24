with
     ada_Type,

     ada.Strings.unbounded,
     ada.Containers.hashed_Maps,
     pointer_Hash;

limited
with
     ada_Package;


package ada_Context
--
--  Models an Ada library unit context.
--
is
   use ada.Strings.unbounded;

   type Item is tagged private;
   type View is access all Item;

   --  Forge
   --
   function to_Context return Item;

   --  Attributes
   --
   function to_Source     (Self : in Item;   own_Package      : in ada_Package.view;                   -- The package to which the context applies.
                                             namespace_Prefix : in unbounded_String) return String;

   function limited_Withs (Self : in Item;   the_Package      : in ada_Package.view) return Boolean;
   function Withs         (Self : in Item;   the_Package      : in ada_Package.view) return Boolean;     -- Once 'to_Source' has been called.


   --  Operations
   --
   procedure add (Self : in out Item;   required_Type  : in ada_Type.view);
   procedure add (Self : in out Item;   required_Types : in ada_Type.views);
   procedure add (Self : in out Item;   required_Type  : in ada_Type.view;
                                        is_access      : in Boolean;
                                        in_a_Ring      : in Boolean := False);
   --
   --  'in_a_Ring' says that the package of the type leads back to the package of the context, through others (see
   --  'leads_to_this_Package' of the source generator), so that a limited view of it is taken where it is only used
   --  as an access, though it does not depend on this one directly.



private

   type type_Info is
      record
         my_Type     : ada_Type.view;
         is_accessed : Boolean;           -- Will be true if the type is only used as an 'access'.
         in_a_Ring   : Boolean := False;  -- Its package leads back to that of the context.
      end record;


   function to_Hash is new pointer_Hash (ada_Type.view);

   function to_Hash         (Self : in type_Info) return ada.Containers.Hash_type;

   package ada_type_Maps is new ada.Containers.hashed_Maps (ada_Type.view, type_Info,
                                                            to_Hash,       ada_Type."=");
   subtype ada_type_Set        is ada_type_Maps.Map;
   subtype ada_type_set_Cursor is ada_type_Maps.Cursor;


   type internal_State;

   type Item is tagged
      record
         a_required_Types :        ada_Type_Set;
         State            : access internal_State;
      end record;

end ada_Context;
