#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 415;
BEGIN { use_ok('li_typemaps') }
require_ok('li_typemaps');

sub batch { my($type, @values) = @_;
  # this is a little ugly because I'm trying to be clever and save my
  # wrists from hammering out all these tests.
  for my $val (@values) {
    for my $tst (qw(
      in inr
      out outr
      inout inoutr
    )) {
      my $func = $tst . '_' . $type;
      is(eval { li_typemaps->can($func)->($val) }, $val, "$func $val");
      if($@) {
        my $err = $@;
        $err =~ s/^/#\$\@# /mg;
        print $err;
      }
    }
  }
}

batch('bool', '', 1);
# let's assume we're at least on a 32 bit machine
batch('int', -0x80000000, -1, 0, 1, 12, 0x7fffffff);
# long could be bigger, but it's at least this big
batch('long', -0x80000000, -1, 0, 1, 12, 0x7fffffff);
batch('short', -0x8000, -1, 0, 1, 12, 0x7fff);
batch('uint', 0, 1, 12, 0xffffffff);
batch('ushort', 0, 1, 12, 0xffff);
batch('ulong', 0, 1, 12, 0xffffffff);
batch('uchar', 0, 1, 12, 0xff);
batch('schar', -0x80, 0, 1, 12, 0x7f);

# IEEE 754 machine, please!
batch('float',
  -(2 - 2 ** -23) * 2 ** 127,
  -1, -2 ** -149, 0, 2 ** -149, 1,
  (2 - 2 ** -23) * 2 ** 127,
  'nan');
{ local $TODO = "shouldn't some Inf <=> float work?";
  # I'm going to guess that it could work reasonably as
  # NV Inf => float Inf
  # float Inf => NV NaN
  # but this needs some thought.
  batch('float', 'inf');
}
batch('double',
  -(2 - 2 ** -53) ** 1023,
  -1, -2 ** -1074, 0, 2 ** 1074,
  (2 - 2 ** -53) ** 1023,
  'nan', 'inf');
batch('longlong', -1, 0, 1, 12);
batch('ulonglong', 0, 1, 12);
SKIP: {
  my $a = "8000000000000000";
  my $b = "7fffffffffffffff";
  my $c = "ffffffffffffffff";
  skip "not a 64bit Perl", 18 unless eval { pack 'q', 1 };
  batch('longlong', -hex($a), hex($b));
  batch('ulonglong', hex($c));
}

my($foo, $int) = li_typemaps::out_foo(10);
isa_ok($foo, 'li_typemaps::Foo');
is($foo->{a}, 10);
is($int, 20);

my($a, $b) = li_typemaps::inoutr_int2(13, 31);
is($a, 13);
is($b, 31);

