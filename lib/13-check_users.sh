#!/bin/bash
#
# **  nextcloudbackupsawss3  **
# **       check users          **
#
# Utility to make backups of Nextcloud and store them in an S3 bucket
# Check if provided nexcloud users exist
#
# Álvaro Castellano Vela - https://github.com/a-castellano

# Logger
source lib/01-default_values_and_commands.sh
source lib/02-usage.sh
source lib/04-logger.sh

function check_users {
    if [[ -v VERBOSE ]]; then
        write_log "Recollectiong database users to backup."
    fi
    users_in_database=$(mysql -u$DATABASE_USER -p$DATABASE_PASSWD --port=$DATABASE_PORT -h $DATABASE_HOST $DATABASE_NAME -Bse "select uid from oc_users;")
    if [[ ! "$NEXTCLOUD_USERS" = "ALL" ]]; then
        selected_users=""
        provided_users=$($ECHO $NEXTCLOUD_USERS | $SED 's/,/ /g')
        lost_users=""
        for user in $provided_users
        do
            $ECHO $users_in_database | $GREP -w $user > /dev/null;
            user_in_database=$?
            #if ! $ECHO $users_in_database | $GREP -w $user > /dev/null; then
            if [[ $user_in_database -eq 1 ]]; then
                lost_users="$user $lost_users"
            else
                selected_users="$user $selected_users"
            fi
        done
        if [[ ! -z "$lost_users" ]];then
            error_msg="The following users are not present as Nexcloud users: $lost_users. Please, provide a valid list of users."
            report_error $error_msg
            exit 1
        fi
    else
        provided_users=$users_in_database
    fi
    if [[ -v VERBOSE ]]; then
        write_log "Users with data to be backuped: $provided_users"
    fi
    echo $provided_users
}
