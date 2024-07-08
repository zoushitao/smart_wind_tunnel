const byte ledPin = 13;
const byte interruptPin = 18;
volatile byte state = LOW;

void setup() {
  Serial.begin(115200);
  pinMode(ledPin, OUTPUT);
  pinMode(interruptPin, INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(interruptPin), blink, FALLING);
}

void loop() {
  digitalWrite(ledPin, state);
  if(state!=LOW){
    Serial.println("pressed");
  }else{
    Serial.println("*");
  }
  delay(2000);
}

void blink() {
  state = !state;
}