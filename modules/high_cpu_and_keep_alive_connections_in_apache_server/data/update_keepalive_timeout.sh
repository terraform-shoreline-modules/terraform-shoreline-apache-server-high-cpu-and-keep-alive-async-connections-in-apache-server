

#!/bin/bash



# Set the new KeepAliveTimeout value

NEW_TIMEOUT=5



# Locate the Apache configuration file

CONF_FILE=${PATH_TO_APACHE_CONF_FILE}



# Check if the configuration file exists

if [ ! -f "$CONF_FILE" ]; then

    echo "Error: Apache configuration file not found."

    exit 1

fi



# Backup the original configuration file

cp "$CONF_FILE" "$CONF_FILE.bak"



# Replace the current KeepAliveTimeout value with the new one

sed -i "s/KeepAliveTimeout [0-9]\+/KeepAliveTimeout $NEW_TIMEOUT/" "$CONF_FILE"



# Restart Apache to apply the changes

service apache2 restart



echo "KeepAliveTimeout value updated to $NEW_TIMEOUT seconds."