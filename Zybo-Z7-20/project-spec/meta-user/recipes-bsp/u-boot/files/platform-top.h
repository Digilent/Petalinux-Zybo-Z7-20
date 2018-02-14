
#include <configs/platform-auto.h>
#define CONFIG_SYS_BOOTM_LEN 0xF000000

/*Required for uartless designs */
#ifndef CONFIG_BAUDRATE
#define CONFIG_BAUDRATE 115200
#ifdef CONFIG_DEBUG_UART
#undef CONFIG_DEBUG_UART
#endif
#endif

/* Read GEM MAC Address from OTP address 0x20 in SPI Flash */

#ifndef CONFIG_ZYNQ_QSPI
#define CONFIG_ZYNQ_QSPI
#endif
#define ZYNQ_GEM_SPI_MAC_OFFSET	0x20

/* Add ability to read uEnv.txt when not using SPI Flash for env */

#ifndef CONFIG_ENV_IS_IN_SPI_FLASH
#define CONFIG_ENV_IS_NOWHERE
#define CONFIG_ENV_SIZE	0x20000
#undef CONFIG_PREBOOT
#define CONFIG_PREBOOT	"echo U-BOOT for Zybo Z7; setenv preboot; setenv bootenv uEnv.txt;  setenv loadbootenv_addr 0x3EE00000; if test $modeboot = sdboot && env run sd_uEnvtxt_existence_test; then if env run loadbootenv; then env run importbootenv; fi; fi; dhcp"
#endif

