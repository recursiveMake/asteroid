int Z = 25;
int W = 640;
int H = 360;
Game game;


void setup() {
  size(W+Z, H+Z);
  game = new Game();
}

void draw() {
  fill(100);
  noStroke();
  rect(0,0,W+Z,H+Z);
  fill(255);
  rect(Z/2,Z/2,W,H);
  stroke(0);
  game.draw();
}

class Game {
  ArrayList<Ship> s;
  ArrayList<Rock> r;
  
  Game() {
    r = new ArrayList<Rock>();
    s = new ArrayList<Ship>();
    s.add(new Ship(W/2, H/2)); // Ship in center
  }
  
  void draw() {
    cycle(s.get(0));
    for(int i = s.get(0).b.size()-1; i >=0; i--) {
      Bullet bullet = s.get(0).b.get(i);
      cycle(bullet);
      if(!bullet.active) { s.get(0).b.remove(i); }
    }
    for(int i = r.size()-1; i >=0; i--) {
      Rock rock = r.get(i);
      cycle(rock);
      if(!rock.active) { r.remove(i); }
    }
    manage();
    checkBounds();
  }

  void manage() {
     // change v and valpha
    if(millis() % 1000 < 100) {
      s.get(0).valpha = random(-0.02, 0.02);
    }
    if(millis() % 2000 < 200) {
      s.get(0).v = random(1, 3);
    }
    if(millis() % 1000 < 100) {
      s.get(0).spawn((s.get(0).b));
    }
    if(millis() % 1000 < 10 && r.size() < 5) {
         // Spawn at random boundary
      float xpos = random(Z,W);
      float ypos = random(Z,H);
      float lr = random(0,1);
      if      (lr < 0.25){ xpos = Z; }
      else if (lr < 0.5) { xpos = W; }
      else if (lr < 0.75){ ypos = Z; }
      else               { ypos = H; }
      float sz =random(10,35);
      float spd=random(0,2);
      float angle=random(0, 2*PI);

      r.add(new Rock(xpos, ypos, sz, spd, angle)); 
    }
  } 
  
  void checkBounds() {
    // for(Rock rock : r) {
    for(int i = r.size()-1; i>=0; i--) {
      Rock rock = r.get(i);
      for(Bullet bullet : s.get(0).b) {
        if (rock.within(bullet.x, bullet.y)) {
           println("BOOM");
           rock.active = false;
           bullet.active = false; 
           if(rock.d >= 10) {rock.spawn(r);}
        }
      }
      if(rock.within(s.get(0).x, s.get(0).y)) {
        println("OUCH");        
      }
    }
  }
  
  void cycle(StellarObject obj) {
    obj.prep();
    obj.update();
    obj.display();
    obj.clean(); 
  }
  
  void stats() {
    println("SHIPS: 1, x=", s.get(0).x, ", y=", s.get(0).y, ", v=", s.get(0).v, ", a=", s.get(0).alpha);
    println("ROCKS: ", r.size());
    println("BULLETS: ", s.get(0).b.size());
  }
}

class StellarObject {
 float x, y, d=0; // center and size
 float v = 0; // velocity
 int c = 100; // color
 float alpha=0; // rotation
 float a_offset =-PI/2; //fix for rotation
 float valpha=0;
 boolean active=true;

 StellarObject(float xpos, float ypos) {
  x = xpos;
  y = ypos;
 }
 
 void update() {
  reset();
  move(); 
 }
 
 void twist(float angle) {
    translate(x,y);
    alpha += angle;
    rotate(alpha);
    translate(-x,-y);
 }
 
 void prep() {
   pushMatrix();
 }
 void clean() {
    popMatrix(); 
 }
 void display() {}
 
 void shift(float dx, float dy) {
   x += dx;
   y += dy;
 } 
 
 void move() {
   float angle = alpha+a_offset;
   shift(v*cos(angle), v*sin(angle));
   twist(valpha);
 }
 
 void reset() { // boundary conditions
  periodic();
 }
 
 void periodic() {
    if(x > W) { x = Z; }
    if(y > H) { y = Z; }
    if(x < Z) { x = W; }
    if(y < Z) { y = H; }
 } 
 
 void bounce() {
   if( x > W) {
    alpha = -alpha;
    x = W;
   }
   if (x < Z ) {
    alpha = -alpha;
    x = Z; 
   }
   if (y > H) {
    alpha = PI - alpha;
    y = H; 
   }
   if (y < Z) {
    alpha = PI - alpha;
    y = Z; 
   }
 }

 boolean within(float xpos, float ypos) {
   return within(xpos, ypos, d);
 }

 boolean within(float xpos, float ypos, float dpos) {
    if(!active) { return false; }
    return ((x-xpos)*(x-xpos) + (y-ypos)*(y-ypos) < dpos*dpos);
 }

 void spawn(ArrayList objList) {}
}

class Ship extends StellarObject {
  ArrayList<Bullet> b;

  Ship(int xpos, int ypos) {
    super(xpos, ypos);
    b = new ArrayList<Bullet>();
    d = 10;   
  }

  void display() {
   fill(c);
   triangle(x,y-d, x-d,y+d, x+d,y+d);  
  }

  void spawn(ArrayList objList) {
    objList.add(new Bullet(x, y, 4, alpha+a_offset));
  }
}

class Bullet extends StellarObject {
  Bullet(float xpos, float ypos, float vel, float angle) {
    super(xpos, ypos);
    d = 1;
    v = vel;
    c = 100;
    alpha = angle;
    a_offset = 0;
  }
  
  void reset() { // die at boundary
    if(x > W || x < Z || y > H || y < Z) {
      active = false;
    } 
  }
  
  void display() {
   fill(c);
   ellipse(x,y,2*d,2*d); 
  }
}

class Rock extends StellarObject {
 Rock(float xpos, float ypos, float size, float speed, float angle) {
   super(xpos, ypos);
   d = size;
   v = speed;
   alpha = angle;
   c=180;
 } 
 
 void reset() {
   bounce();
  }
 
 void display() {
   fill(c);
   ellipse(x,y,2*d,2*d);
 }

 void spawn(ArrayList objList) {
   float angle = random(0,2*PI);
   objList.add(new Rock(x, y, d/2, v, angle));
   objList.add(new Rock(x, y, d/2, v, -angle));
 }
}

void mousePressed() {
  game.stats();
}
