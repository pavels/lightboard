class StaticColorG extends PatternGenerator {
  StaticColorG(){
    param1 = 100;
  }

  void GetFrame(int[][] buffer) {
    for (int i=0;i<buffer.length;i++) {
      java.awt.Color newColor = java.awt.Color.getHSBColor(param1 / 128.0,1,param2 / 128.0);
      buffer[i][0] = newColor.getRed();
      buffer[i][1] = newColor.getGreen();
      buffer[i][2] = newColor.getBlue();
    }
  }
}

