/* @pjs font="Noticia.ttf"; */

/**
 * J/L or LEFT/RIGHT to move left/right<br>
 * COMMA or DOWN for soft drop<br>
 * K or SPACE for hard drop<br>
 * U/I or UP to rotate<br>
 * SHIFT to save block<br>
 * P to pause/resume<br>
 * N to start new game
 */
 
String gamename = "tetris";

int[][] blocks;
var startscreen;
boolean[][] curshape;
boolean[][] nextshape, savedshape;
boolean fell;
boolean paused;
boolean gameend;
boolean down;
int moveleft, moveright;
boolean started, shapesaved;
int curColor, nextColor, savedColor;
int colorIndex;
int fallcount, falldelay;
int curX, curY;
int dispX, dispY;
int bsize;
int lines;
int score;
String name;
String[] scores;
color[][] colors;
PFont font32, font12;

void saveOptions()
{
    String[] options = new String[1];
    options[0] = "color=" + colorIndex;
    try
    {
        saveStrings(gamename + ".options", options);
    }
    catch (Exception e)
    {
    }
}

void loadOptions()
{
    String[] options;
    colorIndex = 1;
    try
    {
        options = loadStrings(gamename + ".options");
        for (String option : options)
        {
            String[] pieces = option.split("=");
            if (pieces[0].equals("color"))
            {
                colorIndex = int(pieces[1]);
            }
            if (pieces[0].equals("name"))
            {
                name = pieces[1];
            }
        }
    }
    catch (Exception e)
    {
    }
}

void setup()
{
    size(615, 602);

    blocks = new int[15][24];
    
    font32 = createFont("Noticia", 32);
    font12 = createFont("Noticia", 12);
    
    startscreen = new Start(this, font12, gamename);
    startscreen.requestLogo("images/TetrisLogo.png");
    startscreen.addButton("images/Start.png", "images/StartGlow.png", width / 2, 400, 0);
    
    colors = new color[2][7];
    colors[0][0] = color(240, 80, 240);
    colors[0][1] = color(250, 150, 150);
    colors[0][2] = color(130, 180, 130);
    colors[0][3] = color(50, 240, 50);
    colors[0][4] = color(140, 150, 240);
    colors[0][5] = color(255, 200, 0);
    colors[0][6] = color(230, 255, 124);

    colors[1][0] = color(255, 128, 0);
    colors[1][1] = color(0, 134, 16);
    colors[1][2] = color(0, 255, 255);
    colors[1][3] = color(0, 128, 255);
    colors[1][4] = color(255, 255, 0);
    colors[1][5] = color(0, 255, 0);
    colors[1][6] = color(0, 255, 128);
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

    name = "";
    
    loadOptions();
    
    dispX = 100;
    dispY = 1;
    bsize = 24;
    falldelay = 40;
    moveleft = -1;
    moveright = -1;
    
    started = false;

    noStroke();
}

void newgame()
{
    for (int i = 0; i < blocks.length; i++)
    {
        for (int j = 0; j < blocks[i].length; j++)
        {
            blocks[i][j] = -1;
        }
    }

    curX = (int)(blocks.length / 2);
    curY = 0;
    curColor = 0;
    nextColor = 0;
    savedColor = 0;
    lines = 0;
    score = 0;

    nextshape = new boolean[1][1];
    savedshape = new boolean[0][0];
    shapesaved = false;

    getNextBlock();
    getNextBlock();

    fell = false;
    paused = false;
    gameend = false;
    down = false;
    moveleft = -1;
    moveright = -1;
    started = true;
}

int ghostY()
{
    int k = 0;
    while (canmove(0, k))
        k++;
    return curY + k - 1;
}

int transX(int shapeX, boolean[][] shapearray, int cx)
{
    return cx - (int)(shapearray.length / 2) + shapeX;
}

int transY(int shapeY, boolean[][] shapearray, int cy)
{
    return cy - (int)(shapearray[0].length / 2) + shapeY;
}

int getLevel()
{
    return 10 * (int)(lines / 100) + (int)sqrt(lines % 100);
}

