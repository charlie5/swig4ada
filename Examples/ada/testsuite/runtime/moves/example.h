/* Objects which can be moved and not copied. */

#include <utility>
#include <memory>

/* A buffer which owns its storage: it can be moved, and cannot be copied. */
class Buffer {
  int* data;
  int  size;
public:
  static int alive;                                  // the buffers which hold storage

  Buffer (int n) : data (new int [n]), size (n)      { alive++;  for (int i = 0;  i < n;  i++) data [i] = i + 1; }
  Buffer (Buffer&& o) noexcept
    : data (o.data), size (o.size)                   { o.data = 0;  o.size = 0; }
  Buffer& operator= (Buffer&& o) noexcept
  {
    if (this != &o)
    {
      if (data) { delete [] data;  alive--; }
      data = o.data;  size = o.size;
      o.data = 0;     o.size = 0;
    }
    return *this;
  }
  Buffer (const Buffer&)            = delete;
  Buffer& operator= (const Buffer&) = delete;
  ~Buffer ()                                         { if (data) { delete [] data;  alive--; } }

  int  length   () const                             { return size; }
  bool is_empty () const                             { return data == 0; }
  int  sum      () const                             { int s = 0;  for (int i = 0;  i < size;  i++) s += data [i];  return s; }
};

inline int    buffers_alive ()                       { return Buffer::alive; }

inline Buffer make_buffer (int n)                    { return Buffer (n); }            // returned by value, which moves it

inline int    peek    (Buffer&& b)                   { return b.length (); }           // an rvalue reference which is left alone
inline int    take    (Buffer&& b)                   { Buffer mine (std::move (b));  return mine.sum (); }   // and one which is moved from
inline int    consume (Buffer b)                     { return b.sum (); }              // passed by value, which must move it

/* A class which is given a buffer, and keeps it. */
class Holder {
  Buffer held;
public:
  Holder (Buffer b) : held (std::move (b))           {}
  int  length () const                               { return held.length (); }
  void adopt  (Buffer&& b)                           { held = std::move (b); }
};

/* A pointer which owns its buffer. */
inline std::unique_ptr<Buffer> make_owned   (int n)                                { return std::unique_ptr<Buffer> (new Buffer (n)); }
inline int                     owned_length (const std::unique_ptr<Buffer>& p)     { return p ? p->length () : -1; }
inline int                     take_owned   (std::unique_ptr<Buffer> p)            { return p->sum (); }     // which frees the buffer
