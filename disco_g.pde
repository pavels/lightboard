import java.util.*;

class DiscoG extends PatternGenerator {
  int lastTime = 0;
  
  int[][] colors = {
   {255,0,0},
   {0,255,0},
   {0,0,255}, 
   {255,0,255},
   {255,255,0},
   {0,255,255}
  };

  DiscoG(){
    param1 = 64;
  }

  void GetFrame(int[][] buffer) {
    if (millis() - lastTime >= 40000 / (param1)) {
      lastTime = millis();
      Collections.shuffle(Arrays.asList(colors));
    }
    int colorPos = 0;
    for (int i=0;i<buffer.length;i++) {
      buffer[i][0] = colors[colorPos][0];
      buffer[i][1] = colors[colorPos][1];
      buffer[i][2] = colors[colorPos][2];
      if(i != 0 && i % 40 == 0){
        colorPos++;
        colorPos = colorPos > 4 ? 0 : colorPos;
      }
    }
  }
}

