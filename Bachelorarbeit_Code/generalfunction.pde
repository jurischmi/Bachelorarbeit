PVector positionFromCoord(float x, float y, float triangleRadius){
  float triangleWidth = 2*sin(PI/3)*triangleRadius;
  float triangleHeight = triangleRadius+sin(PI/6)*triangleRadius;
  float xPosition = x*triangleWidth/2 + width/2;
  float yPosition = y*triangleHeight + height/2;
  float uprightOrientation = 0;
  if(abs(x)%2 == 1 && abs(y)%2 == 1){
    uprightOrientation = 1;
  }
  if(abs(x)%2 == 0 && abs(y)%2 == 0){
    uprightOrientation = 1;
  }
  return new PVector(xPosition,yPosition,uprightOrientation);  
}
String fileNameFormat(int i){
  if(i < 10)return "00" + i;
  if(i < 100)return "0" + i;
  return "" + i;
}
boolean checkRunning(ArrayList<Grid> gs){
  for(Grid g: gs){
    if(!g.isDone()){
      return true;
    }
  }
  return false;
}

color usageColorCalculator(float f){
  return color(0,255-min(255,(f/32)),255-min(255,(f/32)));
}

color segmentColorCalculator(float segID, float segCount){
  return color(255*(segID/segCount),255,255);
}
int maxInteger(ArrayList<Integer> list){
  if(list.size() == 0)return 0;
  int max = list.get(0);
  for(Integer i: list){
    if(i > max)max = i;
  }
  return max;
}
int minInteger(ArrayList<Integer> list){
  if(list.size() == 0)return 0;
  int min = list.get(0);
  for(Integer i: list){
    if(i < min)min = i;
  }
  return min;
}
float meanInteger(ArrayList<Integer> list){
  if(list.size() == 0)return 0;
  float total = 0;
  for(Integer i: list){
    total += i;
  }
  return total/list.size();
}
float stdInteger(ArrayList<Integer> list){
  if(list.size() == 0)return 0;
  if(list.size() == 1)return 0;
  float mean = meanInteger(list);
  float total = 0;
  for(Integer i: list){
    total += sq(i-mean);
  }
  return sqrt(total/(list.size()-1));
}
void removeZeros(ArrayList<Integer> list){
  if(list.size() > 0){
    for(int i = list.size() - 1; i >= 0; i--){
      if(list.get(i).equals(0))list.remove(i);
    }
  }
}
