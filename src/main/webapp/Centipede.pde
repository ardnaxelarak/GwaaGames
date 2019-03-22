/* @pjs font="Noticia.ttf"; */

/**
 * Use arrow keys to move<br>
 * Press SPACE to shoot<br>
 * Press P to pause<br>
 * You lose if you run out of lives
 */
 
String gamename = "centipede";

You you;

PImage imYou, imBullet;
PImage imNormalAlien, imBigAlien, imBossAlien;
PImage imBulletPowerup, imLifePowerup;
PImage[] imMushroom;
Thing[][] grid;
var startscreen;
AlienList aliens;
BulletList bullets;
MushroomList mushrooms;
ItemList items;
boolean gameend, paused;
boolean started;
boolean inparea;
float dispX, dispY, dispW, dispH;
int gridW, gridH, pgridH;
int restartdelay;
float tilesize;
int score;
int ttr;
int level;
int aliencount;
int lives;
int numshots;
int acountdown, bupdate, bcountdown;
float aupdate;
float aspeed, yspeed, bspeed, itspeed;
int arate;
boolean aleft;
boolean ctrl, moveleft, moveright, moveup, movedown, space;
boolean newlevel, bosslevel;
String name;
String[] scores;
PFont font32, font24, font12;

void setup()
{
    size(730, 520);

    font32 = createFont("Noticia", 32);
    font24 = createFont("Noticia", 24);
    font12 = createFont("Noticia", 12);
    
    startscreen = new Start(this, font12, gamename);
    startscreen.requestLogo("images/CentipedeLogo.png");
    startscreen.addButton("images/Start.png", "images/StartGlow.png", width / 2, 360, 0);

    imYou = startscreen.requestImage("images/CentipedeYou.png");
    imNormalAlien = startscreen.requestImage("images/AlienSmall.png");
//    imBigAlien = startscreen.requestImage("images/BigAlien.png");
//    imBossAlien = startscreen.requestImage("images/BossAlien.png");
    imBullet = startscreen.requestImage("images/CentipedeBullet.png");
//    imBulletPowerup = startscreen.requestImage("images/BulletPowerup.png");
//    imLifePowerup = startscreen.requestImage("images/LifePowerup.png");
    
    imMushroom = new PImage[4];
    for (int i = 0; i < 4; i++)
    {
        imMushroom[i] = startscreen.requestImage("images/Mushroom" + (i + 1) + ".png");
    }
    
    dispX = 10;
    dispY = 10;
    tilesize = 16;
    gridW = 30;
    gridH = 24;
    pgridH = 6;
    dispW = tilesize * gridW;
    dispH = tilesize * (gridH + pgridH);

    bupdate = 10;
    bcountdown = 0;
    yspeed = 4;
    bspeed = 6;
    itspeed = 2;
    restartdelay = 0;
    arate = 300;
    
    started = false;

    noStroke();
}

void newgame()
{
    score = 0;
    lives = 5;
    numshots = 1;
    
    gameend = false;
    started = true;
    
    bullets = new BulletList();
    items = new ItemList();
    specials = new AlienList();
    mushrooms = new MushroomList();
    
    grid = new Thing[gridW][gridH + pgridH];
    for (int i = 0; i < gridW; i++)
    {
        for (int j = 0; j < gridH; j++)
        {
            if (random(1) < 0.05)
            {
                Mushroom m = new Mushroom(i, j);
                grid[i][j] = m;
                mushrooms.addBack(m);
            }
        }
    }

    you = new You(imYou, dispW / 2, dispH - 30);
    
    level = 0;
    nextLevel();
}

