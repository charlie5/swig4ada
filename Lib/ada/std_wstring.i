/* -----------------------------------------------------------------------------
 * std_wstring.i
 *
 * std::wstring for Ada.
 * ----------------------------------------------------------------------------- */

%{
#include <string>
%}

namespace std {

    class wstring {
      public:
        // The data members are those of the GNU libstdc++ implementation, so that
        // the Ada record has the layout of the C++ object.
        void*        impl_M_dataplus__M_p;
        size_t       impl_M_string_length;
        wchar_t      impl_M_local_buf[4];

        typedef size_t size_type;

        wstring();
        wstring(const wchar_t* s);
        wstring(const wstring& other);

        size_type size() const;
        size_type length() const;
        bool empty() const;
        void clear();
        const wchar_t* c_str() const;
    };
}
