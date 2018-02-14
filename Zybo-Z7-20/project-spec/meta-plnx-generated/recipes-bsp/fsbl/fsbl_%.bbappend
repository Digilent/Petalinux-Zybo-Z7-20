
XSCTH_WS = "${TOPDIR}/../components/plnx_workspace/fsbl"
EXTERNALXSCTSRC = "${PETALINUX}/tools/hsm/data/embeddedsw"
EXTERNALXSCTSRCHASH = "build"
inherit externalxsctsrc
EXTERNALXSCTSRC_BUILD = "${TOPDIR}/../components/plnx_workspace/fsbl"
export _JAVA_OPTIONS
_JAVA_OPTIONS = "-Duser.home=${TMPDIR}/xsctenv"
YAML_SERIAL_CONSOLE_STDOUT = "ps7_uart_1"
YAML_SERIAL_CONSOLE_STDIN = "ps7_uart_1"
