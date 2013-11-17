class PixelGenerator {

  boolean[][] toggle;
  int[] brightness;

  PixelGenerator() {
    toggle = new boolean[4][3];
    brightness = new int[4];
  }

  void GetFrame(int buffer[][]) {
    buffer[0][0] = toggle[0][0] ? int(255 * (brightness[0] / 127.0)) : 0;
    buffer[0][1] = toggle[0][1] ? int(255 * (brightness[0] / 127.0)) : 0;
    buffer[0][2] = toggle[0][2] ? int(255 * (brightness[0] / 127.0)) : 0;

    buffer[1][0] = toggle[1][0] ? int(255 * (brightness[1] / 127.0)) : 0;
    buffer[1][1] = toggle[1][1] ? int(255 * (brightness[1] / 127.0)) : 0;
    buffer[1][2] = toggle[1][2] ? int(255 * (brightness[1] / 127.0)) : 0;

    buffer[2][0] = toggle[2][0] ? int(255 * (brightness[2] / 127.0)) : 0;
    buffer[2][1] = toggle[2][1] ? int(255 * (brightness[2] / 127.0)) : 0;
    buffer[2][2] = toggle[2][2] ? int(255 * (brightness[2] / 127.0)) : 0;

    buffer[3][0] = toggle[3][0] ? int(255 * (brightness[3] / 127.0)) : 0;
    buffer[3][1] = toggle[3][1] ? int(255 * (brightness[3] / 127.0)) : 0;
    buffer[3][2] = toggle[3][2] ? int(255 * (brightness[3] / 127.0)) : 0;
  }

  void Toggle(int ch, int c) {
    toggle[ch][c] = !toggle[ch][c];
  }

  void Off(int ch, int c) {
    toggle[ch][c] = false;
  }
  
  void RotatePatern(){
   boolean[] tmp =  toggle[0];
   toggle[0] = toggle[1]; 
   toggle[1] = toggle[2];
   toggle[2] = toggle[3];
   toggle[3] = tmp;
  }


  void SetBrightness(int ch, int b) {
    brightness[ch] = b;
  }
}

