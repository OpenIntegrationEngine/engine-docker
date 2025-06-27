<a name="top"></a>
# Table of Contents

* [Supported tags and respective Dockerfile links](#supported-tags)
* [Supported Architectures](#supported-architectures)
* [Quick Reference](#quick-reference)
* [What is Mirth Connect](#what-is-connect)
* [How to use this image](#how-to-use)
    * [Start a Connect instance](#start-connect)
    * [Using `docker stack deploy` or `docker-compose`](#using-docker-compose)
    * [Environment Variables](#environment-variables)
        * [Common mirth.properties options](#common-mirth-properties-options)
        * [Other mirth.properties options](#other-mirth-properties-options)
    * [Using Docker Secrets](#using-docker-secrets)
    * [Using Volumes](#using-volumes)
        * [The appdata folder](#the-appdata-folder)
        * [Additional extensions](#additional-extensions)
* [License](#license)

------------

<a name="supported-tags"></a>
# Supported Images [↑](#top)

All Open Integration Engine releases are packaged into the four following images:

- `latest`, `latest-alpine`, `latest-alpine-jre`
    - `4.5.2-tp.1-alpine`, `4.5.2-tp.1-alpine-jre`
- `latest-alpine-jdk`
    - `4.5.2-tp.1-alpine-jdk`
- `latest-ubuntu`, `latest-ubuntu-jre`
    - `4.5.2-tp.1-ubuntu`, `4.5.2-tp.1-ubuntu-jre`
- `latest-ubuntu-jdk`
    - `4.5.2-tp.1-ubuntu-jdk`

------------

<a name="supported-architectures"></a>
# Supported Architectures [↑](#top)

Docker images for OIE 4.5.2 and later versions support both `linux/amd64` and `linux/arm64` architectures. As an example, to pull the latest `linux/arm64` image, use the command
```
docker pull --platform linux/arm64 openintegrationengine/engine:latest
```

------------

<a name="quick-reference"></a>
# Quick Reference [↑](#top)

#### Where to get help:

- 🌐 **Website**: [openintegrationengine.org](https://openintegrationengine.org)
- 💬 **Discord**: [Join our server](https://discord.gg/azdehW2Zrx)
- 📂 **GitHub Repo**: [github.com/OpenIntegrationEngine/engine](https://github.com/OpenIntegrationEngine/engine)

#### How to file issues:

https://github.com/OpenIntegrationEngine/engine/issues

Please do your best to include the following information in your issue:
* The exact commit hash of the code you are using
* The commands you executed to build or run the image
* The output of the command you executed (Hint add `--progress=plain` to your `docker` command to see the full output)
* Use [Markdown](https://guides.github.com/features/mastering-markdown/) to format your issue text, ESPECIALLY if you are including code snippets or command output. This will make it easier for us to read and understand your issue.

------------

<a name="what-is-oie"></a>
# What is Open Integration Engine [↑](#top)

An open-source message integration engine focused on healthcare. For more information please visit [openintegrationengine.org](https://openintegrationengine.org).

OpenIntegrationEngine is a community-driven project that continues the legacy of Mirth Connect, providing a flexible, open platform for managing healthcare interfaces. It supports a wide range of healthcare standards and protocols, enabling seamless integration between disparate systems.

OpenIntegrationEngine is designed to be vendor-neutral, allowing healthcare organizations to connect their systems without being locked into proprietary solutions. It offers a user-friendly interface for building, deploying, and managing interfaces, along with powerful features for real-time monitoring and alerting.

------------

<a name="how-to-use"></a>
# How to use this image [↑](#top)

<a name="start-connect"></a>
## Start an OpenIntegrationEngine instance [↑](#top)

Quickly start OpenIntegration using embedded Derby database and all configuration defaults. At a minimum you will likely want to use the `-p` option to expose the 8443 port so that you can login with the Administrator GUI or CLI:

```bash
docker run -p 8443:8443 openintegrationengine/engine:latest-ubuntu-jre
```

You can also use the `--name` option to give your container a unique name, and the `-d` option to detach the container and run it in the background:

```bash
docker run --name myconnect -d -p 8443:8443 openintegrationengine/engine:latest-ubuntu-jre
```

To run a different base image, specify a tag at the end:

```bash
docker run --name myconnect -d -p 8443:8443 openintegrationengine/engine:latest-alpine-jdk
```

To run using a specific architecture, specify it using the `--platform` argument:

```bash
docker run --name myconnect -d -p 8443:8443 --platform linux/arm64 openintegrationengine/engine:latest-ubuntu-jre
```

Look at the [Environment Variables](#environment-variables) section for more available configuration options.

------------

<a name="using-docker-compose"></a>
## Using [`docker stack deploy`](https://docs.docker.com/engine/reference/commandline/stack_deploy/) or [`docker-compose`](https://github.com/docker/compose) [↑](#top)

With `docker stack` or `docker-compose` you can easily setup and launch multiple related containers. For example you might want to launch both Connect *and* a PostgreSQL database to run alongside it.

```bash
docker-compose -f stack.yml up
```

Here's an example `stack.yml` file you can use:

```yaml
version: "3.1"
services:
  mc:
    image: openintegrationengine/engine
    platform: linux/amd64
    environment:
      - DATABASE=postgres
      - DATABASE_URL=jdbc:postgresql://db:5432/mirthdb
      - DATABASE_MAX_CONNECTIONS=20
      - DATABASE_USERNAME=mirthdb
      - DATABASE_PASSWORD=mirthdb
      - DATABASE_MAX_RETRY=2
      - DATABASE_RETRY_WAIT=10000
      - KEYSTORE_STOREPASS=docker_storepass
      - KEYSTORE_KEYPASS=docker_keypass
      - VMOPTIONS=-Xmx512m
    ports:
      - 8080:8080/tcp
      - 8443:8443/tcp
    depends_on:
      - db
  db:
    image: postgres
    environment:
      - POSTGRES_USER=mirthdb
      - POSTGRES_PASSWORD=mirthdb
      - POSTGRES_DB=mirthdb
    expose:
      - 5432
```

------------

<a name="environment-variables"></a>
## Environment Variables [↑](#top)

You can use environment variables to configure the [mirth.properties](https://github.com/openintegrationengine/engine/blob/development/server/conf/mirth.properties) file or to add custom JVM options.

### Setting Environment Variables

To set environment variables, use the `-e` option for each variable on the command line:

```bash
docker run -e DATABASE='derby' -p 8443:8443 openintegrationengine/engine:latest-ubuntu-jre
```

You can also use a separate file containing all of your environment variables using the `--env-file` option. For example let's say you create a file **myenvfile.txt**:

```bash
DATABASE=postgres
DATABASE_URL=jdbc:postgresql://serverip:5432/mirthdb
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=postgres
DATABASE_MAX_RETRY=2
DATABASE_RETRY_WAIT=10000
KEYSTORE_STOREPASS=changeme
KEYSTORE_KEYPASS=changeme
VMOPTIONS=-Xmx512m
```

```bash
docker run --env-file=myenvfile.txt -p 8443:8443 openintegrationengine/engine:latest-ubuntu-jre
```

------------

<a name="common-mirth-properties-options"></a>
### Common mirth.properties options [↑](#top)

<a name="env-database"></a>
#### `DATABASE`

The database type to use for the Open Integration Engine backend database. Options:

* derby
* mysql
* postgres
* oracle
* sqlserver

<a name="env-database-url"></a>
#### `DATABASE_URL`

The JDBC URL to use when connecting to the database. For example:
* `jdbc:postgresql://serverip:5432/mirthdb`

<a name="env-database-username"></a>
#### `DATABASE_USERNAME`

The username to use when connecting to the database. If you don't want to use an environment variable to store sensitive information like this, look at the [Using Docker Secrets](#using-docker-secrets) section below.

<a name="env-database-password"></a>
#### `DATABASE_PASSWORD`

The password to use when connecting to the database. If you don't want to use an environment variable to store sensitive information like this, look at the [Using Docker Secrets](#using-docker-secrets) section below.

<a name="env-database-max-connections"></a>
#### `DATABASE_MAX_CONNECTIONS`

The maximum number of connections to use for the internal messaging engine connection pool.

<a name="env-database-max-retry"></a>
#### `DATABASE_MAX_RETRY`

On startup, if a database connection cannot be made for any reason, Connect will wait and attempt again this number of times. By default, will retry 2 times (so 3 total attempts).

<a name="env-database-retry-wait"></a>
#### `DATABASE_RETRY_WAIT`

The amount of time (in milliseconds) to wait between database connection attempts. By default, will wait 10 seconds between attempts.

<a name="env-keystore-storepass"></a>
#### `KEYSTORE_STOREPASS`

The password for the keystore file itself. If you don't want to use an environment variable to store sensitive information like this, look at the [Using Docker Secrets](#using-docker-secrets) section below.

<a name="env-keystore-keypass"></a>
#### `KEYSTORE_KEYPASS`

The password for the keys within the keystore, including the server certificate and the secret encryption key. If you don't want to use an environment variable to store sensitive information like this, look at the [Using Docker Secrets](#using-docker-secrets) section below.

<a name="env-keystore-type"></a>
#### `KEYSTORE_TYPE`

The type of keystore.

<a name="env-session-store"></a>
#### `SESSION_STORE`

If set to true, the web server sessions are stored in the database. This can be useful in situations where you have multiple Connect servers (connecting to the same database) clustered behind a load balancer.

<a name="env-vmoptions"></a>
#### `VMOPTIONS`

A comma-separated list of JVM command-line options to place in the `.vmoptions` file. For example to set the max heap size:

* -Xmx512m

<a name="env-delay"></a>
#### `DELAY`

This tells the entrypoint script to wait for a certain amount of time (in seconds). The entrypoint script will automatically use a command-line SQL client to check connectivity and wait until the database is up before starting Connect, but only when using PostgreSQL or MySQL. If you are using Oracle or SQL Server and the database is being started up at the same time as Connect, you may want to use this option to tell Connect to wait a bit to allow the database time to startup.

<a name="env-keystore-download"></a>
#### `KEYSTORE_DOWNLOAD`

A URL location of a Connect keystore file. This file will be downloaded into the container and Connect will use it as its keystore.

<a name ="env-extensions-download"></a>
#### `EXTENSIONS_DOWNLOAD`

A URL location of a zip file containing Connect extension zip files. The extensions will be installed on the Connect server.

<a name ="env-custom-jars-download"></a>
#### `CUSTOM_JARS_DOWNLOAD`

A URL location of a zip file containing JAR files. The JAR files will be installed into the `server-launcher-lib` folder on the Connect server, so they will be added to the server's classpath.

<a name="env-allow-insecure"></a>
#### `ALLOW_INSECURE`

Allow insecure SSL connections when downloading files during startup. This applies to keystore downloads, plugin downloads, and server library downloads. By default, insecure connections are disabled but you can enable this option by setting `ALLOW_INSECURE=true`.

<a name="env-server-id"></a>
#### `SERVER_ID`

Set the `server.id` to a specific value. Use this to preserve or set the server ID across restarts and deployments. Using the env-var is preferred over storing `appdata` persistently

------------

<a name="other-mirth-properties-options"></a>
### Other mirth.properties options [↑](#top)

Other options in the mirth.properties file can also be changed. Any environment variable starting with the `_MP_` prefix will set the corresponding value in mirth.properties. Replace `.` with a single underscore `_` and `-` with two underscores `__`.

Examples:

* Set the server TLS protocols to only allow TLSv1.2 and 1.3:
    * In the mirth.properties file:
        * `https.server.protocols = TLSv1.3,TLSv1.2`
    * As a Docker environment variable:
        * `_MP_HTTPS_SERVER_PROTOCOLS='TLSv1.3,TLSv1.2'`

* Set the max connections for the read-only database connection pool:
    * In the mirth.properties file:
        * `database-readonly.max-connections = 20`
    * As a Docker environment variable:
        * `_MP_DATABASE__READONLY_MAX__CONNECTIONS='20'`

------------

<a name="using-docker-secrets"></a>
## Using Docker Secrets [↑](#top)

For sensitive information such as the database/keystore credentials, instead of supplying them as environment variables you can use a [Docker Secret](https://docs.docker.com/engine/swarm/secrets/). There are two secret names this image supports:

##### mirth_properties

If present, any properties in this secret will be merged into the mirth.properties file.

##### mcserver_vmoptions

If present, any JVM options in this secret will be appended onto the mcserver.vmoptions file.

------------

Secrets are supported with [Docker Swarm](https://docs.docker.com/engine/swarm/secrets/), but you can also use them with [`docker-compose`](#using-docker-compose).

For example let's say you wanted to set `keystore.storepass` and `keystore.keypass` in a secure way. You could create a new file, **secret.properties**:

```bash
keystore.storepass=changeme
keystore.keypass=changeme
```

Then in your YAML docker-compose stack file:

```yaml
version: '3.1'
services:
  mc:
    image: openintegrationengine/engine
    environment:
      - VMOPTIONS=-Xmx512m
    secrets:
      - mirth_properties
    ports:
      - 8080:8080/tcp
      - 8443:8443/tcp
secrets:
  mirth_properties:
    file: /local/path/to/secret.properties
```

The **secrets** section at the bottom specifies the local file location for each secret.  Change `/local/path/to/secret.properties` to the correct local path and filename.

Inside the configuration for the Connect container there is also a **secrets** section that lists the secrets you want to include for that container.

------------

<a name="using-volumes"></a>
## Using Volumes [↑](#top)

<a name="the-appdata-folder"></a>
#### The appdata folder [↑](#top)

The application data directory (appdata) stores configuration files and temporary data created by Connect after starting up. This usually includes the keystore file and the `server.id` file that stores your server ID. If you are launching Connect as part of a stack/swarm, it's possible the container filesystem is already being preserved. But if not, you may want to consider mounting a **volume** to preserve the appdata folder.

```bash
docker run -v /local/path/to/appdata:/opt/connect/appdata -p 8443:8443 openintegrationengine/engine:latest-ubuntu-jre
```

The `-v` option makes a local directory from your filesystem available to the Docker container. Create a folder on your local filesystem, then change the `/local/path/to/appdata` part in the example above to the correct local path.

You can also configure volumes as part of your docker-compose YAML stack file:

```yaml
version: '3.1'
services:
  mc:
    image: openintegrationengine/engine
    volumes:
      - ~/Documents/appdata:/opt/connect/appdata
```

------------

<a name="additional-extensions"></a>
#### Additional extensions [↑](#top)

The entrypoint script will automatically look for any ZIP files in the `/opt/connect/custom-extensions` folder and unzip them into the extensions folder before Connect starts up. So to launch Connect with any additional extensions not included in the base application, do this:

```bash
docker run -v /local/path/to/custom-extensions:/opt/connect/custom-extensions -p 8443:8443 openintegrationengine/engine:latest-ubuntu-jre
```

Create a folder on your local filesystem containing the ZIP files for your additional extensions. Then change the `/local/path/to/custom-extensions` part in the example above to the correct local path.

As with the appdata example, you can also configure this volume as part of your docker-compose YAML file.

------------

## Known Limitations

Currently, only the Debian flavored images support the newest authentication scheme in MySQL 8. All others (the Alpine based images) will need the following to force the MySQL database container to start using the old authentication scheme:

```yaml
command: --default-authentication-plugin=mysql_native_password
```

Example:

```yaml
  db:
    image: mysql
    command: --default-authentication-plugin=mysql_native_password
    environment:
      ...
```

------------

## Building images

To build the full set of four images (`ubuntu-jre`, `ubuntu-jdk`, `alpine-jre`, and `alpine-jdk`) run the following command in the `deploy/` directory:
```sh
docker compose build --build-arg CREATED_AT=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
```

------------

<a name="license"></a>
# License [↑](#top)

The Dockerfiles, entrypoint script, and any other files used to build these Docker images are Copyright © NextGen Healthcare and OpenIntegrationEngine contributors. They are licensed under the [Mozilla Public License 2.0](https://www.mozilla.org/en-US/MPL/2.0/).
