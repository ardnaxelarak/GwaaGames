/* @pjs font="Noticia.ttf"; */

/**
 * Use numpad or letters around S to move<br>
 * S or 5 waits<br>
 * T or 0 to teleport<br>
 * ENTER to wait until end of round (1 point bonus per robot left)<br>
 * Goal is to avoid being killed by robots
 */
 
String gamename = "robots";

final Junk JUNK = new Junk();
final Nothing NOTHING = new Nothing();
final You YOU = new You();

int bwidth, bheight;
Thing[][] board;
var startscreen;
boolean gameend;
boolean started;
int curX, curY;
int dispX, dispY;
float infoX;
int bsize;
int score;
int sizesel;
int ttr;
int level;
int robotcount;
int safe;
boolean ctrl;
boolean newlevel;
String name;
String[] scores;
PFont font32, font24, font12;

void setup()
{
    size(730, 562);

    bwidth = 12;
    bheight = 12;
    
    font32 = createFont("Noticia", 32);
    font24 = createFont("Noticia", 24);
    font12 = createFont("Noticia", 12);
    
    startscreen = new Start(this, font12, gamename);
    startscreen.requestLogo("images/RobotLogo.png");
    startscreen.addButton("images/Start.png", "images/StartGlow.png", width / 2, 360, 0);
    
    dispX = 150;
    dispY = 19;
    infoX = width - 140;
    bsize = 20;
    sizesel = -1;
    
    started = false;

    noStroke();
}

void newgame()
{
    score = 0;
    safe = 0;
    
    gameend = false;
    started = true;
    
    level = 0;
    nextLevel();
}

void nextLevel()
{
    level++;
    
    if (level >= 10)
    {
        bwidth = 25;
        bheight = 25;
        safe = 5;
    }
    else
    {
        bwidth = 15 + level;
        bheight = 15 + level;
        safe = (int)((level + 1) / 2);
    }
    board = new Thing[bheight][bwidth];
    for (int i = 0; i < bwidth; i++)
    {
        for (int j = 0; j < bheight; j++)
        {
            board[j][i] = NOTHING;
        }
    }
    
    curX = (int)random(bwidth);
    curY = (int)random(bheight);
    board[curY][curX] = YOU;

    int xp = curX, yp = curY;
    
    robotcount = 0;
    
    for (int i = 0; i < 5 + 8 * level; i++)
    {
        while (!board[yp][xp].isNothing)
        {
            xp = (int)random(bwidth);
            yp = (int)random(bheight);
        }
        
        Robot r = new Robot(xp, yp);
        board[yp][xp] = r;
        robotcount++;
    }
    
    dispX = infoX / 2 - (int)(bwidth * (bsize + 1) / 2);
    dispY = height / 2 - (int)(bheight * (bsize + 1) / 2);

    newlevel = true;
}

void drawStartScreen()
{
    startscreen.draw();
}

void drawPlayingArea()
{
    background(200);
    fill(51);
    rect(dispX - 1, dispY - 1, bwidth * (bsize + 1) + 1, bheight * (bsize + 1) + 1);
 
    for (int i = 0; i < bwidth; i++)
    {
        for (int j = 0; j < bheight; j++)
        {
            board[j][i].render((bsize + 1) * i + dispX, (bsize + 1) * j + dispY, bsize, bsize);
        }
    }
    
    textFont(font32);
    textAlign(CENTER, CENTER);
    
    float textX = (infoX + width) / 2;

    fill(0);
    textFont(font12);
    textAlign(CENTER, CENTER);
    if (robotcount == 1)
        text("1 robot", textX, 210);
    else
        text(robotcount + " robots", textX, 210);
    text("level " + level, textX, 230);
    if (safe > 1)
        text(safe + " safe teleports", textX, 250);
    else if (safe == 1)
        text("1 safe teleport", textX, 250);
    text("score:", textX, 310);
    textFont(font24);
    text(score + "", textX, 335);

    if (gameend)
    {
        fill(200);
        float middle = 348;
        rect(middle - 120, 240, 240, 80);
        fill(255, 0, 0);
        textAlign(CENTER, CENTER);
        text("GAME OVER", middle, 270);
        textFont(font12);
        fill(0);
        text("Click or press enter to play again", middle, 300);
        if (ttr > 0)
        ttr--;
    }
}

