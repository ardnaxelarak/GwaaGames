/* @pjs font="Noticia.ttf"; */

/**
 * Click somewhere to place your ball initially<br>
 * Drag in a direction to launch the ball<br>
 * Hitting a ball will turn it black; hitting a ball with a different black ball will increase its value<br>
 * Black balls disappear and add their value to your score when they stop moving<br>
 * Object is to get to the goal score on each level once all the balls are gone<br>
 * One specific color each game (chosen at random) will create another ball every time it is turned black<br>
 * Game ends when the goal for a level is not met
 */
 
String gamename = "circlebouncer";

You you;

var startscreen;
ThingList items;
CircleList circles;
boolean gameend, paused;
boolean started;
float dispX, dispY, dispW, dispH, radius;
int score, level, goal;
int ttr;
int maxspeed;
float maxval;
boolean ctrl, moveleft, moveright, moveup, movedown, space;
String name;
String[] scores;
color[] colors;
int[] actionindex;
PFont font32, font24, font12;

void setup()
{
    size(730, 550);

    font32 = createFont("Noticia", 32);
    font24 = createFont("Noticia", 24);
    font12 = createFont("Noticia", 12);
    
    startscreen = new Start(this, font12, gamename);
    startscreen.requestLogo("images/CircleBouncerLogo.png");
    startscreen.addButton("images/Start.png", "images/StartGlow.png", width / 2, 270, 0);

    colors = new color[6];
    colors[0] = color(0, 200, 200);
    colors[1] = color(230, 230, 10);
    colors[2] = color(255, 100, 150);
    colors[3] = color(60, 240, 60);
    colors[4] = color(250, 180, 60);
    colors[5] = color(250, 90, 250);
    
    actionindex = new int[6];
    for (int i = 0; i < actionindex.length; i++)
        actionindex[i] = i;
    
    dispX = 10;
    dispY = 10;
    dispW = 600;
    dispH = height - 20;
    
    maxspeed = 10;
    
    textAlign(CENTER, CENTER);
    ellipseMode(RADIUS);
    
    frameRate(60);
    
    started = false;
    radius = 11;

    noStroke();
}

void newgame()
{
    score = 0;
    
    gameend = false;
    started = true;
    you = new You(radius);
    
    items = new ThingList();
    circles = new CircleList();
    circles.addThing(you);
//    circles.addThing(new CollectorCircle(300, 300, radius));
    
    shuffleactions();
    level = 0;
    goal = 0;
    nextlevel();
}

void nextlevel()
{
    level++;
    goal += 9 * level + 2 * level * level;
    maxval = 5 + 5 * level;
    placecircles();
}

void shuffleactions()
{
    int j, k;
    for (int i = 0; i < actionindex.length; i++)
    {
        j = (int)random(actionindex.length - i) + i;
        k = actionindex[j];
        actionindex[j] = actionindex[i];
        actionindex[i] = k;
    }
}

void placecircles()
{
//    circles.checkvalue();
    while (circles.count < maxval)
        placecircle();
//    circles.checkvalue();
}

void placecircle()
{
    float xc, yc;
    xc = random(dispW - radius * 2) + radius;
    yc = random(dispH - radius * 2) + radius;
    PointCircle c = new PointCircle(xc, yc, radius, (int)(random(6)));
    while (circles.touching(c, 0))
    {
        c.xc = random(dispW - 2 * radius) + radius;
        c.yc = random(dispH - 2 * radius) + radius;
    }
    circles.addThing(c);
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
    if (you.placed && !you.rolling())
    {
        stroke(255, 0, 0);
        float xd = mouseX - dispX - you.xc;
        float yd = mouseY - dispY - you.yc;
        float sp = you.getspeed(xd, yd);
        float rad = sp * 30;
        line(you.xc, you.yc, you.xc + rad * cos(you.theta), you.yc + rad * sin(you.theta));
    }
    stroke(0);
    noFill();
    //textAlign(CENTER, CENTER);
    textFont(font12);
    items.render();
    fill(0, 200, 0);
    circles.render();
    popMatrix();
    
    noStroke();
    
    //rectMode(CORNERS);
    fill(50);
    rect(0, 0, dispX, height);
    rect(dispX + dispW, 0, width, height);
    rect(0, 0, width, dispY);
    rect(0, dispY + dispH, width, height); 
    fill(200);
    rect(dispX + dispW + 10, dispY, 100, dispH);

    //textAlign(CENTER, CENTER);

    float middleX = dispX + dispW + 60;
    float middleY;
    fill(0);
    textFont(font12);
    //textAlign(CENTER, CENTER);
    text("score", middleX, 25);
    text("goal", middleX, 75);
    text("level", middleX, 125);
    textFont(font24);
    text(str(score), middleX, 50);
    text(str(goal), middleX, 100);
    text(str(level), middleX, 150);
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
    //textAlign(CENTER, CENTER);
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
    //textAlign(CENTER, CENTER);
    text("PAUSED", middleX, middleY - 13);
    textFont(font12);
    fill(0);
    text("Press P to resume", middleX, middleY + 17);
}

