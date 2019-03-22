/* @pjs font="Noticia.ttf"; */

/**
 * Press SPACE or UP to jump<br>
 * Press LEFT or RIGHT to rotate red circles (the starting circle and circles in strategy mode)<br>
 * You gain points based on the length of your jump<br>
 * There is a 50% pentalty to the numbebr of points for the jump if you land on the circle you just left<br>
 * In Arcade mode, you have 3 lives and you lose a life every time you land on a circle you have previously visited<br>
 * In Timed mode, you have 60 seconds to score as many points as possible<br>
 * In Strategy mode, you get 10 jumps to score as many points as possible
 */
 
String gamename = "circlejump";

You you;

var startscreen;
ThingList circles;
ItemList items;
boolean gameend, paused;
boolean started;
float dispX, dispY, dispW, dispH;
float camX, camY;
float maxX;
int score;
int ttr;
int maxtries;
int mode;
int np, maxnp;
int lives, time, fnumber, fupdate, jumps;
float yspeed;
float yangv, circrate, margin;
boolean ctrl, moveleft, moveright, moveup, movedown, space;
String name;
String[] scores;
PFont font32, font24, font12;

void setup()
{
    size(730, 550);

    font32 = createFont("Noticia", 32);
    font24 = createFont("Noticia", 24);
    font12 = createFont("Noticia", 12);
    
    startscreen = new Start(this, font12, gamename);
    startscreen.requestLogo("images/CircleJumpLogo.png");
    startscreen.addButton("images/StartArcade.png", "images/StartArcadeGlow.png", width / 2, 270, 0);
    startscreen.addButton("images/StartTimed.png", "images/StartTimedGlow.png", width / 2, 373, 1);
    startscreen.addButton("images/StartStrategy.png", "images/StartStrategyGlow.png", width / 2, 476, 2);

    dispX = 10;
    dispY = 10;
    dispW = 600;
    dispH = height - 20;
    
    yspeed = 5;
    yangv = 4;
    maxtries = 10;
    circrate = 0.005;
    margin = 7;
    
    started = false;

    noStroke();
}

