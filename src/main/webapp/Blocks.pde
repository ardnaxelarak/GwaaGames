/* @pjs font="Noticia.ttf"; */

/**
 * Left click to place a block<br>
 * Right click to rotate current block<br>
 * Rows or columns clear when completely filled<br>
 * Game ends when the current block cannot be placed<br>
 * 6 x 6 or 7 x 7 is recommended, as 5 x 5 appears to be a bit too small and 8 x 8 too big 
 */
 
String gamename = "blocks";

int[][] blocks;
boolean[][] curshape;
boolean[][] nextshape;
boolean gameend;
boolean started;
int curX, curY;
float xcen, ycen;
float dispX, dispY, dispW, dispH;
int bsize;
int lines;
int score;
int curfade;
int ttr;
boolean ctrl;
String name;
String[] scores;
color[] colors;
PFont font32, font12;

void setup()
{
    size(615, 402);

    curshape = new boolean[0][0];
    
    font32 = createFont("Noticia", 32);
    font12 = createFont("Noticia", 12);
    
    startscreen = new Start(this, font12, gamename);
    startscreen.requestLogo("images/BlocksLogo.png");
    
    String[] loc = new String[] {"55", "66", "77", "88", "99", "58"};
    
    for (int i = 0; i < 6; i++)
            startscreen.addButton(
                    "images/Start" + loc[i] + ".png",
                    "images/Start" + loc[i] + "Glow.png",
                    width / 2 + ((int)(i / 2) - 1) * width / 3,
                    270 + 70 * (i % 2), i);
    startscreen.alttext = "Select a board size";
    startscreen.adjustLogo(width / 2, 130);
    
    colors = new color[7];
    colors[0] = color(0, 128, 255);
    colors[1] = color(0, 255, 0);
    colors[2] = color(255, 50, 50);
    
    dispX = 150;
    dispY = 19;
    bsize = 24;
    
    started = false;

    noStroke();
}

void newgame(int rows, int columns)
{
    gamename = "blocks" + rows + "_" + columns;
    
    blocks = new int[columns][rows];
    for (int i = 0; i < blocks.length; i++)
    {
        for (int j = 0; j < blocks[i].length; j++)
        {
            blocks[i][j] = -1;
        }
    }

    lines = 0;
    score = 0;
    
    try
    {
        scores = loadStrings(gamename + ".best");
    }
    catch (Exception e)
    {
        scores = new String[] {"0", "0"};
    }
    if (scores == null)
        scores = new String[] {"0", "0"};
    
    dispX = 120 + 178 - (int)(columns * (bsize + 1) / 2);
    dispW = blocks.length * (bsize + 1) + 1;
    dispH = blocks[0].length * (bsize + 1) + 1;

    nextshape = new boolean[3][3];

    getNextBlock();
    getNextBlock();

    gameend = false;
    started = true;
    checkMouse();
}

int getLevel()
{
    return 10 * (int)(lines / 100) + (int)sqrt(lines % 100);
}

void setColor(int col, int alph)
{
    fill(red(colors[col]), green(colors[col]), blue(colors[col]), alph);
}

void drawBlock(int left, int top, int blocksize, boolean[][] shapearray, int shapecolor, int alph, boolean connected)
{
    setColor(shapecolor, alph);
    for (int i = 0; i < shapearray.length; i++)
    {
        for (int j = 0; j < shapearray[i].length; j++)
        {
            int wid = blocksize;
            int hei = blocksize;
            if (connected && i < shapearray.length - 1 && shapearray[i + 1][j])
                wid += 1;
            if (connected && j < shapearray[i].length - 1 && shapearray[i][j + 1])
                hei += 1;
            if (shapearray[i][j])
                 rect((blocksize + 1) * i + left, (blocksize + 1) * j + top, wid, hei);
        }
    }
}

void drawStartScreen()
{
    startscreen.draw();
}

