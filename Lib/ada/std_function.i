/* -----------------------------------------------------------------------------
 * std_function.i
 *
 * std::function for Ada.
 *
 * As the generic file of the library has it, an instance is named with
 * '%template' (%template (Checker) std::function<bool (int, const std::string&)>;),
 * and its 'operator()' is 'call'. The data members are those of the GNU
 * libstdc++ implementation, so that the Ada record has the layout of the C++
 * object (32 bytes on a 64 bit machine): the storage of the functor, of two
 * words, and the functions which manage and invoke it. The destructor and the
 * copy constructor are declared, as C++ constructs the class: a result of it is
 * returned through a pointer to an object of the caller. (The generic file
 * declares no member, so that an instance was an empty record.)
 * ----------------------------------------------------------------------------- */

%{
#include <functional>
%}

%rename(call) std::function::operator();

namespace std {
  template <typename> class function;

  template <typename RET, typename... ARGS> class function<RET(ARGS...)> {
  public:
    void*  _M_functor_1;        // '_Any_data', of two words.
    void*  _M_functor_2;
    void*  _M_manager;
    void*  _M_invoker;

    using result_type = RET;

    function();
    function(const function&);
    ~function();

    RET operator()(ARGS...) const;
  };
}
