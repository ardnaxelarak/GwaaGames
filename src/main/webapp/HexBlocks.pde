/* @pjs font="Noticia.ttf"; */

/**
 * Left click to place a block<br>
 * Right click to rotate current block<br>
 * Rows or columns clear when completely filled<br>
 * Game ends when the current block cannot be placed<br>
 * 6 x 6 or 7 x 7 is recommended, as 5 x 5 appears to be a bit too small and 8 x 8 too big 
 */
 
String gamename = "hexblocks";
static float sq3 = sqrt(3);

int[][] blocks;
int[] loffset, roffset;
int rad;
Shape curshape, nextshape;
boolean gameend;
boolean started;
int curX, curY;
//float xcen, ycen;
float dispX, dispY, dispW, dispH;
float xStart;
int bsize;
int lines;
int score;
int curfade;
int ttr;
boolean ctrl;
String name;
String[] scores;
color[] colors;
PFont font32, font12;

void setup()
{
	size(615, 452);

	curshape = new Shape(null);
	
	font32 = createFont("Noticia", 32);
	font12 = createFont("Noticia", 12);

	startscreen = new Start(this, font12, gamename);
	startscreen.requestLogo("images/HexBlocksLogo.png");
	
	String[] loc = new String[] {"3", "4", "5", "6", "7", "8"};
	
	for (int i = 0; i < 6; i++)
			startscreen.addButton(
					"images/Start" + loc[i] + ".png",
					"images/Start" + loc[i] + "Glow.png",
					width / 2 + (i - 2.5) * width / 6,
					345, i);
	startscreen.alttext = "Select a board size";
	startscreen.adjustLogo(width / 2, 150);
	
	colors = new color[7];
	colors[0] = color(0, 128, 255);
	colors[1] = color(0, 255, 0);
	colors[2] = color(255, 50, 50);
	
	dispX = 150;
	dispY = 19;
	bsize = 24;
	
	started = false;

	noStroke();
}

void newgame(int size)
{
	gamename = "hexblocks" + "_" + size;
	rad = size;
	
	blocks = new int[2 * rad - 1][];
	loffset = new int[2 * rad - 1];
	roffset = new int[2 * rad - 1];
	for (int i = 0; i < rad; i++)
	{
		blocks[i] = new int[rad + i];
		loffset[i] = rad - 1 - i;
		roffset[i] = 0;
	}
	for (int i = rad; i < blocks.length; i++)
	{
		blocks[i] = new int[3 * rad - 2 - i];
		loffset[i] = 0;
		roffset[i] = i - rad + 1;
	}
	for (int i = 0; i < blocks.length; i++)
	{
		for (int j = 0; j < blocks[i].length; j++)
		{
			blocks[i][j] = -1;
		}
	}

	lines = 0;
	score = 0;
	
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

	int b1 = bsize + 1;
	
	dispW = (2 * rad - 1) * b1 + 1;
	dispH = (2 * rad - 2) * b1 * sq3 / 2 + b1 + 1;
	dispX = 120 + 178 - dispW / 2;
	xStart = dispX - b1 * 0.5 * (rad - 1);

	getNextBlock();
	getNextBlock();

	gameend = false;
	started = true;
	checkMouse(false);
}

int getLevel()
{
	return 10 * (int)(lines / 100) + (int)sqrt(lines % 100);
}

color setColor(int col, int alph)
{
	color ret = color(red(colors[col]), green(colors[col]), blue(colors[col]), alph);
	return ret;
}

float getX(float left, float b1, int i, int j, boolean ioff)
{
	int xloc = ioff ? j : j + loffset[i];
	return left + b1 / 2 + b1 * xloc + b1 * 0.5 * i;
}

float getY(float top, float b1, int i, int j)
{
	return top + b1 / 2 + b1 * sq3 * 0.5 * i;
}

void hexagon(float x, float y, float radius)
{
	float step = TWO_PI / 6;
	pushMatrix();
	translate(x, y);
	beginShape();
	radius += 1;
	for (int i = 0; i <= 6; i++)
	{
		vertex(radius * sin(step * i), radius * cos(step * i));
	}
	endShape(CLOSE);
	popMatrix();
}

