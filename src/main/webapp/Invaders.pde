/* @pjs font="Noticia.ttf"; */

/**
 * Use arrow keys to move<br>
 * Press SPACE to shoot<br>
 * Press P to pause<br>
 * You lose if you run out of lives or the aliens reach the bottom of the light gray area
 */
 
String gamename = "invaders";

You you;

PImage imYou, imBullet;
PImage imNormalAlien, imBigAlien, imBossAlien;
PImage imBulletPowerup, imLifePowerup;
var startscreen;
AlienList aliens, specials;
BulletList bullets;
ItemList items;
boolean gameend, paused;
boolean started;
float dispX, dispY, dispW, dispH;
int score;
int ttr;
int level;
int aliencount;
int lives;
int numshots;
int aupdate, acountdown, bupdate, bcountdown;
float aspeed, yspeed, bspeed, itspeed;
float amargin, topmargin, arate, bottomspace;
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
    startscreen.requestLogo("images/InvadersLogo.png");
    startscreen.addButton("images/Start.png", "images/StartGlow.png", width / 2, 360, 0);

    imYou = startscreen.requestImage("images/You.png");
    imNormalAlien = startscreen.requestImage("images/Alien.png");
    imBigAlien = startscreen.requestImage("images/BigAlien.png");
    imBossAlien = startscreen.requestImage("images/BossAlien.png");
    imBullet = startscreen.requestImage("images/Bullet.png");
    imBulletPowerup = startscreen.requestImage("images/BulletPowerup.png");
    imLifePowerup = startscreen.requestImage("images/LifePowerup.png");
    
    
    dispX = 10;
    dispY = 10;
    dispW = 600;
    dispH = 500;
    
    amargin = 5;
    topmargin = 40;
    bottomspace = 100;
    bupdate = 20;
    bcountdown = 0;
    yspeed = 2;
    bspeed = 3;
    itspeed = 2;
    
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

    you = new You(imYou, dispW / 2, dispH - 30);
    
    level = 0;
    nextLevel();
}

void nextLevel()
{
    level++;
    
    aliens = new AlienList();

    aliencount = 0;
    
    aspeed = 10 + (int)(level / 5);
    arate = 0.01 + 0.003 * (int)(level / 2);
    aupdate = 15 - (int)min(1, level / 7);
    acountdown = 0;
 
    if (level % 5 == 0)
    {
        Alien[] b = new Alien[(int)(level / 20) + 1];
        for (int i = 0; i < b.length; i++)
        {
            b[i] = new BossAlien(imBossAlien, dispW / 2, dispH / 3,
                                 random(2 * PI), aspeed / 5, 1, 5, 
                                 40 + 2 * level, 10 + level);
            specials.addBack(b[i]);
            aliencount += b[i].number;
        }
        bosslevel = true;
    }
    else
    {
        int awid, ahei;
        
        if (level >= 9)
        {
            awid = 13;
            ahei = 7;
        }
        else
        {
            awid = 4 + level;
            ahei = 3 + (int)(level / 2);
        }
        
        float xmin = (dispW - (awid - 1) * 30) / 2;
        
        for (int j = 0; j < ahei; j++)
        {
            boolean left = false;
            if (level % 2 == 0)
                left = j % 2 == 0;
    
            for (int i = 0; i < awid; i++)
            {
                int health = (int)max(1, (int)(level / 5));
                if (level > 5 && random(5) < level % 5)
                    health += 1;
                Alien a = new NormalAlien(xmin + 30 * i, topmargin + 15 + 30 * j, left, health);
                aliens.addBack(a);
                aliencount += a.number;
            }
        }
        bosslevel = false;
    }
    
    newlevel = true;
    
    drawPlayingArea();
}

void alienKilled(Alien a)
{
    int oldcount = aliencount;
    aliencount -= a.number;
    score += a.pointvalue;
    Item[] its = a.drop();
    for (int i = 0; i < its.length; i++)
        items.addBack(its[i]);

    if (!bosslevel)
    {
        if (oldcount > 5 && aliencount <= 5)
        {
            arate *= 2;
            aupdate = (int)max(1, aupdate * 2 / 3);
        }
        if (oldcount > 1 && aliencount == 1)
        {
            arate *= 2;
            aupdate = (int)max(1, aupdate * 3 / 5);
        }
    }
}

void drawStartScreen()
{
    startscreen.draw();
}

