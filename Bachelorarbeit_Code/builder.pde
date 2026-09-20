class Builder{
  PVector coordinates;
  boolean finishedTask;
  int travelDistance;
  Grid grid;
  Triangle previous,current;
  
  Builder(int x, int y, Grid grid){
    this.coordinates = new PVector(x,y);
    this.grid = grid;
    this.current = grid.getTriangleFromCoordinates(coordinates);
    this.current.incrementBuilder();
    this.previous = grid.getTriangleFromCoordinates(coordinates);
    this.finishedTask = false;
    this.travelDistance = 0;
  }

  Builder(PVector pos, Grid grid){
    this(int(pos.x),int(pos.y),grid);
  }
  
  int getTravelDistance(){
    return this.travelDistance;
  }
  
  void delete(){
    this.current.decrementBuilder();
  }
  boolean moveToRandomFreeNeighbor(){
    ArrayList<Triangle> neighbors;
    neighbors = current.getOneNeighborNonoccupiedNeighbors();
    if(neighbors.size() > 0){
      coordinates = neighbors.get(int(random(neighbors.size()))).getCoordinates();
      this.updateCurrent();
      return true;
    } else return false;
  }
  void moveToLowestUsageNeighbor(){
    ArrayList<Triangle> neighbors;
    neighbors = current.getAllOccupiedNeighbors();
    int neighborssize = neighbors.size();
    if(neighborssize > 0){
      int minOccupiedUsage = 10000000;
      ArrayList<Triangle> minUsageTriangles = new ArrayList<Triangle>();
      for(Triangle t: neighbors){
        if(minOccupiedUsage == t.getUsageScore()){
          minUsageTriangles.add(t);
        } else if(minOccupiedUsage > t.getUsageScore()){
          minOccupiedUsage = t.getUsageScore();
          minUsageTriangles = new ArrayList<Triangle>();
          minUsageTriangles.add(t);
        }
      }
      if(minUsageTriangles.size() > 0){
        coordinates = minUsageTriangles.get(int(random(minUsageTriangles.size()))).getCoordinates();
      } else{
        println("ERROR: Minimum usage neighbor determination failed, because usage score was too high");
      }
      this.updateCurrent();
    }
  }
  
  int getCurrentDistance(){
    return current.distanceToOrigin();
  }
  
  void nextStep(){
    if(!current.getOccupiedStatus()){
      if(!current.isOccupiable() && current.getAllOccupiedNeighbors().size() > 0){
        this.moveToLowestUsageNeighbor();
        return;
      } else if(!current.isOccupiable()){
        // Otherwise the agent is lost.
        //this.hasOccupied = false;
      }
    } else {
      int neighborCount = current.getNeighborCount();
      if(neighborCount < 3){
        if(!moveToRandomFreeNeighbor()){
          this.moveToLowestUsageNeighbor();
        }
      }else {
        this.moveToLowestUsageNeighbor();
      }
    }
  }
  
  void updateCurrent(){
    this.previous = current;
    this.previous.decrementBuilder();
    this.current = grid.getTriangleFromCoordinates(coordinates);
    this.current.incrementBuilder();
  }

  void move(){
    if(!this.finishedTask){
      this.nextStep();
      this.travelDistance++;
      if(!this.finishedTask && current.isOccupiable()){
        this.current.setOccupiedStatus(true);
        this.grid.incrementOccupiedCount();
        this.finishedTask = true;
      }
    }
  }
  
}
