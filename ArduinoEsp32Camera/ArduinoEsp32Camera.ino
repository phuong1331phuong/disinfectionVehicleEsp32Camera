#include "esp_camera.h"
#include <base64.hpp>
#include <base64.h>
//#include "camera_pins.h"
#include <WiFi.h>
//#include <String.h>
#include <PubSubClient.h>

#define CAMERA_MODEL_AI_THINKER

const char *ssid = "Trầm cảm lên";
const char *password = "Matkhaulatenwifichumviethoa";
const char *mqtt_broker = "broker.emqx.io";
const char *topic = "esp32/test/disinfection/vehicle/esp32/camera/app";
const char *mqtt_username = "phuongbgbg";
const char *mqtt_password = "1234567";
const int mqtt_port = 1883;
unsigned char *base64_text;
#define PWDN_GPIO_NUM 32
#define RESET_GPIO_NUM -1
#define XCLK_GPIO_NUM 0
#define SIOD_GPIO_NUM 26
#define SIOC_GPIO_NUM 27

#define Y9_GPIO_NUM 35
#define Y8_GPIO_NUM 34
#define Y7_GPIO_NUM 39
#define Y6_GPIO_NUM 36
#define Y5_GPIO_NUM 21
#define Y4_GPIO_NUM 19
#define Y3_GPIO_NUM 18
#define Y2_GPIO_NUM 5
#define VSYNC_GPIO_NUM 25
#define HREF_GPIO_NUM 23
#define PCLK_GPIO_NUM 22
const int bufferSize = 1024 * 23;
WiFiClient espClient;
PubSubClient client(espClient);

void cameraInit()
{
    camera_config_t config;
    config.ledc_channel = LEDC_CHANNEL_0;
    config.ledc_timer = LEDC_TIMER_0;
    config.pin_d0 = Y2_GPIO_NUM;
    config.pin_d1 = Y3_GPIO_NUM;
    config.pin_d2 = Y4_GPIO_NUM;
    config.pin_d3 = Y5_GPIO_NUM;
    config.pin_d4 = Y6_GPIO_NUM;
    config.pin_d5 = Y7_GPIO_NUM;
    config.pin_d6 = Y8_GPIO_NUM;
    config.pin_d7 = Y9_GPIO_NUM;
    config.pin_xclk = XCLK_GPIO_NUM;
    config.pin_pclk = PCLK_GPIO_NUM;
    config.pin_vsync = VSYNC_GPIO_NUM;
    config.pin_href = HREF_GPIO_NUM;
    config.pin_sscb_sda = SIOD_GPIO_NUM;
    config.pin_sscb_scl = SIOC_GPIO_NUM;
    config.pin_pwdn = PWDN_GPIO_NUM;
    config.pin_reset = RESET_GPIO_NUM;
    config.xclk_freq_hz = 20000000;
    config.pixel_format = PIXFORMAT_JPEG;
    config.frame_size = FRAMESIZE_VGA; // 640x480
    config.jpeg_quality = 30;//đặt lại chất luọng camera
    config.fb_count = 2;

    // camera init
    esp_err_t err = esp_camera_init(&config);
    if (err != ESP_OK)
    {
        Serial.printf("Camera init failed with error 0x%x", err);
        ESP.restart();
        return;
    }
}

void grabImage()
{
  camera_fb_t *fb = esp_camera_fb_get();

  if (fb != NULL && fb->format == PIXFORMAT_JPEG && fb->len < bufferSize)
  {
    Serial.print("Image Length: ");
    Serial.print(fb->len);
    Serial.print("\t Publish Image: ");
    String encoded = base64::encode(fb->buf, fb->len);//endoce hình ảnh thành code base64
    Serial.println(encoded.length());
    //  Serial.println();
    const char *encoded_Image = encoded.c_str();
    //  Serial.println(encoded_Image);
    Serial.println(topic);
    if (!client.connected())
    {
    }
    else
    {
      bool result = client.publish(topic, encoded_Image);//gửi code base64 lên broker mqtt
      //    client.subscribe(topic);
      Serial.println(result);

      if (!result)
      {
        ESP.restart();
      }
    }
  }
  esp_camera_fb_return(fb);
  delay(1);
}

void setup()
{
    Serial.begin(115200);
    cameraInit();
    WiFi.begin(ssid, password);
    while (WiFi.status() != WL_CONNECTED)
    {
        delay(500);
        Serial.println("Connecting to WiFi..");
    }
    Serial.println("Connected to the WiFi network");
    client.setServer(mqtt_broker, mqtt_port);
    client.setCallback(callback);
    while (!client.connected())
    {
        String client_id = "esp32-client-";
        client_id += String(WiFi.macAddress());
        Serial.printf("The client %s connects to the public mqtt broker\n", client_id.c_str());
        if (client.connect(client_id.c_str(), mqtt_username, mqtt_password))
        {
            Serial.println("Public emqx mqtt broker connected");
        }
        else
        {
            Serial.print("failed with state ");
            Serial.print(client.state());
            delay(2000);
        }
    }
    // publish and subscribe
    client.setBufferSize(65535);
    client.publish(topic, "Hi EMQ X I'm ESP32 ^^");
    client.subscribe(topic);
}

void callback(char *topic, byte *payload, unsigned int length)
{
  //    Serial.print("Message arrived in topic: ");
  //    Serial.println(topic);
  //    Serial.print("Message:");
  //    for (int i = 0; i < length; i++)
  //    {
  //        Serial.print((char)payload[i]);
  //    }
  //    Serial.println();
  //    Serial.println("-----------------------");
  if((char)payload == 1){
    //code di len
    }
    else if((char)payload == 2){
    //code di xuong
    }else if((char)payload == 3){
    //code di sang trai
    }else if((char)payload == 4){
    //code di sang phai
    }else if((char)payload == 0){
    //code dung lai
    }else if((char)payload == 5){
    //code phun khu khuan
    }
    
}

void loop()
{
    client.loop();
    if (client.connected())
      grabImage();
}
