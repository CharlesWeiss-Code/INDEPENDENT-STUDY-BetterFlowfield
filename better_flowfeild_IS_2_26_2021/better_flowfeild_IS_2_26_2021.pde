// The Nature of Code
// Daniel Shiffman
// http://natureofcode.com

// Flow Field Following
// Via Reynolds: http://www.red3d.com/cwr/steer/FlowFollow.html

// Using this variable to decide whether to draw all the stuff
boolean debug = true;
ArrayList<ds> circles = new ArrayList<ds>();
int circleCount = 3;

// Flowfield object
FlowField flowfield;
// An ArrayList of vehicles
ArrayList<Vehicle> vehicles;

void setup() {
  size(640, 400);
  circles();
 // organizedCircles();
  // Make a new flow field with "resolution" of 16
  flowfield = new FlowField(5, circles, 50);
  println(flowfield.field.length);
  println(flowfield.field[0].length);
  vehicles = new ArrayList<Vehicle>();
  // Make a whole bunch of vehicles with random maxspeed and maxforce values
  for (int i = 0; i < 120; i++) {
    vehicles.add(new Vehicle(new PVector(random(width), random(height)), random(2, 6), random(0.5, 1.5)));
  }
}

void draw() {
  background(255);
  // Display the flowfield in "debug" mode
  if (debug) {
    flowfield.display(circles);
  } else {
    circleShow(circles);
  }

  // Tell all the vehicles to follow the flow field
  for (Vehicle v : vehicles) {
    v.follow(flowfield);
    v.run();
  }

  // Instructions
  fill(0);
  text("Hit space bar to toggle debugging lines.\nClick the mouse to generate a new flow field.", 10, height-20);
}


void keyPressed() {
  if (key == ' ') {
    debug = !debug;
  }
}

// Make a new flowfield
void mousePressed() {
  flowfield.init2(circles());
}

public void generateCircles() {
  for (int i = 0; i < circleCount; i++) {
    PVector a = new PVector(random(width), random(height));
    circles.add(new ds(a, width/20));
  }
}

public ArrayList<ds> circles() {
  circles.clear();
  for (int i = 0; i < circleCount; i++) {
    genStuff();
  }
  return circles;
}

public void genStuff() {
  float r = random(25, 50);
  PVector pos = new PVector(random(width), random(height));
  if (pos.x < r*3 || pos.x > width - r*3 || pos.y < r*3 || pos.y > height - r*3) {
    genStuff();
  } else {
    circles.add(new ds(pos, r));
  }
}

public void circleShow(ArrayList<ds> circles) {
  for (ds c : circles) {
    noFill();
    stroke(0);
    strokeWeight(3);
    ellipse(c.pos.x, c.pos.y, c.r*2, c.r*2);
    stroke(255, 0, 0);
    strokeWeight(3);
    ellipse(c.pos.x, c.pos.y, c.r*2+20, c.r*2+20);
  }
}

public void organizedCircles() {
  float cols = 3;
  float rows = 2;
  float r = 37.5;
  float spacingW = (width-cols*2*r)/cols+1;
  float spacingH = ((height-2*spacingW)-4*r)*3;
  float windowW = width-spacingW*2;
  float windowH = height-spacingH*2;
  float colsSpacing = windowW/cols;
  float rowsSpacing = windowH/rows;

  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      PVector pos = new PVector((i*spacingW)+spacingW, (j*spacingH) - spacingH*2);
      circles.add(new ds(pos, r));
    }
  }
}  
