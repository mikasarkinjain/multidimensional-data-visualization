class DataParser {

  void loadData() {
    loadAsTable(); // arrayTable
    getMinMax(); // minX, maxX, etc.
    loadAsArray(); // data1D, data2D, etc.
    
    if (dimension >= 4)
      gui.initCycling();
  }


  // Loads file into `arrayTable` 
  void loadAsTable() {
    // don't use "header" argument: we have to load headers manually, because "header" assumes that we know what headers are
    Table table = loadTable(filePath);

    table.trim(); // removes whitespace

    // Put the headers, which should be in the first row, (eg "population") into String[] varLabels
    dimension = table.getColumnCount();
    varLabels = new String[dimension];
    TableRow labelsRow = table.getRow(0);
    for (int i = 0; i < dimension; i++) {
      varLabels[i] = labelsRow.getString(i);
    }
    table.removeRow(0);
    
    // We use wLocation because it's possible that there'll be a variable named "year" or so in a different
    // column than the default column for W (the fourth). We want time variables to be W so that users
    // can cycle through them rather than through a less relevant piece of data.    
    int wLocation = findWLocation();
    if (dimension >= 4)
      swap(varLabels, 3, wLocation);

    // fill arrayTable
    arrayTable = new Double[table.getRowCount()][dimension];
    nullValuesCount = new int[7];

    for (int row = 0; row < table.getRowCount(); row++)
      for (int col = 0; col < dimension; col++) {
        // there's no table.getDouble, so we do table.getString and parse it as Double
        String stringDataValue = table.getString(row, col);
        
        int colInArrayTable = col;
        if (dimension >= 4) {
          if (col == 3)
            colInArrayTable = wLocation;
          else if (col == wLocation)
            colInArrayTable = 3;
        }

        if (stringDataValue.length() == 0) { // for data like 1.0, 2.0, , 4.0
          arrayTable[row][colInArrayTable] = null;
          nullValuesCount[colInArrayTable]++;
        } else
          arrayTable[row][colInArrayTable] = Double.parseDouble(stringDataValue);
      }
  }
  
  int findWLocation() {
    for (int i = 0; i < varLabels.length; i++)
      if (varLabels[i].toLowerCase().indexOf("year") != -1 || 
      varLabels[i].toLowerCase().indexOf("time") != -1 || 
      varLabels[i].toLowerCase().indexOf("month") != -1 ||
      varLabels[i].toLowerCase().indexOf("day") != -1 ||
      varLabels[i].toLowerCase().indexOf("hour") != -1 ||
      varLabels[i].toLowerCase().indexOf("minute") != -1 ||
      varLabels[i].toLowerCase().indexOf("second") != -1)
        return i;
    
    return 3;
  }

  // finds min and max
  void getMinMax() {

    // "col" is the column and hence the dimension
    for (int col = 0; col < dimension; col++) {
      double min = arrayTable[0][col];
      double max = min;
      for (int row = 1; row < arrayTable.length; row++) {

        if (arrayTable[row][col] == null)
          continue;

        if (arrayTable[row][col] < min)
          min =  arrayTable[row][col];
        else if (arrayTable[row][col] > max)
          max =  arrayTable[row][col];
      }

      // puts min and max in correct variables
      switch(col) {
      case 0: 
        minX = min;
        maxX = max; 
        break;
      case 1: 
        minY = min;
        maxY = max; 
        break;
      case 2: 
        minZ = min;
        maxZ = max; 
        break;
      case 3: 
        minW = min;
        maxW = max; 
        break;
      case 4: 
        minU = min;
        maxU = max; 
        break;
      case 5: 
        minV = min;
        maxV = max; 
        break;
      case 6: 
        minT = min;
        maxT = max; 
        break;
      }
    }
  }

  // Loads `arrayTable` into array
  void loadAsArray() {
    calcIncrements();
    switch(dimension) {
    case 1: 
      load1D(); 
      break;
    case 2: 
      load2D(); 
      break;
    case 3: 
      load3D(); 
      break;
    case 4: 
      load4D(); 
      break;
    case 5: 
      load5D(); 
      break;
    case 6: 
      load6D(); 
      break;
    case 7: 
      load7D(); 
      break;
    }
    
    if (dimension > 7)
      load7D();
  }

  void calcIncrements() {
    int[] dimensionsToUse = {
      0, 1, 3
    }; // X, Y, W
    for (int dim : dimensionsToUse) {
      // skip Y or W if dimension isn't big enough 
      if ((dim >= 1 && dimension < 3) || (dim >= 3 && dimension < 4))
        continue;

      // all values from an axis (say, X)
      double[] values = new double[arrayTable.length - nullValuesCount[dim]];

      // fill `values` with relevant column from arrayTable
      int currentValuesIndex = 0; // necessary because null values
      for (int row = 0; row < arrayTable.length; row++)  
        if (arrayTable[row][dim] != null) {
          values[currentValuesIndex] = arrayTable[row][dim];
          currentValuesIndex++;
        }

      // sort  
      Arrays.sort(values);
      
      // wValues is an instance variable of main used by Graph#graphPoints()
      if (dim == 3)
        wValues = values;

      // add up the increments of the points  
      double sum = 0.0;
      int uniqueValuesCount = 1; // we need to remove duplicates. minimum is 1 because first value is by definition unique.

      for (int i = 1; i < values.length; i++) {
        // skip duplicates
        if (values[i] != values[i - 1]) {
          sum += values[i] - values[i - 1];
          uniqueValuesCount++;
        }
      }

      double increment = sum / (uniqueValuesCount - 1);
      // given an increment and a min and max, we can say that there are 1 + (max - min) / increment 
      // elements in the resulting array. 
      int arrayLen = (int) (1 + (values[values.length - 1] - values[0]) / increment);
      if (uniqueValuesCount == 1) {
        increment = 0;
        arrayLen = 1;
      }

      // set `increment` and `len` to relevant instance variables
      switch(dim) {
      case 0: 
        incrementX = increment; 
        lenX = arrayLen; 
        break;
      case 1: 
        incrementY = increment; 
        lenY = arrayLen; 
        break;
      case 3: 
        incrementW = increment; 
        lenW = arrayLen; 
        break;
      }
    }
  }


  /* HELPER METHODS FOR loadAsArray() */
  // rounds raw data value to uniform value
  double roundValue(double value, double min, double increment) {
    return min + Math.round((value - min) / increment) * increment;
  }

  // converts uniform value to array index
  int calcArrayIndex(double value, double min, double increment) {
    return (int) ((value - min) / increment);
  }

  // converts array index to uniform value
  int valAtIndex(int index, double min, double increment) {
    return (int) (index * increment + min);
  }

  double weightedAverage(double currentAverage, double numItems, double newItem) {
    return (currentAverage * numItems + newItem)  / (numItems + 1);
  }   
  
  void swap(String[] arr, int ind1, int ind2) {
    String tmp = arr[ind1];
    arr[ind1] = arr[ind2];
    arr[ind2] = tmp;  
  }
  /* END OF HELPER FUNCTIONS */

  void load1D() {
    // use average of points

    double sum = 0.0;
    for (Double[] point : arrayTable) {
      sum += point[0];
    }

    data1D = sum / arrayTable.length;
  }

  void load2D() {
    data2D = new Double[lenX];

    // When two points have the same X, we average their Ys. (this data structure is best-fit)
    // `averageTally` is a duplicate of `data2D` except that we store # number of times averaged
    // instead of Y for a given X.
    double[] averageTally = new double[lenX];

    for (Double[] point : arrayTable) {
      double roundedX = roundValue(point[0], minX, incrementX);
      int indexX = calcArrayIndex(roundedX, minX, incrementX);

      averageTally[indexX]++;

      // If there already is a Z for this X...
      // ... We compute  the weighted average of the points, using `averageTally`.
      // If there is no value yet for thisX, we don't need to do averaging.
      if (averageTally[indexX] >= 2)
        data2D[indexX] = weightedAverage(data2D[indexX], averageTally[indexX], point[1]);
      else
        data2D[indexX] = point[1];
    }

    estimateDataGaps2D();
  }

  void estimateDataGaps2D() {
    // don't check values at extremes

    for (int x = 1; x < data2D.length - 1; x++)
      if (data2D[x] == null && data2D[x - 1] != null && data2D[x + 1] != null)
        data2D[x] = (data2D[x - 1] + data2D[x + 1]) / 2;
  }


  void load3D() {
    data3D = new Double[lenX][lenY][1];

    // When two points have the same (X, Y), we average their Zs. (this data structure is best-fit)
    // `averageTally` is a duplicate of `data3D` except that we store # number of times averaged
    // instead of Z for a given (X, Y).
    double[][] averageTally = new double[lenX][lenY]; // lowercase-"d" double

    for (Double[] point : arrayTable) {
      double roundedX = roundValue(point[0], minX, incrementX);
      int indexX = calcArrayIndex(roundedX, minX, incrementX);

      double roundedY = roundValue(point[1], minY, incrementY);
      int indexY = calcArrayIndex(roundedY, minY, incrementY);

      averageTally[indexX][indexY]++;


      // If there already is a Z for this (X, Y)...
      // ... We compute  the weighted average of the points, using `averageTally`.
      // If there is no value yet for this (X, Y), we don't need to do averaging.
      if (averageTally[indexX][indexY] >= 2)
        data3D[indexX][indexY][0] = weightedAverage(data3D[indexX][indexY][0], averageTally[indexX][indexY], point[2]);
      else {
        data3D[indexX][indexY][0] = point[2];
      }
    }
  }

  void estimateDataGaps3D() {
    // don't check values at extremes

    for (int x = 1; x < data3D.length - 1; x++)
      for (int y = 1; y < data3D[0].length - 1; y++)
        if (data3D[x][y][0] == null && data3D[x - 1][y][0] != null && data3D[x + 1][y][0] != null && data3D[x][y - 1][0] != null && data3D[x][y + 1][0] != null)
          data3D[x][y][0] = (data3D[x - 1][y][0] + data3D[x + 1][y][0] + data3D[x][y - 1][0] + data3D[x][y + 1][0])  / 4;
  }

  void load4D() {
    data4D = loadHyperDimension();
  }

  void load5D() {
    data5D = loadHyperDimension();
  }

  void load6D() {
    data6D = loadHyperDimension();
  }

  void load7D() {
    data7D = loadHyperDimension();
  }

  // 4D-7D are very similar, so we use this generic method.
  // See the block comment at the top for the special structure of 5D to 7D.
  Double[][][][] loadHyperDimension() {
    Double[][][][] matrix = new Double[lenW][lenX][lenY][dimension - 3];

    // When two points have the same (W, X, Y), we average their Zs, Us, Vs, and Ts (if they exist). (this data structure is best-fit)
    // `averageTally` is a duplicate of `matrix` except that we store # number of times averaged
    // instead of (Z, U, V, T) for a given (W, X, Y).
    double[][][] averageTally = new double[lenW][lenX][lenY]; // lowercase-"d" double

    for (Double[] point : arrayTable) {
      // double[] point is of form [x, y, z, w, u, v, t]

      double roundedW = roundValue(point[3], minW, incrementW);
      int indexW = calcArrayIndex(roundedW, minW, incrementW);

      double roundedX = roundValue(point[0], minX, incrementX);
      int indexX = calcArrayIndex(roundedX, minX, incrementX);

      double roundedY = roundValue(point[1], minY, incrementY);
      int indexY = calcArrayIndex(roundedY, minY, incrementY);


      averageTally[indexW][indexX][indexY]++;

      // If there already is a (Z, U, V, T) for this (W, X, Y)...
      // ... We compute  the weighted average of the points, using `averageTally`.
      if (averageTally[indexW][indexX][indexY] >= 2) {
        matrix[indexW][indexX][indexY][0] = weightedAverage(matrix[indexW][indexX][indexY][0], averageTally[indexW][indexX][indexY], point[2]); 
        if (dimension >= 5)
          matrix[indexW][indexX][indexY][1] = weightedAverage(matrix[indexW][indexX][indexY][1], averageTally[indexW][indexX][indexY], point[4]);
        if (dimension >= 6)
          matrix[indexW][indexX][indexY][2] = weightedAverage(matrix[indexW][indexX][indexY][2], averageTally[indexW][indexX][indexY], point[5]);
        if (dimension >= 7)
          matrix[indexW][indexX][indexY][3] = weightedAverage(matrix[indexW][indexX][indexY][3], averageTally[indexW][indexX][indexY], point[6]);
      } 

      // If there is no value yet for this (W, X, Y), we don't need to do averaging.
      else {
        matrix[indexW][indexX][indexY][0] = point[2];
        if (dimension >= 5)
          matrix[indexW][indexX][indexY][1] = point[4];          
        if (dimension >= 6)
          matrix[indexW][indexX][indexY][2] = point[5];
        if (dimension >= 7)
          matrix[indexW][indexX][indexY][3] = point[6];
      }
    } 

    estimateDataGaps4DTo7D(matrix);
    return matrix;
  }


  void estimateDataGaps4DTo7D(Double[][][][] data) {
    // don't check values at extremes

    for (int _w = 0; _w < data.length; _w++)
      for (int x = 1; x < data[0].length - 1; x++)
        for (int y = 1; y < data[0][0].length - 1; y++)

          if (data[_w][x][y][0] == null && data[_w][x - 1][y][0] != null && data[_w][x + 1][y][0] != null && data[_w][x][y - 1][0] != null && data[_w][x][y + 1][0] != null)
            for (int i = 0; i < data[0][0][0].length; i++)
              data[_w][x][y][i] = (data[_w][x - 1][y][i] + data[_w][x + 1][y][i] + data[_w][x][y - 1][i] + data[_w][x][y + 1][i]) / 4;
  }

  void printDataHuman() {
    println();

    if (dimension >= 2)
      println("incrementX " + incrementX);
    if (dimension >= 3)
      println("incrementY " + incrementY);
    if (dimension >= 4)
      println("incrementW " + incrementW);


    for (String label : varLabels) {
      print(label + "\t");
    }
    println();

    if (dimension == 1)
      println(data1D);

    else if (dimension == 2) {
      for (int x = 0; x < data2D.length; x++) {
        println(valAtIndex(x, minX, incrementX) + "\t" + 
          data2D[x]);
      }
    } else if (dimension == 3) {
      for (int x = 0; x < data3D.length; x++) {
        for (int y = 0; y < data3D[x].length; y++) {
          if (data3D[x][y][0] != null)
            println(valAtIndex(x, minX, incrementX) + "\t" + 
              valAtIndex(y, minY, incrementY) + "\t" +
              data3D[x][y][0]);
        }
      }
    } else if (dimension >= 4) {
      Double[][][][] matrix;
      switch(dimension) {
      case 4: 
        matrix = data4D; 
        break;
      case 5: 
        matrix = data5D; 
        break;
      case 6: 
        matrix = data6D; 
        break;
      case 7: 
        matrix = data7D; 
        break;
      default: 
        matrix = data5D; 
        break;
      }
      
      for (int w = 0; w < matrix.length; w++) {
        for (int x = 0; x < matrix[w].length; x++) {
          for (int y = 0; y < matrix[w][x].length; y++) {
            if (matrix[w][x][y][0] != null) {
              print(valAtIndex(x, minX, incrementX) + "\t" + 
                valAtIndex(y, minY, incrementY) + "\t" +
                matrix[w][x][y][0] + "\t " +
                valAtIndex(w, minW, incrementW) + "\t");
                
              if (dimension >= 5)
                print(matrix[w][x][y][1] + "\t");
              if (dimension >= 6)
                print(matrix[w][x][y][2] + "\t");
              if (dimension >= 7)
                print(matrix[w][x][y][3] + "\t");
              print("\n");
            }
          }
        }
      }
    }
  }
  
  void printData() {
    switch(dimension) {
      case 1: println(data1D);
      case 2: print1DArray(data2D);
      case 3: print3DArray(data3D);
      case 4: print4DArray(data4D);
      case 5: print4DArray(data5D);
      case 6: print4DArray(data6D);
      case 7: print4DArray(data7D);
    }  
  }

  void print1DArray(Double[] data){
    if (data == null)
      return;
      
    print("[");
    for (int i = 0; i < data.length - 1; i++){
      if (data[i] != null)
        print(data[i]);
      else
        print("null");
      
      print(", ");
    } 
    if (data[data.length - 1] != null)
      print(data[data.length - 1]);
    else
      print("null"); // strangely, printing a null (not println) throws NullPointerException
    
    print("]");
  }
  
  void print2DArray(Double[][] data){
    if (data == null)
      return;
     
    print("[");
    for (int i = 0; i < data.length - 1; i++){
      print1DArray(data[i]);
      print(", ");
    }
    print1DArray(data[data.length - 1]);
    print("]");
  }
  
  void print3DArray(Double[][][] data){
    if (data == null)
      return;
     
    print("[");
    for (int i = 0; i < data.length - 1; i++){
      print2DArray(data[i]);
      print(", ");
    }
    print2DArray(data[data.length - 1]);
    print("]");
  }

  void print4DArray(Double[][][][] data) {
    if (data == null)
      return;
    
    println("["); 
    for (int wIndex = 0; wIndex < data.length - 1; wIndex++) {
      print3DArray(data[wIndex]);
      println(", ");
    }
    print3DArray(data[data.length-1]);
    print("\n]");
  }
}
