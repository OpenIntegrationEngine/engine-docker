#!/usr/bin/env bash
#
# SPDX-License-Identifier: MPL-2.0
# SPDX-FileCopyrightText: 2023 NextGen Healthcare
# SPDX-FileCopyrightText: 2025 Kaur Palang
#

set -e

APP_DIR=/opt/oie

# Set (or append) a property in a Java .properties file.
#
#   set_property <key> <value> <file>
#
# The value is passed through the environment and read via awk's ENVIRON, so it
# is treated as a literal string. This avoids the sed replacement pitfalls where
# '&', '\' and '/' are special (e.g. a DATABASE_PASSWORD containing '&' would
# otherwise be expanded to the matched text and corrupt the file).
set_property() {
    local key=$1
    local value=$2
    local file=$3
    # Escape regex metacharacters in the key so it matches literally.
    local ekey
    # shellcheck disable=SC2016  # single quotes are intentional; this is a sed program, not shell
    ekey=$(printf '%s' "$key" | sed -e 's/[][\.*^$(){}?+|/-]/\\&/g')

    VALUE="$value" awk -v pattern="^${ekey}[[:space:]]*=" -v name="$key" '
        $0 ~ pattern { print name " = " ENVIRON["VALUE"]; found=1; next }
        { print }
        END { if (!found) print name " = " ENVIRON["VALUE"] }
    ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
}

MIRTH_PROPERTIES="$APP_DIR/conf/mirth.properties"

# set storepass and keypass to 'changeme' so they aren't overwritten later
KEYSTORE_PASS=changeme
set_property "keystore.storepass" "$KEYSTORE_PASS" "$MIRTH_PROPERTIES"
set_property "keystore.keypass"   "$KEYSTORE_PASS" "$MIRTH_PROPERTIES"

# merge the environment variables into mirth.properties
# db type
if ! [ -z "${DATABASE+x}" ]; then
	set_property "database" "$DATABASE" "$MIRTH_PROPERTIES"
fi

# db username
if ! [ -z "${DATABASE_USERNAME+x}" ]; then
	set_property "database.username" "$DATABASE_USERNAME" "$MIRTH_PROPERTIES"
fi

# db password
if ! [ -z "${DATABASE_PASSWORD+x}" ]; then
	set_property "database.password" "$DATABASE_PASSWORD" "$MIRTH_PROPERTIES"
fi

# db url
if ! [ -z "${DATABASE_URL+x}" ]; then
	set_property "database.url" "$DATABASE_URL" "$MIRTH_PROPERTIES"
fi

# database max connections
if ! [ -z "${DATABASE_MAX_CONNECTIONS+x}" ]; then
	set_property "database.max-connections" "$DATABASE_MAX_CONNECTIONS" "$MIRTH_PROPERTIES"
fi

# database max retries
if ! [ -z "${DATABASE_MAX_RETRY+x}" ]; then
	set_property "database.connection.maxretry" "$DATABASE_MAX_RETRY" "$MIRTH_PROPERTIES"
fi

# database retry wait time
if ! [ -z "${DATABASE_RETRY_WAIT+x}" ]; then
	set_property "database.connection.retrywaitinmilliseconds" "$DATABASE_RETRY_WAIT" "$MIRTH_PROPERTIES"
fi

# keystore storepass
if ! [ -z "${KEYSTORE_STOREPASS+x}" ]; then
	set_property "keystore.storepass" "$KEYSTORE_STOREPASS" "$MIRTH_PROPERTIES"
fi

# keystore keypass
if ! [ -z "${KEYSTORE_KEYPASS+x}" ]; then
	set_property "keystore.keypass" "$KEYSTORE_KEYPASS" "$MIRTH_PROPERTIES"
fi

if ! [ -z "${KEYSTORE_TYPE+x}" ]; then
	set_property "keystore.type" "$KEYSTORE_TYPE" "$MIRTH_PROPERTIES"
fi

# session store
if ! [ -z "${SESSION_STORE+x}" ]; then
	set_property "server.api.sessionstore" "$SESSION_STORE" "$MIRTH_PROPERTIES"
fi

#server ID
if ! [ -z "${SERVER_ID+x}" ]; then
  printf 'server.id = %s\n' "$SERVER_ID" > "$APP_DIR/appdata/server.id"
fi

# merge extra environment variables starting with _MP_ into mirth.properties
while read -r keyvalue; do
	KEY="${keyvalue%%=*}"
	VALUE="${keyvalue#*=}"
	VALUE=$(tr -dc '\40-\176' <<< "$VALUE")

	if ! [ -z "${KEY}" ] && ! [ -z "${VALUE}" ] && ! [[ ${VALUE} =~ ^\ +$ ]]; then

		# filter for variables starting with "_MP_"
		if [[ ${KEY} == _MP_* ]]; then

			# echo "found property ${KEY}=${VALUE}"

			# example: _MP_DATABASE_MAX__CONNECTIONS -> database.max-connections

			# remove _MP_
			# example:  DATABASE_MAX__CONNECTIONS
			ACTUAL_KEY=${KEY:4}

			# switch '__' to '-'
			# example:  DATABASE_MAX-CONNECTIONS
			ACTUAL_KEY="${ACTUAL_KEY//__/-}"

			# switch '_' to '.'
			# example:  DATABASE.MAX-CONNECTIONS
			ACTUAL_KEY="${ACTUAL_KEY//_/.}"

			# lower case
			# example:  database.max-connections
			ACTUAL_KEY="${ACTUAL_KEY,,}"

			set_property "${ACTUAL_KEY}" "${VALUE}" "$MIRTH_PROPERTIES"
		fi
	fi
