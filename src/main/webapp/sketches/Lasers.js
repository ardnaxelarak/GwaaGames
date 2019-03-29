var p5sketch = function(sketch) {
  var gamename = "lasers";
  var you;
  var ggLogo, logo, st, stgl;
  var lasers;
  var startscreen;
  var gameend, paused;
  var started;
  var dispX, dispY, dispW, dispH;
  var yspeed;
  var score;
  var sizesel;
  var ttr;
  var updateval;
  var moveleft, moveright, moveup, movedown;
  var scores;
  var font;
  
  sketch.preload = function() {
    font = sketch.loadFont("Noticia.ttf");
    ggLogo = sketch.loadImage("images/FGLogo.png");
    logo = sketch.loadImage("images/LaserLogo.png");
    st = sketch.loadImage("images/Start.png");
    stgl = sketch.loadImage("images/StartGlow.png");
  };

  sketch.setup = function() {
    sketch.createCanvas(730, 520);
    prepareCanvas(sketch.canvas);

    startscreen = new Start(sketch, font, ggLogo, gamename);
    startscreen.setLogo(logo);
    startscreen.addButton(st, stgl, sketch.width / 2, 360, 0);

    dispX = 10;
    dispY = 10;
    dispW = 600;
    dispH = 500;
    
    yspeed = 2;
    updateval = 0;
    
    started = false;

    sketch.noStroke();
  };

  function newgame() {
    score = 0;

    gameend = false;
    started = true;

    lasers = new LaserList();

    you = new You(sketch, dispW / 2, dispH / 2, dispW, dispH);
  }

  function drawStartScreen() {
    startscreen.draw();
  }

  function drawPlayingArea() {
    sketch.background(50);
    sketch.fill(200);
    sketch.rect(dispX, dispY, dispW, dispH);
    
    sketch.push();
    sketch.translate(dispX, dispY);
    you.render();
    lasers.render();
    sketch.pop();
    
    sketch.noStroke();
    
    sketch.fill(200);
    sketch.rect(dispX + dispW + 10, dispY, 100, dispH);
    sketch.fill(50);
    sketch.rect(0, 0, dispX, sketch.height);
    sketch.rect(dispX + dispW, 0, 10, sketch.height);
    sketch.rect(0, 0, sketch.width, dispY);
    sketch.rect(0, dispY + dispH, sketch.width, sketch.height - dispY - dispH);
    
    sketch.textFont(font);
    sketch.textSize(32);
    sketch.textAlign(sketch.CENTER, sketch.CENTER);

    var middleX = dispX + dispW + 60;
    var middleY;
    sketch.fill(0);
    sketch.textFont(font);
    sketch.textSize(12);
    sketch.textAlign(sketch.CENTER, sketch.CENTER);

    sketch.text("score", middleX, 310);
    sketch.textFont(font);
    sketch.textSize(24);
    sketch.text(sketch.str(score), middleX, 335);

    if (gameend) {
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
      if (ttr > 0) {
        ttr--;
      }
    } else if (paused) {
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
      if (ttr > 0) {
        ttr--;
      }
    }
  }

  function addLaser() {
    var theta = sketch.random(2 * sketch.PI) + sketch.PI / 4;
    var x = sketch.random(dispW);
    var y = sketch.random(dispH);
    var l;
    if (theta < 3 * sketch.PI / 4) {
      y = 0;
    } else if (theta < 5 * sketch.PI / 4) {
      x = dispW;
    } else if (theta < 7 * sketch.PI / 4) {
      y = dispH;
    } else {
      x = 0;
    }
    if (score > 5) {
      theta = sketch.atan2(you.yc - y, you.xc - x);
    }
    theta += sketch.random(2 * sketch.exp(-score / 10.0)) - sketch.exp(-score / 10.0);
    l = new Laser(sketch, x, y, theta, 600, dispW, dispH);
    lasers.addBack(l);
  }

  function moveStuff() {
    if (moveleft) {
      you.move(-yspeed, 0);
    }
    if (moveright) {
      you.move(yspeed, 0);
    }
    if (moveup) {
      you.move(0, -yspeed);
    }
    if (movedown) {
      you.move(0, yspeed);
    }
        
    if (updateval == 0) {
      score++;
      addLaser();
    }
        
    updateval = (updateval + 1) % 60;
    
    lasers.extend(7);
    if (lasers.checkall(you)) {
      endGame();
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
    }
    if (ttr > 0) {
      ttr--;
    }
  };

  function endGame() {
    ttr = 50;
    gameend = true;

    postScore(gamename, score);

    /*
    try {
      scores = sketch.loadStrings(gamename + ".best");
    } catch (e) {
      scores = ["0"];
    }
    if (scores == null) {
      scores = ["0"];
    }
    if (score > sketch.int(scores[0])) {
      scores[0] = sketch.str(score);
    }
    sketch.saveStrings(scores, gamename + ".best");
    */
  }

  sketch.keyPressed = function() {
    if (started && !gameend) {
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
    } else if (started && gameend) {
      if (sketch.keyCode == sketch.RETURN 
          || sketch.keyCode == sketch.ENTER) {
        newgame();
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
  };

  sketch.mouseClicked = function() {
    if (!started) {
      if (startscreen.mouseClicked() != null) {
        newgame();
      }
    }
    if (gameend && ttr <= 0) {
      newgame();
    }
  };
};

var myp5 = new p5(p5sketch, 'p5container');

class Laser {
  constructor(sketch, xc, yc, theta, life, dispW, dispH) {
    this.sketch = sketch;
    this.xc = xc;
    this.yc = yc;
    this.theta = theta;
    this.life = life;
    this.growing = true;
    this.endx = xc;
    this.endy = yc;
    this.dispW = dispW;
    this.dispH = dispH;
  }

  render() {
    this.sketch.strokeWeight(2);
    this.sketch.stroke(255, 0, 0);
    this.sketch.line(this.xc, this.yc, this.endx, this.endy);
  }

  check() {
    if (this.endx < 0 || this.endx > this.dispW || this.endy < 0
        || this.endy > this.dispH) {
      this.growing = false;
    }
  }

  checkCollision(you) {
    var x, y, xd, yd;
    for (var t = 0; t < 1; t += 0.001) {
      x = this.xc * (1 - t) + this.endx * t;
      y = this.yc * (1 - t) + this.endy * t;
      xd = x - you.xc;
      yd = y - you.yc;
      if (xd * xd + yd * yd <= 16) {
        return true;
      }
    }
    return false;
  }

  extend(amount) {
    if (this.growing) {
      this.endx += this.sketch.cos(this.theta) * amount;
      this.endy += this.sketch.sin(this.theta) * amount;
      this.check();
    }
    this.life--;
  }
}

class You {
  constructor(sketch, xc, yc, dispW, dispH) {
    this.sketch = sketch;
    this.xc = xc;
    this.yc = yc;
    this.dispW = dispW;
    this.dispH = dispH;
  }

  render() {
    this.sketch.ellipseMode(this.sketch.RADIUS);
    this.sketch.stroke(0, 0, 255);
    this.sketch.noFill();
    this.sketch.strokeWeight(1);
    this.sketch.ellipse(this.xc, this.yc, 4, 4);
  }

  move(xd, yd) {
    this.xc += xd;
    this.yc += yd;
    if (this.xc <= 4) {
      this.xc = 4;
    }
    if (this.yc <= 4) {
      this.yc = 4;
    }
    if (this.xc > this.dispW - 5) {
      this.xc = this.dispW - 5;
    }
    if (this.yc > this.dispH - 5) {
      this.yc = this.dispH - 5;
    }
  }
}

class LaserNode {
  constructor(element, prev, next) {
    this.element = element;
    this.prev = prev;
    this.next = next;
  }
}

class LaserList {
  constructor()
  {
    this.front = null;
    this.back = null;
    this.count = 0;
  }
  
  addBack(t) {
    var temp;
    if (this.count == 0) {
      temp = new LaserNode(t, null, null);
      this.front = temp;
      this.back = temp;
    } else {
      temp = new LaserNode(t, this.back, null);
      this.back.next = temp;
      this.back = temp;
    }
    this.count++;
  }
  
  addFront(t) {
    var temp;
    if (count == 0) {
      temp = new LaserNode(t, null, null);
      this.front = temp;
      this.back = temp;
    } else {
      temp = new LaserNode(t, null, this.front);
      this.front.prev = temp;
      this.front = temp;
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
      if (tn.element.life <= 0) {
        var temp = tn.next;
        this.removeNode(tn);
        tn = temp;
      } else {
        tn.element.render();
        tn = tn.next;
      }
    }
  }
  
  extend(amount) {
    var ln = this.front;
    while (ln != null) {
      if (ln.element.life <= 0) {
        var temp = ln.next;
        this.removeNode(ln);
        ln = temp;
      } else {
        ln.element.extend(amount);
        ln = ln.next;
      }
    }
  }
  
  checkall(you) {
    var ln = this.front;
    while (ln != null) {
      if (ln.element.life <= 0)
      {
        var temp = ln.next;
        this.removeNode(ln);
        ln = temp;
      }
      else
      {
        if (ln.element.checkCollision(you)) {
          return true;
        }
        ln = ln.next;
      }
    }
    return false;
  }
}