void startlevel()
{
    aliens = new AlienList();
    aliencount = 0;
    restartdelay = 0;
    inparea = false;
    
    aspeed = 10 + (int)(level / 5);
    aupdate = 5 - level * 0.1;
    acountdown = 0;
    
    mushrooms.healMushrooms();
    
    int alen = 13 - level;
    Alien next = null;
    int gx = (int)random(gridW);
    int gy = 0;
    boolean left = true;
    if (random(1) < 0.5)
        left = false;
    Alien a = new NormalAlien(gx * tilesize, gy * tilesize, left, aupdate, null);
    aliens.addBack(a);
    aliencount++;
    next = a;
    for (int i = 1; i < alen; i++)
    {
        a = new NormalAlien(-300, -300, false, aupdate, next);
        next = a;
        aliens.addBack(a);
        aliencount++;
    }
    for (int i = 1; i < level; i++)
    {
        gx = (int)random(gridW);
        gy = min(gridH - 1, i);
        boolean left = true;
        if (random(1) < 0.5)
            left = false;
        a = new NormalAlien(gx * tilesize, gy * tilesize, left, max(1, aupdate - 1), null);
        aliens.addBack(a);
        aliencount++;
    }
}

void addHead()
{
    int gx = 0;
    int gy = gridH - 1;
    Alien a = new NormalAlien(gx * tilesize, gy * tilesize, false, aupdate, null);
    aliens.addBack(a);
    aliencount++;
}

void nextLevel()
{
    level++;
    
    startlevel();
    newlevel = true;
}

void alienKilled(Alien a)
{
    int oldcount = aliencount;
    aliencount -= a.number;
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
    items.render();
    bullets.render();
    mushrooms.render();
    aliens.render();
    you.render();
    popMatrix();
    
    fill(200);
    rect(dispX + dispW + 10, dispY, 100, dispH);
    fill(50);
    rect(0, 0, dispX, height);
    rect(dispX + dispW, 0, 10, height);
    
 
    textFont(font32);
    textAlign(CENTER, CENTER);

    float middleX = dispX + dispW + 60;
    float middleY;
    fill(0);
    textFont(font12);
    textAlign(CENTER, CENTER);
    if (lives == 1)
        text("1 life", middleX, 210);
    else
        text(lives + " lives", middleX, 210);
    if (aliencount == 1)
        text("1 alien", middleX, 230);
    else
        text(aliencount + " aliens", middleX, 230);

    text("level", middleX, 260);
    text("score", middleX, 310);
    textFont(font24);
    text(str(level), middleX, 285);
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

void moveStuff()
{
    you.selfmove();
    aliens.moveAliens();
    bullets.moveBullets(you, aliens, mushrooms);
    items.moveItems(you);
    if (aliens.touching(you))
        playerHit();
}

void checkLevel()
{
    if (aliencount == 0)
    {
        nextLevel();
    }
}

void playerHit()
{
    lives -= 1;
    if (lives <= 0)
        endGame();
    else
        restartdelay = 60;
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
        {
            if (restartdelay > 0)
            {
                restartdelay--;
                if (restartdelay <= 0)
                    startlevel();
            }
            else
                moveStuff();
        }
        checkLevel();
        drawPlayingArea();
    }
    if (ttr > 0)
        ttr--;
}

