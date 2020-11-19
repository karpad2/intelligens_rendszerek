#include <Arduino.h>

#include <WiFi.h>
#include <WiFiMulti.h>
#include <MFRC522.h>
#include <HTTPClient.h>
#include <Arduino_JSON.h>

#define USE_SERIAL Serial
#define SS_PIN    21
#define RST_PIN   22

WiFiMulti wifiMulti;
JSONVar my_elements = JSON.parse("{\"RFID-code\" : \"valami hexa\"}");
MFRC522 rfid(SS_PIN, RST_PIN); // Instance of the class
MFRC522::MIFARE_Key key;
byte nuidPICC[4];
String s_rfid="";


void setup() {
    USE_SERIAL.begin(9600);
    USE_SERIAL.println();
    USE_SERIAL.println();
    USE_SERIAL.println();
    for(uint8_t t = 4; t > 0; t--) {
        USE_SERIAL.printf("[SETUP] WAIT %d...\n", t);
        USE_SERIAL.flush();
        delay(1000);
    }
    wifiMulti.addAP("TP-Link", "asdfghjkl123#");
    SPI.begin(); // Init SPI 
    rfid.PCD_Init(); // Init MFRC522
    for (byte i = 0; i < 6; i++) {
        key.keyByte[i] = 0xFF;
    }
}
void loop()  {
    if ( ! rfid.PICC_IsNewCardPresent()) return;
    if ( ! rfid.PICC_ReadCardSerial()) return;

    Serial.print(F("PICC type: "));
    MFRC522::PICC_Type piccType = rfid.PICC_GetType(rfid.uid.sak);
    Serial.println(rfid.PICC_GetTypeName(piccType));
    if (piccType != MFRC522::PICC_TYPE_MIFARE_MINI &&
        piccType != MFRC522::PICC_TYPE_MIFARE_1K &&
        piccType != MFRC522::PICC_TYPE_MIFARE_4K) {
        Serial.println(F("Your tag is not of type MIFARE Classic."));
        return;
    }
    for (byte i = 0; i < 4; i++) nuidPICC[i] = rfid.uid.uidByte[i];


    Serial.println(F("The NUID tag is:"));
    Serial.print(F("In hex: "));
    s_rfid="";
    for(byte i=0;i<rfid.uid.size;i++)
    {
        s_rfid+=String(rfid.uid.uidByte[i],HEX);
    }
    Serial.println(s_rfid);
    //printHex(rfid.uid.uidByte, rfid.uid.size);
    Serial.println();
    //setClock();
    // wait for WiFi connection
    if((wifiMulti.run() == WL_CONNECTED)) {

        HTTPClient http;

        USE_SERIAL.print("[HTTP] begin...\n");
        // configure traged server and url
        //http.begin("https://www.howsmyssl.com/a/check", ca); //HTTPS
        http.begin("http://46.40.46.94:81/timers.php?json="+s_rfid); //HTTP

        USE_SERIAL.print("[HTTP] GET...\n");
        // start connection and send HTTP header
        int httpCode = http.GET();

        // httpCode will be negative on error
        if(httpCode > 0) {
            // HTTP header has been send and Server response header has been handled
            USE_SERIAL.printf("[HTTP] GET... code: %d\n", httpCode);

            // file found at server
            if(httpCode == HTTP_CODE_OK) {
                String payload = http.getString();
                USE_SERIAL.println(payload);
            }
        } else {
            USE_SERIAL.printf("[HTTP] GET... failed, error: %s\n", http.errorToString(httpCode).c_str());
        }

        http.end();
    }

    // Halt PICC
    rfid.PICC_HaltA();

    // Stop encryption on PCD
    rfid.PCD_StopCrypto1();
}
