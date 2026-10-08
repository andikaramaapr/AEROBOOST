import processing.serial.*;

Serial myPort;

void setup() {
  size(400, 400);
  myPort = new Serial(this, Serial.list()[0], 9600); // Sesuaikan index jika perlu
}

void receive(byte[] data, String ip, int port) {
  int speed = (data[24] & 0xFF) + ((data[25] & 0xFF) << 8);
  int rpm = (data[26] & 0xFF) + ((data[27] & 0xFF) << 8);
  int gear = data[29];

  println("Speed: " + speed + ", RPM: " + rpm + ", Gear: " + gear);
}


void draw() {
  float rpm = 5000;
  float speed = 120;
  int gear = 3;

  // Kirim data ke Arduino
  myPort.write(rpm + "," + speed + "," + gear + "\n");
  
  delay(100); // Kirim per 100ms
}
