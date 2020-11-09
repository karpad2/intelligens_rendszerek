#include <MFRC522.h>
#include <WiFi.h>
#include <HTTPClient.h>
#include <WiFiClientSecure.h>
#include <Arduino_JSON.h>
#include "header.h"
#include "config.h"


MFRC522 rfid(SS_PIN, RST_PIN); // Instance of the class
MFRC522::MIFARE_Key key;

JSONVar my_elements = JSON.parse(basic_json);
String s_rfid="";
// Init array that will store new NUID
byte nuidPICC[4];
struct tm timeinfo;
void setClock();
void client_http();

void setup() {
    //pinMode(LED,OUTPUT);
    Serial.begin(9600);
    SPI.begin(); // Init SPI bus
    rfid.PCD_Init(); // Init MFRC522

    WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
    Serial.print("Connecting to Wi-Fi");
    while (WiFi.status() != WL_CONNECTED)
    {
        Serial.print(".");
        delay(300);
    }
    Serial.println();
    Serial.print("Connected with IP: ");
    Serial.println(WiFi.localIP());
    Serial.println();
    for (byte i = 0; i < 6; i++) {
        key.keyByte[i] = 0xFF;
    }
    Serial.print("Waiting for WiFi... ");
    delay(500);
}

void loop() {
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
    setClock();
    client_http();

    // Halt PICC
    rfid.PICC_HaltA();

    // Stop encryption on PCD
    rfid.PCD_StopCrypto1();
}


/**
   Helper routine to dump a byte array as hex values to Serial.
*/
void printHex(byte *buffer, byte bufferSize) {
    for (byte i = 0; i < bufferSize; i++) {
        Serial.print(buffer[i] < 0x10 ? " 0" : " ");
        Serial.print(buffer[i], HEX);
    }
}

/**
   Helper routine to dump a byte array as dec values to Serial.
*/
void printDec(byte *buffer, byte bufferSize) {
    for (byte i = 0; i < bufferSize; i++) {
        Serial.print(buffer[i] < 0x10 ? " 0" : " ");
        Serial.print(buffer[i], DEC);
    }
}
void setClock() {
    configTime(3600,3600, "2.rs.pool.ntp.org","1.hu.pool.ntp.org");

    Serial.print(F("Waiting for NTP time sync: "));
    time_t nowSecs = time(nullptr);
    while (nowSecs < 8 * 3600 * 2) {
        delay(500);
        Serial.print(F("."));
        yield();
        nowSecs = time(nullptr)+3600;
    }

    Serial.println();
    
    gmtime_r(&nowSecs, &timeinfo);
    Serial.print(F("Current time: "));
    Serial.print(asctime(&timeinfo));
}
void client_http()
{ WiFiClientSecure *client = new WiFiClientSecure;
    if (client) {
        //client -> setCACert(rootCACertificate);
        {
            // Add a scoping block for HTTPClient https to make sure it is destroyed before WiFiClientSecure *client is
            HTTPClient http;
            Serial.print("[HTTPS] begin...\n");
            if (http.begin(*client, FIREBASE_HOST)) {  // HTTPS
                Serial.print("[HTTPS] POST...\n");
                http.addHeader("Content-Type", "application/json");
                //String httpRequestData = "";

                // start connection and send HTTP header
               // String
               my_elements["RFID-code"]=s_rfid;
               String l_time=String(asctime(&timeinfo));
               my_elements["time"]=l_time.substring(0,l_time.length()-1);
               //Serial.println(JSON.stringify(my_elements));
                int httpCode = http.POST( JSON.stringify(my_elements));
                // int httpCode = http.GET();
                // httpCode will be negative on error
                if (httpCode > 0) {
                    // HTTP header has been send and Server response header has been handled
                    Serial.printf("[HTTPS] POST ... code: %d\n", httpCode);

                    // file found at server
                    if (httpCode == HTTP_CODE_OK || httpCode == HTTP_CODE_MOVED_PERMANENTLY) {
                        String payload = http.getString();
                        Serial.println(payload);
                    }
                } else {
                    Serial.printf("[HTTPS] POST... failed, error: %s\n", http.errorToString(httpCode).c_str());
                }

                http.end();
            } else {
                Serial.printf("[HTTPS] Unable to connect\n");
            }

            // End extra scoping block
        }

        delete client;
    } else {
        Serial.println("Unable to create client");
    }
}
