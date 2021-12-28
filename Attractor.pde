class Attractor {
  PVector pos;
  PVector force;
  float mass, r, distanceSq, strength;

  Attractor(float x, float y, float m) {
    pos = new PVector(x, y);
    mass = m;
    r = sqrt(mass) * 2;
  }

  void attract(Mover m) {
    PVector force = PVector.sub(pos, m.position);
    distanceSq = constrain(force.magSq(), 100, 1000);
    strength = (g * (mass * m.mass)) / distanceSq;
    force.setMag(strength);
    m.applyForce(force);
  }

  void show() {
    noStroke();
    noFill();
    circle(pos.x, pos.y, r * 2);
  }
}
