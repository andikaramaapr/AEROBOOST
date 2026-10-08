import processing.serial.*;
import java.net.*;
import java.nio.*;

DatagramSocket socket;
Serial myPort;

String debugText = "Waiting for data...";
float lastSpeed = 0;
int lastPWM = 0;

void setup() {
  size(400, 200);
  background(220);
  textAlign(LEFT, TOP);
  textSize(16);
  fill(0);

  // Connect to Arduino - adjust COM port if needed
  println(Serial.list());
  myPort = new Serial(this, Serial.list()[0], 9600);

  // Open UDP socket on port 20777
  try {
    socket = new DatagramSocket(20777);
    socket.setSoTimeout(50); // small timeout so draw() doesn't hang
    println("UDP socket opened on port 20777");
  } catch (Exception e) {
    println("Failed to open UDP socket: " + e);
    exit();
  }
}

void draw() {
  background(220);
  text(debugText, 10, 10);

  try {
    byte[] buf = new byte[512];
    DatagramPacket packet = new DatagramPacket(buf, buf.length);
    socket.receive(packet); // Will timeout if nothing is received

    byte[] data = packet.getData();
    float speed = getFloat(data, 28) * 3.6;  // Convert m/s to km/h

    int pwm = (int)map(speed, 0, 350, 0, 255);
    pwm = constrain(pwm, 0, 255);

    // Send to Arduino
    myPort.write(pwm + "\n");

    // Update debug text
    debugText = "Speed: " + nf(speed, 0, 2) + " km/h\nPWM: " + pwm;

    lastSpeed = speed;
    lastPWM = pwm;

  } catch (SocketTimeoutException ste) {
    // no data this frame, do nothing
  } catch (Exception e) {
    println("UDP Error: " + e.getMessage());
  }
}

// Helper to extract float from byte array at given offset
float getFloat(byte[] data, int pos) {
  int bits = ((data[pos + 3] & 0xFF) << 24) |
             ((data[pos + 2] & 0xFF) << 16) |
             ((data[pos + 1] & 0xFF) << 8)  |
             ((data[pos] & 0xFF));
  return Float.intBitsToFloat(bits);
}