void newgame(int modenum)
{
    mode = modenum;
    score = 0;
    np = 0;
    fnumber = 0;
    timestart = false;
    
    if (mode == 0)
    {
        gamename = "circlejump_arcade";
        lives = 3;
        circrate = 0.005;
        maxnp = 300;
        np = 100;
    }
    
    if (mode == 1)
    {
        gamename = "circlejump_timed";
        time = 60;
        circrate = 0.01;
        maxnp = 200;
        fupdate = 60;
        np = 0;
    }
    
    if (mode == 2)
    {
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

    StartCircle s = new StartCircle(PI / 4, yangv);
    circles.addThing(s);
    
    you = new You(s.xc + s.rad, 0, 10);
    you.curcircle = s;
    maxX = s.xc + s.rad;
    
    for (int i = 200; i <= dispW + you.xc; i++)
        placeCircle(i, circrate);

    camX = dispW / 2;
    camY = 0;
}

void placeCircle(float xval, float prob)
{
    float cm = margin + you.rad;
    if (random(1) > prob)
    {
        np++;
        if (np < maxnp)
            return;
    }
    np = 0;
    float rad = random(50, 130);
    float yval = random(-dispH / 2 + rad + cm, dispH / 2 - rad - cm);
    float av = random(1.5, 3);
    if (random(1) < 0.5)
        av *= -1;
    int tries = 0;
    Circle c = new getCircle(xval, yval, rad, av / rad);
    Thing t = circles.touching(c, cm, true);
    while (t != null && tries < maxtries)
    {
        rad = random(50, 130);
        yval = random(-dispH / 2 + rad + cm, dispH / 2 - rad - cm);
        c = getCircle(xval, yval, rad, av / rad);
        t = circles.touching(c, cm, true);
        tries++;
    }
    if (tries < maxtries)
    {
        circles.addThing(c);
    }
}

Circle getCircle(float xc, float yc, float rad, float anglev)
{
    if (mode == 0 || mode == 1)
        return new Circle(xc, yc, rad, anglev);
    else
        return new PuzzleCircle(xc, yc, rad, anglev);
}

void drawStartScreen()
{
    startscreen.draw();
}

void drawPlayingArea()
{
    background(50);
    fill(200);
    rect(dispX, dispY, dispW, dispH);
    
    pushMatrix();
    translate(dispX + dispW / 2 - camX, dispY + dispH / 2 - camY);
    scale(1, -1);
    stroke(0);
    noFill();
    you.render();
    circles.render();
    popMatrix();
    
    rectMode(CORNERS);
    fill(50);
    rect(0, 0, dispX, height);
    rect(dispX + dispW, 0, width, height);
    rect(0, 0, width, dispY);
    rect(0, dispY + dispH, width, height); 
    rectMode(CORNER);
    fill(200);
    rect(dispX + dispW + 10, dispY, 100, dispH);
    
 
    textFont(font32);
    textAlign(CENTER, CENTER);

    float middleX = dispX + dispW + 60;
    float middleY;
    fill(0);
    textFont(font12);
    textAlign(CENTER, CENTER);
    String countdown;
    if (mode == 0)
    {
        if (lives == 1)
            countdown = "1 life";
        else
            countdown = lives + " lives";
    }
    if (mode == 1)
    {
        if (time == 1)
            countdown = "1 second";
        else
            countdown = time + " seconds";
    }
    if (mode == 2)
    {
        if (jumps == 1)
            countdown = "1 jump";
        else
            countdown = jumps + " jumps";
    }
    text(countdown, middleX, 80);
    text("current jump", middleX, 120);
    text(you.curscore(), middleX, 140);
    text("score", middleX, 25);
    textFont(font24);
    text(str(score), middleX, 50);
}

void drawGameOver()
{
    fill(200);
    middleX = dispX + dispW / 2;
    middleY = dispY + dispH / 2;
    stroke(0);
    rect(middleX - 120, middleY - 40, 240, 80);
    noStroke();
    fill(255, 0, 0);
    textAlign(CENTER, CENTER);
    text("GAME OVER", middleX, middleY - 13);
    textFont(font12);
    fill(0);
    text("Click or press enter to play again", middleX, middleY + 17);
}

void drawPauseScreen()
{
    fill(200);
    middleX = dispX + dispW / 2;
    middleY = dispY + dispH / 2;
    stroke(0);
    rect(middleX - 120, middleY - 40, 240, 80);
    noStroke();
    fill(255, 0, 0);
    textAlign(CENTER, CENTER);
    text("PAUSED", middleX, middleY - 13);
    textFont(font12);
    fill(0);
    text("Press P to resume", middleX, middleY + 17);
}

void moveStuff()
{
    circles.move();
    you.selfmove();
    if (timestart)
        fnumber++;
    if (mode == 1 && fnumber > 0 && fnumber % fupdate == 0)
    {
        if (time > 0)
            time--;
        if (time <= 0 && you.curcircle != null)
            endGame();
    }
}

void draw()
{
    if (!started)
    {
        drawStartScreen();
    }
    else
    {
        if (!gameend && !paused)
            moveStuff();
        drawPlayingArea();
        if (gameend)
            drawGameOver();
        else if (paused)
            drawPauseScreen();
        
    }
    if (ttr > 0)
        ttr--;
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
            newgame(mode);
        }
    }

    if (started && !gameend)
    {
        if (key == ' ')
        {
            space = true;
        }
        if (key == 'p' || key == 'P')
        {
            paused = !paused;
        }
        switch(keyCode)
        {
            case LEFT:
                moveleft = true;
                break;
            case RIGHT:
                moveright = true;
                break;
            case UP:
                moveup = true;
                break;
            case DOWN:
                movedown = true;
                break;
        }
    }
    else if (gameend)
    {
        if (keyCode == RETURN || keyCode == ENTER)
        {
            started = false;
            gameend = false;
        }
    }
}

void keyReleased()
{
    if (keyCode == CONTROL)
        ctrl = false;
    if (keyCode == LEFT)
        moveleft = false;
    if (keyCode == RIGHT)
        moveright = false;
    if (keyCode == UP)
        moveup = false;
    if (keyCode == DOWN)
        movedown = false;
    if (keyCode == ' ')
        space = false;
}

void mouseClicked()
{
    if (!started)
    {
        int modesel = startscreen.mouseClicked();
        if (modesel != null)
        {
            newgame(modesel);
            name = startscreen.pname;
        }
    }
    if (gameend && ttr <= 0)
    {
        started = false;
        gameend = false;
    }
}

void mouseMoved()
{
    if (!started)
    {
        startscreen.mouseMoved();
    }
}
class Circle extends Thing
{
    float theta;
    float anglev;
    boolean visited;
    color dotcolor;
    public Circle(float xc, float yc, float rad, float anglev)
    {
        super(xc, yc, rad);
        this.theta = 0;
        this.anglev = anglev;
        dotcolor = color(0);
        visited = false;
    }
    