void drawBlock(int left, int top, int blocksize, Shape shape, int shapecolor, int alph, boolean connected)
{
	float b1 = blocksize + 1;
	color scol = setColor(shapecolor, alph);
	fill(scol);
	for (int i = 0; i < shape.shape.length; i++)
	{
		for (int j = 0; j < shape.shape[i].length; j++)
		{
			if (shape.shape[i][j])
			{
//				ellipse(getX(left, b1, i, j, true),
//						getY(top, b1, i, j),
//						blocksize, blocksize);
				hexagon(getX(left, b1, i, j, true),
						getY(top, b1, i, j), blocksize / 2.0);
			}
		}
	}
}

void drawStartScreen()
{
	startscreen.draw();
}

void drawPlayingArea()
{
	int b1 = bsize + 1;
	fill(0);
	textFont(font12);
	textAlign(CENTER, CENTER);
	text("next:", 54, 11);
	text("lines:", 545, 11);
	text("score:", 545, 101);
	text("best: " + scores[0], 545, 75);
	text("best: " + scores[1], 545, 165);
	fill(51);

	for (int i = 0; i < blocks.length; i++)
		for (int j = 0; j < blocks[i].length; j++)
			hexagon(getX(xStart, b1, i, j, false),
					getY(dispY, b1, i, j), bsize / 2.0 + 3);

	//rect(dispX - 1, dispY - 1, dispW, dispH);
	//rect(19, 19, 81, 81);
	for (int i = 0; i < 5; i++)
		for (int j = 0; j < 5; j++)
			hexagon(getX(14, 16, i, j, true),
					getY(29, 16, i, j), 9);

	rect(495, 19, 100, 50);
	rect(495, 109, 100, 50);

	/*
	   noFill();
	   stroke(0);
	   rect(dispX - 1, dispY - 1, dispW, dispH);
	   noStroke();
	 */

	fill(240, 50, 50);
	int alph;
	int tj;
	int off;
	if (curfade < 40)
		alph = 255 - 6 * curfade;
	else
		alph = 15 + 6 * (curfade - 40);
	for (int i = 0; i < blocks.length; i++)
	{
		if (curY < -9)
			off = 0;
		else
			off = loffset[i] - loffset[curY];
		for (int j = 0; j < blocks[i].length; j++)
		{
			tj = j + off;
			if (blocks[i][j] >= 0)
			{
				if (willVanish(i, j))
					fill(setColor(blocks[i][j], alph));
				else
					fill(setColor(blocks[i][j], 255));
				hexagon(getX(xStart, b1, i, j, false),
						getY(dispY, b1, i, j),
						bsize / 2.0);
			}
			else if (wouldFill(i, j))
			{
				if (willVanish(i, j))
					fill(setColor(1, alph));
				else
					fill(setColor(1, 255));
				hexagon(getX(xStart, b1, i, j, false),
						getY(dispY, b1, i, j),
						bsize / 2.0);
			}
		}
	}
	float xcen = curshape.xcen;
	float ycen = curshape.ycen;

	int xo = (int)(b1 * -xcen - 0.5 * b1 * ycen - b1 * 0.5);
	int yo = (int)(-b1 * sq3 * 0.5 * ycen - 0.5 - b1 * 0.5);

	if (curX < -9 || curY < -9)
		drawBlock(mouseX + xo, mouseY + yo, bsize, curshape, 2, 120, true);

	yo = 4 * sq3 * (5 - nextshape.shape.length);
	xo = 8 * (5 - nextshape.shape[0].length) + 4 * (5 - nextshape.shape.length);
	drawBlock(15 + xo, 30 + yo, 15, nextshape, 0, 255, false);

	textFont(font32);
	textAlign(CENTER, CENTER);

	fill(255, 0, 0);
	text(lines + "", 545, 40);
	text(score + "", 545, 130);

	curfade = (curfade + 1) % 80;
}

