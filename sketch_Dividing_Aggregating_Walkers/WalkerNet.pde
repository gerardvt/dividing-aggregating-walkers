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

  ArrayList<Walker> walkers;

  public WalkerNet (
    int numWalkers, float depositRate, float stepSize, float turnAngle, float turnChance,
    float divisionChances, float divisionAngle, boolean discreteDivisionAngle,
    float terminationThreshold, float terminationChances
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

    this.walkers = new ArrayList<Walker>();

    for (int i = 0; i < this.numWalkers; i++) {
        float da = float(i) / float(this.numWalkers) * TWO_PI;
        float distCenter = float(ENV_SIZE) * .25;
        float x = cos(da) * distCenter + ENV_SIZE*.5;
        float y = sin(da) * distCenter + ENV_SIZE*.5;

        float ang = random(0, TWO_PI);// da - PI;
        this.walkers.add(new Walker(x, y, ang, this.depositRate, this.stepSize, this.turnAngle, this.turnChance));
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
        Walker nWalker = new Walker(w.pos.x, w.pos.y, nAngle, this.depositRate, this.stepSize, this.turnAngle, this.turnChance);
        newWalkers.add(nWalker);
        }

        w.draw();
    }

    // adds the new walkers to the active list
    for (Walker w : newWalkers) {
        this.walkers.add(w);
    }

    // checks for dead walkers
    loadPixels();
    for (int i = walkers.size()-1; i >= 0; i--) {
        Walker w = walkers.get(i);

        float r = random(0, 1);
        if (r < this.terminationChances) {
        walkers.remove(i);
        continue;
        }

        // turn the walker coordinates into an index to sample the environment color
        // to do that we compute the "next" walker position
        PVector dir = new PVector(cos(w.ang), sin(w.ang));
        PVector npos = w.pos.copy().add(dir.mult(2 * this.stepSize));
        npos = getTorusPosition(npos);

        // sample aggregate color
        int idx = int(npos.x) + int(npos.y) * ENV_SIZE;
        if (idx > ENV_SIZE*ENV_SIZE) continue;
        int pixel = pixels[idx];
        float red = red(pixel);
        
        // kill the walker if it will run on some aggregate
        if (red > this.terminationThreshold * 255) {
        this.walkers.remove(i);
        // draw its last step to fill the gap
        w.lastPos = w.pos;
        w.pos = npos;
        w.draw();
        }
    }
  }
}