SUMMARY = "Qt6 Application"
DESCRIPTION = "A Qt6-based application"
LICENSE = "GPL-3.0-or-later"
LIC_FILES_CHKSUM = "file://LICENSE;md5=5acfe5f4dc96f514001a4e07648c1af7"


BB_NO_NETWORK = "0"
SRC_URI = "git://git@bitbucket.org/curtisinst/ag-qt6-coffeemachine.git;protocol=ssh;branch=main"
SRCREV = "c5391d5e12c2953b2b3e14cfd01dfe5a03d91a6e"
PV = "6.8.2"

# Ensure the Qt6 dependencies are built and available
DEPENDS = "qtbase qtdeclarative mesa-gl qtwayland"

S = "${WORKDIR}/git"

inherit cmake pkgconfig
EXTRA_OECMAKE += "-DQT_HOST_PATH=${HOME}/Qt6.8.2/6.8.2/gcc_64"

