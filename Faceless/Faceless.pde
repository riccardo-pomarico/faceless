import processing.video.*;
import controlP5.*;
import oscP5.*;
import netP5.*;
import processing.sound.*;

SoundFile file1;

int num_block = 3000; // Number of words that are going to be displayed at each generation
ArrayList<String> words; // List of possible words that can be printed

long[] fitness;

Capture cam;
ControlP5 cp5;
ControlP5 cpButton;
ControlP5 cpintro;

PImage img;
PImage img_res;
PImage imgEnhanced;

color[] colorList; // Color palette of the image

PFont whoFont;

color backgroundColor = color(25, 24, 37);

boolean capture = true;
boolean runWorld = false;
int captureFrame = 0;

int imgW, imgH;

int gen = 0;

ArrayList<String> prompts = new ArrayList<String>();
int promptIndex = 0;
boolean filePlaying = false;
String promptShown;
PGraphics pg;

// Variables for the genetic algorithm for the title
PFont f; 
String target;
String answer = "";
int popmax;
int n = 0;
float mutationRate;
Population population;

World world1;
World world2;
int index_cam = 0;

// Variables used to send OSC messages
int PORT = 57120;
OscP5 oscP5;
NetAddress ip_port;

// Function used to send the OSC message
void sendEffect(float cutoff, float tempo){
    OscMessage effect = new OscMessage("/note_effect");        
    effect.add(cutoff);  
    effect.add(tempo);
    oscP5.send(effect, ip_port);
}

void setup() {
  
  oscP5 = new OscP5(this,55000);
  ip_port = new NetAddress("127.0.0.1",PORT);
  
  prompts.add("Show me who you are");
  prompts.add("Who are you");
  prompts.add("What do you do");
  prompts.add("What makes you happy");
  prompts.add("What makes you sad");
  prompts.add("What is your dream");
  prompts.add("What is your favorite word");
  prompts.add("Who do you want to be");
  prompts.add("Hold on just a moment");
  prompts.add("I am trying to understand you");
  prompts.add("You are difficult to recreate");
  prompts.add("");
  
  words = new ArrayList<String>();
  
  size(1368, 800); // For different display sizes use size(1560, 910)
  cp5 = new ControlP5(this);
  cpButton = new ControlP5(this);
  cpintro = new ControlP5(this);
  
  PFont font = createFont("Arial", 20);
  whoFont = createFont("VCR OSD Mono", 37);
  PFont buttonFont = createFont("VCR OSD Mono", 16);
    
  cp5.addTextfield("")
     .setPosition(width/2-150,height-80)
     .setSize(300,40)
     .setFont(font)
     .setFocus(true)
     .setColor(color(255,255,255))
     .setColorBackground(backgroundColor)
     .setColorActive(color(248, 6, 204))
     .hide();
  
  cpButton.addButton("captureButton")
     .setPosition(width/2 - 140/2, height/2 + 2*height/5)
     .setSize(140, 40)
     .setFont(buttonFont)
     .setColorLabel(color(25, 24, 37))
     .setColorForeground(color(169, 16, 121))
     .setColorBackground(color(248, 6, 204))
     .setLabel("Capture");
     
  cpintro.addButton("introButton")
     .setPosition(width/2 - 140/2, height/2 + 2*height/5)
     .setSize(140, 40)
     .setFont(buttonFont)
     .setColorLabel(color(25, 24, 37))
     .setColorForeground(color(169, 16, 121))
     .setColorBackground(color(248, 6, 204))
     .setLabel("I can help you");
   
  String[] cameras = Capture.list();

  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    
    for (int i = 0; i < cameras.length; i++) {
      println(i, cameras[i]);
    }
    
    cam = new Capture(this, cameras[0]);
    cam.start();
    
    imgW = cam.width;
    imgH = cam.height;
    
    file1 = new SoundFile(this,"intro.mp3");
    file1.play();
    
  }
  
  f = createFont("Retro Banker", 150, true);
  target = "faceless";
  popmax = 150;
  mutationRate = 0.01;

  // Create a population with a target phrase, mutation rate, and population max
  population = new Population(target, mutationRate, popmax);
  
}

