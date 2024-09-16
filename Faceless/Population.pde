// A class to describe a population of virtual organisms
// In this case, each organism is just an instance of a DNA object

class Population {

  float mutationRate;   
  DNAText[] population; // Array to hold the current population
  ArrayList<DNAText> matingPool; // ArrayList which we will use for our "mating pool"
  String target; 
  int generations; 
  boolean finished; 
  int perfectScore;

  Population(String p, float m, int num) {
    
    target = p;
    mutationRate = m;
    population = new DNAText[num];
    
    for (int i = 0; i < population.length; i++) {
      population[i] = new DNAText(target.length());
    }
    
    calcFitness();
    matingPool = new ArrayList<DNAText>();
    finished = false;
    generations = 0;
    perfectScore = int(pow(2,target.length()));
  }

  // Fill our fitness array with a value for every member of the population
  void calcFitness() {
    for (int i = 0; i < population.length; i++) {
      population[i].fitness(target);
    }
  }

  // Generate a mating pool
  void naturalSelection() {
    
    // Clear the ArrayList
    matingPool.clear();

    float maxFitness = 0;
    
    for (int i = 0; i < population.length; i++) {
      if (population[i].fitness > maxFitness) {
        maxFitness = population[i].fitness;
      }
    }

    // Based on fitness, each member will get added to the mating pool a certain number of times
    // a higher fitness = more entries to mating pool = more likely to be picked as a parent
    // a lower fitness = fewer entries to mating pool = less likely to be picked as a parent
    for (int i = 0; i < population.length; i++) {
      
      float fitness = map(population[i].fitness,0,maxFitness,0,1);
      int n = int(fitness * 100); // Arbitrary multiplier
      
      // Pick two random numbers
      for (int j = 0; j < n; j++) { 
        matingPool.add(population[i]);
      }
    }
  }

  // Create a new generation
  void generate() {
    
    // Refill the population with childrens from the mating pool
    for (int i = 0; i < population.length; i++) {
      int a = int(random(matingPool.size()));
      int b = int(random(matingPool.size()));
      
      DNAText partnerA = matingPool.get(a);
      DNAText partnerB = matingPool.get(b);
      DNAText child = partnerA.crossover(partnerB);
      child.mutate(mutationRate);
      population[i] = child;
    }
    
    generations++;
  }

  // Compute the current "most fit" member of the population
  String getBest() {
    
    float worldrecord = 0.0f;
    int index = 0;
    
    for (int i = 0; i < population.length; i++) {
      if (population[i].fitness > worldrecord) {
        index = i;
        worldrecord = population[i].fitness;
      }
    }

    if (worldrecord == perfectScore ) finished = true;
    
    return population[index].getPhrase();
  }

  boolean finished() {
    return finished;
  }

  int getGenerations() {
    return generations;
  }

  // Compute average fitness for the population
  float getAverageFitness() {
    
    float total = 0;
    
    for (int i = 0; i < population.length; i++) {
      total += population[i].fitness;
    }
    
    return total / (population.length);
  }

  String allPhrases() {
    
    String everything = "";
    int displayLimit = min(population.length,50);
    
    for (int i = 0; i < displayLimit; i++) {
      everything += population[i].getPhrase() + "\n";
    }
    
    return everything;
  }
}
