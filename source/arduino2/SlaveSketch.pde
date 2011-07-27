#include <Wire.h>
#include <LiquidCrystal.h>
#include <NetworkSlave.h>
#include <DisplayController.h>
#include <Reservation.h>
#include <BounceButton.h>
#include <string.h>

NetworkSlave slave;
//DisplayController dc("name");
//LiquidCrystal lcd(7, 8, 9, 10, 11, 12);

//BounceButton reserve(2);
//BounceButton cancel(3);


void setup() {
  //reserve.initialize();
  //cancel.initialize();
  Serial.begin(9600);  
  Wire.begin(1);
  Wire.onReceive(callback); 
}

void loop() {
  
  delay(100);
  Serial.print("My name is: ");
  Serial.println(slave.getName());
  //lcd.setCursor(0,0);
  //lcd.print("Your Name is: ");
  //lcd.print(slave.getName());
  
//  if (reserve.check()) {
//    slave.incrementReservePressed();
//  }
//  
//  if (cancel.check()) {
//    slave.incrementCancelPressed();
//  }
  
}

void callback(int numBytes) {
  slave.parseData(numBytes); 
}

