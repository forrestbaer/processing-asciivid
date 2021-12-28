class Mover {

  PVector pos;
  PVector velocity;
  PVector acceleration;
  float mass, csize;
  color fcolor;
  char glyph;

  Mover(float m, float x, float y, float cs) {
    mass = 0.8;
    csize = cs;
    pos = new PVector(x, y);
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
  }

  void applyForce(PVector force) {
    PVector f = PVector.div(force, mass);
    acceleration.add(f);
  }

  void update() {
    velocity.add(acceleration);
    pos.add(velocity);
    acceleration.mult(0);
  }

  void display() {
    noStroke();
    if (csize < 15) {
    } else {
      fill(fcolor);
      float mappedSize = map(csize, 0, 80, 1, 40);
      textSize(mappedSize);
      textAlign(CENTER,CENTER);
      text(glyph, pos.x, pos.y);
    }
  }
}
