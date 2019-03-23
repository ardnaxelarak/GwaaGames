class ImageElement {
  constructor(
      sketch, im, imhover, xc, yc, selaction, dispcond, caller) {
    this.sketch = sketch;
    this.im = im;
    this.imhover = imhover;
    this.xc = xc;
    this.yc = yc;
    this.w = im.width;
    this.h = im.height;
    if (typeof selaction == "undefined") {
      this.selaction = null;
    } else {
      this.selaction = selaction;
    }
    this.align = sketch.CENTER;
    if (typeof dispcond == "undefined") {
      this.dispcond = function() {return true;}
    } else {
      this.dispcond = dispcond;
    }
    if (typeof caller == "undefined") {
      this.caller = null;
    } else {
      this.caller = caller;
    }
  }

  selected() {
    var left, right, top, bottom;
    if (this.align == this.sketch.CENTER) {
      left = this.xc - this.w / 2;
      right = this.xc + this.w / 2;
      top = this.yc - this.h / 2;
      bottom = this.yc + this.h / 2;
    } else {
      left = this.xc;
      right = this.xc + this.w;
      top = this.yc;
      bottom = this.yc + this.h;
    }
    if (this.sketch.mouseX < left || this.sketch.mouseX > right
        || this.sketch.mouseY < top || this.sketch.mouseY > bottom) {
      return false;
    }
    return true;
  }

  setPos(xc, yc) {
    this.xc = xc;
    this.yc = yc;
  }

  draw() {
    if (!this.dispcond(this.caller)) {
      return;
    }
    this.sketch.imageMode(this.align);
    if (this.selected() && this.imhover != null) {
      this.sketch.image(this.imhover, this.xc, this.yc, this.w, this.h);
    }
    this.sketch.image(this.im, this.xc, this.yc, this.w, this.h);
  }

  setAlign(corner) {
    if (corner) {
      this.align = this.sketch.CORNER;
    } else {
      this.align = this.sketch.CENTER;
    }
  }

  mouseClicked() {
    if (this.selected()) {
      return this.selaction;
    } else {
      return null;
    }
  }
}

class TextElement {
  constructor(sketch, font, text, xc, yc) {
    this.sketch = sketch;
    this.alignh = sketch.LEFT;
    this.alignv = sketch.TOP;
    this.xc = xc;
    this.yc = yc;
    this.width = -1;
    this.height = -1;
    this.text = text;
    this.font = font;
    this.color = sketch.color(0);
  }

  setLoc(xc, yc) {
    this.xc = xc;
    this.yc = yc;
  }

  setWH(width, height) {
    this.width = width;
    this.height = height;
  }

  setAlign(horiz, vert) {
    this.alignh = horiz;
    this.alignv = vert;
  }

  setText(text) {
    this.text = text;
  }

  setColor(color) {
    this.color = color;
  }

  draw() {
    this.sketch.fill(this.color);
    this.sketch.textAlign(this.alignh, this.alignv);
    this.sketch.textFont(this.font);
    if (this.width > 0) {
      this.sketch.text(
          this.text, this.xc, this.yc, this.width, this.height);
    } else {
      this.sketch.text(this.text, this.xc, this.yc);
    }
  }
}

class Page {
  constructor(sketch) {
    this.sketch = sketch;
    this.elements = [];
  }

  addElement(element) {
    this.elements.push(element);
  }

  draw() {
    this.sketch.background(200);
    for (var i = 0; i < this.elements.length; i++) {
      this.elements[i].draw();
    }
  }

  mouseClicked() {
    var selaction = null;
    for (var i = 0; i < this.elements.length; i++) {
      if (typeof this.elements[i].mouseClicked == "function") {
        var cursel = this.elements[i].mouseClicked();
        if (cursel != null) {
          selaction = cursel;
        }
      }
    }
    return selaction;
  }
}

class StartPage {
  constructor(sketch, font) {
    this.page = new Page(sketch);
    var nameTxt = new TextElement(sketch, font, "Name: ", 20, 15);
    var nameHelpTxt =
        new TextElement(
            sketch,
            font,
            "(use backspace or left arrow to change)",
            20,
            35);
    this.nameEl = new TextElement(sketch, font, "", 65, 15);
    this.nameEl.setColor(sketch.color(255, 0, 0));
    this.instEl =
        new TextElement(
            sketch, font, "Loading...", sketch.width / 2, 170);
    this.instEl.setAlign(sketch.CENTER, sketch.CENTER);
    this.page.addElement(nameTxt);
    this.page.addElement(nameHelpTxt);
    this.page.addElement(this.nameEl);
    this.page.addElement(this.instEl);
  }

