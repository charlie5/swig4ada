/* -----------------------------------------------------------------------------
 * std_set.i
 *
 * std::set for Ada.
 * ----------------------------------------------------------------------------- */

%{
#include <set>
%}

namespace std {

    template<class T, class Compare = std::less<T> > class set {
      public:
        // The data members are those of the GNU libstdc++ implementation, so that
        // the Ada record has the layout of the C++ object.
        void*        _M_t__M_impl__M_key_compare;
        int          _M_t__M_impl__M_header__M_color;
        void*        _M_t__M_impl__M_header__M_parent;
        void*        _M_t__M_impl__M_header__M_left;
        void*        _M_t__M_impl__M_header__M_right;
        size_t       _M_t__M_impl__M_node_count;

        typedef size_t size_type;
        typedef T key_type;
        typedef T value_type;

        set();
        set(const set& other);

        size_type size() const;
        %rename(isEmpty) empty;
        bool empty() const;
        void clear();

        size_type erase(const key_type& x);
        size_type count(const key_type& x) const;

        %extend {
            void add(const value_type& x) {
                self->insert(x);
            }
            bool contains(const key_type& x) {
                return self->find(x) != self->end();
            }
        }
    };
}
