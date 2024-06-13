# Domotización de Persianas con Waspmote

Este proyecto consiste en la domotización de persianas utilizando una placa Waspmote de Libelium. Se han desarrollado dos versiones del programa: una básica que controla las persianas según la cantidad de luz ambiente y otra avanzada que incluye conectividad Wi-Fi y comunicación MQTT.

## Tabla de Contenidos

1. [Descripción del Proyecto](#descripción-del-proyecto)
2. [Requisitos del Sistema](#requisitos-del-sistema)
3. [Instalación](#instalación)
4. [Uso](#uso)
   - [Versión Básica](#versión-básica)
   - [Versión con Wi-Fi y MQTT](#versión-con-wi-fi-y-mqtt)
5. [Licencia](#licencia)
6. [Créditos](#créditos)

## Descripción del Proyecto

El proyecto de domotización de persianas se compone de dos versiones:

1. **Versión Básica:** Controla las persianas basándose en la cantidad de luz detectada por un sensor de luz en la placa Waspmote. La acción de subir o bajar las persianas se imprime en la pantalla.
2. **Versión con Wi-Fi y MQTT:** Además de controlar las persianas según la luz ambiente, esta versión envía la información a un servidor MQTT y espera una respuesta del servidor para imprimirla en pantalla.

## Requisitos del Sistema

- Placa Waspmote de Libelium.
- Sensor de luz.
- Módulo Wi-Fi (para la versión con Wi-Fi y MQTT).
- Conexión a Internet (para la versión con Wi-Fi y MQTT).

## Instalación

1. **Clona el repositorio:**
    ```sh
    git clone https://github.com/tu-usuario/domotizacion-persianas.git
    cd domotizacion-persianas
    ```

2. **Selecciona la rama adecuada:**
    - Para la versión básica:
        ```sh
        git checkout main
        ```
    - Para la versión con Wi-Fi y MQTT:
        ```sh
        git checkout wifi-mqtt
        ```

3. **Carga el código en la placa Waspmote usando el IDE de Waspmote.**

## Uso

### Versión Básica

1. **Configura el entorno:**
    - Conecta el sensor de luz a la placa Waspmote.
    
2. **Carga y ejecuta el programa:**
    - Abre el archivo `domotizacion_persianas_basico.pde` en el IDE de Waspmote.
    - Sube el código a la placa y abre el monitor serie para ver las acciones de las persianas según la luz detectada.

    ```cpp
    #include <WaspSensorEvent_v30.h>

    uint32_t luxes = 0;
    const uint32_t LUX_UMBRAL = 100;

    void setup() {
      USB.ON();
      USB.println(F("Iniciando el programa...\n"));
      Events.ON();
    }

    void loop() {
      luxes = Events.getLuxes(INDOOR);
      USB.print(F("Luxes: "));
      USB.print(luxes);
      USB.println(F(" lux"));

      if (luxes > LUX_UMBRAL) {
        USB.println(F("Cerrar persianas"));
      } else {
        USB.println(F("Abrir persianas"));
      }

      delay(3000);
    }
    ```

### Versión con Wi-Fi y MQTT

1. **Configura el entorno:**
    - Conecta el sensor de luz y el módulo Wi-Fi a la placa Waspmote.
    - Asegúrate de tener acceso a un servidor MQTT y la configuración correcta (SSID y contraseña de Wi-Fi, dirección del servidor MQTT, etc.).

2. **Carga y ejecuta el programa:**
    - Abre el archivo `domotizacion_persianas_wifi_mqtt.pde` en el IDE de Waspmote.
    - Sube el código a la placa y abre el monitor serie para ver las acciones de las persianas y las publicaciones en el servidor MQTT.

    ```cpp
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

      uint8_t error = WIFI_PRO_V3.ON(socket);
      if (error == 0) {
        USB.println(F("Wi-Fi encendido correctamente"));
      } else {
        USB.println(F("Error al encender Wi-Fi"));
        return;
      }

      error = WIFI_PRO_V3.resetValues();
      if (error != 0) {
        USB.print(F("Error al resetear Wi-Fi: "));
        USB.println(error, DEC);
        return;
      }

      error = WIFI_PRO_V3.configureMode(WaspWIFI_v3::MODE_STATION);
      if (error != 0) {
        USB.print(F("Error al configurar modo Wi-Fi: "));
        USB.println(error, DEC);
        return;
      }

      error = WIFI_PRO_V3.configureStation(SSID, PASSW, WaspWIFI_v3::AUTOCONNECT_ENABLED);
      if (error != 0) {
        USB.print(F("Error al configurar SSID: "));
        USB.println(error, DEC);
        return;
      }

      if (WIFI_PRO_V3.isConnected()) {
        USB.println(F("Conectado al punto de acceso"));
      } else {
        USB.println(F("Error al conectar al punto de acceso"));
        return;
      }

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
    ```

## Licencia

Este programa es software libre: puede redistribuirlo y/o modificarlo bajo los términos de la Licencia Pública General de GNU según es publicada por la Free Software Foundation, bien de la versión 3 de dicha Licencia o bien (a su elección) de cualquier versión posterior.

Este programa se distribuye con la esperanza de que sea útil, pero SIN NINGUNA GARANTÍA; ni siquiera la garantía implícita MERCANTIL o de APTITUD PARA UN PROPÓSITO DETERMINADO. Vea la Licencia Pública General de GNU para más detalles.

Debería haber recibido una copia de la Licencia Pública General de GNU junto con este programa. En caso contrario, consulte <http://www.gnu.org/licenses/>.

## Créditos

- **Desarrollador:** Lucas Pérez Rodríguez
- **Compañía:** IES El Rincón
- **Sitio web:** [IES El Rincón](https://www3.gobiernodecanarias.org/medusa/edublog/ieselrincon/)
