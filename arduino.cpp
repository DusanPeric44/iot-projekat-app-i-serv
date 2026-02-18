#include <WiFi.h>
#include <WebSocketsServer.h>

const char* ssid = "ESP32-HEALTH";
const char* password = "12345678";

WebSocketsServer webSocket = WebSocketsServer(81);

const int ecgPin = 34;      // AD8232 OUTPUT → GPIO 34 (ADC)
const int tempPin = 35;     // TMP36 → GPIO 35 (ADC)

// TMP36 constants
// 10mV per degree, 500mV offset
float readTemperatureC() {
  int raw = analogRead(tempPin);
  float voltage = (raw / 4095.0) * 3.3;   // ESP32 ADC reference 3.3V
  float tempC = (voltage - 0.5) * 100.0;  // TMP36 formula
  return tempC;
}

void onEvent(uint8_t num, WStype_t type, uint8_t * payload, size_t lenght) {
  if (type == WStype_CONNECTED) {
    Serial.println("Client connected.");
  }
}

void setup() {
  Serial.begin(115200);

  WiFi.mode(WIFI_AP);
  WiFi.softAP(ssid, password);

  webSocket.begin();
  webSocket.onEvent(onEvent);

  Serial.println("Health Monitor Ready...");
}

void loop() {
  webSocket.loop();

  int ecg = analogRead(ecgPin);
  float temp = readTemperatureC();

  // format: ECG:1234;TEMP:36.7
  String data = "ECG:" + String(ecg) + ";TEMP:" + String(temp, 2);

  webSocket.broadcastTXT(data);

  delay(5); // ~200 Hz
}
