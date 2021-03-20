class Walker {
  PVector pos;
  PVector lastPos;
  float ang;
  float depositRate;
  float stepSize;
  float turnAngle;
  float turnChance;
  float terminationChances;
  boolean isTerminated;
  float divisionChances;
  float divisionAngle;
  boolean discreteDivisionAngle;
  PVector boundingBoxUpperLeft;
  PVector boundingBoxLowerRight;
  PVector c;

  public Walker (
        float x, float y, float ang, 
        float depositRate, float stepSize, float turnAngle, float turnChance,
        float terminationChances,
        float divisionChances, float divisionAngle, boolean discreteDivisionAngle,
        PVector boundingBoxUpperLeft, PVector boundingBoxLowerRight,
        PVector c
        ) {
    this.lastPos = new PVector(x, y);
    this.pos = new PVector(x, y);
    this.ang = ang;
    this.depositRate = depositRate;
    this.stepSize = stepSize;
    this.turnAngle = turnAngle;
    this.turnChance = turnChance;
    this.terminationChances = terminationChances;
    this.isTerminated = false;
    this.divisionChances = divisionChances;
    this.divisionAngle = divisionAngle;
    this.discreteDivisionAngle = discreteDivisionAngle;
    this.boundingBoxUpperLeft = boundingBoxUpperLeft.copy();
    this.boundingBoxLowerRight = boundingBoxLowerRight.copy();
    this.c = c.copy();

  }
  

  ArrayList<Walker> update () {
    ArrayList<Walker> splitWalkers = new ArrayList<Walker>();

    // Walker only updates if it's still alive
    if (isAlive())
    {
      lastPos = pos.copy();

      // the walker has a random chances to turn
      if (random(0, 1) < this.turnChance) {
        this.ang+= this.turnAngle * (round(random(0, 1)) * 2. - 1.);
      }

      // move along the direction
      PVector dir = new PVector(cos(ang), sin(ang));
      pos.add(dir.mult(this.stepSize));
      
      // makes sure that the walkers stays within the window area
      pos = mapPositionInsideBoundingBox(pos);

      // After this update, walker can self terminate based on its terminationChances
      if (random(0, 1) < this.terminationChances) {
        this.isTerminated = true;
      }

      // Decide if walker will self-split.
      // In preparation for the planned feature where a walker
      // might split into more than two walker (current and new one), we
      // will return an array of Walkers and not a single new Walker. This also
      // allows us to return an in the case the Walker does not split.
      if ( random(0, 1) < this.divisionChances) {
        float newAngle = this.ang + (this.discreteDivisionAngle ? round(random(0, 1))*2-1 : random(-1, 1)) * this.divisionAngle;
        Walker newWalker = new Walker(this.pos.x, this.pos.y, newAngle, this.depositRate, this.stepSize, this.turnAngle, this.turnChance, this.terminationChances,
                            this.divisionChances, this.divisionAngle, this.discreteDivisionAngle,
                            this.boundingBoxUpperLeft, this.boundingBoxLowerRight,
                            c.copy());
        splitWalkers.add(newWalker);
      }
    }
    
    return splitWalkers;
  }
  
  void draw () {
    // Walker only draws if it's still alive
    if (isAlive()) {
      stroke(c.x, int(255. * this.depositRate));
      strokeWeight(1);
      
      // if the line is too long (because of torus world), we shorthen it
      PVector line = lastPos.copy().sub(pos);

      if (line.mag() < 4*this.stepSize) {
        line(lastPos.x, lastPos.y, pos.x, pos.y);
      }
    }
  }

  boolean isAlive()
  {
    return ! this.isTerminated;
  }

  PVector mapPositionInsideBoundingBox (PVector position) {
    PVector pos = position.copy();
    if (pos.x < this.boundingBoxUpperLeft.x) pos.x = this.boundingBoxLowerRight.x + pos.x;
    if (pos.x > boundingBoxLowerRight.x) pos.x %= (this.boundingBoxLowerRight.x -  this.boundingBoxUpperLeft.x);
    if (pos.y < this.boundingBoxUpperLeft.y) pos.y = this.boundingBoxLowerRight.y + pos.y;
    if (pos.y > boundingBoxLowerRight.y) pos.y = pos.y %= (this.boundingBoxLowerRight.y -  this.boundingBoxUpperLeft.y);
    return pos;
  }
}
