(function () {
  'use strict';

  // Arabic copy; English lives in the HTML (also what search engines index).
  var AR = {
    navFeatures: 'المزايا', navScreens: 'الشاشات', navFaq: 'الأسئلة', navDownload: 'تحميل',
    heroEyebrow: 'مشغّل IPTV لأندرويد',
    heroTitleA: 'كل بثّ تملكه،', heroTitleB: 'في مدار واحد.',
    heroLead: 'بثّ مباشر مع دليل برامج كامل، وأفلام ومسلسلات تُكمل من الثانية التي توقفت عندها، ومشغّل مصمَّم للشاشات الكبيرة. اربط حساب Xtream Codes أو رابط M3U أو دليل EPG الخاص بك، وأوربكس يتكفّل بالباقي.',
    ctaDownload: 'حمّل لأندرويد', ctaExplore: 'استكشف المزايا',
    fine1: 'مجاني', fine2: 'بلا تسجيل', fine3: 'أندرويد 9 فأحدث', fine4: 'العربية و English',
    chip1: 'مباشر الآن', chip2: 'دليل البرامج', chip2s: '7 أيام · مصدران', chip3: 'استئناف م3 · ح4',
    mq1: 'صورة داخل صورة', mq2: 'الأجهزة اللوحية والقابلة للطي', mq3: 'رمز PIN للرقابة', mq4: 'العربية والإنجليزية',
    featEyebrow: 'كل شيء في مكان واحد',
    featTitle: 'تصميم بروح السينما. وتحكّم بسهولة الريموت.',
    featLead: 'يحوّل أوربكس قائمة التشغيل الخام إلى مكتبة جميلة: تصفّح سريع، ومشاهدة مريحة من الأريكة، وخصوصية من الأساس.',
    f1t: 'بثّ مباشر مع دليل حقيقي',
    f1p: 'ما يُعرض الآن وما يليه على كل قناة، ودليل برامج لسبعة أيام بخط زمني حيّ، وتصنيفات ومفضلة وتنقّل فوري بين القنوات. وعلى الأجهزة اللوحية: التصنيفات والقنوات والمعاينة جنبًا إلى جنب.',
    f2t: 'أفلام ومسلسلات',
    f2p: 'ملصقات وقصص وطاقم تمثيل ومواسم، مع حفظ التقدّم حتى الثانية والحلقة التالية جاهزة للتشغيل.',
    f3t: 'مشغّل يبدو أصيلًا',
    f3p: 'اسحب للسطوع والصوت، وانقر مرتين للتقديم، وكبّر بإصبعين، واقفل عناصر التحكم، وتابع المشاهدة بميزة صورة داخل صورة.',
    f4t: 'لكل حجم شاشة',
    f4p: 'شريط سفلي على الهواتف، وشريط جانبي على الأجهزة اللوحية، ولوحتان على الأجهزة القابلة للطي، وثلاث لوحات للبث المباشر على الشاشات الكبيرة.',
    f5t: 'رقابة أبوية',
    f5p: 'اقفل تصنيفات أو قنوات بعينها برمز PIN من 4 أرقام، وأخفِ محتوى البالغين في كل مكان.',
    f6t: 'خصوصية من الأساس',
    f6p: 'بلا حساب ولا تتبّع ولا إعلانات. عناوين الخوادم وكلمات المرور مشفّرة بمخزن مفاتيح أندرويد ولا تغادر جهازك أبدًا.',
    f7t: 'مصادرك بطريقتك',
    f7p: 'حسابات Xtream Codes أو روابط M3U أو ملفات قوائم محلية، مع دليل XMLTV الخاص بك. عدة حسابات على جهاز واحد، والتبديل بلمسة.',
    scrEyebrow: 'شاهده وهو يعمل', scrTitle: 'مصمَّم على طريقتك في المشاهدة',
    tabPhone: 'الهاتف', tabTablet: 'الجهاز اللوحي', tabPlayer: 'المشغّل',
    arEyebrow: 'ثنائي اللغة حقًا', arTitle: 'يتحدث العربية والإنجليزية بطلاقة.',
    ar1: 'واجهة كاملة من اليمين إلى اليسار، لا مجرد انعكاس متأخر.',
    ar2: 'خط Readex Pro مضبوط للعربية، وأرقام غربية للأوقات والقنوات.',
    ar3: 'الترجمة العربية والعناوين المختلطة تُقرأ دائمًا في الاتجاه الصحيح.',
    stEyebrow: 'جاهز خلال دقيقة', stTitle: 'ثلاث خطوات إلى مكتبتك',
    s1t: 'ثبّت أوربكس', s1p: 'حمّل ملف APK من الأسفل وافتحه على هاتفك أو جهازك اللوحي أو القابل للطي.',
    s2t: 'أضف مزوّدك', s2p: 'أدخل بيانات Xtream Codes أو الصق رابط M3U. يختبر أوربكس الاتصال قبل الحفظ.',
    s3t: 'اضغط تشغيل', s3p: 'البث المباشر جاهز أولًا، بينما تكمل الأفلام والمسلسلات والدليل التحميل في الخلفية.',
    dlEyebrow: 'الإصدار 1.0.0', dlTitle: 'حمّل أوربكس لأندرويد',
    dlLead: 'ملف APK واحد لكل هواتف أندرويد وأجهزته اللوحية والقابلة للطي بنظام أندرويد 9 فأحدث.',
    spVersion: 'الإصدار', spSize: 'الحجم', spReq: 'يتطلب', spLang: 'اللغات',
    copy: 'نسخ', copied: 'تم النسخ', qr: 'امسح للتحميل على هاتفك',
    in1t: '1 · التحميل', in1p: 'اضغط الزر من جهاز أندرويد.',
    in2t: '2 · اسمح بالتثبيت', in2p: 'إن طُلب منك، اسمح للمتصفح بتثبيت التطبيقات غير المعروفة.',
    in3t: '3 · افتح أوربكس', in3p: 'أضف حساب IPTV الخاص بك وابدأ المشاهدة.',
    faqEyebrow: 'أسئلة', faqTitle: 'معلومات مفيدة',
    q1: 'هل يتضمن أوربكس قنوات أو محتوى؟',
    a1: 'لا. أوربكس مشغّل وسائط فقط، لا يوفّر أي قنوات أو أفلام أو مسلسلات ولا يستضيفها أو يبيعها. تربط خدمة مخوّلًا باستخدامها، وأوربكس يشغّلها.',
    q2: 'ما المصادر المدعومة؟',
    a2: 'حسابات Xtream Codes، وروابط قوائم M3U و M3U8، وملفات القوائم المحلية، وأدلة XMLTV من مزوّدك أو من رابطك الخاص.',
    q3: 'هل هو مجاني؟ هل أحتاج حسابًا؟',
    a3: 'أوربكس مجاني، بلا تسجيل ولا إعلانات ولا تتبّع. كل ما تضيفه يبقى على جهازك.',
    q4: 'كيف أتأكد أن الملف أصلي؟',
    a4: 'ملف APK موقّع من مطوّر أوربكس. يمكنك مطابقة بصمة SHA-256 المعروضة أعلاه مع الملف بعد تحميله.',
    q5: 'على أي أجهزة يعمل؟',
    a5: 'أندرويد 9 فأحدث: الهواتف والأجهزة اللوحية والقابلة للطي، مع تصميم مخصّص لكل منها.',
    legal: 'أوربكس مشغّل وسائط فقط. لا يوفّر القنوات أو الأفلام أو المسلسلات ولا يستضيفها أو يبيعها. استخدمه فقط مع خدمات مخوّل بالوصول إليها.'
  };

  var root = document.documentElement;
  var EN = {};
  var nodes = document.querySelectorAll('[data-i18n]');
  nodes.forEach(function (n) { EN[n.getAttribute('data-i18n')] = n.innerHTML; });
  var imgs = document.querySelectorAll('img[data-ar]');
  imgs.forEach(function (i) { i.setAttribute('data-en', i.getAttribute('src')); });
  var langBtn = document.getElementById('lang');

  function apply(lang) {
    var dict = lang === 'ar' ? AR : EN;
    root.lang = lang;
    root.dir = lang === 'ar' ? 'rtl' : 'ltr';
    nodes.forEach(function (n) {
      var k = n.getAttribute('data-i18n');
      if (dict[k] != null) n.innerHTML = dict[k];
    });
    imgs.forEach(function (i) { i.src = i.getAttribute(lang === 'ar' ? 'data-ar' : 'data-en'); });
    document.title = lang === 'ar' ? 'أوربكس — كل بثّ تملكه، في مدار واحد' : 'Orbix — Your IPTV, in one orbit';
    langBtn.textContent = lang === 'ar' ? 'EN' : 'ع';
    langBtn.setAttribute('aria-label', lang === 'ar' ? 'English' : 'العربية');
    try { localStorage.setItem('orbix-lang', lang); } catch (e) {}
  }
  apply(root.lang === 'ar' ? 'ar' : 'en');
  langBtn.addEventListener('click', function () { apply(root.lang === 'ar' ? 'en' : 'ar'); });

  // Nav background once scrolled.
  var nav = document.getElementById('nav');
  function onScroll() { nav.classList.toggle('scrolled', window.scrollY > 20); }
  onScroll();
  window.addEventListener('scroll', onScroll, { passive: true });

  // Reveal on scroll.
  if ('IntersectionObserver' in window) {
    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (e) {
        if (e.isIntersecting) { e.target.classList.add('in'); io.unobserve(e.target); }
      });
    }, { rootMargin: '0px 0px -8% 0px', threshold: 0.08 });
    document.querySelectorAll('.reveal').forEach(function (el) { io.observe(el); });
  } else {
    document.querySelectorAll('.reveal').forEach(function (el) { el.classList.add('in'); });
  }

  // Hero parallax (mouse / pointer devices only, never with reduced motion).
  var reduce = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  var stage = document.getElementById('stage');
  if (stage && !reduce && window.matchMedia('(pointer: fine)').matches) {
    var layers = stage.querySelectorAll('.parallax');
    var base = [];
    layers.forEach(function (l) { base.push(getComputedStyle(l).transform); });
    window.addEventListener('mousemove', function (e) {
      var x = e.clientX / window.innerWidth - 0.5;
      var y = e.clientY / window.innerHeight - 0.5;
      layers.forEach(function (l, i) {
        var d = +l.getAttribute('data-depth');
        var t = 'translate3d(' + (-x * d) + 'px,' + (-y * d) + 'px,0)';
        l.style.transform = (base[i] && base[i] !== 'none' ? base[i] + ' ' : '') + t;
      });
    }, { passive: true });
  }

  // Card spotlight follows the pointer.
  document.querySelectorAll('.card').forEach(function (c) {
    c.addEventListener('pointermove', function (e) {
      var r = c.getBoundingClientRect();
      c.style.setProperty('--mx', (e.clientX - r.left) + 'px');
      c.style.setProperty('--my', (e.clientY - r.top) + 'px');
    });
  });

  // Screens tabs.
  var tabs = document.querySelectorAll('[data-tab]');
  tabs.forEach(function (t) {
    t.addEventListener('click', function () {
      tabs.forEach(function (o) { o.setAttribute('aria-selected', String(o === t)); });
      document.querySelectorAll('[data-panel]').forEach(function (p) {
        p.classList.toggle('on', p.getAttribute('data-panel') === t.getAttribute('data-tab'));
      });
    });
  });

  // Copy SHA-256.
  var copy = document.getElementById('copy');
  copy.addEventListener('click', function () {
    var hash = document.getElementById('sha').textContent.replace('SHA-256 ', '').trim();
    var done = function () {
      copy.textContent = root.lang === 'ar' ? AR.copied : 'Copied';
      setTimeout(function () { copy.textContent = root.lang === 'ar' ? AR.copy : EN.copy; }, 1800);
    };
    if (navigator.clipboard) navigator.clipboard.writeText(hash).then(done, done); else done();
  });

  document.getElementById('year').textContent = new Date().getFullYear();
})();
