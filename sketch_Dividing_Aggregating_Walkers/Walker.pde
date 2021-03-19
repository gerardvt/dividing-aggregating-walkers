class Walker {
  PVector pos;
  PVector lastPos;
  float ang;
  float depositRate;
  float stepSize;
  float turnAngle;
  float turnChance;
  
  public Walker (
        float x, float y, float ang, 
        float depositRate, float stepSize, float turnAngle, float turnChance
        ) {
    this.lastPos = new PVector(x, y);
    this.pos = new PVector(x, y);
    this.ang = ang;
    this.depositRate = depositRate;
    this.stepSize = stepSize;
    this.turnAngle = turnAngle;
    this.turnChance = turnChance;
  }
  
  void update () {
    lastPos = pos.copy();

    // the walker has a random chances to turn
    if (random(0, 1) < this.turnChance) {
      this.ang+= this.turnAngle * (round(random(0, 1)) * 2. - 1.);
    }

    // move along the direction
    PVector dir = new PVector(cos(ang), sin(ang));
    pos.add(dir.mult(this.stepSize));
    
    // makes sure that the walkers stays within the window area
    pos = getTorusPosition(pos);
  }
  
  void draw () {
    stroke(255, int(255. * this.depositRate));
    strokeWeight(1);
    
    // if the line is too long (because of torus world), we shorthen it
    PVector line = lastPos.copy().sub(pos);

    if (line.mag() < 4*this.stepSize) {
      line(lastPos.x, lastPos.y, pos.x, pos.y);
    }
  }
}
