HCanvas canvas;
HDrawablePool pool;
HColorPool colors;
HCallback onTweenEnd;

void setup() {
  size(640,640,P3D);
  H.init(this).background(#202020).use3D(true);
  smooth();
  
  colors = new HColorPool(
    #FFFFFF, #F7F7F7, #ECECEC, #333333,
    #0095A8, #00616F, #FF3300, #FF6600)
    .fillOnly();
  
  canvas = (HCanvas) H.add(new HCanvas(P3D)
    .autoClear(false)
    .fade(2));
  
  onTweenEnd = new HCallback(){public void run(Object obj) {
    HTween tween = (HTween) obj;
    pool.release(tween.target());
  }};
  
  pool = new HDrawablePool(300);
  pool.autoParent(canvas)
    .add( new HRect()
      .rounding(5)
      .noStroke()
      .anchorAt(H.CENTER))
    .colorist(colors)
    .onCreate(new HCallback(){public void run(Object obj) {
      HDrawable d = (HDrawable) obj;
      d.obj("tween", new HTween()
          .target(d)
          .property(H.Z)
          .ease(.0005)
          .spring(.95)
          .callback(onTweenEnd))
        .obj("rosc", new HOscillator()
          .property(H.ROTATION)
          .waveform(H.SINE)
          .speed(1)
          .freq(2)
          .range(-90,90))
        .obj("sosc", new HOscillator()
          .property(H.SCALE)
          .waveform(H.SINE)
          .speed(0.5)
          .freq(4)
          .range(0,2));
    }})
    .onRequest(new HCallback(){public void run(Object obj) {
      HDrawable d = (HDrawable) obj;
      HOscillator rosc = (HOscillator) d.obj("rosc");
      HOscillator sosc = (HOscillator) d.obj("sosc");
      HTween tween = (HTween) d.obj("tween");
      int i = pool.currentIndex();
      
      d.loc(random(width), random(height), random(-2000))
        .size(HMath.randomInt(1,11)*5);
      tween.register()
        .start(d.z())
        .end(100);
      rosc.register()
        .currentStep(i*2)
        .target(d);
      sosc.register()
        .currentStep(i*2)
        .target(d);
    }})
    .onRelease(new HCallback(){public void run(Object obj) {
      HDrawable d = (HDrawable) obj;
      HOscillator rosc = (HOscillator) d.obj("rosc");
      HOscillator sosc = (HOscillator) d.obj("sosc");
      
      rosc.unregister();
      sosc.unregister();
    }});
  
  new HTimer(250).callback(new HCallback(){public void run(Object obj){
    pool.request();
  }});
}

void draw() {
  H.drawStage();
}

