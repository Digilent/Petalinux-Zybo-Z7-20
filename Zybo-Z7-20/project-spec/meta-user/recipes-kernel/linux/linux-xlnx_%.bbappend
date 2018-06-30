SRC_URI += "file://user_2017-07-10-08-35-00.cfg \
            file://user_2017-07-11-07-44-00.cfg \
            file://user_2017-07-18-17-02-00.cfg \
            file://user_2017-07-28-03-36-00.cfg \
            file://user_2017-07-28-21-03-00.cfg \
            file://user_2017-10-11-17-11-00.cfg \
            file://user_2017-10-13-22-56-00.cfg \
            file://user_2018-02-13-04-02-00.cfg \
            file://user_2018-02-13-04-15-00.cfg \
            file://user_2018-03-05-17-31-00.cfg \
            file://user_2018-03-06-01-20-00.cfg \
            file://user_2018-06-29-17-10-00.cfg \
            "


FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

KERNEL_VERSION_SANITY_SKIP = "1"


