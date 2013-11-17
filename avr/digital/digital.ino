#include "FastSPI_LED2.h"

// How many leds are in the strip?
#define NUM_LEDS 240

// Data pin that led data will be written out over
#define DATA_PIN 14

// This is an array of leds.  One item for each led in your strip.
CRGB leds[NUM_LEDS];

void setup() {
      FastLED.addLeds<WS2811, DATA_PIN, GRB>(leds, NUM_LEDS);
      Serial.begin(115200);
      pinMode(1, OUTPUT);
      digitalWrite(1, LOW);
      Serial.println("RGB Led Controller");
      Serial.println("==================");
}

char shift = 0;
int incomingByte = 0;

void loop() {
   CRGB color = CRGB::White;
   for(int whiteLed = 0; whiteLed < NUM_LEDS; whiteLed = whiteLed + 1) {
      color.setHSV(whiteLed + shift, 255, 64);
      leds[whiteLed] = color;
   }
   FastLED.show();
   shift+=1;
   if (Serial.available() > 0) {
     incomingByte = Serial.read();
     Serial.print(incomingByte);
   }
}