void drawPlayingArea()
{
    fill(0);
    textFont(font12);
    textAlign(CENTER, CENTER);
    text("next:", 55, 11);
    text("lines:", 545, 11);
    text("score:", 545, 101);
    text("best: " + scores[0], 545, 75);
    text("best: " + scores[1], 545, 165);
    fill(51);
    rect(dispX - 1, dispY - 1, dispW, dispH);
    rect(19, 19, 81, 81);
    rect(495, 19, 100, 50);
    rect(495, 109, 100, 50);
 
    fill(240, 50, 50);
    int alph;
    if (curfade < 80)
        alph = 255 - 3 * curfade;
    else
        alph = 15 + 3 * (curfade - 80);
    for (int i = 0; i < blocks.length; i++)
    {
        for (int j = 0; j < blocks[i].length; j++)
        {
            if (blocks[i][j] >= 0)
            {
                if (willVanish(i, j))
                    setColor(blocks[i][j], alph);
                else
                    setColor(blocks[i][j], 255);
                rect((bsize + 1) * i + dispX, (bsize + 1) * j + dispY, bsize, bsize);
            }
            else if (wouldFill(i, j))
            {
                if (willVanish(i, j))
                    setColor(1, alph);
                else
                    setColor(1, 255);
                rect((bsize + 1) * i + dispX, (bsize + 1) * j + dispY, bsize, bsize);
            }
        }
    }
    
    int xo = (int)((bsize + 1) * -xcen);
    int yo = (int)((bsize + 1) * -ycen);
    
    if (curX < 0 || curY < 0)
        drawBlock(mouseX + xo, mouseY + yo, bsize, curshape, 2, 120, true);

    xo = 8 * (5 - nextshape.length);
    yo = 8 * (5 - nextshape[0].length);
    drawBlock(20 + xo, 20 + yo, 15, nextshape, 0, 255, false);

    textFont(font32);
    textAlign(CENTER, CENTER);

    fill(255, 0, 0);
    text(lines + "", 545, 40);
    text(score + "", 545, 130);
    
    curfade = (curfade + 1) % 160;
}

void draw()
{
    background(200);
    
    if (!started)
    {
        drawStartScreen();
    }
    else
    {
        drawPlayingArea();
        
        if (gameend)
        {
            textAlign(CENTER, CENTER);
            text("GAME OVER", (int)(width / 2), 270);
            textFont(font12);
            fill(0);
            text("Click to play again", (int)(width / 2), 300);
            if (ttr > 0)
                ttr--;
        }
    }
}

void setBlock(int cols, int... rows)
{
    int k;
    nextshape = new boolean[cols][rows.length];
    for (int j = 0; j < rows.length; j++)
    {
        k = 1;
        for (int i = 0; i < cols; i++)
        {
            nextshape[i][j] = (rows[j] & k) == k;
            k *= 2;
        }
    }
}

void checkCen()
{
    xcen = curshape.length / 2.0f;
    ycen = curshape[0].length / 2.0f;
    if (curshape.length % 2 == 0 && curshape.length > 1)
    {
        int c1 = 0, c2 = 0;
        for (int i = 0; i < curshape[0].length; i++)
        {
            if (curshape[(int)xcen - 1][i])
                c1++;
            if (curshape[(int)xcen][i])
                c2++;
        }
        if (c2 > c1 + 1)
            xcen = (int)xcen + .5;
        else if (c1 > c2 + 1)
            xcen = (int)xcen - .5;
    }
    if (curshape[0].length % 2 == 0 && curshape[0].length > 1)
    {
        int c1 = 0, c2 = 0;
        for (int i = 0; i < curshape.length; i++)
        {
            if (curshape[i][(int)ycen - 1])
                c1++;
            if (curshape[i][(int)ycen])
                c2++;
        }
        if (c2 > c1 + 1)
            ycen = (int)ycen + .5;
        else if (c1 > c2 + 1)
            ycen = (int)ycen - .5;
    }
}

