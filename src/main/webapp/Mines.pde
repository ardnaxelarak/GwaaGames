/* @pjs font="Noticia.ttf"; */

boolean[][] checked;
boolean[][] mine, flag;
boolean paused;
boolean gameend, win;
boolean started;
boolean ctrl;
int bsize;
int minecount;
int lines;
int score;
int dispX, dispY;
color[] colors;
PFont font32, font12;

public void setup()
{
  size(651, 651);

  font32 = createFont("Noticia", 32);
  font12 = createFont("Noticia", 12);
  
  colors = new color[7];
  colors[0] = color(240, 80, 240);
  colors[1] = color(250, 150, 150);
  colors[2] = color(130, 180, 130);
  colors[3] = color(50, 240, 50);
  colors[4] = color(140, 150, 240);
  colors[5] = color(255, 200, 0);
  colors[6] = color(230, 255, 124);
  
  dispX = 101;
  dispY = 101;
  bsize = 29;
  
  started = false;
  ctrl = false;

  noStroke();
}

void newgame()
{
  checked = new boolean[15][15];
  mine = new boolean[15][15];
  flag = new boolean[15][15];
  
  minecount = 35;

  for (int i = 0; i < checked.length; i++)
  {
    for (int j = 0; j < checked[i].length; j++)
    {
      checked[i][j] = false;
    }
  }
  
  int mines = 0;
  while (mines < minecount)
  {
    int rx, ry;
    rx = (int)random(checked[0].length);
    ry = (int)random(checked.length);
    if (!mine[ry][rx])
    {
      mine[ry][rx] = true;
      mines++;
    }
  }
  
  paused = false;
  gameend = false;
  win = false;
  started = true;
}

int getMines(int xind, int yind)
{
  int count = 0;
  for (int xo = -1; xo <= 1; xo++)
  {
    for (int yo = -1; yo <= 1; yo++)
    {
      if (yind + yo < 0 || yind + yo >= checked.length ||
          xind + xo < 0 || xind + xo >= checked[0].length)
        continue;
      if (mine[yind + yo][xind + xo])
        count++;
    }
  }
  return count;
}

int getFlags(int xind, int yind)
{
  int count = 0;
  for (int xo = -1; xo <= 1; xo++)
  {
    for (int yo = -1; yo <= 1; yo++)
    {
      if (yind + yo < 0 || yind + yo >= checked.length ||
          xind + xo < 0 || xind + xo >= checked[0].length)
        continue;
      if (flag[yind + yo][xind + xo])
        count++;
    }
  }
  return count;
}

void checkWin()
{
  for (int j = 0; j < checked.length; j++)
  {
    for (int i = 0; i < checked[0].length; i++)
    {
      if (!checked[j][i] && !flag[j][i])
        return;
    }
  }
  gameend = true;
  win = true;
}

