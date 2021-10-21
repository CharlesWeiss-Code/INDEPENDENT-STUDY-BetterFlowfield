// The Nature of Code
// Daniel Shiffman
// http://natureofcode.com

// Flow Field Following

class FlowField {

  // A flow field is a two dimensional array of PVectors
  PVector[][] field;
  int cols, rows; // Columns and Rows
  int resolution; // How large is each "cell" of the flow field
  int threshold;
  FlowField(int r) {
    resolution = r;
    // Determine the number of columns and rows based on sketch's width and height
    cols = width/resolution;
    rows = height/resolution;
    field = new PVector[cols][rows];
    init();
  }

  FlowField(int r, ArrayList<ds> circles, int threshold) {
    resolution = r;
    // Determine the number of columns and rows based on sketch's width and height
    cols = width/resolution;
    rows = height/resolution;
    field = new PVector[cols][rows];
    this.threshold = threshold;
    init2(circles);
  }


  void init() {
    // Reseed noise so we get a new flow field every time
    noiseSeed((int)random(10000));
    float xoff = 0;
    for (int i = 0; i < cols; i++) {
      float yoff = 0;
      for (int j = 0; j < rows; j++) {
        float theta = map(noise(xoff, yoff), 0, 1, 0, TWO_PI);
        // Polar to cartesian coordinate transformation to get x and y components of the vector
        field[i][j] = new PVector(random(0.5, 4)*cos(theta), random(0.5, 2)*sin(theta));
        yoff += 0.1;
      }
      xoff += 0.1;
    }
  }

  void init2(ArrayList<ds> circles) {
    // Reseed noise so we get a new flow field every time
    //noiseSeed((int)random(10000));
    resetVecs();
    generateFlow(circles);
    fillInsidesOfCircles(circles);
  }
  // Draw every vector
  void display(ArrayList<ds> circles) {
    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        //push();
        //translate(i*resolution,j*resolution);
        //rotate(field[i][j].heading());
        //line(0,resolution/2,resolution,resolution/2);
        //pop();
        push();
        drawVector(field[i][j], i*resolution, j*resolution, 2.0);
        pop();
      }
    }
    for (ds c : circles) {
      push();
      noFill();
      stroke(0);
      strokeWeight(3);
      ellipse(c.pos.x, c.pos.y, c.r*2, c.r*2);
      stroke(255, 0, 0);
      ellipse(c.pos.x, c.pos.y, c.r*2+threshold, c.r*2+threshold);
      pop();
    }
  }

  // Renders a vector object 'v' as an arrow and a location 'x,y'
  void drawVector(PVector v, float x, float y, float scayl) {
    pushMatrix();
    push();
    float arrowsize = 4;
    // Translate to location to render vector
    translate(x, y);
    if (v.mag() > 500) {
      stroke(0, 0, 255);
    } else {
      stroke(0, 100);
    }
    // Call vector heading function to get direction (note that pointing up is a heading of 0) and rotate
    rotate(v.heading2D());
    // Calculate length of vector & scale it to be bigger or smaller if necessary
    float len = resolution;
    // Draw three lines to make an arrow (draw pointing up since we've rotate to the proper direction)
    line(0, 0, len, 0);
    //line(len,0,len-arrowsize,+arrowsize/2);
    //line(len,0,len-arrowsize,-arrowsize/2);
    pop();
    popMatrix();
  }

  PVector lookup(PVector lookup) {
    int column = int(constrain(lookup.x/resolution, 0, cols-1));
    int row = int(constrain(lookup.y/resolution, 0, rows-1));
    return field[column][row].get();
  }

  public void resetVecs() {
    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        field[i][j] = new PVector(0, 0);
      }
    }
  }




  public void generateFlow(ArrayList<ds> circ) {
    for (int k = 0; k < circ.size(); k++) {
      int xMid = int(circ.get(k).pos.x);
      int yMid = int(circ.get(k).pos.y);
      float xoff = 0;
      int xCoor = 0;
      int yCoor = 0;
      float R = circ.get(k).r;
      float radius = 0;
      float theta = 0;
      float Vr = 0;
      float Vtheta = 0;
      float angleV = 0;
      float Vx = 0;
      float Vy = 0;
      float Vmag = 0;
      float U = resolution -2;
      for (int i = 0; i < cols; i++) {
        float yoff = 0;
        for (int j = 0; j < rows; j++) {
          // float theta = map(noise(xoff,yoff),0,1,0,TWO_PI);
          // Polar to cartesian coordinate transformation to get x and y components of the vector
          xCoor = i*resolution - xMid;
          yCoor = j*resolution - yMid;
          radius = sqrt(pow(xCoor, 2)+pow(yCoor, 2));
          if (xCoor !=0) {
            theta = atan((1.0*yCoor)/xCoor);
            if (xCoor < 0)
            {
              theta = theta + 3.1415;
            }
          } else 
          {  
            if (yCoor >0) {
              theta = 1*3.1415/2;
            } else {
              theta = 3*3.1415/2;
            }
          }
          if (radius > R) {
            Vr = U*(1-pow(R, 2)/pow(radius, 2))*cos(theta);
            Vtheta = -1*U*(1+pow(R, 2)/pow(radius, 2))*sin(theta);
            Vmag = sqrt(pow(Vr, 2)+pow(Vtheta, 2));
            angleV = atan(Vr/Vtheta);

            Vx =Vmag*cos(theta+-1*angleV+3.1415/2);

            Vy =Vmag*sin((theta+-1*angleV+3.1415/2));
            PVector spot = new PVector(i*resolution, j*resolution);
            PVector v = new PVector(Vx, Vy).setMag(1000);
            if (yCoor < 0) {  
              if (PVector.dist(spot, circles.get(k).pos) > circles.get(k).r  && PVector.dist(spot, circles.get(k).pos) < circles.get(k).r + threshold/2) {
                field[i][j].add(v);
              } else {
                field[i][j].add(v.normalize());
              }
            } else {
              PVector oppV = new PVector(-1*Vx, -1*Vy).setMag(1000);
              if (PVector.dist(spot, circles.get(k).pos) > circles.get(k).r  && PVector.dist(spot, circles.get(k).pos) < circles.get(k).r + threshold/2) {
                field[i][j].add(oppV);
              } else {
                field[i][j].add(v.normalize());
              }
            }
          } 
          yoff += 0.1;
        }
        xoff += 0.1;
      }
    }
  }

  public void fillInsidesOfCircles(ArrayList<ds> circles) {
    for (ds c : circles) {
      for (float i = 1; i < c.r; i+=.25) {
        for (float j = 0; j < TWO_PI; j+=.125) {
          int x = int(c.pos.x/resolution) + int(i*cos(j)/resolution);
          int y = int(c.pos.y/resolution) + int(i*sin(j)/resolution);
          
          int goodX = constrain(x,0,field.length-1);
          int goodY = constrain(y,0,field[0].length-1);
           

          PVector v = new PVector(i*cos(j), i*(sin(j))).setMag(10);
          field[goodX][goodY].add(v);
        }
      }
    }
  }
}