void drawPlayingArea()
{
    background(50);
    fill(150);
    rect(dispX, dispY, dispW, dispH);
    fill(200);
    rect(dispX + amargin, dispY + topmargin,
             dispW - 2 * amargin, dispH - topmargin - bottomspace);
    
    pushMatrix();
    translate(dispX, dispY);
    items.render();
    bullets.render();
    specials.render();
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
    if (moveleft)
        you.move(-yspeed, 0);
    if (moveright)
        you.move(yspeed, 0);
    if (moveup)
        you.move(0, -yspeed);
    if (movedown)
        you.move(0, yspeed);
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
    acountdown = (acountdown + 1) % aupdate;
    if (acountdown == 0)
    {
        if (!aliens.canMoveAll(aspeed))
        {
            aliens.flip();
            aliens.moveAliens(0, 30);
        }
        else
            aliens.moveAliens(aspeed, 0);
        aliens.fireall(arate, bullets);
    }
    specials.moveSpecials(arate, bullets);
    bullets.moveBullets(you, aliens, specials);
    items.moveItems(you);
    Alien a;
    if (specials.count == 0 && random(2000) < 1)
    {
        if (random(1) < 0.5)
            a = new SpecialAlien1(imBigAlien, 0, 20, 1.8, 0, 1);
        else
            a = new SpecialAlien1(imBigAlien, dispW, 20, -1.8, 0, 1);
        specials.addBack(a);
    }
    else if (specials.count == 0 && random(3000) < 1)
    {
        if (random(1) < 0.5)
            a = new SpecialAlien2(imBigAlien, 0, 20, 1.8, 0, 1);
        else
            a = new SpecialAlien2(imBigAlien, dispW, 20, -1.8, 0, 1);
        specials.addBack(a);
    }
    if (aliens.bottommost() >= getBottomBorder() || lives <= 0)
        endGame();
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
public float getLeftBorder()
{
    return amargin;
}

public float getRightBorder()
{
    return dispW - amargin;
}

public float getTopBorder()
{
    return topmargin;
}

public float getBottomBorder()
{
    return dispH - bottomspace;
}
class NormalAlien extends Alien
{
    int health;
    public NormalAlien(float xc, float yc, boolean moveleft, int health)
    {
        super(imNormalAlien, xc, yc, moveleft);
        rateModifier = 1;
        pointvalue = health;
        number = 1;
        this.health = health;
    }
    
    public void hit(Bullet b)
    {
        if (b.halien)
        {
            health--;
            if (health <= 0)
                destroy();
            b.destroy();
        }
    }
}

class SpecialAlien extends Alien
{
    float xv, yv;

    public SpecialAlien(PImage im, float xc, float yc,
                        float xv, float yv, int update, int points)
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
    
    public void hit(Bullet b)
    {
        if (b.halien)
        {
            destroy();
            b.destroy();
        }
    }
}

class SpecialAlien1 extends SpecialAlien
{
    public SpecialAlien1(PImage im, float xc, float yc, float xv, float yv, int update)
    {
        super(im, xc, yc, xv, yv, update, 10);
    }
}

class SpecialAlien2 extends SpecialAlien
{
    public SpecialAlien2(PImage im, float xc, float yc, float xv, float yv, int update)
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
    
//    public Item[] drop()
//    {
//        Item it = new BulletPowerup((int)(left + w / 2), (int)(top + h / 2), 0, itspeed);
//        return new Item[] {it};
//    }
    
    public void hit(Bullet b)
    {
        if (b.halien)
        {
            health--;
            if (health <= 0)
            {
                numshots++;
                destroy();
            }
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

class You extends Thing
{
    public You(PImage im, float xc, float yc)
    {
        super(im, xc, yc, im.width / 2, im.height / 2);
    }
    
    public void move(float xd, float yd)
    {
        super.move(xd, yd);
        if (left < 0)
            left = 0;
        if (left + w > dispW)
            left = dispW - w;
        if (top < getBottomBorder())
            top = getBottomBorder();
        if (top + h > dispH)
            top = dispH - h;
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

class Alien extends Thing
{
    boolean moveleft;
    float rateModifier = 1;
    int pointvalue, number;
    public int update;
    public Alien(PImage im, float xc, float yc, boolean moveleft)
    {
        super(im, xc, yc, im.width / 2, im.height / 2);
        this.moveleft = moveleft;
    }
    
    public void destroy()
    {
        alienKilled(this);
        exists = false;
    }
    
    public boolean canMove(float xd, float yd)
    {
        if (left + xd < getLeftBorder() || left + xd + w > getRightBorder())
            return false;
        return true;
    }

    public Bullet[] fire()
    {
        Bullet b = new Bullet(left + w / 2, top + h, 0, bspeed, true, false);
        return new Bullet[] {b};
    }
    
    public Item[] drop()
    {
        return new Item[0];
    }
    
    public Bullet[] alienFire(float prob)
    {
        if (random(1) < prob * rateModifier)
            return fire();
        else
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
    public void moveAliens(float aspeed, float yd)
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
                if (a.moveleft)
                    a.move(-aspeed, yd);
                else
                    a.move(aspeed, yd);
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

