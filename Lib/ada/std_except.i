/* -----------------------------------------------------------------------------
 * std_except.i
 *
 * The standard exceptions for Ada.
 *
 * A function which is declared to throw one of them records a pending exception,
 * as the generic file of the library has it (see 'exception.i'), which the
 * support package 'swig.Exceptions' reads.
 *
 * The classes themselves are declared with the shape of the GNU libstdc++
 * implementation, so that a class which is derived from one of them (as many
 * libraries' exceptions are) has its layout and its vtable: 'std::exception' is
 * a pointer to its table, with a virtual destructor and 'what', and
 * 'std::logic_error' and 'std::runtime_error' add the reference counted string of
 * their message, one pointer. Where a class is derived from one which SWIG is not
 * shown, the places of its virtual functions are not known, and none of them can
 * be called through the vtable.
 * ----------------------------------------------------------------------------- */

%{
#include <typeinfo>
#include <stdexcept>
%}

%include <exception.i>


%define %std_exception_map(Exception, Code)
  %typemap(throws,noblock=1) Exception {
    SWIG_exception(Code, $1.what());
  }
%enddef

namespace std {
  %std_exception_map(bad_cast,           SWIG_TypeError);
  %std_exception_map(bad_exception,      SWIG_SystemError);
  %std_exception_map(domain_error,       SWIG_ValueError);
  %std_exception_map(exception,          SWIG_SystemError);
  %std_exception_map(invalid_argument,   SWIG_ValueError);
  %std_exception_map(length_error,       SWIG_IndexError);
  %std_exception_map(logic_error,        SWIG_RuntimeError);
  %std_exception_map(out_of_range,       SWIG_IndexError);
  %std_exception_map(overflow_error,     SWIG_OverflowError);
  %std_exception_map(range_error,        SWIG_OverflowError);
  %std_exception_map(runtime_error,      SWIG_RuntimeError);
  %std_exception_map(underflow_error,    SWIG_OverflowError);
}


//  'exception' is a reserved word of Ada: the class is bound as 'the_exception', which the core need not say.
//
%warnfilter(SWIGWARN_PARSE_KEYWORD) std::exception;
%warnfilter(SWIGWARN_PARSE_KEYWORD) std::exception::exception;

//  Each destructor is given a body, as it is inline in C++ (or the library need not export it), so that it is made
//  by a function of the wrapper.
//
namespace std {

  class exception {
  public:
    exception () noexcept;
    exception (const exception&) noexcept;
    virtual ~exception () noexcept {}
    virtual const char* what () const noexcept;
  };

  class bad_exception : public exception {
  public:
    bad_exception () noexcept;
    virtual ~bad_exception () noexcept {}
    virtual const char* what () const noexcept;
  };

  class bad_cast : public exception {
  public:
    bad_cast () noexcept;
    virtual ~bad_cast () noexcept {}
    virtual const char* what () const noexcept;
  };


  class logic_error : public exception {
  private:
    void* _M_msg;        // A '__cow_string', which is one pointer.
  public:
    explicit logic_error (const char* what_arg);
    logic_error (const logic_error&) noexcept;
    virtual ~logic_error () noexcept {}
    virtual const char* what () const noexcept;
  };

  class domain_error : public logic_error {
  public:
    explicit domain_error (const char* what_arg);
    virtual ~domain_error () noexcept {}
  };

  class invalid_argument : public logic_error {
  public:
    explicit invalid_argument (const char* what_arg);
    virtual ~invalid_argument () noexcept {}
  };

  class length_error : public logic_error {
  public:
    explicit length_error (const char* what_arg);
    virtual ~length_error () noexcept {}
  };

  class out_of_range : public logic_error {
  public:
    explicit out_of_range (const char* what_arg);
    virtual ~out_of_range () noexcept {}
  };


  class runtime_error : public exception {
  private:
    void* _M_msg;        // A '__cow_string', which is one pointer.
  public:
    explicit runtime_error (const char* what_arg);
    runtime_error (const runtime_error&) noexcept;
    virtual ~runtime_error () noexcept {}
    virtual const char* what () const noexcept;
  };

  class range_error : public runtime_error {
  public:
    explicit range_error (const char* what_arg);
    virtual ~range_error () noexcept {}
  };

  class overflow_error : public runtime_error {
  public:
    explicit overflow_error (const char* what_arg);
    virtual ~overflow_error () noexcept {}
  };

  class underflow_error : public runtime_error {
  public:
    explicit underflow_error (const char* what_arg);
    virtual ~underflow_error () noexcept {}
  };
}
