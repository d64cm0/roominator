#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#include <SPI.h>
#include <Wire.h>
#include <Ethernet.h>


byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED }; //mac address of master arduino
byte ip[] = { 10, 99, 33, 128 }; //IP address of arduino
byte gateway[] = { 10, 99, 33, 254 }; //IP address of router in office
byte subnet[] = { 255, 255, 254, 0 }; //subnet mask of office network

byte server[] = {10, 99, 32, 130 }; //My comp

int slaves[] = { 1 }; //Put addresses for slaves here

Client client(server, 3000);

void setup()
{
  Serial.begin(9600);  //For debugging, take out eventually
  Wire.begin(); //join bus as master
  Ethernet.begin(mac, ip, gateway, subnet);
  delay(1000);   
}

void loop()
{
  //Loop over addresses 1 thru 9
  for(int i = 1; i < 9; i++)
  {
    Wire.requestFrom(i,2); //request 2 bytes from slave
    if(Wire.available()) //if the slave is responsive
    {  
      Serial.print("Got data from slave: ");
      Serial.println(i);  
      int cancel = (int) Wire.receive();           
      
      Serial.print("Cancel byte is: ");
      Serial.println(cancel);
      
      int reserveCount = (int) Wire.receive();      
      Serial.print("rsv byte is: ");
      Serial.println(reserveCount);
      
      char* message = (char*) malloc(100);
      generatePostRequest(1, reserveCount, cancel, message);
      Serial.print("Message to server is: ");
      Serial.println(message);
 
      while(!client.connect())
      {
        Serial.println("Could not connect, trying again");
      }
      Serial.println("Connected");
      //Send request
      client.println(message);
      client.println();
      free(message);
      
      while(!client.available())
      {
        Serial.println("server response not available yet");
        //nop
      }
 
      char* response = (char*) malloc(500);
      parseHttpResponse(response);
      sendDownstreamPacket(i, response);
      free(response);

      client.stop();
      Serial.println("Disconnected from server");
      
    }
    else
    {
      Serial.print("Slave was not responsive: ");
      Serial.println(i);
    }
  }
}


void sendDownstreamPacket(int id, char* message)
{
  Serial.print("In send Downstream packet, the packet I would have sent is: ");
  Serial.print(message);
  Serial.print(" to id:");
  Serial.println(id);
}

//Parses http response and stores downstreampacket in message
void parseHttpResponse(char* message)
{
  throwAwayHeader();
  message[0] = (char) 0;
  int count = 1;
  while(client.available())
  {
    char c = client.read();
    //Got ending char
    if(((int) c) == 200)
    {
      Serial.println("Got the second 200 integer from the websever, message is now done");
      client.flush();
      return;
    }
    message[count] = c;
    count++;
  }
}

void throwAwayHeader()
{
  while(client.available())
 {
   int c = (int) client.read();
   if(c == 200) 
   {
     //Return with next digit to be the message
     Serial.println("Got the 200 integer from the webserver");
     return;  
   }
 } 
}



void generatePostRequest(int id, int reservationCount, int cancelCount, char* message)
{
  char temp[5];
  
  strcpy(message, "GET /room/report?id=");
  sprintf(temp, "%u", id);
  strcat(message, temp); 
  
  strcat(message, "&rsv=");
  sprintf(temp, "%u", reservationCount);
  strcat(message, temp);

  strcat(message, "&cancel=");
  sprintf(temp, "%u", cancelCount);
  strcat(message, temp);
  
  strcat(message, " HTTP/1.0");
  
  Serial.print("String returned from generate(while in func): ");
  Serial.println(message);  
}

