---
layout: post
title:  树莓派连接WiFi
author: 詹子知(James Zhan)
date:   2015-03-02 15:00:00
meta:   版权所有，转载须声明出处
category: raspberrypi
tags: [raspberrypi, linux, hardware, wifi]
---

尽管树莓派非常小，但是如果不能连接WiFi，那么它的移动性将大打折扣，因为它必须需要一根网线直接连接路由器。下面本文就介绍一下如何让树莓派连接无线网络。

### 准备工作

首先，你需要有：

+ 树莓派一台
+ 无线路由器一台
+ USB WiFi网卡一枚（[这里](http://elinux.org/RPi_USB_Wi-Fi_Adapters)可以查看raspbian支持的无线网卡型号列表）

先把USB WiFi网卡插入树莓派USB接口，启动树莓派（如果树莓派已经在移动状态，则直接插入无线网卡即可）。

使用 `sudo lsusb` 命令查看无线网卡是否已经被正确识别，例如我本地显示为：

```
Bus 001 Device 004: ID 0bda:8176 Realtek Semiconductor Corp. RTL8188CUS 802.11n WLAN Adapter
```

最新的raspbian已经有了wifi必要的包，一般直接插上就可以使用了，可以使用`iwconfig`再次确认网卡是否正常工作。

```
wlan0     unassociated  Nickname:"<WIFI@REALTEK>"
          Mode:Managed  Frequency=2.412 GHz  Access Point: Not-Associated
          Sensitivity:0/0
          Retry:off   RTS thr:off   Fragment thr:off
          Power Management:off
          Link Quality:0  Signal level:0  Noise level:0
          Rx invalid nwid:0  Rx invalid crypt:0  Rx invalid frag:0
          Tx excessive retries:0  Invalid misc:0   Missed beacon:0

lo        no wireless extensions.

eth0      no wireless extensions.
```

如果出现了类似如上例所示的`wlan0`，说明无线网卡已经可以正常工作了。

### 配置无线网卡

使用 `sudo ifconfig` 可以查看网卡的工作状态。

```
eth0      Link encap:Ethernet  HWaddr b8:27:eb:db:e8:f6
          inet addr:192.168.1.242  Bcast:192.168.1.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:79683 errors:0 dropped:0 overruns:0 frame:0
          TX packets:58163 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:109145561 (104.0 MiB)  TX bytes:5489567 (5.2 MiB)

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

wlan0     Link encap:Ethernet  HWaddr e8:4e:06:26:ab:45
          UP BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:6 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
```

这里的`wlan0`就是USB无线网卡，不过它还没有被分配IP。

搜索可用的无线网络。

```sh
sudo iwlist wlan0 scan | grep ESSID
```

编辑 `/etc/network/interfaces`文件，可以自行选择emacs，vim，nano编辑器，记得使用`sudo`。

```sh
sudo cp interfaces interfaces_bak   # 先备份
sudo emacs /etc/network/interfaces
```

修改内容如下：

```
allow-hotplug wlan0
iface wlan0 inet dhcp
wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf
iface default inet dhcp
```

> 除非manual，否则请一定要把`wpa-roam`改为`wpa-conf`。

配置WiFi连接

```sh
sudo emacs /etc/wpa_supplicant/wpa_supplicant.conf
```
添加如下内容：

```
network={
    ssid="YOUR_NETWORK_NAME"
    psk="YOUR_NETWORK_PASSWORD"
    proto=RSN
    key_mgmt=WPA-PSK
    pairwise=CCMP
    auth_alg=OPEN
}
```

+ proto 可以是 RSN (WPA2) 或者 WPA (WPA1)。
+ key_mgmt 可以是 WPA-PSK (绝大部分) or WPA-EAP (企业无线网络)。
+ pairwise 可以是 CCMP (WPA2) 或者 TKIP (WPA1)。
+ auth_alg 绝大部分都是OPEN, 其它的选项有 LEAP 和 SHARED。

如果想固定IP，不使用DHCP分配IP的方式，可以修改`/etc/network/interfaces`文件，如下例所示：

```
iface wlan0 inet static # dhcp to static
address 192.168.1.155 # Static IP you want 
netmask 255.255.255.0 
gateway 192.168.1.1   # IP of your router
```

配置完成后，重启树莓派，如果不想重启，也可以执行`sudo ifdown wlan0 && sudo ifup wlan0`来激活你的无线网卡。

