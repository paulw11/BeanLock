/*
  Serial Loopback Test
 
  Reads all bytes on the serial input and sends them right
  back to the sender.

  This example code is in the public domain.
 */

int ledTimeout=0;
int LEDTIME=10;
int state=0;
String collectedPassword;
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
  closeLock();
  
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
    if (ledTimeout == 0) {
      Bean.setLed(0,0,0);
    }
  }
}

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
            collectedPassword="";
            error();
          } else if (b==3) {
            denied();
            state=0;
          }
          else {
            collectedPassword=collectedPassword+String(b);
            if (collectedPassword.length() == thePassword.length()) {
              state=2;
            }
          }
          break;
      case 2:
           if (b==3) {
              if (collectedPassword == thePassword) {
                 pulseLock(10); 
                 ok();  
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

void error() {
  Serial.println("Error");
  Bean.setLed(0,0,255);
  ledTimeout=LEDTIME;
}

void ok() {
  Serial.println("OK");
}

void denied() {
  Serial.println("No");
  Bean.setLed(241,196,15);
  ledTimeout=LEDTIME;
}

void pulseLock(int time) {
 openLock();
 delay(time*1000 );  
 closeLock();
}


void openLock() {
  digitalWrite(0,HIGH);
  Bean.setLed(0,255,0);
  ledTimeout=LEDTIME;
}



void closeLock() {
  digitalWrite(0,LOW);
  Bean.setLed(255,0,0);
  ledTimeout=LEDTIME;
}