void endGame()
{
    ttr = 50;
    gameend = true;

    postScore(gamename, name, score, level);
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
    else if (started && !gameend)
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
    if (!started)
    {
        if (startscreen.mouseClicked() != null)
        {
            newgame();
            name = startscreen.pname;
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
public float getBottomBorder()
{
    return dispH - pgridH * tilesize;
}
class Alien extends Thing
{
    boolean moveleft, movedown;
    float rateModifier = 1;
    int pointvalue, number;
    float update;
    float movepoints;
    Alien next, prev;
    public Alien(PImage im, float left, float top, boolean moveleft, float update, Alien next)
    {
        super(im, left + im.width / 2, top + im.height / 2, im.width / 2, im.height / 2);
        this.update = update;
        this.moveleft = moveleft;
        this.movedown = true;
        this.prev = null;
        this.next = next;
        if (next != null)
            next.prev = this;
    }
    
    public void destroy()
    {
        super.destroy();
        alienKilled(this);
        if (next == null)
            score += 100;
        else
            score += 10;
        if (next != null)
            next.prev = null;
        if (prev != null)
            prev.next = null;
        if (grid[gridX()][gridY()] == null)
        {
            Mushroom m = new Mushroom(gridX(), gridY());
            mushrooms.addBack(m);
        }
    }
    
    public void follow(Alien a)
    {
        if (prev != null)
            prev.follow(this);
        moveto(a.left, a.top);
        this.moveleft = a.moveleft;
    }
    
    public void selfmove()
    {
        movepoints += 1;
        while (movepoints >= update)
        {
            movepoints -= update;
            
            int ogx = gridX();
            int ogy = gridY();
            int ngx, ngy;
            if (next != null)
            {
                return;
            }
            else
            {
                if (prev != null)
                    prev.follow(this);
                ngy = ogy;
                if (moveleft)
                    ngx = ogx - 1;
                else
                    ngx = ogx + 1;
                if (ngx < 0 || ngx >= grid.length || grid[ngx][ngy] != null)
                {
                    ngx = ogx;
                    if (movedown)
                    {
                        ngy = ogy + 1;
                        if (ngy >= grid[0].length)
                        {
                            ngy = ogy - 1;
                            movedown = false;
                        }
                    }
                    else
                    {
                        ngy = ogy - 1;
                        if (ngy < gridH)
                        {
                            ngy = ogy + 1;
                            movedown = true;
                        }
                    }
                    
                    moveleft = !moveleft;
                }
                moveto(ngx * tilesize, ngy * tilesize);
            }
            if (gridY() >= gridH)
                inparea = true;
        }
    }
}

class NormalAlien extends Alien
{
    public NormalAlien(float left, float top, boolean moveleft, int update, Alien next)
    {
        super(imNormalAlien, left, top, moveleft, update, next);
        rateModifier = 1;
        pointvalue = 10;
        number = 1;
    }
    
    public void hit(Bullet b)
    {
        if (b.halien)
        {
            destroy();
            b.destroy();
        }
    }
}

class SpecialAlien extends Alien
{
    float xv, yv;

    public SpecialAlien(PImage im, float xc, float yc, float xv, float yv, int update, int points)
    {
        super(im, xc, yc, xv < 0);
        this.xv = xv;
        this.yv = yv;
        this.update = update;
        rateModifier = 0;
        pointvalue = points;
        number = 0;
    }
    
    public boolean canMove(float xd, float yd)
    {
        return true;
    }
    
    public void selfmove()
    {
        move(xv, yv);
    }
    
    public void move(float xd, float yd)
    {
        super.move(xd, yd);
        if (left + w < 0 || left > dispW)
            exists = false;
    }
}

class SpecialAlien1 extends SpecialAlien
{
    public SpecialAlien1(PImage im, float xc, float yc,
                                                                 float xv, float yv, int update)
    {
        super(im, xc, yc, xv, yv, update, 10);
    }
}

class SpecialAlien2 extends SpecialAlien
{
    public SpecialAlien2(PImage im, float xc, float yc,
                                                                 float xv, float yv, int update)
    {
        super(im, xc, yc, xv, yv, update, 5);
    }
    
    public Item[] drop()
    {
        Item it = new LifePowerup((int)(left + w / 2), (int)(top + h / 2), 0, itspeed);
        return new Item[] {it};
    }
}

class BossAlien extends Alien
{
    float theta, velocity;
    int health;

    public BossAlien(PImage im, float xc, float yc,
                                                            float theta, float velocity,
                                                            int update, float rateModifier,
                                                            int pointvalue, int health)
    {
        super(im, xc, yc, (theta + PI) % (2 * PI) < PI);
        this.theta = theta;
        this.velocity = velocity;
        this.update = update;
        this.rateModifier = rateModifier;
        this.pointvalue = pointvalue;
        this.health = health;
        number = 1;
    }
    
    public boolean canMove(float xd, float yd)
    {
        return true;
    }
    
    public void selfmove()
    {
        float xv = cos(theta) * velocity;
        float yv = sin(theta) * velocity;
        boolean good = false;
        while (!good)
        {
            xv = cos(theta) * velocity;
            yv = sin(theta) * velocity;
            if (left + xv < getLeftBorder() || left + w + xv > getRightBorder())
            {
                theta = (3 * PI - theta) % (2 * PI);
            }
            else if (top + yv < getTopBorder() || top + h + yv > getBottomBorder())
            {
                theta = (2 * PI - theta) % (2 * PI);
            }
            else
            {
                good = true;
            }
        }
        move(xv, yv);
    }
    
    public void move(float xd, float yd)
    {
        super.move(xd, yd);
    }
    
    public Bullet[] fire()
    {
        float theta = random(PI / 2) + PI / 4;
        float xoff = cos(theta) * w / 4;
        Bullet b = new Bullet(left + w / 2 + xoff, top + h, cos(theta) * bspeed,
                                                 sin(theta) * bspeed, true, false);
        return new Bullet[] {b};
    }
    
    public Item[] drop()
    {
        Item it = new BulletPowerup((int)(left + w / 2), (int)(top + h / 2), 0, itspeed);
        return new Item[] {it};
    }
    
    public void hit(Bullet b)
    {
        if (b.halien)
        {
            health--;
            if (health <= 0)
                destroy();
            else
                theta = random(2 * PI);
            b.destroy();
        }
    }
}
class BulletPowerup extends Item
{
    float xv, yv;
    public BulletPowerup(float xc, float yc, float xv, float yv)
    {
        super(imBulletPowerup, xc, yc, xv, yv);
    }
    
    public void collect()
    {
        numshots++;
        destroy();
    }
}

class LifePowerup extends Item
{
    float xv, yv;
    public LifePowerup(float xc, float yc, float xv, float yv)
    {
        super(imLifePowerup, xc, yc, xv, yv);
    }
    
    public void collect()
    {
        lives += 1;
        destroy();
    }
}
abstract class Thing
{
    public float left, top, w, h;
    public boolean exists;
    public PImage im;
    public Thing(PImage im, float xc, float yc, float halfw, float halfh)
    {
        exists = true;
        this.im = im;
        this.left = xc - halfw;
        this.top = yc - halfh;
        this.w = 2 * halfw;
        this.h = 2 * halfh;
    }
    public void move(float xd, float yd)
    {
        left += xd;
        top += yd;
    }
    public void moveto(float xc, float yc)
    {
        left = xc;
        top = yc;
    }
    public void selfmove()
    {
    }
    public void render()
    {
        imageMode(CORNER);
        image(im, left, top);
    }
    public void destroy()
    {
        exists = false;
    }
    public void hit(Bullet b)
    {
    }
    
    public int gridX()
    {
        return (int)(left / tilesize);
    }
    public int gridY()
    {
        return (int)(top / tilesize);
    }
    
    public boolean touching(Thing other)
    {
        if (other.left + other.w < left ||
                other.left > left + w ||
                other.top + other.h < top ||
                other.top > top + h)
            return false;
            
        float xmax = min(other.left + other.w, left + w);
        float ymax = min(other.top + other.h, top + h);
        float a1, a2;
        for (float y = max(other.top, top); y < ymax; y++)
        {
            for (float x = max(other.left, left); x < xmax; x++)
            {
                a1 = alpha(other.im.get((int)(x - other.left), (int)(y - other.top))); 
                a2 = alpha(im.get((int)(x - left), (int)(y - top)));
                if (a1 + a2 > 400)
                    return true; 
            }
        }
        return false;
    }
    public Bullet[] fire()
    {
        return new Bullet[0];
    }
}

class Bullet extends Thing
{
    float xv, yv;
    boolean hyou, halien;
    public Bullet(float xc, float yc, float xv, float yv, boolean hyou, boolean halien)
    {
        super(imBullet, xc, yc, imBullet.width / 2, imBullet.height / 2);
        
        this.xv = xv;
        this.yv = yv;
        this.hyou = hyou;
        this.halien = halien;
    }
    
    public void selfmove()
    {
        super.move(xv, yv);
        if (left + w < 0 || top + h < 0 ||
                left > dispW || top > dispH)
            destroy();
    }
}

class Item extends Thing
{
    float xv, yv;
    public Item(PImage im, float xc, float yc, float xv, float yv)
    {
        super(im, xc, yc, im.width / 2, im.height / 2);
        
        this.xv = xv;
        this.yv = yv;
    }
    
    public void collect()
    {
    }
    
    public void selfmove()
    {
        super.move(xv, yv);
        if (left + w < 0 || top + h < 0 ||
                left > dispW || top > dispH)
            destroy();
    }
}

class Mushroom extends Thing
{
    int health;
    public Mushroom(float gxc, float gyc)
    {
        super(imMushroom[3], gxc * tilesize + tilesize / 2, gyc * tilesize + tilesize / 2, imMushroom[3].width / 2, imMushroom[3].height / 2);
        health = 4;
        grid[gxc][gyc] = this;
    }

    public void hit(Bullet b)
    {
        setHealth(health - 1);
        b.destroy();
    }
    
    public void setHealth(int health)
    {
        this.health = health;
        if (this.health <= 0)
        {
            destroy();
            score += 1;
        }
        else
        {
            this.im = imMushroom[health - 1];
        }
    }
    
    public void destroy()
    {
        super.destroy();
        if (grid[gridX()][gridY()] == this)
            grid[gridX()][gridY()] = null;
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
    
    public void addBack(Thing t)
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
    
    public void addFront(Thing t)
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
            temp = new ThingNode(t, null, front);
            front.prev = temp;
            front = temp;
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
                tn.element.render();
                tn = tn.next;
            }
        }
    }
    
    public void move(float xd, float yd)
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
                tn.element.move(xd, yd);
                tn = tn.next;
            }
        }
    }
    
    public boolean touching(Thing t)
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
                if (tn.element.touching(t))
                    return true;
                tn = tn.next;
            }
        }
        return false;
    }
    
    public float leftmost()
    {
        ThingNode tn = front;
        if (tn == null)
            return 0;
        Thing t = tn.element;
        float lm = t.left;
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
                t = tn.element;
                if (t.left < lm)
                    lm = t.left;
                tn = tn.next;
            }
        }
        return lm;
    }
    
    public float rightmost()
    {
        ThingNode tn = front;
        if (tn == null)
            return 0;
        Thing t = tn.element;
        float rm = t.left + t.w;
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
                t = tn.element;
                if (t.left + t.w > rm)
                    rm = t.left + t.w;
                tn = tn.next;
            }
        }
        return rm;
    }
    
    public float bottommost()
    {
        ThingNode tn = front;
        if (tn == null)
            return 0;
        Thing t = tn.element;
        float bm = t.top + t.h;
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
                t = tn.element;
                if (t.top + t.h > bm)
                    bm = t.top + t.h;
                tn = tn.next;
            }
        }
        return bm;
    }
    
    public boolean checkCollision(Bullet b)
    {
        ThingNode tn = front;
        while (tn != null && b.exists)
        {
            if (!tn.element.exists)
            {
                ThingNode temp = tn.next;
                removeNode(tn);
                tn = temp;
            }
            else
            {
                if (b.touching(tn.element))
                {
                    tn.element.hit(b);
                }
                tn = tn.next;
            }
        }
    }
}

