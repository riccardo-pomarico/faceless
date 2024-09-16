// Class used to contain the information about the blocks

class DNA {

  // The genetic sequence
  PVector position;
  float dim;
  color col;
  float rotation;
  String word;
  PFont font;
  
  // Constructor (makes a random DNA)
  DNA(ArrayList<String> words, int w, int h, color[] colorList, int gen) {
    
    position = new PVector(random(w), random(h));
    col = colorList[int(random(colorList.length))];
    word = words.get(int(random(words.size())));
    
    // The words tend to decrease in size as the generations go on
    if (gen < 6) {
      dim = random(80, 90)/(word.length()+gen);
    } else {
      dim = random(10, 20)/word.length();
    }
    
    rotation = round(random(1));
  }
  
  // Constructor when inheriting from a parent
  DNA(DNA parent, int gen) {
    position = new PVector(parent.position.x+random(-20, 20), parent.position.y+random(-20,20));
    col = parent.col;
    word = parent.word;
    dim = parent.dim+random(-gen, 0);
    
    if (dim<=0) { 
      dim = 0.01;
    }
    
    rotation = parent.rotation;
  }
  
}
