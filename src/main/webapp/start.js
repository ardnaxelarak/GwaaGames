function ImageElement(processing, im, imhover, xc, yc, selaction, dispcond, caller)
{
	this.processing = processing;
	this.loaded = false;
	this.im = im;
	this.imhover = imhover;
	this.xc = xc;
	this.yc = yc;
	this.w = 0;
	this.h = 0;
	if (typeof selaction == "undefined")
		this.selaction = null;
	else
		this.selaction = selaction;
	this.align = processing.CENTER;
	if (typeof dispcond == "undefined")
		this.dispcond = function() {return true;}
	else
		this.dispcond = dispcond;
	if (typeof caller == "undefined")
		this.caller = null;
	else
		this.caller = caller;
	this.load();
}

ImageElement.prototype.load = function()
{
	if (this.im != null && this.im.width > 0)
	{
		this.w = this.im.width;
		this.h = this.im.height;
		this.loaded = true;
	}
}

ImageElement.prototype.selected = function()
{
	var left, right, top, bottom;
	if (this.align == this.processing.CENTER)
	{
		left = this.xc - this.w / 2;
		right = this.xc + this.w / 2;
		top = this.yc - this.h / 2;
		bottom = this.yc + this.h / 2;
	}
	else
	{
		left = this.xc;
		right = this.xc + this.w;
		top = this.yc;
		bottom = this.yc + this.h;
	}
	if (this.processing.mouseX < left || this.processing.mouseX > right ||
		this.processing.mouseY < top || this.processing.mouseY > bottom)
		return false;
	return true;
}

ImageElement.prototype.setPos = function(xc, yc)
{
	this.xc = xc;
	this.yc = yc;
}

ImageElement.prototype.draw = function()
{
	if (!this.dispcond(this.caller))
		return;
	if (!this.loaded)
	{
		this.load();
	}
	if (this.loaded)
	{
		this.processing.imageMode(this.align);
		if (this.selected() && this.imhover != null)
			this.processing.image(this.imhover, this.xc, this.yc, this.w, this.h);
		this.processing.image(this.im, this.xc, this.yc, this.w, this.h);
	}
}

ImageElement.prototype.setAlign = function(corner)
{
	if (corner)
		this.align = this.processing.CORNER;
	else
		this.align = this.processing.CENTER;
}

ImageElement.prototype.mouseClicked = function()
{
	if (this.selected())
		return this.selaction;
	else
		return null;
}

function TextElement(processing, font, text, xc, yc)
{
	this.processing = processing;
	this.alignh = processing.LEFT;
	this.alignv = processing.TOP;
	this.xc = xc;
	this.yc = yc;
	this.width = -1;
	this.height = -1;
	this.text = text;
	this.font = font;
	this.color = processing.color(0);
}
	
TextElement.prototype.setLoc = function(xc, yc)
{
	this.xc = xc;
	this.yc = yc;
}
	
TextElement.prototype.setWH = function(width, height)
{
	this.width = width;
	this.height = height;
}
	
TextElement.prototype.setAlign = function(horiz, vert)
{
	this.alignh = horiz;
	this.alignv = vert;
}
	
TextElement.prototype.setText = function(text)
{
	this.text = text;
}
	
TextElement.prototype.setColor = function(color)
{
	this.color = color;
}
	
TextElement.prototype.draw = function()
{
	this.processing.fill(this.color);
	this.processing.textAlign(this.alignh, this.alignv);
	this.processing.textFont(this.font);
	if (this.width > 0)
	{
		this.processing.text(this.text, this.xc, this.yc, this.width, this.height);
	}
	else
	{
		this.processing.text(this.text, this.xc, this.yc);
	}
}

function Page(processing)
{
	this.processing = processing;
	this.elements = new Array();
}

Page.prototype.addElement = function(element)
{
	this.elements.push(element);
}

Page.prototype.draw = function()
{
	this.processing.background(200);
	for (var i = 0; i < this.elements.length; i++)
		this.elements[i].draw();
}

Page.prototype.mouseClicked = function()
{
	var selaction = null;
	for (var i = 0; i < this.elements.length; i++)
	{
		if (typeof this.elements[i].mouseClicked == "function")
		{
			var cursel = this.elements[i].mouseClicked();
			if (cursel != null)
				selaction = cursel;
		}
	}
	return selaction;
}

function StartPage(processing, font12)
{
	this.page = new Page(processing);
	var nameTxt = new TextElement(processing, font12, "Name: ", 20, 15);
	var nameHelpTxt = new TextElement(processing, font12, "(use backspace or left arrow to change)", 20, 35);
	this.nameEl = new TextElement(processing, font12, "", 65, 15);
	this.nameEl.setColor(processing.color(255, 0, 0));
	this.instEl = new TextElement(processing, font12, "Loading...", processing.width / 2, 170);
	this.instEl.setAlign(processing.CENTER, processing.CENTER);
	this.page.addElement(nameTxt);
	this.page.addElement(nameHelpTxt);
	this.page.addElement(this.nameEl);
	this.page.addElement(this.instEl);
}