done <<< "$(printenv)"

# merge vmoptions into oieserver.vmoptions
if ! [ -z "${VMOPTIONS+x}" ]; then
    PREV_IFS="$IFS"
	IFS=","
	read -ra vmoptions <<< "$VMOPTIONS"
	IFS="$PREV_IFS"

    for vmoption in "${vmoptions[@]}"
    do
        echo "${vmoption}" >> "$APP_DIR/oieserver.vmoptions"
    done
fi

# merge the user's secret mirth.properties
# takes a whole mirth.properties file and merges line by line with mirth.properties
if [ -f /run/secrets/mirth_properties ]; then

    while read -r keyvalue; do
        KEY="${keyvalue%%=*}"
        VALUE="${keyvalue#*=}"

        # remove leading and trailing white space
        KEY="$(echo -e "${KEY}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
        VALUE="$(echo -e "${VALUE}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"

        if ! [ -z "${KEY}" ] && ! [ -z "${VALUE}" ] && ! [[ ${VALUE} =~ ^\ +$ ]]; then
            set_property "${KEY}" "${VALUE}" "$MIRTH_PROPERTIES"
        fi
    done <<< "$(cat /run/secrets/mirth_properties)"
fi

# merge the user's secret vmoptions
# takes a whole oieserver.vmoptions file and merges line by line with oieserver.vmoptions
if [ -f /run/secrets/oieserver_vmoptions ]; then
    (cat /run/secrets/oieserver_vmoptions ; echo "") >> "$APP_DIR/oieserver.vmoptions"
fi

 download jars from this url "$CUSTOM_JARS_DOWNLOAD", set by user
if ! [ -z "${CUSTOM_JARS_DOWNLOAD+x}" ]; then
	echo "Downloading Jars at ${CUSTOM_JARS_DOWNLOAD}"
	if ! [ -z "${ALLOW_INSECURE}" ] && [ "${ALLOW_INSECURE}" == "true" ]; then
		curl -ksSLf "${CUSTOM_JARS_DOWNLOAD}" -o userJars.zip || echo "problem with custom jars download"
	else
		curl -sSLf "${CUSTOM_JARS_DOWNLOAD}" -o userJars.zip || echo "problem with custom jars download"
	fi

	# Unzipping contents of userJars.zip into /opt/engine/server-launcher-lib folder
	if [ -e "userJars.zip" ]; then
		echo "Unzipping contents of userJars.zip into $APP_DIR/server-launcher-lib"
		unzip userJars.zip -d "$APP_DIR/server-launcher-lib"
		# removing the downloaded zip file
		rm userJars.zip
	fi
fi

# download extensions from this url "$EXTENSIONS_DOWNLOAD", set by user
if ! [ -z "${EXTENSIONS_DOWNLOAD+x}" ]; then
	echo "Downloading extensions at ${EXTENSIONS_DOWNLOAD}"
	if ! [ -z "${ALLOW_INSECURE}" ] && [ "${ALLOW_INSECURE}" == "true" ]; then
		curl -ksSLf "${EXTENSIONS_DOWNLOAD}" -o  userExtensions.zip || echo "problem with extensions download"
	else
		curl -sSLf "${EXTENSIONS_DOWNLOAD}" -o userExtensions.zip || echo "problem with extensions download"
	fi

	# Unzipping contents of userExtensions.zip
	if [ -e "userExtensions.zip" ]; then
		echo "Unzipping contents of userExtensions.zip"
		mkdir /tmp/userextensions
		unzip userExtensions.zip -d /tmp/userextensions
		# removing the downloaded zip file
		rm userExtensions.zip

		# Unzipping contents of individual extension zip files into /opt/engine/extensions folder
		zipFileCount=`ls -1 /tmp/userextensions/*.zip 2>/dev/null | wc -l`
		if [ $zipFileCount != 0 ]; then
			echo "Unzipping contents of /tmp/userextensions/ zips into $APP_DIR/extensions"
			for f in /tmp/userextensions/*.zip; do unzip "$f" -d "$APP_DIR/extensions"; done
		fi
		# removing the tmp folder
		rm -rf /tmp/userextensions
	fi
fi

# download keystore
if ! [ -z "${KEYSTORE_DOWNLOAD+x}" ]; then
	echo "Downloading keystore at ${KEYSTORE_DOWNLOAD}"
	if ! [ -z "${ALLOW_INSECURE}" ] && [ "${ALLOW_INSECURE}" == "true" ]; then
		curl -ksSLf "${KEYSTORE_DOWNLOAD}" -o "$APP_DIR/appdata/keystore.jks" || echo "problem with keystore download"
	else
		curl -sSLf "${KEYSTORE_DOWNLOAD}" -o "$APP_DIR/appdata/keystore.jks" || echo "problem with keystore download"
	fi
fi

# if delay is set as an environment variable then wait that long in seconds
if ! [ -z "${DELAY+x}" ]; then
	sleep $DELAY
fi

exec "$@"
