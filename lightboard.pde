import promidi.*;
import processing.serial.*;

ArrayList<PatternGenerator> leftGenerators;
ArrayList<PatternGenerator> rightGenerators;
ArrayList<int[][]> leftBuffers;
ArrayList<int[][]> rightBuffers;

int[][] outputBuffer;

int[][] stripBuffer;

int currentLeftGenerator;
int currentRightGenerator;

int bufferSize = 240;

int mixLevel = 0;

int masterBrightness = 127;
int masterSaturation = 127;

boolean noteLock[][] = new boolean[8][64];

PixelGenerator stripGenerator;

MidiIO midiIO;
Serial serialIO;

void setup() {
  leftGenerators = new ArrayList<PatternGenerator>();
  rightGenerators = new ArrayList<PatternGenerator>();
  leftBuffers = new ArrayList<int[][]>();
  rightBuffers = new ArrayList<int[][]>();
  
  leftGenerators.add(new StaticColorG());
  rightGenerators.add(new StaticColorG());
  leftBuffers.add(new int[bufferSize][3]);
  rightBuffers.add(new int[bufferSize][3]);

  leftGenerators.add(new SingleColorG());
  rightGenerators.add(new SingleColorG());
  leftBuffers.add(new int[bufferSize][3]);
  rightBuffers.add(new int[bufferSize][3]);

  leftGenerators.add(new DiscoG());
  rightGenerators.add(new DiscoG());
  leftBuffers.add(new int[bufferSize][3]);
  rightBuffers.add(new int[bufferSize][3]);

  leftGenerators.add(new PlasmaG());
  rightGenerators.add(new PlasmaG());
  leftBuffers.add(new int[bufferSize][3]);
  rightBuffers.add(new int[bufferSize][3]);

  outputBuffer = new int[bufferSize][3];

  stripGenerator = new PixelGenerator();
  stripBuffer = new int[4][3];

  midiIO = MidiIO.getInstance(this);
  println("MIDI");
  midiIO.printDevices();

  println("SERIAL");
  println(Serial.list());

  serialIO = new Serial(this, Serial.list()[4], 230400);  

  for (int i = 0;i<8;i++) {
    midiIO.openInput(0, i);
  }

  size(800, 600);
  background(0, 0, 0);

  currentLeftGenerator = 0;
  currentRightGenerator = 1;
}

void draw() {
  int x = 20;
  int y = 20;
  for (int i = 0;i< leftGenerators.size();i++) {
    int[][] buffer = leftBuffers.get(i);
    leftGenerators.get(i).GetFrame(buffer);
    for (int j = 0;j<bufferSize;j++) {
      stroke(buffer[j][0], buffer[j][1], buffer[j][2]);
      line(x+j, y, x+j, y+10);
    }
    y += 30;
  }

  y = 20;
  x = 300;

  for (int i = 0;i< rightGenerators.size();i++) {
    int[][] buffer = rightBuffers.get(i);
    rightGenerators.get(i).GetFrame(buffer);
    for (int j = 0;j<bufferSize;j++) {
      stroke(buffer[j][0], buffer[j][1], buffer[j][2]);
      line(x+j, y, x+j, y+10);
    }
    y += 30;
  }

  y += 30;

  int[][] lbuffer = leftBuffers.get(currentLeftGenerator);
  int[][] rbuffer = rightBuffers.get(currentRightGenerator);

  x = 20;
  for (int j = 0;j<bufferSize;j++) {
    stroke(lbuffer[j][0], lbuffer[j][1], lbuffer[j][2]);
    line(x+j, y, x+j, y+10);
  }

  x = 300;
  for (int j = 0;j<bufferSize;j++) {
    stroke(rbuffer[j][0], rbuffer[j][1], rbuffer[j][2]);
    line(x+j, y, x+j, y+10);
  }


  float leftMix = (127-mixLevel) / 127.0;
  float rightMix = (mixLevel) / 127.0;

  for (int j = 0;j<bufferSize;j++) {
    outputBuffer[j][0] = int(lbuffer[j][0] * leftMix + rbuffer[j][0] * rightMix);
    outputBuffer[j][1] = int(lbuffer[j][1] * leftMix + rbuffer[j][1] * rightMix);
    outputBuffer[j][2] = int(lbuffer[j][2] * leftMix + rbuffer[j][2] * rightMix);

    float[] hsb = java.awt.Color.RGBtoHSB(outputBuffer[j][0], outputBuffer[j][1], outputBuffer[j][2], null);
    java.awt.Color newColor = java.awt.Color.getHSBColor(hsb[0], hsb[1] * (masterSaturation / 127.0), hsb[2] * (masterBrightness / 127.0));

    outputBuffer[j][0] = newColor.getRed();
    outputBuffer[j][1] = newColor.getGreen();
    outputBuffer[j][2] = newColor.getBlue();
  }

  y += 30;
  x = 150;  
  for (int j = 0;j<bufferSize;j++) {
    stroke(outputBuffer[j][0], outputBuffer[j][1], outputBuffer[j][2]);
    line(x+j, y, x+j, y+10);
  }

  x = 600;
  
  stripGenerator.GetFrame(stripBuffer);
  drawColorIndicator(stripBuffer[0][0], stripBuffer[0][1], stripBuffer[0][2], x, y);
  drawColorIndicator(stripBuffer[1][0], stripBuffer[1][1], stripBuffer[1][2], x+60, y);
  drawColorIndicator(stripBuffer[2][0], stripBuffer[2][1], stripBuffer[2][2], x, y+80);
  drawColorIndicator(stripBuffer[3][0], stripBuffer[3][1], stripBuffer[3][2], x+60, y+80);

  writePixelBuffer(outputBuffer);
  writeStripBuffer(stripBuffer);
}

