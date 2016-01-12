import java.lang.ArrayIndexOutOfBoundsException;

import java.awt.Robot; //java library that lets us take screenshots
import java.awt.AWTException;
import java.awt.event.InputEvent;
import java.awt.image.BufferedImage;
import java.awt.Rectangle;
import java.awt.Dimension;

import processing.net.*; //library for client-port

Server server; //creates object "port" of server class
Robot os; //creates object "os" of robot class
PFont f;

static int sample = 2; //increase value to reduce the number of pixels sampled

float lastR = 0; //store previous values to avoid clogging serial com
float lastG = 0;
float lastB = 0;

void setup() {
  size(200,200);
  surface.setResizable(true);
  server = new Server(this, 12345);
  f = createFont("Arial", 14, true);
  textFont(f, 14);
  fill(0);
  println(Server.ip());
  
  try {
    os = new Robot(); //standard Robot class error check
  } catch (AWTException e) {
    println("FATAL ERROR: Robot class not supported by your system!");
    exit();
  }
}

void draw()
{
  int pixel; //ARGB variable with 32 int bytes where
  //sets of 8 bytes are: Alpha, Red, Green, Blue
  float r=0;
  float g=0;
  float b=0;
  
  //get screenshot into object "screenshot" of class BufferedImage
  BufferedImage screenshot = os.createScreenCapture(new Rectangle(new Dimension(displayWidth,displayHeight)));
 
  int i=0;
  int j=0;
  
  //I skip every alternate pixel making my program 4 times faster
  for(i=0; i < displayWidth; i+=sample){
    for(j=i%2; j < displayHeight; j+=sample){
      pixel = screenshot.getRGB(i,j); //the ARGB integer has the colors of pixel (i,j)
      r = r+(int)(255&(pixel>>16)); //add up reds
      g = g+(int)(255&(pixel>>8)); //add up greens
      b = b+(int)(255&(pixel)); //add up blues
    }
  }
  int pixelCount = (displayWidth*displayHeight)/(sample*sample);
  r = r/pixelCount; //average red (remember that I skipped ever alternate pixel)
  g = g/pixelCount; //average green
  b = b/pixelCount; //average blue
 
  //Enhance Colour
  float[] rgbList = {r, g, b};
  rgbList = sort(rgbList);
  
  for(i = 0; i < 3; i++){
   if(rgbList[i] == r){ r = i; }
   else if(rgbList[i] == g){ g = i;} 
   else if(rgbList[i] == b){ b = i; }
  }
  rgbList[0] -= 8.0*(rgbList[1]-rgbList[0]);
  rgbList[2] += 8.0*(rgbList[2]-rgbList[1]);

  //cap values
  if(rgbList[0] < 0){
    rgbList[0] = 0;
  }
  if(rgbList[2] > 255){
   rgbList[2] = 255; 
  }
  r= rgbList[(int)r];
  g= rgbList[(int)g];
  b= rgbList[(int)b];
  
  //update if necessary
  if((abs(lastR - r) > 3 || abs(lastG - g) > 3 || abs(lastB - b) > 3)){
    lastR = r;
    lastG = g;
    lastB = b;
    //println(frameRate);
    background(r,g,b); //make window background average color
    text(Server.ip(), 80, 100);
    if(server.active()){
      server.write(-1); // for sync
      server.write((int)r);
      server.write((int)g);
      server.write((int)b);
      println("Sent " + (int)r + "," + (int)g + "," + (int)b);
    }else{
      println("ERROR: No Device Connected");
      println("Please connect a device and restart the application");
      text("No Device Connected!\nConnect a device and restart", 10, 100);
    }
  }
}

void serverEvent(Server server, Client client){
  println("Connect " + client.ip());
  delay(2000);
}