void moveStuff()
{
    items.move();
    circles.move();
    if (circles.count <= 1 && !you.rolling())
    {
        if (score >= goal)
            nextlevel();
        else
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
        {
            newgame();
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
            newgame();
            name = startscreen.pname;
        }
    }
    if (gameend && ttr <= 0)
    {
        newgame();
    }
}

void mousePressed()
{
    if (started && !you.placed)
    {
        if (mouseX > dispX && mouseX < dispX + dispW &&
            mouseY > dispY && mouseY < dispY + dispH)
            you.place(mouseX - dispX, mouseY - dispY);
    }
}

void mouseReleased()
{
    if (!started)
    {
        int modesel = startscreen.mouseClicked();
        if (modesel != null)
        {
            newgame();
            name = startscreen.pname;
        }
    }
    else if (started && you.placed && !you.rolling())
    {
        float cx = mouseX - dispX;
        float cy = mouseY - dispY;
        you.roll(cx - you.xc, cy - you.yc);
    }
}

void mouseMoved()
{
    if (!started)
    {
        startscreen.mouseMoved();
    }
    if (started && you.placed && !you.rolling())
    {
        float xd = mouseX - dispX - you.xc;
        float yd = mouseY - dispY - you.yc;
        you.theta = atan2(yd, xd);
    }
}

void mouseDragged()
{
    if (!started)
        startscreen.mouseMoved();
    if (started && you.placed && !you.rolling())
    {
        float xd = mouseX - dispX - you.xc;
        float yd = mouseY - dispY - you.yc;
        you.theta = atan2(yd, xd);
    }
}
class Circle extends Thing
{
    float acc;
    boolean placed;
    Vector velocity;
    float theta;
    int coltimeout;
    Circle lcol;
    public Circle(float xc, float yc, float rad)
    {
        super(xc, yc, rad);
        velocity = new Vector(0, 0);
        theta = 0;
        acc = -0.02;
        placed = true;
    }
    
    public void move(float xd, float yd)
    {
        super.move(xd, yd);
        if (xc < rad && velocity.xc < 0)
            velocity.xc *= -1;
        if (xc > dispW - rad && velocity.xc > 0)
            velocity.xc *= -1;
        if (yc < rad && velocity.yc < 0)
            velocity.yc *= -1;
        if (yc > dispH - rad && velocity.yc > 0)
            velocity.yc *= -1;
    }
    
    public void moveforward(int slices)
    {
        for (int i = 0; i < slices; i += 1)
        {
            move(velocity.xc / slices, velocity.yc / slices);
            circles.checkCollisions(this);
            //items.collect(this, 0);
        }
    }
    
    public void render(boolean drawline)
    {
        if (placed)
        {
            super.render();
            if (drawline)
            {
                if (rolling())
                    theta = velocity.getTheta();
                line(xc, yc, xc + cos(theta) * rad, yc + sin(theta) * rad);
            }
        }
    }
    
    public void selfmove()
    {
        if (coltimeout > 0)
            coltimeout--;
        if (placed && rolling())
        {
            moveforward((int)(speed / 5) + 1);
            float speed = velocity.getR();
            speed = max(speed + acc, 0);
            velocity.setR(speed);
            if (speed == 0)
            {
                float xd = mouseX - dispX - xc;
                float yd = mouseY - dispY - yc;
                theta = atan2(yd, xd);
            }
        }
    }
    
    public void collide(Circle other)
    {
        if (coltimeout > 0 && lcol == other)
            return;
        Vector defl = new Vector(other.xc - xc, other.yc - yc);
        Vector ndefl = new Vector(xc - other.xc, yc - other.yc);
        Vector v1 = Vector.project(velocity, defl).addto(Vector.reject(other.velocity, ndefl));
        Vector v2 = Vector.reject(velocity, defl).addto(Vector.project(other.velocity, ndefl));
        velocity = v2;
        other.velocity = v1;
        lcol = other;
        other.lcol = this;
        coltimeout = 2;
        other.coltimeout = 2;
        inCollision(other);
        other.inCollision(this);
    }
    
    public boolean rolling()
    {
        return velocity.getR() > 0;
    }
    
    public void inCollision(Circle c)
    {
    }
    
    public void collect()
    {
    }
}

class PointCircle extends Circle
{
    int value;
    int action;
    boolean collected = false;
    public PointCircle(float xc, float yc, float rad, int action)
    {
        super(xc, yc, rad);
        this.value = 1;
        this.action = action;
        collected = false;
    }
    
    public void selfmove()
    {
        if (!rolling() && collected)
        {
            destroy();
        }
        else
            super.selfmove();
    }
    
    public void render()
    {
        noStroke();
        if (!collected)
            fill(colors[action]);
        else
            fill(0);
        super.render(false);
        if (collected)
            fill(255);
        else
            fill(0);
        text(str(value), xc - rad, yc - rad - 2, 2 * rad, 2 * rad);
    }
    
