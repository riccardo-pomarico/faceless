// Class used to define a single block which represents a single word and its position in space

class Block {
  DNA dna;
  
  Block(DNA dna_) { 
    dna = dna_;    
  }

  // Method to display
  void display(PGraphics pg) {
    
    pg.fill(dna.col);
    pg.translate(dna.position.x, dna.position.y);
    
    if (dna.rotation==1){
      pg.rotate(radians(90));
    }
    
    pg.textAlign(CENTER);
    pg.textSize(dna.dim);
    pg.text(dna.word, 0, 0);
    
    if (dna.rotation==1){
      pg.rotate(radians(-90));
    }
    
    pg.translate(-dna.position.x, -dna.position.y);
    
  }
  
  DNA returnDNA(){
    return dna;
  }
  
  // This function prints the word in an empty PGraphic and computes the pixel by pixel difference
  // with respect to the original image in the square where the word is printed. 
  // This represents the fitness function related to a single word.
  long computeFitness(PImage img, PGraphics pg){
    
    pg.beginDraw();
    pg.clear();
    pg.image(img,0,0);
    display(pg);
    
    float lower = dna.position.y + textDescent();
    float upper = lower - dna.dim;
    
    pg.endDraw();
    pg.updatePixels();
    pg.loadPixels();
    
    long fit_sum = 0;

    int j = int(dna.position.x + upper*img.width);
    if (j<0) j=0;
    
    int n = int(dna.position.x + textWidth(dna.word) + lower*img.width);
    if (n>img.pixels.length) n=img.pixels.length;

    for (int i = 0; i<n; i++){
      fit_sum += abs(img.pixels[i]-pg.pixels[i]);
    }
    
    if (n==j) return fit_sum;
    
    return fit_sum/ceil(dna.dim*textWidth(dna.word));
  }
  
  // This function prints the block on a copy of the recreated image and computes the pixel by
  // pixel difference with respect to the original image.
  // This is used to determine which block contributes better to the fitness function.
  long computeFitness(PImage img, PGraphics pg, PImage print){
    
    pg.beginDraw();
    pg.image(print,0,0);
    display(pg);
    pg.endDraw();
    pg.updatePixels();
    pg.loadPixels();
    
    long fit_sum = 0;
    
    for (int i=0; i<img.pixels.length; i++){
      fit_sum += abs(img.pixels[i]-pg.pixels[i]);
    }
    
    return fit_sum/ceil(dna.dim);
  }

}
