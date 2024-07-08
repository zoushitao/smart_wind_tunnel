#include "Adafruit_PWMServoDriver.h"
#include <avr/wdt.h>
//#include "Wire.h"

#define NUM 50
#define _PWM_RESOLUTION_ 4096


Adafruit_PWMServoDriver PCAs_left[50];
Adafruit_PWMServoDriver PCAs_right[50];

//Settings
auto SoftWire_left = SoftwareWire(50, 51);  //SDA,SCL
auto SoftWire_right = SoftwareWire(52, 53);

/**Global Varables Related to Serial buffer**/
/*时间戳定义*/
unsigned long lastReceiveTime = 0;
const unsigned long receiveInterval = 30; // 每隔30ms处理一次串口数据


/*缓冲区定义*/
const int BUFFER_SIZE = 64; // 缓冲区大小
char buffer[BUFFER_SIZE]; // 缓冲区数组
int bufferIndex = 0; // 缓冲区索引

/*******************************************/
//PWM
const int pwm_scalar = 1700;

void setup() {
  Serial.begin(115200);
  initPCA();

  //Initialize addr&freq
  
}

void loop() {
  wdt_reset();//feed the dog
  
  
  unsigned long currentTime = millis();
  
  while (Serial.available()) {
    char receivedChar = Serial.read();
    buffer[bufferIndex] = receivedChar; // 将接收到的字符存储到缓冲区

    if (receivedChar == '\n') { // 换行符作为结束符
      buffer[bufferIndex] = '\0'; // 添加字符串终止符
      
      bufferIndex = 0; // 重置缓冲区索引
    } else {
      bufferIndex++;
      if (bufferIndex >= BUFFER_SIZE) {
        bufferIndex = 0; // 缓冲区溢出，重置索引
      }
    }
    lastReceiveTime = currentTime;
  }

  // 检查是否达到处理间隔
  if (currentTime - lastReceiveTime >= receiveInterval) {
    // 执行耗时函数并处理接收到的数据
    // ...
    lastReceiveTime = currentTime;    
    processBuffer();
    resetBuffer();
  }
  // 继续其他的循环任务
  
}

void resetBuffer(){
  memset(buffer,0,BUFFER_SIZE);
  bufferIndex =0;
  
}

void processBuffer(){
  handleInstruction();
}

void handleInstruction() {
  // 在这里处理接收到的字符串
  switch (buffer[0]) {
    case 0 :
    return;
    case 'a':
      operationSetAll();
      break;
    case 'r':
      operationSetRow();
      break;
    case 'c':
      operationSetCol();
      break;
    case 'u':
      operationSetUnit();
      break;


    case 'e' :
    Serial.println(buffer);
    break;
  }
  // 可以在这里添加其他处理逻辑
}

void operationSetAll() {
#ifdef DEBUG
  //Serial.println("operationSetAll()");
#endif
  //parsing
  int value;
  sscanf(buffer, "a:%d", &value);
  
  //Serial.println(value);
  //sending
  PCAs_setAll(value);
  //reporting
  Serial.println('a');

  //Serial.println(message);
}

void operationSetRow() {

  int row, value;
  sscanf(buffer, "r:%d,%d", &row, &value);
  PCAs_setRow(row, value);
  
  Serial.println('r');
  #ifdef DEBUG
  Serial.print("operationSetRow()---");
  Serial.print("row:");
  Serial.print(row);
  Serial.print("val:");
  Serial.println(value);

#endif
}

void operationSetCol() {
#ifdef DEBUG
  Serial.println("operationSetCol()");
#endif
  int col, value;
  sscanf(buffer, "c:%d,%d", &col, &value);
  PCAs_setCol(col, value);
  Serial.println('c');
  
}

void operationSetUnit() {
#ifdef DEBUG
  Serial.println("operationSetUnit()");
#endif
  int row, col, value;
  sscanf(buffer, "u:%d,%d,%d", &row, &col, &value);
  PCAs_setUnit(row, col, value);
}





void PCAs_setRow(int row, int pwm) {
  for (int i = 0; i < 20; i++) {
    PCAs_setUnit(row, i, pwm);
  }
}

void PCAs_setCol(int col, int pwm) {
  for (int i = 0; i < 40; i++) {
    PCAs_setUnit(i, col, pwm);
  }
}







void initPCA() {
  for (int i = 0; i < 50; i++) {
    PCAs_left[i].resetAddr(0x40 + i, SoftWire_left);
    PCAs_left[i].begin();
    PCAs_left[i].setOscillatorFrequency(27000000);
    PCAs_left[i].setPWMFreq(1600);
  }

  for (int i = 0; i < 50; i++) {
    PCAs_right[i].resetAddr(0x40 + i, SoftWire_right);
    PCAs_right[i].begin();
    PCAs_right[i].setOscillatorFrequency(27000000);
    PCAs_right[i].setPWMFreq(1600);
  }

  //set clock
  //default 100000
  SoftWire_left.setClock(100000UL);
  SoftWire_right.setClock(100000UL);
  
  //set Out time to await I2C acknowledge signal
  // defualt 1000
  SoftWire_left.setTimeout(10L);
  SoftWire_right.setTimeout(10L);
}



void PCAs_setAll(int pwm) {
  for (int i = 0; i < 50; i++) {
    for (int j = 0; j < 16; j++) {
      PCAs_right[i].setPWM(j, 0, pwm);
      PCAs_left[i].setPWM(j, 0, pwm);
    }
  }
}

void PCAs_setUnit(int row, int col, int pwm) {
  int PCA_count, channel;
  //错误处理
  if(col<0 || col>39 ||row<0 ||row>39){
    Serial.print("!Error in  PCAs_setUnit();");
    Serial.print("row:");
    Serial.print(row);
    Serial.print(",col:");
    Serial.println(col);
  }
  // 判断是左边还是右边
  if (col < 20) {
    getLeftDeviceInfo(row, col, PCA_count, channel);
    PCAs_left[PCA_count].setPWM(channel, 0, pwm);
    Serial.print("Left#");
  } else {
    col = col -20;
    getRightDeviceInfo(row, col, PCA_count, channel);
    PCAs_right[PCA_count].setPWM(channel, 0, pwm);
  }
  
  
}

const unsigned channel_map[] = {
  0, 1, 6, 7,
  2, 3, 4, 5,
  10, 11, 12, 13,
  8, 9, 14, 15
};

void getLeftDeviceInfo(int row, int col, int &PCA_count, int &channel) {
  PCA_count = (row / 4) * 5 + col / 4;
  channel = channel_map[(row % 4) * 4 + (col % 4)];
}

void getRightDeviceInfo(int row, int col, int &PCA_count, int &channel) {
  col = 19 - col;
  PCA_count = (row / 4) * 5 + col / 4;
  channel = channel_map[(row % 4) * 4 + (col % 4)];
}
