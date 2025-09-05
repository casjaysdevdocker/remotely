#!/usr/bin/env bash
# shellcheck shell=bash
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
##@Version           :  202408270903-git
# @@Author           :  Jason Hempstead
# @@Contact          :  jason@casjaysdev.pro
# @@License          :  WTFPL
# @@ReadME           :  entrypoint.sh --help
# @@Copyright        :  Copyright: (c) 2024 Jason Hempstead, Casjays Developments
# @@Created          :  Tuesday, Aug 27, 2024 09:03 EDT
# @@File             :  entrypoint.sh
# @@Description      :  Entrypoint file for remotely
# @@Changelog        :  New script
# @@TODO             :  Better documentation
# @@Other            :
# @@Resource         :
# @@Terminal App     :  no
# @@sudo/root        :  no
# @@Template         :  other/docker-entrypoint
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# shellcheck disable=SC2016
# shellcheck disable=SC2031
# shellcheck disable=SC2120
# shellcheck disable=SC2155
# shellcheck disable=SC2199
# shellcheck disable=SC2317
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# setup debugging - https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html
[ -f "/config/.debug" ] && [ -z "$DEBUGGER_OPTIONS" ] && export DEBUGGER_OPTIONS="$(<"/config/.debug")" || DEBUGGER_OPTIONS="${DEBUGGER_OPTIONS:-}"
{ [ "$DEBUGGER" = "on" ] || [ -f "/config/.debug" ]; } && echo "Enabling debugging" && set -o pipefail -x$DEBUGGER_OPTIONS && export DEBUGGER="on" || set -o pipefail
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
PATH="/usr/local/etc/docker/bin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Set bash options
SCRIPT_FILE="$0"
CONTAINER_NAME="remotely"
SCRIPT_NAME="$(basename "$SCRIPT_FILE" 2>/dev/null)"
CONTAINER_NAME="${ENV_CONTAINER_NAME:-$CONTAINER_NAME}"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# remove whitespaces from beginning argument
while :; do [ "$1" = " " ] && shift 1 || break; done
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
[ "$1" = "$SCRIPT_FILE" ] && shift 1
[ "$1" = "$SCRIPT_NAME" ] && shift 1
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# import the functions file
if [ -f "/usr/local/etc/docker/functions/entrypoint.sh" ]; then
  . "/usr/local/etc/docker/functions/entrypoint.sh"
else
  echo "Can not load functions from /usr/local/etc/docker/functions/entrypoint.sh"
  exit 1
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
case "$1" in
# Help message
-h | --help)
  shift 1
  echo 'Docker container for '$CONTAINER_NAME''
  echo "Usage: $CONTAINER_NAME [cron exec start init shell certbot ssl procs ports healthcheck backup command]"
  echo ""
  exit 0
  ;;
-*)
  shift
  ;;
