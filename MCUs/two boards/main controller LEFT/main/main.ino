void setup() {
        // 初始化主串口（Serial0）
  Serial1.begin(115200);      // 初始化第二个串口（Serial1）
}

void loop() {
  Serial1.println("hello world");
  delay(1000);
}