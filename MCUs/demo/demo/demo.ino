#include "Adafruit_PWMServoDriver.h"
//#include "Wire.h"
#include "background.h"
#define NUM 50
#define _PWM_RESOLUTION_ 4096

extern int background[40][40]; //数组储存背景，来自头文件background.h
int clouds[10][40];//用来计算运动的云
Adafruit_PWMServoDriver PCAs_left[50];
Adafruit_PWMServoDriver PCAs_right[50];

//Settings
auto SoftWire_left = SoftwareWire(50, 51);  //SDA,SCL
auto SoftWire_right = SoftwareWire(52, 53);

//PWM
const int pwm_scalar = 1700;

void setup() {
  Serial.begin(115200);
  initPCA();

  //Initialize addr&freq
  plotBackground();
}

void loop() {
  plotClouds();
  delay(5000);
  //debugPrint();//打印数组
}



void debugPrint(){
  for(int i=0;i<40;i++){
    Serial.print("line");
    Serial.print(i);
    Serial.print("##");

    for(int j=0;j<40;j++){
      Serial.print(background[i][j]);
      Serial.print(',');
    }
    Serial.println(";");
  }
}

void plotBackground(){
  for(int i=0;i<40;i++){    
    for(int j=0;j<40;j++){
      PCAs_setUnit(i, j,  background[i][j]*pwm_scalar);//pwm
    }
  }
}

void plotClouds(){
  //9-19行为云运动的层级,类似移位寄存器一样不断移动移动
  for(int i=9;i<19;i++){
    shiftArray(background[i], 40);
  }
  //把结果发送到风墙上
  for(int i=9;i<19;i++){
    for(int j=0;j<40;j++){
      PCAs_setUnit(i, j, background[i][j]*pwm_scalar);//pwm
    }
  }


}

void shiftArray(int arr[], int size) {
    int lastElement = arr[size - 1];
    for (int i = size - 1; i > 0; i--) {
        arr[i] = arr[i - 1];
    }
    arr[0] = lastElement;
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
  //for debug use
  Serial.print("!Error in  PCAs_setUnit();");
    Serial.print("row:");
    Serial.print(row);
    Serial.print(",col:");
    Serial.print(col);
    Serial.print("PCA_count");
  
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
