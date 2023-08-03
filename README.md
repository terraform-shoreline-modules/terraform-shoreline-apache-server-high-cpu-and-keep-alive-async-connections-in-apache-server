
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# High CPU and Keep-Alive Connections in Apache Server
---

This incident type refers to a high resource utilization issue in an Apache server. Specifically, it involves a high number of keep-alive async connections combined with high CPU usage. The recommended solution involves lowering the maximum number of simultaneous connections to the server and/or decreasing the KeepAliveTimeout to avoid holding connections open longer than necessary. This incident type can impact the performance of the Apache server and may require immediate attention to avoid further issues.

### Parameters
```shell
# Environment Variables

export APACHE_CONFIG_FILE="PLACEHOLDER"

export NEW_MAX_WORKERS_VALUE="PLACEHOLDER"

export KEEP_ALIVE_THRESHOLD="PLACEHOLDER"

export CPU_THRESHOLD="PLACEHOLDER"

export PATH_TO_APACHE_CONF_FILE="PLACEHOLDER"
```

## Debug

### Display the current cpu usage using the 'top' command.
```shell
top
```

### Check Apache processes
```shell
ps aux | grep apache
```

### Check Apache resource usage
```shell
apachectl fullstatus | grep "CPU usage\|requests currently being processed"
```

### Check Apache configuration
```shell
apachectl -t -D DUMP_VHOSTS
```

### Check Apache error log for any recent errors
```shell
tail -n 50 /var/log/apache2/error.log
```

### Check Apache access log for requests and response codes
```shell
tail -n 50 /var/log/apache2/access.log
```

### Check the current number of established connections
```shell
netstat -anp | grep 80 | grep ESTABLISHED | wc -l
```

### Check the maximum number of simultaneous connections allowed
```shell
grep "MaxRequestWorkers" ${APACHE_CONFIG_FILE}
```

### Check the KeepAliveTimeout setting
```shell
grep "KeepAliveTimeout" ${APACHE_CONFIG_FILE}
```

### A sudden increase in traffic to the server could lead to a spike in CPU usage and the number of Keep-Alive connections.
```shell


#!/bin/bash



# Get the current CPU usage

cpu_usage=$(top -b -n1 | grep "Cpu(s)" | awk '{print $2 + $4}')



# Get the current number of Keep-Alive connections

keep_alive_connections=$(netstat -an | grep ":80" | awk '{print $6}' | sort | uniq -c | sort -n | grep "WAIT" | awk '{print $1}')



# Check if the CPU usage or number of Keep-Alive connections exceeds a certain threshold

if (( $(echo "$cpu_usage > ${CPU_THRESHOLD}" | bc -l) )) || (( $(echo "$keep_alive_connections > ${KEEP_ALIVE_THRESHOLD}" | bc -l) )); then

    echo "Warning: High CPU usage or Keep-Alive connections detected."

    # Add any additional diagnostic commands or actions here

fi


```

## Repair

### Set the desired MaxRequestWorkers value
```shell
max_workers=${NEW_MAX_WORKERS_VALUE}
```

### Set the Apache configuration file path
```shell
apache_conf=/etc/httpd/conf/httpd.conf
```

### Find the current MaxRequestWorkers line and replace its value
```shell
sed -i "s/^\s*MaxRequestWorkers\s*[0-9]\+/MaxRequestWorkers $max_workers/" $apache_conf
```

### Restart the Apache service
```shell
systemctl restart httpd.service
```

### Decrease the KeepAliveTimeout to avoid holding connections open longer than necessary.
```shell


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


```