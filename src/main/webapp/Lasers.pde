/* @pjs font="Noticia.ttf"; */

/**
 * Use arrow keys to move<br>
 * Avoid the lasers as long as possible!
 */
 
String gamename = "lasers";

You you;

PImage logo, st, stgl;
LaserList lasers;
var startscreen;
boolean gameend, paused;
boolean started;
float dispX, dispY, dispW, dispH;
float yspeed;
int score;
int sizesel;
int ttr;
int updateval;
boolean ctrl, moveleft, moveright, moveup, movedown, space;
String[] scores;
PFont font32, font24, font12;

void setup()
{
    size(730, 520);

    font32 = createFont("Noticia", 32);
    font24 = createFont("Noticia", 24);
    font12 = createFont("Noticia", 12);
    
    startscreen = new Start(this, font12, gamename);
    startscreen.requestLogo("images/LaserLogo.png");
    startscreen.addButton("images/Start.png", "images/StartGlow.png", width / 2, 360, 0);
    
    dispX = 10;
    dispY = 10;
    dispW = 600;
    dispH = 500;
    
    yspeed = 2;
    updateval = 0;
    
    started = false;

    noStroke();
}

void newgame()
{
    score = 0;
    
    gameend = false;
    started = true;
    
    lasers = new LaserList();

    you = new You(dispW / 2, dispH / 2);
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
    translate(dispX, dispY);
    you.render();
    lasers.render();
    popMatrix();
    
    noStroke();
    
    fill(200);
    rect(dispX + dispW + 10, dispY, 100, dispH);
    fill(50);
    rect(0, 0, dispX, height);
    rect(dispX + dispW, 0, 10, height);
    rect(0, 0, width, dispY);
    rect(0, dispY + dispH, width, height - dispY - dispH);
    
    textFont(font32);
    textAlign(CENTER, CENTER);

    float middleX = dispX + dispW + 60;
    float middleY;
    fill(0);
    textFont(font12);
    textAlign(CENTER, CENTER);

    text("score", middleX, 310);
    textFont(font24);
    text(str(score), middleX, 335);

    if (gameend)
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
        if (ttr > 0)
        ttr--;
    }
    else if (paused)
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
        if (ttr > 0)
        ttr--;
    }
}

void addLaser()
{
    float theta = random(2 * PI) + PI / 4;
    float x = random(dispW);
    float y = random(dispH);
    Laser l;
    if (theta < 3 * PI / 4)
        y = 0;
    else if (theta < 5 * PI / 4)
        x = dispW;
    else if (theta < 7 * PI / 4)
        y = dispH;
    else
        x = 0;
    if (score > 5)
    {
        theta = atan2(you.yc - y, you.xc - x);
    }
    theta += random(2 * exp(-score / 10.0)) - exp(-score / 10.0);
    l = new Laser(x, y, theta, 600);
    lasers.addBack(l);
}

void moveStuff()
{
    if (moveleft)
        you.move(-yspeed, 0);
    if (moveright)
        you.move(yspeed, 0);
    if (moveup)
        you.move(0, -yspeed);
    if (movedown)
        you.move(0, yspeed);
        
    if (updateval == 0)
        score++;
        
    if (updateval == 0)
        addLaser();
    
    updateval = (updateval + 1) % 60;
    
    lasers.extend(7);
    if (lasers.checkall(you))
        endGame();
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
    }
    if (ttr > 0)
        ttr--;
}

void endGame()
{
    ttr = 50;
    gameend = true;

    postScore(gamename, score);
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
            newgame();
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
    if (gameend && ttr <= 0)
    {
        newgame();
    }
}

class Laser
{
    float xc, yc;
    float endx, endy;
    float theta;
    int life;
    boolean growing;
    public Laser(float xc, float yc, float theta, int life)
    {
        this.xc = xc;
        this.yc = yc;
        this.theta = theta;
        this.life = life;
        growing = true;
        endx = xc;
        endy = yc;
    }
    public void render()
    {
        strokeWeight(2);
        stroke(255, 0, 0);
        line(xc, yc, endx, endy);
    }
    void check()
    {
        if (endx < 0 || endx > dispW || endy < 0 || endy > dispH)
            growing = false;
    }
    boolean checkCollision(You you)
    {
        float x, y, xd, yd;
        for (float t = 0; t < 1; t += 0.001)
        {
            x = xc * (1 - t) + endx * t;
            y = yc * (1 - t) + endy * t;
            xd = x - you.xc;
            yd = y - you.yc;
            if (xd * xd + yd * yd <= 16)
                return true;
        }
        return false;
    }
    public void extend(float amount)
    {
        if (growing)
        {
            endx += cos(theta) * amount;
            endy += sin(theta) * amount;
            check();
        }
        life--;
    }
}

class You
{
    float xc, yc;
    public You(float xc, float yc)
    {
        this.xc = xc;
        this.yc = yc;
    }
    public void render()
    {
        ellipseMode(RADIUS);
        stroke(0, 0, 255);
        noFill();
        strokeWeight(1);
        ellipse(xc, yc, 4, 4);
    }
    public void move(float xd, float yd)
    {
        xc += xd;
        yc += yd;
        if (xc <= 4)
            xc = 4;
        if (yc <= 4)
            yc = 4;
        if (xc > dispW - 5)
            xc = dispW - 5;
        if (yc > dispH - 5)
            yc = dispH - 5;
    }
}
class LaserNode
{
    public Laser element;
    public LaserNode prev, next;
    public LaserNode(Laser element, LaserNode prev, LaserNode next)
    {
        this.element = element;
        this.prev = prev;
        this.next = next;
    }
}

class LaserList
{
    public LaserNode front, back;
    public int count;
    
    public LaserList()
    {
        front = null;
        back = null;
        count = 0;
    }
    
    public void addBack(Laser t)
    {
        LaserNode temp;
        if (count == 0)
        {
            temp = new LaserNode(t, null, null);
            front = temp;
            back = temp;
        }
        else
        {
            temp = new LaserNode(t, back, null);
            back.next = temp;
            back = temp;
        }
        count++;
    }
    
    public void addFront(Laser t)
    {
        LaserNode temp;
        if (count == 0)
        {
            temp = new LaserNode(t, null, null);
            front = temp;
            back = temp;
        }
        else
        {
            temp = new LaserNode(t, null, front);
            front.prev = temp;
            front = temp;
        }
        count++;
    }
    
    public void removeNode(LaserNode n)
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
        LaserNode tn = front;
        while (tn != null)
        {
            if (tn.element.life <= 0)
            {
                LaserNode temp = tn.next;
                removeNode(tn);
                tn = temp;
            }
            else
            {
                tn.element.render();
                tn = tn.next;
            }
        }
    }
    
    public void extend(float amount)
    {
        LaserNode ln = front;
        while (ln != null)
        {
            if (ln.element.life <= 0)
            {
                LaserNode temp = ln.next;
                removeNode(ln);
                ln = temp;
            }
            else
            {
                ln.element.extend(amount);
                ln = ln.next;
            }
        }
    }
    
    public boolean checkall(You you)
    {
        LaserNode ln = front;
        while (ln != null)
        {
            if (ln.element.life <= 0)
            {
                LaserNode temp = ln.next;
                removeNode(ln);
                ln = temp;
            }
            else
            {
                if (ln.element.checkCollision(you))
                    return true;
                ln = ln.next;
            }
        }
        return false;
    }
}