class BulletList extends ThingList
{
    public void moveBullets(Thing you, ThingList a1, ThingList a2)
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
                Bullet b = (Bullet)tn.element;
                b.selfmove();
                if (b.hyou && b.touching(you))
                {
                    you.hit(b);
                }
                else if (b.halien)
                {
                    a1.checkCollision(b);
                    a2.checkCollision(b);
                }
                tn = tn.next;
            }
        }
    }
}

class MushroomList extends ThingList
{
    public void healMushrooms()
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
                Mushroom m = (Mushroom)tn.element;
                m.setHealth(4);
                tn = tn.next;
            }
        }
    }
}

class ItemList extends ThingList
{
    public void moveItems(Thing you)
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
                it.selfmove();
                if (it.touching(you))
                {
                    it.collect();
                }
                tn = tn.next;
            }
        }
    }
    
    public void checkItems(Thing you)
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

class AlienList extends ThingList
{
    int movenumber = 0;
    public void moveAliens()
    {
        movenumber += 1;
        if (inparea && movenumber % arate == 0)
            addHead();
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
                Alien a = (Alien)tn.element;
                a.selfmove();
                tn = tn.next;
            }
        }
    }
    
    public void moveSpecials(float fireprob, BulletList bullets)
    {
        movenumber += 1;
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
                Alien a = (Alien)tn.element;
                if (movenumber % a.update == 0)
                {
                    a.selfmove();
                    Bullet[] b = a.alienFire(fireprob);
                    for (int i = 0; i < b.length; i++)
                        bullets.addBack(b[i]);
                }
                tn = tn.next;
            }
        }
    }
    
    public boolean canMoveAll(float aspeed)
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
                Alien a = (Alien)tn.element;
                boolean cmove;
                if (a.moveleft)
                    cmove = a.canMove(-aspeed, 0);
                else
                    cmove = a.canMove(aspeed, 0);
                if (!cmove)
                    return false;
                tn = tn.next;
            }
        }
        return true;
    }
    
    public void flip()
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
                Alien a = (Alien)tn.element;
                a.moveleft = !a.moveleft;
                tn = tn.next;
            }
        }
    }
    
    public void fireall(float prob, BulletList bullets)
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
                Alien a = (Alien)tn.element;
                Bullet[] b = a.alienFire(prob);
                for (int i = 0; i < b.length; i++)
                    bullets.addBack(b[i]);
                tn = tn.next;
            }
        }
    }
}
class You extends Thing
{
    public You(PImage im, float xc, float yc)
    {
        super(im, xc, yc, im.width / 2, im.height / 2);
    }
    
