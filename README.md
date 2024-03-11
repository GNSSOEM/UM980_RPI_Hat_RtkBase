# UM980_RPI_Hat_RtkBase

### RTK Base for RPI HAT ELT0229/ELT0219 on Unicore UM980/UM982

Based on RtkBase

## Easy installation:
+ Connect your ELT0229/ELT0219 to your raspberry pi/orange pi/....

+ Open a terminal and:

  ```bash
  wget https://raw.githubusercontent.com/GNSSOEM/UM980_RPI_Hat_RtkBase/main/install.sh
  chmod +x install.sh
  ./install.sh
  ```
+ RTFM

## Two phase installation:

+ ./install.sh -1 for part of installation without receiver
+ ./install.sh -2 for part of installation with receiver

## main feature, added to RtkBase

+ Full configure for Unicore receiver and RPI
+ If mount and password are both TCP use TCP-client instead of NTRIP-server. It's need for rtkdirect.com
+ Setup base position to Unicore receiver
+ Timeout for PPP-solution is extended to 36 hours
+ Add port 5017 for direct configure Unicore Receiver
+ Default settings is adopted to Unicore receiver, onocoy.com and rtkdirect.com
+ Windows RTK & HAS utilitis for precise resolving rtkbase position
+ Zeroconf configuration as rtkbase.local in the local network

## License:
UM980_RPI_Hat_RtkBase is licensed under AGPL 3 (see [LICENSE](./LICENSE) file).

UM980_RPI_Hat_RtkBase uses [RtkBase](https://github.com/Stefal/rtkbase) (GPL v3)
