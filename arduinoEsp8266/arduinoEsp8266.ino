#include <ESP8266WiFi.h>   
#include <MQTTClient.h>
#include <ESP8266WebServer.h>
#include <WiFiClientSecure.h>
#include <DNSServer.h>
#include "secrets.h"

const int bufferSize = 1024 * 23; // 23552 bytes

WiFiClientSecure net = WiFiClientSecure();
MQTTClient client = MQTTClient(bufferSize);

#define ENA   5          // Điều khiển tốc độ động cơ bên trái     GPIO5(D1)
#define ENB   12          // Điều khiển tốc độ động cơ bên phải    GPIO12(D6)
#define IN1  4          // L298N in1 Động cơ trái quay             GPIO4(D2)
#define IN2  0          // L298N in2 Động cơ trái quay ngược lại   GPIO0(D3)
#define IN3  2           // L298N in3 Động cơ phải quay            GPIO2(D4)
#define IN4  14           // L298N in4 Động cơ phải quay ngược lại GPIO14(D5)


int di_chuyen = 0;

int minRange = 312;
int maxRange = 712;
int tocdoxe = 800;         // 400 - 1023.
/********************************************* Tiến tới *****************************************************/
void tien()
{
      digitalWrite(IN1, LOW);
      digitalWrite(IN2, HIGH);
      analogWrite(ENA, tocdoxe);
      digitalWrite(IN3, LOW);
      digitalWrite(IN4, HIGH);
      analogWrite(ENB, tocdoxe+300);
}
/********************************** Lùi lại ******************************************/
void lui()
{
      digitalWrite(IN1, HIGH);
      digitalWrite(IN2, LOW);
      analogWrite(ENA, tocdoxe);
      digitalWrite(IN3, HIGH);
      digitalWrite(IN4, LOW);
      analogWrite(ENB, tocdoxe);
}
/********************************** Dừng lại ******************************************/
void dung()
{
      digitalWrite(IN1, LOW);
      digitalWrite(IN2, LOW);
      analogWrite(ENA, 0);
      digitalWrite(IN3, LOW);
      digitalWrite(IN4, LOW);
      analogWrite(ENB, 0);
}
/********************************** Rẽ trái ******************************************/
void re_trai()
{
  digitalWrite(IN1, LOW);
      digitalWrite(IN2, HIGH);
      analogWrite(ENA, tocdoxe);
      digitalWrite(IN3, LOW);
      digitalWrite(IN4, LOW);
      analogWrite(ENB, tocdoxe+300);
}
/********************************** Rẽ phải ******************************************/
void re_phai()
{
      digitalWrite(IN1, LOW);
      digitalWrite(IN2, LOW);
      analogWrite(ENA, tocdoxe);
      digitalWrite(IN3, LOW);
      digitalWrite(IN4, HIGH);
      analogWrite(ENB, tocdoxe);
}

void den_pin(int a){
    if(a == 1){
      digitalWrite(D0,HIGH);
    }else{
      digitalWrite(D0,LOW);
    }
}

void phun_khu_khuan(int a){
    if(a == 1){
      digitalWrite(D7,HIGH);
    }else{
      digitalWrite(D7,LOW);
    }
}

void coi_bao(){
      digitalWrite(D8,HIGH);
      delay(1000);
      digitalWrite(D8,LOW);
}

void callback(char *topic, byte *payload, unsigned int length) {
    if((char)payload[0] == 48){
        di_chuyen = 0;
    }else if((char)payload[0] == 49){
        di_chuyen = 1;
    }else if((char)payload[0] == 50){
        di_chuyen = 2;
    }else if((char)payload[0] == 51){
        di_chuyen = 3;
    }else if((char)payload[0] == 52){
        di_chuyen = 4;
    }else if((char)payload[0] == 65){
        phun_khu_khuan(1);
    }else if((char)payload[0] == 97){
        phun_khu_khuan(0);
    }else if((char)payload[0] == 88){
        den_pin(1);
    }else if((char)payload[0] == 120){
        den_pin(0);
    }else if((char)payload[0] == 79){
        coi_bao();
    }
}

void connectAWS()
{
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  Serial.println("\n\n=====================");
  Serial.println("Connecting to Wi-Fi");
  Serial.println("=====================\n\n");

  while (WiFi.status() != WL_CONNECTED){
    delay(500);
    Serial.print(".");
  }

  // Configure WiFiClientSecure to use the AWS IoT device credentials
  net.setCACert((const uint8_t*)AWS_CERT_CA,1190);
  net.setCertificate((const uint8_t*)AWS_CERT_CRT,1226);
  net.setPrivateKey((const uint8_t*)AWS_CERT_PRIVATE,1677);

  // Connect to the MQTT broker on the AWS endpoint we defined earlier
  client.begin(AWS_IOT_ENDPOINT, 8883, net);
  client.setCleanSession(true);

  Serial.println("\n\n=====================");
  Serial.println("Connecting to AWS IOT");
  Serial.println("=====================\n\n");

  while (!client.connect(THINGNAME)) {
    Serial.print(".");
    delay(100);
  }

  if(!client.connected()){
    Serial.println("AWS IoT Timeout!");
    ESP.restart();
    return;
  }
  Serial.println("\n\n=====================");
  Serial.println("AWS IoT Connected!");
  Serial.println("=====================\n\n");
}

void setup()
{
  connectAWS();
  pinMode(ENA, OUTPUT);
  pinMode(ENB, OUTPUT); 
  pinMode(IN1, OUTPUT);
  pinMode(IN2, OUTPUT);
  pinMode(IN3, OUTPUT);
  pinMode(IN4, OUTPUT);
  pinMode(D0,OUTPUT);
  pinMode(D7,OUTPUT);
  pinMode(D8,OUTPUT);
  digitalWrite(ENA, LOW);
  digitalWrite(ENB, LOW);
  digitalWrite(IN1, LOW);
  digitalWrite(IN2, LOW);
  digitalWrite(IN3, LOW);
  digitalWrite(IN4, LOW);
  digitalWrite(D0,HIGH);
  digitalWrite(D7,HIGH);
  digitalWrite(D8,HIGH);
}


void loop(){
    client.loop();
    if(di_chuyen == 0){
        dung();
    }else if(di_chuyen == 1){
        tien();
    }else if(di_chuyen == 2){
        re_phai();
    }else if (di_chuyen == 3) {
        lui();
    }else if (di_chuyen == 4) {
        re_trai();
    }
}
