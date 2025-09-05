#!/usr/bin/env bash
# shellcheck shell=bash
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
##@Version           :  202408270904-git
# @@Author           :  Jason Hempstead
# @@Contact          :  jason@casjaysdev.pro
# @@License          :  WTFPL
# @@ReadME           :  01-remotely.sh --help
# @@Copyright        :  Copyright: (c) 2024 Jason Hempstead, Casjays Developments
# @@Created          :  Tuesday, Aug 27, 2024 09:04 EDT
# @@File             :  01-remotely.sh
# @@Description      :
# @@Changelog        :  New script
# @@TODO             :  Better documentation
# @@Other            :
# @@Resource         :
# @@Terminal App     :  no
# @@sudo/root        :  no
# @@Template         :  other/start-service
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# shellcheck disable=SC2016
# shellcheck disable=SC2031
# shellcheck disable=SC2120
# shellcheck disable=SC2155
# shellcheck disable=SC2199
# shellcheck disable=SC2317
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# run trap command on exit
trap 'retVal=$?;[ "$SERVICE_IS_RUNNING" != "yes" ] && [ -f "$SERVICE_PID_FILE" ] && rm -Rf "$SERVICE_PID_FILE";exit $retVal' SIGINT SIGTERM EXIT
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# setup debugging
[ -f "/config/.debug" ] && [ -z "$DEBUGGER_OPTIONS" ] && export DEBUGGER_OPTIONS="$(<"/config/.debug")" || DEBUGGER_OPTIONS="${DEBUGGER_OPTIONS:-}"
{ [ "$DEBUGGER" = "on" ] || [ -f "/config/.debug" ]; } && echo "Enabling debugging" && set -xo pipefail -x$DEBUGGER_OPTIONS && export DEBUGGER="on" || set -o pipefail
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
export PATH="/usr/local/etc/docker/bin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
SCRIPT_FILE="$0"
SERVICE_NAME="remotely"
SCRIPT_NAME="$(basename "$SCRIPT_FILE" 2>/dev/null)"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# exit if __start_init_scripts function hasn't been Initialized
if [ ! -f "/run/__start_init_scripts.pid" ]; then
  echo "__start_init_scripts function hasn't been Initialized" >&2
  SERVICE_IS_RUNNING="no"
  exit 1
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# import the functions file
if [ -f "/usr/local/etc/docker/functions/entrypoint.sh" ]; then
  . "/usr/local/etc/docker/functions/entrypoint.sh"
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# import variables
for set_env in "/root/env.sh" "/usr/local/etc/docker/env"/*.sh "/config/env"/*.sh; do
  [ -f "$set_env" ] && . "$set_env"
done
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
printf '%s\n' "# - - - Initializing $SERVICE_NAME - - - #"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Script to execute
START_SCRIPT="/usr/local/etc/docker/exec/$SERVICE_NAME"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Reset environment before executing service
RESET_ENV="no"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Default predefined variables
DATA_DIR="/data/remotely"   # set data directory
CONF_DIR="/config/remotely" # set config directory
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# set the containers etc directory
ETC_DIR="/etc/remotely"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
TMP_DIR="/tmp/remotely"       # set the temp dir
RUN_DIR="/run/remotely"       # set scripts pid dir
LOG_DIR="/data/logs/remotely" # set log directory
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# port which service is listening on
SERVICE_PORT="5000"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# User to use to launch service
RUNAS_USER="root"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# User and group in which the service switches to
SERVICE_USER="nginx"
SERVICE_GROUP="nginx"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Set user and group ID
SERVICE_UID="0"
SERVICE_GID="0"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# execute command variables
EXEC_CMD_BIN='remotely'
EXEC_CMD_ARGS='--config $CONF_DIR/remotely.conf'
EXEC_PRE_SCRIPT=''
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Is this service a web server
IS_WEB_SERVER="no"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Is this service a database server
IS_DATABASE_SERVICE="no"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Does this service use a database server
USES_DATABASE_SERVICE="no"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
APPLICATION_FILES="$LOG_DIR/$SERVICE_NAME.log"
APPLICATION_DIRS="$RUN_DIR $ETC_DIR $CONF_DIR $LOG_DIR $TMP_DIR"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Load variables from config
[ -f "/config/env/remotely.script.sh" ] && . "/config/env/remotely.script.sh"
[ -f "/config/env/remotely.sh" ] && . "/config/env/remotely.sh"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Standard service initialization follows the same pattern as other repos
SERVICE_EXIT_CODE=0
EXEC_CMD_NAME="$(basename "$EXEC_CMD_BIN")"
SERVICE_PID_FILE="/run/init.d/$EXEC_CMD_NAME.pid"
SERVICE_PID_NUMBER="$(__pgrep)"
EXEC_CMD_BIN="$(type -P "$EXEC_CMD_BIN" || echo "$EXEC_CMD_BIN")"
EXEC_PRE_SCRIPT="$(type -P "$EXEC_PRE_SCRIPT" || echo "$EXEC_PRE_SCRIPT")"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Only run check
__check_service "$1" && SERVICE_IS_RUNNING=yes
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# ensure needed directories exists
[ -d "$LOG_DIR" ] || mkdir -p "$LOG_DIR"
[ -d "$RUN_DIR" ] || mkdir -p "$RUN_DIR"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Standard service startup procedure
__create_service_user "$SERVICE_USER" "$SERVICE_GROUP" "${WORK_DIR:-/home/$SERVICE_USER}" "${SERVICE_UID:-}" "${SERVICE_GID:-}"
__set_user_group_id $SERVICE_USER ${SERVICE_UID:-} ${SERVICE_GID:-}
__setup_directories
__switch_to_user
__init_working_dir
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Initialize the service
__init_config_etc
__initialize_replace_variables "$ETC_DIR" "$CONF_DIR" "$WWW_ROOT_DIR"
__fix_permissions "$SERVICE_USER" "$SERVICE_GROUP"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Custom setup for remotely
__update_conf_files() {
  mkdir -p "$CONF_DIR" "$DATA_DIR"
  # Create basic remotely config if it doesn't exist
  if [ ! -f "$CONF_DIR/remotely.conf" ]; then
    cat <<EOF > "$CONF_DIR/remotely.conf"
# Remotely configuration
[server]
port = $SERVICE_PORT
host = 0.0.0.0
data_dir = $DATA_DIR

EOF
  fi
}
__update_conf_files
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Start the service using standard pattern
__run_start_script() {
  local cmd="$(eval echo "${EXEC_CMD_BIN:-}")"
  local args="$(eval echo "${EXEC_CMD_ARGS:-}")"
  local name="$(basename "$cmd")"
  
  if [ -z "$cmd" ]; then
    echo "Initializing $SCRIPT_NAME has completed"
    exit 0
  fi
  
  if [ ! -x "$cmd" ]; then
    echo "$name is not a valid executable"
    return 2
  fi
  
  if __proc_check "$name"; then
    echo "$name is already running" >&2
    return 0
  fi
  
  echo "Starting service: $name $args"
  eval "$cmd $args" 2>>/dev/stderr >>"$LOG_DIR/$SERVICE_NAME.log" &
  execPid=$!
  sleep 10
  checkPID="$(ps ax | awk '{print $1}' | grep -v grep | grep "$execPid$" || false)"
  
  if [ -n "$execPid" ] && [ -n "$checkPID" ]; then
    echo "$execPid" >"$SERVICE_PID_FILE"
    echo "$cmd has been started"
    return 0
  else
    echo "Failed to start $cmd" >&2
    return 1
  fi
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
__run_start_script
errorCode=$?
if [ -n "$EXEC_CMD_BIN" ]; then
  if [ "$errorCode" -eq 0 ]; then
    SERVICE_EXIT_CODE=0
    SERVICE_IS_RUNNING="yes"
  else
    SERVICE_EXIT_CODE=$errorCode
    SERVICE_IS_RUNNING="no"
    [ -s "$SERVICE_PID_FILE" ] || rm -Rf "$SERVICE_PID_FILE"
  fi
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
echo "Initializing of $SERVICE_NAME has completed with statusCode: $SERVICE_EXIT_CODE"
exit $SERVICE_EXIT_CODE