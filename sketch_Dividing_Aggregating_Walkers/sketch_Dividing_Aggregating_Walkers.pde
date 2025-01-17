// the simulation settings
int ENV_SIZE = 1024;
int NB_INITIAL_WALKERS = 10;

float STEP_SIZE = 1f;
float TURN_CHANCES = 0.03;
float TURN_ANGLE = 0.4;
float DEPOSIT_RATE = 0.1;

float DIVISION_CHANCES = 0.01;
float DIVISION_ANGLE = PI / 4;
boolean DISCRETE_DIV_ANGLE = false;

float TERMINATION_THRESHOLD = 0.7;
float TERMINATION_CHANCES = DIVISION_CHANCES * 0.;

WalkerNet walkerNet;

void settings(){
  size(ENV_SIZE, ENV_SIZE);
}

void setup () {
  background(0, 0, 0);

  PVector bbUpperLeft = new PVector(ENV_SIZE/12, ENV_SIZE/12);
  PVector bbLowerRight = new PVector(ENV_SIZE-ENV_SIZE/12, ENV_SIZE-ENV_SIZE/12);
  noFill();
  stroke(255);
  rect(bbUpperLeft.x, bbUpperLeft.y, bbLowerRight.x - bbUpperLeft.x, bbLowerRight.y-bbUpperLeft.y);

  walkerNet = new WalkerNet (
      NB_INITIAL_WALKERS, DEPOSIT_RATE, STEP_SIZE, TURN_ANGLE, TURN_CHANCES,
      DIVISION_CHANCES, DIVISION_ANGLE, DISCRETE_DIV_ANGLE,
      TERMINATION_THRESHOLD, TERMINATION_CHANCES,
     bbUpperLeft, bbLowerRight);
}

void keyPressed() {
  if (key == ' ') {
    saveFrame("outputs/output-" + new java.text.SimpleDateFormat("yyyyMMdd-HHmmss").format(new java.util.Date()) + ".png");
  }  
}

boolean running = false;
void mousePressed() {
  running = !running;
}

void draw () {
  // Suspend/resume running upon mouse clicks
  if (running) {
    walkerNet.update();
  }
}
