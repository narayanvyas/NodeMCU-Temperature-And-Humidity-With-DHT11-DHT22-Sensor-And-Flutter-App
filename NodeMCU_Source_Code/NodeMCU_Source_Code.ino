/*  NodeMCU ESP8266 Temperature And Humidity With DHT11 / DHT22 Sensor And Flutter App
 *   
 *  GitHub URL - https://github.com/narayanvyas/NodeMCU-Temperature-And-Humidity-With-DHT11-DHT22-Sensor-And-Flutter-App
 * 
 *  Developed By Web Dev Fusion
 *  URL - https://www.webdevfusion.com
 *  
 * Components
 * ----------
 *  - NodeMCU
 *  - 10KOhm Resistor
 *  - DHT11 / DHT22
 *  - jumper wires  
 *  - Breadboard
 *  
 *  Libraries
 *  ---------
 *  - DHT - https://github.com/adafruit/DHT-sensor-library
 *
 * Connections
 * -----------
 *      DHT       |    NodeMCU
 *  -----------------------------
 *      1         |      3.3V  (Left Pin Number 1)
 *      2         |      4 (Digital Pin 2 On NodeMCU)
 *      3         |      Unplugged (If you have)
 *      4         |      GND
 *      
 */

#include "DHT.h"
#include <ESP8266WiFi.h>
#include <WiFiClient.h>
#include <ESP8266WebServer.h>


/* Set these to your desired credentials. */
const char *ssid = "*****";
const char *password = "*****";

#define DHTPIN 4    // what pin we're connected to
#define DHTTYPE DHT22   // DHT 11  (AM2302)
DHT dht(DHTPIN, DHTTYPE);

float c,f,h;
String dhtData;
boolean sensorError = false;

ESP8266WebServer server(80);

void handleRoot() {
  // Sending sample message if you try to open configured IP Address
  server.send(200, "text/html", "<h1>You are connected</h1>");
}

void setup() {
  Serial.begin(9600);
  //Trying to connect to the WiFi
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print("*");
  }

  // Setting IP Address to 192.168.1.200, you can change it as per your need, you also need to change IP in Flutter app too.
  WiFi.mode(WIFI_STA);
  IPAddress ip(192, 168, 1, 200);
  IPAddress gateway(192, 168, 1, 1);
  IPAddress subnet(255, 255, 255, 0);
  WiFi.config(ip, gateway, subnet);
  Serial.println(WiFi.localIP());
  server.on("/", handleRoot);
  server.on("/dht", sendDhtData);
  server.begin();
  Serial.println("HTTP server started");
  Serial.println("DHT11 Sensor");
  dht.begin();
}

void sendDhtData() {
  server.send(200, "text/plain", dhtData);
}

void loop() {
  server.handleClient();
  c = dht.readTemperature();
  f = dht.readTemperature(true);
  h = dht.readHumidity();
  delay(500);
  // check if returns are valid, if they are NaN (not a number) then something went wrong!
  if (isnan(c) || isnan(h) || isnan(f)) {
    Serial.print("Sensor Not Connected");
    sensorError=true;
  } else {
    Serial.println("Temperature In Celcius: ");
    Serial.print(c);
    Serial.println(" *C");
    Serial.println("Temperature In Fahrenheit: ");
    Serial.println(f);
    Serial.println(" *F");
    Serial.println("Humidity: ");
    Serial.println(h);
    Serial.println(" %");
  }
  // If there is any issue in sensor connections, it will send 000 as String.
  if(sensorError) {
    dhtData = "sensorError";
  }
  else {
    dhtData = String(c) + ' ' + String(f) + ' ' + String(h);
  }
  delay(2000);
}
