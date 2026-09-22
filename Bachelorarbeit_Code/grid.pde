class Grid{
  HashMap<PVector,Triangle> triangles = new HashMap<PVector,Triangle>();
  ArrayList<Builder> builders;
  ArrayList<Remover> removers;
  int totalBuilders,totalRemovers;
  int maxBuilders;
  int occupiedCells,emptiedCells;
  int occupiedCount;
  float removerSpawnProbability;
  float triangleRadius;
  int removalUsageLimit;
  int segmentCount;
  int surroundedOccupiedCount;
  int simulationLimit;
  int radius;
  int totalSegmentSize;
  String allSegmentSizes;
  ArrayList<Integer> groupSizes;
  ArrayList<ArrayList<Triangle>> segments;
  int usageValue;
  private final int id;
  int simulationStepCount;
  int builderTravelDistance;
  int removerTravelDistance;
  int totalTravelDistance;
  float meanTravelDistance;
  Grid(int initradius, float triangleRadius,int removalUsageLimit,float removerSpawnProbability,int usageValue, int simulationLimit, int id){
    this.id = id;
    this.removalUsageLimit = removalUsageLimit;
    this.removerSpawnProbability = removerSpawnProbability;
    this.simulationLimit = simulationLimit;
    this.radius = 0;
    this.triangleRadius = triangleRadius;
    this.simulationStepCount = 0;
    this.builders = new ArrayList<Builder>();
    this.removers = new ArrayList<Remover>();
    this.totalBuilders = 0;
    this.totalRemovers = 0;
    this.builderTravelDistance = 0;
    this.removerTravelDistance = 0;
    this.totalTravelDistance = 0;
    this.meanTravelDistance = 0;
    this.segmentCount = 0;
    this.occupiedCount = 0;
    this.occupiedCells = 0;
    this.emptiedCells = 0;
    this.surroundedOccupiedCount = 0;
    this.totalSegmentSize = 0;
    this.allSegmentSizes = "";
    this.groupSizes = new ArrayList<Integer>();
    this.segments = new ArrayList<ArrayList<Triangle>>();
    this.maxBuilders = 100;
    this.usageValue = usageValue;
    this.initTriangles(initradius);
  }
  
  int getID(){
    return id;
  }
  int getRemovalUsageLimit(){
    return this.removalUsageLimit;
  }
  int getUsageValue(){
    return usageValue;
  }
  int getSimulationLimit(){
    return simulationLimit;
  }
  String getSegmentSizesAsString(){
    return allSegmentSizes;
  }
  int getTotalSegmentSizes(){
    return totalSegmentSize;
  }

  int getMinSegment(){
    ArrayList<Integer> segmentSizes = new ArrayList<Integer>();
    for(ArrayList<Triangle> subseg: segments){
      segmentSizes.add(subseg.size());
    }
    return minInteger(segmentSizes);
  }
  int getMaxSegment(){
    ArrayList<Integer> segmentSizes = new ArrayList<Integer>();
    for(ArrayList<Triangle> subseg: segments){
      segmentSizes.add(subseg.size());
    }
    return maxInteger(segmentSizes);
  }
  float getMeanSegment(){
    ArrayList<Integer> segmentSizes = new ArrayList<Integer>();
    for(ArrayList<Triangle> subseg: segments){
      segmentSizes.add(subseg.size());
    }
    return meanInteger(segmentSizes);
  }
  float getStdSegment(){
    ArrayList<Integer> segmentSizes = new ArrayList<Integer>();
    for(ArrayList<Triangle> subseg: segments){
      segmentSizes.add(subseg.size());
    }
    return stdInteger(segmentSizes);
  }
  int getBuildersSize(){
    return builders.size();
  }
  int getremoversSize(){
    return removers.size();
  }
  int getSimulationSteps(){
    return this.simulationStepCount;
  }
  int getSegmentCount(){
    return this.segments.size();
  }
  int getOccupiedPlaced(){
     return occupiedCells;
  }
  int getOccupiedRemoved(){
     return emptiedCells;
  }
  float getRemoverChance(){
    return float(int(10000*removerSpawnProbability))/100;
  }
  int getBuilderTravelDistance(){
    return this.builderTravelDistance;
  }
  int getRemoverTravelDistance(){
    return this.removerTravelDistance;
  }
  int getTotalTravelDistance(){
    return this.builderTravelDistance + this.removerTravelDistance;
  }
  float getMeanTravelDistance(){
    return this.meanTravelDistance;
  }
  int getMaxDistance(){
    int max = -1;
    for (Triangle t: triangles.values()) {
      if(t.getOccupiedStatus())max = max(max,t.distanceToOrigin());
    }
    return max;
  }
  int getSurfacearea(){
    int result = 0;
    for(Triangle t: triangles.values()){
      if(t.getOccupiedStatus() && !t.getOriginStatus())result += t.getSurfacearea();
    }
    return result;
  }
  float getAverageSurfacearea(){
    if(this.getOccupiedCount() == 0) return 0;
    return float(this.getSurfacearea()) / this.getOccupiedCount();
  }
  float getAverageDistance(){
    if(this.getOccupiedCount() == 0) return 0;
    float total = 0;
    for(Triangle t: triangles.values()){
      if(t.getOccupiedStatus() && !t.getOriginStatus())total += t.distanceToOrigin();
    }
    return total/float(this.getOccupiedCount());
  }
  
  Triangle getTriangleFromCoordinates(PVector coordinates){
    return triangles.get(coordinates);
  }
  Triangle getTriangleFromCoordinates(int x, int y){
    return triangles.get(new PVector(x,y));
  }
  boolean existsTriangleFromCoordinates(PVector coordinates){
    if(triangles.containsKey(coordinates)){
      return true;
    } else return false;
  }
  boolean existsTriangleFromCoordinates(int x, int y){
    if(triangles.containsKey(new PVector(x,y))){
      return true;
    } else return false;
  }
  ArrayList<Triangle> getTriangles(){
    ArrayList<Triangle> result = new ArrayList<Triangle>();
    for(Triangle t: triangles.values()){
      if(t.getOccupiedStatus())result.add(t);
    }
    return result;
  }
  int getOccupiedCount(){
    int result = 0;
    for(Triangle t: triangles.values()){
      if(t.getOccupiedStatus() && !t.getOriginStatus())result += 1;
    }
    return result;
  }
  
  
  
  
  void initTriangles(int initradius){
    triangles.put(new PVector(0,0), new Triangle(0,0, this.triangleRadius, this.removalUsageLimit, this, 0));
    this.addLayers(initradius);
  }
  void addLayers(int amount){
    for(int i = 0; i < amount; i++){
      ArrayList<Triangle> edgeTriangles = new ArrayList<Triangle>();
      for(Triangle t : triangles.values()){
        if(t.isEdge)edgeTriangles.add(t);
      }
      for(Triangle t : edgeTriangles){
        t.addLayer(triangles);
      }
    }
    radius += amount;
  }
  void addAgent(){
    if(!this.isDone()){
      if(random(1) < this.removerSpawnProbability){
        this.removers.add(new Remover(0,0,this));
        this.totalRemovers++;
      } else{
        this.builders.add(new Builder(0,0,this));
        this.totalBuilders++;
      }
    }
  }

  
  
  
  void moveAgents(){
    if(!this.isDone()){
      simulationStepCount++;
      for(Builder b: builders){
        if(b.getCurrentDistance() > radius - 8)this.addLayers(8);
        if(!this.isDone())b.move();
      }
      for(Remover r: removers){
        if(r.getCurrentDistance() > radius - 8)this.addLayers(8);
        if(!this.isDone())r.move();
      }
    }
  }
  
  void updateUsage(){
    if(!this.isDone()){
      for (Triangle t: triangles.values()) {
        t.updateUsage(usageValue);
      }
    }
  }

  void incrementOccupiedCount(){
    occupiedCells++;
    occupiedCount++;
  }
  void decrementOccupiedCount(){
    emptiedCells++;
    if(occupiedCount > 0){
      occupiedCount--;
    } else {
      println("decrementing occupied count failed in: " + id);
    }
  }

  boolean isDone(){
    return (this.occupiedCount >= simulationLimit);
  }
  boolean existsAgents(){
    if(builders.size() == 0 && removers.size() == 0){
      return false;
    }
    return true;
  }
  void deleteDeadAgents(){
    if(this.isDone()){
      this.deleteAllAgents();
    } else if(this.existsAgents()){
      for(int j = builders.size()-1; j >= 0; j--){
        if(builders.get(j).finishedTask){
          builderTravelDistance += builders.get(j).getTravelDistance();
          builders.get(j).delete();
          builders.remove(j);
        }
      }
      for(int j = removers.size()-1; j >= 0; j--){
        if(removers.get(j).finishedTask){
          removerTravelDistance += removers.get(j).getTravelDistance();
          removers.get(j).delete();
          removers.remove(j);
        }
      }
    }
  }
  void deleteAllAgents(){
    for(Builder b: builders){
      this.builderTravelDistance += b.getTravelDistance();
      b.delete();
    }
    for(Remover r: removers){
      this.removerTravelDistance += r.getTravelDistance();
      r.delete();
    }
    builders.clear();
    removers.clear();
  }


  
  
  void calculateSegments(){
    for(Triangle t: triangles.values()){
      t.isBranching = false;
    }
    Triangle origin = this.getTriangleFromCoordinates(0,0);
    origin.calculateBranchingCells(this.getTriangles());
    origin.calculateSegments(this.getTriangles(),new ArrayList<Triangle>(),segments);
    for(int i = 0; i < segments.size(); i++){
      for(Triangle t: segments.get(i)){
        t.setSegmentID(i);
      }
    }
  }
  
  void calculateSegmentSizesAsString(){
    allSegmentSizes = "";
    if(this.segments.size() <= 0) return;
    for(int i = 0; i < this.segments.size()-1; i++){
      allSegmentSizes = allSegmentSizes.concat(this.segments.get(i).size() + ", ");
    }
    allSegmentSizes = allSegmentSizes.concat(this.segments.get(this.segments.size()-1).size() + "");
  }
  
  void calculateTotalSegmentSizes(){
    totalSegmentSize = 0;
    for(ArrayList<Triangle> subseg: this.segments){
      totalSegmentSize += subseg.size();
    }
    if(totalSegmentSize != this.getOccupiedCount())println("Error in segment calculation for grid: " + id);
  }
  void calculateTravelDistance(){
    this.totalTravelDistance = 0;
    this.meanTravelDistance = 0;
    for(Builder b: builders){
      this.builderTravelDistance += b.getTravelDistance();
    }
    for(Remover r: removers){
      this.removerTravelDistance += r.getTravelDistance();
    }
    this.totalTravelDistance = this.builderTravelDistance + this.removerTravelDistance;
    this.meanTravelDistance = float(this.builderTravelDistance)/float(this.totalBuilders);
    
  }


  void addResultToChart(CSVFile csvfile, float result){
    csvfile.addData(this.getID(),this.getRemoverChance(),this.getRemovalUsageLimit(),this.getUsageValue(),this.getSimulationLimit(),result);
  }
  void addResultToChart(CSVFile csvfile, int result){
    csvfile.addData(this.getID(),this.getRemoverChance(),this.getRemovalUsageLimit(),this.getUsageValue(),this.getSimulationLimit(),result);
  }
  
 
  void display(){
    for(Triangle t:triangles.values()){
      t.display();
    }
  }
}
