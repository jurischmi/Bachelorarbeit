import java.util.Map;

ArrayList<Grid> grids;
ArrayList<CSVFile> graphs;

Legend legend;

int seed;
int simulationSpeed, speedUp;
int stepCount;
boolean running;
boolean savedTable;
int currentGrid;

/*

*/
void setup(){
  seed = int(random(1000000));
  //seed = 749122; // uncomment for tested remover-agent condition random seed
  //seed = 939802; // uncomment for tested neutral-agent condition random seed
  //seed = 302012; // uncomment for usage parameter pretrial random seed
  //seed = 868047; // uncomment for usage score limit pretrial random seed
  //seed = 870345; // uncomment for structure size limit pretrial random seed
  randomSeed(seed);

  fullScreen();
  colorMode(HSB);
  pixelDensity(1);
  strokeWeight(1);
  frameRate(60);
  
  // Initialization of Grids
  grids = new ArrayList<Grid>();
  int gridID = 0;
  float[] spawnChances = {0, 0.005, 0.01, 0.02, 0.03, 0.05, 0.1, 0.2, 0.4, 0.49};
  
  for(int i = 0; i < 10; i++){
    for(int j = 0; j < 50; j++){
      for(int k = 0; k < 1; k++){
        for(int l = 0; l < spawnChances.length; l++){
          grids.add(new Grid(32,10,20,spawnChances[l],2,100,gridID));
          gridID++;
        }
        /*
        //Initiate grids with variable usage parameters
        for(int l = 0; l < spawnChances.length; l++){
          grids.add(new Grid(32,10,20,spawnChances[l],i,100,gridID));
          gridID++;
        }*/
  
        
        /*
        //Initiate grids with variable usage score limits
        for(int l = 0; l < spawnChances.length; l++){
          grids.add(new Grid(32,10,i*10,spawnChances[l],2,100,gridID));
          gridID++;
        }
        /*
        //Initiate grids with variable structure size limits
        for(int l = 0; l < spawnChances.length; l++){
          grids.add(new Grid(32,10,20,spawnChances[l],2,25*(i+1),gridID));
          gridID++;
        }*/
        
        println("Initiated " + gridID + " grids");
      }
    }
  }
  println("Initiated all grids");
  
  graphs = new ArrayList<CSVFile>();
  for(int i = 0; i < 17; i++){
    graphs.add(new CSVFile());
  }
  
  legend = new Legend(width-75,50,10,500);
  
  simulationSpeed = 10;
  speedUp = 10;
  stepCount = 0;
  running = true;
  savedTable = false;
  currentGrid = 0;
}


void mouseClicked(){
  for(Grid g: grids){
    if(g.existsAgents())currentGrid = g.getID();
  }
}
void mouseWheel(MouseEvent event) {
  if(grids.size() > 0){
    int e = event.getCount();
    
    currentGrid+=e;
    
    while(currentGrid<0){
      currentGrid+=grids.size();
    }
    currentGrid = currentGrid%grids.size();    
  }
}

