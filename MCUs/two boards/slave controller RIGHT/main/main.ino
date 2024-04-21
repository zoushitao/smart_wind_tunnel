void setup() {
      // 初始化主串口（Serial0）
  Serial1.begin(9600);      // 初始化第二个串口（Serial1）
}

void loop() {
  delay(1000);
  Serial1.println("Hello from slave!!!");
}