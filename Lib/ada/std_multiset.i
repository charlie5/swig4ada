/* -----------------------------------------------------------------------------
 * std_multiset.i
 *
 * std::multiset for Ada.
 * ----------------------------------------------------------------------------- */

%{
#include <set>
%}

namespace std {

    template<class T, class Compare = std::less<T> > class multiset {
      public:
        // The data members are those of the GNU libstdc++ implementation, so that
        // the Ada record has the layout of the C++ object.
        void*        _M_t__M_impl__M_key_compare;
        int          _M_t__M_impl__M_header__M_color;
        void*        _M_t__M_impl__M_header__M_parent;
        void*        _M_t__M_impl__M_header__M_left;
        void*        _M_t__M_impl__M_header__M_right;
        size_t       _M_t__M_impl__M_node_count;

        multiset();
        multiset(const multiset& other);
        ~multiset();

        size_t size() const;
        %rename(isEmpty) empty;
        bool empty() const;
        void clear();

        size_t erase(const T& x);
        size_t count(const T& x) const;

        %extend {
            void add(const T& x) {
                self->insert(x);
            }
            bool contains(const T& x) {
                return self->find(x) != self->end();
            }
        }
    };
}