void draw(){

  background(255);
  if(checkRunning(grids)){
    if(mousePressed){
      simulationSpeed = 1;
    } else { 
      simulationSpeed = speedUp;
    }
    for(int i = 0; i < simulationSpeed; i++){
      if(frameCount%1 == 0){   
        for(Grid g: grids){
          g.addAgent();
        }
      
        stepCount++;
        for(Grid grid: grids){
          grid.moveAgents();
          //grid.incrementOccupiedAge(1);
          grid.updateUsage();
          grid.deleteDeadAgents();
          
          //grid.addAagentCountToChart(timecsvfile);
        }
      }
    }
    
  } else{
    
    
    if(!savedTable){
      for(Grid grid: grids){
        grid.calculateSegments();
        grid.calculateTotalSegmentSizes();
        grid.calculateSegmentSizesAsString();
        grid.calculateTravelDistance();
        
        grid.addResultToChart(graphs.get(0),grid.getOccupiedCount());
        grid.addResultToChart(graphs.get(1),grid.getAverageDistance());
        grid.addResultToChart(graphs.get(2),grid.getMaxDistance());
        grid.addResultToChart(graphs.get(3),grid.getSurfacearea());
        grid.addResultToChart(graphs.get(4),grid.getAverageSurfacearea());
        grid.addResultToChart(graphs.get(5),grid.getSimulationSteps());
        grid.addResultToChart(graphs.get(6),grid.getOccupiedPlaced());
        grid.addResultToChart(graphs.get(7),grid.getOccupiedRemoved());
        grid.addResultToChart(graphs.get(8),grid.getSegmentCount());
        grid.addResultToChart(graphs.get(9),grid.getMinSegment());
        grid.addResultToChart(graphs.get(10),grid.getMaxSegment());
        grid.addResultToChart(graphs.get(11),grid.getMeanSegment());
        grid.addResultToChart(graphs.get(12),grid.getStdSegment());
        grid.addResultToChart(graphs.get(13),grid.getBuilderTravelDistance());
        grid.addResultToChart(graphs.get(14),grid.getRemoverTravelDistance());
        grid.addResultToChart(graphs.get(15),grid.getTotalTravelDistance());
        grid.addResultToChart(graphs.get(16),grid.getMeanTravelDistance());
      }
      graphs.get(0).saveData("occupiedcount");
      graphs.get(1).saveData("averagedistance");
      graphs.get(2).saveData("maxdistance");
      graphs.get(3).saveData("surfacearea");
      graphs.get(4).saveData("averagesurfacearea");
      graphs.get(5).saveData("simulationstepscount");
      graphs.get(6).saveData("placedcount");
      graphs.get(7).saveData("removedcount");
      graphs.get(8).saveData("segmentcount");
      graphs.get(9).saveData("minsegmentsize");
      graphs.get(10).saveData("maxsegmentsize");
      graphs.get(11).saveData("meansegmentsize");
      graphs.get(12).saveData("stdsegmentsize");
      graphs.get(13).saveData("buildertraveldistance");
      graphs.get(14).saveData("removertraveldistance");
      graphs.get(15).saveData("totaltraveldistance");
      graphs.get(16).saveData("meantraveldistance");
      println("Saved data for seed:" + seed);
      
      savedTable = true;
    }
  }
  //if(mousePressed){
    grids.get(currentGrid).display();
    textSize(15);
    fill(0);
    text("Grid ID: " + currentGrid, 50,30);
    text("Remover Agent Spawn Chance: " + grids.get(currentGrid).getRemoverChance(), 50,60);
    text("Cell Usage Limit: " + grids.get(currentGrid).getRemovalUsageLimit(), 60,90);
    text("Usage Parameter: " + grids.get(currentGrid).getUsageValue(), 60,120);
    text("Simulation Steps Count: " + grids.get(currentGrid).getSimulationSteps(), 60,150);
    text("Occupied Count: " + grids.get(currentGrid).occupiedCells + " - " + grids.get(currentGrid).emptiedCells + " = " + grids.get(currentGrid).occupiedCount, 60,180);
    /*text("Active Builder Agents: " + grids.get(currentGrid).getAgentsSize(), 50,90);
    text("Active Remover Agents: " + grids.get(currentGrid).getremoversSize(), 50,120);*/
    
    
    
    
    if(savedTable){
      //text("Truth: " + grids.get(currentGrid).getOccupiedCount(), 240,210);
      text("Surfacearea: " + grids.get(currentGrid).getSurfacearea(), 60,210);
      text("Mean Distance: " + grids.get(currentGrid).getAverageDistance(), 60,240);
      text("Segment Count: " + grids.get(currentGrid).getSegmentCount(), 60,270);
      text("Segment Sizes: " + grids.get(currentGrid).getSegmentSizesAsString(), 60,300);
      text("Total Segment Sizes: " + grids.get(currentGrid).getTotalSegmentSizes(), 60,330);
      text("Builder Travel Distance: " + grids.get(currentGrid).getBuilderTravelDistance(), 60,360);
      text("Remover Travel Distance: " + grids.get(currentGrid).getRemoverTravelDistance(), 60,390);
      text("Total Travel Distance: " + grids.get(currentGrid).getTotalTravelDistance(), 60,420);
      text("Mean Travel Distance: " + grids.get(currentGrid).getMeanTravelDistance(), 60,450);
    }
  legend.display();
}
