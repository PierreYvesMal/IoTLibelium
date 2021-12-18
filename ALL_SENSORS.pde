/*  
 *  --[Ag_v30_01] - Temperature sensor reading
 *  
 *  Explanation: Turn on the Agriculture v30 board and read the 
 *  temperature,humidity and pressure once every second
 *  
 *  Copyright (C) 2016 Libelium Comunicaciones Distribuidas S.L. 
 *  http://www.libelium.com 
 *  
 *  This program is free software: you can redistribute it and/or modify 
 *  it under the terms of the GNU General Public License as published by 
 *  the Free Software Foundation, either version 3 of the License, or 
 *  (at your option) any later version. 
 *  
 *  This program is distributed in the hope that it will be useful, 
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of 
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
 *  GNU General Public License for more details. 
 *  
 *  You should have received a copy of the GNU General Public License 
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>. 
 *  
 *  Version:           3.0 
 *  Design:            David Gascón 
 *  Implementation:    Carlos Bello
 */
#include <WaspLoRaWAN.h>
#include <WaspSensorAgr_v30.h>

//MESSAGE TEMPLATE
//TEMP+HUM+PRES+FREQ1+FREQ2+FREQ3+TEMPpt
//FLOAT -> *10 -> int -> char -> send
//In python on reception : receive-> float -> /10

  ///////////////////////////////////////
  // 1.WHITE
  /////////////////////////////////////// 
// Variable to store the read value
float temp,humd,pres;

  ///////////////////////////////////////
  // 2. GREEN
  ///////////////////////////////////////

// Variable to store the read value
float watermark1, watermark2, watermark3;
//Instance objects
watermarkClass wmSensor1(SOCKET_1);
watermarkClass wmSensor2(SOCKET_2);
watermarkClass wmSensor3(SOCKET_3);

  ///////////////////////////////////////
  // 3. BLACK
  ///////////////////////////////////////
//Variable to store the read value
float value;
//Instance object
pt1000Class pt1000Sensor;

  ///////////////////////////////////////
  // 4. LORAWAN
  ///////////////////////////////////////
//CONVERTION
float measuresFl[7];


// socket to use
uint8_t socket = SOCKET0;

// Device parameters for Back-End registration
char DEVICE_EUI[]  = "70B3D57ED0049A94";
char APP_EUI[] = "0102030405060708";
char APP_KEY[] = "01020304050607080910111213141516";

// Define port to use in Back-End: from 1 to 223
uint8_t PORT = 3;


// Define data payload to send (maximum is up to data rate)
//char data[] = "Bonjour";

// variable
uint8_t error;
uint8_t error_config = 0;

