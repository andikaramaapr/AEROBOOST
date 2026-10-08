const int ledPin = 13;
int pwmValue = 0;

void setup() {
  pinMode(ledPin, OUTPUT);
  Serial.begin(9600);
}

void loop() {
  if (Serial.available()) {
    String input = Serial.readStringUntil('\n');
    input.trim();
    if (input.length() > 0) {
      pwmValue = input.toInt();

      // Optional: print to Serial for debugging (comment this if needed)
      Serial.print("PWM: ");
      Serial.println(pwmValue);

      // 100 km/h ≈ PWM 73 based on map(0–350 km/h → 0–255)
      if (pwmValue >= 73) {
        digitalWrite(ledPin, HIGH);
      } else {
        digitalWrite(ledPin, LOW);
      }
    }
  }
}