    public void render()
    {
        stroke(0);
        if (visited && mode == 0)
            fill(255, 255, 100);
        else
            fill(255);
        super.render();
        noStroke();
        fill(dotcolor);
        for (float dt = 0; dt <= 2 * PI; dt += PI / 2)
            ellipse(xc + cos(theta + dt) * (rad - 10), yc + sin(theta + dt) * (rad - 10), 6, 6);
    }
    
    public void rotate(float dt)
    {
        theta += dt;
        if (you.curcircle == this)
            you.rotate(dt);
    }
    
    public void selfmove()
    {
        rotate(anglev);
    }
    
    public void land()
    {
        if (visited && mode == 0)
        {
            lives--;
            if (lives <= 0)
                endGame();
        }
        if (mode == 1 && time <= 0)
            endGame();
        if (mode == 2)
        {
            jumps--;
            if (jumps <= 0)
                endGame();
        }
        visited = true;
    }
}

class PuzzleCircle extends Circle
{
    public PuzzleCircle(float xc, float yc, float rad, float anglev)
    {
        super(xc, yc, rad, anglev);
        dotcolor = color(255, 0, 0);
    }

    public void selfmove()
    {
        if (you.curcircle == this)
        {
            if (moveleft)
                rotate(yangv / rad);
            if (moveright)
                rotate(-yangv / rad);
        }
    }
}

class StartCircle extends PuzzleCircle
{
    float maxAng;
    public StartCircle(float halfang, float anglev)
    {
        super(-dispH / (2 * tan(halfang)), 0, dispH / (2 * sin(halfang)), anglev);
        this.maxAng = halfang;
        visited = true;
    }
    
    void rotate(float dt)
    {
        if (abs(theta + dt) < maxAng)
            super.rotate(dt);
    }
    
    public void land()
    {
        super.land();
        theta = you.theta;
    }
}
class Mineral extends Item
{
    int value;
    public Mineral(PImage im, float xc, float yc, int value)
    {
        super(im, xc, yc);
    }
    
    public void collect()
    {
        money += value;
        destroy();
    }
}

abstract class Thing
{
    float xc, yc, rad;
    public boolean exists;
    int index;
    public Thing(float xc, float yc, float rad)
    {
        exists = true;
        this.xc = xc;
        this.yc = yc;
        this.rad = rad;
    }

    public void move(float xd, float yd)
    {
        xc += xd;
        yc += yd;
    }

    public void selfmove()
    {
    }

    public void render()
    {
        ellipseMode(RADIUS);
        ellipse(xc, yc, rad, rad);
    }
    
    public boolean visible()
    {
        if (abs(xc - camX) > dispW + 150)
            return false;
        if (abs(yc - camY) > dispH + 100)
            return false;
        return true;
    }

    public void destroy()
    {
        exists = false;
    }

    public boolean touching(Thing other, float mindist)
    {
        float xd = other.xc - xc;
        float yd = other.yc - yc;
        float dist2 = xd * xd + yd * yd;
        float rad2 = other.rad + rad + mindist;
        rad2 *= rad2;
        return (dist2 <= rad2);
    }

}

class Item extends Thing
{
    PImage im;
    public Item(PImage im, float xc, float yc)
    {
        super(xc, yc, im.width / 2);
        this.im = im;
    }
    
    public void render()
    {
        imageMode(CENTER);
        image(im, xc, yc);
    }
    
    public void collect()
    {
    }
}
class ThingNode
{
    public Thing element;
    public ThingNode prev, next;
    public ThingNode(Thing element, ThingNode prev, ThingNode next)
    {
        this.element = element;
        this.prev = prev;
        this.next = next;
    }
}

class ThingList
{
    public ThingNode front, back;
    public int count;
    
    public ThingList()
    {
        front = null;
        back = null;
        count = 0;
    }
    
    public void addThing(Thing t)
    {
        ThingNode temp;
        if (count == 0)
        {
            temp = new ThingNode(t, null, null);
            front = temp;
            back = temp;
        }
        else
        {
            temp = new ThingNode(t, back, null);
            back.next = temp;
            back = temp;
        }
        count++;
    }
    