void draw() {
  
  if (captureFrame == 1 && cam != null && cam.available()) {
    
    // It captures a frame only when the flag is active and the webcam is available
    cam.read();

    colorList = new color[cam.width*cam.height];
    img=createImage(cam.width,cam.height,RGB);
    copy2img(cam, img);
    img_res=createImage(img.width,img.height,RGB);
    copy_img(img, img_res);
    img_res.resize(img_res.width/2, img_res.height/2);
    img_res.filter(BLUR);
    takeColor(img_res);

    background(backgroundColor);
    
    capture = false;
    pg = createGraphics(img_res.width, img_res.height);
    pg.beginDraw();
    pg.endDraw();
    pg.updatePixels();
  }
  
  if (captureFrame == 2) {
    cam.stop();
    background(backgroundColor);
    promptShown = prompts.get(1);
  }
  
  // Scene 1
  if (captureFrame == 0) {
    background(backgroundColor);
  }
  
  // Scene 2
  if (img != null && promptIndex <= 7 && captureFrame > 0) {
    
    image(img, width/2-imgW/2, height/2 - imgH/2 + 50);
    
  } 
  
  // Scene 3
  else if (img != null && promptIndex >= 8) {
    
    fill(backgroundColor);
    image(img, width/4-imgW/2, height/2 - imgH/2 + 50);
    
  }
  
  // To display the initial questions
   if (promptIndex == 0){
    promptShown = prompts.get(promptIndex);
  }

  else if (promptIndex < 8) {
    
    promptShown = prompts.get(promptIndex)+"?";
    
  } 
  // To display the comments during the generations
  else if (promptIndex < 12) {
    
    promptShown = prompts.get(promptIndex);
    
    if (promptIndex > 8 && promptIndex < 11 && !filePlaying) {
      file1 = new SoundFile(this, prompts.get(promptIndex)+".mp3");
      file1.play();
    } else if (promptIndex == 11 && !filePlaying) {
      file1 = new SoundFile(this,"outro.mp3");
      file1.play();
    }
    
  }

  n++;
  
  if ((n % 2) == 0) {
    
    // Generate mating pool
    population.naturalSelection();
    
    //Create next generation
    population.generate();
    
    // Calculate fitness
    population.calcFitness();
    
    answer = population.getBest();
  }
  
  textFont(f);
  textAlign(CENTER);
  fill(248, 6, 204);
  
  textSize(100);
  text(answer, width/2, 125);
  
  textFont(whoFont);
  textAlign(CENTER);
  fill(169, 16, 121);
  text(promptShown, width/2, 200);
  
  if (runWorld){
    
    filePlaying = !filePlaying;
    
    // Get the parents for each world
    
    ArrayList<Block> parents = new ArrayList<Block>();
    parents = world1.run(parents, pg);
    parents = world2.run(parents, pg);
    
    // Display the world with the best fitness function
    
    if (world1.getFitness()<world2.getFitness()){
      world1.display(pg);
    } else {
      world2.display(pg);
    }
    gen++;
    
    // Map the cutoff and tempo to send the OSC messages
    float cutoff = map(gen, 0, 7, 0, 3);
    float tempo = map(gen, 0, 7, 0.5, 1);
    sendEffect(cutoff, tempo);
    
    world1 = new World(num_block, words, img_res.width, img_res.height, colorList, img_res, parents, gen);
    world2 = new World(num_block, words, img_res.width, img_res.height, colorList, img_res, parents, gen);
  }
  
  if (promptIndex == 8 && filePlaying) {
      file1 = new SoundFile(this, prompts.get(8)+".mp3");
      file1.play();
   }
  
  
  
  if (promptIndex >= 8 && promptIndex < 11 && filePlaying) {    
   
      promptIndex++;
      
  }
}

void controlEvent(ControlEvent theEvent) {
  
  if (theEvent.isController() && theEvent.getController().getName().equals("captureButton") && captureFrame == 1) {
    
    // When the user clicks on the capture button, the system takes a photo
    captureFrame++;
    cpButton.getController("captureButton").hide();
    cp5.getController("").setVisible(true);
    promptIndex++;
    
    file1 = new SoundFile(this, prompts.get(promptIndex)+".mp3");
    file1.play();
  } 
  
  if (theEvent.isController() && theEvent.getController().getName().equals("introButton") && captureFrame == 0) {
    
    // When the user clicks on the intro button, the application changes scene
    cpintro.getController("introButton").hide();
    cpButton.getController("captureButton").setVisible(true);
    
    captureFrame++;
    
    file1 = new SoundFile(this,"show me who you are.mp3");
    file1.play();
  }
}

void keyPressed(){
  
  if (key==ENTER && cp5.get(Textfield.class,"").getText().length()>0){
    
    words.add(cp5.get(Textfield.class,"").getText());
    
    if (promptIndex==7){
      startWorld();
      runWorld = true;
      //filePlaying = false;
    }
    
    // To avoid the scenario in which the final comments are skipped because the user has clicked 
    // enter after the seventh question
    if (promptIndex < 8) {
      
      promptIndex++;
      
      if (promptIndex < 8) {
        file1 = new SoundFile(this, prompts.get(promptIndex)+".mp3");
        file1.play();
      }
      
    } 
  }
}

void copy2img(Capture camera, PImage img) {
  img.loadPixels();
  for (int i=0; i<camera.width*camera.height; i++) {
    img.pixels[i]=camera.pixels[i];
  }
  img.updatePixels();
}

void copy2img(PGraphics pg, PImage img) {
  img.loadPixels();
  for (int i=0; i<pg.width*pg.height; i++) {
    img.pixels[i]=pg.pixels[i];
  }
  img.updatePixels();
}

void copy_img(PImage src, PImage dst) {
  dst.set(0,0,src);
}

void startWorld(){
  world1 = new World(num_block, words, img_res.width, img_res.height, colorList, img_res);
  world2 = new World(num_block, words, img_res.width, img_res.height, colorList, img_res);
}

void takeColor(PImage img) {
  int numpal=0;
  for (int x=0;x<img.width;x++){
    for (int y=0;y<img.height;y++) {
      
      color c = img.get(x,y);
      boolean exists = false;
      
      for (int n=0;n<numpal;n++) {
        if (c==colorList[n]) {
          exists = true;
          break;
        }
      }
      if (!exists) {
          colorList[numpal] = c;
          numpal++;
        }
      }
    }
  }
  
int indexOfMin(long[] arr) {
  int imax = 0;
  for (int i = 1; i < arr.length; i++) {
      if (arr[i] < arr[imax]) {
          imax = i;
      }
  }
  return imax;
}
  
long max(long[] arr) {
  int min = 0;
  for (int i = 1; i < arr.length; i++) {
      if (arr[i] > arr[min]) {
          min = i;
      }
  }
  return arr[min];
}
