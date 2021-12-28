isurface.setAlwaysOnTop(true);mport processing.video.*;
import themidibus.*;

Capture video;
MidiBus bus;

//String letterOrder = " •♦■#$░▒▓█";
String letterOrder = " •♦■░▒▓█";
String glyphs = "☻♫♥♦";
color[] gcolors = {color(88, 194, 64),color(62,214,156),color(153,62,214),color(214,62,133)};
char[] glypha = glyphs.toCharArray();
char[] letters;
float amt, rx, ry;
color one = color(200, 255, 200);
color two = color(230, 25, 230);
color three = color(0, 100, 255);
color four = color(0, 5, 50);
color[] vcolors = {one, two, three, four};

float[] bright;
float[] lastSize = {0.0, 0.0, 0.0, 0.0};
char[] chars;
color startc, stopc, fill1;
color[] colors;

PFont font;
float fontSize = 8;
int bmaxheight, bwidth, c1size;
float g = 0.6;

Mover[] movers = new Mover[4];
Attractor att;

void setup() { 
  bus = new MidiBus(this, "vm3", -1);
  size(416, 280);
  surface.setAlwaysOnTop(true);

  for (int i = 0; i < movers.length; i++) {
    movers[i] = new Mover(10,random(416),random(280)); 
    /* movers[i].colorf = gcolors[i]; */
    movers[i].colorf = color(255, 255, 255);
    movers[i].glyph = glypha[i];
  }
  att = new Attractor(208, 140, 100);
  rx = 208;
  ry = 140;

  c1size = 0;
  
  video = new Capture(this, 52, 35, "IPEVO Do-Cam");
  video.start();
  
  int count = 52 * 35;

  font = createFont("Ac437_IBM_EGA_8x8.ttf", 8);

  colorMode(RGB);

  letters = new char[256];
  colors = new color[256];
  for (int i = 0; i < 256; i++) {
    int index = int(map(i, 0, 256, 0, letterOrder.length()));
    letters[i] = letterOrder.charAt(index);
    float tm = map(i, 0, 255, 0, 70); 
    amt = tm/70;
    colors[i] = lerpColors(amt, vcolors);
  }

  chars = new char[count];

  bright = new float[count];
  for (int i = 0; i < count; i++) {
    bright[i] = 128;
  }
}


void captureEvent(Capture c) {
  c.read();
}


void draw() {
  background(0);

  pushMatrix();

  textFont(font, fontSize);

  int index = 0;
  video.loadPixels();

  rx += random(-1, 1);
  ry += random(-1, 1);
  if(rx < 0) {
    rx = 416;
  }
  if(rx > 416) {
    rx = 0;
  }

  //prevent going off top or bottom
  if(ry < 0){
    ry = 280;
  }
  if(ry > 280){
    ry = 0;
  }

  att.pos.x = rx;
  att.pos.y = ry;
  att.show();

  for (int y = 0; y < 35; y++) {

    translate(0, 9);

    pushMatrix();
    for (int x = 0; x < 52; x++) {
      
      int pixelColor = video.pixels[index];
      int r = (pixelColor >> 16) & 0xff;
      int g = (pixelColor >> 8) & 0xff;
      int b = pixelColor & 0xff;

      float luminance = 0.3*r + 0.59*g + 0.11*b;

      float diff = luminance - bright[index];
      bright[index] += diff * 0.2;

      fill(colors[floor(map(index, 0, 1820, 0, 256))]);
      int num = int(bright[index]);
      textSize(floor(map(num, 0, 256, 2, 10)));
      text(letters[num], 0, 0);
      
      index++;

      translate(8, 0);
    }
    popMatrix();
  }
  popMatrix();

  for (int i = 0; i < movers.length; i++) {
    movers[i].position.x += random(0.5);
    movers[i].update();
    movers[i].display();
    att.attract(movers[i]);
  }
}

void controllerChange(int channel, int number, int value) {
  float size = map(value, 0, 127, 0, 80);
  if (abs(lastSize[number-1] - size) > 3) {
    movers[number-1].csize = lerp(size, lastSize[number-1], 0.5);
  } else {
    movers[number-1].csize = size;
  }
  lastSize[number-1] = size;
}

void delay(int time) {
  int current = millis();
  while (millis () < current+time) Thread.yield();
}

color lerpColors(float amt, color... colors) {
  if(colors.length==1){ return colors[0]; }
  float cunit = 1.0/(colors.length-1);
  return lerpColor(colors[floor(amt / cunit)], colors[ceil(amt / cunit)], amt%cunit/cunit);
}