void draw()
{
  background(200);
  
  if (!started)
  {
    textFont(font32);
    fill(0);
    textAlign(CENTER, CENTER);
    text("Mines", (float)(width / 2), (float)(height  / 2));
    textFont(font12);
    text("Click to start", (float)(width / 2), (float)(height / 2 + 50)); 
  }
  else
  {
    fill(51);
    rect(dispX - 1, dispY - 1, checked[0].length * (bsize + 1) + 1,
         checked.length * (bsize + 1) + 1);
    
    textAlign(CENTER, CENTER);
    textFont(font12);
    fill(0);
    
    for (int j = 0; j < checked.length; j++)
    {
      for (int i = 0; i < checked[j].length; i++)
      {
        if (checked[j][i])
        {
          if (mine[j][i])
            fill(200, 0, 0);
          else
            fill(150);
        }
        else if (flag[j][i])
        {
          fill(100);
        }
        else
        {
          if (getMouseX() >= 0 && getMouseY() >= 0 &&
              checked[getMouseY()][getMouseX()] &&
              abs(getMouseX() - i) <= 1 &&
              abs(getMouseY() - j) <= 1 &&
              mousePressed)
            fill(125);
          else
            fill(100);
        }
        rect(dispX + i * (bsize + 1), dispY + j * (bsize + 1),
            bsize, bsize);
        fill(0);
        if (checked[j][i])
        {
          if (mine[j][i])
          {
            text("M", dispX + i * (bsize + 1) + (float)(bsize / 2),
                      dispY + j * (bsize + 1) + (float)(bsize / 2)); 
          }
          else
          {
            if (getMines(i, j) > 0)
              text(getMines(i, j) + "",
                   dispX + i * (bsize + 1) + (float)(bsize / 2),
                   dispY + j * (bsize + 1) + (float)(bsize / 2)); 
          }
        }
        else if (flag[j][i])
        {
          text("F", dispX + i * (bsize + 1) + (float)(bsize / 2),
                    dispY + j * (bsize + 1) + (float)(bsize / 2)); 
        }
      }
    }
    
    if (paused)
    {
      fill(200);
      rect(183, 220, 200, 160);
      textFont(font12);
      fill(0);
      text("Paused for some\npointless reason", 283, 300);
    }
    
    if (gameend)
    {
      textFont(font32);
      fill(255, 0, 0);
      String egtext = "GAME OVER";
      if (win)
        egtext = "You win!";
      text(egtext,
           (int)((dispX + checked[0].length * (bsize + 1) / 2)),
           (int)((dispY + checked.length * (bsize + 1))) + 40);
      textFont(font12);
      text("Press ENTER to play again",
           (int)((dispX + checked[0].length * (bsize + 1) / 2)),
           (int)((dispY + checked.length * (bsize + 1))) + 75);
    }
  }
}

void keyPressed()
{
  if (gameend && (keyCode == ENTER || keyCode == RETURN))
    newgame();
  if (keyCode == CONTROL)
    ctrl = true;
  if (key == 'p' || key == 'P')
    paused = !paused;
  if (key == 'n' && gameend)
    newgame();
}

void keyReleased()
{
  if (keyCode == CONTROL)
    ctrl = false;
  if (!paused && !gameend)
  {
  }
} 

void checkaround(int xind, int yind)
{
  for (int xo = -1; xo <= 1; xo++)
  {
    for (int yo = -1; yo <= 1; yo++)
    {
      if (yind + yo < 0 || yind + yo >= checked.length ||
          xind + xo < 0 || xind + xo >= checked[0].length)
        continue;
      if (!checked[yind + yo][xind + xo] && !flag[yind + yo][xind + xo])
        check(xind + xo, yind + yo);
    }
  }
}

void check(int xind, int yind)
{
  checked[yind][xind] = true;
  if (mine[yind][xind])
    gameend = true;
  else if (getMines(xind, yind) == 0)
  {
    checkaround(xind, yind);
  }
  if (!gameend)
    checkWin();    
}

int getMouseX()
{
  int xind;
  xind = floor((mouseX - dispX) / (bsize + 1.0));
  if (xind < 0 || xind >= checked[0].length)
    return -2;
  else
    return xind;
}

int getMouseY()
{
  int yind;
  yind = floor((mouseY - dispY) / (bsize + 1.0));
  if (yind < 0 || yind >= checked.length)
    return -2;
  else
    return yind;
}

void mouseClicked()
{
  if (!started)
    newgame();
  else if (gameend)
  {
  }
  else
  {
    int xind, yind;
    xind = getMouseX();
    yind = getMouseY();
    if (xind < 0 || yind < 0)
      return;
    //check(xind, yind);
    //println(mouseButton);
    if (mouseButton == LEFT && !ctrl)
    {
      if (!checked[yind][xind] && !flag[yind][xind])
        check(xind, yind);
      if (checked[yind][xind] && getMines(xind, yind) == getFlags(xind, yind))
        checkaround(xind, yind);
    }
    else if (mouseButton == RIGHT || ctrl)
    {
      if (!checked[yind][xind])
        flag[yind][xind] = !flag[yind][xind];
      checkWin();
    }
  }
}
