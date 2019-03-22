/* @pjs font="Noticia.ttf"; */

/**
 * <p>Oh no!  You were minding your own business trying to catch a few worms for lunch,<br>
 * when suddenly a purple alien appeared; fearing what he might do to you, you started<br>
 * running, but as luck would have it you ran straight into a field of rocks!  See how<br>
 * long you can catch worms while avoiding both rocks and the alien.</p> 
 * Use arrow keys to move<br>
 * Press SPACE to run faster, but beware that you tire easily and have only so much energy!<br>
 * Press P to pause<br>
 * Eggs make you smaller, kiwifruits make you invincible<br>
 * You lose if the purple alien catches you or you hit a rock.<br><br>
 * Kiwi drawings by Connor Powell and Mike Song<br>
 * Egg drawing by Liz Ensminger<br>
 * Kiwifruit drawing by Matt Bergey
 */
 
String gamename = "kiwirun";

You you;

PImage imYou, imYouSmall, imYouSuper;
PImage imAlien;
PImage imWorm;
PImage impshrink, imfruit;
PImage[] imRock;
var startscreen;
Alien alien;
ItemList items;
boolean gameend, paused;
boolean started, loaded;
float dispX, dispY, dispW, dispH;
int framenum;
int score, time;
int ttr;
int level;
float energy;
float rockrate, wormrate;
float hspeed, yspeed;
float camX;
boolean ctrl, moveleft, moveright, moveup, movedown, space;
boolean newlevel;
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

    startscreen.requestLogo("images/KiwirunLogo.png");
    startscreen.addButton("images/Start.png", "images/StartGlow.png", width / 2, 360, 0);
    imYou = startscreen.requestImage("images/kiwi.png");
    imYouSmall = startscreen.requestImage("images/kiwismall.png");
    imYouSuper = startscreen.requestImage("images/superkiwi.png");
    imAlien = startscreen.requestImage("images/Alien.png");
    imWorm = startscreen.requestImage("images/wormsmall.png");
    impshrink = startscreen.requestImage("images/kiwiegg.png");
    imfruit = startscreen.requestImage("images/kiwifruit.png");
    imRock = new PImage[6];
    for (int i = 1; i <= imRock.length; i++)
        imRock[i - 1] = startscreen.requestImage("images/rock" + i + ".png");
        
    dispX = 10;
    dispY = 10;
    dispW = 600;
    dispH = 500;

    yspeed = 2;
    
    started = false;

    noStroke();
}

void newgame()
{
    score = 0;
    
    gameend = false;
    started = true;

    items = new ItemList();
    
    hspeed = 2;
    alien = new Alien(0, 0, hspeed + 0.1);
    items.addBack(alien);

    you = new You(imYou, 70, 0);
    camX = -30;
    
    rockrate = 0.03;
    wormrate = 0.05;
    
    energy = 0;
    
    level = 0;
    nextLevel();
}

void nextLevel()
{
    level++;
    hspeed += 1;
    alien.velocity += 1.01;
    rockrate += 0.01;
}

