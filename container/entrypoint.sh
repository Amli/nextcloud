#!/bin/sh
set -eu

# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
    _var="$1"
    _fileVar="${_var}_FILE"
    _def="${2:-}"
    _varValue=$(env | grep -E "^${_var}=" | sed -E -e "s/^${_var}=//")
    _fileVarValue=$(env | grep -E "^${_fileVar}=" | sed -E -e "s/^${_fileVar}=//")
    if [ -n "${_varValue}" ] && [ -n "${_fileVarValue}" ]; then
        echo >&2 "error: both $_var and $_fileVar are set (but are exclusive)"
        exit 1
    fi
    if [ -n "${_varValue}" ]; then
        export "$_var"="${_varValue}"
    elif [ -n "${_fileVarValue}" ]; then
        export "$_var"="$(cat "${_fileVarValue}")"
    elif [ -n "${_def}" ]; then
        export "$_var"="$_def"
    fi
    unset "$_fileVar"
}


if [ -n "${REDIS_HOST+x}" ]; then

    echo "Configuring Redis as session handler"
    {
        file_env REDIS_HOST_PASSWORD
        echo 'session.save_handler = redis'
        # check if redis host is an unix socket path
        if [ "$(echo "$REDIS_HOST" | cut -c1-1)" = "/" ]; then
            if [ -n "${REDIS_HOST_PASSWORD+x}" ]; then
            if [ -n "${REDIS_HOST_USER+x}" ]; then
                echo "session.save_path = \"unix://${REDIS_HOST}?auth[]=${REDIS_HOST_USER}&auth[]=${REDIS_HOST_PASSWORD}\""
            else
                echo "session.save_path = \"unix://${REDIS_HOST}?auth=${REDIS_HOST_PASSWORD}\""
            fi
            else
            echo "session.save_path = \"unix://${REDIS_HOST}\""
            fi
        # check if redis password has been set
        elif [ -n "${REDIS_HOST_PASSWORD+x}" ]; then
            if [ -n "${REDIS_HOST_USER+x}" ]; then
                echo "session.save_path = \"tcp://${REDIS_HOST}:${REDIS_HOST_PORT:=6379}?auth[]=${REDIS_HOST_USER}&auth[]=${REDIS_HOST_PASSWORD}\""
            else
                echo "session.save_path = \"tcp://${REDIS_HOST}:${REDIS_HOST_PORT:=6379}?auth=${REDIS_HOST_PASSWORD}\""
            fi
        else
            echo "session.save_path = \"tcp://${REDIS_HOST}:${REDIS_HOST_PORT:=6379}\""
        fi
        echo "redis.session.locking_enabled = 1"
        echo "redis.session.lock_retries = -1"
        # redis.session.lock_wait_time is specified in microseconds.
        # Wait 10ms before retrying the lock rather than the default 2ms.
        echo "redis.session.lock_wait_time = 10000"
    } > /usr/local/etc/php/conf.d/redis-session.ini
fi

exec "$@"
