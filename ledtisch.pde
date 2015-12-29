import processing.net.*;
//import processing.io.*;

boolean ledOn = false;
PImage im;

OPC opc;
Server server;

String incomingMessage = "";
int hue = 0;
int mode = 0;
int par1 = 0;
int par2 = 0;
int par3 = 0;

//Clouds
float dx, dy;
float noiseScale=0.02;
float fractalNoise(float x, float y, float z) {
  float r = 0;
  float amp = 1.0;
  for (int octave = 0; octave < 4; octave++) {
    r += noise(x, y, z) * amp;
    amp /= 2;
    x *= 2;
    y *= 2;
    z *= 2;
  }
  return r;
}

void setup() 
{
  int zoom = 8;
  size(320, 160);
  background(100);
  server = new Server(this, 23);

  //GPIO.pinMode(4, GPIO.OUTPUT);

  // Connect to the local instance of fcserver
  opc = new OPC(this, "127.0.0.1", 7890);

  // Map one 64-LED strip to the center of the window
  opc.ledGrid(0 * 64, 32, 2, width/2.0, height * 1/9, width/34.0, height/18.0, 0.0, true); // Index, Breite, Höhe, Center_X, Center_Y, Spacing_X, Spacing_Y, Winkel, Zigzag
  opc.ledGrid(1 * 64, 32, 2, width/2.0, height * 2/9, width/34.0, height/18.0, 0.0, true); // Index, Breite, Höhe, Center_X, Center_Y, Spacing_X, Spacing_Y, Winkel, Zigzag
  opc.ledGrid(2 * 64, 32, 2, width/2.0, height * 3/9, width/34.0, height/18.0, 0.0, true); // Index, Breite, Höhe, Center_X, Center_Y, Spacing_X, Spacing_Y, Winkel, Zigzag
  opc.ledGrid(3 * 64, 32, 2, width/2.0, height * 4/9, width/34.0, height/18.0, 0.0, true); // Index, Breite, Höhe, Center_X, Center_Y, Spacing_X, Spacing_Y, Winkel, Zigzag
  opc.ledGrid(4 * 64, 32, 2, width/2.0, height * 5/9, width/34.0, height/18.0, 0.0, true); // Index, Breite, Höhe, Center_X, Center_Y, Spacing_X, Spacing_Y, Winkel, Zigzag
  opc.ledGrid(5 * 64, 32, 2, width/2.0, height * 6/9, width/34.0, height/18.0, 0.0, true); // Index, Breite, Höhe, Center_X, Center_Y, Spacing_X, Spacing_Y, Winkel, Zigzag
  opc.ledGrid(6 * 64, 32, 2, width/2.0, height * 7/9, width/34.0, height/18.0, 0.0, true); // Index, Breite, Höhe, Center_X, Center_Y, Spacing_X, Spacing_Y, Winkel, Zigzag
  opc.ledGrid(7 * 64, 32, 2, width/2.0, height * 8/9, width/34.0, height/18.0, 0.0, true); // Index, Breite, Höhe, Center_X, Center_Y, Spacing_X, Spacing_Y, Winkel, Zigzag
}







void draw() 
{
  Client client = server.available();
  
  switch (mode)
    {
      case 0:
        //GPIO.digitalWrite(4, GPIO.HIGH);  
      break;
      
      case 1:
        //GPIO.digitalWrite(4, GPIO.LOW);  
        colorMode(RGB, 255);
        background(par1, par2, par3);
        println("Typ = RGB-Festwert " + "RGB(" + par1 + "," + par2 + "," + par3 + ")");
      break;
      
      case 2:
        //GPIO.digitalWrite(4, GPIO.LOW);  
        colorMode(HSB, 255);
        frameRate(par1);
        hue++;
        if (hue >= 255) 
          { 
            hue = 0; 
          }  
        background(hue, par2, par3);
        println("Typ = RGB-Verlauf" + " Speed =" + par1 + " Hue =" + hue + " Saturation = " + par2 + " Brightness = " + par3);
      break;
      
      case 3:
        //GPIO.digitalWrite(4, GPIO.LOW);  
        colorMode(RGB, 255);
        background(0, 0, 0);
        textSize(100); // Set text size to 32
        fill(255); // Fill color white
        textAlign(CENTER);
        text("2016", 0,20, 320, 160);  // Write "LAX" at coordinate (0,40)
      break;   
        
      case 4:
        colorMode(HSB, 100);
        frameRate(100);
       long now = millis();
  float speed = 0.002;
  float angle = sin(now * 0.001);
  float z = now * 0.00008;
  float hue = now * 0.01;
  float scale = 0.005;

  dx += cos(angle) * speed;
  dy += sin(angle) * speed;

  loadPixels();
  for (int x=0; x < width; x++) {
    for (int y=0; y < height; y++) {
     
      float n = fractalNoise(dx + x*scale, dy + y*scale, z) - 0.75;
      float m = fractalNoise(dx + x*scale, dy + y*scale, z + 10.0) - 0.75;

      color c = color(
         (hue + 80.0 * m) % 100.0,
         100 - 100 * constrain(pow(3.0 * n, 3.5), 0, 0.9),
         100 * constrain(pow(3.0 * n, 1.5), 0, 0.9)
         );
      
      pixels[x + width*y] = c;
    }
  }
  updatePixels();
      break;
      
      case 5:
         im = loadImage("2016.png");
         image(im, 0, 0, 320, 160);
      break;
      case 6:
      break;
      
    } 
    
     
    


  if (client!= null) // We should only proceed if the client is not null
  {       
    incomingMessage = client.readString();         
    incomingMessage = incomingMessage.trim();
    //println( "Input:" + incomingMessage);
    int[] parameter = int(split(incomingMessage, ','));
    
    if (parameter[0]!= 0)
    {
      mode = parameter[0];
      par1 = parameter[1];
      par2 = parameter[2];
      par3 = parameter[3];
    }
    println( "Input:" + mode + "," + par1 + "," + par2 + "," + par3);
  }
}










void serverEvent(Server server, Client client) 
{
  incomingMessage = "Neuer Telnet Client verbunden: " + client.ip();
  println(incomingMessage);
  incomingMessage = "";
}