esac
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Create the default env files
__create_env_file "/config/env/default.sh" "/root/env.sh" &>/dev/null
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# import variables from files
for set_env in "/root/env.sh" "/usr/local/etc/docker/env"/*.sh "/config/env"/*.sh; do
  [ -f "$set_env" ] && . "$set_env"
done
unset set_env
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# User to use to launch service - IE: postgres
RUNAS_USER="root" # normally root
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# User and group in which the service switches to - IE: nginx,apache,mysql,postgres
SERVICE_USER="nginx"  # execute command as another user
SERVICE_GROUP="nginx" # Set the service group
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Set user and group ID
SERVICE_UID="0" # set the user id
SERVICE_GID="0" # set the group id
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Primary server port- will be added to server ports
WEB_SERVER_PORT="" # port : 80,443
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Secondary ports
SERVER_PORTS="" # specifiy other ports
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Healthcheck variables
HEALTH_ENABLED="yes"                     # enable healthcheck [yes/no]
SERVICES_LIST="tini,remotely,nginx"      # auto-detected from init.d scripts
HEALTH_ENDPOINTS=""                      # url endpoints: [http://localhost/health,http://localhost/test]
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Update path var
export PATH RUNAS_USER SERVICE_USER SERVICE_GROUP SERVICE_UID SERVICE_GID WWW_ROOT_DIR DATABASE_DIR
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Custom variables

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# show message
__run_message() {

  return
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
################## END OF CONFIGURATION #####################
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Startup variables
export INIT_DATE="${INIT_DATE:-$(date)}"
export CONTAINER_INIT="${CONTAINER_INIT:-no}"
export START_SERVICES="${START_SERVICES:-yes}"
export ENTRYPOINT_MESSAGE="${ENTRYPOINT_MESSAGE:-yes}"
export ENTRYPOINT_FIRST_RUN="${ENTRYPOINT_FIRST_RUN:-yes}"
export DATA_DIR_INITIALIZED="${DATA_DIR_INITIALIZED:-no}"
export CONFIG_DIR_INITIALIZED="${CONFIG_DIR_INITIALIZED:-no}"
export CONTAINER_NAME="${ENV_CONTAINER_NAME:-$CONTAINER_NAME}"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# System
export LANG="${LANG:-C.UTF-8}"
export LC_ALL="${LANG:-C.UTF-8}"
export TZ="${TZ:-${TIMEZONE:-America/New_York}}"
export HOSTNAME="${FULL_DOMAIN_NAME:-${SERVER_HOSTNAME:-$HOSTNAME}}"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Default directories
export SSL_DIR="${SSL_DIR:-/config/ssl}"
export SSL_CA="${SSL_CERT:-/config/ssl/ca.crt}"
export SSL_KEY="${SSL_KEY:-/config/ssl/localhost.pem}"
export SSL_CERT="${SSL_CERT:-/config/ssl/localhost.crt}"
export BACKUP_DIR="${BACKUP_DIR:-/data/backups}"
export LOCAL_BIN_DIR="${LOCAL_BIN_DIR:-/usr/local/bin}"
export DEFAULT_DATA_DIR="${DEFAULT_DATA_DIR:-/usr/local/share/template-files/data}"
export DEFAULT_CONF_DIR="${DEFAULT_CONF_DIR:-/usr/local/share/template-files/config}"
export DEFAULT_TEMPLATE_DIR="${DEFAULT_TEMPLATE_DIR:-/usr/local/share/template-files/defaults}"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Additional
export PHP_INI_DIR="${PHP_INI_DIR:-$(__find_php_ini)}"
export PHP_BIN_DIR="${PHP_BIN_DIR:-$(__find_php_bin)}"
export HTTPD_CONFIG_FILE="${HTTPD_CONFIG_FILE:-$(__find_httpd_conf)}"
export NGINX_CONFIG_FILE="${NGINX_CONFIG_FILE:-$(__find_nginx_conf)}"
export MYSQL_CONFIG_FILE="${MYSQL_CONFIG_FILE:-$(__find_mysql_conf)}"
export PGSQL_CONFIG_FILE="${PGSQL_CONFIG_FILE:-$(__find_pgsql_conf)}"
export MONGODB_CONFIG_FILE="${MONGODB_CONFIG_FILE:-$(__find_mongodb_conf)}"
export ENTRYPOINT_PID_FILE="${ENTRYPOINT_PID_FILE:-$ENTRYPOINT_PID_FILE}"
export ENTRYPOINT_INIT_FILE="${ENTRYPOINT_INIT_FILE:-/config/.entrypoint.done}"
export ENTRYPOINT_DATA_INIT_FILE="${ENTRYPOINT_DATA_INIT_FILE:-/data/.docker_has_run}"
export ENTRYPOINT_CONFIG_INIT_FILE="${ENTRYPOINT_CONFIG_INIT_FILE:-/config/.docker_has_run}"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# variables based on env/files
[ -f "/config/enable/ssl" ] && SSL_ENABLED="yes"
[ -f "/config/enable/ssh" ] && SSH_ENABLED="yes"
[ "$WEB_SERVER_PORT" = "443" ] && SSL_ENABLED="yes"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# export variables

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# is already Initialized
[ -f "$ENTRYPOINT_DATA_INIT_FILE" ] && DATA_DIR_INITIALIZED="yes" || DATA_DIR_INITIALIZED="no"
[ -f "$ENTRYPOINT_CONFIG_INIT_FILE" ] && CONFIG_DIR_INITIALIZED="yes" || CONFIG_DIR_INITIALIZED="no"
{ [ -f "$ENTRYPOINT_PID_FILE" ] || [ -f "$ENTRYPOINT_INIT_FILE" ]; } && ENTRYPOINT_FIRST_RUN="no" || ENTRYPOINT_FIRST_RUN="yes"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# clean ENV_PORTS variables
ENV_PORTS="${ENV_PORTS//,/ }"  #
ENV_PORTS="${ENV_PORTS//\/*/}" #
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# clean SERVER_PORTS variables
SERVER_PORTS="${SERVER_PORTS//,/ }"  #
SERVER_PORTS="${SERVER_PORTS//\/*/}" #
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# clean WEB_SERVER_PORTS variables
WEB_SERVER_PORTS="${WEB_SERVER_PORT//\/*/}"                             #
WEB_SERVER_PORTS="${WEB_SERVER_PORTS//\/*/}"                            #
WEB_SERVER_PORTS="${WEB_SERVER_PORT//,/ } ${ENV_WEB_SERVER_PORTS//,/ }" #
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# rewrite and merge variables
ENV_PORTS="$(__format_variables "$ENV_PORTS" || false)"
WEB_SERVER_PORTS="$(__format_variables "$WEB_SERVER_PORTS" || false)"
ENV_PORTS="$(__format_variables "$SERVER_PORTS" "$WEB_SERVER_PORTS" "$ENV_PORTS" "$SERVER_PORTS" || false)"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#
HEALTH_ENDPOINTS="${HEALTH_ENDPOINTS//,/ }"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# create required directories
mkdir -p "/run"
mkdir -p "/tmp"
mkdir -p "/root"
mkdir -p "/var/run"
mkdir -p "/var/tmp"
mkdir -p "/run/cron"
mkdir -p "/data/logs"
mkdir -p "/run/init.d"
mkdir -p "/config/enable"
mkdir -p "/config/secure"
mkdir -p "/usr/local/etc/docker/exec"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# create required files
touch "/data/logs/start.log"
touch "/data/logs/entrypoint.log"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# fix permissions
chmod -f 777 "/run"
chmod -f 777 "/tmp"
chmod -f 700 "/root"
chmod -f 777 "/var/run"
chmod -f 777 "/var/tmp"
chmod -f 777 "/run/cron"
chmod -f 777 "/data/logs"
chmod -f 777 "/run/init.d"
chmod -f 777 "/config/enable"
chmod -f 777 "/config/secure"
chmod -f 777 "/data/logs/entrypoint.log"
chmod -f 777 "/usr/local/etc/docker/exec"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# lets ensure everyone can write to std*
[ -f "/dev/stdin" ] && chmod -f 777 "/dev/stdin"
[ -f "/dev/stderr" ] && chmod -f 777 "/dev/stderr"
[ -f "/dev/stdout" ] && chmod -f 777 "/dev/stdout"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
cat <<EOF | tee /etc/profile.d/locales.shadow /etc/profile.d/locales.sh >/dev/null
export LANG="\${LANG:-C.UTF-8}"
export LC_ALL="\${LANG:-C.UTF-8}"
export TZ="\${TZ:-\${TIMEZONE:-America/New_York}}"
EOF
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Create the backup dir
[ -n "$BACKUP_DIR" ] && { [ -d "$BACKUP_DIR" ] || mkdir -p "$BACKUP_DIR"; }
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if [ -f "$ENTRYPOINT_PID_FILE" ]; then
  START_SERVICES="no"
  touch "$ENTRYPOINT_PID_FILE"
