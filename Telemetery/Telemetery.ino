const int dirPin = 11;        // Direction pin (A)
const int speedPin = 12;     // Speed pin (B)
const int redLED = 13;       // LED for PWM == 0
const int greenLED = 10;      // Green LED for PWM > 100

int pwm = 0;
int lastPWM = 0;

const int pwmThreshold = 80;      // Threshold to turn fan ON
const int greenThreshold = 100;   // Threshold for green LED
const int kickStartPWM = 255;
const int kickStartTime = 150;    // Kick duration in ms

void setup() {
  pinMode(dirPin, OUTPUT);
  pinMode(speedPin, OUTPUT);
  pinMode(redLED, OUTPUT);
  pinMode(greenLED, OUTPUT);

  Serial.begin(9600);

  // Initialize all outputs
  digitalWrite(dirPin, LOW);
  analogWrite(speedPin, 0);
  digitalWrite(redLED, LOW);
  digitalWrite(greenLED, LOW);
}

void loop() {
  if (Serial.available()) {
    int incoming = Serial.parseInt();

    if (incoming >= 0 && incoming <= 255) {
      pwm = incoming;

      // --- Red LED when PWM is 0 ---
      if (pwm == 0) {
        digitalWrite(redLED, HIGH);
      } else {
        digitalWrite(redLED, LOW);
      }

      // --- Green LED if above threshold ---
      digitalWrite(greenLED, (pwm > greenThreshold) ? HIGH : LOW);

      // --- Fan control ---
      if (pwm < pwmThreshold) {
        analogWrite(speedPin, 0);
        digitalWrite(dirPin, LOW);
      } else {
        digitalWrite(dirPin, LOW);
        analogWrite(speedPin, kickStartPWM);
        delay(kickStartTime);
        analogWrite(speedPin, pwm);
      }

      // --- Serial debug ---
      Serial.print("PWM: ");
      Serial.print(pwm);
      Serial.print(" | Fan: ");
      Serial.println((pwm < pwmThreshold) ? "OFF" : "ON");

      lastPWM = pwm;
    }
  }
}
