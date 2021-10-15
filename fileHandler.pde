final String FILENAME = "gridSave.txt";

void saveGrid(boolean[][] g){
    String[] stringGrid = arrayToStringArray(g);
    saveStrings(FILENAME, stringGrid);
}

boolean[][] loadGrid(){
    String[] stringGrid = loadStrings(FILENAME);
    return stringArrayToArray(stringGrid);
}

// will assume rect grid
void safeLoadGrid(){
    boolean[][] g = loadGrid();
    if (g.length > GRID_SIZE || g[0].length > GRID_SIZE){
        println("ERROR - loaded grid is too large ('" + g.length + "," + g[0].length + ").");
    }
    else if (g.length == GRID_SIZE && g[0].length == GRID_SIZE){
        grid = g;
        println("Loaded file '" + FILENAME + "' to grid.");
    }
    else if (g.length < GRID_SIZE || g[0].length < GRID_SIZE){
        boolean[][] newGrid = new boolean[GRID_SIZE][GRID_SIZE];
        copyTwoDimensionalArray(g,newGrid);
        grid = newGrid;
        println("Loaded file '" + FILENAME + "' safely to grid.");
        println(grid.length);
    }
}

String[] arrayToStringArray(boolean[][] inputArray){
    String[] outputStringArray = new String[inputArray.length];
    for (int y=0; y<inputArray.length; y++){
        boolean[] row = inputArray[y];
        String stringRow = "";
        for (int x=0; x<row.length; x++){
            boolean tile = row[x];
            if (tile){
                stringRow += "O";
            }
            else{
                stringRow += ".";
            }
        }
        outputStringArray[y] = stringRow;
    }
    return outputStringArray;
}

boolean[][] stringArrayToArray(String[] inputStringArray){
    boolean[][] outputArray = new boolean[inputStringArray.length][];
    for (int y=0; y<inputStringArray.length; y++){
        String row = inputStringArray[y];
        outputArray[y] = new boolean[row.length()];
        for (int x=0; x<row.length(); x++){
            char chr = row.charAt(x);
            if (chr == 'O'){
                outputArray[y][x] = true;
            }
            else if (chr == '.'){
                outputArray[y][x] = false;
            }
            else{
                println("ERROR - Invalid input '" + chr + "' at (" + x + ":" + y + ").");
            }
        }
    }
    return outputArray;
}