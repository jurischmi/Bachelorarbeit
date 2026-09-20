class Legend{
  float x, y, xsize, ysize;
  Legend(float x, float y, float xsize, float ysize){
    this.x = x;
    this.y = y;
    this.xsize = xsize;
    this.ysize = ysize;
  }
  
  void display(){
    //noStroke();
    textSize(10);
    for(int i = 0; i <= ysize; i+=xsize){
      fill(usageColorCalculator(i*10));
      rect(x,y+i,xsize,xsize);
      fill(0);
      text("-" + i*10 ,x + xsize, y + i + xsize);
    }
    
    text("Cell Usage Score Legend" ,x - 3*xsize, y - xsize/2);
  }
}