void setup()
{
  // Turn on the USB and print a start message
  USB.ON();
  USB.println(F("Start program"));
  // Turn on the sensor board
  Agriculture.ON(); 
  
  ///////////////////////////////////////
  // 4. LORAWAN
  ///////////////////////////////////////
  //Switch ON
  error = LoRaWAN.ON(socket);

  // Check status
  if( error == 0 ) 
  {
    USB.println(F("1. Switch ON OK"));     
  }
  else 
  {
    USB.print(F("1. Switch ON error = ")); 
    USB.println(error, DEC);
    error_config = 1;
  }
  
 
  // 2. Change data rate

  error = LoRaWAN.setDataRate(3);

  // Check status
  if( error == 0 ) 
  {
    USB.println(F("2. Data rate set OK"));     
  }
  else 
  {
    USB.print(F("2. Data rate set error= ")); 
    USB.println(error, DEC);
     error_config = 2;
  }

  // 3. Set Device EUI

  error = LoRaWAN.setDeviceEUI(DEVICE_EUI);

  // Check status
  if( error == 0 ) 
  {
    USB.println(F("3. Device EUI set OK"));     
  }
  else 
  {
    USB.print(F("3. Device EUI set error = ")); 
    USB.println(error, DEC);
    error_config = 3;
  }

  // 4. Set Application EUI

  error = LoRaWAN.setAppEUI(APP_EUI);

  // Check status
  if( error == 0 ) 
  {
    USB.println(F("4. Application EUI set OK"));     
  }
  else 
  {
    USB.print(F("4. Application EUI set error = ")); 
    USB.println(error, DEC);
    error_config = 4;
  }

  // 5. Set Application Session Key

  error = LoRaWAN.setAppKey(APP_KEY);

  // Check status
  if( error == 0 ) 
  {
    USB.println(F("5. Application Key set OK"));     
  }
  else 
  {
    USB.print(F("5. Application Key set error = ")); 
    USB.println(error, DEC);
    error_config = 5;
  }

  // 6. Join OTAA to negotiate keys with the server
  
  error = LoRaWAN.joinOTAA();

  // Check status
  if( error == 0 ) 
  {
    USB.println(F("6. Join network OK"));         
  }
  else 
  {
    USB.print(F("6. Join network error = ")); 
    USB.println(error, DEC);
    error_config = 6;
  }


  // 7. Save configuration

  error = LoRaWAN.saveConfig();

  // Check status
  if( error == 0 ) 
  {
    USB.println(F("7. Save configuration OK"));     
  }
  else 
  {
    USB.print(F("7. Save configuration error = ")); 
    USB.println(error, DEC);
    error_config = 7;
  }

  // 8. Switch off

  error = LoRaWAN.OFF(socket);

  // Check status
  if( error == 0 ) 
  {
    USB.println(F("8. Switch OFF OK"));     
  }
  else 
  {
    USB.print(F("8. Switch OFF error = ")); 
    USB.println(error, DEC);
    error_config = 8;
  }
  
  if (error_config == 0){
    USB.println(F("\n---------------------------------------------------------------"));
    USB.println(F("Module configured"));
    USB.println(F("After joining through OTAA, the module and the network exchanged "));
    USB.println(F("the Network Session Key and the Application Session Key which "));
    USB.println(F("are needed to perform communications. After that, 'ABP mode' is used"));
    USB.println(F("to join the network and send messages after powering on the module"));
    USB.println(F("---------------------------------------------------------------\n"));
    USB.println();  
  }
  else{
    USB.println(F("\n---------------------------------------------------------------"));
    USB.println(F("Module not configured"));
    USB.println(F("Check OTTA parameters and restart the code."));
    USB.println(F("If you continue executing the code, frames might not be sent even"));
    USB.println(F("though the code prints: Send unconfirmed packet OK"));
    USB.println(F("\n---------------------------------------------------------------"));
    
  }

}
 