void nextBlock(boolean four)
{
    int r = (int)random(7);
    int dir = (int)random(4);
    if (!four)
        r = (int)(random(17) + 7);

    curshape = nextshape;

    checkCen();
    
    switch(r)
    {
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
    for (int i = 0; i < dir; i++)
        nextshape = rotateLeft(nextshape);
    curY = 0;
}

boolean[][] rotateLeft(boolean[][] oldshape)
{
    boolean[][] newshape = new boolean[oldshape[0].length][oldshape.length];
    for (int i = 0; i < newshape.length; i++)
    {
        for (int j = 0; j < oldshape.length; j++)
        {
            newshape[i][j] = oldshape[j][newshape.length - i - 1];
        }
    }
    return newshape;
}

void doRotateLeft()
{
    curshape = rotateLeft(curshape);
    checkCen();
}

void doRotateRight()
{
    curshape = rotateRight(curshape);
    checkCen();
}

boolean[][] rotateRight(boolean[][] oldshape)
{
    boolean[][] newshape = new boolean[oldshape[0].length][oldshape.length];
    for (int i = 0; i < newshape.length; i++)
    {
        for (int j = 0; j < oldshape.length; j++)
        {
            newshape[i][j] = oldshape[oldshape.length - j - 1][i];
        }
    }
    return newshape;
}

boolean canPlace(boolean[][] testshape, int cx, int cy)
{
    for (int i = 0; i < testshape.length; i++)
    {
        for (int j = 0; j < testshape[i].length; j++)
        {
            if (testshape[i][j])
            {
                if (cx + i < 0 || cy + j < 0)
                    return false;
                if (cx + i >= blocks.length || cy + j >= blocks[0].length)
                    return false;
                if (blocks[cx + i][cy + j] >= 0)
                    return false;
            }
        }
    }
    return true;
}

void getNextBlock()
{
    if (getLevel() >= 10)
        nextBlock(random(10) + 10 > getLevel());
    else
        nextBlock(true);
}

boolean placeable()
{
    boolean[][] test = curshape;
    for (int k = 0; k < 4; k++)
    {
        for (int i = 0; i < blocks.length; i++)
        {
            for (int j = 0; j < blocks[0].length; j++)
            {
                if (canPlace(test, i, j))
                    return true;
            }
        }
        test = rotateLeft(test);
    }
    return false;
}

void place()
{
    for (int i = 0; i < curshape.length; i++)
    {
        for (int j = 0; j < curshape[i].length; j++)
        {
            if (curshape[i][j])
                blocks[curX + i][curY + j] = 0;
        }
    }
    checkrow();
    getNextBlock();
    if (!placeable())
        endGame();
}

boolean wouldFill(int xi, int yi)
{
    if (curX < 0 || curY < 0)
        return false;
    int xv = xi - curX;
    int yv = yi - curY;
    if (xv < 0 || xv >= curshape.length ||
            yv < 0 || yv >= curshape[0].length)
        return false;
    return curshape[xv][yv];
}

boolean willVanish(int xi, int yi)
{
    if (curX < 0 || curY < 0)
        return false;
    boolean row, col;
    row = true;
    col = true;
    for (int j = 0; j < blocks.length; j++)
    {
        if (blocks[j][yi] < 0 && !wouldFill(j, yi))
        {
            row = false;
            break;
        }
    }
    if (row)
        return true;
    for (int i = 0; i < blocks[0].length; i++)
    {
        if (blocks[xi][i] < 0 && !wouldFill(xi, i))
        {
            col = false;
            break;
        }
    }
    if (col)
        return true;
    return false;
}

void checkrow()
{
    int n = 0;
    int nr = 0, nc = 0;
    boolean[] crow, ccol;
    crow = new boolean[blocks[0].length];
    ccol = new boolean[blocks.length];
    boolean filled;
    for (int i = 0; i < blocks[0].length; i++)
    {
        filled = true;
        for (int j = 0; j < blocks.length; j++)
        {
            if (blocks[j][i] < 0)
            {
                filled = false;
                break;
            }
        }
        if (filled)
        {
            crow[i] = true;
            nr++;
        }
    }
    for (int i = 0; i < blocks.length; i++)
    {
        filled = true;
        for (int j = 0; j < blocks[0].length; j++)
        {
            if (blocks[i][j] < 0)
            {
                filled = false;
                break;
            }
        }
        if (filled)
        {
            ccol[i] = true;
            nc++;
        }
    }
    n = max(nc, nr) * (min(nc, nr) + 1);
    for (int i = 0; i < crow.length; i++)
        if (crow[i])
            clearrow(i);
    for (int i = 0; i < ccol.length; i++)
        if (ccol[i])
            clearcol(i);
    score += (int)((n * n + n) / 2);
}

void clearrow(int row)
{
    lines++;
    for (int j = 0; j < blocks.length; j++)
        blocks[j][row] = -1;
}

void clearcol(int col)
{
    lines++;
    for (int i = 0; i < blocks[0].length; i++)
        blocks[col][i] = -1;
}

void endGame()
{
    curX = -1;
    curY = -1;
    ttr = 50;
    gameend = true;

    writelog("scores/" + gamename + "-scores", name, lines, score);
    try
    {
        scores = loadStrings(gamename + ".best");
    }
    catch (Exception e)
    {
        scores = new String[] {"0", "0"};
    }
    if (scores == null)
        scores = new String[] {"0", "0"};
    if (lines > int(scores[0]))
        scores[0] = str(lines);
    if (score > int(scores[1]))
        scores[1] = str(score);
    saveStrings(gamename + ".best", scores);
}

void keyPressed()
{
    if (keyCode == CONTROL)
        ctrl = true;
    if (!started)
    {
        startscreen.keyPressed();
    }
    else
    {
        if (keyCode == 114)
        {
            started = false;
            gameend = false;
        }
        if (keyCode == 115)
        {
            newgame(blocks[0].length, blocks.length);
        }
    }
    if (started && !gameend)
    {
        if (keyCode == LEFT)
        {
            doRotateRight();
            checkMouse();
        }
        else if (keyCode == RIGHT)
        {
            doRotateLeft();
            checkMouse();
        }
    }
}

void keyReleased()
{
    if (keyCode == CONTROL)
        ctrl = false;
}

boolean outsideBox()
{
    float border = 0;
    if (mouseX < dispX - border || mouseX > dispX + dispW + border)
        return true;
    if (mouseY < dispY - border || mouseY > dispY + dispH + border)
        return true;
    return false;
}

void mouseClicked()
{
    if (!started)
    {
        int sizesel = startscreen.mouseClicked();
        if (sizesel != null)
        {
            name = startscreen.pname;
            if (sizesel == 5)
                newgame(5, 8);
            else
                newgame(sizesel + 5, sizesel + 5);
        }
    }
    if (started && !gameend)
    {
        if (mouseButton == RIGHT || ctrl || outsideBox())
        {
            doRotateLeft();
            checkMouse();
        }
        else if (curX >= 0 && curY >= 0)
        {
            place();
            checkMouse();
        }
    }
    if (gameend && ttr <= 0)
    {
        started = false;
        gameend = false;
    }
}

int getMouseX()
{
    int xo = (int)((bsize + 1) * -xcen);
    int xind;
    xind = round((mouseX + xo - dispX) / (bsize + 1.0));
    if (xind < 0 || xind >= blocks.length)
        return -1;
    else
        return xind;
}

int getMouseY()
{
    int yo = (int)((bsize + 1) * -ycen);
    int yind;
    yind = round((mouseY + yo - dispY) / (bsize + 1.0));
    if (yind < 0 || yind >= blocks[0].length)
        return -1;
    else
        return yind;
}

void checkMouse()
{
    int ox = curX;
    int oy = curY;
    curX = getMouseX();
    curY = getMouseY();
    
    if (curX >= 0 && curY >= 0 && !canPlace(curshape, curX, curY))
    {
        curX = -1;
        curY = -1;
    }
    
    if (ox != curX || oy != curY)
        curfade = 0;
}

void mouseMoved()
{
    if (!started)
    {
        startscreen.mouseMoved();
    }
    if (started && !gameend)
    {
        checkMouse();
    }
}

