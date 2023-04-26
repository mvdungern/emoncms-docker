#!/bin/bash -x
# Start MQTT service
./usr/local/bin/php /var/www/emoncms/scripts/services/emoncms_mqtt/emoncms_mqtt.php &
# Wait for process to exit
wait -n
# Exit with status
exit $?