void setColor(int col, int alph)
{
    fill(red(colors[colorIndex][col]), green(colors[colorIndex][col]), blue(colors[colorIndex][col]), alph);
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

void makeMove(int xo, int yo)
{
    if (trymove(xo, yo))
        fallcount = falldelay;
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
    text("next:", 45, 11);
    text("saved:", 45, 111);
    text("lines:", 545, 11);
    text("score:", 545, 101);
    text("best: " + scores[0], 545, 75);
    text("best: " + scores[1], 545, 165);
    text("level:", 545, 191);
    fill(51);
    rect(dispX - 1, dispY - 1, blocks.length * (bsize + 1) + 1, blocks[0].length * (bsize + 1) + 1);
    rect(9, 19, 81, 81);
    rect(9, 119, 81, 81);
    rect(495, 19, 100, 50);
    rect(495, 109, 100, 50);
    rect(495, 199, 100, 50);
 
    fill(240, 50, 50);
    for (int i = 0; i < blocks.length; i++)
    {
        for (int j = 0; j < blocks[i].length; j++)
        {
            if (blocks[i][j] >= 0)
            {
                setColor(blocks[i][j], 255);
                rect((bsize + 1) * i + dispX, (bsize + 1) * j + dispY, bsize, bsize);
            }
        }
    }
    
    if (!gameend)
    {
        drawBlock(dispX + transX(0, curshape, curX) * (bsize + 1),
                            dispY + transY(0, curshape, curY) * (bsize + 1),
                            bsize, curshape, curColor, 255, true);
        drawBlock(dispX + transX(0, curshape, curX) * (bsize + 1),
                            dispY + transY(0, curshape, ghostY()) * (bsize + 1),
                            bsize, curshape, curColor, 120, false);
    }
    
    int xo = 8 * (5 - nextshape.length);
    int yo = 8 * (5 - nextshape[0].length);
    drawBlock(10 + xo, 20 + yo, 15, nextshape, nextColor, 255, false);

    if (shapesaved)
    {
        xo = 8 * (5 - savedshape.length);
        yo = 8 * (5 - savedshape[0].length);
        drawBlock(10 + xo, 120 + yo, 15, savedshape, savedColor, 255, false);
    }

    textFont(font32);
    textAlign(CENTER, CENTER);

    fill(255, 0, 0);
    text(lines + "", 545, 40);
    text(score + "", 545, 130);
    text(getLevel() + "", 545, 220);
}

void drawPauseScreen()
{
    fill(200);
    rect(183, 220, 200, 200);
    textFont(font12);
    fill(0);
    textAlign(CENTER, CENTER);
    text("7 / U to rotate right\n" +
             "8 / I / UP to rotate right\n" +
             "LEFT / 4 / J to move left\n" + 
             "RIGHT / 6 / L to move right\n" +     
             "DOWN / 2 / COMMA to soft drop\n" + 
             "SPACE / 5 / K to hard drop\n" +
             "A to save block\n" +    
             "P to resume", 283, 300);
    if (mouseX >= 198 && mouseX <= 368 && mouseY >= 390 && mouseY <= 410)
        fill(255);
    else
        fill(200);
    stroke(0);
    strokeWeight(2);
    rect(203, 390, 20, 20);
    strokeWeight(1);
    if (colorIndex == 0)
    {
        line(203, 390, 223, 410);
        line(203, 410, 223, 390);
    }
    fill(0);
    noStroke();
    textAlign(LEFT, CENTER);
    text("Use alternate colors", 233, 400);
}

void draw()
{
    background(200);
    
//    if (moveleft >= 0)
//        println(moveleft);

    if (!started)
    {
        drawStartScreen();
    }
    else
    {
        drawPlayingArea();
        
        if (gameend)
        {
            text("GAME\nOVER", 495, 240, 100, 100);
            textFont(font12);
            fill(0);
            text("Press N to play again", 545, 365);
        }
    
        int refresh = 30 - getLevel();
        if (getLevel() >= 10)
            refresh += 5;
            
        if (refresh < 1)
            refresh = 1;
    
        if (!paused && !gameend)
        {
            if (ghostY() == curY)
            {
                fallcount--;
                if (fallcount == 0)
                    place();
            }
            else
            {
                fallcount = falldelay;
            }
            if (moveleft > 0)
                moveleft--;
            if (moveleft == 0)
            {
                makeMove(-1, 0);
                moveleft = 4;
            }
            if (moveright > 0)
                moveright--;
            if (moveright == 0)
            {
                makeMove(1, 0);
                moveright = 4;
            }
            if (frameCount % refresh == 0 || (down && frameCount % 2 == 0))
                drop();
        }
        
        if (paused)
        {
            drawPauseScreen();
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

void nextBlock(boolean four)
{
    int r = (int)random(7);
    int dir = (int)random(4);
    if (!four)
        r = (int)(random(17) + 7);
    curColor = nextColor;
    nextColor = r % 7;

    curshape = nextshape;

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
    if (!adjustnew())
        endGame();
}

boolean adjustnew()
{
    if (curY < (int)(curshape[0].length / 2))
        curY = (int)(curshape[0].length / 2);
    if (curX < (int)(curshape.length / 2))
        curX = (int)(curshape.length / 2);
    if (curX + (int)((curshape.length + 1) / 2) >= blocks.length)
        curX = blocks.length - (int)((curshape.length + 1) / 2);
    for (int i = 0; i <= 2; i++)
    {
        if (trymove(i, 0))
            return true;
        if (trymove(-i, 0))
            return true;
    }
    return false;
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

boolean validShape(boolean[][] testshape, int cx, int cy)
{
    for (int i = 0; i < testshape.length; i++)
    {
        for (int j = 0; j < testshape[i].length; j++)
        {
            if (testshape[i][j])
            {
                if (transX(i, testshape, cx) < 0 || transY(j, testshape, cy) < 0)
                    return false;
                if (transX(i, testshape, cx) >= blocks.length || transY(j, testshape, cy) >= blocks[0].length)
                    return false;
                if (blocks[transX(i, testshape, cx)][transY(j, testshape, cy)] >= 0)
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
    fallcount = falldelay;
}

void place()
{
    for (int i = 0; i < curshape.length; i++)
    {
        for (int j = 0; j < curshape[i].length; j++)
        {
            if (curshape[i][j])
                blocks[transX(i, curshape, curX)][transY(j, curshape, curY)] = curColor;
        }
    }
    checkrow();
    getNextBlock();
}

void drop()
{
    trymove(0, 1);
}

void harddrop()
{
    trymove(0, ghostY() - curY);
    place();
}

void checkrow()
{
    int n = 0;
    int sl = getLevel();
    if (sl == 0)
        sl = 1;
    for (int i = 0; i < blocks[0].length; i++)
    {
        boolean filled = true;
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
            clearrow(i);
            n++;
        }
    }
    score += (int)((n * n + n) * sl) / 2;
}

void clearrow(int row)
{
    lines++;
    for (int i = row; i > 0; i--)
    {
        for (int j = 0; j < blocks.length; j++)
        {
            blocks[j][i] = blocks[j][i - 1];
        }
    }
    for (int j = 0; j < blocks.length; j++)
        blocks[j][0] = -1;
}

boolean canmove(int xd, int yd)
{
    for (int i = 0; i < curshape.length; i++)
    {
        for (int j = 0; j < curshape[i].length; j++)
        {
            if (curshape[i][j])
            {
                if (transX(i, curshape, curX) + xd < 0 || transY(j, curshape, curY) + yd < 0)
                    return false;
                if (transX(i, curshape, curX) + xd >= blocks.length || transY(j, curshape, curY) + yd >= blocks[0].length)
                    return false;
                if (blocks[transX(i, curshape, curX) + xd][transY(j, curshape, curY) + yd] >= 0)
                    return false;
            }
        }
    }

    return true;
}

boolean trymove(int xd, int yd)
{
    if (canmove(xd, yd))
    {
        curY += yd;
        curX += xd;
        return true;
    }
    else
    {
        return false;
    }
}

void swap()
{
    if (!shapesaved)
    {
        shapesaved = true;
        savedshape = curshape;
        savedColor = curColor;
        getNextBlock();
    }
    else
    {
        int tempcolor = curColor;
        boolean[][] temp = curshape;
        curshape = savedshape;
        curColor = savedColor;
        savedColor = tempcolor;
        savedshape = temp;
    }
    adjustnew();
}

boolean testAdjust(boolean[][] test)
{
    int[] xs = new int[] {0, -1, 1, -2, 2};
    int[] ys = new int[] {0, 1, -1};
    for (int i = 0; i < ys.length; i++)
    {
        int yo = ys[i];
        for (int j = 0; j < xs.length; j++)
        {
            int xo = xs[i];
            if (validShape(test, curX + xo, curY + yo))
            {
                curshape = test;
                curX += xo;
                curY += yo;
                return true;
            }
        }
    }
    return false;
}

boolean tryRotateRight()
{
    boolean[][] test = rotateRight(curshape);
    return testAdjust(test);
}

boolean tryRotateLeft()
{
    boolean[][] test = rotateLeft(curshape);
    return testAdjust(test);
}

void endGame()
{
    gameend = true;
    postScore(gamename, lines, score);
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
    if (started && !paused && !gameend)
    {
        boolean[][] test;
        if (keyCode == LEFT || key == '4' || key == 'j')
        {
            if (moveleft < 0)
            {
                makeMove(-1, 0);
                //println("setleft" + moveleft);
                moveleft = 12;
             }
        }
        if (keyCode == RIGHT || key == '6' || key == 'l')
        {
            if (moveright < 0)
            {
                makeMove(1, 0);
                moveright = 12;
            }
        }
        if (keyCode == DOWN || key == '2' || key == ',')
        {
            down = true;
        }
        if (key == ' ' || key == '5' || key == 'k')
        {
            harddrop();
        }
        if (key == '7' || key == 'u')
        {
            if (tryRotateRight())
                fallcount = falldelay;
        }
        if (key == '8' || key == 'i' || keyCode == UP)
        {
            if (tryRotateLeft())
                fallcount = falldelay;
        }
        if (key == 'a' || keyCode == SHIFT)
            swap();
    }
    if (key == 'p' || key == 'P')
        paused = !paused;
    if (key == 'n' && gameend)
        newgame();
}

void keyReleased()
{
    //println("released");
    if (!paused && !gameend)
    {
        if (keyCode == DOWN || key == '2' || key == ',')
            down = false;
        if (keyCode == LEFT || key == '4' || key == 'j')
            moveleft = -2;
        if (keyCode == RIGHT || key == '6' || key == 'l')
            moveright = -2;
    }
}

void mouseClicked()
{
    if (!started)
    {
        if (startscreen.mouseClicked() != null)
        {
            newgame();
        }
    }
    if (paused)
    {
        if (mouseX >= 198 && mouseX <= 368 && mouseY >= 390 && mouseY <= 410)
        {
            if (colorIndex == 0)
                colorIndex = 1;
            else
                colorIndex = 0;
            saveOptions();
        }
    }
}

