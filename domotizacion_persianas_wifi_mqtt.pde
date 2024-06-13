/*
    --[Domotización de persianas]--
    
    Este programa lee la cantidad de luz en el ambiente utilizando
    un sensor de luz en Waspmote y decide si se deben subir o bajar 
    las persianas. Luego, envía esta información a un servidor MQTT y
    espera una respuesta del servidor para imprimirla en pantalla.
    
    Copyright (C) 2024 Libelium Comunicaciones Distribuidas S.L.
    http://www.libelium.com
    
    Este programa es software libre: puede redistribuirlo y/o modificarlo
    bajo los términos de la Licencia Pública General de GNU según es 
    publicada por la Free Software Foundation, bien de la versión 3 de 
    dicha Licencia o bien (a su elección) de cualquier versión posterior.
    
    Este programa se distribuye con la esperanza de que sea útil,
    pero SIN NINGUNA GARANTÍA; ni siquiera la garantía implícita 
    MERCANTIL o de APTITUD PARA UN PROPÓSITO DETERMINADO. 
    Vea la Licencia Pública General de GNU para más detalles.
    
    Debería haber recibido una copia de la Licencia Pública General de GNU
    junto con este programa. En caso contrario, consulte 
    <http://www.gnu.org/licenses/>.
    
    Versión:           1.0
    Implementación:    Lucas Perez Rodríguez
 */
#include <WaspSensorEvent_v30.h>
#include <WaspWIFI_PRO_V3.h>

uint32_t luxes = 0;
const uint32_t LUX_UMBRAL = 100;

char action[20];

// Configuración de Wi-Fi y MQTT
uint8_t socket = SOCKET0;
char SSID[] = "G103";
char PASSW[] = "test1234";
char MQTT_SERVER[] = "test.mosquitto.org";
uint16_t MQTT_PORT = 1883;
char MQTT_TOPIC[] = "persianas";

void setup() {
  
  USB.ON();
  USB.println(F("Iniciando el programa...\n"));

  Events.ON();

  // Configuración del módulo Wi-Fi
  uint8_t error = WIFI_PRO_V3.ON(socket);
  if (error == 0) {
    USB.println(F("Wi-Fi encendido correctamente"));
  } else {
    USB.println(F("Error al encender Wi-Fi"));
    return;
  }

  // Resetea valores por defecto
  error = WIFI_PRO_V3.resetValues();
  if (error != 0) {
    USB.print(F("Error al resetear Wi-Fi: "));
    USB.println(error, DEC);
    return;
  }

  // Configura el modo de operación (MODE_STATION)
  error = WIFI_PRO_V3.configureMode(WaspWIFI_v3::MODE_STATION);
  if (error != 0) {
    USB.print(F("Error al configurar modo Wi-Fi: "));
    USB.println(error, DEC);
    return;
  }

  // Configura la conexión al punto de acceso
  error = WIFI_PRO_V3.configureStation(SSID, PASSW, WaspWIFI_v3::AUTOCONNECT_ENABLED);
  if (error != 0) {
    USB.print(F("Error al configurar SSID: "));
    USB.println(error, DEC);
    return;
  }

  // Verifica si está conectado al punto de acceso
  if (WIFI_PRO_V3.isConnected()) {
    USB.println(F("Conectado al punto de acceso"));
  } else {
    USB.println(F("Error al conectar al punto de acceso"));
    return;
  }

  // Configura la conexión MQTT
  error = WIFI_PRO_V3.mqttConfiguration(MQTT_SERVER, "Prueba", MQTT_PORT, WaspWIFI_v3::MQTT_TLS_DISABLED);
  if (error == 0) {
    USB.println(F("Conexión MQTT configurada"));
  } else {
    USB.println(F("Error al configurar conexión MQTT"));
  }
}

void loop() { 
  luxes = Events.getLuxes(INDOOR);
  
  USB.print(F("Luxes: "));
  USB.print(luxes);
  USB.println(F(" lux"));

  if (luxes > LUX_UMBRAL) {
    USB.println(F("Cerrar persianas"));
    strcpy(action, "Cerrar persianas");
  } else {
    USB.println(F("Abrir persianas"));
    strcpy(action, "Abrir persianas");
  }

  uint8_t error = WIFI_PRO_V3.mqttPublishTopic(MQTT_TOPIC, WaspWIFI_v3::QOS_1, WaspWIFI_v3::RETAINED, action);
  if (error == 0) {
    USB.println(F("Estado publicado en MQTT"));
  } else {
    USB.println(F("Error al publicar estado en MQTT"));
  }
  
  delay(3000);
}

