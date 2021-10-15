final int GRID_SIZE = 51; // if running slow: change to smaller number
int stepSpeed = 5; 
boolean[][] grid = new boolean[GRID_SIZE][GRID_SIZE];
boolean running;
// debug
boolean DRAW_POS;
boolean DRAW_VALUES;

void setup() {
    size(1000,1000);
    running = false;
    // sets the default grid
    grid[GRID_SIZE/2][GRID_SIZE/2-1] = true;
    grid[GRID_SIZE/2][GRID_SIZE/2] = true;
    grid[GRID_SIZE/2][GRID_SIZE/2+1] = true;
}

void draw() {
    update();
}

void update(){
    drawGridBorder();
    drawGrid();
    if (DRAW_POS) drawGridPos();
    if (DRAW_VALUES) drawGridValues();
    if (running){
        frameRate(stepSpeed);
        grid = nextGrid();
    }
    else{
        frameRate(60); // sets frameRate back to 60 when not running to unsure smooth input
    }
}

// debug tool - will print out boolean grid
void printGrid(boolean[][] g){
    for (boolean[] row: g){
        for (boolean tile: row){
            print(tile+", ");
        }
        println();
    }
    println();
}

void keyPressed(){
    switch (key){
        // debug
        case 'p': // print grid 
            printGrid(grid);
        break;	
        // grid flow
        case ' ': // toggle run
            running = !running;
            println("Running:",running);
        break;
        case ENTER: // step through grid
            if (!running){
                frameRate(60);
                grid = nextGrid();
            }
            else{
                println("ERROR - Can not step while already running");
            }
        break;
        // change stepSpeed
        case '+': // increase stepSpeed
            stepSpeed = min(stepSpeed+1,60);
            println("Step Speed:",stepSpeed);
            break;
        case '-': // decrease stepSpeed
            stepSpeed = max(stepSpeed-1,1);
            println("Step Speed:",stepSpeed);
            break;
        // file
        case 's':{ // save
            if (!running){
                saveGrid(grid);
                println("Saved grid to file '" + FILENAME + "'.");
            }
            else {
                println("ERROR - stop sim before saving");
            }
            break;
        }
        case 'l':{ // load
            if (!running){
                safeLoadGrid();
            }
            else {
                println("ERROR - stop sim before loading");
            }
            break;
        }
        case 'r':{ // resets grid
            grid = new boolean[GRID_SIZE][GRID_SIZE];
            println("Reset grid.");
        }
    }
}

// draws the grid borders
void drawGridBorder(){
    stroke(69);
    for (float x=0; x<width; x+=width/GRID_SIZE){
        for (float y=0; y<height; y+=height/GRID_SIZE){
            fill(0);
            rect(x,y,width/GRID_SIZE,height/GRID_SIZE);
        }
    }
}

// draws the all the alive cells in the grid
void drawGrid(){
    for (int y=0; y<grid.length; y++){
        boolean[] row = grid[y];
        for (int x=0; x<row.length; x++){
            boolean tile = row[x];
            if (tile){
                fill(0,255,0);
                rect(x*(width/GRID_SIZE),y*(height/GRID_SIZE),width/GRID_SIZE,height/GRID_SIZE);
            }
        }
    }
}

// will not display well on large grid sizes
void drawGridPos(){
    for (int y=0; y<grid.length; y++){
        for (int x=0; x<grid[y].length; x++){
            fill(255);
            text(x+":"+y,x*(width/GRID_SIZE),(y+1)*(height/GRID_SIZE)); // tile coord
        }
    }
}

// will not display well on large grid sizes
void drawGridValues(){
    for (int y=0; y<grid.length; y++){
        for (int x=0; x<grid[y].length; x++){
            fill(255);
            text(tileValue(x,y)+"n",x*(width/GRID_SIZE),(y+1)*(height/GRID_SIZE)); // tile value
        }
    }
}

// TODO: put in loop
PVector[] neighborIndex(int xInput, int yInput){
    PVector[] tempArray = new PVector[8];
    //
    tempArray[0] = new PVector(xInput-1,yInput-1);
    tempArray[1] = new PVector(xInput-1,yInput);
    tempArray[2] = new PVector(xInput-1,yInput+1);
    //
    tempArray[3] = new PVector(xInput,yInput-1);
    tempArray[4] = new PVector(xInput,yInput+1);
    //
    tempArray[5] = new PVector(xInput+1,yInput-1);
    tempArray[6] = new PVector(xInput+1,yInput);
    tempArray[7] = new PVector(xInput+1,yInput+1);
    //
    for (int i=0; i<tempArray.length; i++){ // TODO: optimize whole section (do not even add if invalid)
        if (!checkVector(tempArray[i])){
            tempArray[i] = new PVector(-1,-1); // if out of range set to invalid PVector(-1,-1) to make checks easier
        }
    }
    return tempArray;
}

// checks vector lies within the grid size
boolean checkVector(PVector vector){
    return (0 < vector.x && vector.x <GRID_SIZE) && (0 < vector.y && vector.y <GRID_SIZE);
}

// returns the sum of all alive neighbors for a given cell at position (x,y)
int tileValue(int xPos, int yPos){
    int total = 0;
    PVector[] neighbors = neighborIndex(xPos,yPos);
    for (PVector neighbor: neighbors){
        fill(0,0,255,100);
        if (int(neighbor.x) == -1 || int(neighbor.y) == -1){ // NOR;
        }
        else{
            if (grid[int(neighbor.y)][int(neighbor.x)]){
                total += 1;
            }
        }
    }
    return total;
}

// returns the next grid layout
boolean[][] nextGrid(){
    boolean[][] tempGrid = new boolean[grid.length][]; // creates new grid - prevents data being read and written to grid at same time.
    copyTwoDimensionalArray(grid,tempGrid); // copy old grid data to new
    //
    for (int y=0; y<grid.length; y++){
        for (int x=0; x<grid[y].length; x++){
            int tValue = tileValue(x,y);
            if (tValue < 2){ // underpop
                // println("u");
                tempGrid[y][x] = false;
            }
            else if (tValue > 3){ // overpop
                // println("o");
                tempGrid[y][x] = false;
            }
            else if (tValue == 3){ // reproduce
                // println("r");
                tempGrid[y][x] = true;
            }
        }
    }
    return tempGrid; // returns new grid
}

void mousePressed() {
    if (!running){
        int xPos = min(max(round(mouseX/(width/GRID_SIZE)),0),GRID_SIZE-1); // converts mousePos to grid index
        int yPos = min(max(round(mouseY/(height/GRID_SIZE)),0),GRID_SIZE-1); // converts mousePos to grid index
        grid[yPos][xPos] = !grid[yPos][xPos]; // toggle cell at index 
    }
}

// copies all data from inputArray to outputArray
void copyTwoDimensionalArray(boolean[][] inputArray, boolean[][] outputArray){
    for (int y=0; y<inputArray.length; y++){
        if (outputArray[y] == null){
            outputArray[y] = new boolean[inputArray[y].length];
        }
        for (int x=0; x<inputArray[y].length; x++){
            outputArray[y][x] = inputArray[y][x];
        }
    }
}