with
     assimp.Binding,
     assimp.Importer,
     assimp.aiScene,
     assimp.aiMesh,
     assimp.aiFace,
     assimp.aiNode,
     assimp.aiString,
     assimp.aiVector3D,
     assimp.aiMesh_Pointer,
     assimp.Logger,
     assimp.DefaultLogger,
     assimp.LogStream,
     assimp.ProgressHandler,

     Listeners,

     swig,
     interfaces.C.Strings,
     Checks;


procedure Tester
--
--  A binding to Assimp, made from its own headers: an importer which Ada declares reads a scene from text, whose meshes,
--  faces and vertices are plain structures with arrays reached by pointer, and tells a progress handler and a log
--  stream which are derived in Ada as it does. Text of no format which it knows is refused.
--
is
   use assimp,
       assimp.Binding,
       interfaces.C,
       Checks;

   use type swig.bool,
            aiScene.Pointer,
            ai_uint32;

   function bytes (Bits : in Natural) return size_t is (size_t (Bits / 8));

   --  A square of four corners, which the importer triangulates.
   --
   Square : aliased char_array := to_C (  "v 0 0 0" & ASCII.LF
                                        & "v 1 0 0" & ASCII.LF
                                        & "v 1 1 0" & ASCII.LF
                                        & "v 0 1 0" & ASCII.LF
                                        & "f 1 2 3 4" & ASCII.LF,
                                        Append_Nul => False);
   Garbage : aliased char_array := to_C ("this is no scene of any format", Append_Nul => False);
   Obj     : aliased char_array := to_C ("obj");
   Nothing : aliased char_array := to_C ("nothing");

   Flags  : constant unsigned := aiPostProcessSteps'Enum_Rep (aiProcess_Triangulate)
                               + aiPostProcessSteps'Enum_Rep (aiProcess_JoinIdenticalVertices);

   function "+" (the_Text : access char_array) return Strings.chars_ptr
   is (Strings.to_chars_ptr (the_Text.all'unrestricted_Access));

   the_Importer : aliased Importer.Item;     -- Which C++ constructs.
begin
   check (bytes (aiScene   .Item'Size) = size_of_scene,     "a scene has the size of its structure");
   check (bytes (aiMesh    .Item'Size) = size_of_mesh,      "and so has a mesh, with its arrays of a fixed length");
   check (bytes (aiFace    .Item'Size) = size_of_face,      "and a face");
   check (bytes (aiVector3D.Item'Size) = size_of_vector3,   "and a vector, an instance of a template");
   check (bytes (aiNode    .Item'Size) = size_of_node,      "and a node");
   check (bytes (aiString  .Item'Size) = size_of_string,    "and a string, of the length of a constant which is 'static constexpr' in an 'extern ""C""' block");

   importing :
   declare
      the_Progress : aliased Listeners.Progress;
      the_Log      : aliased Listeners.Log;
      Logging      : constant Logger.Pointer := DefaultLogger.create (Strings.Null_Ptr, Logger.VERBOSE, 0);
      All_Kinds    : constant unsigned       := 15;     -- Every severity.
      the_Scene    : aiScene.Pointer;
   begin
      check (Logger.attachStream (Logging, the_Log'unchecked_Access, All_Kinds) /= 0,
             "a log stream which is derived in Ada is attached to the logger");
      Importer.SetProgressHandler (the_Importer, the_Progress'unchecked_Access);

      the_Scene := Importer.ReadFileFromMemory (the_Importer, Square'Address, Square'Length, Flags, +Obj'Access);
      check (the_Scene /= null,                                    "a scene is read from text by an importer which Ada declares");

      declare
         Meshes   : constant aiMesh_Pointer.Pointer := aiMesh_Pointer.Pointer (the_Scene.mMeshes.all);
         the_Mesh : aiMesh.Item renames Meshes.all;
         Faces    : constant aiFace.Pointer         := aiFace.Pointer (the_Mesh.mFaces);
         Corners  : constant aiVector3D.Item_Array  := aiVector3D.C_Pointers.Value (aiVector3D.Pointer (the_Mesh.mVertices),
                                                                                     ptrdiff_t (the_Mesh.mNumVertices));
         Widest   : C_float := 0.0;
      begin
         check (the_Scene.mNumMeshes = 1,                          "with a mesh");
         check (the_Mesh.mNumFaces = 2 and the_Mesh.mNumVertices = 4,
                "the square is made two triangles over its four corners");
         check (Faces.all.mNumIndices = 3,                         "each of three corners");

         for Each of Corners
         loop
            Widest := C_float'Max (Widest, Each.x);
         end loop;

         check (Widest = 1.0,                                       "the corners are read from the array of the mesh");
         declare
            Name : aiString.Item renames the_Scene.mRootNode.mName;
            Text : constant String := interfaces.C.To_Ada (Name.data (0 .. size_t (Name.length)), Trim_Nul => True);
         begin
            check (Name.length > 0 and Text'Length = Natural (Name.length),
                   "the name of the root node is read, as a string of Assimp: " & Text);
         end;
      end;

      check (the_Progress.Calls > 0,                                "Assimp tells a progress handler which is derived in Ada of its progress");
      check (the_Log.Messages > 0,                                  "and writes to a log stream which is derived in Ada:" & the_Log.Messages'Image & " messages");

      the_Scene := Importer.ReadFileFromMemory (the_Importer, Garbage'Address, Garbage'Length, Flags, +Nothing'Access);
      check (the_Scene = null,                                      "text of no format which Assimp knows is refused");
      check (String'(Strings.Value (Importer.GetErrorString (the_Importer))) /= "",
             "and the importer says why: " & String'(Strings.Value (Importer.GetErrorString (the_Importer))));

      Importer.SetProgressHandler (the_Importer, null);     -- The importer gives it back, and does not delete it.
      check (Logger.detachStream (Logging, the_Log'unchecked_Access, All_Kinds) /= 0,
             "and the log stream is detached, so that the logger does not delete it");
      DefaultLogger.kill;

      LogStream      .destruct_0 (LogStream.Item (the_Log));
      ProgressHandler.destruct_0 (ProgressHandler.Item (the_Progress));
   end importing;

   Importer.destruct_0 (the_Importer);
   finish;
end Tester;
