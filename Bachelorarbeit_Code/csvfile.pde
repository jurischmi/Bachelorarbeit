class CSVFile{
  Table table;
  int factorcount;
  int resultcount;
  CSVFile(){
    factorcount = 5;
    resultcount = 1;
    table = new Table();
    for(int i = 1; i <= factorcount; i++){
      table.addColumn("Factor " + i);
    }
    for(int i = 1; i <= resultcount; i++){
      table.addColumn("Result " + i);
    }
  }
  void addData(float... fs){
    TableRow newRow = table.addRow();
    for(int i = 0; i < factorcount; i++){
      
      newRow.setFloat("Factor "+ int(i+1), fs[i]);
    }
    for(int i = factorcount; i < resultcount + factorcount; i++){
      newRow.setFloat("Result "+ int(i-factorcount+1), fs[i]);
    }
  }

  void saveData(String name){
    saveTable(table, "data/"+name+".csv");
  }
  void saveData(){
    saveTable(table, "data/unnamed"+int(random(1000))+".csv");
  }
  void resetData(){
    table = new Table();
    for(int i = 1; i <= factorcount; i++){
      table.addColumn("Factor " + i);
    }
    for(int i = 1; i <= resultcount; i++){
      table.addColumn("Result " + i);
    }
  }


}
