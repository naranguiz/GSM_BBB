#!/bin/bash

# Asegúrate de tener instalados sms-tools y las librerías para tus sensores I2C
# (e.g., i2c-tools, python-smbus)

function reiniciar_sistema() {
    sms_texto=$(sms_tool_get_sms)  # Reemplaza con el comando de sms-tools para obtener el último SMS
    if [[ "$sms_texto" == *"reset"* ]]; then
        echo "Mensaje de reinicio recibido. Reiniciando sistema..."
        sudo shutdown -r now
    fi
}

function subir_registro_errores() {
    sms_texto=$(sms_tool_get_sms)
    if [[ "$sms_texto" == *"upload"* ]]; then
        echo "Mensaje de subida recibido. Subiendo registro de errores..."
        scp /var/log/syslog usuario@servidor_remoto:/ruta/en/la/nube
    fi
}

function subir_mediciones() {
    sms_texto=$(sms_tool_get_sms)
    if [[ "$sms_texto" == *"mediciones"* ]]; then
        echo "Mensaje de mediciones recibido. Subiendo datos..."

        # Leer temperatura y humedad de sensores I2C (ajusta según tus sensores)
        temperatura=$(i2cget -y 1 0x48 0x00 w | awk '{printf "%.1f", ($1*256 + $2) / 128.0}')
        humedad=$(i2cget -y 1 0x40 0x00 w | awk '{printf "%.1f", ($1*256 + $2) / 128.0}') 

        timestamp=$(date +%Y%m%d_%H%M%S)
        archivo_mediciones="mediciones_$timestamp.txt"
        echo "Temperatura: $temperatura" > "$archivo_mediciones"
        echo "Humedad: $humedad" >> "$archivo_mediciones"

        scp "$archivo_mediciones" usuario@servidor_remoto:/ruta/en/la/nube
    fi
}

# Bucle principal
while true; do
    reiniciar_sistema
    subir_registro_errores
    subir_mediciones
    sleep 60 
done