void draw()
{
	background(200);

	if (!started)
	{
		drawStartScreen();
	}
	else
	{
		drawPlayingArea();

		if (gameend)
		{
			textAlign(CENTER, CENTER);
			text("GAME OVER", (int)(width / 2), 390);
			textFont(font12);
			fill(0);
			text("Click to play again", (int)(width / 2), 420);
			if (ttr > 0)
				ttr--;
		}
	}
}

void nextBlock(boolean four)
{
	curshape = nextshape;
	nextshape = createBlock(four);
}

boolean canPlace(Shape testshape, int cx, int cy)
{
	int ti, tj;
	int off;
	for (int i = 0; i < testshape.shape.length; i++)
	{
		ti = cy + i;
		if (ti < 0 || ti >= blocks.length)
			return false;
		off = loffset[cy] - loffset[ti];
		for (int j = 0; j < testshape.shape[i].length; j++)
		{
			if (testshape.shape[i][j])
			{
				tj = cx + j + off;
				if (tj < 0 || tj >= blocks[ti].length)
					return false;
				if (blocks[ti][tj] >= 0)
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
}

boolean placeable()
{
	Shape test = new Shape(curshape);
	for (int k = 0; k < 6; k++)
	{
		for (int i = 0; i < blocks.length; i++)
		{
			for (int j = -3; j < blocks[i].length; j++)
			{
				if (canPlace(test, j, i))
					return true;
			}
		}
		test.rotateLeft();
	}
	return false;
}

void place()
{
	int off;
	for (int i = 0; i < curshape.shape.length; i++)
	{
		off = loffset[curY] - loffset[curY + i];
		for (int j = 0; j < curshape.shape[i].length; j++)
		{
			if (curshape.shape[i][j])
				blocks[curY + i][curX + j + off] = 0;
		}
	}
	checkrow();
	getNextBlock();
	if (!placeable())
		endGame();
}

boolean wouldFill(int i, int j)
{
	if (curX < -9 || curY < -9)
		return false;
	int yv = i - curY;
	if (yv < 0 || yv >= curshape.shape.length)
		return false;
	int xv = j - curX + loffset[i] - loffset[curY];
	if (xv < 0 || xv >= curshape.shape[yv].length)
		return false;
	return curshape.shape[yv][xv];
}

boolean willVanish(int ci, int cj)
{
	if (curX < -9 || curY < -9)
		return false;
	boolean row, lcol, rcol;
	int tj;
	row = true;
	lcol = true;
	rcol = true;
	for (int i = 0; i < blocks.length; i++)
	{
		tj = cj + loffset[ci] - loffset[i];
		if (tj < 0 || tj >= blocks[i].length)
			continue;
		if (blocks[i][tj] < 0 && !wouldFill(i, tj))
		{
			lcol = false;
			break;
		}
	}
	if (lcol)
		return true;
	for (int i = 0; i < blocks.length; i++)
	{
		tj = cj + roffset[ci] - roffset[i];
		if (tj < 0 || tj >= blocks[i].length)
			continue;
		if (blocks[i][tj] < 0 && !wouldFill(i, tj))
		{
			rcol = false;
			break;
		}
	}
	if (rcol)
		return true;
	for (int j = 0; j < blocks[ci].length; j++)
	{
		if (blocks[ci][j] < 0 && !wouldFill(ci, j))
		{
			row = false;
			break;
		}
	}
	if (row)
		return true;
	return false;
}

void checkrow()
{
	int n = 0;
	int nr = 0, nlc = 0, nrc = 0;
	int tj;
	boolean[] crow, clcol, crcol;
	crow = new boolean[blocks.length];
	clcol = new boolean[blocks.length];
	crcol = new boolean[blocks.length];
	boolean filled;
	for (int i = 0; i < crow.length; i++)
	{
		filled = true;
		for (int j = 0; j < blocks[i].length; j++)
		{
			if (blocks[i][j] < 0)
			{
				filled = false;
				break;
			}
		}
		if (filled)
		{
			crow[i] = true;
			nr++;
		}
	}
	for (int j = 0; j < clcol.length; j++)
	{
		filled = true;
		for (int i = 0; i < blocks.length; i++)
		{
			tj = j - loffset[i];
			if (tj >= 0 && tj < blocks[i].length && blocks[i][tj] < 0)
			{
				filled = false;
				break;
			}
		}
		if (filled)
		{
			clcol[j] = true;
			nlc++;
		}
	}
	for (int j = 0; j < crcol.length; j++)
	{
		filled = true;
		for (int i = 0; i < blocks.length; i++)
		{
			tj = j - roffset[i];
			if (tj >= 0 && tj < blocks[i].length && blocks[i][tj] < 0)
			{
				filled = false;
				break;
			}
		}
		if (filled)
		{
			crcol[j] = true;
			nrc++;
		}
	}

	n = (nlc + 1) * (nrc + 1) * (nr + 1) - 1;
	for (int i = 0; i < crow.length; i++)
		if (crow[i])
			clearrow(i);
	for (int i = 0; i < clcol.length; i++)
		if (clcol[i])
			clearlcol(i);
	for (int i = 0; i < crcol.length; i++)
		if (crcol[i])
			clearrcol(i);
	score += (int)((n * n + n) / 2);
}

void clearrow(int row)
{
	lines++;
	for (int j = 0; j < blocks[row].length; j++)
		blocks[row][j] = -1;
}

void clearlcol(int col)
{
	lines++;
	int tj;
	for (int i = 0; i < blocks.length; i++)
	{
		tj = col - loffset[i];
		if (tj >= 0 && tj < blocks[i].length)
			blocks[i][tj] = -1;
	}
}

void clearrcol(int col)
{
	lines++;
	int tj;
	for (int i = 0; i < blocks.length; i++)
	{
		tj = col - roffset[i];
		if (tj >= 0 && tj < blocks[i].length)
			blocks[i][tj] = -1;
	}
}

void endGame()
{
	curX = -10;
	curY = -10;
	ttr = 50;
	gameend = true;

	postScore(gamename, name, lines, score);
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
			newgame(rad);
		}
	}
	if (started && !gameend)
	{
		if (keyCode == LEFT)
		{
			curshape.rotateRight();
			checkMouse(false);
		}
		else if (keyCode == RIGHT)
		{
			curshape.rotateLeft();
			checkMouse(false);
		}
	}
}

void keyReleased()
{
	if (keyCode == CONTROL)
		ctrl = false;
}

boolean outsideBox()
{
	/*
	   float border = 0;
	   if (mouseX < dispX - border || mouseX > dispX + dispW + border)
	   return true;
	   if (mouseY < dispY - border || mouseY > dispY + dispH + border)
	   return true;
	 */
	return false;
}

void mouseClicked()
{
	if (!started)
	{
		int sizesel = startscreen.mouseClicked();
		if (sizesel != null)
		{
			name = startscreen.pname;
			newgame(sizesel + 3);
		}
	}
	if (started && !gameend)
	{
		checkMouse(true);
		if (mouseButton == RIGHT || ctrl || outsideBox())
		{
			curshape.rotateLeft();
			checkMouse(false);
		}
		else if (curX >= -9 && curY >= -9)
		{
			place();
			checkMouse(false);
		}
	}
	if (gameend && ttr <= 0)
	{
		started = false;
		gameend = false;
	}
}

int getMouseX(int yind)
{
	if (yind < 0 || yind >= blocks.length)
		return -1;
	int b1 = bsize + 1;
	float xcen = curshape.xcen;
	float ycen = curshape.ycen;
	int xo = (int)(b1 * -xcen - 0.5 * b1 * (ycen - 0.5) - b1 * 0.5);
	int xind;
	xind = round((mouseX + xo - xStart - yind * b1 / 2) / b1);
	xind = xind - loffset[yind];
	return xind;
}

int getMouseY()
{
	int b1 = bsize + 1;
	float ycen = curshape.ycen;
	int yo = (int)(-b1 * sq3 * 0.5 * ycen - b1 * 0.5);
	int yind;
	yind = round((mouseY + yo - dispY) / ((bsize + 1.0) * sq3 / 2));
	if (yind < 0 || yind >= blocks.length)
		return -10;
	else
		return yind;
}

void checkMouse(boolean verbose)
{
	int ox = curX;
	int oy = curY;
	curY = getMouseY();
	curX = getMouseX(curY);

	if (curX >= -9 && curY >= 0 && !canPlace(curshape, curX, curY))
	{
		curX = -10;
		curY = -10;
	}

	if (ox != curX || oy != curY)
		curfade = 0;
}

void mouseMoved()
{
	if (!started)
	{
		startscreen.mouseMoved();
	}
	if (started && !gameend)
	{
		checkMouse(false);
	}
}
class Shape
{
	boolean[][] shape;
	float xcen, ycen;

	public Shape(Shape b)
	{
		if (b == null)
		{
			shape = new boolean[1][1];
			xcen = 0;
			ycen = 0;
			return;
		}

		shape = new boolean[b.shape.length][];
		xcen = b.xcen;
		ycen = b.ycen;
		for (int i = 0; i < b.shape.length; i++)
		{
			shape[i] = new boolean[b.shape[i].length];
			for (int j = 0; j < b.shape[i].length; j++)
				shape[i][j] = b.shape[i][j];
		}
	}

	void rotateLeft()
	{
		int[][] newx, newy;
		int cx, cy;
		int minx = 30, miny = 30, maxx = -30, maxy = -30;
		newx = new int[shape.length][shape[0].length];
		newy = new int[shape.length][shape[0].length];
		for (int i = 0; i < shape.length; i++)
			for (int j = 0; j < shape[0].length; j++)
			{
				cy = j + i;
				cx = -i;

				if (shape[i][j])
				{
					if (cy < miny)
						miny = cy;
					if (cx < minx)
						minx = cx;
					if (cy > maxy)
						maxy = cy;
					if (cx > maxx)
						maxx = cx;
				}

				newx[i][j] = cx;
				newy[i][j] = cy;
			}

		boolean[][] newshape = new boolean[maxy - miny + 1][maxx - minx + 1];
		for (int i = 0; i < newshape.length; i++)
			for (int j = 0; j < newshape[i].length; j++)
				newshape[i][j] = false;
		
		for (int i = 0; i < shape.length; i++)
			for (int j = 0; j < shape[i].length; j++)
				if (shape[i][j])
					newshape[newy[i][j] - miny][newx[i][j] - minx] = true;

		float ox, oy;
		ox = xcen;
		oy = ycen;
		ycen = ox + oy - miny;
		xcen = -oy - minx;

		shape = newshape;
	}

	void rotateRight()
	{
		int[][] newx, newy;
		int cx, cy;
		int minx = 30, miny = 30, maxx = -30, maxy = -30;
		newx = new int[shape.length][shape[0].length];
		newy = new int[shape.length][shape[0].length];
		for (int i = 0; i < shape.length; i++)
			for (int j = 0; j < shape[0].length; j++)
			{
				cy = -j;
				cx = i + j;

				if (shape[i][j])
				{
					if (cy < miny)
						miny = cy;
					if (cx < minx)
						minx = cx;
					if (cy > maxy)
						maxy = cy;
					if (cx > maxx)
						maxx = cx;
				}

				newx[i][j] = cx;
				newy[i][j] = cy;
			}

		boolean[][] newshape = new boolean[maxy - miny + 1][maxx - minx + 1];
		for (int i = 0; i < newshape.length; i++)
			for (int j = 0; j < newshape[i].length; j++)
				newshape[i][j] = false;
		
		for (int i = 0; i < shape.length; i++)
			for (int j = 0; j < shape[i].length; j++)
				if (shape[i][j])
					newshape[newy[i][j] - miny][newx[i][j] - minx] = true;

		float ox, oy;
		ox = xcen;
		oy = ycen;
		xcen = ox + oy - minx;
		ycen = -ox - miny;

		shape = newshape;
	}
}

void setBlock(Block b, int rows, int... cols)
{
	int cur;
	b.shape = new boolean[rows][cols.length];
	for (int j = 0; j < cols.length; j++)
	{
		cur = cols[j];
		for (int i = 0; i < rows; i++)
		{
			b.shape[i][j] = (cur & 1) == 1;
			cur >>>= 1;
		}
	}
	b.ycen = (b.shape.length - 1) / 2.0;
	b.xcen = (b.shape[0].length - 1) / 2.0;
}

Shape createBlock(boolean four)
{
	Shape b = new Shape(null);
	int r = (int)random(10);
	int dir = (int)random(6);
	if (!four)
		r = (int)(random(34) + 10);

	switch(r)
	{
	case 0:
		setBlock(b, 4, 15);
		break;
	case 1:
		setBlock(b, 3, 1, 7);
		break;
	case 2:
		setBlock(b, 3, 2, 7);
		break;
	case 3:
		setBlock(b, 3, 4, 7);
		break;
	case 4:
		setBlock(b, 4, 8, 7);
		break;
	case 5:
		setBlock(b, 2, 3, 3);
		break;
	case 6:
		setBlock(b, 3, 5, 3);
		break;
	case 7:
		setBlock(b, 2, 1, 3, 2);
		break;
	case 8:
		setBlock(b, 4, 8, 6, 1);
		break;
	case 9:
		setBlock(b, 3, 2, 6, 1);
		break;

	case 10:
		setBlock(b, 5, 31);
		break;
	case 11:
		setBlock(b, 4, 1, 15);
		break;
	case 12:
		setBlock(b, 4, 2, 15);
		break;
	case 13:
		setBlock(b, 4, 4, 15);
		break;
	case 14:
		setBlock(b, 4, 8, 15);
		break;
	case 15:
		setBlock(b, 5, 16, 15);
		break;
	case 16:
		setBlock(b, 4, 3, 14);
		break;
	case 17:
		setBlock(b, 3, 1, 1, 7);
		break;
	case 18:
		setBlock(b, 3, 2, 1, 7);
		break;
	case 19:
		setBlock(b, 3, 3, 7);
		break;
	case 20:
		setBlock(b, 3, 5, 7);
		break;
	case 21:
		setBlock(b, 4, 9, 7);
		break;
	case 22:
		setBlock(b, 3, 1, 7, 4);
		break;
	case 23:
		setBlock(b, 3, 1, 7, 2);
		break;
	case 24:
		setBlock(b, 3, 1, 7, 1);
		break;
	case 25:
		setBlock(b, 4, 2, 14, 1);
		break;
	case 26:
		setBlock(b, 3, 2, 2, 7);
		break;
	case 27:
		setBlock(b, 3, 4, 2, 7);
		break;
	case 28:
		setBlock(b, 3, 6, 7);
		break;
	case 29:
		setBlock(b, 4, 10, 7);
		break;
	case 30:
		setBlock(b, 3, 2, 7, 2);
		break;
	case 31:
		setBlock(b, 3, 2, 7, 1);
		break;
	case 32:
		setBlock(b, 4, 12, 7);
		break;
	case 33:
		setBlock(b, 4, 8, 14, 1);
		break;
	case 34:
		setBlock(b, 4, 8, 8, 7);
		break;
	case 35:
		setBlock(b, 5, 24, 7);
		break;
	case 36:
		setBlock(b, 5, 16, 14, 1);
		break;
	case 37:
		setBlock(b, 2, 2, 1, 3, 2);
		break;
	case 38:
		setBlock(b, 3, 5, 3, 2);
		break;
	case 39:
		setBlock(b, 3, 1, 3, 6);
		break;
	case 40:
		setBlock(b, 2, 2, 2, 1, 3);
		break;
	case 41:
		setBlock(b, 4, 10, 6, 1);
		break;
	case 42:
		setBlock(b, 3, 3, 6, 4);
		break;
	case 43:
		setBlock(b, 3, 2, 5, 3);
		break;
	}
	for (int i = 0; i < dir; i++)
		b.rotateLeft();
	curY = 0;
	return b;
}

