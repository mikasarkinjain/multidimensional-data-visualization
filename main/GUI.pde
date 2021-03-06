class GUI {
  final int UI_WINDOW_PADDING_BUTTONS = 5;
  final int UI_WINDOW_PADDING_TEXT = 10;
  final int UI_BUTTON_SEPARATION = 10;
  final int UI_GROUP_SEPARATION = 70;
  final int UI_BUTTON_WIDTH = 100;
  final int UI_BUTTON_HEIGHT = 30;
  final int UI_BUTTON_YPOS = UI_WINDOW_PADDING_BUTTONS;
  final int UI_COLOR_SEPARATION = 40;
  final int UI_TEXT_SIZE = 13;

  boolean hoveringOverLoad = false;
  boolean hoveringOverPoints = false;
  boolean hoveringOverMesh = false;
  boolean hoveringOverSurface = false;
  boolean holdingWKey = false;

  final float ROTATE_RATE = 0.01;
  final float PAN_RATE = 4;
  float CYCLE_RATE = 1; // for changing W. is not final because depends on data set.
  final float ZOOM_RATE = 1.02;


  // called by dataParser#loadData
  void initCycling() {
    w = wValues[wValues.length / 2]; // set W to middle of Ws
    roundedWIndex = wValues.length / 2;
    CYCLE_RATE = (float) (5 * (maxW - minW) / height);
  }

  void drawUI() {
    hoveringOverLoad = false;
    hoveringOverPoints = false;
    hoveringOverMesh = false;
    hoveringOverSurface = false;
    //holdingWKey = false;

    if (fileName == null)
      frame.setTitle("Hyperdimensional Data Visualization ");
    else
      frame.setTitle("Hyperdimensional Data Visualization - " + fileName);

    hint(DISABLE_DEPTH_TEST); // draws as fixed 2D
    noLights(); // otherwise it breaks
    camera(); // center camera on origin
    perspective(); // reset perspective
    updateMouse();

    noStroke();
    if (hoveringOverLoad) // set in updateMouse()
      fill(200);
    else
      fill(255);

    float topX; 
    float bottomX; 
    float y;
    textSize(UI_TEXT_SIZE);
    textAlign(CENTER, CENTER); // centered horizontally & vertically

    y = UI_BUTTON_YPOS;
    topX = UI_WINDOW_PADDING_BUTTONS;

    if (hoveringOverLoad) // set in updateMouse()
      fill(200);
    else
      fill(255);
    rect(topX, y, UI_BUTTON_WIDTH, UI_BUTTON_HEIGHT);

    if (hoveringOverPoints) // set in updateMouse()
      fill(200);
    else
      fill(255);
    fill(0);
    text("Load CSV", topX, y, UI_BUTTON_WIDTH, UI_BUTTON_HEIGHT);



    topX += UI_GROUP_SEPARATION + UI_BUTTON_WIDTH;
    if (viewType != DATA_POINTS) // set in updateMouse()
      fill(BACKGROUND_SHADE);
    else if (viewType == DATA_POINTS && !hoveringOverPoints)
      fill(255);  
    else if (viewType == DATA_POINTS && hoveringOverPoints)
      fill(200);

    rect(topX, y, UI_BUTTON_WIDTH, UI_BUTTON_HEIGHT);


    if (viewType == DATA_POINTS)
      fill(BACKGROUND_SHADE);
    else if (viewType != DATA_POINTS && !hoveringOverPoints)
      fill(200);
    else if (viewType != DATA_POINTS && hoveringOverPoints)
      fill(255);
    text("Points", topX, y, UI_BUTTON_WIDTH, UI_BUTTON_HEIGHT);



    topX += UI_BUTTON_WIDTH + UI_BUTTON_SEPARATION;
    if (viewType != BEST_FIT_MESH) // set in updateMouse()
      fill(BACKGROUND_SHADE);
    else if (viewType == BEST_FIT_MESH && !hoveringOverMesh)
      fill(255);  
    else if (viewType == BEST_FIT_MESH && hoveringOverMesh)
      fill(200);
    rect(topX, y, UI_BUTTON_WIDTH, UI_BUTTON_HEIGHT);

    if (viewType == BEST_FIT_MESH)
      fill(BACKGROUND_SHADE);
    else if (viewType != BEST_FIT_MESH && !hoveringOverMesh)
      fill(200);
    else if (viewType != BEST_FIT_MESH && hoveringOverMesh)
      fill(255);
    text("Mesh", topX, y, UI_BUTTON_WIDTH, UI_BUTTON_HEIGHT);



    topX += UI_BUTTON_WIDTH + UI_BUTTON_SEPARATION;
    if (viewType != BEST_FIT_SURFACE) // set in updateMouse()
      fill(BACKGROUND_SHADE);
    else if (viewType == BEST_FIT_SURFACE && !hoveringOverSurface)
      fill(255);  
    else if (viewType == BEST_FIT_SURFACE && hoveringOverSurface)
      fill(200);
    rect(topX, y, UI_BUTTON_WIDTH, UI_BUTTON_HEIGHT);

    if (viewType == BEST_FIT_SURFACE)
      fill(BACKGROUND_SHADE);
    else if (viewType != BEST_FIT_SURFACE && !hoveringOverSurface)
      fill(200);
    else if (viewType != BEST_FIT_SURFACE && hoveringOverSurface)
      fill(255);
    text("Surface", topX, y, UI_BUTTON_WIDTH, UI_BUTTON_HEIGHT);






    fill(255);  

    textAlign(LEFT, CENTER);
    if (dimension >= 4) { 
      text(varLabels[3] + " = " + graph.humanReadableDouble(wValues[roundedWIndex]), UI_WINDOW_PADDING_TEXT, height - UI_WINDOW_PADDING_TEXT - UI_TEXT_SIZE);
    }

    if (dimension >= 5) {
      textAlign(RIGHT, CENTER);
      text("RED: " + varLabels[4], width - UI_WINDOW_PADDING_TEXT, height - UI_WINDOW_PADDING_TEXT - 20);
    }

    if (dimension >= 6) {
      text("GREEN: " + varLabels[5], width - UI_WINDOW_PADDING_TEXT, height - UI_WINDOW_PADDING_TEXT - 20 - UI_COLOR_SEPARATION);
    }

    if (dimension >= 7) {
      text("BLUE: " + varLabels[6], width - UI_WINDOW_PADDING_TEXT, height - UI_WINDOW_PADDING_TEXT - 20 - 2 * UI_COLOR_SEPARATION);
    }

    hint(ENABLE_DEPTH_TEST);
  }

  void updateMouse() {
    if (mouseOverRect(UI_WINDOW_PADDING_BUTTONS, UI_BUTTON_YPOS, 100, 30))
      hoveringOverLoad = true;

    else if (mouseOverRect(UI_WINDOW_PADDING_BUTTONS + UI_GROUP_SEPARATION + UI_BUTTON_WIDTH, UI_BUTTON_YPOS, 100, 30))
      hoveringOverPoints = true;

    else if (mouseOverRect(UI_WINDOW_PADDING_BUTTONS + UI_GROUP_SEPARATION + 2 * UI_BUTTON_WIDTH + UI_BUTTON_SEPARATION, UI_BUTTON_YPOS, 100, 30))
      hoveringOverMesh = true;

    else if (mouseOverRect(UI_WINDOW_PADDING_BUTTONS + UI_GROUP_SEPARATION + 3 * UI_BUTTON_WIDTH + 2 * UI_BUTTON_SEPARATION, UI_BUTTON_YPOS, 100, 30))
      hoveringOverSurface = true;
  }

  boolean mouseOverRect(int rectX, int rectY, int rectWidth, int rectHeight) {
    return rectX <= mouseX && rectX + rectWidth >= mouseX &&
      rectY <= mouseY && rectY + rectHeight >= mouseY;
  }

  void mousePressed() {
    if (hoveringOverLoad)
      loadFile();

    else if (hoveringOverPoints)
      viewType = DATA_POINTS;

    else if (hoveringOverMesh)
      viewType = BEST_FIT_MESH;

    else if (hoveringOverSurface)
      viewType = BEST_FIT_SURFACE;
  }

  void mouseDragged() {
    if (holdingWKey && dimension >= 4) {
      w += (pmouseY - mouseY) * CYCLE_RATE;

      // constrain w to within [minW - abs(minW), maxW)
      // the decreased lower bound allows some buffer space. if the lower bound were just minW,
      // roundedWIndex would never equal 0.
      w = constrain((float) w, (float) (minW - Math.abs(minW)), (float) maxW);

      // set roundedWIndex
      while (roundedWIndex < wValues.length - 1 && w > wValues[roundedWIndex]) {
        roundedWIndex++;
      }

      while (roundedWIndex >= 1 && w < wValues[roundedWIndex - 1])
        roundedWIndex--;
    } else {
      double changeX = (pmouseY-mouseY) * ROTATE_RATE;
      double changeY = (pmouseX-mouseX) * ROTATE_RATE;

      camera.rotate(changeX, changeY);
    }
  }

  void keyPressed() {
    double changeX = 0; 
    double changeY = 0;
    if (key == CODED) {

      switch(keyCode) {
      case LEFT: 
        changeX = -PAN_RATE; 
        break;
      case RIGHT: 
        changeX = PAN_RATE; 
        break;
      case UP: 
        changeY = -PAN_RATE; 
        break;
      case DOWN: 
        changeY = PAN_RATE; 
        break;
      }
      camera.pan(changeX, changeY);
    } else {
      if (key == 'w' || key == 'W')
        holdingWKey = true;
    }
  }

  void keyReleased() {
    if (key == 'w' || key == 'W')
      holdingWKey = false;
  }

  void mouseMoved() {
  }

  void mouseWheel(MouseEvent event) {
    int wheelRotation = event.getCount(); // seems always to be 1  
    double multiplier = 1;

    if (wheelRotation > 0)
      multiplier = wheelRotation * ZOOM_RATE;

    else 
      multiplier = -wheelRotation * 1 / ZOOM_RATE;  

    camera.zoom(multiplier);
  }

  void loadFile() {
    selectInput("Select CSV", "fileSelected");
  }

  void fileSelected(File selection) {
    if (selection == null)
      return;

    filePath = selection.getAbsolutePath();

    if (filePath.substring(filePath.length()-4).equals(".csv")) {
      fileName = selection.getName();
      dataParser.loadData();
    } else
      fileName = null;
  }
}

