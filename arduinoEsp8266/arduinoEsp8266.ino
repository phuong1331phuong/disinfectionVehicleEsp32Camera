#include <ESP8266WiFi.h>
#include <PubSubClient.h>
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
      Serial.println("tien");

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
      Serial.println("lui");

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
      Serial.println("dung");

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
      Serial.println("re trai");
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
      Serial.println("re phai");

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
// WiFi
const char *ssid = "phuong nguyen"; // Enter your WiFi name
const char *password = "123456789";  // Enter WiFi password

// MQTT Broker
const char *mqtt_broker = "broker.emqx.io";
const char *topic = "esp8266/control";
const char *mqtt_username = "phuongbgbg";
const char *mqtt_password = "777777";
const int mqtt_port = 1883;

WiFiClient espClient;
PubSubClient client(espClient);

void setup() {
  // Set software serial baud to 115200;
  Serial.begin(115200);
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
  // connecting to a WiFi network
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
      delay(500);
      Serial.println("Connecting to WiFi..");
  }
  Serial.println("Connected to the WiFi network");
  //connecting to a mqtt broker
  client.setServer(mqtt_broker, mqtt_port);
  client.setCallback(callback);
  while (!client.connected()) {
      String client_id = "esp8266-client-";
      client_id += String(WiFi.macAddress());
      Serial.printf("The client %s connects to the public mqtt broker\n", client_id.c_str());
      if (client.connect(client_id.c_str(), mqtt_username, mqtt_password)) {
          Serial.println("Public emqx mqtt broker connected");
      } else {
          Serial.print("failed with state ");
          Serial.print(client.state());
          delay(2000);
      }
  }
  // publish and subscribe
  client.subscribe(topic);
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


void loop() {
  client.loop();
  if(di_chuyen == 0){
        dung();
        delay(100);
    }else if(di_chuyen == 1){
        tien();
        delay(100);
    }else if(di_chuyen == 2){
        re_phai();
        delay(100);
    }else if (di_chuyen == 3) {
        lui();
        delay(100);
    }else if (di_chuyen == 4) {
        re_trai();
        delay(100);
    }
}