void loop()
{
  ///////////////////////////////////////
  // 1.WHITE
  /////////////////////////////////////// 

  USB.println(F("###White Sensor###"));
  temp = Agriculture.getTemperature()*100;
  measuresFl[0]=temp;
  humd  = Agriculture.getHumidity()*100;
  measuresFl[1]=humd;
  pres = Agriculture.getPressure()/10;//hpa //REVOIR SI CEST PAS TROP ABREGE 
  measuresFl[2]=pres; 

  USB.print(F("Temperature: "));
  USB.print(temp/100);
  USB.println(F(" Celsius"));
  USB.print(F("Humidity: "));
  USB.print(humd/100);
  USB.println(F(" %"));  
  USB.print(F("Pressure: "));
  USB.print(pres/100);
  USB.println(F(" kPa"));  
  USB.println(); 


  ///////////////////////////////////////
  // 2. GREEN
  ///////////////////////////////////////
  USB.println(F("###Green Sensor###"));
  // Part 1: Read the Watermarks sensors one by one 
  USB.println(F("Wait for Watermark 1..."));
  watermark1 = wmSensor1.readWatermark()*100; 
  measuresFl[3]=watermark1;     
  
  USB.println(F("Wait for Watermark 2..."));  
  watermark2 = wmSensor2.readWatermark()*100;  
  measuresFl[4]=watermark2;    
  
  USB.println(F("Wait for Watermark 3..."));  
  watermark3 = wmSensor3.readWatermark()*100; 
  measuresFl[5]=watermark3;     
  
  // Part 2: USB printing
  // Print the watermark measures
  USB.print(F("Watermark 1 - Frequency: "));
  USB.print(watermark1);
  USB.println(F(" Hz"));
  USB.print(F("Watermark 2 - Frequency: "));
  USB.print(watermark2);
  USB.println(F(" Hz"));  
  USB.print(F("Watermark 3 - Frequency: "));
  USB.print(watermark3);
  USB.println(F(" Hz"));  
  USB.println();

  ///////////////////////////////////////
  // 3. BLACK
  ///////////////////////////////////////
  USB.println(F("###Black Sensor###"));
  // Part 1: Read the PT1000 sensor 
  value = pt1000Sensor.readPT1000()*100;  
  measuresFl[6]=value;
  
  // Part 2: USB printing
  // Print the PT1000 temperature value through the USB
  USB.print(F("PT1000: "));
  USB.printFloat(value,3);
  USB.println(F(" ºC")); 

  ///////////////////////////////////////
  // 4. LORAWAN
  ///////////////////////////////////////


//MESSAGE TEMPLATE
//TEMP+HUM+PRES+FREQ1+FREQ2+FREQ3+TEMPpt  %.2f
//FLOAT -> *100 -> int -> char -> send
//In python on reception : receive-> float -> /100

//We have 7 data of 4 char => 28 char needed => 30 char (multiple of 6)

char data[30];

float temp;
int tempInt;
//char test[30];

//TODO : remplir les char à pd des float EN RAW
for(short measure=0;measure<7;measure++)
{
  //2734.5
  temp=measuresFl[measure]/1000;//2.7345
  //USB.print(F("\ntemp: "));  USB.print(temp);
  for(short i=0;i<4;i++)
  {
    
    tempInt=(int)temp;//2
    //USB.print(F("\nThe value is :"));    USB.print(tempInt);
    data[measure*4+i]='0'+tempInt;//2
    //USB.print(data[measure+i]);
    temp-=tempInt;//0.7345
    temp*=10;//7.345
  }
}
data[29]='0';
data[28]='0';
USB.println();
USB.println(F("###Final message###"));
for(int i=0;i<30;i++)USB.print(data[i]);
USB.println();
USB.println();
//Needs to be a multiple of 6
    //char data[] = "010402";
    
USB.println(F("###Sending message###"));
  // 1. Switch on

  error = LoRaWAN.ON(socket);

  // Check status
  if( error == 0 ) 
  {
    USB.println(F("1. Switch ON OK"));     
  }
  else 
  {
    USB.print(F("1. Switch ON error = ")); 
    USB.println(error, DEC);
  }

  // 2. Join network

  error = LoRaWAN.joinABP();

  // Check status
  if( error == 0 ) 
  {
    USB.println(F("2. Join network OK"));     

    // 3. Send unconfirmed packet 

    error = LoRaWAN.sendUnconfirmed( PORT, data);

    // Error messages:
    /*
     * '6' : Module hasn't joined a network
     * '5' : Sending error
     * '4' : Error with data length   
     * '2' : Module didn't response
     * '1' : Module communication error   
     */
    // Check status
    if( error == 0 ) 
    {
      USB.println(F("3. Send unconfirmed packet OK"));  
      if (LoRaWAN._dataReceived == true)
      { 
        USB.print(F("   There's data on port number "));
        USB.print(LoRaWAN._port,DEC);
        USB.print(F(".\r\n   Data: "));
        USB.println(LoRaWAN._data);
      }   
    }
    else 
    {
      USB.print(F("3. Send unconfirmed packet error = ")); 
      USB.println(error, DEC);
    } 
  }
  else 
  {
    USB.print(F("2. Join network error = ")); 
    USB.println(error, DEC);
  }

  // 4. Switch off

  error = LoRaWAN.OFF(socket);

  // Check status
  if( error == 0 ) 
  {
    USB.println(F("4. Switch OFF OK"));     
  }
  else 
  {
    USB.print(F("4. Switch OFF error = ")); 
    USB.println(error, DEC);
    USB.println();
  }
  USB.println("------------------------------------");
  USB.println();
  delay(2000);
  
}
