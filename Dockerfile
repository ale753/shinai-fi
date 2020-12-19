
FROM kalilinux/kali as builder
RUN apt-get update && apt-get install -y \
  build-essential \
  pkg-config \
  git \
  libnl-genl-3-dev \
  libssl-dev \
&& rm -rf /var/lib/apt/lists/*
WORKDIR /hostapd-mana/
RUN git clone --depth=3 https://github.com/ale753/hostapd-mana \
&& make -j2 -C hostapd-mana/hostapd

FROM kalilinux/kali
#LABEL maintainer="@singe at SensePost <research@sensepost.com>"

RUN apt-get update && apt-get install -y \
  net-tools \
  procps \
  iproute2 \
  iptables \
  iputils-ping \
  isc-dhcp-client \
  isc-dhcp-common \
  nftables \
  aircrack-ng \
  ca-certificates \
  cron \
  git \
  iw \
  pciutils \
  ssl-cert \
  tcpreplay \
  unzip \
  wpasupplicant \
&& rm -rf /var/lib/apt/lists/*

RUN git clone --depth=3 https://github.com/ale753/shinai-fi.git

RUN mkdir opt/sensepost/ && mkdir opt/sensepost/bin && mkdir opt/sensepost/capture && mkdir opt/sensepost/etc && mkdir root/mana

RUN cp /shinai-fi/attacker/client.sh /opt/sensepost/bin/
RUN cp shinai-fi/attacker/wifi-replay.sh /opt/sensepost/bin/


RUN cp shinai-fi/caps/wpa-induction.cap /opt/sensepost/capture/sensepost.cap
#RUN RUN cp shinai-fi/caps/wep-induction.cap /opt/sensepost/capture/sensepost.cap
#Uncomment this command and comment the previous if you want wep traffic 

RUN cp shinai-fi/attacker/wpasup.conf /opt/sensepost/etc/wpasup.conf

RUN chmod +x /opt/sensepost/bin/wifi-replay.sh \
&& chmod +x /opt/sensepost/bin/client.sh \
&& echo -n \
"* * * * * /opt/sensepost/bin/wifi-replay.sh\n \
* * * * * /opt/sensepost/bin/client.sh\n" > crontab.tmp \
&& crontab -u root crontab.tmp \
&& rm -rf crontab.tmp

COPY --from=builder /hostapd-mana/hostapd-mana/hostapd/hostapd /usr/local/bin/
COPY --from=builder /hostapd-mana/hostapd-mana/hostapd/hostapd_cli /usr/local/bin/
RUN cp shinai-fi/mana/dhparam.pem /root/mana/
RUN cp shinai-fi/mana/hostapd.eap_user /root/mana/
RUN cp shinai-fi/mana/open_eap.conf /root/mana/
ENV PATH $PATH:/hostapd-mana

CMD  /etc/init.d/cron start && /bin/bash