    public void removeNode(ThingNode n)
    {
        if (n == front)
            front = n.next;
        if (n == back)
            back = n.prev;
        if (n.next != null)
            n.next.prev = n.prev;
        if (n.prev != null)
            n.prev.next = n.next;
        count--;
    }
    
    public void render()
    {
        ThingNode tn = front;
        while (tn != null)
        {
            if (!tn.element.exists)
            {
                ThingNode temp = tn.next;
                removeNode(tn);
                tn = temp;
            }
            else
            {
                if (tn.element.visible())
                    tn.element.render();
                tn = tn.next;
            }
        }
    }
    
    public void move()
    {
        ThingNode tn = front;
        while (tn != null)
        {
            if (!tn.element.exists)
            {
                ThingNode temp = tn.next;
                removeNode(tn);
                tn = temp;
            }
            else
            {
                if (tn.element.visible())
                    tn.element.selfmove();
                tn = tn.next;
            }
        }
    }
    
    public Thing touching(Thing t, float mindist, boolean checkinvis)
    {
        ThingNode tn = front;
        while (tn != null)
        {
            if (!tn.element.exists)
            {
                ThingNode temp = tn.next;
                removeNode(tn);
                tn = temp;
            }
            else
            {
                if ((checkinvis || tn.element.visible()) && tn.element.touching(t, mindist))
                    return tn.element;
                tn = tn.next;
            }
        }
        return null;
    }
}

class ItemList extends ThingList
{
    public void checkItems()
    {
        ThingNode tn = front;
        while (tn != null)
        {
            if (!tn.element.exists)
            {
                ThingNode temp = tn.next;
                removeNode(tn);
                tn = temp;
            }
            else
            {
                Item it = (Item)tn.element;
                if (it.touching(you))
                {
                    it.collect();
                }
                tn = tn.next;
            }
        }
    }
}
class You extends Thing
{
    float theta;
    Circle curcircle, prevcircle;
    float xv, yv;
    float xacc;
    float initv;
    float curjump;
    public You(float xc, float yc, float rad)
    {
        super(xc, yc, rad);
        curcircle = null;
        prevcircle = null;
        theta = 0;
        initv = yspeed;
        xacc = -0.04;
        xv = 0;
        yv = 0;
    }
    
    public void move(float xd, float yd)
    {
        super.move(xd, yd);
        if (xc < 0)
            xc = 0;
        if (xc - camX > 0)
            camX = xc;
        if (xc - camX < -200)
            camX = max(dispW / 2, xc + 200);
        if (xc > maxX)
        {
            for (int i = (int)maxX; i < (int)xc; i++)
                placeCircle(i + dispW, circrate);
            maxX = xc;
        }
        if (abs(yc) > dispH / 2)
            yv *= -1;
    }
    
    int curscore()
    {
        return (int)max(1, curjump * curjump / 10000);
    }
    
    public void moveforward(int slices)
    {
        for (int i = 0; i < slices; i += 1)
        {
            curjump += 1;
            move(xv / slices, yv / slices);
            Thing t = circles.touching(this, -rad, false);
            if (t != null && (t != prevcircle || curjump > 10))
            {
                curcircle = (Circle)t;
                theta = atan2(yc - t.yc, xc - t.xc);
                if (curcircle == prevcircle)
                    score += (int)(curscore() / 2);
                else
                    score += curscore();
                xc = t.rad * cos(theta) + t.xc;
                yc = t.rad * sin(theta) + t.yc;
                curcircle.land();
                space = false;
                moveup = false;
                return;
            }
        }
    }
    
    public void rotate(float dt)
    {
        if (curcircle != null)
        {
            float xd = cos(theta + dt) - cos(theta);
            float yd = sin(theta + dt) - sin(theta);
            xd *= curcircle.rad;
            yd *= curcircle.rad;
            move(xd, yd);
        }
        theta += dt;
    }
    
    public void render()
    {
        stroke(0);
        fill(255, 0, 0);
        super.render();
        line(xc, yc, xc + cos(theta) * rad, yc + sin(theta) * rad);
    }
    
    public void selfmove()
    {
        if (curcircle != null)
        {
            if (space || moveup)
            {
                timestart = true;
                prevcircle = curcircle;
                curcircle = null;
                xv = initv * cos(theta);
                yv = initv * sin(theta);
                curjump = 0;
                moveforward(yspeed);
            }
        }
        else
        {
            xv += xacc;
            theta = atan2(yv, xv);
            moveforward(yspeed);
        }
        items.checkItems();
    }
}

