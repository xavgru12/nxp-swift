# NXP Yocto evaluation

Warning: This requires qt6 6.8.2 to be installed in $HOME. If you want to compile without the qt6 coffeemachine, remove "coffeemachine" from IMAGE_INSTALL:append in nxp/conf/local.conf.

## instructions

### optional: setup wsl

```
wsl --install
```
or
```
wsl --update
```
exit wsl and execute
```
wsl --set-default-version 2
```

### optional: setup Linux environment

- install Ubuntu via wsl
https://documentation.ubuntu.com/wsl/en/latest/howto/install-ubuntu-wsl2/

- ssh for git 

    follow this guide:
http://ag-polarion/polarion/#/project/ag/wiki/Tools%20and%20Responsibles/Git

- install packages which are required for a decent setup using wsl

```
git clone https://github.com/xavgru12/linux-configuration.git ~/linux-configuration
```

```
cd ~/linux-configuration
```

```
sh installPackages.sh
```

- setup tmux

    follow the steps at:
    https://github.com/xavgru12/tmux-configuration.git

- setup nvim

```
git clone https://github.com/xavgru12/NvChad.git --recurse-submodules ~/.config/nvim
```

start nvim which will automatically configure and install its packages:
```
nvim
```

### clone repository

Note: starting wsl, it will default to: /mnt/c/git/
This makes the filesystem really slow:
use "cd" in order to switch to /home/$USER

```
git clone git@bitbucket.org:curtisinst/ag-nxp-yocto-evaluation.git --recurse-submodules
```

### Docker
Install Docker

```
sudo apt update && sudo apt upgrade -y
```

```
sudo apt install docker.io
```

To work better with docker, without `sudo`, add your user to `docker group`.
  ```{.sh}
  sudo usermod -aG docker <your_user>
  ```

Additionally, you may need to execute this:
```
sudo chmod 666 /var/run/docker.sock
```

Log out and log back in so that your group membership is re-evaluated.


Build Docker (start the script in the repository, once only)

```
./build-docker.sh
```
Run Docker
```
./run-docker.sh
```

Make sure your ssh keys exist or 
create new keys.
inside Docker, start the ssh agent
```
eval "$(ssh-agent -s)"
```

```
ssh-add ~/.ssh/id_ed25519
```

Setup environment variables
```
source setup-environment nxp/ 
```

Finally, start the build,
refer to the build images chapter 

### Optional setup without Docker: install yocto dependencies

```
sudo apt-get update && sudo apt-get upgrade -y
```

Install yocto dependencies


```
sudo apt install -y build-essential chrpath cpio debianutils diffstat file gawk gcc git iputils-ping libacl1 liblz4-tool locales python3 python3-git python3-jinja2 python3-pexpect python3-pip python3-subunit socat texinfo unzip wget xz-utils zstd
```

These dependencies are taken from the official website
under "Build Host Packages":

https://docs.yoctoproject.org/brief-yoctoprojectqs/index.html


Install and configure more packages that are required for wsl Ubuntu

```
sudo locale-gen en_US.UTF-8
```
```
sudo update-locale
```
```
sudo apt install -y autoconf
```
```
sudo apt install -y libtool-bin
```

### build images 

Source, in order to setup the variables.
```
source setup-environment nxp/ 
```

The build may take several hours.

```
bitbake <image_name>
```
Tested images: 

imx-image-core and
imx-image-full

### Run qemu

```
runqemu nographic
```

Get out of qemu with C-a x

### Troubleshooting

delete the binaries with:

```
rm -rf tmp sstate-cache
```

If you need to restart specific targets,
eg nettle or llvm:

```
bitbake -c cleansstate llvm && bitbake llvm 
```

### Optional: using wsl optimize disk space usage on windows (.vhdx error message)
```
wsl --shutdown
diskpart
# open window Diskpart
select vdisk file="C:\WSL-Distros\…\ext4.vhdx"
attach vdisk readonly
compact vdisk
detach vdisk
exit
```
https://github.com/microsoft/WSL/issues/4699


### Build an application with SDK from yocto using cmake
run this command:
```
bitbake imx-image-core -c populate_sdk
```

this will generate the directory:
./nxp/tmp/deploy/sdk with a .sh file inside.
Execute it to install the sdk.

Once the sdk is installed, open the console where
you want to build your application and source the 
setup-evironment.. file.
Building with cmake, you need to do the configure step 
using the toolchain file: 
<sdk_root>/sysroots/x86_64-pokysdk-linux/usr/share/cmake/OEToolchainConfig.cmake

eg:
cmake -S . -B build -DCMAKE_TOOLCHAIN_FILE=/home/xaver/code/imx-sdk/sysroots/x86_64-pokysdk-linux/usr/share/cmake/OEToolchainConfig.cmake


### Memory build issues
Peak memory usage can reach 50gb. There are two ways to circumvent this.

Option 1: restrict parallel jobs
```
export BB_NUMBER_THREADS=4
```

```
export PARALLEL_MAKE="-j 4"
```

```
source ~/.bashrc
```

Option 2: set up a swap file

```
dd if=/dev/zero of=/customSwapFile bs=1024 count=64M
```

```
mkswap /customSwapFile
```

add this line to /etc/fstab:

/customSwapFile swap swap sw 0 0

```
swapon /customSwapFile 
```

check, if it worked:
```
cat /proc/swaps
```

```
top
```

### Flashing an image


1) Download the uuu tool, eg sudo apt install uuu, version used: 
uuu (Universal Update Utility) for nxp imx chips -- lib1.5.141

2) put the uuu tool in the same folder of your final image or put uuu in your PATH.

3) Put your board in download mode setting the boot switches (You can refer to the image attached to this post)

4) connect the usb port1 (J301) to you host computer and the usb port2 (J302) to the power supply

5) run the next command to flash the SD card (The SD card should be mounted in the EVK board):
The image name may vary.
```
sudo uuu -b sd_all imx-boot-imx8mnevk-sd.bin-flash_evk imx-image-core-imx8mnevk.rootfs-20250226171614.wic.zst
```
If you want to flash the eMMC you have to use the next command:
```
sudo uuu -b emmc_all imx-boot-imx8mnevk-sd.bin-flash_evk imx-image-core-imx8mnevk.rootfs-20250226171614.wic.zst
```
When the flash process is completed, you have to put the boot switches in eMMC/SD boot (Refer to the attached image)

![alt text](./NXPEmbeddedLinux.png?raw=true)


### NXP SoC Board

i.MX 8M Nano applications processors 

https://www.nxp.com/part/MIMX8MN6DVTJZAA#/


### How to debug the MCU Core M7

## SEGGER J-Link
1) Launch Visual Studio Code and connect to COM ports: baud rate is 115200. The serial port of the M7 is silent, the other one shows the Linux boot output at startup.

2) On the Linux console inhibit Linux boot at startup in order to enter the U-Boot promt.

3) Enter the following commands
```
u-boot=> run prepare_mcore
u-boot=> boot
```

4) Run J-Link GDB Server from SEGGER

5) Add script `NXP_iMX8M_Connect_CortexM7.JLinkScript` from `iar_segger_support_patch_imx8mp.zip` in J-Link GDB Server (see AN14120.pdf, page 10)

6) Make sure the value of `gdbServerTargetRemote` in `Launch.json` is set to the IP adress of the host (see Launch.json in m7 folder of this repo). `Launch.json` is located in the .vscode/ folder.

7) From Visual Studio Code connect to the GDB server

8) Connect Visual Studio Code to GDB Server using MCUXpresso extension.

![alt text](./m7/gdb_connected_to_m7.png?raw=true)
