/*
    --[Domotización de persianas]--

    Este programa lee la cantidad de luz en el ambiente utilizando
    un sensor de luz en Waspmote y decide si se deben subir o bajar
    las persianas. Se imprime un mensaje en pantalla indicando la acción.

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
    Implementación:    Lucas Pérez Rodríguez
*/
#include <WaspSensorEvent_v30.h>

uint32_t luxes = 0;
const uint32_t LUX_UMBRAL = 100;

void setup() {
  USB.ON();
  USB.println(F("Iniciando el programa...\n"));

  Events.ON();
}

void loop(){
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

