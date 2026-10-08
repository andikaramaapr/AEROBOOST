import processing.serial.*;
import java.net.*;
import java.nio.*;

Serial myPort;
DatagramSocket socket;

volatile float currentSpeed = 0;
volatile int currentPWM = 0;

float lastSentSpeed = -1;
int lastSentPWM = -1;

String debugText = "Waiting for data...";

void setup() {
  size(400, 200);
  textAlign(LEFT, TOP);
  textSize(16);
  fill(0);

  // Setup Serial
  println(Serial.list()); // See COM ports
  myPort = new Serial(this, Serial.list()[0], 9600);

  // Start UDP listener thread
  new Thread(new UDPListener()).start();
}

void draw() {
  background(220);
  text(debugText, 10, 10);

  // Only send new PWM value if it's changed by a threshold
  if (abs(currentPWM - lastSentPWM) > 1) {
    myPort.write(currentPWM + "\n");
    lastSentPWM = currentPWM;
    lastSentSpeed = currentSpeed;
  }

  debugText = "Speed: " + nf(currentSpeed, 0, 2) + " km/h\nPWM: " + currentPWM;
}

class UDPListener implements Runnable {
  public void run() {
    try {
      socket = new DatagramSocket(20777);
      socket.setSoTimeout(100);
      println("UDP listener started on port 20777");
    } catch (Exception e) {
      println("Error starting UDP listener: " + e);
      return;
    }

    while (true) {
      try {
        byte[] buf = new byte[512];
        DatagramPacket packet = new DatagramPacket(buf, buf.length);
        socket.receive(packet);

        byte[] data = packet.getData();
        float speed = getFloat(data, 28) * 3.6; // Convert m/s to km/h
        int pwm = (int)map(speed, 0, 350, 0, 255);
        pwm = constrain(pwm, 0, 255);

        currentSpeed = speed;
        currentPWM = pwm;

      } catch (SocketTimeoutException ste) {
        // Just wait for next packet
      } catch (Exception e) {
        println("UDP Receive Error: " + e.getMessage());
      }
    }
  }
}

// Helper function to read float from byte array
float getFloat(byte[] data, int pos) {
  int bits = ((data[pos + 3] & 0xFF) << 24) |
             ((data[pos + 2] & 0xFF) << 16) |
             ((data[pos + 1] & 0xFF) << 8)  |
             ((data[pos] & 0xFF));
  return Float.intBitsToFloat(bits);
}
