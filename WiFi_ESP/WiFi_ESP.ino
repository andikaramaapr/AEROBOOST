#include <WiFi.h>

// Replace with your Wi-Fi network credentials
const char* ssid = "andiko";
const char* password = "11111111";

void setup() {
  Serial.begin(115200);

  // Connect to Wi-Fi
  WiFi.begin(ssid, password);

  // Wait for connection
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("WiFi connected");
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP()); // Prints the IP address to the Serial Monitor
}

void loop() {
  // Your code here
}
