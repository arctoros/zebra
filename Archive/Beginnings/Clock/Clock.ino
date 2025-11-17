#define CLOCK_PIN 13

enum Mode { ASTABLE, MONOSTABLE };
Mode mode = ASTABLE;

volatile unsigned long clockRate = 1; // Default 1 Hz
volatile bool clockRunning = false;

void setup() {
  pinMode(CLOCK_PIN, OUTPUT);
  digitalWrite(CLOCK_PIN, LOW); // Ensure the clock starts LOW
  Serial.begin(115200);
}

void loop() {
  // Check for serial input
  if (Serial.available() > 0) {
    String input = Serial.readStringUntil('\n');
    input.trim(); // Trim whitespace and newline characters
    processCommand(input);
  }

  if (mode == ASTABLE && clockRunning) {
    static unsigned long lastToggle = 0;
    unsigned long interval = 1000 / (2 * clockRate); // Interval for half-period in ms

    if (millis() - lastToggle >= interval) {
      digitalWrite(CLOCK_PIN, !digitalRead(CLOCK_PIN)); // Toggle clock signal
      lastToggle = millis();
    }
  }
}

void processCommand(String command) {
  if (command.startsWith("a")) {
    mode = ASTABLE;
    clockRunning = false;
    Serial.println("Mode: Astable");
  } else if (command.startsWith("m")) {
    mode = MONOSTABLE;
    clockRunning = false;
    Serial.println("Mode: Monostable");
  } else if (command.startsWith("r")) {
    if (mode == ASTABLE) {
      clockRate = command.substring(1).toInt();
      Serial.print("Rate set to: ");
      Serial.print(clockRate);
      Serial.println(" Hz");
    }
  } else if (command == "p") {
    if (mode == ASTABLE) {
      clockRunning = true;
      Serial.println("Clock started.");
    } else if (mode == MONOSTABLE) {
      pulseClock(1);
    }
  } else if (command.startsWith("p")) {
    if (mode == MONOSTABLE) {
      pulseClock(command.substring(1).toInt());
    }
  } else if (command == "h") {
    if (mode == ASTABLE) {
      clockRunning = false;
      digitalWrite(CLOCK_PIN, LOW); // Ensure clock is low when halted
      Serial.println("Clock halted.");
    }
  } else {
    Serial.println("Unknown command.");
  }
}

void pulseClock(int count) {
  for (int i = 0; i < count; i++) {
    digitalWrite(CLOCK_PIN, HIGH);
    delay(500 / clockRate); // Half-period high
    digitalWrite(CLOCK_PIN, LOW);
    delay(500 / clockRate); // Half-period low
  }

  Serial.print("Pulsed ");
  Serial.print(count);
  Serial.println(" times.");
}