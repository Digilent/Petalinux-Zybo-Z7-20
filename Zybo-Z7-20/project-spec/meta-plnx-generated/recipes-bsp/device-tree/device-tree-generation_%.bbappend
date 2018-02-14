



DT_PADDING_SIZE = "0x1000"
XSCTH_WS = "${TOPDIR}/../components/plnx_workspace/device-tree"
YAML_DT_BOARD_FLAGS = "{BOARD template }"
sysconf = "${TOPDIR}/../project-spec/configs"
SRC_URI_append ="\
    file://config\
"
export PETALINUX
export _JAVA_OPTIONS
_JAVA_OPTIONS = "-Duser.home=${TMPDIR}/xsctenv"
KERNEL_DTS_INCLUDE = "${STAGING_KERNEL_DIR}/include"
YAML_MAIN_MEMORY_CONFIG = "ps7_ddr_0"
FILESEXTRAPATHS_append := ":${sysconf}"
YAML_CONSOLE_DEVICE_CONFIG = "ps7_uart_1"

do_configure_append () {
	script="${PETALINUX}/etc/hsm/scripts/petalinux_hsm_bridge.tcl"
	data=${PETALINUX}/etc/hsm/data/
	eval xsct ${script} -c ${WORKDIR}/config \
	-hdf ${DEVICETREE_WORKDIR}/hardware_description.hdf -repo ${S}\
	-data ${data} -sw ${DEVICETREE_WORKDIR} -o ${DEVICETREE_WORKDIR} -a "soc_mapping"
}