void drawColorIndicator(int r, int g, int b, int x, int y) {
  stroke(0, 0, 0);
  fill(r, 0, 0);
  rect(x, y, 20, 40);

  fill(0, g, 0);
  rect(x+20, y, 20, 40);

  fill(0, 0, b);
  rect(x+40, y, 20, 40);

  fill(r, g, b);
  rect(x, y+40, 60, 40);
}

void outputArray(int[] data) {
  for (int i = 0;i< data.length;i++) {
    serialIO.write(data[i]);
  }
}

void writeStripBuffer(int[][] buffer) {
  for (int i = 0;i<4;i++) {
    int c1 = buffer[i][0] == 0 ? 1 : buffer[i][0];
    int c2 = buffer[i][1] == 0 ? 1 : buffer[i][1];
    int c3 = buffer[i][2] == 0 ? 1 : buffer[i][2];

    outputArray(new int[] {
      0, i + 64, c1, c2, c3
    }
    );
  }
}

void writePixelBuffer(int[][] buffer) {
  outputArray(new int[] {
    0, 2, 1, buffer.length
  }
  );
  for (int i = 0;i<240;i++) {
    serialIO.write(buffer[i][0] == 0 ? 1 : buffer[i][0]);
    serialIO.write(buffer[i][1] == 0 ? 1 : buffer[i][1]);
    serialIO.write(buffer[i][2] == 0 ? 1 : buffer[i][2]);
  }
}

void controllerIn(Controller controller, int device, int channel) {
  int num = controller.getNumber();
  int val = controller.getValue();

  val = val < 10 ? 0 : val;

  if (num == 16) {
    leftGenerators.get(currentLeftGenerator).param1 = val+1;
  }

  if (num == 18) {
    rightGenerators.get(currentRightGenerator).param1 = val+1;
  }
  
  if (num == 17) {
    leftGenerators.get(currentLeftGenerator).param2 = val+1;
  }

  if (num == 19) {
    rightGenerators.get(currentRightGenerator).param2 = val+1;
  }


  if (num == 15) {
    mixLevel = val;
  }

  if (channel == 0 && num == 7) {
    masterSaturation = val;
  }

  if (channel == 1 && num == 7) {
    masterBrightness= val;
  }

  if (channel > 3 && channel < 8 && num == 7) {
    stripGenerator.SetBrightness(channel - 4, val);
  } 

  print("c: ");
  print(channel);

  print(" number: ");
  print(num);

  print(" value: ");
  println(val);
}

void noteOn(Note note, int device, int channel) {
  int vel = note.getVelocity();
  int pit = note.getPitch();

  if (channel < 8 && pit < 64) {
    if (noteLock[channel][pit] == true) {
      return;
    }
    noteLock[channel][pit] = true;
  }

  if (channel == 6 && pit-53 < (leftGenerators.size()) && pit > 52) {
    currentLeftGenerator = pit-53;
  }

  if (channel == 7 && pit-53 < (rightGenerators.size()) && pit > 52 ) {
    currentRightGenerator = pit-53;
  }

  if (channel < 3 && pit > 52 && pit < 57) {
    stripGenerator.Toggle(pit-53, channel);
  }
  
  if (channel == 4 && pit == 53) {
    stripGenerator.RotatePatern();
  }

  if (channel < 3 && pit == 52) {
    stripGenerator.Off(0, channel);
    stripGenerator.Off(1, channel);
    stripGenerator.Off(2, channel);
    stripGenerator.Off(3, channel);
  }

  if (channel == 3 && pit > 52 && pit < 57) {
    stripGenerator.Off(pit-53, 0);
    stripGenerator.Off(pit-53, 1);
    stripGenerator.Off(pit-53, 2);
  }


  print("NON c: ");
  print(channel);

  print(" vel: ");
  print(vel);

  print(" pit: ");
  println(pit);
}

void noteOff(Note note, int device, int channel) {
  int vel = note.getVelocity();
  int pit = note.getPitch();

  if (channel < 8 && pit < 64) {
    noteLock[channel][pit] = false;
  }

  print("NOff c: ");
  print(channel);

  print(" vel: ");
  print(vel);

  print(" pit: ");
  println(pit);
}

