package body c_Declarable
is

   procedure warn (Self : access Item'Class;   Kind    : in Logger.warning_Kind;
                                               Message : in String)
   is
   begin
      Logger.warn (Kind, Message,
                   File => ada.Strings.unbounded.to_String (Self.File),
                   Line => Self.Line,
                   Filter => ada.Strings.unbounded.to_String (Self.warning_Filter));
   end warn;



   procedure warn (Self : access Item'Class;   Kind    : in Logger.warning_Kind;
                                               Message : in ada.Strings.unbounded.unbounded_String)
   is
   begin
      warn (Self, Kind, ada.Strings.unbounded.to_String (Message));
   end warn;

end c_Declarable;
