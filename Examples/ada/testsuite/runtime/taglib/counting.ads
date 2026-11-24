with
     taglib.FileTypeResolver,
     taglib.FileName,
     taglib.File,
     taglib.AudioProperties,
     swig;

package Counting
--
-- A resolver of the types of files which is declared in Ada, and derived from TagLib's abstract 'FileTypeResolver':
-- it counts the files which TagLib asks it of, and makes none of them, so that TagLib goes on to its own resolvers.
-- TagLib calls its function through the vtable of the class, so the package is at library level.
--
is
   use taglib;

   type Item is new FileTypeResolver.Item with
      record
         Calls : Natural := 0;     -- How often TagLib has asked it for a file.
      end record;

   overriding
   procedure destruct_0 (Self : in out Item);
   overriding
   procedure destruct   (Self : in out Item);

   overriding
   function  createFile (Self                 : access Item;
                         fileName             : in     taglib.FileName.Item;
                         readAudioProperties  : in     swig.bool;
                         audioPropertiesStyle : in     AudioProperties.ReadStyle) return File.Pointer;

   pragma Convention (CPP, destruct_0);
   pragma Convention (CPP, destruct);
   pragma Convention (CPP, createFile);

end Counting;
