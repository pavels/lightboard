#include <stdint.h>
#include <string.h>
#include <avr/io.h>
#include <avr/interrupt.h>

#define PWM_COUNT 3 * 4

volatile uint8_t pwm_settings[PWM_COUNT];
volatile uint8_t pwm_status[PWM_COUNT];
volatile uint8_t pwm_ports[PWM_COUNT] = {14,15,16,17,9,10,8,7,6,5,3,2};

volatile unsigned char state = 0;

static uint8_t pwm_cnt=0;

ISR(TIMER0_COMPB_vect) {
    uint8_t tmp=0, i=0;

    TCNT0 = 0;
 
    pwm_cnt++;

    if (pwm_cnt==(uint8_t)(255)){
        for (; i<PWM_COUNT; i++) {
          pwm_status[i] = 0;
          digitalWrite(pwm_ports[i], LOW);
        }
    }else{
      for (; i<PWM_COUNT; i++) {    
      	if (pwm_status[i] == 0 && pwm_settings[i] > (255 - pwm_cnt)){
            pwm_status[i] = 1;
            digitalWrite(pwm_ports[i], HIGH);
          }
      }
    } 
}

void setup()
{
  noInterrupts();
  TCCR0A = 0;
  TCCR0B = 0;
  TCNT0 = 0;
  OCR0A = 0;
  OCR0B = 0;

  TCCR0B |= (1<<CS01);
  OCR0B = 0x50;
  TIMSK0 |= (1<<OCIE0B);
  interrupts();

  for (int i=0; i<PWM_COUNT; i++) {               
    pinMode(pwm_ports[i], OUTPUT);
    digitalWrite(pwm_ports[i], LOW);
  }
  
  Serial.begin(230400);
 
}

unsigned char data, address = 0;
unsigned char buffer[3];

void loop()
{
  uint8_t tmp=0, i=0;

   while( Serial.available() > 0 ){
     data = Serial.read();
     if(data == 0){
       state = 1;
     }else if(data > 63 && data < 68 && state == 1){
       address = (data - 64) * 3;
       state = 2;
     }else if(state > 1 && state < 5){
       buffer[state - 2] = data;       
       state++;
       if(state == 5){
        noInterrupts();
        pwm_settings[address] = buffer[0];
        pwm_settings[address+1] = buffer[1];
        pwm_settings[address+2] = buffer[2];
        state = 0;
        interrupts();        
       }
     }else{
       state = 0;
     }
   }
}