  changename(newname) {
    this.nameEl.setText(newname);
  }

  siText(newtext) {
    this.instEl.setText(newtext);
  }

  siPos(xc, yc) {
    this.instEl.setLoc(xc, yc);
  }

  addElement(element) {
    this.page.addElement(element);
  }

  draw() {
    this.page.draw();
  }

  mouseClicked() {
    return this.page.mouseClicked();
  }
}

class Start {
  constructor(sketch, font, ggLogo, gamename) {
    this.alttext = "";
    this.pname = "";
    this.valid = false;
    this.font = font;
    window.gamename = gamename;
    this.sizesel = -1;
    this.starts = [];
    this.textoffset = 20;
    this.xc = sketch.width / 2;
    this.yc = 150;
    this.imEl = null;
    this.sketch = sketch;
    this.page = new StartPage(sketch, font);
    this.ggLogo = ggLogo;
    this.logoEl = new ImageElement(
        sketch,
        ggLogo,
        null,
        this.sketch.width - this.ggLogo.width,
        0);
    this.logoEl.setAlign(true);
    this.page.addElement(this.logoEl);
    this.loadName();
    this.saveName();
    this.oname = "CondSIE";
  }

  setInst() {
    if (this.pname === "") {
      this.page.siText("Please enter your name.");
      this.valid = false;
    } else {
      this.page.siText(this.alttext);
      this.valid = true;
    }
    if (this.imEl != null) {
      this.imEl.setPos(this.xc, this.yc);
    }
    var newy = this.yc + this.textoffset;
    if (this.im != null) {
      newy += this.im.height / 2;
    }
    this.page.siPos(this.xc, newy);
    this.logoEl.setPos(this.sketch.width - this.ggLogo.width, 0);
  }

  saveName() {
    window.user = this.pname;
    this.page.changename(this.pname);
    this.setInst();
  }

  loadName() {
    /*
    try {
      var options = this.sketch.loadStrings("name");
      if (options.length < 1) {
        this.pname = "";
      } else {
        this.pname = options[0].split("_").join(" ");
      }
    } catch (e) {
      this.pname = "";
    }
    window.user = this.pname;
    this.page.changename(this.pname);
    this.setInst();
    */
  }

  setLogo(image) {
    this.im = image;
    this.imEl =
        new ImageElement(this.sketch, image, null, this.xc, this.yc);
    this.setInst();
    this.page.addElement(this.imEl);
  }

  adjustLogo(xc, yc) {
    this.xc = xc;
    this.yc = yc;
    this.setInst();
  }

  changeOffset(offset) {
    this.textoffset = offset;
    this.setInst();
  }

  draw() {
    this.page.draw();
  }

  isValid(object) {
    return object.valid;
  }

  addButton(im, imhover, xc, yc, selaction) {
    var csie = new ImageElement(
        this.sketch, im, imhover, xc, yc, selaction, this.isValid, this);
    this.page.addElement(csie);
  }

  keyTyped() {
    var key = this.sketch.key;
    if ((key >= 'a' && key <= 'z')
        || (key >= 'A' && key <= 'Z')
        || (key >= '0' && key <= '9')
        || (key == '-')) {
      this.pname += key;
    }
    if ((key == ' ' || key == '_') && this.pname.length > 0) {
      this.pname += key;
    }
    this.saveName();
  }

  keyPressed() {
    var kc = this.sketch.keyCode;
    if ((kc == this.sketch.BACKSPACE || kc == this.sketch.DELETE
        || kc == this.sketch.LEFT_ARROW) && this.pname.length > 0) {
      this.pname = this.pname.slice(0, -1);
    }
    this.saveName();
  }

  mouseMoved() {}

  mouseClicked() {
    var selaction = this.page.mouseClicked();
    if (typeof selaction != "undefined" && selaction != null) {
      if (typeof selaction == "number") {
        return selaction;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }
}

