package body Counting
is

   overriding
   procedure destruct_0 (Self : in out Item)
   is
   begin
      null;     -- The resolver is never destructed, as TagLib keeps it.
   end destruct_0;



   overriding
   procedure destruct (Self : in out Item)
   is
   begin
      null;
   end destruct;



   overriding
   function createFile (Self                 : access Item;
                        fileName             : in     taglib.FileName.Item;
                        readAudioProperties  : in     swig.bool;
                        audioPropertiesStyle : in     AudioProperties.ReadStyle) return File.Pointer
   is
      pragma Unreferenced (fileName, readAudioProperties, audioPropertiesStyle);
   begin
      Self.Calls := Self.Calls + 1;
      return null;     -- TagLib then tries its other resolvers.
   end createFile;

end Counting;
