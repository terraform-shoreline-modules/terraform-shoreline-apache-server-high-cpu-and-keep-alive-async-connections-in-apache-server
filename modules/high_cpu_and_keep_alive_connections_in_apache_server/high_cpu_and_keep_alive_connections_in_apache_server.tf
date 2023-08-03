resource "shoreline_notebook" "high_cpu_and_keep_alive_connections_in_apache_server" {
  name       = "high_cpu_and_keep_alive_connections_in_apache_server"
  data       = file("${path.module}/data/high_cpu_and_keep_alive_connections_in_apache_server.json")
  depends_on = [shoreline_action.invoke_cpu_keep_alive_monitor,shoreline_action.invoke_update_keepalive_timeout]
}

resource "shoreline_file" "cpu_keep_alive_monitor" {
  name             = "cpu_keep_alive_monitor"
  input_file       = "${path.module}/data/cpu_keep_alive_monitor.sh"
  md5              = filemd5("${path.module}/data/cpu_keep_alive_monitor.sh")
  description      = "A sudden increase in traffic to the server could lead to a spike in CPU usage and the number of Keep-Alive connections."
  destination_path = "/agent/scripts/cpu_keep_alive_monitor.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "update_keepalive_timeout" {
  name             = "update_keepalive_timeout"
  input_file       = "${path.module}/data/update_keepalive_timeout.sh"
  md5              = filemd5("${path.module}/data/update_keepalive_timeout.sh")
  description      = "Decrease the KeepAliveTimeout to avoid holding connections open longer than necessary."
  destination_path = "/agent/scripts/update_keepalive_timeout.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_cpu_keep_alive_monitor" {
  name        = "invoke_cpu_keep_alive_monitor"
  description = "A sudden increase in traffic to the server could lead to a spike in CPU usage and the number of Keep-Alive connections."
  command     = "`chmod +x /agent/scripts/cpu_keep_alive_monitor.sh && /agent/scripts/cpu_keep_alive_monitor.sh`"
  params      = ["CPU_THRESHOLD","KEEP_ALIVE_THRESHOLD"]
  file_deps   = ["cpu_keep_alive_monitor"]
  enabled     = true
  depends_on  = [shoreline_file.cpu_keep_alive_monitor]
}

resource "shoreline_action" "invoke_update_keepalive_timeout" {
  name        = "invoke_update_keepalive_timeout"
  description = "Decrease the KeepAliveTimeout to avoid holding connections open longer than necessary."
  command     = "`chmod +x /agent/scripts/update_keepalive_timeout.sh && /agent/scripts/update_keepalive_timeout.sh`"
  params      = ["PATH_TO_APACHE_CONF_FILE"]
  file_deps   = ["update_keepalive_timeout"]
  enabled     = true
  depends_on  = [shoreline_file.update_keepalive_timeout]
}

