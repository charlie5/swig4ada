li_boost_shared_ptr

debug = false;

function main()
    if (debug)
      printf("Started\n")
    endif

    li_boost_shared_ptr.cvar.debug_shared = debug;

    # Change loop count to run for a long time to monitor memory
    loopCount = 1; #5000
    for i=0:loopCount,
      self.runtest();
    endfor

    if (li_boost_shared_ptr.Klass.getTotal_count() != 0)
      error("Klass.total_count=", li_boost_shared_ptr.Klass.getTotal_count())
    endif

    wrapper_count = li_boost_shared_ptr.shared_ptr_wrapper_count();
    if (wrapper_count != li_boost_shared_ptr.NOT_COUNTING)
      if (wrapper_count != 0)
        error("shared_ptr wrapper count not zero: %i", wrapper_count)
      endif
    endif

    if (debug)
      error("Finished")
    endif
endfunction

function runtest()
    # simple shared_ptr usage - created in C++
    k = li_boost_shared_ptr.Klass("me oh my");
    val = k.getValue();
    self.verifyValue("me oh my", val);
    self.verifyCount(1, k);

    # simple shared_ptr usage - not created in C++
    k = li_boost_shared_ptr.factorycreate();
    val = k.getValue();
    self.verifyValue("factorycreate", val);
    self.verifyCount(1, k);

    # pass by shared_ptr
    k = li_boost_shared_ptr.Klass("me oh my");
    kret = li_boost_shared_ptr.smartpointertest(k);
    val = kret.getValue();
    self.verifyValue("me oh my smartpointertest", val);
    self.verifyCount(2, k);
    self.verifyCount(2, kret);

    # pass by shared_ptr pointer
    k = li_boost_shared_ptr.Klass("me oh my");
    kret = li_boost_shared_ptr.smartpointerpointertest(k);
    val = kret.getValue();
    self.verifyValue("me oh my smartpointerpointertest", val);
    self.verifyCount(2, k);
    self.verifyCount(2, kret);

    # pass by shared_ptr reference
    k = li_boost_shared_ptr.Klass("me oh my");
    kret = li_boost_shared_ptr.smartpointerreftest(k);
    val = kret.getValue();
    self.verifyValue("me oh my smartpointerreftest", val);
    self.verifyCount(2, k);
    self.verifyCount(2, kret);

    # pass by shared_ptr pointer reference
    k = li_boost_shared_ptr.Klass("me oh my");
    kret = li_boost_shared_ptr.smartpointerpointerreftest(k);
    val = kret.getValue();
    self.verifyValue("me oh my smartpointerpointerreftest", val);
    self.verifyCount(2, k);
    self.verifyCount(2, kret);

    # const pass by shared_ptr
    k = li_boost_shared_ptr.Klass("me oh my");
    kret = li_boost_shared_ptr.constsmartpointertest(k);
    val = kret.getValue();
    self.verifyValue("me oh my", val);
    self.verifyCount(2, k);
    self.verifyCount(2, kret);

    # const pass by shared_ptr pointer
    k = li_boost_shared_ptr.Klass("me oh my");
    kret = li_boost_shared_ptr.constsmartpointerpointertest(k);
    val = kret.getValue();
    self.verifyValue("me oh my", val);
    self.verifyCount(2, k);
    self.verifyCount(2, kret);

    # const pass by shared_ptr reference
    k = li_boost_shared_ptr.Klass("me oh my");
    kret = li_boost_shared_ptr.constsmartpointerreftest(k);
    val = kret.getValue();
    self.verifyValue("me oh my", val);
    self.verifyCount(2, k);
    self.verifyCount(2, kret);

    # pass by value
    k = li_boost_shared_ptr.Klass("me oh my");
    kret = li_boost_shared_ptr.valuetest(k);
    val = kret.getValue();
    self.verifyValue("me oh my valuetest", val);
    self.verifyCount(1, k);
    self.verifyCount(1, kret);

    # pass by pointer
    k = li_boost_shared_ptr.Klass("me oh my");
    kret = li_boost_shared_ptr.pointertest(k);
    val = kret.getValue();
    self.verifyValue("me oh my pointertest", val);
    self.verifyCount(1, k);
    self.verifyCount(1, kret);

    # pass by reference
    k = li_boost_shared_ptr.Klass("me oh my");
    kret = li_boost_shared_ptr.reftest(k);
    val = kret.getValue();
    self.verifyValue("me oh my reftest", val);
    self.verifyCount(1, k);
    self.verifyCount(1, kret);

    # pass by pointer reference
    k = li_boost_shared_ptr.Klass("me oh my");
    kret = li_boost_shared_ptr.pointerreftest(k);
    val = kret.getValue();
    self.verifyValue("me oh my pointerreftest", val);
    self.verifyCount(1, k);
    self.verifyCount(1, kret);

    # null tests
    k = None;

    if (li_boost_shared_ptr.smartpointertest(k) != None)
      error("return was not null")
    endif

    if (li_boost_shared_ptr.smartpointerpointertest(k) != None)
      error("return was not null")
    endif

    if (li_boost_shared_ptr.smartpointerreftest(k) != None)
      error("return was not null")
    endif

    if (li_boost_shared_ptr.smartpointerpointerreftest(k) != None)
      error("return was not null")
    endif

    if (li_boost_shared_ptr.nullsmartpointerpointertest(None) != "null pointer")
      error("not null smartpointer pointer")
    endif

    try
      li_boost_shared_ptr.valuetest(k)
      error("Failed to catch null pointer")
    catch
    end_try_catch

    if (li_boost_shared_ptr.pointertest(k) != None)
      error("return was not null")
    endif

    try
      li_boost_shared_ptr.reftest(k)
      error("Failed to catch null pointer")
    catch
    end_try_catch

    # $owner
    k = li_boost_shared_ptr.pointerownertest();
    val = k.getValue();
    self.verifyValue("pointerownertest", val);
    self.verifyCount(1, k);
    k = li_boost_shared_ptr.smartpointerpointerownertest();
    val = k.getValue();
    self.verifyValue("smartpointerpointerownertest", val);
    self.verifyCount(1, k);

    # //////////////////////////////// Derived class ////////////////////////////////////////
    # derived pass by shared_ptr
    k = li_boost_shared_ptr.KlassDerived("me oh my");
    kret = li_boost_shared_ptr.derivedsmartptrtest(k);
    val = kret.getValue();
    self.verifyValue("me oh my derivedsmartptrtest-Derived", val);
    self.verifyCount(2, k);
    self.verifyCount(2, kret);

    # derived pass by shared_ptr pointer
    k = li_boost_shared_ptr.KlassDerived("me oh my");
    kret = li_boost_shared_ptr.derivedsmartptrpointertest(k);
    val = kret.getValue();
    self.verifyValue("me oh my derivedsmartptrpointertest-Derived", val);
    self.verifyCount(2, k);
    self.verifyCount(2, kret);

    # derived pass by shared_ptr ref
    k = li_boost_shared_ptr.KlassDerived("me oh my");
    kret = li_boost_shared_ptr.derivedsmartptrreftest(k);
    val = kret.getValue();
    self.verifyValue("me oh my derivedsmartptrreftest-Derived", val);
    self.verifyCount(2, k);
    self.verifyCount(2, kret);

    # derived pass by shared_ptr pointer ref
    k = li_boost_shared_ptr.KlassDerived("me oh my");
    kret = li_boost_shared_ptr.derivedsmartptrpointerreftest(k);
    val = kret.getValue();
    self.verifyValue("me oh my derivedsmartptrpointerreftest-Derived", val);
    self.verifyCount(2, k);
    self.verifyCount(2, kret);

    # derived pass by pointer
    k = li_boost_shared_ptr.KlassDerived("me oh my");
    kret = li_boost_shared_ptr.derivedpointertest(k);
    val = kret.getValue();
    self.verifyValue("me oh my derivedpointertest-Derived", val);
    self.verifyCount(1, k);
    self.verifyCount(1, kret);

    # derived pass by ref
    k = li_boost_shared_ptr.KlassDerived("me oh my");
    kret = li_boost_shared_ptr.derivedreftest(k);
    val = kret.getValue();
    self.verifyValue("me oh my derivedreftest-Derived", val);
    self.verifyCount(1, k);
    self.verifyCount(1, kret);

    # //////////////////////////////// Derived and base class mixed ////////////////////////////////////////
    # pass by shared_ptr (mixed)
    k = li_boost_shared_ptr.KlassDerived("me oh my");
    kret = li_boost_shared_ptr.smartpointertest(k);
    val = kret.getValue();
    self.verifyValue("me oh my smartpointertest-Derived", val);
    self.verifyCount(2, k);
    self.verifyCount(2, kret);

    # pass by shared_ptr pointer (mixed)
    k = li_boost_shared_ptr.KlassDerived("me oh my");
    kret = li_boost_shared_ptr.smartpointerpointertest(k);
    val = kret.getValue();
    self.verifyValue("me oh my smartpointerpointertest-Derived", val);
    self.verifyCount(2, k);
    self.verifyCount(2, kret);

    # pass by shared_ptr reference (mixed)
    k = li_boost_shared_ptr.KlassDerived("me oh my");
    kret = li_boost_shared_ptr.smartpointerreftest(k);
    val = kret.getValue();
    self.verifyValue("me oh my smartpointerreftest-Derived", val);
    self.verifyCount(2, k);
    self.verifyCount(2, kret);

    # pass by shared_ptr pointer reference (mixed)
    k = li_boost_shared_ptr.KlassDerived("me oh my");
    kret = li_boost_shared_ptr.smartpointerpointerreftest(k);
    val = kret.getValue();
    self.verifyValue("me oh my smartpointerpointerreftest-Derived", val);
    self.verifyCount(2, k);
    self.verifyCount(2, kret);

    # pass by value (mixed)
    k = li_boost_shared_ptr.KlassDerived("me oh my");
    kret = li_boost_shared_ptr.valuetest(k);
    val = kret.getValue();
    self.verifyValue("me oh my valuetest", val); # note slicing
    self.verifyCount(1, k);
    self.verifyCount(1, kret);

    # pass by pointer (mixed)
    k = li_boost_shared_ptr.KlassDerived("me oh my");
    kret = li_boost_shared_ptr.pointertest(k);
    val = kret.getValue();
    self.verifyValue("me oh my pointertest-Derived", val);
    self.verifyCount(1, k);
    self.verifyCount(1, kret);

    # pass by ref (mixed)
    k = li_boost_shared_ptr.KlassDerived("me oh my");
    kret = li_boost_shared_ptr.reftest(k);
    val = kret.getValue();
    self.verifyValue("me oh my reftest-Derived", val);
    self.verifyCount(1, k);
    self.verifyCount(1, kret);

    # //////////////////////////////// Overloading tests ////////////////////////////////////////
    # Base class
    k = li_boost_shared_ptr.Klass("me oh my");
    self.verifyValue(li_boost_shared_ptr.overload_rawbyval(k), "rawbyval");
    self.verifyValue(li_boost_shared_ptr.overload_rawbyref(k), "rawbyref");
    self.verifyValue(li_boost_shared_ptr.overload_rawbyptr(k), "rawbyptr");
    self.verifyValue(li_boost_shared_ptr.overload_rawbyptrref(k), "rawbyptrref");

    self.verifyValue(li_boost_shared_ptr.overload_smartbyval(k), "smartbyval");
    self.verifyValue(li_boost_shared_ptr.overload_smartbyref(k), "smartbyref");
    self.verifyValue(li_boost_shared_ptr.overload_smartbyptr(k), "smartbyptr");
    self.verifyValue(li_boost_shared_ptr.overload_smartbyptrref(k), "smartbyptrref");

    # Derived class
    k = li_boost_shared_ptr.KlassDerived("me oh my");
    self.verifyValue(li_boost_shared_ptr.overload_rawbyval(k), "rawbyval");
    self.verifyValue(li_boost_shared_ptr.overload_rawbyref(k), "rawbyref");
    self.verifyValue(li_boost_shared_ptr.overload_rawbyptr(k), "rawbyptr");
    self.verifyValue(li_boost_shared_ptr.overload_rawbyptrref(k), "rawbyptrref");

    self.verifyValue(li_boost_shared_ptr.overload_smartbyval(k), "smartbyval");
    self.verifyValue(li_boost_shared_ptr.overload_smartbyref(k), "smartbyref");
    self.verifyValue(li_boost_shared_ptr.overload_smartbyptr(k), "smartbyptr");
    self.verifyValue(li_boost_shared_ptr.overload_smartbyptrref(k), "smartbyptrref");

    # //////////////////////////////// Member variables ////////////////////////////////////////
    # smart pointer by value
    m = li_boost_shared_ptr.MemberVariables();
    k = li_boost_shared_ptr.Klass("smart member value");
    m.SmartMemberValue = k;
    val = k.getValue();
    self.verifyValue("smart member value", val);
    self.verifyCount(2, k);

    kmember = m.SmartMemberValue;
    val = kmember.getValue();
    self.verifyValue("smart member value", val);
    self.verifyCount(3, kmember);
    self.verifyCount(3, k);

    clear m;
    self.verifyCount(2, kmember);
    self.verifyCount(2, k);

    # smart pointer by pointer
    m = li_boost_shared_ptr.MemberVariables();
    k = li_boost_shared_ptr.Klass("smart member pointer");
    m.SmartMemberPointer = k;
    val = k.getValue();
    self.verifyValue("smart member pointer", val);
    self.verifyCount(1, k);

    kmember = m.SmartMemberPointer;
    val = kmember.getValue();
    self.verifyValue("smart member pointer", val);
    self.verifyCount(2, kmember);
    self.verifyCount(2, k);

    clear m;
    self.verifyCount(2, kmember);
    self.verifyCount(2, k);

    # smart pointer by reference
    m = li_boost_shared_ptr.MemberVariables();
    k = li_boost_shared_ptr.Klass("smart member reference");
    m.SmartMemberReference = k;
    val = k.getValue();
    self.verifyValue("smart member reference", val);
    self.verifyCount(2, k);

    kmember = m.SmartMemberReference;
    val = kmember.getValue();
    self.verifyValue("smart member reference", val);
    self.verifyCount(3, kmember);
    self.verifyCount(3, k);

    # The C++ reference refers to SmartMemberValue...
    kmemberVal = m.SmartMemberValue;
    val = kmember.getValue();
    self.verifyValue("smart member reference", val);
    self.verifyCount(4, kmemberVal);
    self.verifyCount(4, kmember);
    self.verifyCount(4, k);

    clear m;
    self.verifyCount(3, kmemberVal);
    self.verifyCount(3, kmember);
    self.verifyCount(3, k);

    # plain by value
    m = li_boost_shared_ptr.MemberVariables();
    k = li_boost_shared_ptr.Klass("plain member value");
    m.MemberValue = k;
    val = k.getValue();
    self.verifyValue("plain member value", val);
    self.verifyCount(1, k);

    kmember = m.MemberValue;
    val = kmember.getValue();
    self.verifyValue("plain member value", val);
    self.verifyCount(1, kmember);
    self.verifyCount(1, k);

    clear m;
    self.verifyCount(1, kmember);
    self.verifyCount(1, k);

    # plain by pointer
    m = li_boost_shared_ptr.MemberVariables();
    k = li_boost_shared_ptr.Klass("plain member pointer");
    m.MemberPointer = k;
    val = k.getValue();
    self.verifyValue("plain member pointer", val);
    self.verifyCount(1, k);

    kmember = m.MemberPointer;
    val = kmember.getValue();
    self.verifyValue("plain member pointer", val);
    self.verifyCount(1, kmember);
    self.verifyCount(1, k);

    clear m;
    self.verifyCount(1, kmember);
    self.verifyCount(1, k);

    # plain by reference
    m = li_boost_shared_ptr.MemberVariables();
    k = li_boost_shared_ptr.Klass("plain member reference");
    m.MemberReference = k;
    val = k.getValue();
    self.verifyValue("plain member reference", val);
    self.verifyCount(1, k);

    kmember = m.MemberReference;
    val = kmember.getValue();
    self.verifyValue("plain member reference", val);
    self.verifyCount(1, kmember);
    self.verifyCount(1, k);

    clear m;
    self.verifyCount(1, kmember);
    self.verifyCount(1, k);

    # null member variables
    m = li_boost_shared_ptr.MemberVariables();

    # shared_ptr by value
    k = m.SmartMemberValue;
    if (k != None)
      error("expected null")
    endif
    m.SmartMemberValue = None;
    k = m.SmartMemberValue;
    if (k != None)
      error("expected null")
    endif
    self.verifyCount(0, k);

    # plain by value
    try
      m.MemberValue = None;
      error("Failed to catch null pointer");
    catch
    end_try_catch

    # templates
    pid = li_boost_shared_ptr.PairIntDouble(10, 20.2)
    if (pid.baseVal1 != 20 || pid.baseVal2 != 40.4)
      error("Base values wrong")
    endif
    if (pid.val1 != 10 || pid.val2 != 20.2)
      error("Derived Values wrong")
    endif
endfunction

function verifyValue(expected,got)
  if (expected != got)
    error("verify value failed. Expected: %i, Got %i\n",expected,got)
  endif
endfunction

function verifyCount(expected,k)
  got = li_boost_shared_ptr.use_count(k);
  if (expected != got)
    error("verify value failed. Expected: %i, Got %i\n",expected,got)
  endif
endfunction


