class SingleColorG extends PatternGenerator {
  int lastTime = 0;

  int lastH = 128;
  
  SingleColorG(){
    param1 = 100;
  }

  void GetFrame(int[][] buffer) {
    if (millis() - lastTime >= 3000 / (param1*2)) {
      lastTime = millis();
      lastH = lastH < 254 ? lastH + 1 : 0;
      
    }
    for (int i=0;i<buffer.length;i++) {
      java.awt.Color newColor = java.awt.Color.getHSBColor(lastH / 255.0,255 / 255.0,255 / 255.0);
      buffer[i][0] = newColor.getRed();
      buffer[i][1] = newColor.getGreen();
      buffer[i][2] = newColor.getBlue();
    }
  }
}

