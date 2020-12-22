# shinai-fi - Practise wifi hacking without the hardware

This is a modified version of shinai-fi repository (check out the original forked repo).

Difference from master repo :

- Improved Dockerfile (size and code)

- WPA2-CCMP caption with an easy password

- WEP caption

## 1) Setup the wlan simulator :

Open a terminal in your docker host and type :
```
modprobe mac80211_hwsim radios=4

```
This will allow you to simulate WiFi traffic without a network card



It is preferable if you run it on Ubuntu and Debian distribution because, as stated in the original repo : 
"If you're running docker-ce on macOS or Windows, the fake docker host doesn't have kernel support for wifi, rather run your docker host in a VM. If you do want to make your docker-ce work with a custom kernel, check [this article](https://medium.com/@notsinge/making-your-own-linuxkit-with-docker-for-mac-5c1234170fb1)."

## 2) Build

There is a Docker file in the main folder, build it with :
```
docker build -t wifi_hacking_docker .
```
This will create a Docker image named "wifi_hacking_dock". You can choose the name you prefer.
The dockerfile will be configured with the WPA2-CCMP caption. If you want to test your skills also with an old WEP access point, modify the dockerfile and replace the line
```
RUN cp shinai-fi/caps/wpa-induction.cap /opt/sensepost/capture/sensepost.cap
```
with
```
RUN cp shinai-fi/caps/wep-induction.cap /opt/sensepost/capture/sensepost.cap
```

## 3) Run

Run the Docker container :

```
docker run -it --privileged --network host wifi_hacking_docker:latest
```
Alternatively, pull it from Dockerhub

```
docker pull ale753/wpa2_hacking_docker
docker pull ale753/wep_hacking_docker
```



If you pulled it from DockerHub, change "wifi_hacking_docker" in "ale753/wpa2_hacking_docker" or "ale753/wep_hacking_docker"

## 4) Crack the password

Once the container is up and running, launch :

```
airmon-ng start wlan1
airodump-ng wlan1mon -w capture.cap
```

You can also set up an hostapd AP and see a client connect.
The password for the WPA2 .cap is "Induction"

# Full guide to setup your Hacking Lab and a Hostapd Wifi Access Point

With these tools you can also make active attacks on custom Access Points you can configure. Let's check out how this can be done.

In this repo you will find a folder "hostapd-docker". It contains a full configurable Access Point that will run on a docker container and will work in combination with mac80211_hwsim (check https://github.com/fgg89/docker-ap)

```
cd shinai-fi/hostapd-docker
./docker_ap start wlan0
```
This will setup an AP (WPA TKIP) on wlan0 and you can clearly see it if you run airodump on wlan1.

[![Screenshot-from-2020-11-01-20-44-17.png](https://i.postimg.cc/SR4bW2Xj/Screenshot-from-2020-11-01-20-44-17.png)](https://postimg.cc/R6gYm0Lz)

You can easly connect to this AP with another network card (for example wlan2)

```
nmcli d wifi connect DockerAP password dockerap123 iface wlan2
```
[![Screenshot-from-2020-11-01-20-47-06.png](https://i.postimg.cc/tCfDw05N/Screenshot-from-2020-11-01-20-47-06.png)](https://postimg.cc/QHQpKyvF)

An example of what you can do, send a fake deauth attack to the station that is connected through wlan2.
Remember to check out the channel of the access point and to run wlan1mon with the option --channel selecting the correct channel.

```
airodump-ng wlan1mon --channel 1
```
```
aireplay-ng --deauth 0 -c 02:00:00:00:02:00 -a 02:00:00:00:00:00 wlan1mon
```
Where 02:00:00:00:00:00 is the bssid of the DockerAP and 02:00:00:00:02:00 is the bssid of your station. You are now disconnected from the AP.

[![Screenshot-from-2020-11-01-20-48-03.png](https://i.postimg.cc/HWr62s0k/Screenshot-from-2020-11-01-20-48-03.png)](https://postimg.cc/t7HdRbmK)



# How can I create my own Wifi-Hacking Docker container?

Shinai-fi repository uses also tcpreplay to emulate the traffic, using real data packets contained in the wpa-supplicant.cap file (you can find it in the folder caps in this repository). If you want to customize your lab and make your own .cap file, you will need to setup a real AP and capture packets from your devices connected to it. So you will need a functioning network card to capture data packets of a real network environment.

## 1) Setup the wifi card in monitor mode :
Install tcpdump
```
apt-get install tcpdump
```

Then start your network card
```
airmon-ng check kill
ifconfig wlan0 down
iwconfig wlan0 mode monitor
ifconfig wlan0 up
```
## 2) Capture the packets

Launch this command to capture the traffic and save it in example.cap

```
sudo tcpdump -i wlan0 -w example.cap ether host "YOUR BSSID"
```
It is really important that you capture the packets with tcp-dump, otherwise you could have compatibility problems due to DTL type and tcpreplay will not be able to send the packets due to incorrect arguments.

Note that to filter the traffic only on your wifi and devices connected, you will need the bssid. You can easly find it through

```
airmon-ng start wlan0 
```
and check the bssid number correspondent to the name of your Access Point.

## 3) Working test

Collect a decent amount of packets (if you are collecting wep traffic) or capure an handshake by connecting your device to the Access point (in case of WPA2-CCMP traffic)

```
tcpreplay -i wlan1 example.cap

```
This will replicate the network traffic you captured on the wlan1 card (simulation). Use airmon-ng to make sure it works well.

Shinai-fi simulates clients and ap with the packets in the .cap file , so rename your example.cap file in wpa-supplicant.cap and copy it in the folder /caps of your cloned repo (or also directly in your docker container is fine by using the command docker cp)

If you are collecting WEP traffic and you have problems with tcp-replay, the cause could be the size of the MTU. Change this with :
```
ifconfig wlan1 mtu 1600

```
If you put 1600 and still can't see the packets, try different sizes.

## 4) How can I setup a WEP Access point and collect wep traffic for my docker lab?

Since WEP is deprecated, your home modem could not support it anymore. For this reason, I suggest you to setup a Wifi Hotspot in Ubuntu 14.4 (an old version of Ubuntu that supports WEP encryption) with WEP 40bit/128bit as Security parameter. Of course you don't need to install Ubuntu 14.4 on your machine, just install it on a USB pendrive (4GB is fine) and boot it with "try ubuntu without installing".