void checkLevel()
{
    if (time % 20 == 0)
        nextLevel();
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
    translate(-camX, -you.ycenter() + dispH / 2);
    items.render();
    you.render();
    popMatrix();
    
    fill(50);
    rect(0, 0, dispX, height);
    rect(dispX + dispW, 0, width - dispX - dispW, height);
    rect(0, 0, width, dispY);
    rect(0, dispY + dispH, width, height - dispY - dispH);

    fill(200);
    rect(dispX + dispW + 10, dispY, 100, dispH);    
    
    fill(0, 0, 255);
    rect(dispX + dispW + 10, dispY, energy, 10);
 

    float middleX = dispX + dispW + 60;
    float middleY;
    fill(0);
    textFont(font12);

    textAlign(LEFT, TOP);    
    text("energy", dispX + dispW + 10, dispY + 10);
    textAlign(CENTER, CENTER);

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
        you.move(-hspeed, 0);
    if (moveright)
        you.move(yspeed, 0);
    if (moveup)
        you.move(0, -yspeed);
    if (movedown)
        you.move(0, yspeed);
        
    curspeed = hspeed;
    if (space)
    {
        if (energy < 1)
        {
            space = false;
        }
        else
        {
            energy -= 1;
            curspeed = hspeed + 2;
        }
    }
    else
    {
        energy = min(100, energy + 0.03);
    }
    camX += curspeed;
    you.move(curspeed, 0);
    you.update();
    items.moveItems();
    items.checkItems(you);
    float xv = camX + dispW + 100;
    float yv = you.ycenter() + random(-500, 500);
    framenum++;
    int count = 0;
    if (framenum % 60 == 0)
    {
        score++;
        time++;
        checkLevel();
    }
    if (random(1) < wormrate)
    {
        Worm w = new Worm(xv, yv);
        while (items.touches(w) && count < 100)
        {
            v = you.ycenter() + random(-500, 500);
            w = new Worm(xv, yv);
            count++;
        }
        if (count < 100)
            items.addBack(w);
    }
    if (random(1) < rockrate)
    {
        int rind = (int)random(imRock.length);
        Rock r = new Rock(xv, yv, rind);
        while (items.touches(r) && count < 100)
        {
            yv = you.ycenter() + random(-500, 500);
            r = new Rock(xv, yv, rind);
            count++;
        }
        if (count < 100)
            items.addBack(r);
    }
    if (random(1) < 0.001)
    {
        Item t = new Shrinker(xv, yv);
        while (items.touches(t) && count < 100)
        {
            yv = you.ycenter() + random(-500, 500);
            t = new Shrinker(xv, yv);
            count++;
        }
        if (count < 100)
            items.addBack(t);
    }
    if (random(1) < 0.001)
    {
        Item t = new Kiwifruit(xv, yv);
        while (items.touches(t) && count < 100)
        {
            yv = you.ycenter() + random(-500, 500);
            t = new Kiwifruit(xv, yv);
            count++;
        }
        if (count < 100)
            items.addBack(t);
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
class Worm extends Item
{
    public Worm(float xc, float yc)
    {
        super(imWorm, xc, yc);
    }
    
    public void collect()
    {
        score += 3;
        destroy();
    }
}

class Shrinker extends Item
{
    public Shrinker(float xc, float yc)
    {
        super(impshrink, xc, yc);
    }
    
    public void collect()
    {
        you.shrink();
        destroy();
    }
}

class Kiwifruit extends Item
{
    public Kiwifruit(float xc, float yc)
    {
        super(imfruit, xc, yc);
    }
    
    public void collect()
    {
        you.superkiwi();
        destroy();
    }
}

class Rock extends Item
{
    public Rock(float xc, float yc, int index)
    {
        super(imRock[index], xc, yc);
    }
    
    public void collect()
    {
        if (you.supertime >= 0)
        {
//            score += 1;
            destroy();
        }
        else
        {
            endGame();
        }
    }
}

class Alien extends Item
{
    float velocity;
    public Alien(float xc, float yc, float velocity)
    {
        super(imAlien, xc, yc);
        this.velocity = velocity;
    }
    
    public void collect()
    {
        endGame();
    }
    
    public void destroy()
    {
    }
    
    public void selfmove()
    {
        float theta = atan2(you.ycenter() - ycenter(), you.xcenter() - xcenter());
        super.move(velocity * cos(theta), velocity * sin(theta));
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
    
    public void changeImage(PImage newimage)
    {
        float xc = left + w / 2;
        float yc = top + h / 2;
        this.im = newimage;
        left = xc - im.width / 2;
        top = yc - im.height / 2;
        w = im.width;
        h = im.height;
    }
    
    public void move(float xd, float yd)
    {
        left += xd;
        top += yd;
    }
    
    public float xcenter()
    {
        return left + w / 2;
    }

    public float ycenter()
    {
        return top + h / 2;
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
    
    public void update()
    {
    }
    
    public boolean checkVisible()
    {
        if (left + w < camX - 100)
            return false;
        return true;
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
}

class You extends Thing
{
    int shrinktime, supertime;
    
    public You(PImage im, float xc, float yc)
    {
        super(im, xc, yc, im.width / 2, im.height / 2);
        shrinktime = -1;
        supertime = -1;
    }
        
    public void move(float xd, float yd)
    {
        super.move(xd, yd);
        
        if (left - camX < 0)
            left = camX;
        if (left + w - camX > dispW)
            left = dispW - w + camX;
    }
    
    public void shrink()
    {
        if (shrinktime < 0)
        {
            if (supertime >= 0)
                supertime = -1;
            changeImage(imYouSmall);
            shrinktime = 900;
        }
        else
        {
            shrinktime += 900;
        }
    }
    
    public void superkiwi()
    {
        if (supertime < 0)
        {
            if (shrinktime >= 0)
                shrinktime = -1;
            changeImage(imYouSuper);
            supertime = 900;
        }
        else
        {
            supertime += 900;
        }        
    }

    public void destroy()
    {
        playerHit();
    }
    
    public void update()
    {
        if (shrinktime >= 0)
        {
            shrinktime--;
            if (shrinktime == 0)
            {
                changeImage(imYou);
                shrinktime = -1;
            }
        }
        if (supertime >= 0)
        {
            supertime--;
            if (supertime == 0)
            {
                changeImage(imYou);
                supertime = -1;
            }
        }
    }
}

class Item extends Thing
{
    public Item(PImage im, float xc, float yc)
    {
        super(im, xc, yc, im.width / 2, im.height / 2);
    }
    
    public void collect()
    {
    }
    
    public void selfmove()
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
    
    public void checkAll()
    {
        ThingNode tn = front;
        while (tn != null)
        {
            if (!tn.element.checkVisible())
                tn.element.destroy();
            if (!tn.element.exists)
            {
                ThingNode temp = tn.next;
                removeNode(tn);
                tn = temp;
            }
            else
            {
                tn = tn.next;
            }
        }
    }
    
    public boolean touches(Thing t)
    {
        ThingNode tn = front;
        while (tn != null)
        {
            if (!tn.element.checkVisible())
                tn.element.destroy();
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
}

class ItemList extends ThingList
{
    public void checkItems(Thing you)
    {
        ThingNode tn = front;
        while (tn != null)
        {
            if (!tn.element.checkVisible())
                tn.element.destroy();
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

    public void moveItems()
    {
        ThingNode tn = front;
        while (tn != null)
        {
            if (!tn.element.checkVisible())
                tn.element.destroy();
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
                tn = tn.next;
            }
        }
    }
}

