var p5sketch = function(sketch) {
  var gamename = "circlejump";

  var you;
  var startscreen;
  var circles;
  var items;
  var started, gameend, paused;
  var dispX, dispY, dispW, dispH;
  var camX, camY;
  var maxX;
  var score;
  var ttr;
  var maxtries;
  var mode;
  var np, maxnp;
  var lives, time, fnumber, fupdate, jumps;
  var yspeed;
  var yangv, circrate, margin;
  var moveleft, moveright, moveup, movedown, space;
  var scores;
  var font;
  var logo, ggLogo, stArc, stArcGl, stTim, stTimGl, stStr, stStrGl;

  sketch.preload = function() {
    font = sketch.loadFont("Noticia.ttf");
    ggLogo = sketch.loadImage("images/FGLogo.png");
    logo = sketch.loadImage("images/CircleJumpLogo.png");
    stArc = sketch.loadImage("images/StartArcade.png");
    stArcGl = sketch.loadImage("images/StartArcadeGlow.png");
    stTim = sketch.loadImage("images/StartTimed.png");
    stTimGl = sketch.loadImage("images/StartTimedGlow.png");
    stStr = sketch.loadImage("images/StartStrategy.png");
    stStrGl = sketch.loadImage("images/StartStrategyGlow.png");
  };

  sketch.setup = function() {
    sketch.createCanvas(730, 550);
    prepareCanvas(sketch.canvas);

    startscreen = new Start(this, font, ggLogo, gamename);
    startscreen.setLogo(logo);
    startscreen.changeOffset(-18);
    startscreen.addButton(stArc, stArcGl, sketch.width / 2, 270, 0);
    startscreen.addButton(stTim, stTimGl, sketch.width / 2, 373, 1);
    startscreen.addButton(stStr, stStrGl, sketch.width / 2, 476, 2);

    dispX = 10;
    dispY = 10;
    dispW = 600;
    dispH = sketch.height - 20;
    
    yspeed = 5;
    yangv = 4;
    maxtries = 10;
    circrate = 0.005;
    margin = 7;
    
    started = false;

    sketch.noStroke();
  };

  function newgame(modenum) {
    mode = modenum;
    score = 0;
    np = 0;
    fnumber = 0;
    timestart = false;
    
    if (mode == 0) {
      gamename = "circlejump_arcade";
      lives = 3;
      circrate = 0.005;
      maxnp = 300;
      np = 100;
    } else if (mode == 1) {
      gamename = "circlejump_timed";
      time = 60;
      circrate = 0.01;
      maxnp = 200;
      fupdate = 60;
      np = 0;
    } else if (mode == 2) {
      gamename = "circlejump_strategy";
      jumps = 10;
      circrate = 0.008;
      maxnp = 200;
      np = 0;
    }
    
    gameend = false;
    started = true;
    
    circles = new ThingList();
    items = new ItemList();
    
    this.mode = mode;

    var s = new StartCircle(sketch.PI / 4, yangv);
    circles.addThing(s);
    
    you = new You(s.xc + s.rad, 0, 10);
    you.curcircle = s;
    maxX = s.xc + s.rad;
    
    for (var i = 200; i <= dispW + you.xc; i++) {
      placeCircle(i, circrate);
    }

    camX = dispW / 2;
    camY = 0;
  }

  function placeCircle(xval, prob) {
    var cm = margin + you.rad;
    if (sketch.random() > prob) {
      np++;
      if (np < maxnp) {
        return;
      }
    }
    np = 0;
    var rad = sketch.random(50, 130);
    var yval = sketch.random(-dispH / 2 + rad + cm, dispH / 2 - rad - cm);
    var av = sketch.random(1.5, 3);
    if (sketch.random() < 0.5) {
      av *= -1;
    }
    var tries = 0;
    var c = new getCircle(xval, yval, rad, av / rad);
    var t = circles.touching(c, cm, true);
    while (t != null && tries < maxtries) {
      rad = sketch.random(50, 130);
      yval = sketch.random(-dispH / 2 + rad + cm, dispH / 2 - rad - cm);
      c = getCircle(xval, yval, rad, av / rad);
      t = circles.touching(c, cm, true);
      tries++;
    }
    if (tries < maxtries) {
      circles.addThing(c);
    }
  }

  function getCircle(xc, yc, rad, anglev) {
    if (mode == 0 || mode == 1) {
      return new Circle(xc, yc, rad, anglev);
    } else {
      return new PuzzleCircle(xc, yc, rad, anglev);
    }
  }

  function drawStartScreen() {
    startscreen.draw();
  }

  function drawPlayingArea() {
    sketch.background(50);
    sketch.fill(200);
    sketch.rect(dispX, dispY, dispW, dispH);
    
    sketch.push();
    sketch.translate(dispX + dispW / 2 - camX, dispY + dispH / 2 - camY);
    sketch.scale(1, -1);
    sketch.stroke(0);
    sketch.noFill();
    you.render();
    circles.render();
    sketch.pop();
    
    sketch.rectMode(sketch.CORNERS);
    sketch.fill(50);
    sketch.rect(0, 0, dispX, sketch.height);
    sketch.rect(dispX + dispW, 0, sketch.width, sketch.height);
    sketch.rect(0, 0, sketch.width, dispY);
    sketch.rect(0, dispY + dispH, sketch.width, sketch.height); 
    sketch.rectMode(sketch.CORNER);
    sketch.fill(200);
    sketch.rect(dispX + dispW + 10, dispY, 100, dispH);
   
    sketch.textFont(font);
    sketch.textSize(32);
    sketch.textAlign(sketch.CENTER, sketch.CENTER);

    var middleX = dispX + dispW + 60;
    var middleY;
    sketch.fill(0);
    sketch.textFont(font);
    sketch.textSize(12);
    sketch.textAlign(sketch.CENTER, sketch.CENTER);
    var countdown;
    if (mode == 0) {
      if (lives == 1) {
        countdown = "1 life";
      } else {
        countdown = lives + " lives";
      }
    } else if (mode == 1) {
      if (time == 1) {
        countdown = "1 second";
      } else {
        countdown = time + " seconds";
      }
    } else if (mode == 2) {
      if (jumps == 1) {
        countdown = "1 jump";
      } else {
        countdown = jumps + " jumps";
      }
    }
    sketch.text(countdown, middleX, 80);
    sketch.text("current jump", middleX, 120);
    sketch.text(you.curscore(), middleX, 140);
    sketch.text("score", middleX, 25);
    sketch.textFont(font);
    sketch.textSize(24);
    sketch.text(score, middleX, 50);
  }

  function drawGameOver() {
    sketch.fill(200);
    middleX = dispX + dispW / 2;
    middleY = dispY + dispH / 2;
    sketch.stroke(0);
    sketch.rect(middleX - 120, middleY - 40, 240, 80);
    sketch.noStroke();
    sketch.fill(255, 0, 0);
    sketch.textAlign(sketch.CENTER, sketch.CENTER);
    sketch.text("GAME OVER", middleX, middleY - 13);
    sketch.textFont(font);
    sketch.textSize(12);
    sketch.fill(0);
    sketch.text("Click or press enter to play again", middleX, middleY + 17);
  }

  function drawPauseScreen() {
    sketch.fill(200);
    middleX = dispX + dispW / 2;
    middleY = dispY + dispH / 2;
    sketch.stroke(0);
    sketch.rect(middleX - 120, middleY - 40, 240, 80);
    sketch.noStroke();
    sketch.fill(255, 0, 0);
    sketch.textAlign(sketch.CENTER, sketch.CENTER);
    sketch.text("PAUSED", middleX, middleY - 13);
    sketch.textFont(font);
    sketch.textSize(12);
    sketch.fill(0);
    sketch.text("Press P to resume", middleX, middleY + 17);
  }

  function moveStuff() {
    circles.move();
    you.selfmove();
    if (timestart) {
      fnumber++;
    }
    if (mode == 1 && fnumber > 0 && fnumber % fupdate == 0) {
      if (time > 0) {
        time--;
      }
      if (time <= 0 && you.curcircle != null) {
        endGame();
      }
    }
  }

  sketch.draw = function() {
    if (!started) {
      drawStartScreen();
    } else {
      if (!gameend && !paused) {
        moveStuff();
      }
      drawPlayingArea();
      if (gameend) {
        drawGameOver();
      } else if (paused) {
        drawPauseScreen();
      }
    }
    if (ttr > 0) {
      ttr--;
    }
  };

  function endGame() {
    ttr = 50;
    gameend = true;

    postScore(gamename, score);
  }

  sketch.keyPressed = function() {
    if (started) {
      if (sketch.keyCode == 114) {
        started = false;
        gameend = false;
      }
      if (sketch.keyCode == 115) {
        newgame(mode);
      }
    }

    if (started && !gameend) {
      if (sketch.key == ' ') {
        space = true;
      }
      if (sketch.key == 'p' || sketch.key == 'P') {
        paused = !paused;
      }
      switch(sketch.keyCode) {
        case sketch.LEFT_ARROW:
          moveleft = true;
          break;
        case sketch.RIGHT_ARROW:
          moveright = true;
          break;
        case sketch.UP_ARROW:
          moveup = true;
          break;
        case sketch.DOWN_ARROW:
          movedown = true;
          break;
      }
    } else if (gameend) {
      if (sketch.keyCode == sketch.RETURN || sketch.keyCode == sketch.ENTER) {
        started = false;
        gameend = false;
      }
    }
  };

  sketch.keyReleased = function() {
    if (sketch.keyCode == sketch.LEFT_ARROW) {
      moveleft = false;
    }
    if (sketch.keyCode == sketch.RIGHT_ARROW) {
      moveright = false;
    }
    if (sketch.keyCode == sketch.UP_ARROW) {
      moveup = false;
    }
    if (sketch.keyCode == sketch.DOWN_ARROW) {
      movedown = false;
    }
    if (sketch.key == ' ') {
      space = false;
    }
  };

  sketch.mouseClicked = function() {
    if (!started) {
      var modesel = startscreen.mouseClicked();
      if (modesel != null) {
        newgame(modesel);
      }
    }
    if (gameend && ttr <= 0) {
      started = false;
      gameend = false;
    }
  };

  class Thing {
    constructor(xc, yc, rad) {
      this.exists = true;
      this.xc = xc;
      this.yc = yc;
      this.rad = rad;
    }

    move(xd, yd) {
      this.xc += xd;
      this.yc += yd;
    }

    selfmove() {
    }

    render() {
      sketch.ellipseMode(sketch.RADIUS);
      sketch.ellipse(this.xc, this.yc, this.rad, this.rad);
    }
    
    visible() {
      if (Math.abs(this.xc - camX) > dispW + 150) {
        return false;
      }
      if (Math.abs(this.yc - camY) > dispH + 100) {
        return false;
      }
      return true;
    }

    destroy() {
      this.exists = false;
    }

    touching(other, mindist) {
      var xd = other.xc - this.xc;
      var yd = other.yc - this.yc;
      var dist2 = xd * xd + yd * yd;
      var rad2 = other.rad + this.rad + mindist;
      rad2 *= rad2;
      return (dist2 <= rad2);
    }
  }

  class Circle extends Thing {
    constructor(xc, yc, rad, anglev) {
      super(xc, yc, rad);
      this.theta = 0;
      this.anglev = anglev;
      this.dotcolor = sketch.color(0);
      this.visited = false;
    }
    
    render() {
      sketch.stroke(0);
      if (this.visited && mode == 0) {
        sketch.fill(255, 255, 100);
      } else {
        sketch.fill(255);
      }
      super.render();
      sketch.noStroke();
      sketch.fill(this.dotcolor);
      for (var dt = 0; dt <= sketch.TWO_PI; dt += sketch.HALF_PI) {
        sketch.ellipse(
            this.xc + Math.cos(this.theta + dt) * (this.rad - 10),
            this.yc + Math.sin(this.theta + dt) * (this.rad - 10),
            6,
            6);
      }
    }
    
    rotate(dt) {
      this.theta += dt;
      if (you.curcircle == this) {
        you.rotate(dt);
      }
    }
    
    selfmove() {
      this.rotate(this.anglev);
    }
    
    land() {
      if (mode == 0 && this.visited) {
        lives--;
        if (lives <= 0) {
          endGame();
        }
      } else if (mode == 1 && time <= 0) {
        endGame();
      } else if (mode == 2) {
        jumps--;
        if (jumps <= 0) {
          endGame();
        }
      }
      this.visited = true;
    }
  }

  class PuzzleCircle extends Circle {
    constructor(xc, yc, rad, anglev) {
      super(xc, yc, rad, anglev);
      this.dotcolor = sketch.color(255, 0, 0);
    }

    selfmove() {
      if (you.curcircle == this) {
        if (moveleft) {
          this.rotate(yangv / this.rad);
        }
        if (moveright) {
          this.rotate(-yangv / this.rad);
        }
      }
    }
  }

  class StartCircle extends PuzzleCircle {
    constructor(halfang, anglev) {
      super(-dispH / (2 * Math.tan(halfang)), 0, dispH / (2 * Math.sin(halfang)), anglev);
      this.maxAng = halfang;
      this.visited = true;
    }
    
    rotate(dt) {
      if (Math.abs(this.theta + dt) < this.maxAng) {
        super.rotate(dt);
      }
    }
    
    land() {
      super.land();
      this.theta = you.theta;
    }
  }

  class Item extends Thing {
    constructor(im, xc, yc) {
      super(xc, yc, im.width / 2);
      this.im = im;
    }
    
    render() {
      sketch.imageMode(sketch.CENTER);
      sketch.image(this.im, this.xc, this.yc);
    }
    
    collect() {
    }
  }

  class Mineral extends Item {
    constructor(im, xc, yc, value) {
      super(im, xc, yc);
      this.value = value;
    }
    
    collect() {
      money += this.value;
      this.destroy();
    }
  }

  class ThingNode {
    constructor(element, prev, next) {
      this.element = element;
      this.prev = prev;
      this.next = next;
    }
  }

  class ThingList {
    constructor() {
      this.front = null;
      this.back = null;
      this.count = 0;
    }

    addThing(t) {
      var temp;
      if (this.count == 0) {
        temp = new ThingNode(t, null, null);
        this.front = temp;
        this.back = temp;
      } else {
        temp = new ThingNode(t, this.back, null);
        this.back.next = temp;
        this.back = temp;
      }
      this.count++;
    }
    
    removeNode(n) {
      if (n == this.front) {
        this.front = n.next;
      }
      if (n == this.back) {
        this.back = n.prev;
      }
      if (n.next != null) {
        n.next.prev = n.prev;
      }
      if (n.prev != null) {
        n.prev.next = n.next;
      }
      this.count--;
    }

    render() {
      var tn = this.front;
      while (tn != null) {
        if (!tn.element.exists) {
          var temp = tn.next;
          this.removeNode(tn);
          tn = temp;
        } else {
          if (tn.element.visible()) {
            tn.element.render();
          }
          tn = tn.next;
        }
      }
    }
    
    move() {
      var tn = this.front;
      while (tn != null) {
        if (!tn.element.exists) {
          var temp = tn.next;
          this.removeNode(tn);
          tn = temp;
        } else {
          if (tn.element.visible()) {
            tn.element.selfmove();
          }
          tn = tn.next;
        }
      }
    }
    
    touching(t, mindist, checkinvis) {
      var tn = this.front;
      while (tn != null) {
        if (!tn.element.exists) {
          var temp = tn.next;
          this.removeNode(tn);
          tn = temp;
        } else {
          if ((checkinvis || tn.element.visible()) && tn.element.touching(t, mindist)) {
            return tn.element;
          }
          tn = tn.next;
        }
      }
      return null;
    }
  }

  class ItemList extends ThingList {
    checkItems() {
      var tn = this.front;
      while (tn != null) {
        if (!tn.element.exists) {
          var temp = tn.next;
          this.removeNode(tn);
          tn = temp;
        } else {
          var it = tn.element;
          if (it.touching(you)) {
            it.collect();
          }
          tn = tn.next;
        }
      }
    }
  }

  class You extends Thing {
    constructor(xc, yc, rad) {
      super(xc, yc, rad);
      this.curcircle = null;
      this.prevcircle = null;
      this.theta = 0;
      this.initv = yspeed;
      this.xacc = -0.04;
      this.xv = 0;
      this.yv = 0;
      this.curjump = 0;
    }
    
    move(xd, yd) {
      super.move(xd, yd);
      if (this.xc < 0) {
        this.xc = 0;
      }
      if (this.xc - camX > 0) {
        camX = this.xc;
      }
      if (this.xc - camX < -200) {
        camX = Math.max(dispW / 2, this.xc + 200);
      }
      if (this.xc > maxX) {
        for (var i = Math.floor(maxX); i < Math.floor(this.xc); i++) {
          placeCircle(i + dispW, circrate);
        }
        maxX = this.xc;
      }
      if (Math.abs(this.yc) > dispH / 2) {
        this.yv *= -1;
      }
    }
    
    curscore() {
      return Math.floor(Math.max(1, this.curjump * this.curjump / 10000));
    }
    
    moveforward(slices) {
      for (var i = 0; i < slices; i += 1) {
        this.curjump += 1;
        this.move(this.xv / slices, this.yv / slices);
        var t = circles.touching(this, -this.rad, false);
        if (t != null && (t != this.prevcircle || this.curjump > 10)) {
          this.curcircle = t;
          this.theta = sketch.atan2(this.yc - t.yc, this.xc - t.xc);
          if (this.curcircle == this.prevcircle) {
            score += Math.floor(this.curscore() / 2);
          } else {
            score += this.curscore();
          }
          this.xc = t.rad * Math.cos(this.theta) + t.xc;
          this.yc = t.rad * Math.sin(this.theta) + t.yc;
          this.curcircle.land();
          space = false;
          moveup = false;
          return;
        }
      }
    }
    
    rotate(dt) {
      if (this.curcircle != null) {
        var xd = Math.cos(this.theta + dt) - Math.cos(this.theta);
        var yd = Math.sin(this.theta + dt) - Math.sin(this.theta);
        xd *= this.curcircle.rad;
        yd *= this.curcircle.rad;
        this.move(xd, yd);
      }
      this.theta += dt;
    }
    
    render() {
      sketch.stroke(0);
      sketch.fill(255, 0, 0);
      super.render();
      sketch.line(
          this.xc,
          this.yc,
          this.xc + Math.cos(this.theta) * this.rad,
          this.yc + Math.sin(this.theta) * this.rad);
    }
    
    selfmove() {
      if (this.curcircle != null) {
        if (space || moveup) {
          timestart = true;
          this.prevcircle = this.curcircle;
          this.curcircle = null;
          this.xv = this.initv * Math.cos(this.theta);
          this.yv = this.initv * Math.sin(this.theta);
          this.curjump = 0;
          this.moveforward(yspeed);
        }
      } else {
        this.xv += this.xacc;
        this.theta = sketch.atan2(this.yv, this.xv);
        this.moveforward(yspeed);
      }
      items.checkItems();
    }
  }
}

var myp5 = new p5(p5sketch, 'p5container');

