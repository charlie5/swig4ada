import li_attribute

aa = li_attribute.A(1,2,3)

if aa.a != 1:
  raise RuntimeError
aa.a = 3
if aa.a != 3:
  print aa.a
  raise RuntimeError


if aa.b != 2:
  print aa.b
  raise RuntimeError
aa.b = 5
if aa.b != 5:
  raise RuntimeError



if aa.d != aa.b:
  raise RuntimeError

if aa.c != 3:
  raise RuntimeError
#aa.c = 5
#if aa.c != 3:
#  raise RuntimeError

pi = li_attribute.Param_i(7)
if pi.value != 7:
 raise RuntimeError

pi.value=3
if pi.value != 3:
 raise RuntimeError


b = li_attribute.B(aa)

if b.a.c != 3:
 raise RuntimeError
  

myFoo = li_attribute.MyFoo
myFoo.x = 8
myClass = li_attribute.MyClass
myClass.Foo = myFoo
if myClass.Foo.x != 8:
  raise RuntimeError

