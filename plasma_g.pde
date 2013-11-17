class PlasmaG extends PatternGenerator {
  int lastTime = 0;

  float lastH = 0;
  
  float multX = 2;
  int mult = 1;

  PlasmaG() {
    param1 = 100;
  }

  void GetFrame(int[][] buffer) {
    multX = param1 / 8.0;
    if (millis() - lastTime >= 100) {
      lastTime = millis();
      if(lastH > (param3 * 15 ) && mult == 1){
         mult = -1;
      }else if(lastH < 1 && mult == -1){
         mult = 1;
      }
      
      lastH += mult * multX;      
    }


    for (int i=0;i<buffer.length;i++) {
      float x = i / float(buffer.length);
      float y = 1;

      float u_k = 15.0;

      float u_time = (lastH) / 250.0;

      float v = 0.0;
      float cx = x * u_k - u_k/2.0;
      float cy = y * u_k - u_k/2.0;

      v += sin((x+u_time));
      v += sin((y+u_time)/2.0);
      v += sin((x+y+u_time)/2.0);
      cx += u_k/2.0 * sin(u_time/3.0);
      cy += u_k/2.0 * cos(u_time/2.0);

      v += sin(sqrt(cx*cy+cy*cy+1.0));
      v = v/2.0;

      int r = 0;
      int g = 0;
      int b = 0;
      if(param2 > 64){
        r = int(sin(v * PI + 2 * PI / 3) * 255);
        g = int(cos(v * PI + 2 * PI / 3) * 255);
        b = int(sin(v * PI) * 255);
      }else if(param2 > 32){
        r = int(sin(v * PI) * 255);
        g = int(cos(v * PI) * 255);
        b = 0;          
      }else{
        java.awt.Color newColor = java.awt.Color.getHSBColor(v, 1, 1);
        r = newColor.getRed();
        g = newColor.getGreen();
        b = newColor.getBlue();
      }
      
      r = r < 0 ? 0 : r;
      g = g < 0 ? 0 : g;
      b = b < 0 ? 0 : b;
      
      buffer[i][0] = r > 255 ? 255 : r;
      buffer[i][1] = g > 255 ? 255 : g;
      buffer[i][2] = b > 255 ? 255 : b;
    }
  }
}

