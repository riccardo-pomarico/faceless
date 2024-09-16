// Class used to define a collection of blocks

class World {
  PImage img;
  ArrayList<Block> blocks;
  ArrayList<Block> best;
  long[] fitness; // Array of fitness used for every single block
  int num;
  int w;
  int h;
  PGraphics pg;
  int pop_double = 5; // Create 5 times the number of blocks to be displayed
  long globalFitness; // It is used to compute the difference with respect to the original image

  // Constructor 1: generates the first worlds randomically
  World(int n, ArrayList<String> words, int wid, int hei, color[] colorList, PImage img_) {
    
    blocks = new ArrayList<Block>(); // Components of the world
    best = new ArrayList<Block>(); // Used to display the blocks
    img=img_; // Image to copy
    num=n*pop_double; // Number of components to generate
    w=wid; // Width of the image
    h=hei; // Height of the image
    pg = createGraphics(w, h); // PGraphic to compute fitness function
    fitness = new long[num];
    
    for (int i = 0; i < num; i++) {
      DNA dna = new DNA(words, w, h, colorList, 1); 
      blocks.add(new Block(dna));
      fitness[i] = blocks.get(i).computeFitness(img, pg);
    }
    
    pg.loadPixels();
    pg.beginDraw();
    pg.clear();
    int j;
    long maxF = max(fitness);
    
    // It prints the best blocks on the PGraphic
    for (int i = 0; i<num/pop_double; i++) {
      j = indexOfMin(fitness);
      Block b = blocks.get(j);
      best.add(b);
      fitness[j]=maxF;
      b.display(pg);
    }
    
    pg.endDraw();
    pg.updatePixels();    
  }
  
  //Constructor 2: generates worlds based on the best fit blocks from the previous generation
  World(int n, ArrayList<String> words, int wid, int hei, color[] colorList, PImage img_, ArrayList<Block> parents, int gen) {
    
    blocks = new ArrayList<Block>(); // Components of the world
    best = new ArrayList<Block>(); // Used to display the blocks
    img=img_; // Image to copy
    num=n*pop_double; // Number of components to generate
    w=wid; // Width of the image
    h=hei; // Height of the image
    pg = createGraphics(w, h); // PGraphic to compute fitness function
    fitness = new long[num];
    
    for (int i = 0; i < num; i++) {
      
      // Random mutation
      if (random(1)<0.001) {
        DNA dna = new DNA(words, w, h, colorList, gen);
        blocks.add(new Block(dna));
        fitness[i] = blocks.get(i).computeFitness(img, pg);
      }
      // Generate similar to parent
      else {
        DNA dna = new DNA(parents.get(int(random(parents.size()))).returnDNA(), gen);
        blocks.add(new Block(dna));
        fitness[i] = blocks.get(i).computeFitness(img, pg);
      }
    
    }
    
    pg.loadPixels();
    pg.beginDraw();
    pg.clear();
    int j;
    long maxF = max(fitness);
    
    // It prints the best blocks on the PGraphic
    for (int i = 0; i<num/pop_double; i++) {
      j = indexOfMin(fitness);
      Block b = blocks.get(j);
      best.add(b);
      fitness[j]=maxF;
      b.display(pg);
    }
    
    pg.endDraw();
    pg.updatePixels();
    
  }
  
  // It adds parents to the pool, computes global fitness
  ArrayList<Block> run(ArrayList<Block> parents, PGraphics graphic) {
  
    // It creates an image to copy the graphic 
    PImage print = createImage(w,h,RGB);
    copy2img(graphic, print);
    
    // For each block compute the fitness if it was copied onto the image
    for (int i = 0; i < num; i++) { 
      Block b = blocks.get(i);
      fitness[i] = b.computeFitness(img, pg, print);
    }
    
    int j;
    long maxF = max(fitness);
    globalFitness = 0;
   
    // It adds the best blocks to the parents
    for (int i = 0; i<num/pop_double; i++) { 
    
      j = indexOfMin(fitness);
      
      Block b = blocks.get(j);
      parents.add(b);
      
      globalFitness+=fitness[j];
      fitness[j]=maxF;
      
    }
    
    // Global fitness is scaled with the dimensions of the image
    globalFitness = globalFitness/(img.width*img.height*255*3);
    println(globalFitness); // Print used to test
       
    return parents;
  }
  
  void display(PGraphics graphic){
    
    graphic.loadPixels();
    graphic.beginDraw();
    
    // Write the best blocks onto the graphic and add them to the parents
    for (int i = 0; i<num/pop_double; i++) { 
      Block b = best.get(i);
      b.display(graphic);
    }
    
    graphic.endDraw();
    graphic.updatePixels();
    
    PImage print = new PImage(w, h, RGB);
    
    // Copy the PGraphic into an image and print it
    copy2img(graphic, print);
    
    print.resize(w*2, h*2);
    image(print, 3*width/4-print.width/2, height/2-print.height/2+50);
  }
  
  long getFitness(){
    return globalFitness;
  }
 
}
