var p5sketch = function(sketch) {
  var gamename = "blocks";

  var blocks;
  var curshape;
  var nextshape;
  var gameend;
  var started;
  var curX, curY;
  var xcen, ycen;
  var dispX, dispY, dispW, dispH;
  var bsize;
  var lines;
  var score;
  var curfade;
  var ttr;
  var ctrl;
  var name;
  var scores;
  var colors;
  var font;
  var ggLogo, logo, st, stgl;

  sketch.preload = function() {
    font = sketch.loadFont("Noticia.ttf");
    ggLogo = sketch.loadImage("images/FGLogo.png");
    logo = sketch.loadImage("images/BlocksLogo.png");

    var loc = ["55", "66", "77", "88", "99", "58"];
    
    st = [];
    stgl = [];
    for (var i = 0; i < 6; i++) {
      st.push(sketch.loadImage("images/Start" + loc[i] + ".png"));
      stgl.push(sketch.loadImage("images/Start" + loc[i] + "Glow.png"));
    }
  };

  sketch.setup = function() {
    sketch.createCanvas(615, 402);
    prepareCanvas(sketch.canvas);

    curshape = [[]];
    
    startscreen = new Start(this, font, ggLogo, gamename);
    startscreen.setLogo(logo);
    
    for (var i = 0; i < 6; i++) {
      startscreen.addButton(
          st[i],
          stgl[i],
          Math.floor(sketch.width / 2) + (Math.floor(i / 2) - 1) * Math.floor(sketch.width / 3),
          270 + 70 * (i % 2), i);
    }

    startscreen.alttext = "Select a board size";
    startscreen.adjustLogo(Math.floor(sketch.width / 2), 130);
    
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

  function newgame(rows, columns) {
    gamename = "blocks" + rows + "_" + columns;
    
    blocks = [];
    for (var i = 0; i < columns; i++) {
      blocks.push([]);
      for (var j = 0; j < rows; j++) {
        blocks[i][j] = -1;
      }
    }

    lines = 0;
    score = 0;
    
    /*
    try {
      scores = sketch.loadStrings(gamename + ".best");
    } catch (Exception e) {
      scores = [0, 0];
    }
    if (scores == null) {
      scores = [0, 0];
    }
    */
    
    dispX = 120 + 178 - Math.floor(columns * (bsize + 1) / 2);
    dispW = blocks.length * (bsize + 1) + 1;
    dispH = blocks[0].length * (bsize + 1) + 1;

    nextshape = [[]];

    getNextBlock();
    getNextBlock();

    gameend = false;
    started = true;
    checkMouse();
  }

  function getLevel() {
    return 10 * Math.floor(lines / 100) + Math.floor(Math.sqrt(lines % 100));
  }

  function setColor(col, alph) {
    sketch.fill(
        sketch.red(colors[col]),
        sketch.green(colors[col]),
        sketch.blue(colors[col]), alph);
  }

  function drawBlock(left, top, blocksize, shapearray, shapecolor, alph, connected) {
    setColor(shapecolor, alph);
    for (var i = 0; i < shapearray.length; i++)
    {
      for (var j = 0; j < shapearray[i].length; j++)
      {
        var wid = blocksize;
        var hei = blocksize;
        if (connected && i < shapearray.length - 1 && shapearray[i + 1][j]) {
          wid += 1;
        }
        if (connected && j < shapearray[i].length - 1 && shapearray[i][j + 1]) {
          hei += 1;
        }
        if (shapearray[i][j]) {
          sketch.rect((blocksize + 1) * i + left, (blocksize + 1) * j + top, wid, hei);
        }
      }
    }
  }

  function drawStartScreen() {
    startscreen.draw();
  }

  function drawPlayingArea() {
    sketch.fill(0);
    sketch.textFont(font);
    sketch.textSize(12);
    sketch.textAlign(sketch.CENTER, sketch.CENTER);
    sketch.text("next:", 55, 11);
    sketch.text("lines:", 545, 11);
    sketch.text("score:", 545, 101);
    /*
    sketch.text("best: " + scores[0], 545, 75);
    sketch.text("best: " + scores[1], 545, 165);
    */
    sketch.fill(51);
    sketch.rect(dispX - 1, dispY - 1, dispW, dispH);
    sketch.rect(19, 19, 81, 81);
    sketch.rect(495, 19, 100, 50);
    sketch.rect(495, 109, 100, 50);
 
    sketch.fill(240, 50, 50);
    var alph;
    if (curfade < 80) {
      alph = 255 - 3 * curfade;
    } else {
      alph = 15 + 3 * (curfade - 80);
    }
    for (var i = 0; i < blocks.length; i++)
    {
      for (var j = 0; j < blocks[i].length; j++)
      {
        if (blocks[i][j] >= 0)
        {
          if (willVanish(i, j)) {
            setColor(blocks[i][j], alph);
          } else {
            setColor(blocks[i][j], 255);
          }
          sketch.rect((bsize + 1) * i + dispX, (bsize + 1) * j + dispY, bsize, bsize);
        } else if (wouldFill(i, j)) {
          if (willVanish(i, j)) {
            setColor(1, alph);
          } else {
            setColor(1, 255);
          }
          sketch.rect((bsize + 1) * i + dispX, (bsize + 1) * j + dispY, bsize, bsize);
        }
      }
    }
    
    var xo = Math.floor((bsize + 1) * -xcen);
    var yo = Math.floor((bsize + 1) * -ycen);
    
    if (curX < 0 || curY < 0) {
      drawBlock(sketch.mouseX + xo, sketch.mouseY + yo, bsize, curshape, 2, 120, true);
    }

    xo = 8 * (5 - nextshape.length);
    yo = 8 * (5 - nextshape[0].length);
    drawBlock(20 + xo, 20 + yo, 15, nextshape, 0, 255, false);

    sketch.textFont(font);
    sketch.textSize(32);
    sketch.textAlign(sketch.CENTER, sketch.CENTER);

    sketch.fill(255, 0, 0);
    sketch.text(lines, 545, 40);
    sketch.text(score, 545, 130);
    
    curfade = (curfade + 1) % 160;
  }

  sketch.draw = function() {
    sketch.background(200);
    
    if (!started) {
      drawStartScreen();
    } else {
      drawPlayingArea();
      
      if (gameend) {
        sketch.textAlign(sketch.CENTER, sketch.CENTER);
        sketch.text("GAME OVER", Math.floor(sketch.width / 2), 270);
        sketch.textFont(font);
        sketch.textSize(12);
        sketch.fill(0);
        sketch.text("Click to play again", Math.floor(sketch.width / 2), 300);
        if (ttr > 0) {
          ttr--;
        }
      }
    }
  };

  function setBlock(cols) {
    var rows = Array.prototype.slice.call(arguments, 1);
    var k;
    nextshape = [];
    for (var i = 0; i < cols; i++) {
      nextshape.push([]);
    }
    for (var j = 0; j < rows.length; j++) {
      k = 1;
      for (var i = 0; i < cols; i++) {
        nextshape[i][j] = (rows[j] & k) == k;
        k *= 2;
      }
    }
  }

  function checkCen() {
    xcen = curshape.length / 2;
    ycen = curshape[0].length / 2;
    if (curshape.length % 2 == 0 && curshape.length > 1)
    {
      var c1 = 0, c2 = 0;
      for (var i = 0; i < curshape[0].length; i++)
      {
        if (curshape[Math.floor(xcen) - 1][i]) {
          c1++;
        }
        if (curshape[Math.floor(xcen)][i]) {
          c2++;
        }
      }
      if (c2 > c1 + 1) {
        xcen = Math.floor(xcen) + .5;
      } else if (c1 > c2 + 1) {
        xcen = Math.floor(xcen) - .5;
      }
    }
    if (curshape[0].length % 2 == 0 && curshape[0].length > 1)
    {
      var c1 = 0, c2 = 0;
      for (var i = 0; i < curshape.length; i++)
      {
        if (curshape[i][Math.floor(ycen) - 1]) {
          c1++;
        }
        if (curshape[i][Math.floor(ycen)]) {
          c2++;
        }
      }
      if (c2 > c1 + 1) {
        ycen = Math.floor(ycen) + .5;
      } else if (c1 > c2 + 1) {
        ycen = Math.floor(ycen) - .5;
      }
    }
  }

  function nextBlock(four) {
    var r = Math.floor(sketch.random(7));
    var dir = Math.floor(sketch.random(4));
    if (!four) {
      r = Math.floor(sketch.random(7, 24));
    }

    curshape = nextshape;

    checkCen();
    
    switch(r) {
      case 0:
        setBlock(4, 15);
        break;
      case 1:
        setBlock(3, 2, 7);
        break;
      case 2:
        setBlock(3, 3, 6);
        break;
      case 3:
        setBlock(3, 6, 3);
        break;
      case 4:
        setBlock(2, 3, 3);
        break;
      case 5:
        setBlock(3, 7, 4);
        break;
      case 6:
        setBlock(3, 7, 1);
        break;
      case 7:
        setBlock(5, 31);
        break;
      case 8:
        setBlock(4, 15, 1);
        break;
      case 9:
        setBlock(4, 15, 2);
        break;
      case 10:
        setBlock(4, 15, 4);
        break;
      case 11:
        setBlock(4, 15, 8);
        break;
      case 12:
        setBlock(3, 7, 5);
        break;
      case 13:
        setBlock(3, 7, 3);
        break;
      case 14:
        setBlock(3, 7, 6);
        break;
      case 15:
        setBlock(3, 7, 1, 1);
        break;
      case 16:
        setBlock(3, 1, 7, 1);
        break;
      case 17:
        setBlock(3, 2, 7, 1);
        break;
      case 18:
        setBlock(3, 4, 7, 1);
        break;
      case 19:
        setBlock(3, 2, 7, 2);
        break;
      case 20:
        setBlock(3, 2, 7, 4);
        break;
      case 21:
        setBlock(3, 4, 6, 3);
        break;
      case 22:
        setBlock(4, 12, 7);
        break;
      case 23:
        setBlock(4, 7, 12);
        break;
    }
    for (var i = 0; i < dir; i++) {
      nextshape = rotateLeft(nextshape);
    }
    curY = 0;
  }

  function rotateLeft(oldshape) {
    var newshape = [];
    for (var i = 0; i < oldshape[0].length; i++) {
      newshape.push([]);
      for (var j = 0; j < oldshape.length; j++) {
        newshape[i][j] = oldshape[j][oldshape[0].length - i - 1];
      }
    }
    return newshape;
  }

  function rotateRight(oldshape) {
    var newshape = [];
    for (var i = 0; i < oldshape[0].length; i++) {
      newshape.push([]);
      for (var j = 0; j < oldshape.length; j++) {
        newshape[i][j] = oldshape[oldshape.length - j - 1][i];
      }
    }
    return newshape;
  }

  function doRotateLeft() {
    curshape = rotateLeft(curshape);
    checkCen();
  }

  function doRotateRight() {
    curshape = rotateRight(curshape);
    checkCen();
  }

  function canPlace(testshape, cx, cy) {
    for (var i = 0; i < testshape.length; i++) {
      for (var j = 0; j < testshape[i].length; j++) {
        if (testshape[i][j]) {
          if (cx + i < 0 || cy + j < 0) {
            return false;
          }
          if (cx + i >= blocks.length || cy + j >= blocks[0].length) {
            return false;
          }
          if (blocks[cx + i][cy + j] >= 0) {
            return false;
          }
        }
      }
    }
    return true;
  }

  function getNextBlock() {
    if (getLevel() >= 10) {
      nextBlock(sketch.random(10, 20) > getLevel());
    } else {
      nextBlock(true);
    }
  }

  function placeable() {
    var test = curshape;
    for (var k = 0; k < 4; k++)
    {
      for (var i = 0; i < blocks.length; i++)
      {
        for (var j = 0; j < blocks[0].length; j++)
        {
          if (canPlace(test, i, j))
            return true;
        }
      }
      test = rotateLeft(test);
    }
    return false;
  }

  function place() {
    for (var i = 0; i < curshape.length; i++) {
      for (var j = 0; j < curshape[i].length; j++) {
        if (curshape[i][j]) {
          blocks[curX + i][curY + j] = 0;
        }
      }
    }
    checkrow();
    getNextBlock();
    if (!placeable()) {
      endGame();
    }
  }

  function wouldFill(xi, yi) {
    if (curX < 0 || curY < 0) {
      return false;
    }
    var xv = xi - curX;
    var yv = yi - curY;
    if (xv < 0 || xv >= curshape.length || yv < 0 || yv >= curshape[0].length) {
      return false;
    }
    return curshape[xv][yv];
  }

  function willVanish(xi, yi) {
    if (curX < 0 || curY < 0) {
      return false;
    }
    var row = true, col = true;
    for (var j = 0; j < blocks.length; j++) {
      if (blocks[j][yi] < 0 && !wouldFill(j, yi)) {
        row = false;
        break;
      }
    }
    if (row) {
      return true;
    }
    for (var i = 0; i < blocks[0].length; i++) {
      if (blocks[xi][i] < 0 && !wouldFill(xi, i)) {
        col = false;
        break;
      }
    }
    if (col) {
      return true;
    }
    return false;
  }

  function checkrow() {
    var n = 0;
    var nr = 0, nc = 0;
    var crow, ccol;
    crow = [];
    ccol = [];
    var filled;
    for (var i = 0; i < blocks[0].length; i++) {
      filled = true;
      for (var j = 0; j < blocks.length; j++) {
        if (blocks[j][i] < 0) {
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
    for (var i = 0; i < blocks.length; i++) {
      filled = true;
      for (var j = 0; j < blocks[0].length; j++) {
        if (blocks[i][j] < 0) {
          filled = false;
          break;
        }
      }
      if (filled) {
        ccol[i] = true;
        nc++;
      } else {
        ccol[i] = false;
      }
    }
    n = Math.max(nc, nr) * (Math.min(nc, nr) + 1);
    for (var i = 0; i < blocks[0].length; i++) {
      if (crow[i]) {
        clearrow(i);
      }
    }
    for (var i = 0; i < blocks.length; i++) {
      if (ccol[i]) {
        clearcol(i);
      }
    }
    score += Math.floor((n * n + n) / 2);
  }

  function clearrow(row) {
    lines++;
    for (var j = 0; j < blocks.length; j++) {
      blocks[j][row] = -1;
    }
  }

  function clearcol(col) {
    lines++;
    for (var i = 0; i < blocks[0].length; i++)
      blocks[col][i] = -1;
  }

  function endGame() {
    curX = -1;
    curY = -1;
    ttr = 50;
    gameend = true;

    postScore(gamename, name, lines, score);
  }

  sketch.keyTyped = function() {
    if (!started) {
      startscreen.keyTyped();
    }
  };

  sketch.keyPressed = function() {
    if (sketch.keyCode == sketch.CONTROL) {
      ctrl = true;
    }
    if (!started) {
      startscreen.keyPressed();
    } else {
      if (sketch.keyCode == 114) {
        started = false;
        gameend = false;
      } else if (sketch.keyCode == 115) {
        newgame(blocks[0].length, blocks.length);
      }
    }
    if (started && !gameend) {
      if (sketch.keyCode == sketch.LEFT_ARROW) {
        doRotateRight();
        checkMouse();
      } else if (sketch.keyCode == sketch.RIGHT_ARROW) {
        doRotateLeft();
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
    var border = 0;
    if (sketch.mouseX < dispX - border || sketch.mouseX > dispX + dispW + border) {
      return true;
    }
    if (sketch.mouseY < dispY - border || sketch.mouseY > dispY + dispH + border) {
      return true;
    }
    return false;
  }

  sketch.mouseClicked = function() {
    if (!started) {
      var sizesel = startscreen.mouseClicked();
      if (sizesel != null)
      {
        name = startscreen.pname;
        if (sizesel == 5) {
          newgame(5, 8);
        } else {
          newgame(sizesel + 5, sizesel + 5);
        }
      }
    } else if (!gameend) {
      if (sketch.mouseButton == sketch.RIGHT || ctrl || outsideBox()) {
        doRotateLeft();
        checkMouse();
      } else if (curX >= 0 && curY >= 0) {
        place();
        checkMouse();
      }
    } else if (ttr <= 0) {
      started = false;
      gameend = false;
    }
  };

  function getMouseX() {
    var xo = Math.floor((bsize + 1) * -xcen);
    var xind;
    xind = Math.round((sketch.mouseX + xo - dispX) / (bsize + 1));
    if (xind < 0 || xind >= blocks.length) {
      return -1;
    } else {
      return xind;
    }
  }

  function getMouseY() {
    var yo = Math.floor((bsize + 1) * -ycen);
    var yind;
    yind = Math.round((sketch.mouseY + yo - dispY) / (bsize + 1));
    if (yind < 0 || yind >= blocks[0].length) {
      return -1;
    } else {
      return yind;
    }
  }

  function checkMouse() {
    var ox = curX;
    var oy = curY;
    curX = getMouseX();
    curY = getMouseY();
    
    if (curX >= 0 && curY >= 0 && !canPlace(curshape, curX, curY)) {
      curX = -1;
      curY = -1;
    }
    
    if (ox != curX || oy != curY) {
      curfade = 0;
    }
  }

  sketch.mouseMoved = function() {
    if (!started) {
      startscreen.mouseMoved();
    } else if (!gameend) {
      checkMouse();
    }
  };
}

var myp5 = new p5(p5sketch, 'p5container');
