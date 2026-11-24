/* What the tester needs beside TagLib itself: an audio file of its own, which TagLib can read and tag. */

#include <string>
#include <cstdio>
#include <cstdint>
#include <cstdlib>
#include <unistd.h>

inline std::string scratch_wave (unsigned sample_rate, unsigned channels, unsigned seconds)
/* Writes a wave file of silence, of 16 bit samples, and gives its name. */
{
  char name [] = "/tmp/swig4ada-taglib-XXXXXX.wav";
  int  file    = mkstemps (name, 4);
  if (file < 0) return "";

  const uint32_t data_size = sample_rate * channels * 2 * seconds;
  const uint32_t riff_size = 36 + data_size;
  const uint32_t byte_rate = sample_rate * channels * 2;
  const uint16_t align     = channels * 2,   bits = 16,   pcm = 1,   chans = channels;
  const uint32_t fmt_size  = 16;

  FILE* out = fdopen (file, "wb");
  fwrite ("RIFF", 1, 4, out);   fwrite (&riff_size,   4, 1, out);   fwrite ("WAVE", 1, 4, out);
  fwrite ("fmt ", 1, 4, out);   fwrite (&fmt_size,    4, 1, out);   fwrite (&pcm,   2, 1, out);   fwrite (&chans, 2, 1, out);
  fwrite (&sample_rate, 4, 1, out);   fwrite (&byte_rate, 4, 1, out);   fwrite (&align, 2, 1, out);   fwrite (&bits, 2, 1, out);
  fwrite ("data", 1, 4, out);   fwrite (&data_size,   4, 1, out);
  for (uint32_t i = 0; i < data_size; ++i) fputc (0, out);
  fclose (out);

  return name;
}

inline void remove_file (const std::string& name)   { unlink (name.c_str ()); }
