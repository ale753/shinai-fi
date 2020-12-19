# docker-ap

This script prepares a docker container with all the necessary daemons and configuration to run a fully working access point. This includes the following:

* hostapd (Soft Access Point)
* dnsmasq (DHCP server)
* Enable IPv4 forwarding
* Set NAT rules

The script must be run as root. The docker image ``fgg89/docker-ap`` will be built the first time that the script is executed (you can find the Dockerfile under ``/build``). The image contains the programs dnsmasq and hostapd. Their respective configuration files are generated on the fly and mounted in the docker container.

The docker container is granted exclusive access to the physical wireless interface (for more info please visit: https://github.com/fgg89/docker-ap/wiki/Container-access-to-wireless-network-interface)

* Tested on: Ubuntu 14.04/16.04, Raspbian 8 (Jessie)
* Supported architectures: x86_64, armv7

Default configuration
---------------------

* SSID = **DockerAP**
* Passphrase = **dockerap123**

The script will configure the access point with the default settings. However, if you wish to set different ones then you must modify the ``wlan_config.txt`` file, which contains all the config parameters that are supported at the moment.

## Usage

Start the service:

```
./docker_ap start [wlan_interface]
```

Stop the service:

```
./docker_ap stop [wlan_interface]
```

## License

This project is licensed under the terms of the MIT license.
