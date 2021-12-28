class Mover {

  PVector position;
  PVector velocity;
  PVector acceleration;
  float mass, csize;
  color colorf;
  char glyph;

  Mover(float m, float x, float y) {
    mass = 0.8;
    csize = m;
    position = new PVector(x, y);
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
  }

  void applyForce(PVector force) {
    PVector f = PVector.div(force, mass);
    acceleration.add(f);
  }

  void update() {
    velocity.add(acceleration);
    position.add(velocity);
    acceleration.mult(0);
  }

  void display() {
    stroke(2);
    fill(colorf);
    float tsize = map(csize, 0, 80, 1, 40);
    textSize(tsize);
    textAlign(CENTER,CENTER);
    text(glyph, position.x, position.y, 10);
  }
}
