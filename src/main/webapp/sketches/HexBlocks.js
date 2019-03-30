var p5sketch = function(sketch) {
  var gamename = "hexblocks";
  var sq3 = Math.sqrt(3);

  var blocks;
  var loffset, roffset;
  var rad;
  var curshape, nextshape;
  var gameend;
  var started;
  var curX, curY;
  var dispX, dispY, dispW, dispH;
  var xStart;
  var bsize;
  var lines;
  var score;
  var curfade;
  var ttr;
  var ctrl;
  var scores;
  var colors;
  var font;
  var logo, ggLogo, st, stgl;

  sketch.preload = function() {
    font = sketch.loadFont("Noticia.ttf");
    ggLogo = sketch.loadImage("images/FGLogo.png");
    logo = sketch.loadImage("images/HexBlocksLogo.png");

    var loc = ["3", "4", "5", "6", "7", "8"];
    
    st = [];
    stgl = [];
    for (var i = 0; i < 6; i++) {
      st.push(sketch.loadImage("images/Start" + loc[i] + ".png"));
      stgl.push(sketch.loadImage("images/Start" + loc[i] + "Glow.png"));
    }
  };

  sketch.setup = function() {
    sketch.createCanvas(615, 452);
    prepareCanvas(sketch.canvas);

    curshape = new Shape(null);
    
    startscreen = new Start(this, font, ggLogo, gamename);
    startscreen.setLogo(logo);
    
    for (var i = 0; i < 6; i++) {
      startscreen.addButton(
        st[i],
        stgl[i],
        sketch.width / 2 + (i - 2.5) * sketch.width / 6,
        345, i);
    }
    startscreen.alttext = "Select a board size";
    startscreen.adjustLogo(sketch.width / 2, 150);
    
    colors = [];
    colors[0] = sketch.color(0, 128, 255);
    colors[1] = sketch.color(0, 255, 0);
    colors[2] = sketch.color(255, 50, 50);
    
    dispX = 150;
    dispY = 19;
    bsize = 24;
    
    started = false;

    sketch.noStroke();
  };

  function newgame(size) {
    gamename = "hexblocks" + "_" + size;
    rad = size;
    
    blocks = [];
    loffset = [];
    roffset = [];
    for (var i = 0; i < rad; i++) {
      blocks[i] = [];
      for (var j = 0; j < rad + i; j++) {
        blocks[i][j] = -1;
      }
      loffset[i] = rad - 1 - i;
      roffset[i] = 0;
    }
    for (var i = rad; i < 2 * rad - 1; i++) {
      blocks[i] = [];
      for (var j = 0; j < 3 * rad - 2 - i; j++) {
        blocks[i][j] = -1;
      }
      loffset[i] = 0;
      roffset[i] = i - rad + 1;
    }

    lines = 0;
    score = 0;
    
    var b1 = bsize + 1;
    
    dispW = (2 * rad - 1) * b1 + 1;
    dispH = (2 * rad - 2) * b1 * sq3 / 2 + b1 + 1;
    dispX = 120 + 178 - dispW / 2;
    xStart = dispX - b1 * 0.5 * (rad - 1);

    getNextBlock();
    getNextBlock();

    gameend = false;
    started = true;
    checkMouse();
  };

  function getLevel() {
    return 10 * Math.floor(lines / 100) + Math.floor(Math.sqrt(lines % 100));
  }

  function setColor(col, alph) {
    return sketch.color(
        sketch.red(colors[col]),
        sketch.green(colors[col]),
        sketch.blue(colors[col]),
        alph);
  }

  function getX(left, b1, i, j, ioff) {
    var xloc = ioff ? j : j + loffset[i];
    return left + b1 / 2 + b1 * xloc + b1 * 0.5 * i;
  }

  function getY(top, b1, i, j) {
    return top + b1 / 2 + b1 * sq3 * 0.5 * i;
  }

  function hexagon(x, y, radius) {
    var step = sketch.TWO_PI / 6;
    sketch.push();
    sketch.translate(x, y);
    sketch.beginShape();
    radius += 1;
    for (var i = 0; i <= 6; i++) {
      sketch.vertex(radius * Math.sin(step * i), radius * Math.cos(step * i));
    }
    sketch.endShape(sketch.CLOSE);
    sketch.pop();
  }

  function drawBlock(left, top, blocksize, shape, shapecolor, alph, connected) {
    var b1 = blocksize + 1;
    var scol = setColor(shapecolor, alph);
    sketch.fill(scol);
    for (var i = 0; i < shape.shape.length; i++) {
      for (var j = 0; j < shape.shape[i].length; j++) {
        if (shape.shape[i][j]) {
          hexagon(getX(left, b1, i, j, true), getY(top, b1, i, j), blocksize / 2);
        }
      }
    }
  }

  function drawStartScreen() {
    startscreen.draw();
  }

  function drawPlayingArea() {
    var b1 = bsize + 1;
    sketch.fill(0);
    sketch.textFont(font);
    sketch.textSize(12);
    sketch.textAlign(sketch.CENTER, sketch.CENTER);
    sketch.text("next:", 54, 11);
    sketch.text("lines:", 545, 11);
    sketch.text("score:", 545, 101);
    /*
    sketch.text("best: " + scores[0], 545, 75);
    sketch.text("best: " + scores[1], 545, 165);
    */
    sketch.fill(51);

    for (var i = 0; i < blocks.length; i++) {
      for (var j = 0; j < blocks[i].length; j++) {
        hexagon(getX(xStart, b1, i, j, false), getY(dispY, b1, i, j), bsize / 2 + 3);
      }
    }

    for (var i = 0; i < 5; i++) {
      for (var j = 0; j < 5; j++) {
        hexagon(getX(14, 16, i, j, true), getY(29, 16, i, j), 9);
      }
    }

    sketch.rect(495, 19, 100, 50);
    sketch.rect(495, 109, 100, 50);

    sketch.fill(240, 50, 50);
    var alph;
    var tj;
    var off;
    if (curfade < 40) {
      alph = 255 - 6 * curfade;
    } else {
      alph = 15 + 6 * (curfade - 40);
    }
    for (var i = 0; i < blocks.length; i++) {
      if (curY < -9) {
        off = 0;
      } else {
        off = loffset[i] - loffset[curY];
      }
      for (var j = 0; j < blocks[i].length; j++) {
        tj = j + off;
        if (blocks[i][j] >= 0) {
          if (willVanish(i, j)) {
            sketch.fill(setColor(blocks[i][j], alph));
          } else {
            sketch.fill(setColor(blocks[i][j], 255));
          }
          hexagon(getX(xStart, b1, i, j, false), getY(dispY, b1, i, j), bsize / 2);
        } else if (wouldFill(i, j)) {
          if (willVanish(i, j)) {
            sketch.fill(setColor(1, alph));
          } else {
            sketch.fill(setColor(1, 255));
          }
          hexagon(getX(xStart, b1, i, j, false), getY(dispY, b1, i, j), bsize / 2);
        }
      }
    }
    var xcen = curshape.xcen;
    var ycen = curshape.ycen;

    var xo = Math.floor(b1 * -xcen - 0.5 * b1 * ycen - b1 * 0.5);
    var yo = Math.floor(-b1 * sq3 * 0.5 * ycen - 0.5 - b1 * 0.5);

    if (curX < -9 || curY < -9) {
      drawBlock(sketch.mouseX + xo, sketch.mouseY + yo, bsize, curshape, 2, 120, true);
    }

    if (nextshape.shape.length > 0) {
      yo = 4 * sq3 * (5 - nextshape.shape.length);
      xo = 8 * (5 - nextshape.shape[0].length) + 4 * (5 - nextshape.shape.length);
      drawBlock(15 + xo, 30 + yo, 15, nextshape, 0, 255, false);
    }

    sketch.textFont(font);
    sketch.textSize(32);
    sketch.textAlign(sketch.CENTER, sketch.CENTER);

    sketch.fill(255, 0, 0);
    sketch.text(lines + "", 545, 40);
    sketch.text(score + "", 545, 130);

    curfade = (curfade + 1) % 80;
  }

  sketch.draw = function() {
    sketch.background(200);

    if (!started) {
      drawStartScreen();
    } else {
      drawPlayingArea();

      if (gameend) {
        sketch.textAlign(sketch.CENTER, sketch.CENTER);
        sketch.text("GAME OVER", sketch.width / 2, 390);
        sketch.textFont(font);
        sketch.textSize(12);
        sketch.fill(0);
        sketch.text("Click to play again", sketch.width / 2, 420);
        if (ttr > 0) {
          ttr--;
        }
      }
    }
  };

  function nextBlock(four) {
    curshape = nextshape;
    nextshape = createBlock(four);
  }

  function canPlace(testshape, cx, cy) {
    var ti, tj;
    var off;
    for (var i = 0; i < testshape.shape.length; i++) {
      ti = cy + i;
      if (ti < 0 || ti >= blocks.length) {
        return false;
      }
      off = loffset[cy] - loffset[ti];
      for (var j = 0; j < testshape.shape[i].length; j++) {
        if (testshape.shape[i][j]) {
          tj = cx + j + off;
          if (tj < 0 || tj >= blocks[ti].length) {
            return false;
          }
          if (blocks[ti][tj] >= 0) {
            return false;
          }
        }
      }
    }
    return true;
  }

  function getNextBlock() {
    if (getLevel() >= 10) {
      nextBlock(random(10) + 10 > getLevel());
    } else {
      nextBlock(true);
    }
  }

  function placeable() {
    var test = new Shape(curshape);
    for (var k = 0; k < 6; k++) {
      for (var i = 0; i < blocks.length; i++) {
        for (var j = -3; j < blocks[i].length; j++) {
          if (canPlace(test, j, i)) {
            return true;
          }
        }
      }
      test.rotateLeft();
    }
    return false;
  }

  function place() {
    var off;
    for (var i = 0; i < curshape.shape.length; i++) {
      off = loffset[curY] - loffset[curY + i];
      for (var j = 0; j < curshape.shape[i].length; j++) {
        if (curshape.shape[i][j]) {
          blocks[curY + i][curX + j + off] = 0;
        }
      }
    }
    checkrow();
    getNextBlock();
    if (!placeable()) {
      endGame();
    }
  }

  function wouldFill(i, j) {
    if (curX < -9 || curY < -9) {
      return false;
    }
    var yv = i - curY;
    if (yv < 0 || yv >= curshape.shape.length) {
      return false;
    }
    var xv = j - curX + loffset[i] - loffset[curY];
    if (xv < 0 || xv >= curshape.shape[yv].length) {
      return false;
    }
    return curshape.shape[yv][xv];
  }

  function willVanish(ci, cj) {
    if (curX < -9 || curY < -9) {
      return false;
    }
    var row, lcol, rcol;
    var tj;
    row = true;
    lcol = true;
    rcol = true;
    for (var i = 0; i < blocks.length; i++) {
      tj = cj + loffset[ci] - loffset[i];
      if (tj < 0 || tj >= blocks[i].length) {
        continue;
      }
      if (blocks[i][tj] < 0 && !wouldFill(i, tj)) {
        lcol = false;
        break;
      }
    }
    if (lcol) {
      return true;
    }
    for (var i = 0; i < blocks.length; i++) {
      tj = cj + roffset[ci] - roffset[i];
      if (tj < 0 || tj >= blocks[i].length) {
        continue;
      }
      if (blocks[i][tj] < 0 && !wouldFill(i, tj)) {
        rcol = false;
        break;
      }
    }
    if (rcol) {
      return true;
    }
    for (var j = 0; j < blocks[ci].length; j++) {
      if (blocks[ci][j] < 0 && !wouldFill(ci, j)) {
        row = false;
        break;
      }
    }
    if (row) {
      return true;
    }
    return false;
  }

  function checkrow() {
    var n = 0;
    var nr = 0, nlc = 0, nrc = 0;
    var tj;
    var crow, clcol, crcol;
    crow = [];
    clcol = [];
    crcol = [];
    var filled;
    for (var i = 0; i < blocks.length; i++) {
      filled = true;
      for (var j = 0; j < blocks[i].length; j++) {
        if (blocks[i][j] < 0) {
          filled = false;
          break;
        }
      }
      if (filled) {
        crow[i] = true;
        nr++;
      } else {
        crow[i] = false;
      }
    }
    for (var j = 0; j < blocks.length; j++) {
      filled = true;
      for (var i = 0; i < blocks.length; i++) {
        tj = j - loffset[i];
        if (tj >= 0 && tj < blocks[i].length && blocks[i][tj] < 0) {
          filled = false;
          break;
        }
      }
      if (filled) {
        clcol[j] = true;
        nlc++;
      } else {
        clcol[j] = false;
      }
    }
    for (var j = 0; j < blocks.length; j++) {
      filled = true;
      for (var i = 0; i < blocks.length; i++) {
        tj = j - roffset[i];
        if (tj >= 0 && tj < blocks[i].length && blocks[i][tj] < 0) {
          filled = false;
          break;
        }
      }
      if (filled) {
        crcol[j] = true;
        nrc++;
      } else {
        crcol[j] = false;
      }
    }

    n = (nlc + 1) * (nrc + 1) * (nr + 1) - 1;
    for (var i = 0; i < crow.length; i++) {
      if (crow[i]) {
        clearrow(i);
      }
    }
    for (var i = 0; i < clcol.length; i++) {
      if (clcol[i]) {
        clearlcol(i);
      }
    }
    for (var i = 0; i < crcol.length; i++) {
      if (crcol[i]) {
        clearrcol(i);
      }
    }
    score += (n * n + n) / 2;
  }

  function clearrow(row) {
    lines++;
    for (var j = 0; j < blocks[row].length; j++) {
      blocks[row][j] = -1;
    }
  }

  function clearlcol(col) {
    lines++;
    var tj;
    for (var i = 0; i < blocks.length; i++) {
      tj = col - loffset[i];
      if (tj >= 0 && tj < blocks[i].length) {
        blocks[i][tj] = -1;
      }
    }
  }

  function clearrcol(col) {
    lines++;
    var tj;
    for (var i = 0; i < blocks.length; i++) {
      tj = col - roffset[i];
      if (tj >= 0 && tj < blocks[i].length) {
        blocks[i][tj] = -1;
      }
    }
  }

  function endGame() {
    curX = -10;
    curY = -10;
    ttr = 50;
    gameend = true;

    postScore(gamename, lines, score);
  }

  sketch.keyPressed = function() {
    if (sketch.keyCode == sketch.CONTROL) {
      ctrl = true;
    }
    if (started) {
      if (sketch.keyCode == 114) {
        started = false;
        gameend = false;
      }
      if (sketch.keyCode == 115) {
        newgame(rad);
      }
    }
    if (started && !gameend) {
      if (sketch.keyCode == sketch.LEFT_ARROW) {
        curshape.rotateRight();
        checkMouse();
      } else if (sketch.keyCode == sketch.RIGHT_ARROW) {
        curshape.rotateLeft();
        checkMouse();
      }
    }
  };

  sketch.keyReleased = function() {
    if (sketch.keyCode == sketch.CONTROL) {
      ctrl = false;
    }
  };

  function outsideBox() {
    /*
       float border = 0;
       if (mouseX < dispX - border || mouseX > dispX + dispW + border)
       return true;
       if (mouseY < dispY - border || mouseY > dispY + dispH + border)
       return true;
     */
    return false;
  }

  sketch.mouseClicked = function() {
    if (!started) {
      var sizesel = startscreen.mouseClicked();
      if (sizesel != null) {
        newgame(sizesel + 3);
      }
    }
    if (started && !gameend) {
      checkMouse();
      if (sketch.mouseButton == sketch.RIGHT || ctrl || outsideBox()) {
        curshape.rotateLeft();
        checkMouse();
      } else if (curX >= -9 && curY >= -9) {
        place();
        checkMouse();
      }
    }
    if (gameend && ttr <= 0) {
      started = false;
      gameend = false;
    }
  };

  function getMouseX(yind) {
    if (yind < 0 || yind >= blocks.length) {
      return -1;
    }
    var b1 = bsize + 1;
    var xcen = curshape.xcen;
    var ycen = curshape.ycen;
    var xo = Math.floor(b1 * -xcen - 0.5 * b1 * (ycen - 0.5) - b1 * 0.5);
    var xind;
    xind = Math.round((sketch.mouseX + xo - xStart - yind * b1 / 2) / b1);
    xind = xind - loffset[yind];
    return xind;
  }

  function getMouseY() {
    var b1 = bsize + 1;
    var ycen = curshape.ycen;
    var yo = Math.floor(-b1 * sq3 * 0.5 * ycen - b1 * 0.5);
    var yind;
    yind = Math.round((sketch.mouseY + yo - dispY) / ((bsize + 1.0) * sq3 / 2));
    if (yind < 0 || yind >= blocks.length) {
      return -10;
    } else {
      return yind;
    }
  }

  function checkMouse() {
    var ox = curX;
    var oy = curY;
    curY = getMouseY();
    curX = getMouseX(curY);

    if (curX >= -9 && curY >= 0 && !canPlace(curshape, curX, curY)) {
      curX = -10;
      curY = -10;
    }

    if (ox != curX || oy != curY) {
      curfade = 0;
    }
  }

  sketch.mouseMoved = function() {
    if (started && !gameend) {
      checkMouse();
    }
  };

  class Shape {
    constructor(b) {
      if (b == null) {
        this.shape = [[]];
        this.xcen = 0;
        this.ycen = 0;
        return;
      }

      this.shape = [];
      this.xcen = b.xcen;
      this.ycen = b.ycen;
      for (var i = 0; i < b.shape.length; i++) {
        this.shape[i] = [];
        for (var j = 0; j < b.shape[i].length; j++) {
          this.shape[i][j] = b.shape[i][j];
        }
      }
    }

    rotateLeft() {
      var newx, newy;
      var cx, cy;
      var minx = 30, miny = 30, maxx = -30, maxy = -30;
      newx = [];
      newy = [];
      for (var i = 0; i < this.shape.length; i++) {
        newx[i] = [];
        newy[i] = [];
        for (var j = 0; j < this.shape[0].length; j++) {
          cy = j + i;
          cx = -i;

          if (this.shape[i][j]) {
            if (cy < miny) {
              miny = cy;
            }
            if (cx < minx) {
              minx = cx;
            }
            if (cy > maxy) {
              maxy = cy;
            }
            if (cx > maxx) {
              maxx = cx;
            }
          }

          newx[i][j] = cx;
          newy[i][j] = cy;
        }
      }

      var newshape = [];
      for (var i = 0; i < maxy - miny + 1; i++) {
        newshape[i] = [];
        for (var j = 0; j < maxx - minx + 1; j++) {
          newshape[i][j] = false;
        }
      }
      
      for (var i = 0; i < this.shape.length; i++) {
        for (var j = 0; j < this.shape[i].length; j++) {
          if (this.shape[i][j]) {
            newshape[newy[i][j] - miny][newx[i][j] - minx] = true;
          }
        }
      }

      var ox, oy;
      ox = this.xcen;
      oy = this.ycen;
      this.ycen = ox + oy - miny;
      this.xcen = -oy - minx;

      this.shape = newshape;
    }

    rotateRight() {
      var newx, newy;
      var cx, cy;
      var minx = 30, miny = 30, maxx = -30, maxy = -30;
      newx = [];
      newy = [];
      for (var i = 0; i < this.shape.length; i++) {
        newx[i] = [];
        newy[i] = [];
        for (var j = 0; j < this.shape[0].length; j++) {
          cy = -j;
          cx = i + j;

          if (this.shape[i][j]) {
            if (cy < miny) {
              miny = cy;
            }
            if (cx < minx) {
              minx = cx;
            }
            if (cy > maxy) {
              maxy = cy;
            }
            if (cx > maxx) {
              maxx = cx;
            }
          }

          newx[i][j] = cx;
          newy[i][j] = cy;
        }
      }

      var newshape = [];
      for (var i = 0; i < maxy - miny + 1; i++) {
        newshape[i] = [];
        for (var j = 0; j < maxx - minx + 1; j++) {
          newshape[i][j] = false;
        }
      }
      
      for (var i = 0; i < this.shape.length; i++) {
        for (var j = 0; j < this.shape[i].length; j++) {
          if (this.shape[i][j]) {
            newshape[newy[i][j] - miny][newx[i][j] - minx] = true;
          }
        }
      }

      var ox, oy;
      ox = this.xcen;
      oy = this.ycen;
      this.xcen = ox + oy - minx;
      this.ycen = -ox - miny;

      this.shape = newshape;
    }
  }

  function setBlock(b, rows /*, cols... */) {
    var cols = Array.prototype.slice.call(arguments, 2);
    var cur;
    b.shape = [];
    for (var i = 0; i < rows; i++) {
      b.shape[i] = [];
    }
    for (var j = 0; j < cols.length; j++) {
      cur = cols[j];
      for (var i = 0; i < rows; i++) {
        b.shape[i][j] = (cur & 1) == 1;
        cur >>>= 1;
      }
    }
    b.ycen = (b.shape.length - 1) / 2;
    b.xcen = (b.shape[0].length - 1) / 2;
  }

  function createBlock(four) {
    var b = new Shape(null);
    var r = Math.floor(sketch.random(10));
    var dir = Math.floor(sketch.random(6));
    if (!four) {
      r = Math.floor(sketch.random(10, 44));
    }

    switch(r) {
      case 0:
        setBlock(b, 4, 15);
        break;
      case 1:
        setBlock(b, 3, 1, 7);
        break;
      case 2:
        setBlock(b, 3, 2, 7);
        break;
      case 3:
        setBlock(b, 3, 4, 7);
        break;
      case 4:
        setBlock(b, 4, 8, 7);
        break;
      case 5:
        setBlock(b, 2, 3, 3);
        break;
      case 6:
        setBlock(b, 3, 5, 3);
        break;
      case 7:
        setBlock(b, 2, 1, 3, 2);
        break;
      case 8:
        setBlock(b, 4, 8, 6, 1);
        break;
      case 9:
        setBlock(b, 3, 2, 6, 1);
        break;

      case 10:
        setBlock(b, 5, 31);
        break;
      case 11:
        setBlock(b, 4, 1, 15);
        break;
      case 12:
        setBlock(b, 4, 2, 15);
        break;
      case 13:
        setBlock(b, 4, 4, 15);
        break;
      case 14:
        setBlock(b, 4, 8, 15);
        break;
      case 15:
        setBlock(b, 5, 16, 15);
        break;
      case 16:
        setBlock(b, 4, 3, 14);
        break;
      case 17:
        setBlock(b, 3, 1, 1, 7);
        break;
      case 18:
        setBlock(b, 3, 2, 1, 7);
        break;
      case 19:
        setBlock(b, 3, 3, 7);
        break;
      case 20:
        setBlock(b, 3, 5, 7);
        break;
      case 21:
        setBlock(b, 4, 9, 7);
        break;
      case 22:
        setBlock(b, 3, 1, 7, 4);
        break;
      case 23:
        setBlock(b, 3, 1, 7, 2);
        break;
      case 24:
        setBlock(b, 3, 1, 7, 1);
        break;
      case 25:
        setBlock(b, 4, 2, 14, 1);
        break;
      case 26:
        setBlock(b, 3, 2, 2, 7);
        break;
      case 27:
        setBlock(b, 3, 4, 2, 7);
        break;
      case 28:
        setBlock(b, 3, 6, 7);
        break;
      case 29:
        setBlock(b, 4, 10, 7);
        break;
      case 30:
        setBlock(b, 3, 2, 7, 2);
        break;
      case 31:
        setBlock(b, 3, 2, 7, 1);
        break;
      case 32:
        setBlock(b, 4, 12, 7);
        break;
      case 33:
        setBlock(b, 4, 8, 14, 1);
        break;
      case 34:
        setBlock(b, 4, 8, 8, 7);
        break;
      case 35:
        setBlock(b, 5, 24, 7);
        break;
      case 36:
        setBlock(b, 5, 16, 14, 1);
        break;
      case 37:
        setBlock(b, 2, 2, 1, 3, 2);
        break;
      case 38:
        setBlock(b, 3, 5, 3, 2);
        break;
      case 39:
        setBlock(b, 3, 1, 3, 6);
        break;
      case 40:
        setBlock(b, 2, 2, 2, 1, 3);
        break;
      case 41:
        setBlock(b, 4, 10, 6, 1);
        break;
      case 42:
        setBlock(b, 3, 3, 6, 4);
        break;
      case 43:
        setBlock(b, 3, 2, 5, 3);
        break;
    }
    for (var i = 0; i < dir; i++) {
      b.rotateLeft();
    }
    curY = 0;
    return b;
  }
}

var myp5 = new p5(p5sketch, 'p5container');