StartPage.prototype.changename = function(newname)
{
	this.nameEl.setText(newname);
}
StartPage.prototype.siText = function(newtext)
{
	this.instEl.setText(newtext);
}
StartPage.prototype.siPos = function(xc, yc)
{
	this.instEl.setLoc(xc, yc);
}
StartPage.prototype.addElement = function(element)
{
	this.page.addElement(element);
}
StartPage.prototype.draw = function()
{
	this.page.draw();
}
StartPage.prototype.mouseClicked = function()
{
	return this.page.mouseClicked();
}

function Start(processing, font12, gamename)
{
	this.alttext = "";
	this.pname = "";
	this.valid = false;
	this.font12 = font12;
	window.gamename = gamename;
	this.sizesel = -1;
	this.starts = new Array();
	this.textoffset = 20;
	this.xc = processing.width / 2;
	this.yc = 150;
	this.imEl = null;
	this.images = new Array();
	this.processing = processing;
	this.page = new StartPage(processing, font12);
	this.fglogo = this.requestImage("images/FGLogo.png");
	this.logoEl = new ImageElement(processing, this.fglogo, null, this.processing.width - this.fglogo.width, 0);
	this.logoEl.setAlign(true);
	this.page.addElement(this.logoEl);
	this.loadName();
	this.saveName();
	this.oname = "CondSIE";
}

Start.prototype.setInst = function()
{
	if (this.pname === "")
	{
		this.page.siText("Please enter your name.");
		this.valid = false;
	}
	else if (this.images.length > 0)
	{
		this.page.siText("Loading: please wait...");
		this.valid = false;
	}
	else
	{
		this.page.siText(this.alttext);
		this.valid = true;
	}
	if (this.imEl != null)
	{
		this.imEl.setPos(this.xc, this.yc);
	}
	var newy = this.yc + this.textoffset;
	if (this.im != null)
		newy += this.im.height / 2;
	this.page.siPos(this.xc, newy);
	this.logoEl.setPos(this.processing.width - this.fglogo.width, 0);
}

Start.prototype.saveName = function()
{
	var options = Array(this.pname);
	this.processing.saveStrings("name", options);
	window.user = this.pname;
	this.page.changename(this.pname);
	this.setInst();
}
	
Start.prototype.loadName = function()
{
	try
	{
		var options = this.processing.loadStrings("name");
		if (options.length < 1)
			this.pname = "";
		else
			this.pname = options[0].split("_").join(" ");
	}
	catch (e)
	{
		this.pname = "";
	}
	window.user = this.pname;
	this.page.changename(this.pname);
	this.setInst();
}
	
Start.prototype.checkImages = function()
{
	for (var i = 0; i < this.images.length; i++)
	{
		if (this.images[i].width > 0)
		{
			this.images.splice(i, 1);
			i--;
		}
	}
	this.setInst();
}
	
Start.prototype.requestLogo = function(filename)
{
	this.im = this.requestImage(filename);
	this.imEl = new ImageElement(this.processing, this.im, null, this.xc, this.yc);
	this.setInst();
	this.page.addElement(this.imEl);
	return this.im;
}

Start.prototype.requestImage = function(filename)
{
	var im = this.processing.requestImage(filename);
	this.images.push(im);
	return im;
}

Start.prototype.adjustLogo = function(xc, yc)
{
	this.xc = xc;
	this.yc = yc;
	this.setInst();
}

Start.prototype.changeOffset = function(offset)
{
	this.textoffset = offset;
	this.setInst();
}
	
Start.prototype.draw = function()
{
	this.checkImages();
	this.page.draw();
}

Start.prototype.isValid = function(object)
{
	return object.valid;
}
	
Start.prototype.addButtonImage = function(im, imhover, xc, yc, selaction)
{
	var csie = new ImageElement(this.processing, im, imhover, xc, yc, selaction, this.isValid, this);
	this.page.addElement(csie);
}
	
Start.prototype.addButton = function(file, filehover, xc, yc, selaction)
{
	var im = this.requestImage(file);
	var imhover = this.requestImage(filehover);
	var csie = new ImageElement(this.processing, im, imhover, xc, yc, selaction, this.isValid, this);
	this.page.addElement(csie);
}
	
Start.prototype.keyPressed = function()
{
	var key = this.processing.key;
	var kc = this.processing.keyCode;
	if ((key >= 97 && key <= 122) ||
		(key >= 65 && key <= 90) ||
		(key >= 48 && key <= 57) ||
		(key == 45))
		this.pname += this.processing.str(key);
	if ((key == 32 || key == 95) && this.pname.length > 0)
		this.pname += this.processing.str(key);
	if ((kc == this.processing.BACKSPACE || kc == this.processing.DELETE ||
		 kc == this.processing.LEFT) && this.pname.length > 0)
		this.pname = this.pname.slice(0, -1);
	this.saveName();
}

Start.prototype.mouseMoved = function()
{
}

Start.prototype.mouseClicked = function()
{
	var selaction = this.page.mouseClicked();
	if (typeof selaction != "undefined" && selaction != null)
	{
		if (typeof selaction == "number")
			return selaction;
		else
			return null;
	}
	else
		return null;
}
