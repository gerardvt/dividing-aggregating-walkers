class WalkerNet {
  float depositRate;
  float stepSize;
  float turnAngle;
  float turnChance;
  float divisionChances;
  float divisionAngle;
  boolean discreteDivisionAngle;
  float terminationThreshold;
  float terminationChances;
  int numWalkers;
  PVector boundingBoxUpperLeft;
  PVector boundingBoxLowerRight;

  ArrayList<Walker> walkers;

  public WalkerNet (
    int numWalkers, float depositRate, float stepSize, float turnAngle, float turnChance,
    float divisionChances, float divisionAngle, boolean discreteDivisionAngle,
    float terminationThreshold, float terminationChances,
    PVector boundingBoxUpperLeft, PVector boundingBoxLowerRight
) {

    this.numWalkers = numWalkers;
    this.depositRate = depositRate;
    this.stepSize = stepSize;
    this.turnAngle = turnAngle;
    this.turnChance = turnChance;
    this.divisionChances = divisionChances;
    this.divisionAngle = divisionAngle;
    this.discreteDivisionAngle = discreteDivisionAngle;
    this.terminationThreshold = terminationThreshold;
    this.terminationChances = terminationChances;
    this.boundingBoxUpperLeft = boundingBoxUpperLeft.copy();
    this.boundingBoxLowerRight = boundingBoxLowerRight.copy();

    this.walkers = new ArrayList<Walker>();

    for (int i = 0; i < this.numWalkers; i++) {
        float da = float(i) / float(this.numWalkers) * TWO_PI;
        float distCenter = float(ENV_SIZE) * .25;
        float x = cos(da) * distCenter + ENV_SIZE*.5;
        float y = sin(da) * distCenter + ENV_SIZE*.5;

        PVector pos = new PVector(x,y);
        pos = mapPositionInsideBoundingBox(pos);
        x = pos.x;
        y = pos.y;


        float ang = random(0, TWO_PI);// da - PI;
        this.walkers.add(new Walker(x, y, ang, this.depositRate, this.stepSize, this.turnAngle, this.turnChance, this.terminationChances,
                                    this.boundingBoxUpperLeft, this.boundingBoxLowerRight,
                                    new PVector (random(0,1) * 255, random(0,1) * 255, random(0,1) * 255)));
    }
  }
  
  void update () {
    ArrayList<Walker> newWalkers = new ArrayList<Walker>();

    for (Walker w : this.walkers) {
        // 1. walking step
        w.update();

        // 2. division step
        float r = random(0, 1);
        if (r < this.divisionChances) {
        float nAngle = w.ang + (this.discreteDivisionAngle ? round(random(0, 1))*2-1 : random(-1, 1)) * this.divisionAngle;
        Walker nWalker = new Walker(w.pos.x, w.pos.y, nAngle, this.depositRate, this.stepSize, this.turnAngle, this.turnChance, this.terminationChances,
                            this.boundingBoxUpperLeft, this.boundingBoxLowerRight,
                            new PVector (random(0,1) * 255, random(0,1) * 255, random(0,1) * 255));
        newWalkers.add(nWalker);
        }

        w.draw();
    }

    // adds the new walkers to the active list
    for (Walker w : newWalkers) {
        this.walkers.add(w);
    }


    loadPixels();
    for (int i = walkers.size()-1; i >= 0; i--) {
        Walker w = walkers.get(i);

        // Remove dead walkers from walkers list
        if (!w.isAlive()) {
          walkers.remove(i);
          continue;
        }

        // turn the walker coordinates into an index to sample the environment color
        // to do that we compute the "next" walker position
        PVector dir = new PVector(cos(w.ang), sin(w.ang));
        PVector npos = w.pos.copy().add(dir.mult(this.stepSize));
        npos = mapPositionInsideBoundingBox(npos);

        // sample aggregate color
        int idx = int(npos.x) + int(npos.y) * ENV_SIZE;
        if (idx > ENV_SIZE*ENV_SIZE) continue;
        int pixel = pixels[idx];
        float red = red(pixel);
        
        // kill the walker if it will run on some aggregate
        if (red > this.terminationThreshold * 255) {
        // draw its last step to fill the gap
        w.lastPos = w.pos;
        w.pos = npos;
        w.draw();
        this.walkers.remove(i);
        }
    }
  }

  PVector mapPositionInsideBoundingBox (PVector position) {
    PVector pos = position.copy();

    // If position falls outside bounding box, wrap around the x or y axis to com baack
    // inside the bounding box on the other side.
    if (pos.x < this.boundingBoxUpperLeft.x) pos.x = this.boundingBoxLowerRight.x + pos.x;
    if (pos.x > boundingBoxLowerRight.x) pos.x %= (this.boundingBoxLowerRight.x -  this.boundingBoxUpperLeft.x);
    if (pos.y < this.boundingBoxUpperLeft.y) pos.y = this.boundingBoxLowerRight.y + pos.y;
    if (pos.y > boundingBoxLowerRight.y) pos.y = pos.y %= (this.boundingBoxLowerRight.y -  this.boundingBoxUpperLeft.y);
    return pos;
  }

}