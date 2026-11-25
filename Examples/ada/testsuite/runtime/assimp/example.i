/* A binding to Assimp, from its own headers: an importer which reads a scene of plain structures with arrays (its
   meshes, faces and vertices), and the abstract classes of a progress handler and a log stream, which are derived
   in Ada and called back by the library. */

%module assimp

%{
#include <assimp/Importer.hpp>
#include <assimp/scene.h>
#include <assimp/postprocess.h>
#include <assimp/DefaultLogger.hpp>
#include <assimp/LogStream.hpp>
#include <assimp/ProgressHandler.hpp>
#include <assimp/Logger.hpp>
#include <assimp/IOStream.hpp>
#include <assimp/IOSystem.hpp>
#include "example.h"
%}

%include <std_string.i>
%include <std_vector.i>
%include <std_pair.i>

//  'defs.h' makes 'ASSIMP_API' an attribute of visibility ('__attribute__((visibility("default")))'), which SWIG's
//  parser does not read: an attribute is nothing for SWIG's reading. (The wrapper includes the headers as they are.)
//
#define __attribute__(x)

//  For SWIG, 'defs.h' leaves these to the interface file of Assimp's own ('AssimpSwigPort.i'). What it hides from SWIG
//  otherwise ('#ifndef SWIG') is the literal of each enumeration which makes it of the size of an 'int', as one of
//  convention C is in Ada all the same, and an empty base class of the logger and its streams.
//
#define AI_FORCE_INLINE inline
#define AI_WONT_RETURN

%include <assimp/defs.h>
%include <assimp/vector2.h>
%include <assimp/vector3.h>
%include <assimp/color4.h>
%include <assimp/matrix3x3.h>
%include <assimp/matrix4x4.h>
%include <assimp/quaternion.h>
%include <assimp/types.h>

//  The math types, which are templates of the number they are made of, named by typedefs.
//
%template (aiVector2D)  aiVector2t<ai_real>;
%template (aiVector3D)  aiVector3t<ai_real>;
%template (aiColor4D)   aiColor4t<float>;
%template (aiMatrix3x3) aiMatrix3x3t<ai_real>;
%template (aiMatrix4x4) aiMatrix4x4t<ai_real>;
%template (aiQuaternion) aiQuaterniont<ai_real>;

%include <assimp/aabb.h>
%include <assimp/mesh.h>
%include <assimp/texture.h>
%include <assimp/light.h>
%include <assimp/camera.h>
%include <assimp/material.h>
%include <assimp/anim.h>
%include <assimp/metadata.h>
%include <assimp/scene.h>
%include <assimp/postprocess.h>

%include <assimp/ProgressHandler.hpp>
%include <assimp/LogStream.hpp>
//  A helper of the logger, which takes Assimp's own formatter by value: SWIG is not shown its type, which cannot be
//  assigned, so that the function of the wrapper would not compile.
//
%ignore Assimp::Logger::formatMessage;

%include <assimp/Logger.hpp>
%include <assimp/DefaultLogger.hpp>
%include <assimp/IOStream.hpp>
%include <assimp/IOSystem.hpp>
%include <assimp/Importer.hpp>

//  The containers which the classes hold, or which their functions take or return.
//
%template (StringVector)      std::vector<std::string>;
%template (LogStreamInfoList) std::vector<Assimp::LogStreamInfo*>;
%template (TextureAndIndex)   std::pair<const aiTexture*, int>;

%include "example.h"