void draw()
{
    if (!started)
        drawStartScreen();
    else
        drawPlayingArea();
    if (ttr > 0)
        ttr--;
}

void robotKilled()
{
    robotcount--;
    score += 10;
    if (robotcount == 0)
    {
        nextLevel();
    }
}

void endGame()
{
    ttr = 50;
    gameend = true;

    writelog("scores/" + gamename + "-scores", name, score);
    try
    {
        scores = loadStrings(gamename + ".best");
    }
    catch (Exception e)
    {
        scores = new String[] {"0"};
    }
    if (scores == null)
        scores = new String[] {"0"};
    if (score > int(scores[0]))
        scores[0] = str(score);
    saveStrings(gamename + ".best", scores);
}

boolean isSafe(int xc, int yc)
{
    for (int i = -1; i <= 1; i++)
    {
        if (yc + i < 0 || yc + i >= bheight)
            continue;
        for (int j = -1; j <= 1; j++)
        {
             if (xc + j < 0 || xc + j >= bwidth)
                 continue;
             if (board[yc + i][xc + j].isRobot)
             {
                 return false;
             }
        }
    }
    return !board[yc][xc].willKill;
}

boolean trymove(int xd, int yd)
{
    int nx = curX + xd;
    int ny = curY + yd;
    if (nx < 0 || nx >= bwidth || ny < 0 || ny >= bheight)
    {
        return false;
    }
    if (!isSafe(nx, ny))
        return false;
    Thing you = board[curY][curX];
    board[curY][curX] = NOTHING;
    curX = nx;
    curY = ny;
    board[curY][curX] = you;
    return true;
}

void moveRobots()
{
    newlevel = false;
    Thing[][] newboard = new Thing[bheight][bwidth];
    for (int j = 0; j < bheight; j++)
    {
        for (int i = 0; i < bwidth; i++)
        {
            newboard[j][i] = board[j][i].moveCopy();
        }
    }
    for (int j = 0; j < bheight && !newlevel && !gameend; j++)
    {
        for (int i = 0; i < bwidth && !newlevel && !gameend; i++)
        {
            board[j][i].move(newboard);
        }
    }
    if (!newlevel)
        board = newboard;
}

void makeMove(int xd, int yd)
{
    if (trymove(xd, yd))
    {
        moveRobots();
    }
}

void teleport()
{
    board[curY][curX] = NOTHING;
    curX = (int)random(bwidth);
    curY = (int)random(bheight);
    
    while (!board[curY][curX].isNothing)
    {
        curX = (int)random(bwidth);
        curY = (int)random(bheight);
    }

    if (safe > 0)
    {
        int count = 0;
        while (!isSafe(curX, curY) && count < 100)
        {
            curX = (int)random(bwidth);
            curY = (int)random(bheight);
            while (!board[curY][curX].isNothing)
            {
                curX = (int)random(bwidth);
                curY = (int)random(bheight);
            }
            count++;
        }
        safe--;
    }
    else
    {
        while (!board[curY][curX].isNothing)
        {
            curX = (int)random(bwidth);
            curY = (int)random(bheight);
        }
    }
    board[curY][curX] = YOU;
    moveRobots();
}

void waitforend()
{
    newlevel = false;
    int rc = robotcount;
    while (!newlevel && !gameend)
    {
        moveRobots();
        drawPlayingArea();
    }
    if (!gameend)
        score += rc;
}

