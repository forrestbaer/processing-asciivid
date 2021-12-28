import processing.video.*;
import themidibus.*;

// variable declarations
Capture video;
MidiBus bus;

Mover[] movers = new Mover[4];
Attractor att;

String letterOrder = " •♦■░▒▓█";
String glyphs = "☻♫♥♦";
char[] glypha = glyphs.toCharArray();
char[] letters;

float[] bright;
float[] lastSize = {0.0, 0.0, 0.0, 0.0};
float colorInterpolationAmt;
// gravity
float g = 0.6;
float fontSize = 8;

// video color array
color one = color(200, 255, 200);
color two = color(230, 25, 230);
color three = color(0, 100, 255);
color four = color(0, 5, 50);
color[] vcolors = {one, two, three, four};
color[] colors;

char[] chars;

// based on characters, using an 8x8 font
// 52 * 8 = 416, 35 * 8 = 280
int width = 52;
int height = 35;
int totalCharacters = width * height;
int screenWidth = int(floor(width * fontSize));
int screenHeight = int(floor(height * fontSize));

PFont font;
PVector walkerpos = new PVector(screenWidth/2, screenHeight/2);

public void settings() {
  size(screenWidth, screenHeight);
}

void setup() { 
  surface.setAlwaysOnTop(true);
  colorMode(RGB);

  // use your device name here
  video = new Capture(this, width, height, "IPEVO Do-Cam");
  video.start();
  
  // will need to provide your own virtual midi device here
  bus = new MidiBus(this, "vm3", -1);
  
  // a nice nostalgic font
  font = createFont("Ac437_IBM_EGA_8x8.ttf", 8);

  // set up the movers, and attractor, which float around the screen
  for (int i = 0; i < movers.length; i++) {
    movers[i] = new Mover(0.8, random(416), random(280), 8); 
    // glyphs all white for now, could easily use lerp or an array
    movers[i].fcolor = color(255, 255, 255);
    movers[i].glyph = glypha[i];
  }
  att = new Attractor(208, 140, 100);

  letters = new char[256];
  colors = new color[256];
  for (int i = 0; i < 256; i++) {
    int index = int(map(i, 0, 256, 0, letterOrder.length()));
    letters[i] = letterOrder.charAt(index);
    float tm = map(i, 0, 255, 0, 70); 
    colorInterpolationAmt = tm/70;
    colors[i] = lerpColors(colorInterpolationAmt, vcolors);
  }

  chars = new char[totalCharacters];
  bright = new float[totalCharacters];
  for (int i = 0; i < totalCharacters; i++) {
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
  doRandomWalk();

  for (int y = 0; y < 35; y++) {
    // move 9 pixels to add some space
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
      int num = int(bright[index]);

      fill(colors[floor(map(index, 0, 1820, 0, 256))]);
      textSize(floor(map(num, 0, 256, 2, 10)));
      text(letters[num], 0, 0);
      
      translate(8, 0);
      index++;
    }
    popMatrix();
  }
  popMatrix();

  // set those walkers aspinnin
  for (int i = 0; i < movers.length; i++) {
    movers[i].pos.x += random(0.5);
    movers[i].update();
    movers[i].display();
    att.attract(movers[i]);
  }
}

// midi control message arrives
// using lerp here to smooth out the fast message changes
void controllerChange(int channel, int number, int value) {
  // we rarely ever hit 127, lower the bar a bit
  int index = number-1;

  if (abs(lastSize[index] - value) > 5) {
    float lerped = lerp(value, lastSize[index], 0.5);
    movers[index].csize = lerped;
    lastSize[index] = lerped;
  } else {
    movers[index].csize = value;
    lastSize[index] = value;
  }
}

// better color interpolation, pass an array
color lerpColors(float amt, color... colors) {
  if(colors.length==1){ return colors[0]; }
  float cunit = 1.0/(colors.length-1);
  return lerpColor(colors[floor(amt / cunit)], colors[ceil(amt / cunit)], amt%cunit/cunit);
}

// move the attractor around slowly
void doRandomWalk() {
  walkerpos.x += random(-1, 1);
  walkerpos.y += random(-1, 1);

  if(walkerpos.x < 0) {
    walkerpos.x = 416;
  }
  if(walkerpos.x > 416) {
    walkerpos.x = 0;
  }

  //prevent going off top or bottom
  if(walkerpos.y < 0){
    walkerpos.y = 280;
  }
  if(walkerpos.y > 280){
    walkerpos.y = 0;
  }

  att.pos.x = walkerpos.x;
  att.pos.y = walkerpos.y;
  att.show();
}
