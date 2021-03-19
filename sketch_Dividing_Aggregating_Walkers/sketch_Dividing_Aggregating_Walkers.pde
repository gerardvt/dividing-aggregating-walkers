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


PVector getTorusPosition (PVector position) {
  PVector pos = position.copy();
  if (pos.x < 0) pos.x = ENV_SIZE + pos.x;
  if (pos.x > ENV_SIZE) pos.x %= ENV_SIZE;
  if (pos.y < 0) pos.y = ENV_SIZE + pos.y;
  if (pos.y > ENV_SIZE) pos.y = pos.y %= ENV_SIZE;
  return pos;
}

void settings(){
  size(ENV_SIZE, ENV_SIZE);
}

void setup () {
  background(0, 0, 0);
  walkerNet = new WalkerNet (NB_INITIAL_WALKERS, DEPOSIT_RATE, STEP_SIZE, TURN_ANGLE, TURN_CHANCES);
}

void keyPressed() {
  if (key == ' ') {
    saveFrame("outputs/output-" + new java.text.SimpleDateFormat("yyyyMMdd-HHmmss").format(new java.util.Date()) + ".png");
  }  
}

void draw () {
  walkerNet.update();
}