void keyPressed()
{
    if (keyCode == CONTROL)
        ctrl = true;
    if (!started)
    {
        startscreen.keyPressed();
    }
    else if (started && !gameend)
    {
        switch (key)
        {
            case 'q':
            case '7':
                makeMove(-1, -1);
                break;
            case 'w':
            case '8':
                makeMove(0, -1);
                break;
            case 'e':
            case '9':
                makeMove(1, -1);
                break;
            case 'a':
            case '4':
                makeMove(-1, 0);
                break;
            case 's':
            case '5':
            case ' ':
                makeMove(0, 0);
                break;
            case 'd':
            case '6':
                makeMove(1, 0);
                break;
            case 'z':
            case '1':
                makeMove(-1, 1);
                break;
            case 'x':
            case '2':
                makeMove(0, 1);
                break;
            case 'c':
            case '3':
                makeMove(1, 1);
                break;
            case 't':
            case '0':
                teleport();
                break;
        }
        if (keyCode == ENTER || keyCode == RETURN)
            waitforend();
    }
    else if (gameend)
    {
        if (keyCode == RETURN || keyCode == ENTER)
            newgame();
    }
}

void keyReleased()
{
    if (keyCode == CONTROL)
        ctrl = false;
}

void mouseClicked()
{
    if (!started)
    {
        if (startscreen.mouseClicked() != null)
        {
            name = startscreen.pname;
            newgame();
        }
    }
    if (gameend && ttr <= 0)
    {
        newgame();
    }
}

void mouseMoved()
{
    if (!started)
    {
        startscreen.mouseMoved();
    }
}
abstract class Thing
{
    /*
     * -3 = junk
     * -2 = robot
     * -1 = you
     *    0 = nothing
     */
    public int type;
    public boolean isNothing = false, isRobot = false, willKill = false;
    public void move(Thing[][] newboard)
    {
    }
    public abstract void render(float left, float top, float w, float h);
    public Thing destroy()
    {
        return this;
    }
    public Thing moveCopy()
    {
        return this;
    }
}

class Junk extends Thing
{
    public Junk()
    {
        type = -3;
        willKill = true;
    }
    public void render(float left, float top, float w, float h)
    {
        fill(180, 110, 40);
        rect(left, top, w, h);
    }
}

class Nothing extends Thing
{
    public Nothing()
    {
        type = 0;
        isNothing = true;
    }
    public void render(float left, float top, float w, float h)
    {
        fill(170);
        rect(left, top, w, h);
    }
}

class You extends Thing
{
    public You()
    {
        type = -1;
    }
    public void render(float left, float top, float w, float h)
    {
        fill(170);
        rect(left, top, w, h);
        strokeWeight(3);
        stroke(190, 30, 30);
        float margin = 5;
        ellipseMode(CORNER);
        ellipse(left + margin, top + margin, w - 2 * margin, h - 2 * margin);
        noStroke();
        strokeWeight(1);
    }
    public Thing destroy()
    {
        endGame();
        return JUNK;
    }
}

class Robot extends Thing
{
    boolean exists;
    int xc, yc;
    public Robot(int xc, int yc)
    {
        exists = true;
        this.type = -2;
        this.xc = xc;
        this.yc = yc;
        isRobot = true;
        willKill = true;
    }
    
    public void render(float left, float top, float w, float h)
    {
        fill(170);
        rect(left, top, w, h);
        stroke(170, 15, 200);
        strokeWeight(3);
        float margin = 5;
        line(left + margin, top + margin, left + w - margin, top + h - margin);
        line(left + margin, top + h - margin, left + w - margin, top + margin);
        strokeWeight(1);
        noStroke();
    }
    
    public void move(Thing[][] newboard)
    {
        int xd = 0, yd = 0;
        if (xc > curX)
            xd = -1;
        else if (xc < curX)
            xd = 1;
        if (yc > curY)
            yd = -1;
        else if (yc < curY)
            yd = 1;
            
        xc = xc + xd;
        yc = yc + yd;
        
        Thing t = newboard[yc][xc];
        newboard[yc][xc] = this;
        t.destroy();
        if (t.willKill)
        {
            destroy();
            newboard[yc][xc] = JUNK;
        }
    }
    
    public Thing destroy()
    {
        exists = false;
        robotKilled();
        return JUNK;
    }
    
    public Thing moveCopy()
    {
        return NOTHING;
    }
}