    public void move(float xd, float yd)
    {
        super.move(xd, yd);
        if (mushrooms.touching(this))
            super.move(-xd, -yd);
        if (left < 0)
            left = 0;
        if (left + w > dispW)
            left = dispW - w;
        if (top < getBottomBorder())
            top = getBottomBorder();
        if (top + h > dispH)
            top = dispH - h;
    }
    
    public void selfmove()
    {
        for (int i = 0; i < yspeed; i++)
        {
            if (moveleft)
                you.move(-1, 0);
            if (moveright)
                you.move(1, 0);
            if (moveup)
                you.move(0, -1);
            if (movedown)
                you.move(0, 1);
        }
        items.checkItems(you);
        if (bcountdown > 0)
            bcountdown -= 1;
        if (space && bcountdown <= 0)
        {
            Bullet[] b = you.fire();
            for (int i = 0; i < b.length; i++)
                bullets.addBack(b[i]);
            bcountdown = bupdate;
        }
    }

    public void hit(Bullet b)
    {
        if (b.hyou)
        {
            playerHit();
            b.destroy();
        }
    }
    
    public Bullet[] fire()
    {
        Bullet[] b = new Bullet[numshots];
        if (numshots == 1)
        {
            b[0] = new Bullet(left + w / 2, top, 0, -bspeed, false, true);
        }
        else if (numshots == 2)
        {
            b[0] = new Bullet(left + w / 2 - 5, top, 0, -bspeed, false, true);
            b[1] = new Bullet(left + w / 2 + 5, top, 0, -bspeed, false, true);
        }
        else
        {
            float theta;
            float xoff;
            for (int i = 0; i < numshots; i++)
            {
                theta = PI * 5 / 12 + (PI * i / (6 * (numshots - 1)));
                xoff = cos(theta) * w / 2;
                b[i] = new Bullet(left + w / 2 + xoff, top, cos(theta) * bspeed,
                                                 -sin(theta) * bspeed, false, true);

            }
        }
        return b;
    }
}

