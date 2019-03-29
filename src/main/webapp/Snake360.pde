/* @pjs font="Noticia.ttf"; */

/**
 * Hold left or right to rotate<br>
 * collect food pellets to gain points<br>
 * game ends when you hit yourself or a wall
 */
 
String gamename = "snake";

int score, best;
PFont font32, font12;
var startscreen;
CircleList tail;
Circle current, food;
boolean paused, moveleft, moveright, gameend, started;
float angle;
float left, right, top, bottom;
int curlength;
float radius;

public void setup()
{
    size(600, 600);
    
    font32 = createFont("Noticia", 32);
    font12 = createFont("Noticia", 12);
    
    startscreen = new Start(this, font12, gamename);
    startscreen.requestLogo("images/SnakeLogo.png");
    startscreen.addButton("images/Start.png", "images/StartGlow.png", width / 2, 360, 0);

    radius = 3;
    
    left = 100;
    right = 500;
    top = 100;
    bottom = 500;
    
    score = 0;
    best = 0;
    
    ellipseMode(RADIUS);
    rectMode(CORNERS);
    textAlign(CENTER, CENTER);

    noStroke();
    smooth();
    
    started = false;
}

void newgame()
{
    if (score > best)
        best = score;
    score = 0;
    current = new Circle((left + right) / 2, (top + bottom) / 2);
    tail = new CircleList();
    angle = 0;
    curlength = 10;
    paused = false;
    moveleft = false;
    moveright = false;
    gameend = false;
    started = true;
    placefood();
}

void drawStartScreen()
{
    startscreen.draw();
}

public void draw()
{
    background(200);
    
    if (!started)
    {
        drawStartScreen();
        return;
    }
    
    if (gameend)
    {
        fill(0);
        textFont(font32);
        text("Game over", 300, 540);
        textFont(font12);
        text("Click to restart", 300, 570);
    }

    if (paused)
    {
        fill(0);
        textFont(font32);
        text("Paused", 300, 540);
        textFont(font12);
        text("Press P to resume", 300, 570);
    }

    fill(150);
    stroke(0);
    strokeWeight(radius);
    rect(left, top, right, bottom);
    strokeWeight(1);
    
    fill(0);
    textAlign(LEFT);
    textFont(font12);
    text("Score: " + score, left, top - 5);
    textAlign(RIGHT);
    text("Best: " + best, right, top - 5);
    textAlign(CENTER, CENTER);
    
    fill(255);
    stroke(0);
    tail.render(current);
    
    fill(0, 255, 0);
    ellipse(food.xc, food.yc, radius, radius);
    
    if (!paused && !gameend)
    {
        if (moveleft)
            angle -= 0.04;
        if (moveright)
            angle += 0.04;
            
        if (frameCount % 5 == 0)
        {
            makemove();
        }
    }
    
    fill(255, 0, 0);
    ellipse(current.xc, current.yc, radius, radius);
}

void makemove()
{
    tail.addElement(current);
    while (tail.size() > curlength)
        tail.removeFirst();
    current = current.next(angle);
    
    if (tail.checkCollision(current))
        endGame();
    
    if (current.xc - radius <= left ||
            current.xc + radius >= right ||
            current.yc - radius <= top ||
            current.yc + radius >= bottom)
        endGame();
        
    if (current.touches(food))
    {
        curlength += 10;
        score += 1;
        placefood();
    }
}

void endGame()
{
    gameend = true;
    if (score > 0) {
        postScore(gamename, score);
    }
}

void placefood()
{
    food = new Circle(random(left + 15, right - 15),
                                        random(top + 15, bottom - 15));
}

void keyPressed()
{
    if (started && !paused)
    {
        if (keyCode == LEFT || key == '4' || key == 'j')
            moveleft = true;
        if (keyCode == RIGHT || key == '6' || key == 'l')
            moveright = true;
    }
    if (started && !gameend && (key == 'p' || key == 'P'))
        paused = !paused;
    if (gameend && (key == 'n' || keyCode == ENTER || keyCode == RETURN))
        newgame();
}

void keyReleased()
{
    if (!paused)
    {
        if (keyCode == LEFT || key == '4' || key == 'j')
            moveleft = false;
        if (keyCode == RIGHT || key == '6' || key == 'l')
            moveright = false;
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
    else if (gameend)
        newgame();
}class Circle
{
    public float xc, yc;
    public Circle(float xc, float yc)
    {
        this.xc = xc;
        this.yc = yc;
    }
    public boolean touches(Circle c)
    {
        float xd = xc - c.xc;
        float yd = yc - c.yc;
        return xd * xd + yd * yd <= 4 * radius * radius;
    }
    public Circle next(float angle)
    {
        float nx, ny;
        nx = (2 * radius + 1) * cos(angle) + xc;
        ny = (2 * radius + 1) * sin(angle) + yc;
        return new Circle(nx, ny);
    }
    public void render()
    {
        ellipse(xc, yc, radius, radius);
    }
}

static class ListNode
{
    Circle element;
    ListNode next;
    public ListNode(Circle element, ListNode next)
    {
        this.element = element;
        this.next = next;
    }
}

class CircleList
{
    int count;
    ListNode front, back;
    public CircleList()
    {
        front = null;
        back = null;
    }
    
    public void addElement(Circle element)
    {
        ListNode temp = new ListNode(element, null);
        if (back == null)
        {
            front = temp;
            back = temp;
            count++;
        }
        else
        {
            back.next = temp;
            back = temp;
            count++;
        }
    }
    
    public Circle removeFirst()
    {
        if (front == null)
            return null;
            
        ListNode temp = front;
        front = front.next;
        count--;
        return temp.element;
    }
    
    public void render(Circle current)
    {
        int index = 1;
        ListNode temp = front;
        while (temp != null)
        {
            index++;
            //temp.element.render();
            if (temp.next != null)
            {
                strokeWeight(radius * 2 + 1);
                line(temp.element.xc, temp.element.yc,
                         temp.next.element.xc, temp.next.element.yc);
                strokeWeight(1);
            }
            temp = temp.next;
        }
        strokeWeight(radius * 2 + 1);
        if (current != null && back != null)
            line(back.element.xc, back.element.yc,
                     current.xc, current.yc);
        strokeWeight(1);        
    }
    
    public boolean checkCollision(Circle current)
    {
        ListNode temp = front;
        while (temp != null)
        {
            if (current.touches(temp.element))
                return true;
            temp = temp.next;
        }
        return false;
    }
    
    public int size()
    {
        return count;
    }
}

