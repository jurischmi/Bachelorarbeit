class Remover{
  PVector coordinates;
  boolean finishedTask;
  boolean canRemove;
  int travelDistance;
  Grid grid;
  Triangle previous,current;
  
  Remover(int x, int y, Grid grid){
    this.coordinates = new PVector(x,y);
    this.grid = grid;
    this.current = this.grid.getTriangleFromCoordinates(coordinates);
    this.current.incrementRemover();
    this.previous = this.grid.getTriangleFromCoordinates(coordinates);
    this.finishedTask = false;
    this.travelDistance = 0;
    this.canRemove = true;  // set to false for neutral-agent condition
  }

  Remover(PVector pos, Grid grid){
    this(int(pos.x),int(pos.y),grid);
  }
  
  int getTravelDistance(){
    return this.travelDistance;
  }
  
  void delete(){
    this.current.decrementRemover();
  }
  void moveToLowestUsageNeighbor(){
    ArrayList<Triangle> neighbors;
    neighbors = current.getAllOccupiedNeighbors();
    int neighborssize = neighbors.size();
    if(neighborssize > 0){
      int minUsage = 1000000;
      ArrayList<Triangle> minUsageTriangles = new ArrayList<Triangle>();
      for(Triangle t: neighbors){
        if(minUsage == t.getUsageScore()){
          minUsageTriangles.add(t);
        } else if(minUsage > t.getUsageScore()){
          minUsage = t.getUsageScore();
          minUsageTriangles = new ArrayList<Triangle>();
          minUsageTriangles.add(t);
        }
      }
      if(minUsageTriangles.size() > 0){
        coordinates = minUsageTriangles.get(int(random(minUsageTriangles.size()))).getCoordinates();
      } else{
        println("ERROR: Minumum usage neighbor determination failed, because usage score was to high");
      }
      this.updateCurrent();
    }
  }
  void removeRandomRemovableNeighbor(){
    ArrayList<Triangle> neighbors;
    neighbors = current.getRemovableNeighbors();
    coordinates = neighbors.get(int(random(neighbors.size()))).getCoordinates();
    this.updateCurrent();
  }
  
  void nextStep(){
    if(!current.getOccupiedStatus()){
      if(!current.isRemovable() && current.getAllOccupiedNeighbors().size() > 0){
        this.moveToLowestUsageNeighbor();
        return;
      } else if(!current.isRemovable()){
        // Otherwise the agent is lost.
        //this.hasOccupied = true;
      }
    } else {
      int removableNeighborsSize = current.getRemovableNeighbors().size();
      if(removableNeighborsSize == 0){
        this.moveToLowestUsageNeighbor();
      } else {
        this.removeRandomRemovableNeighbor();
      }
    }
  }
  
  void updateCurrent(){
    this.previous = current;
    this.previous.decrementRemover();
    this.current = grid.getTriangleFromCoordinates(coordinates);
    this.current.incrementRemover();
  }

  int getCurrentDistance(){
    return current.distanceToOrigin();
  }
  void move(){
    if(!this.finishedTask){
      this.nextStep();
      this.travelDistance++;
      if(!this.finishedTask && current.isRemovable()){
        if(this.canRemove)this.current.setOccupiedStatus(false);
        this.grid.decrementOccupiedCount();
        this.finishedTask = true;
      }   
    }
     
  }
  
}
