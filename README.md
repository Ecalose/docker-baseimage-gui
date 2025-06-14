# A minimal docker baseimage to ease creation of X graphical application containers
[![Release](https://img.shields.io/github/release/jlesage/docker-baseimage-gui.svg?logo=github&style=for-the-badge)](https://github.com/jlesage/docker-baseimage-gui/releases/latest)
[![Build Status](https://img.shields.io/github/actions/workflow/status/jlesage/docker-baseimage-gui/build-baseimage.yml?logo=github&branch=master&style=for-the-badge)](https://github.com/jlesage/docker-baseimage-gui/actions/workflows/build-baseimage.yml)
[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg?style=for-the-badge)](https://paypal.me/JocelynLeSage)

This is a docker baseimage that can be used to create containers able to run
any X application on a headless server very easily. The application's GUI
is accessed through a modern web browser (no installation or configuration
needed on the client side) or via any VNC client.

## Table of Content

   * [Images](#images)
      * [Versioning](#versioning)
      * [Content](#content)
   * [Getting started](#getting-started)
   * [Using the Baseimage](#using-the-baseimage)
      * [Selecting a Baseimage](#selecting-a-baseimage)
      * [Container Startup Sequence](#container-startup-sequence)
      * [Container Shutdown Sequence](#container-shutdown-sequence)
      * [Environment Variables](#environment-variables)
         * [Public Environment Variables](#public-environment-variables)
         * [Internal Environment Variables](#internal-environment-variables)
         * [Adding/Removing Internal Environment Variables](#addingremoving-internal-environment-variables)
         * [Availability](#availability)
         * [Docker Secrets](#docker-secrets)
      * [Ports](#ports)
      * [User/Group IDs](#usergroup-ids)
      * [Locales](#locales)
      * [Accessing the GUI](#accessing-the-gui)
      * [Security](#security)
         * [SSVNC](#ssvnc)
         * [Certificates](#certificates)
         * [VNC Password](#vnc-password)
         * [DH Parameters](#dh-parameters)
         * [Web Authentication](#web-authentication)
            * [Configuring Users Credentials](#configuring-users-credentials)
      * [Initialization Scripts](#initialization-scripts)
      * [Finalization Scripts](#finalization-scripts)
      * [Services](#services)
         * [Service Group](#service-group)
         * [Default Service](#default-service)
         * [Service Readiness](#service-readiness)
      * [Configuration Directory](#configuration-directory)
         * [Application's Data Directories](#applications-data-directories)
      * [Container Log](#container-log)
      * [Logrotate](#logrotate)
      * [Log Monitor](#log-monitor)
         * [Notification Definition](#notification-definition)
         * [Notification Backend](#notification-backend)
      * [Web Audio](#web-audio)
      * [Helpers](#helpers)
         * [Adding/Removing Packages](#addingremoving-packages)
         * [Modifying Files With Sed](#modifying-files-with-sed)
         * [Evaluating Boolean Value](#evaluating-boolean-value)
         * [Taking Ownership of a Directory](#taking-ownership-of-a-directory)
         * [Setting Interval Environment Variable](#setting-interval-environment-variable)
      * [Application Icon](#application-icon)
      * [Dark Mode](#dark-mode)
         * [GTK](#gtk)
         * [QT](#qt)
      * [Tips and Best Practices](#tips-and-best-practices)
         * [Do Not Modify Baseimage Content](#do-not-modify-baseimage-content)
         * [Default Configuration Files](#default-configuration-files)
         * [The $HOME Variable](#the-home-variable)
         * [Referencing Linux User/Group](#referencing-linux-usergroup)
         * [Using rootfs Directory](#using-rootfs-directory)
         * [Maximizing Only the Main Window](#maximizing-only-the-main-window)
         * [Adaptations from the 3.x Version](#adaptations-from-the-3x-version)

## Images

Multiple docker images, based on different Linux distributions, are available:

| Linux Distribution | Docker Image Tag      | Size |
|--------------------|-----------------------|------|
| [Alpine 3.16]      | alpine-3.16-vX.Y.Z    | [![](https://img.shields.io/docker/image-size/jlesage/baseimage-gui/alpine-3.16-v4?style=for-the-badge)](#)  |
| [Alpine 3.17]      | alpine-3.17-vX.Y.Z    | [![](https://img.shields.io/docker/image-size/jlesage/baseimage-gui/alpine-3.17-v4?style=for-the-badge)](#)  |
| [Alpine 3.18]      | alpine-3.18-vX.Y.Z    | [![](https://img.shields.io/docker/image-size/jlesage/baseimage-gui/alpine-3.18-v4?style=for-the-badge)](#)  |
| [Alpine 3.19]      | alpine-3.19-vX.Y.Z    | [![](https://img.shields.io/docker/image-size/jlesage/baseimage-gui/alpine-3.19-v4?style=for-the-badge)](#)  |
| [Alpine 3.20]      | alpine-3.20-vX.Y.Z    | [![](https://img.shields.io/docker/image-size/jlesage/baseimage-gui/alpine-3.20-v4?style=for-the-badge)](#)  |
| [Alpine 3.21]      | alpine-3.21-vX.Y.Z    | [![](https://img.shields.io/docker/image-size/jlesage/baseimage-gui/alpine-3.21-v4?style=for-the-badge)](#)  |
| [Alpine 3.22]      | alpine-3.22-vX.Y.Z    | [![](https://img.shields.io/docker/image-size/jlesage/baseimage-gui/alpine-3.22-v4?style=for-the-badge)](#)  |
| [Debian 10]        | debian-10-vX.Y.Z      | [![](https://img.shields.io/docker/image-size/jlesage/baseimage-gui/debian-10-v4?style=for-the-badge)](#)    |
| [Debian 11]        | debian-11-vX.Y.Z      | [![](https://img.shields.io/docker/image-size/jlesage/baseimage-gui/debian-11-v4?style=for-the-badge)](#)    |
| [Debian 12]        | debian-12-vX.Y.Z      | [![](https://img.shields.io/docker/image-size/jlesage/baseimage-gui/debian-12-v4?style=for-the-badge)](#)    |
| [Ubuntu 16.04 LTS] | ubuntu-16.04-vX.Y.Z   | [![](https://img.shields.io/docker/image-size/jlesage/baseimage-gui/ubuntu-16.04-v4?style=for-the-badge)](#) |
| [Ubuntu 18.04 LTS] | ubuntu-18.04-vX.Y.Z   | [![](https://img.shields.io/docker/image-size/jlesage/baseimage-gui/ubuntu-18.04-v4?style=for-the-badge)](#) |
| [Ubuntu 20.04 LTS] | ubuntu-20.04-vX.Y.Z   | [![](https://img.shields.io/docker/image-size/jlesage/baseimage-gui/ubuntu-20.04-v4?style=for-the-badge)](#) |
| [Ubuntu 22.04 LTS] | ubuntu-22.04-vX.Y.Z   | [![](https://img.shields.io/docker/image-size/jlesage/baseimage-gui/ubuntu-22.04-v4?style=for-the-badge)](#) |
| [Ubuntu 24.04 LTS] | ubuntu-24.04-vX.Y.Z   | [![](https://img.shields.io/docker/image-size/jlesage/baseimage-gui/ubuntu-24.04-v4?style=for-the-badge)](#) |

Each Docker image is tagged with the Linux distribution and the release version.
All release versions can be found under the [Releases] page.

Version part of the tag can be decomposed in the following way:

| Tag           | Description                                              |
|---------------|----------------------------------------------------------|
| distro-vX.Y.Z | Exact version of the image.                              |
| distro-vX.Y   | Latest version of a specific minor version of the image. |
| distro-vX     | Latest version of a specific major version of the image. |

Finally, all available Docker image tags can also be consulted on [Docker Hub].

[Alpine 3.16]: https://alpinelinux.org/posts/Alpine-3.16.0-released.html
[Alpine 3.17]: https://alpinelinux.org/posts/Alpine-3.17.0-released.html
[Alpine 3.18]: https://alpinelinux.org/posts/Alpine-3.18.0-released.html
[Alpine 3.19]: https://alpinelinux.org/posts/Alpine-3.19.0-released.html
[Alpine 3.20]: https://alpinelinux.org/posts/Alpine-3.20.0-released.html
[Alpine 3.21]: https://alpinelinux.org/posts/Alpine-3.21.0-released.html
[Alpine 3.22]: https://alpinelinux.org/posts/Alpine-3.22.0-released.html
[Debian 10]: https://www.debian.org/releases/buster/
[Debian 11]: https://www.debian.org/releases/bullseye/
[Debian 12]: https://www.debian.org/releases/bookworm/
[Ubuntu 16.04 LTS]: http://releases.ubuntu.com/16.04/
[Ubuntu 18.04 LTS]: http://releases.ubuntu.com/18.04/
[Ubuntu 20.04 LTS]: http://releases.ubuntu.com/20.04/
[Ubuntu 22.04 LTS]: http://releases.ubuntu.com/22.04/
[Ubuntu 24.04 LTS]: http://releases.ubuntu.com/24.04/
[Releases]: https://github.com/jlesage/docker-baseimage-gui/releases
[Docker Hub]: https://hub.docker.com/r/jlesage/baseimage-gui/tags

### Versioning

Images are versioned. Version number follows the [semantic versioning]. The
version format is `MAJOR.MINOR.PATCH`, where an increment of the:

  - `MAJOR` version indicates that a backwards-incompatible change has been done.
  - `MINOR` version indicates that functionality has been added in a backwards-compatible manner.
  - `PATCH` version indicates that a bug fix has been done in a backwards-compatible manner.

[semantic versioning]: https://semver.org

### Content

Here are the main components of the baseimage:

  * An init system.
  * A process supervisor, with proper PID 1 functionality (proper reaping of
    processes).
  * [TigerVNC], a X server with an integrated VNC server.
  * [Openbox], a window manager.
  * [noVNC], a HTML5 VNC client.
  * [NGINX], a high-performance HTTP server.
  * Useful tools to ease container building.
  * Environment to better support dockerized applications.

[TigerVNC]: https://tigervnc.org
[Openbox]: http://openbox.org
[noVNC]: https://github.com/novnc/noVNC
[NGINX]: https://www.nginx.com

## Getting started

The `Dockerfile` for your application can be very simple, as only three things
are required:

  * Instructions to install the application.
  * A script that starts the application (stored at `/startapp.sh` in
    container).
  * The name of the application.

Here is an example of a docker file that would be used to run the `xterm`
terminal.

In `Dockerfile`:
```Dockerfile
# Pull base image.
FROM jlesage/baseimage-gui:alpine-3.19-v4

# Install xterm.
RUN add-pkg xterm

# Copy the start script.
COPY startapp.sh /startapp.sh

# Set the name of the application.
RUN set-cont-env APP_NAME "Xterm"

```

In `startapp.sh`:
```shell
#!/bin/sh
exec /usr/bin/xterm
```

Make sure the file is executable, by running `chmod +x startapp.sh`.

Then, build your docker image:

    docker build -t docker-xterm .

And run it:

    docker run --rm -p 5800:5800 -p 5900:5900 docker-xterm

You should be able to access the xterm GUI by opening in a web browser:

```
http://[HOST IP ADDR]:5800
```

## Using the Baseimage

### Selecting a Baseimage

Using a baseimage based on Alpine Linux is the recommended choice. Not only
because of its small size, but also because Alpine Linux is a distribution based
on [musl] and [BusyBox] that is designed for security, simplicity and resource
efficiency.

However, using this baseimage to integrate an application not part of the
Alpine's software repository or without its source code available may be harder.
This is because Alpine Linux uses [musl] C standard library instead of GNU C
library ([glibc]) that most applications are built against. Compatibility
between these two libraries is very limited.

Else, `Debian` and `Ubuntu` images are well known Linux distributions that
provide great compatibility with existing applications.

[musl]: https://www.musl-libc.org
[BusyBox]: https://busybox.net
[glibc]: https://www.gnu.org/software/libc/

### Container Startup Sequence

When the container is starting, the following steps are performed:

  - The init process (`/init`) is invoked.
  - Internal environment variables are loaded from `/etc/cont-env.d`.
  - Initialization scripts under `/etc/cont-init.d` are executed in alphabetical
    order.
  - Control is given to the process supervisor.
  - The service group `/etc/services.d/default` is loaded, along with its
    dependencies.
  - Services are started, in proper order.
  - Container is now fully started.

### Container Shutdown Sequence

There are two ways a container can shutdown:

  1. When the implemented application terminates.
  2. When Docker performs a shutdown of the container (e.g via the `docker stop`
     command).

In both cases, the shutdown sequence is:

  - All services are terminated, in reverse order.
  - If some processes are still alive, a SIGTERM is sent to everyone.
  - After 5 seconds, all remaining processes are forcefully terminated via the
    SIGKILL signal.
  - The process supervisor execute the exit script (`/etc/services.d/exit`).
  - The exit script executes, in alphabetical order, finalization scripts
    defined under `/etc/cont-finish.d/`.
  - Container is full stopped.

### Environment Variables

Environment variables are very useful to customize the behavior of the container
and its application.

There are two types of environment variables:

  - **Public**: These variables are targeted to people using the container.
    They provide a way to configure it. They are declared in the `Dockerfile`,
    via the `ENV` instruction. Their value can be set by users during the
    creation of the container, via the `-e "<VAR>=<VALUE>"` argument of the
    `docker run` command. Also, many Docker container management systems use
    these variables to automatically provide configuration parameters to the
    user.

  - **Internal**: These variables are the ones that don't need to be exposed to
    users. They are useful for the application itself, but are not intended to
    be changed by users.

**NOTE**: If a variable is defined as both an internal and public one, the value
of the public variable takes precedence.

#### Public Environment Variables

The following public environment variables are provided by the baseimage:

| Variable       | Description                                  | Default |
|----------------|----------------------------------------------|---------|
|`USER_ID`| ID of the user the application runs as. See [User/Group IDs](#usergroup-ids) to better understand when this should be set. | `1000` |
|`GROUP_ID`| ID of the group the application runs as. See [User/Group IDs](#usergroup-ids) to better understand when this should be set. | `1000` |
|`SUP_GROUP_IDS`| Comma-separated list of supplementary group IDs of the application. | (no value) |
|`UMASK`| Mask that controls how permissions are set for newly created files and folders. The value of the mask is in octal notation. By default, the default umask value is `0022`, meaning that newly created files and folders are readable by everyone, but only writable by the owner. See the online umask calculator at http://wintelguy.com/umask-calc.pl. | `0022` |
|`LANG`| Set the [locale](https://en.wikipedia.org/wiki/Locale_(computer_software)), which defines the application's language, **if supported**. Format of the locale is `language[_territory][.codeset]`, where language is an [ISO 639 language code](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes), territory is an [ISO 3166 country code](https://en.wikipedia.org/wiki/ISO_3166-1#Current_codes) and codeset is a character set, like `UTF-8`. For example, Australian English using the UTF-8 encoding is `en_AU.UTF-8`. | `en_US.UTF-8` |
|`TZ`| [TimeZone](http://en.wikipedia.org/wiki/List_of_tz_database_time_zones) used by the container. Timezone can also be set by mapping `/etc/localtime` between the host and the container. | `Etc/UTC` |
|`KEEP_APP_RUNNING`| When set to `1`, the application will be automatically restarted when it crashes or terminates. | `0` |
|`APP_NICENESS`| Priority at which the application should run. A niceness value of -20 is the highest priority and 19 is the lowest priority. The default niceness value is 0. **NOTE**: A negative niceness (priority increase) requires additional permissions. In this case, the container should be run with the docker option `--cap-add=SYS_NICE`. | `0` |
|`INSTALL_PACKAGES`| Space-separated list of packages to install during the startup of the container. Packages are installed from the repository of the Linux distribution this container is based on. **ATTENTION**: Container functionality can be affected when installing a package that overrides existing container files (e.g. binaries). | (no value) |
|`PACKAGES_MIRROR`| Mirror of the repository to use when installing packages. | (no value) |
|`CONTAINER_DEBUG`| Set to `1` to enable debug logging. | `0` |
|`DISPLAY_WIDTH`| Width (in pixels) of the application's window. | `1920` |
|`DISPLAY_HEIGHT`| Height (in pixels) of the application's window. | `1080` |
|`DARK_MODE`| When set to `1`, dark mode is enabled for the application. | `0` |
|`WEB_AUDIO`| When set to `1`, audio support is enabled, meaning that any audio produced by the application is played through the browser. Note that audio is not supported for VNC clients. | `0` |
|`WEB_AUTHENTICATION`| When set to `1`, the application's GUI is protected via a login page when accessed via a web browser. Access is allowed only when providing valid credentials. **NOTE**: This feature requires secure connection (`SECURE_CONNECTION` environment variable) to be enabled. | `0` |
|`WEB_AUTHENTICATION_TOKEN_VALIDITY_TIME`| The lifetime of a token, in hours. A token is attributed to the user after a successful login. As long as the token is valid, user can access the application's GUI without having to log in again. Once the token expires, the login page is prompted again. | `24` |
|`WEB_AUTHENTICATION_USERNAME`| Optional username to configure for the web authentication. This is a quick and easy way to configure credentials for a single user. To configure credentials in a more secure way, or to add more users, see the [Web Authentication](#web-authentication) section. | (no value) |
|`WEB_AUTHENTICATION_PASSWORD`| Optional password to configure for the web authentication. This is a quick and easy way to configure credentials for a single user. To configure credentials in a more secure way, or to add more users, see the [Web Authentication](#web-authentication) section. | (no value) |
|`SECURE_CONNECTION`| When set to `1`, an encrypted connection is used to access the application's GUI (either via a web browser or VNC client). See the [Security](#security) section for more details. | `0` |
|`SECURE_CONNECTION_VNC_METHOD`| Method used to perform the secure VNC connection. Possible values are `SSL` or `TLS`. See the [Security](#security) section for more details. | `SSL` |
|`SECURE_CONNECTION_CERTS_CHECK_INTERVAL`| Interval, in seconds, at which the system verifies if web or VNC certificates have changed. When a change is detected, the affected services are automatically restarted. A value of `0` disables the check. | `60` |
|`WEB_LISTENING_PORT`| Port used by the web server to serve the UI of the application. This port is used internally by the container and it is usually not required to be changed. By default, a container is created with the default bridge network, meaning that, to be accessible, each internal container port must be mapped to an external port (using the `-p` or `--publish` argument). However, if the container is created with another network type, changing the port used by the container might be useful to prevent conflict with other services/containers. **NOTE**: a value of `-1` disables listening, meaning that the application's UI won't be accessible over HTTP/HTTPs. | `5800` |
|`VNC_LISTENING_PORT`| Port used by the VNC server to serve the UI of the application. This port is used internally by the container and it is usually not required to be changed. By default, a container is created with the default bridge network, meaning that, to be accessible, each internal container port must be mapped to an external port (using the `-p` or `--publish` argument). However, if the container is created with another network type, changing the port used by the container might be useful to prevent conflict with other services/containers. **NOTE**: a value of `-1` disables listening, meaning that the application's UI won't be accessible over VNC. | `5900` |
|`VNC_PASSWORD`| Password needed to connect to the application's GUI. See the [VNC Password](#vnc-password) section for more details. | (no value) |
|`ENABLE_CJK_FONT`| When set to `1`, open-source computer font `WenQuanYi Zen Hei` is installed. This font contains a large range of Chinese/Japanese/Korean characters. | `0` |

#### Internal Environment Variables

The following internal environment variables are provided by the baseimage:

| Variable       | Description                                  | Default |
|----------------|----------------------------------------------|---------|
|`APP_NAME`| Name of the implemented application. | `DockerApp` |
|`APP_VERSION`| Version of the implemented application. | (no value) |
|`DOCKER_IMAGE_VERSION`| Version of the Docker image that implements the application. | (no value) |
|`DOCKER_IMAGE_PLATFORM`| Platform (OS / CPU architecture) of the Docker image that implements the application. | (no value) |
|`HOME`| Home directory. | (no value) |
|`XDG_CONFIG_HOME`| Defines the base directory relative to which user specific configuration files should be stored. | `/config/xdg/config` |
|`XDG_DATA_HOME`| Defines the base directory relative to which user specific data files should be stored. | `/config/xdg/data` |
|`XDG_CACHE_HOME`| Defines the base directory relative to which user specific non-essential data files should be stored. | `/config/xdg/cache` |
|`TAKE_CONFIG_OWNERSHIP`| When set to `0`, ownership of the content of the `/config` directory is not taken during startup of the container. | `1` |
|`INSTALL_PACKAGES_INTERNAL`| Space-separated list of packages to install during the startup of the container. Packages are installed from the repository of the Linux distribution this container is based on. | (no value) |
|`SUP_GROUP_IDS_INTERNAL`| Comma-separated list of supplementary group IDs of the application. These are merged with the ones that might be supplied by `SUP_GROUP_IDS`. | (no value) |
|`SERVICES_GRACETIME`| During container shutdown, this defines the amount of time (in milliseconds) allowed to services to gracefully terminate before sending the KILL signal to everyone. | `5000` |

#### Adding/Removing Internal Environment Variables

Internal environment variables are defined by adding a file to
`/etc/cont-env.d/` inside the container, where the name of the file is the name
of the variable and its value is defined by the content of the file.

If the file has execute permission, the init process will execute the program
and the value of the environment variable is expected to be printed to its
standard output.

**NOTE**: If the program exits with the return code `100`, the environment
          variable is not set (this is different than being set with an empty
          value).

**NOTE**: Any output to stderr performed by the program is redirected to the
          container's log.

**NOTE**: The helper `set-cont-env` can be used to set internal environment
          variables from the Dockerfile.

#### Availability

Since public environment variables are defined during the creation of the
container, they are always available to all your scripts and services, as soon
as the container starts.

For internal environment variables, they first need to be loaded during the
startup of the container before they can be used. Since this is done before
running init scripts and services, availability should not be an issue.

#### Docker Secrets

[Docker secrets](https://docs.docker.com/engine/swarm/secrets/) is a
functionality available to swarm services that offers a secure way to store
sensitive information such as username, passwords, etc.

This baseimage automatically exports, as environment variables, Docker secrets
that follow this naming convention:

```
CONT_ENV_<environment variable name>
```

For example, for a secret named `CONT_ENV_MY_PASSWORD`, the environment variable
`MY_PASSWORD` is created, with its content matching the one of the secret.

### Ports

Here is the list of ports used by the baseimage. With a container using the
default bridge network, these ports can be mapped to the host via the
`-p <HOST_PORT>:<CONTAINER_PORT>` parameter.

| Port | Mapping to host | Description |
|------|-----------------|-------------|
| 5800 | Optional        | Port to access the application's GUI via the web interface. Mapping to the host is optional if access through the web interface is not wanted. For a container not using the default bridge network, the port can be changed with the `WEB_LISTENING_PORT` environment variable. |
| 5900 | Optional        | Port to access the application's GUI via the VNC protocol. Mapping to the host is optional if access through the VNC protocol is not wanted. For a container not using the default bridge network, the port can be changed with the `VNC_LISTENING_PORT` environment variable. |

### User/Group IDs

When mapping data volumes (via the `-v` flag of the `docker run` command),
permissions issues can occur between the host and the container. Files and
folders of a data volume are owned by a user, which is probably not the same as
the default user under which the implemented application is running. Depending
on permissions, this situation could prevent the container from accessing files
and folders on the shared volume.

To avoid this problem, you can specify the user the application should run as.

This is done by passing the user ID and group ID to the container via the
`USER_ID` and `GROUP_ID` environment variables.

To find the right IDs to use, issue the following command on the host, with the
user owning the data volume on the host:

    id <username>

Which gives an output like this one:
```
uid=1000(myuser) gid=1000(myuser) groups=1000(myuser),4(adm),24(cdrom),27(sudo),46(plugdev),113(lpadmin)
```

The value of `uid` (user ID) and `gid` (group ID) are the ones that you should
be given the container.

### Locales

The default locale of the container is set to `POSIX`. If this cause issues
with your application, the proper locale can be installed. For example, adding
the following instructions to your `Dockerfile` set the locale to `en_US.UTF-8`.
```Dockerfile
RUN \
    add-pkg locales && \
    sed-patch 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
ENV LANG=en_US.UTF-8
```

**NOTE**: Locales are not supported by `musl` C standard library on `Alpine`.
See:
  * http://wiki.musl-libc.org/wiki/Open_Issues#C_locale_conformance
  * https://github.com/gliderlabs/docker-alpine/issues/144

### Accessing the GUI

Assuming that container's ports are mapped to the same host's ports, the
graphical interface of the application can be accessed via:

  * A web browser:
```
http://<HOST IP ADDR>:5800
```

  * Any VNC client:
```
<HOST IP ADDR>:5900
```

### Security

By default, access to the application's GUI is done over an unencrypted
connection (HTTP or VNC).

Secure connection can be enabled via the `SECURE_CONNECTION` environment
variable. See the [Environment Variables](#environment-variables) section for
more details on how to set an environment variable.

When enabled, application's GUI is performed over an HTTPs connection when
accessed with a browser. All HTTP accesses are automatically redirected to
HTTPs.

When using a VNC client, the VNC connection is performed over SSL. Note that
few VNC clients support this method. [SSVNC] is one of them.

#### SSVNC

[SSVNC] is a VNC viewer that adds encryption security to VNC connections.

While the Linux version of [SSVNC] works well, the Windows version has some
issues. At the time of writing, the latest version `1.0.30` is not functional,
as a connection fails with the following error:

```
ReadExact: Socket error while reading
```

However, for your convienence, an unoffical and working version is provided
here:

https://github.com/jlesage/docker-baseimage-gui/raw/master/tools/ssvnc_windows_only-1.0.30-r1.zip

The only difference with the offical package is that the bundled version of
`stunnel` has been upgraded to version `5.49`, which fixes the connection
problems.

[SSVNC]: http://www.karlrunge.com/x11vnc/ssvnc.html

#### Certificates
 
Here are the certificate files needed by the container. By default, when they
are missing, self-signed certificates are generated and used. All files are
PEM encoded, x509 certificates.

| Container Path                  | Purpose                    | Content |
|---------------------------------|----------------------------|---------|
|`/config/certs/vnc-server.pem`   |VNC connection encryption.  |VNC server's private key and certificate, bundled with any root and intermediate certificates.|
|`/config/certs/web-privkey.pem`  |HTTPs connection encryption.|Web server's private key.|
|`/config/certs/web-fullchain.pem`|HTTPs connection encryption.|Web server's certificate, bundled with any root and intermediate certificates.|

**NOTE**: To prevent any certificate validity warnings/errors from the browser
or VNC client, make sure to supply your own valid certificates.

**NOTE**: Certificate files are monitored and relevant daemons are automatically
restarted when changes are detected.

#### VNC Password

To restrict access to your application, a password can be specified. This can
be done via two methods:
  * By using the `VNC_PASSWORD` environment variable.
  * By creating a `.vncpass_clear` file at the root of the `/config` volume.
    This file should contains the password in clear-text. During the container
    startup, content of the file is obfuscated and moved to `.vncpass`.

The level of security provided by the VNC password depends on two things:
  * The type of communication channel (encrypted/unencrypted).
  * How secure access to the host is.

When using a VNC password, it is highly desirable to enable the secure
connection to prevent sending the password in clear over an unencrypted channel.

Access to the host by unexpected users with sufficient privileges can be
dangerous as they can retrieve the password with the following methods:
  * By looking at the `VNC_PASSWORD` environment variable value via the
    `docker inspect` command. By defaut, the `docker` command can be run only
    by the root user. However, it is possible to configure the system to allow
    the `docker` command to be run by any users part of a specific group.
  * By decrypting the `/config/.vncpass` file. This requires the user to have
    the appropriate permission to read the file: it has to be root or be the
    user defined by the `USER_ID` environment variable.

#### DH Parameters

Diffie-Hellman (DH) parameters define how the [DH key-exchange] is performed.
More details about this algorithm can be found on the [OpenSSL Wiki].

DH Parameters are saved into the PEM encoded file located inside the container
at `/config/certs/dhparam.pem`. By default, when this file is missing, 2048
bits DH parameters are automatically generated. Note that this one-time
operation takes some time to perform and increases the startup time of the
container.

[DH key-exchange]: https://en.wikipedia.org/wiki/Diffie%E2%80%93Hellman_key_exchange
[OpenSSL Wiki]: https://wiki.openssl.org/index.php/Diffie_Hellman

#### Web Authentication

Access to the application's GUI via a web browser can be protected with a login
page. When web authentication is enabled, users have to provide valid
credentials, otherwise access is denied.

Web authentication can be enabled by setting the `WEB_AUTHENTICATION`
environment variable to `1`.

See the [Environment Variables](#environment-variables) section for more details
on how to set an environment variable.

**NOTE**: Secure connection must be also enabled to use web authentication.
          See the [Security](#security) section for more details.

##### Configuring Users Credentials

Two methods can be used to configure users credentials:

  1. Via container environment variables.
  2. Via password database.

Containers environment variables can be used to quickly and easily configure
a single user. Username and pasword are defined via the following environment
variables:
  - `WEB_AUTHENTICATION_USERNAME`
  - `WEB_AUTHENTICATION_PASSWORD`

See the [Environment Variables](#environment-variables) section for more details
on how to set an environment variable.

The second method is more secure and allows multiple users to be configured.
The usernames and password hashes are saved into a password database, located at
`/config/webauth-htpasswd` inside the container. This database file has the
same format as htpasswd files of the Apache HTTP server. Note that password
themselves are not saved into the database, but only their hash. The bcrypt
password hashing function is used to generate hashes.

Users are managed via the `webauth-user` tool included in the container:
  - To add a user password: `docker exec -ti <container name or id> webauth-user add <username>`.
  - To update a user password: `docker exec -ti <container name or id> webauth-user update <username>`.
  - To remove a user: `docker exec <container name or id> webauth-user del <username>`.
  - To list users: `docker exec <container name or id> webauth-user user`.

### Initialization Scripts

During the container startup, initialization scripts are executed in
alphabetical order. They are executed before starting services.

Initialization scripts are located at `/etc/cont-init.d/` inside the container.

To have a better predictability of the execution order, name of the scripts
follows the `XX-name.sh` format, where `XX` is a sequence number.

The following ranges are used by the baseimage:

  - 10-29
  - 70-89

Unless specific needs are required, containers built against this baseimage
should use the range 50-59.

### Finalization Scripts

Finalization scripts are executed, in alphabetical order, during the shutdown
process of the container. They are executed after all services have been
stopped.

Finalization scripts are located under `/etc/cont-finish.d/` inside the
container.

### Services

Services are programs handled by the process supervisor that run in background.
When a service dies, it can be configured to be automatically restarted.

Services are defined under `/etc/services.d/` in the container. Each service
has its own directory, in which different files are used to store the behavior
of the service.

The content of files provides the value for the associated configuration
setting. If the file has execution permission, it will be executed by the
process supervisor and its output is taked as the value of the configuration
setting.

| File                   | Type             | Description | Default |
|------------------------|------------------|-------------|---------|
| run                    | Program          | The program to run. | N/A |
| is_ready               | Program          | Program invoked by the process supervisor to verify if the service is ready. The program should exit with an exit code of `0` when service is ready. PID of the service if given to the program as parameter. | N/A |
| kill                   | Program          | Program to run when service needs to be killed. The PID of the service if given to the program as parameter. Note that the `TERM` signal is still sent to the service after executing the program. | N/A |
| finish                 | Program          | Program invoked when the service terminates. The service's exit code is given to the program as parameter. | N/A |
| params                 | String           | Parameter for the service's program to run. One parameter per line. | No parameter |
| environment            | String           | Environment to use for the service. One environment variable per line, of the form `key=value`. | Environment untouched |
| environment_extra      | String           | Extra variables to add to the environment of the service. One environment variable per line, of the form `key=value`. | No extra variable |
| respawn                | Boolean          | Whether or not the process must be respawned when it dies. | `FALSE`  |
| sync                   | Boolean          | Whether or not the process supervisor waits until the service ends. This is mutually exclusive with `respawn`. | `FALSE` |
| ready_timeout          | Unsigned integer | Maximum amount of time (in milliseconds) to wait for the service to be ready. | `10000` |
| interval               | Interval         | Interval, in seconds, at which the service should be executed. This is mutually exclusive with `respawn`. | No interval |
| uid                    | Unsigned integer | The user ID under which the service will run. | `$USER_ID` |
| gid                    | Unsigned integer | The group ID under which the service will run. | `$GROUP_ID` |
| sgid                   | Unsigned integer | List of supplementary group IDs of the service. One group ID per line. | Empty list |
| umask                  | Octal integer    | The umask value (in octal notation) of the service. | `0022` |
| priority               | Signed integer   | Priority at which the service should run. A niceness value of -20 is the highest priority and 19 is the lowest priority. | `0` |
| workdir                | String           | The working directory of the service. | Service's directory path  |
| ignore_failure         | Boolean          | When set, the inability to start the service won't prevent the container to start. | `FALSE` |
| shutdown_on_terminate  | Boolean          | Indicates that the container should be shut down when the service terminates. | `FALSE` |
| min_running_time       | Unsigned integer | The minimum amount of time (in milliseconds) the service should be running before considering it as ready. | `500` |
| disabled               | Boolean          | Indicates that the service is disabled, meaning that it won't be loaded nor started. | `FALSE` |
| <service>.dep          | Boolean          | Indicates that the service depends on another one. For example, having `srvB.dep` means that `srvB` should be started before this service. | N/A |

The following table provides more details about some value types:

| Type     | Description |
|----------|-------------|
| Program  | An executable binary, a script or a symbolic link to the program to run. The program file must have the execute permission. |
| Boolean  | A boolean value. A *true* value can be `1`, `true`, `on`, `yes`, `y`, `enable`, `enabled`. A *false* value can be `0`, `false`, `off`, `no`, `n`, `disable`, `disabled`. Values are case insensitive. Also, the presence of an empty file indicates a *true* value (i.e. the file can be "touched"). |
| Interval | An unsigned integer value. The following values are also accepted (case insensitive): `yearly`, `monthly`, `weekly`, `daily`, `hourly`. |

#### Service Group

A service group is a service for which there is no `run` program. The process
supervisor will only load its dependencies.

#### Default Service

During startup, the process supervisor first load the service group `default`.
This service group contains dependencies to services that should be started
and that are not a dependency of the `app` service.

#### Service Readiness

By default, a service is considered ready once it has been successfully launched
and ran for a minimum amount of time (500ms by default).

This behavior can be adjusted with the following methods:
  - By adjusting the minimum amount of time the service should run before 
    considering it as ready. This can be done by adding the
    `min_running_time` file to the service's directory.
  - By informing the process supervisor when the service is ready. This is done
    by adding the `is_ready` program to the service's directory, along with
    `ready_timeout` file to indicate the maximum amount of time to wait for the
    service to be ready.

### Configuration Directory

Applications often need to write configuration, data, states, logs, etc.
Inside the container, this data should be stored under the `/config` directory.

This directory is intended to be mapped to a folder on the host. The goal is to
write stuff outside the container to keep this data persistent.

**NOTE**: During the container startup, ownership of this folder and all its
          content is taken. This is to make sure that `/config` can be accessed
          by the user configured through `USER_ID`/`GROUP_ID`. This behavior
          can be adjusted via the `TAKE_CONFIG_OWNERSHIP` internal environment
          variable.

#### Application's Data Directories

A lot of applications use the environment variables defined by the
[XDG Base Directory Specification] to determine where to store
various data. The baseimage sets these variables so they all fall under
`/config/`:

  * XDG_DATA_HOME=/config/xdg/data
  * XDG_CONFIG_HOME=/config/xdg/config
  * XDG_CACHE_HOME=/config/xdg/cache
  * XDG_STATE_HOME=/config/xdg/state

[XDG Base Directory Specification]: https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html

### Container Log

Everything written to the standard output and standard error output of scripts
executed by the init process and services is saved into the container's log.
The container log can be viewed with the command
`docker logs <name of the container>`.

To ease consultation of the log, all messages are prefixed with the name of the
service or script. Also, it is a good idea to limit the number of information
written to this log. If a program's output is too verbose, it is preferable
to redirect it to a file. For example, the `run` command of a service that
redirects the standard output and standard error output to different files
could be:

```shell
#!/bin/sh
exec /usr/bin/my_service > /config/log/my_service_out.log 2> /config/log/my_service_err.log
```

### Logrotate

The baseimage integrates `logrotate`, an utility used to rotate and compress
log files. This tool runs automatically once a day via a service. The service
is automatically disabled when no log files are configured.

To enable the rotation/compression of a log file, a configuration file needs to
be added to the `/etc/cont-logrotate.d` directory inside the container. This
configuration defines how to handle this specific log file.

Here is a simple example of a configuration defined at
`/etc/cont-logrotate.d/myapp`:

```
/config/log/myapp.log {
    minsize 1M
}
```

This configuration file can override the default parameters, which are defined
at `/opt/base/etc/logrotate.conf` inside the container. In summary, by default:
  - Log files are rotated weekly.
  - Four weeks worth of backlogs are kept.
  - Rotated log files are compressed.
  - Date is used as a suffix of rotated log files.

For more details about the content of `logrotate` configuration files, see the
manual at https://linux.die.net/man/8/logrotate.

### Log Monitor

The baseimage includes a simple log monitor. This monitor allows sending
notification(s) when a particular message is detected in a log or status file.

This system has two main components:
  - **Notification definitions**: Describe properties of a notification (title,
    message, severity, etc),  how it is triggered (filtering function) and the
    associated monitored file(s).
  - **Backends (targets)**:  Once a matching string is found in a file, a
    notification is triggered and sent to one or more backends. A backend can
    implement any functionality. For example, it could send the notification to
    the container's log, a file or an online service.

There are two types of files that can be monitored:
  - **Log files**: A log file is a file having new content appended to it.
  - **Status files*: A status file doesn't have new content appended. Instead,
    its whole content is refreshed/overwritten periodically.

#### Notification Definition

The definition of a notification consists in multiple files, stored in a
directory under `/etc/logmonitor/notifications.d` inside the container. For
example, definition of notification `MYNOTIF` is found under
`/etc/logmonitor/notifications.d/MYNOTIF/`.

The following table describe files part of the definition:

| File     | Mandatory  | Description |
|----------|------------|-------------|
| `filter` | Yes        | Program (script or binary with executable permission) used to filter messages from a log file. It is invoked by the log monitor with a single argument: a line from the log file. On a match, the program should exit with a value of `0`. Any other values is interpreted as non-match. |
| `title`  | Yes        | File containing the title of the notification. To produce dynamic content, the file can be a program (script or binary with executable permission). In this case, the program is invoked by the log monitor with the matched message from the log file as the single argument. Output of the program is used as the notification's title. |
| `desc`   | Yes        | File containing the description/message of the notification. To produce dynamic content, the file can be a program (script or binary with executable permission). In this case, the program is invoked by the log monitor with the matched message from the log file as the single argument. Output of the program is used as the notification's description/message. |
| `level`  | Yes        | File containing severity level of the notification. Valid severity level values are `ERROR`, `WARNING` or `INFO`. To produce dynamic content, the file can be a program (script or binary with executable permission). In this case, the program is invoked by the log monitor with the matched message from the log file as the single argument. Output of the program is used as the notification's severity level. |
| `source` | Yes        | File containing the absolute path(s) to file(s) to monitor (one path per line). Prepend the path with `status:` to indicate that the file is a status file. A path with prefixed with `log:` or without any prefix is considered as a log file. |

#### Notification Backend

Definition of a notification backend is stored in a directory under
`/etc/cont-logmonitor/targets.d`. For example, definition of `STDOUT` backend is
found under `/etc/cont-logmonitor/target.d/STDOUT/`. The following table
describe files part of the definition:

| File         | Mandatory  | Description |
|--------------|------------|-------------|
| `send`       | Yes        | Program (script or binary with executable permission) that sends the notification. It is invoked by the log monitor with the following notification properties as arguments: title, description/message and the severity level. |
| `debouncing` | No         | File containing the minimum amount time (in seconds) that must elapse before sending the same notification with this backend. A value of `0` means infinite (notification is sent once). If this file is missing, no debouncing is done. |

By default, the baseimage contains the following notification backends:

| Backend  | Description | Debouncing time |
|----------|-------------|-----------------|
| `stdout` | Display a message to the standard output, making it visible in the container's log. Message of the format is `{LEVEL}: {TITLE} {MESSAGE}`. | 21 600s (6 hours) |
| `yad`    | Display the notification in a window box, visible in the application's GUI. | Infinite |

### Web Audio

The baseimage supports streaming audio from any application that supports
PulseAudio. The audio plays through the web browser of users. Audio is not
supported when the application is accessed via a VNC client.

Audio is streamed with the following specification:

  * Raw PCM format
  * 2 channels
  * 16 bit sample depth
  * 44.1KHZ sample rate

Web audio support can be enabled by setting the value of the `WEB_AUDIO`
environment variable to `1`. See the
[Environment Variables](#environment-variables) section for more details on how
to set an environment variable.

Once support is enabled, PulseAudio environment is automatically configured
for the application and additional services are started to capture and stream
the audio.

### Helpers

The baseimage contains a few helpers that can be used when bulding a container
or during the execution of a container.

#### Adding/Removing Packages

To add or remove packages, use the helpers `add-pkg` and `del-pkg` provided by
this baseimage. To minimize the size of the container, these tools perform
proper cleanup and make sure that no useless files are left after addition or
removal of packages.

Also, these tools can be used to easily install a group packages temporarily.
Using the `--virtual NAME` parameter, this allows installing packages and remove
them at a later time using the provided `NAME` (no need to repeat given
packages).

Note that if a specified package is already installed, it will be ignored and
will not be removed automatically. For example, the following commands could be
added to `Dockerfile` to compile a project:

```Dockerfile
RUN \
    add-pkg --virtual build-dependencies build-base cmake git && \
    git clone https://myproject.com/myproject.git
    make -C myproject && \
    make -C myproject install && \
    del-pkg build-dependencies
```

Supposing that, in the example above, the `git` package was already installed
when the call to `add-pkg` is performed, running `del-pkg build-dependencies`
doesn't remove it.

#### Modifying Files With Sed

`sed` is a useful tool often used in container builds to modify files. However,
one downside of this method is that there is no easy way to determine if `sed`
actually modified the file or not.

It's for this reason that the baseimage includes a helper that gives `sed` a
"patch-like" behavior:  if applying a sed expression results in no change on the
target file, then an error is reported. This helper is named `sed-patch` and
has the following usage:

```shell
sed-patch [SED_OPT]... SED_EXPRESSION FILE
```

Note that the sed option `-i` (edit files in place) is already supplied by the
helper.

It can be used in `Dockerfile`, for example, like this:

```shell
RUN sed-patch 's/Replace this/By this/' /etc/myfile
```

If running this sed expression doesn't bring any change to `/etc/myfiles`, the
command fails and thus, the Docker build also.

#### Evaluating Boolean Value

Environment variables are often used to store a boolean value. Using the
helpers `is-bool-value-true` and `is-bool-value-false` allows to easily
determine if a value is "true" or "false".

The following values are considered "true":
  - `1`
  - `true`
  - `yes`
  - `enabled`
  - `enable`
  - `on`

The following values are considered "false":
  - `0`
  - `false`
  - `no`
  - `disabled`
  - `disable`
  - `off`

For example, the following shell script snippet checks if the environment
variable `CONTAINER_DEBUG` contains a "true" value:

```shell
if is-bool-value-true "${CONTAINER_DEBUG:-0}"; then
    # Do something...
fi
```

#### Taking Ownership of a Directory

The helper `take-ownership` recursively sets the user ID and group ID of a
directory and all the files and directories under it.

This helper is well suited for scenarios where the directory is mapped to the
host. If on the host this directory is a network share, setting/changing the
ownership via `chown` can fail. The helper handles this case by ignoring the
failure if a write test turns out to be positive.

For example, the following command take ownership of `/config`, by automatically
using the user and group IDs from the `USER_ID` and `GROUP_ID` environment
variables:

```shell
take-ownership /config
```

User and group IDs can also be explicit. For example, to set ownership to user
ID `99` and group ID `100`:

```shell
take-ownership /config 99 100
```

#### Setting Interval Environment Variable

The helper `set-cont-env` can be used to set internal environment variables
from the Dockerfile.

For example, the following line can be added to the Dockerfile to set the value
of the `APP_NAME` internal environment variable:

```Dockerfile
RUN set-cont-env APP_NAME "Xterm"
```

This automatically creates the environment variable file under
`/etc/cont-env.d`.

### Application Icon

A picture of your application can be added to the image. This picture is
displayed in the WEB interface's navigation bar. This is also the master
picture used to generate favicons that support different browsers and
platforms.

Add the following command to your `Dockerfile`, with the proper URL pointing to
your master icon:  The master icon should be a square PNG image with a size of
at least 260x260 for optimal results.

```Dockerfile
# Generate and install favicons.
RUN \
    APP_ICON_URL=https://github.com/jlesage/docker-templates/raw/master/jlesage/images/generic-app-icon.png && \
    install_app_icon.sh "$APP_ICON_URL"
```

Note that favicons are generated by [RealFaviconGenerator].

[RealFaviconGenerator]: https://realfavicongenerator.net/

### Dark Mode

Dark mode can be enabled via the `DARK_MODE` environment variable. When
enabled, the web interface used to display the application is automatically
adjusted accordingly.

For the application itself, supporting dark mode is more complicated.
Applications don't use the same toolkit to build their UI and each toolkit has
its own way to activate the dark mode.

The baseimage provides support for the [GTK] and [QT] toolkits.

[GTK]: https://www.gtk.org
[QT]: https://www.qt.io

#### GTK

When dark mode is enabled, the baseimage automatically setups the environment
to force the application to use a dark theme. Under the hood, this is done by
setting the following environment variables:
  - `GTK_THEME` is set to `Adwaita:dark`. This is used by GTK3 and GTK4
    applications.
  - `GTK2_RC_FILES` is set to `/opt/base/share/themes/Dark/gtk-2.0/gtkrc`. This
    is used by GTK2 applications.

#### QT

When dark mode is enabled, the baseimage automatically setup the environment
to force the application to use a dark theme. Under the hood, this is done by
setting the `QT_STYLE_OVERRIDE` environment variable to `Adwaita-Dark`.

In addition, the application's Dockerfile should install the Adwaita
style/theme. It is provided by the `adwaita-qt` package, available from the
Ubuntu, Debian or Alpine Linux software repositories.

NOTE: Dark mode is currently supported by QT5 and QT6.

### Tips and Best Practices

#### Do Not Modify Baseimage Content

Try to avoid modifications to files provided by the baseimage. This minimizes
the risk of breaking your container after using a new version of the baseimage.

#### Default Configuration Files

It is often useful to keep the original version of a configuration file. For
example, a copy of the original file could be modified by an initialization
script before being installed.

These original files, also called default files, should be stored under the
`/defaults` directory inside the container.

#### The $HOME Variable

The application is run under a Linux user having its own ID. This user has no
login capability, has no password, no valid login shell and no home directory.
It is effectively a kind of user used by daemons.

Thus, by default, the `$HOME` environment variable is not set. While this
should be fine in most case, some applications may expect the `$HOME`
environment variable to be set (since normally the application is run by a
logged user) and may not behave correctly otherwise.

To make the application happy, the home directory can be set at the beginning
of the `startapp.sh` script:
```shell
export HOME=/config
```

Adjust the location of the home directory to fit your needs. However, if the
application uses the home directory to write data, make sure it is done in a
volume mapped to the host (e.g. `/config`),

Note that the same technique can be used by services, by exporting the home
directory into their `run` script.

#### Referencing Linux User/Group

The Linux user/group under which the application is running can be referenced
via:
  - Its ID, as indicated by the `USER_ID`/`GROUP_ID` environment variable.
  - By the user/group `app`. The `app` user/group is setup during the startup
    to match the configured `USER_ID`/`GROUP_ID`.

#### Using `rootfs` Directory

All files that need to be copied into the container should be stored in your
source tree under the directory `rootfs`. The folder structure into this
directory should reflect the structure inside the container. For example, the
file `/etc/cont-init.d/my-init.sh` inside the container should be saved as
`rootfs/etc/cont-init.d/my-init.sh` in your source tree.

This way, copying all the required files to the correct place into the container
can be done with this single line in your `Dockerfile`:

```Dockerfile
COPY rootfs/ /
```

#### Maximizing Only the Main Window

By default, the application's window is maximized and decorations are hidden.
When the application has multiple windows, this behavior may need to be
restricted to only the main one.

The window manager can be configured to apply different behaviors for different
windows of the application. A specific window is identified by matching one or
more of its properties:
  - Name of the window.
  - Class of the window.
  - Title of the window.
  - Type of the window.
  - etc.

To find the value of a property for a particular window:
  - Create and start an instance of the container.
  - From the host, start the `obxprop` tool:
```shell
docker exec <container name or id> obxprop | grep "^_OB_APP"
```
  - Access the GUI of the application and click somewhere on the
    interested window.
  - Information about that window will be printed.

The following table shows how to find the relevant information:

| Property   | Value |
|------------|-------|
| Name       | The window's `_OB_APP_NAME` property. |
| Class      | The window's `_OB_APP_CLASS` property. |
| Title      | The window's `_OB_APP_TITLE` property. |
| GroupName  | The window's `_OB_APP_GROUP_NAME property`. |
| GroupClass | The window's `_OB_APP_GROUP_CLASS property`. |
| Type       | The window's `_OB_APP_TYPE property`. The type can be one of the following values: `desktop`, `dialog`, `dock`, `menu`, `normal`, `notification`, `splash`, `toolbar`, `utility`. |
| Role       | The window's `_OB_APP_ROLE` property. |

By default, the window manager configuration matches only the type of the
window, which must be `normal`. More restrictions can be added to better
select the correct window.

To do this, matching criterias can be defined by adding a file located at
`/etc/openbox/main-window-selection.xml` in the container. This file should
have one matching critera per line, in XML format. For example, to match
against both the type and the name of the window, the file content should be:

```xml
<Type>normal</Type>
<Name>My Application</Name>
```

**NOTE**: To maintain backward compatibility with previous 4.x versions, the
          container fallbacks to `/etc/jwm/main-window-selection.jwmrc` if
          `/etc/openbox/main-window-selection.xml` does not exist.

#### Adaptations from the 3.x Version

For existing applications using the previous version of the baseimage, few
adaptations are needed when updating to the new baseimage. Here are a few
tips:

  - Verify exposed environment variables: each of them should be categorized as
    a public or private one. See the
    [Environment Variables](#environment-variables) section.
  - Initialization scripts should be renamed to have the proper naming format.
    See the [Initialization Scripts](#initialization-scripts) section.
  - Parameters/definition of services should be adjusted for the new system.
    See the [Services](#services) section.
  - Verify that no scripts are using `with-contenv` in their shebang (e.g. from
    init scripts).
  - Set the `APP_VERSION` and `DOCKER_IMAGE_VERSION` internal environment
    variables when/if needed.
  - Any adjustment to the window manager config (e.g. to maximize only the main
    window) should be adapted to use the new mechanism. See the
    [Maximizing Only the Main Window](#maximizing-only-the-main-window) section.

