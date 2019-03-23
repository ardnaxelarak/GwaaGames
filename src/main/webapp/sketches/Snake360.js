var p5sketch = function(sketch) {
  var gamename = "snake";

  var score, best;
  var font;
  var startscreen;
  var tail;
  var current, food;
  var paused, moveleft, moveright, gameend, started;
  var angle;
  var left, right, top, bottom;
  var curlength;
  var radius;
  var name;
  var ggLogo, logo, st, stgl;

  sketch.preload = function() {
    font = sketch.loadFont("Noticia.ttf");
    ggLogo = sketch.loadImage("images/FGLogo.png");
    logo = sketch.loadImage("images/SnakeLogo.png");
    st = sketch.loadImage("images/Start.png");
    stgl = sketch.loadImage("images/StartGlow.png");
  };

  sketch.setup = function() {
    sketch.createCanvas(600, 600);
    prepareCanvas(sketch.canvas);

    startscreen = new Start(this, font, ggLogo, gamename);
    startscreen.setLogo(logo);
    startscreen.addButton(st, stgl, sketch.width / 2, 360, 0);

    radius = 3;
    
    left = 100;
    right = 500;
    top = 100;
    bottom = 500;
    
    score = 0;
    best = 0;
    
    sketch.ellipseMode(sketch.RADIUS);
    sketch.rectMode(sketch.CORNERS);
    sketch.textAlign(sketch.CENTER, sketch.CENTER);

    sketch.noStroke();
    sketch.smooth();
    
    started = false;
  };

  function newgame() {
    if (score > best) {
      best = score;
    }
    score = 0;
    current = new Circle((left + right) / 2, (top + bottom) / 2);
    tail = new CircleList();
    angle = 0;
    curlength = 10;
    paused = false;
    moveleft = false;
    moveright = false;
    gameend = false;
    started = true;
    placefood();
  }

  function drawStartScreen() {
    startscreen.draw();
  }

  sketch.draw = function() {
    sketch.background(200);
    
    if (!started) {
      drawStartScreen();
      return;
    }
    
    if (gameend) {
      sketch.noStroke();
      sketch.fill(0);
      sketch.textFont(font);
      sketch.textSize(32);
      sketch.text("Game over", 300, 540);
      sketch.textSize(12);
      sketch.text("Click to restart", 300, 570);
    }

    if (paused) {
      sketch.noStroke();
      sketch.fill(0);
      sketch.textFont(font);
      sketch.textSize(32);
      sketch.text("Paused", 300, 540);
      sketch.textSize(12);
      sketch.text("Press P to resume", 300, 570);
    }

    sketch.fill(150);
    sketch.stroke(0);
    sketch.strokeWeight(radius);
    sketch.rect(left, top, right, bottom);
    sketch.strokeWeight(1);
    
    sketch.fill(0);
    sketch.noStroke();
    sketch.textAlign(sketch.LEFT, sketch.BOTTOM);
    sketch.textFont(font);
    sketch.textSize(12);
    sketch.text("Score: " + score, left, top - 5);
    sketch.textAlign(sketch.RIGHT, sketch.BOTTOM);
    sketch.text("Best: " + best, right, top - 5);
    sketch.textAlign(sketch.CENTER, sketch.CENTER);
    
    sketch.fill(255);
    sketch.stroke(0);
    tail.render(current);
    
    sketch.fill(0, 255, 0);
    sketch.ellipse(food.xc, food.yc, radius, radius);
    
    if (!paused && !gameend) {
      if (moveleft) {
        angle -= 0.04;
      }
      if (moveright) {
        angle += 0.04;
      }
          
      if (sketch.frameCount % 5 == 0) {
        makemove();
      }
    }
    
    sketch.fill(255, 0, 0);
    sketch.ellipse(current.xc, current.yc, radius, radius);
  };

  function makemove() {
    tail.addElement(current);
    while (tail.size() > curlength) {
      tail.removeFirst();
    }
    current = current.next(angle);
    
    if (tail.checkCollision(current)) {
      endGame();
    }
    
    if (current.xc - radius <= left 
        || current.xc + radius >= right
        || current.yc - radius <= top
        || current.yc + radius >= bottom) {
      endGame();
    }
        
    if (current.touches(food))
    {
      curlength += 10;
      score += 1;
      placefood();
    }
  }

  function endGame() {
    gameend = true;
    if (score > 0) {
        postScore(gamename, name, score);
    }
  }

  function placefood() {
    food = new Circle(
        sketch.random(left + 15, right - 15),
        sketch.random(top + 15, bottom - 15));
  }

  sketch.keyTyped = function() {
    if (!started) {
      startscreen.keyTyped();
    }
  };

  sketch.keyPressed = function() {
    if (!started) {
      startscreen.keyPressed();
      return;
    }
    if (!paused) {
      if (sketch.keyCode == sketch.LEFT_ARROW || sketch.key == '4' || sketch.key == 'j') {
        moveleft = true;
      }
      if (sketch.keyCode == sketch.RIGHT_ARROW || sketch.key == '6' || sketch.key == 'l') {
        moveright = true;
      }
    }
    if (!gameend && sketch.key == 'p' || sketch.key == 'P') {
      paused = !paused;
    }
    if (gameend
        && (sketch.key == 'n' || sketch.keyCode == sketch.ENTER
            || sketch.keyCode == sketch.RETURN)) {
      newgame();
    }
  };

  sketch.keyReleased = function() {
    if (!paused) {
      if (sketch.keyCode == sketch.LEFT_ARROW || sketch.key == '4' || sketch.key == 'j') {
        moveleft = false;
      }
      if (sketch.keyCode == sketch.RIGHT_ARROW || sketch.key == '6' || sketch.key == 'l') {
        moveright = false;
      }
    }
  };

  sketch.mouseMoved = function() {
    if (!started) {
      startscreen.mouseMoved();
    }
  };

  sketch.mouseClicked = function() {
    if (!started) {
      if (startscreen.mouseClicked() != null) {
        name = startscreen.pname;
        newgame();
      }
    } else if (gameend) {
      newgame();
    }
  }

  class Circle {
    constructor(xc, yc) {
      this.xc = xc;
      this.yc = yc;
    }

    touches(c) {
      var xd = this.xc - c.xc;
      var yd = this.yc - c.yc;
      return xd * xd + yd * yd <= 4 * radius * radius;
    }

    next(angle) {
      var nx, ny;
      nx = (2 * radius + 1) * sketch.cos(angle) + this.xc;
      ny = (2 * radius + 1) * sketch.sin(angle) + this.yc;
      return new Circle(nx, ny);
    }

    render() {
      sketch.ellipse(this.xc, this.yc, radius, radius);
    }
  }

  class ListNode {
    constructor(element, next) {
      this.element = element;
      this.next = next;
    }
  }

  class CircleList {
    constructor() {
      this.count = 0;
      this.front = null;
      this.back = null;
    }
    
    addElement(element) {
      var temp = new ListNode(element, null);
      if (this.back == null) {
        this.front = temp;
        this.back = temp;
        this.count++;
      } else {
        this.back.next = temp;
        this.back = temp;
        this.count++;
      }
    }
    
    removeFirst() {
      if (this.front == null) {
        return null;
      }

      var temp = this.front;
      this.front = this.front.next;
      this.count--;
      return temp.element;
    }
    
    render(current) {
      var index = 1;
      var temp = this.front;
      while (temp != null) {
        index++;
        if (temp.next != null) {
          sketch.strokeWeight(radius * 2 + 1);
          sketch.line(
              temp.element.xc,
              temp.element.yc,
              temp.next.element.xc,
              temp.next.element.yc);
          sketch.strokeWeight(1);
        }
        temp = temp.next;
      }
      sketch.strokeWeight(radius * 2 + 1);
      if (current != null && this.back != null) {
        sketch.line(
            this.back.element.xc, this.back.element.yc, current.xc, current.yc);
      }
      sketch.strokeWeight(1);        
    }
    
    checkCollision(current) {
      var temp = this.front;
      while (temp != null) {
        if (current.touches(temp.element)) {
          return true;
        }
        temp = temp.next;
      }
      return false;
    }
    
    size() {
      return this.count;
    }
  }
}

var myp5 = new p5(p5sketch, 'p5container');