    public void inCollision(Circle c)
    {
        if (collected && !c.collected)
        {
            c.value += value;
            c.collect();
        }
    }
    
    public void collect()
    {
        if (!collected)
        {
            collected = true;
            score += value;
            if (actionindex[action] == 0)
                placecircle();
        }
//            switch (actionindex[action])
//            {
//                case 1:
//                    you.speed = min(you.speed + 5, maxspeed * 2);
//                    placecircle();
//                    break;
//                case 2:
//                    you.speed = max(you.speed - 3, 0);
//                    placecircle();
//                    break;
//                case 3:
//    //                placecircle();
//                    placecircle();
//                    break;
//                case 4:
//                    break;
//                case 5:
//                    placecircle();
//                    //shuffleactions();
//                    break;
//                default:
//                    placecircle();
//                    break;
//            }
    //        destroy();
    //        placecircles();
    }
}

class CollectorCircle extends Circle
{
    public CollectorCircle(float xc, float yc, float rad)
    {
        super(xc, yc, rad);
    }
    
    public void render()
    {
        noStroke();
        fill(0);
        super.render(false);
    }
    
    public void inCollision(Circle c)
    {
        c.collect();
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
        ellipse(xc, yc, rad, rad);
    }
    
    public void destroy()
    {
        exists = false;
    }

    public boolean touching(Thing other, float mindist)
    {
        if (this == other)
            return false;
        float xd = other.xc - xc;
        float yd = other.yc - yc;
        float dist2 = xd * xd + yd * yd;
        float rad2 = other.rad + rad + mindist;
        rad2 *= rad2;
        return (dist2 <= rad2);
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
                tn.element.render();
                tn = tn.next;
            }
        }
    }
    
    public void checkvalue()
    {
        ThingNode tn = back;
        int curval = 1;
        while (tn != null)
        {
            if (!tn.element.exists)
            {
                ThingNode temp = tn.prev;
                removeNode(tn);
                tn = temp;
            }
            else
            {
                tn.element.value = curval;
                curval++;
                tn = tn.prev;
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
                tn.element.selfmove();
                tn = tn.next;
            }
        }
    }
    
    public void collect(Thing t, float mindist)
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
                if (tn.element.touching(t, mindist))
                    tn.element.collect();
                tn = tn.next;
            }
        }
    }
    
    public boolean touching(Thing t, float mindist)
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
                if (tn.element.touching(t, mindist))
                    return true;
                tn = tn.next;
            }
        }
        return false;
    }
    
    public void collect()
    {
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

class CircleList extends ThingList
{
    public void checkCollisions(Circle c)
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
                Circle o = (Circle)tn.element;
                if (o.touching(c, 1))
                {
                    c.collide(o);
                }
                tn = tn.next;
            }
        }
    }
}
class Vector
{
    public float xc, yc;
    public Vector(float xc, float yc)
    {
        this.xc = xc;
        this.yc = yc;
    }
    
    public float getR()
    {
        return sqrt(xc * xc + yc * yc);
    }
    
    public float getTheta()
    {
        return atan2(yc, xc);
    }
    
    public void setR(float r)
    {
        float theta = getTheta();
        yc = r * sin(theta);
        xc = r * cos(theta);
    }
    
    public void setTheta(float theta)
    {
        float r = getR();
        yc = r * sin(theta);
        xc = r * cos(theta);
    }
    
    public void setRTheta(float r, float theta)
    {
        yc = r * sin(theta);
        xc = r * cos(theta);        
    }
    
    public static Vector project(Vector v1, Vector v2)
    {
        return v2.scalarMultiply(v1.dotProduct(v2) / v2.dotProduct(v2));
    }
    
    public static Vector reject(Vector v1, Vector v2)
    {
        return v1.subtract(project(v1, v2));
    }
    
    public float dotProduct(Vector v)
    {
        return xc * v.xc + yc * v.yc;
    }
    
    public Vector scalarMultiply(float c)
    {
        return new Vector(c * xc, c * yc);
    }
    
    public Vector subtract(Vector v)
    {
        return new Vector(xc - v.xc, yc - v.yc);
    }
    
    public Vector addto(Vector v)
    {
        return new Vector(xc + v.xc, yc + v.yc);
    }
}
class You extends Circle
{
    public You(float rad)
    {
        super(0, 0, rad);
        placed = false;
    }
    
    public void render()
    {
        stroke(0);
        fill(255, 0, 0);
        super.render(true);
    }

    public void place(float xc, float yc)
    {
        this.xc = xc;
        this.yc = yc;
        placed = true;
    }
    
    public int getspeed(float xd, float yd)
    {
        return min(sqrt(xd * xd + yd * yd) / 30, maxspeed);
    }
    
    public void roll(float xd, float yd)
    {
        float speed = getspeed(xd, yd) * 2;
        theta = atan2(yd, xd);
        velocity.setRTheta(speed, theta);
    }
    
    public void inCollision(Circle c)
    {
        c.collect();
    }
}