else
  echo "$$" >"$ENTRYPOINT_PID_FILE"
fi
if [ -f "$ENTRYPOINT_INIT_FILE" ]; then
  ENTRYPOINT_MESSAGE="no" ENTRYPOINT_FIRST_RUN="no"
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if [ "$ENTRYPOINT_FIRST_RUN" != "no" ]; then
  # Show start message
  if [ "$CONFIG_DIR_INITIALIZED" = "no" ] || [ "$DATA_DIR_INITIALIZED" = "no" ]; then
    [ "$ENTRYPOINT_MESSAGE" = "yes" ] && echo "Executing entrypoint script for remotely"
  fi
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Set reusable variables
  { { [ -w "/etc" ] && [ ! -e "/etc/hosts" ]; } || [ -w "/etc/hosts" ]; } && UPDATE_FILE_HOSTS="yes"
  { { [ -w "/etc" ] && [ ! -e "/etc/timezone" ]; } || [ -w "/etc/timezone" ]; } && UPDATE_FILE_TZ="yes"
  { { [ -w "/etc" ] && [ ! -e "/etc/resolv.conf" ]; } || [ -w "/etc/resolv.conf" ]; } && UPDATE_FILE_RESOLV="yes"
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Set timezone
  [ -n "$TZ" ] && [ "$UPDATE_FILE_TZ" = "yes" ] && echo "$TZ" >"/etc/timezone"
  [ -f "/usr/share/zoneinfo/$TZ" ] && [ "$UPDATE_FILE_TZ" = "yes" ] && ln -sf "/usr/share/zoneinfo/$TZ" "/etc/localtime"
  # Standard entrypoint initialization continues...
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# if no pid assume container restart - clean stale files on restart
if [ ! -f "$ENTRYPOINT_PID_FILE" ]; then 
  START_SERVICES="yes"
  # Clean stale pid files from previous container runs
  rm -f /run/__start_init_scripts.pid /run/init.d/*.pid /run/*.pid
elif [ ! -f "/run/__start_init_scripts.pid" ]; then
  START_SERVICES="yes" 
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Setup standard directories and initialization
__initialize_custom_bin_dir
__initialize_default_templates
__initialize_config_dir
__initialize_data_dir
__initialize_ssl_certs
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Start all services if no pidfile
if [ "$START_SERVICES" = "yes" ] && [ "$1" != "backup" ] && [ "$1" != "healthcheck" ]; then
  [ "$1" = "start" ] && shift 1
  [ "$1" = "all" ] && shift 1
  [ "$1" = "init" ] && export CONTAINER_INIT="yes"
  echo "$$" >"$ENTRYPOINT_PID_FILE"
  __start_init_scripts "/usr/local/etc/docker/init.d"
  START_SERVICES="no"
  CONTAINER_INIT="${CONTAINER_INIT:-no}"
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Standard entrypoint command handling
case "$1" in
init)
  shift 1
  echo "Container has been Initialized"
  exit 0
  ;;
healthcheck)
  shift
  healthStatus=0
  services="${SERVICES_LIST:-$@}"
  healthEnabled="${HEALTH_ENABLED:-}"
  healthMessage="Everything seems to be running"
  services="${services//,/ }"
  { [ "$1" = "init" ] || [ "$1" = "test" ]; } && exit 0
  [ "$healthEnabled" = "yes" ] || exit 0
  for proc in $services; do
    if [ -n "$proc" ]; then
      if ! __pgrep "$proc"; then
        echo "$proc is not running" >&2
        healthStatus=$((healthStatus + 1))
      fi
    fi
  done
  [ "$healthStatus" -eq 0 ] || healthMessage="Errors reported see: docker logs --follow $CONTAINER_NAME"
  [ -n "$healthMessage" ] && echo "$healthMessage"
  exit $healthStatus
  ;;
*)
  if [ $# -eq 0 ]; then
    if [ ! -f "$ENTRYPOINT_PID_FILE" ]; then
      echo "$$" >"$ENTRYPOINT_PID_FILE"
      [ "$START_SERVICES" = "no" ] && [ "$CONTAINER_INIT" = "yes" ] || __start_init_scripts "/usr/local/etc/docker/init.d"
    fi
    __no_exit
  else
    __exec_command "$@"
  fi
  exit $?
  ;;
esac