/*
  BeanLock
 
  Example of a relay controlled lock using the LightBlue Bean

The MIT License (MIT)

Copyright (c) 2014 Paul Wilkinson

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

 */

int ledTimeout=0;
int LEDTIME=10;    // LED time is 5 seconds (sleep for 500ms every loop)
int state=0;
String collectedPassword;
int selectedLock;
String thePassword="OpenSesame";

// the setup routine runs once when you press reset:
void setup() {
  // initialize serial communication at 57600 bits per second:
  Serial.begin(57600);
  // this makes it so that the arduino read function returns
  // immediatly if there are no less bytes than asked for.
  Serial.setTimeout(25);
  //Set pin 0 to Output mode
  pinMode(0,OUTPUT);
  pinMode(1,OUTPUT);
  closeLock(0);
  closeLock(1);
  
}

// the loop routine runs over and over again forever:
void loop() {
  char buffer[64];
  size_t length = 64; 
      
  length = Serial.readBytes(buffer, length);    
  
  if ( length > 0 )
  
  processBytes(buffer,length);
  
  Bean.sleep(500);
  if (ledTimeout >0) {
    ledTimeout--;
    if (ledTimeout == 0) {      // Turn off the LED after required time
      Bean.setLed(0,0,0);
    }
  }
}

// State machine to process incoming data - Format is <STX>password<ETX>
// STX=0x02 (^B)
// ETX=0x03 (^C)

void processBytes(char buffer[], size_t length) {
  for (int i=0;i<length;i++) {
    char b=buffer[i];
    
    switch (state) {
      case 0:
          if (b==2) {
            state=1;
            collectedPassword="";
          }
          break;
      case 1:
          if (b==2) {
            state=1;
          }
          else if (b=='0') {
            selectedLock=0;
            state=2;
          }
          else if (b=='1') {
            selectedLock=1;
            state=2;
          }
          else {
            error();
            state=0;
          }
          break;
          
      case 2:
          if (b==2) {
            state=1;
            collectedPassword="";
            error();
          } else if (b==3) {
            denied();
            state=0;
          }
          else {
            collectedPassword=collectedPassword+String(b);
            if (collectedPassword.length() == thePassword.length()) {
              state=3;
            }
          }
          break;
      case 3:
           if (b==3) {
              if (collectedPassword == thePassword) {
                 ok();  
                 pulseLock(selectedLock,2); 
                 closed();
                 state=0;    
              }
              else {
                denied();
                state=0;
              }
           } else if (b==2) {
               state=1;
               error();
           }
           else {
               state=0;
               collectedPassword="";
           }
           break;
    }
  }   
}

// Send various status messages

void error() {
  Serial.println("Error");
  Bean.setLed(0,0,255);
  ledTimeout=LEDTIME;
}

void ok() {
  Serial.println("OK");
}


void closed() {
  Serial.println("Closed");
}

void denied() {
  Serial.println("No");
  Bean.setLed(241,196,15);
  ledTimeout=LEDTIME;
}

// Pulse the lock open for a specified time

void pulseLock(int lock,int time) {
 openLock(lock);
 delay(time*1000 );  
 closeLock(lock);
}


// Open the lock
// The relay board has an active-low input

void openLock(int lock) {
  digitalWrite(lock,LOW);
  Bean.setLed(0,255,0);
  ledTimeout=LEDTIME;
}


// Close the lock
void closeLock(int lock) {
  digitalWrite(lock,HIGH);
  Bean.setLed(255,0,0);
  ledTimeout=LEDTIME;
}

