#include <WiFi.h>
#include <WebSocketsClient.h>
#include <OneWire.h>
#include <DallasTemperature.h>

// WIFI
const char* ssid = "realme 9";
const char* password = "dusandusan23";

// SERVER
const char* host = "10.15.225.187";
const uint16_t port = 8080;

// ECG pins
#define ECG_OUTPUT 32
#define LO_MINUS 26
#define LO_PLUS 27

// TEMP pin
#define TEMP_PIN 4

OneWire oneWire(TEMP_PIN);
DallasTemperature sensors(&oneWire);

WebSocketsClient webSocket;

void webSocketEvent(WStype_t type, uint8_t * payload, size_t length) {

  switch(type) {

    case WStype_CONNECTED:
      Serial.println("WebSocket connected");
      break;

    case WStype_DISCONNECTED:
      Serial.println("WebSocket disconnected");
      break;

  }
}

void setup() {

  Serial.begin(9600);

  pinMode(LO_MINUS, INPUT);
  pinMode(LO_PLUS, INPUT);

  sensors.begin();

  // WIFI CONNECT
  WiFi.begin(ssid, password);
  Serial.print("Connecting WiFi");

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("\nWiFi connected");

  // WEBSOCKET CONNECT
  webSocket.begin(host, port, "/");
  webSocket.onEvent(webSocketEvent);

}

void loop() {

  webSocket.loop();

  if ((digitalRead(LO_PLUS) == 1) || (digitalRead(LO_MINUS) == 1)) {
    return;
  }

  int ecgValue = analogRead(ECG_OUTPUT);

  sensors.requestTemperatures();
  float temperature = sensors.getTempCByIndex(0);

  // JSON format
  String payload = "{";
  payload += "\"ecg\":";
  payload += ecgValue;
  payload += ",\"temp\":";
  payload += temperature;
  payload += "}";

  webSocket.sendTXT(payload);

  delay(10);
}
