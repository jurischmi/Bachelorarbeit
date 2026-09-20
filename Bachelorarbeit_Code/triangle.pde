class Triangle{
  PVector center;
  Grid grid;
  int xCoord,yCoord;
  float radius;
  boolean upright;
  int builderCount;
  int removerCount;
  int segmentID;
  boolean isOccupied;
  boolean isOrigin;
  boolean isBranching;
  //boolean isCovered;
  boolean isEdge;
  color displayColor;
  int stepsFromOrigin;
  int usageScore;
  int removalUsageLimit;
  int branchSizeLimit;
  Triangle left;
  Triangle right;
  Triangle above;
  Triangle below;
  
  
  Triangle(int xCoordinate, int yCoordinate, float radius,int removalUsageLimit,Grid g,int stepsFromOrigin){
    this.grid = g;
    this.removalUsageLimit = removalUsageLimit;
    this.stepsFromOrigin = stepsFromOrigin;
    this.segmentID = -1;
    PVector position = positionFromCoord(xCoordinate,yCoordinate,radius);
    center = new PVector(position.x,position.y);
    xCoord = xCoordinate;
    yCoord = yCoordinate;
    this.upright = boolean(int(position.z));
    this.builderCount = 0;
    this.removerCount = 0;
    this.isOrigin = false;
    this.isBranching = false;
    this.isEdge = true;
    this.displayColor = color(255,0,255);
    this.radius = radius;
    if(xCoordinate == 0 && yCoordinate == 0){
      this.isOccupied = true;
      this.isOrigin = true;
    }
    this.usageScore = 0;
    this.branchSizeLimit = 3;
  }
  boolean getOccupiedStatus(){
    return this.isOccupied;
  }
  void setOccupiedStatus(boolean value){
    this.isOccupied = value;
  }
  boolean getOriginStatus(){
    return this.isOrigin;
  }
  void setOriginStatus(boolean value){
    this.isOrigin = value;
  }
  int getRemovalUsageLimit(){
    return this.removalUsageLimit;
  }
  int getUsageScore(){
    return usageScore;
  }
  PVector getCoordinates(){
    return new PVector(xCoord,yCoord);
  }
  void setSegmentID(int ID){
    if(this.segmentID != -1)println("Triangle already has the segment-ID: " + segmentID + ". Has now been changed to this ID: " + ID);
    this.segmentID = ID;
  }
  int getSurfacearea(){
    return 3-this.getNeighborCount();
  }
  int distanceToOrigin(){
    return this.stepsFromOrigin;
  }
  
  void incrementBuilder(){
    builderCount++;
  }
  void decrementBuilder(){
    if(builderCount > 0){
      builderCount--;
    } else println("Tried to remove agent without agent being there");
  }
  void incrementRemover(){
    removerCount++;
  }
  void decrementRemover(){
    if(removerCount > 0){
      removerCount--;
    } else println("Tried to remove remover-agent without agent being there");
  }
  
  void addLayer(HashMap<PVector,Triangle> triangles){
    if(this.isEdge){
      if(grid.existsTriangleFromCoordinates(new PVector(this.xCoord-1,this.yCoord))){
        left = grid.getTriangleFromCoordinates(new PVector(this.xCoord-1,this.yCoord));
        left.right = this;
        if(left.distanceToOrigin() > this.stepsFromOrigin + 1)println("Initialization of distance went wront!");
      } else {
        triangles.put(new PVector(this.xCoord-1,this.yCoord), new Triangle(this.xCoord-1,this.yCoord, this.radius, this.removalUsageLimit, this.grid, stepsFromOrigin+1));
        left = grid.getTriangleFromCoordinates(new PVector(this.xCoord-1,this.yCoord));
        left.right = this;
      }
      if(grid.existsTriangleFromCoordinates(new PVector(this.xCoord+1,this.yCoord))){
        right = grid.getTriangleFromCoordinates(new PVector(this.xCoord+1,this.yCoord));
        right.left = this;
        if(right.distanceToOrigin() > this.stepsFromOrigin + 1)println("Initialization of distance went wrong!");
      } else {
        triangles.put(new PVector(this.xCoord+1,this.yCoord), new Triangle(this.xCoord+1,this.yCoord, this.radius, this.removalUsageLimit, this.grid, stepsFromOrigin+1));
        right = grid.getTriangleFromCoordinates(new PVector(this.xCoord+1,this.yCoord));
        right.left = this;
      }

      if(grid.existsTriangleFromCoordinates(new PVector(xCoord,yCoord+1))){
        below = grid.getTriangleFromCoordinates(new PVector(xCoord,yCoord+1));
        below.above = this;
        if(below.distanceToOrigin() > this.stepsFromOrigin + 1)println("Initialization of distance went wront!");
      } else {
        if(this.upright){
          triangles.put(new PVector(xCoord,yCoord+1), new Triangle(xCoord,yCoord+1, this.radius, this.removalUsageLimit, this.grid, stepsFromOrigin+1));
          below = grid.getTriangleFromCoordinates(new PVector(xCoord,yCoord+1));
          below.above = this;
        }
      }
      if(grid.existsTriangleFromCoordinates(new PVector(xCoord,yCoord-1))){
        above = grid.getTriangleFromCoordinates(new PVector(xCoord,yCoord-1));
        above.below = this;
        if(above.distanceToOrigin() > this.stepsFromOrigin + 1)println("Initialization of distance went wront!");
      } else {
        if(!this.upright){
          triangles.put(new PVector(xCoord,yCoord-1), new Triangle(xCoord,yCoord-1, this.radius, this.removalUsageLimit, this.grid, stepsFromOrigin+1));
          above = grid.getTriangleFromCoordinates(new PVector(xCoord,yCoord-1));
          above.below = this;
        }
      }
      this.isEdge = false;
    }
  }
  
  
  
  
  ArrayList<Triangle> getAllOccupiedNeighbors(){
    ArrayList<Triangle> neighbors = new ArrayList<Triangle>();
    if(left != null && left.isOccupied)neighbors.add(left);
    if(right != null && right.isOccupied)neighbors.add(right);
    if(this.upright){
      if(below != null && below.isOccupied)neighbors.add(below);
    } else {
      if(above != null && above.isOccupied)neighbors.add(above);
    }
    return neighbors;
  }
  ArrayList<Triangle> getRemovableNeighbors(){
    ArrayList<Triangle> neighbors = new ArrayList<Triangle>();
    if(left != null && left.isRemovable())neighbors.add(left);
    if(right != null && right.isRemovable())neighbors.add(right);
    if(this.upright){
      if(below != null && below.isRemovable())neighbors.add(below);
    } else {
      if(above != null && above.isRemovable())neighbors.add(above);
    }
    return neighbors;
  }
  ArrayList<Triangle> getOccupiedNeighbors(){
    ArrayList<Triangle> neighbors = new ArrayList<Triangle>();
    if(left != null && left.isOccupied && !left.isOrigin)neighbors.add(left);
    if(right != null && right.isOccupied && !right.isOrigin)neighbors.add(right);
    if(this.upright){
      if(below != null && below.isOccupied && !below.isOrigin)neighbors.add(below);
    } else {
      if(above != null && above.isOccupied && !above.isOrigin)neighbors.add(above);
    }
    return neighbors;
  }
  ArrayList<Triangle> getOccupiedNeighbors(ArrayList<Triangle> subsection){
    ArrayList<Triangle> neighbors = new ArrayList<Triangle>();
    if(left != null && left.isOccupied && !left.isOrigin && subsection.contains(left))neighbors.add(left);
    if(right != null && right.isOccupied && !right.isOrigin && subsection.contains(right))neighbors.add(right);
    if(this.upright){
      if(below != null && below.isOccupied && !below.isOrigin && subsection.contains(below))neighbors.add(below);
    } else {
      if(above != null && above.isOccupied && !above.isOrigin && subsection.contains(above))neighbors.add(above);
    }
    return neighbors;
  }

  ArrayList<Triangle> getOneNeighborNonoccupiedNeighbors(){
    ArrayList<Triangle> neighbors = new ArrayList<Triangle>();
    if(left != null && left.isOccupiable())neighbors.add(left);
    if(right != null && right.isOccupiable())neighbors.add(right);
    if(this.upright){
      if(below != null && below.isOccupiable())neighbors.add(below);
    } else {
      if(above != null && above.isOccupiable())neighbors.add(above);
    }
    return neighbors;
  }


  
  
  ArrayList<Triangle> getAllConnected(){
    return this.getAllConnected(new ArrayList<Triangle>());
  }
  ArrayList<Triangle> getAllConnected(ArrayList<Triangle> result){
    ArrayList<Triangle> neighbors = this.getOccupiedNeighbors();
    if(this.isOccupied && !result.contains(this)){
        result.add(this);
    }
    for(Triangle t: neighbors){
      if(!result.contains(t)){
        t.getAllConnected(result);
      }
    }
    return result;
  }
  ArrayList<Triangle> getAllConnectedInSubsection(ArrayList<Triangle> subsection){
    return this.getAllConnectedInSubsection(new ArrayList<Triangle>(),subsection);
  }
  ArrayList<Triangle> getAllConnectedInSubsection(ArrayList<Triangle> result, ArrayList<Triangle> subsection){
    ArrayList<Triangle> neighbors = this.getOccupiedNeighbors(subsection);
    if(this.isOccupied && !result.contains(this) && subsection.contains(this)){
        result.add(this);
    }
    for(Triangle t: neighbors){
      if(!result.contains(t)){
        t.getAllConnectedInSubsection(result,subsection);
      }
    }
    return result;
  }
  
  void calculateBranchingCells(ArrayList<Triangle> branch){
    ArrayList<Triangle> neighbors = this.getOccupiedNeighbors(branch);
    if(neighbors.size() == 0){

    }else if(neighbors.size() == 1){
      if(!branch.remove(this)){
        println("Could not delete for branch counting");
      } else {
        neighbors.get(0).calculateBranchingCells(branch);
      }
    } else if(neighbors.size() == 2){
      if(!branch.remove(this)){
        println("Could not delete for branch counting");
      } else {
        ArrayList<Triangle> branch0 = neighbors.get(0).getAllConnectedInSubsection(branch);
        ArrayList<Triangle> branch1 = neighbors.get(1).getAllConnectedInSubsection(branch);
        int proxyBranchCount = 0;
        if(branch0.size() >= this.branchSizeLimit){
          neighbors.get(0).calculateBranchingCells(branch0);
          proxyBranchCount ++;
        }
        if(branch1.size() >= this.branchSizeLimit){
          neighbors.get(1).calculateBranchingCells(branch1);
          proxyBranchCount ++;
        }
        if(proxyBranchCount > 1)this.isBranching = true;
      }
    } else if(neighbors.size() == 3){
      if(xCoord != 0 || yCoord != 0)println("Could not delete for branch counting");
      if(!branch.remove(this)){
        println("Could not delete for branch counting");
      } else {
        ArrayList<Triangle> branch0 = neighbors.get(0).getAllConnectedInSubsection(branch);
        ArrayList<Triangle> branch1 = neighbors.get(1).getAllConnectedInSubsection(branch);
        ArrayList<Triangle> branch2 = neighbors.get(2).getAllConnectedInSubsection(branch);
        int proxyBranchCount = 0;
        if(branch0.size() >= this.branchSizeLimit){
          neighbors.get(0).calculateBranchingCells(branch0);
          proxyBranchCount ++;
        }
        if(branch1.size() >= this.branchSizeLimit){
          neighbors.get(1).calculateBranchingCells(branch1);
          proxyBranchCount ++;
        }
        if(branch2.size() >= this.branchSizeLimit){
          neighbors.get(2).calculateBranchingCells(branch2);
          proxyBranchCount ++;
        }
        if(proxyBranchCount > 1){
          this.isBranching = true;
        }
      }
    }
  }
  
  void calculateSegments(ArrayList<Triangle> branch,ArrayList<Triangle> currentSegment, ArrayList<ArrayList<Triangle>> segments){
    ArrayList<Triangle> neighbors = this.getOccupiedNeighbors(branch);
    if(!branch.remove(this)){
      println("Could not delete for segment counting");
    }
    if(this.isBranching){
      if(currentSegment.size() > 0){
        if(!currentSegment.contains(this) && !this.isOrigin)currentSegment.add(this);
        segments.add(currentSegment);
      }
      if(neighbors.size() <= 1){
        println("Is marked as branching wrongly");
      } else if(neighbors.size() == 2){
        
        for(Triangle n: neighbors){
          ArrayList<Triangle> tbranch = n.getAllConnectedInSubsection(branch);
          if(tbranch.size() >= this.branchSizeLimit){
            ArrayList nextSegment = new ArrayList<Triangle>();
            nextSegment.add(n);
            //n.calculateSegments(tbranch,new ArrayList<Triangle>(),segments);
            n.calculateSegments(tbranch,nextSegment,segments);
          } else println("Is marked as branching wrongly 2");
        }
      } else if(neighbors.size() >= 3){
        for(Triangle n: neighbors){
          ArrayList<Triangle> tbranch = n.getAllConnectedInSubsection(branch);
          if(tbranch.size() >= this.branchSizeLimit){
            ArrayList nextSegment = new ArrayList<Triangle>();
            nextSegment.add(n);
            n.calculateSegments(tbranch,nextSegment,segments);
          } else {
            segments.add(tbranch);
          }
        } 
      }
    } else if(!this.isBranching){
      if(neighbors.size() == 0){
        if(!currentSegment.contains(this) && !this.isOrigin)currentSegment.add(this);
        segments.add(currentSegment);
      } else if(neighbors.size() == 1){
        if(!currentSegment.contains(this) && !this.isOrigin)currentSegment.add(this);
        if(!currentSegment.contains(neighbors.get(0)) && !neighbors.get(0).isOrigin)currentSegment.add(neighbors.get(0));
        neighbors.get(0).calculateSegments(branch,currentSegment,segments);
      } else if(neighbors.size() > 1){
        
        //int totalSize = currentSegmentSize;
        for(Triangle n: neighbors){
          ArrayList<Triangle> subseg = n.getAllConnectedInSubsection(branch);
          if(subseg.size() < this.branchSizeLimit){
            currentSegment.addAll(subseg);
          }
        }
        boolean continues = false;
        for(Triangle n: neighbors){
          ArrayList<Triangle> subseg = n.getAllConnectedInSubsection(branch);
          if(subseg.size() >= this.branchSizeLimit){
            if(!currentSegment.contains(this) && !this.isOrigin)currentSegment.add(this);
            n.calculateSegments(n.getAllConnectedInSubsection(branch),currentSegment,segments);
            continues = true;
            break;
          }
        }
        if(!continues){
          if(!currentSegment.contains(this) && !this.isOrigin)currentSegment.add(this);
          segments.add(currentSegment);
        }
      } 
    }
  }

  
  int getNeighborCount(){
    if(this.isEdge)return 0;
    int neighborCount = 0;
    if(left != null && left.isOccupied)neighborCount++;
    if(right != null && right.isOccupied)neighborCount++;
    if(this.upright){
      if(below != null && below.isOccupied)neighborCount++;
    } else {
      if(above != null && above.isOccupied)neighborCount++;
    }
    return neighborCount;
  }

  
  boolean isEnoughSpace(){
    if(this.getNeighborCount() != 1){
      return false;
    } else {
      if(left.isOccupied){
        if(right.right.isOccupied)return false;
        if(this.upright){
          if(below.right.isOccupied)return false;
          if(below.right.right.isOccupied)return false;
        } else if(!this.upright){
          if(above.right.isOccupied)return false;
          if(above.right.right.isOccupied)return false;
        }
      }else if(right.isOccupied){
        if(left.left.isOccupied)return false;
        if(this.upright){
          if(below.left.isOccupied)return false;
          if(below.left.left.isOccupied)return false;
        } else if(!this.upright){
          if(above.left.isOccupied)return false;
          if(above.left.left.isOccupied)return false;
        }
      }else if(above.isOccupied && !this.upright){ // maybe need to check upright
        if(below.isOccupied)return false;
        if(below.left.isOccupied)return false;
        if(below.right.isOccupied)return false;
      }else if(below.isOccupied && this.upright){ // maybe need to check upright
        if(above.isOccupied)return false;
        if(above.left.isOccupied)return false;
        if(above.right.isOccupied)return false;
      }
      return true;
    }
  }
 
  boolean isRemovable(){
    if(this.usageScore > removalUsageLimit && !this.isOrigin && this.isOccupied && this.getNeighborCount() < 2 && this.builderCount == 0){ //normally at this.getNeighborCount() < 3
    //if(this.usageScore > removalUsageLimit && !this.isOrigin && this.isOccupied && this.getNeighborCount() < 2){ //normally at this.getNeighborCount() < 3
      return true;
    } else return false;
  }
  boolean isOccupiable(){
    if(!this.isOccupied && this.isEnoughSpace()){
      return true;
    } else return false;
  }
 
  
  void updateUsage(int usageValue){
    if(!grid.isDone()){
      if(this.isOccupied){
        usageScore += abs(usageValue - (builderCount + removerCount));
      if(usageScore < 0) usageScore = 0;
      } else usageScore = 0;
    }
    
  }
  void display(){
      stroke(63,10);
      
      if(isOccupied){
        //fill(255-(float(occupiedage)/4)%255,192,255);
        if(segmentID == -1){
          fill(usageColorCalculator(usageScore));
        } else {
          fill(segmentColorCalculator(segmentID,grid.segments.size()));
        }
      } else {
        fill(255);
      }
      
      if(isOrigin){
        if(!grid.isDone()){
          fill(#FF6AC8);
        } else {
          fill(color(0));
        }
      }
      if(!grid.isDone()){
        if(builderCount > 0) fill(#15FF31);
        if(removerCount > 0) fill(0);
        if(builderCount > 0 && removerCount > 0) fill(#0E9B55);
      }
      if(upright){
        triangle(center.x, center.y - (radius + sin(PI/6)*radius)/2,
        center.x - sin(PI/3)*radius, center.y + (radius + sin(PI/6)*radius)/2, 
        center.x + sin(PI/3)*radius, center.y + (radius + sin(PI/6)*radius)/2);
  
      } else {
        triangle(center.x, center.y + (radius + sin(PI/6)*radius)/2,
        center.x + sin(PI/3)*radius, center.y - (radius + sin(PI/6)*radius)/2, 
        center.x - sin(PI/3)*radius, center.y - (radius + sin(PI/6)*radius)/2);
      }
      /*
      // Highlights cells marked as branching
      if(isBranching){
        fill(255);
        circle(center.x,center.y,10);
      }*/
      
      /*
      // Highlights cells marked as removable
      if(this.isRemovable()){
        fill(255);
        circle(center.x,center.y,5);
      }*/
  }
}
