#define DEBUG  //debug switch

/*third party lib required here*/
#include "stdio.h"                    //Arduino_AVRSTL
#include "Adafruit_PWMServoDriver.h"  //Adafruit_PWMServoDriver
/*******************************************/

int a = 0;

/**Configure**/
enum Position {
  LEFT,
  RIGHT
};

Position controler_position = RIGHT;
/*******************************************/

/****************Test Result******************/
namespace TestCase {
bool result_ok = false;
int col_millis, row_millis, all_millis;
bool undetected_devices[50];
}
/*******************************************/


/**Global Varables Related to Serial buffer**/
     // 缓冲区索引
/*******************************************/


/**Global Varables Related to PCA9685 IIC chips**/
Adafruit_PWMServoDriver PCAs[50];
const int PWMFreq = 100;
const unsigned channel_map[] = {
  0, 1, 6, 7,
  2, 3, 4, 5,
  10, 11, 12, 13,
  8, 9, 14, 15
};
/*******************************************/


enum State {
  STATE_IDLE,
  STATE_RUNNING,
  STATE_STOPPED
};

enum State currentState = STATE_IDLE;

//pause here
short int frames[4][40][20];  //row,column

void setup() {

  Serial.begin(115200);  // 初始化串口通信
  initPCAs();
  //PCAs_detection();
  
}

String buffer;

void loop() {
  if (Serial.available()) {  // 检查是否有数据可供读取
    buffer = Serial.readStringUntil('\n'); // 读取串口数据直到遇到换行符
    //buffer.trim(); // 
    int start = millis();
    
    
 processBuffer();
 
  }
}

void resetBuffer(){
  
}

void processBuffer() {
  // 在这里处理接收到的字符串
  switch (buffer[0]) {
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
  Serial.println("all");
  int value;
  
  sscanf(buffer.c_str(), "a:%d", &value);
  
  //Serial.println(value);
  //sending
  PCAs_setAll(value);
  //reporting
  auto message = "{'message':'setAll',}";

  //Serial.println(message);
  Serial.println(value);
  

  
}

void operationSetRow() {
#ifdef DEBUG
  Serial.println("operationSetRow()");
#endif
  int row, value;
  sscanf(buffer.c_str(), "r:%d,%d", &row, &value);
  PCAs_setRow(row, value);
  resetBuffer();
}

void operationSetCol() {
#ifdef DEBUG
  Serial.println("operationSetCol()");
#endif
  int col, value;
  sscanf(buffer.c_str(), "c:%d,%d", &col, &value);
  PCAs_setCol(col, value);
  resetBuffer();
}

void operationSetUnit() {
#ifdef DEBUG
  Serial.println("operationSetUnit()");
#endif
  int row, col, value;
  sscanf(buffer.c_str(), "u:%d,%d,%d", &row, &col, &value);
  PCAs_setUnit(row, col, value);
}


void initPCAs() {
  for (int i = 0; i < 50; i++) {
    PCAs[i] = Adafruit_PWMServoDriver(0x40 + i);
    PCAs[i].begin();
    PCAs[i].setPWMFreq(PWMFreq);
  }
}

void PCAs_setAll(int pwm) {
  for (int i = 0; i < 50; i++) {
    for (int j = 0; j < 16; j++) {
      PCAs[i].setPWM(j, 0, pwm);
    }
  }
}

void PCAs_setUnit(int row, int col, int pwm) {
  int PCA_count, channel;
  if (controler_position == LEFT) {
    getLeftDeviceInfo(row, col, PCA_count, channel);
  }
  if (controler_position == RIGHT) {
    getRightDeviceInfo(row, col, PCA_count, channel);
  }
  PCAs[PCA_count].setPWM(channel, 0, pwm);
  
}

void getLeftDeviceInfo(int row, int col, int &PCA_count, int &channel) {
  PCA_count = (row / 4) * 5 + col / 4;
  channel = channel_map[(row % 4) * 4 + (col % 4)];
}

void getRightDeviceInfo(int row, int col, int &PCA_count, int &channel) {
  col = 19 - col;
  PCA_count = (row / 4) * 5 + col / 4;
  channel = channel_map[(row % 4) * 4 + (col % 4)];
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

void PCAs_detection() {
  for (int i = 0; i < 50; i++) {
    TestCase::undetected_devices[i] = false;
  }

  //Step 1 : detect IIC devices
  byte error, address;
  int deviceCount = 0;

#ifdef DEBUG
  Serial.println("Scanning...");
#endif

  for (address = 0x40; address <= 0x71; address++) {
    Wire.beginTransmission(address);
    error = Wire.endTransmission();

    if (error == 0) {
#ifdef DEBUG
      Serial.print("Device found at address 0x");

      if (address < 16) {
        Serial.print("0");
      }
      Serial.println(address, HEX);
#endif

      TestCase::undetected_devices[address - 0x40] = false;
      deviceCount++;
    }
  }

  if (deviceCount == 0) {
    Serial.println("No devices found.");
  }

  //Step 2 : test time consumed
  int start, end;
  start = millis();
  PCAs_setAll(100);
  PCAs_setAll(0);
  end = millis();
  TestCase::all_millis = (end - start) / 2 + 1;

  start = millis();
  PCAs_setRow(0, 100);
  PCAs_setRow(0, 0);
  end = millis();
  TestCase::row_millis = (end - start) / 2 + 1;

  start = millis();
  PCAs_setCol(0, 100);
  PCAs_setCol(0, 0);
  end = millis();
  TestCase::col_millis = (end - start) / 2 + 1;

#ifdef DEBUG
  Serial.print("All time : ");
  Serial.print(TestCase::all_millis);
  Serial.print(" Row time :");
  Serial.print(TestCase::row_millis);
  Serial.print(" Col time :");
  Serial.println(TestCase::col_millis);
#endif

}


