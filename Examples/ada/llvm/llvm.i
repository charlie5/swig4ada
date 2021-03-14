%module LLVM 
%{
#define __STDC_CONSTANT_MACROS
#define __STDC_LIMIT_MACROS
#include "llvm/Use.h"
#include "llvm/User.h"
#include "llvm/Value.h"
#include "llvm/Constant.h"
#include "llvm/Constants.h"
#include "llvm/BasicBlock.h"
#include "llvm/GlobalValue.h"
#include "llvm/Function.h"
#include "llvm/Type.h"
#include "llvm/DerivedTypes.h"
#include "llvm/Module.h"
#include "llvm/Pass.h"
#include "llvm/AbstractTypeUser.h"
#include "llvm/LLVMContext.h"
#include "llvm/ExecutionEngine/GenericValue.h"
#include "llvm/ExecutionEngine/Executionengine.h"

#define IRBuilder ruby__IRBuilder
#include "llvm/Support/IRBuilder.h"
#undef IRBuilder
using namespace llvm;

%}

#define __STDC_CONSTANT_MACROS
#define __STDC_LIMIT_MACROS

%include "std_vector.i"
#%include "std_string.i"

%typemap(in) uint64_t {
    $1 = NUM2ULL($input);
}

%typemap(typecheck) uint64_t {
    $1 = TYPE($input) == T_FIXNUM || TYPE($input) == T_BIGNUM;
}

// typemaps for StringRef
%typemap(in) llvm::StringRef {
    $1 = StringRef(RSTRING_PTR($input), RSTRING_LEN($input));
}

%typemap(out) llvm::StringRef {
    $result = rb_str_new($1.data(), $1.size());
}

// for overloading in llvm/Module.h
%typemap(typecheck) llvm::StringRef {
    $1 = TYPE($input) == T_STRING;
}


//%template(TypeVector) std::vector<llvm::Type const *,std::allocator< llvm::Type const * > >;


%{
    inline static void check_null(void *m) {
        if (m == NULL) {
            SWIG_exception(SWIG_ValueError,"Expected llvm::Module.");
        }
    }
%}

%typemap(check) llvm::Module * {
    check_null($1);
}

%extend llvm::Module {
    %typemap(out) llvm::Constant * {
        $result = SWIG_NewPointerObj(SWIG_as_voidptr($1), SWIGTYPE_p_llvm__Function, 0 |  0 );
    }
}

%rename(to_type) operator Type*;

%ignore *::refineAbstractType;
%ignore *::typeBecameConcrete;
%ignore llvm::Pass::getAdjustedAnalysisPointer;
%ignore llvm::GlobalValue::use_empty_except_constants;

// #lock= causes errors because SmartMutex::operator = is private.
%ignore llvm::ExecutionEngine::lock;

#define llvm_pointer_equality bool operator==(void* another) { return $self == another; }
%extend llvm::LLVMContext {
    llvm_pointer_equality
}


%include "llvm/ADT/ilist_node.h"

%template(Ilist_node__BasicBlock) ::llvm::ilist_node<BasicBlock>;
%template(Ilist_node__Function) ::llvm::ilist_node<Function>;

%include "llvm/IR/OperandTraits.h"
//%include "llvm/IR/Value.h"
//%include "llvm/IR/User.h"
%include "llvm/IR/Constant.h"
%include "llvm/IR/Constants.h"
%include "llvm/IR/BasicBlock.h"
%include "llvm/Support/Compiler.h"
%include "llvm/IR/GlobalValue.h"
%include "llvm/IR/Function.h"
//%include "llvm/AbstractTypeUser.h"
%include "llvm/IR/Type.h"
%include "llvm/Support/DataTypes.h"
%include "llvm/IR/DerivedTypes.h"
%include "llvm/IR/Module.h"
%include "llvm/Pass.h"
%include "llvm/IR/LLVMContext.h"

%include "llvm/ExecutionEngine/GenericValue.h"
%include "llvm/ExecutionEngine/ExecutionEngine.h"

%ignore llvm::APInt::Emit;
%ignore llvm::APInt::Read;
%ignore llvm::APInt::mu;
%ignore llvm::APInt::ms;

%include "llvm/ADT/APInt.h"

%include "llvm/ADT/Twine.h"

#define IRBuilder ruby__IRBuilder
%include "llvm/IR/IRBuilder.h"
#undef IRBuilder

%template(IRBuilderDefaultInserterPreserveNames) llvm::IRBuilderDefaultInserter<true>;
%template(IRBuilder) llvm::ruby__IRBuilder<true>;
