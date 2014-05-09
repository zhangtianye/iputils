#
# Configuration
#

# CC
#指定gcc程序
CC=gcc
# Path to parent kernel include files directory
#根内核库文件目录的路径
LIBC_INCLUDE=/usr/include
# Libraries
#添加库
ADDLIB=
# Linker flags
#链接器标识
#Wl命令告诉编译器将后面的参数传递给链接器
#-Wl,Bstatic告诉链接器使用Bstatic选项,该选项是告诉链接器,对接下来的-l选项使用静态链接
#-Wl,Bdynamic就是告诉链接器对接下来的-l选项使用动态链接
#指定静态链接
LDFLAG_STATIC=-Wl,-Bstatic
#指定动态链接
LDFLAG_DYNAMIC=-Wl,-Bdynamic
#指定加载库
#加载cap库
LDFLAG_CAP=-lcap
#加载TLS加密协议库
LDFLAG_GNUTLS=-lgnutls-openssl
#加载crypto密码类库
LDFLAG_CRYPTO=-lcrypto
#加载IDN(综合数字网)库
LDFLAG_IDN=-lidn
#加载resolv库
LDFLAG_RESOLV=-lresolv
#加载sysfs库
LDFLAG_SYSFS=-lsysfs

#
# Options
#选项
#
#变量定义,设置开关
# Capability support (with libcap) [yes|static|no]
#默认添加功能支持(使用cap库)[是|静态|不]
USE_CAP=yes
# sysfs support (with libsysfs - deprecated) [no|yes|static]
#默认添加sysfs的支持(使用sysfs-deprecated库)[否|是|静态]
USE_SYSFS=no
# IDN support (experimental) [no|yes|static]
#默认添加综合数字网支持(实验性的)[否|是|静态]
USE_IDN=no

# Do not use getifaddrs [no|yes|static]
#默认不使用getifaddrs函数[否|是|静态]
WITHOUT_IFADDRS=no
# arping default device (e.g. eth0) []
#系统默认arping设备(例如eth0)[]
ARPING_DEFAULT_DEVICE=

# GNU TLS library for ping6 [yes|no|static]
#默认为ping6添加TLS加密协议库[是|静态|不]
USE_GNUTLS=yes
# Crypto library for ping6 [shared|static]
#默认为ping6添加crypto密码类库[共享|静态]
USE_CRYPTO=shared
# Resolv library for ping6 [yes|static]
#默认为ping6添加resolv库[是|静态]
USE_RESOLV=yes
# ping6 source routing (deprecated by RFC5095) [no|yes|RFC3542]
#默认ping6路由来源选择(反对使用REC5095)[不|是|REC3452]
ENABLE_PING6_RTHDR=no

# rdisc server (-r option) support [no|yes]
#默认RDISC服务不使用-r选项[否|是]
ENABLE_RDISC_SERVER=no

# -------------------------------------
# What a pity, all new gccs are buggy and -Werror does not work. Sigh.
# CCOPT=-fno-strict-aliasing -Wstrict-prototypes -Wall -Werror -g
#-Wstrict-prototypes:如果函数的声明或定义没有指出参数类型,编译器就发出警告
#编译选项
CCOPT=-fno-strict-aliasing -Wstrict-prototypes -Wall -g
#优化级别
CCOPTOPT=-O3
#C运行库修复
GLIBCFIX=-D_GNU_SOURCE
#定义
DEFINES=
#加载库
LDLIB=

#选择库函数
FUNC_LIB = $(if $(filter static,$(1)),$(LDFLAG_STATIC) $(2) $(LDFLAG_DYNAMIC),$(2))

#判断是否加载TLS加密库
# USE_GNUTLS: DEF_GNUTLS, LIB_GNUTLS
# USE_CRYPTO: LIB_CRYPTO
ifneq ($(USE_GNUTLS),no)
	LIB_CRYPTO = $(call FUNC_LIB,$(USE_GNUTLS),$(LDFLAG_GNUTLS))
	DEF_CRYPTO = -DUSE_GNUTLS
else
	LIB_CRYPTO = $(call FUNC_LIB,$(USE_CRYPTO),$(LDFLAG_CRYPTO))
endif

# USE_RESOLV: LIB_RESOLV
#解析库
LIB_RESOLV = $(call FUNC_LIB,$(USE_RESOLV),$(LDFLAG_RESOLV))

# USE_CAP:  DEF_CAP, LIB_CAP
#判断是否加载cap库
ifneq ($(USE_CAP),no)
	DEF_CAP = -DCAPABILITIES
	LIB_CAP = $(call FUNC_LIB,$(USE_CAP),$(LDFLAG_CAP))
endif

# USE_SYSFS: DEF_SYSFS, LIB_SYSFS
#判断是否加载sysfs库
ifneq ($(USE_SYSFS),no)
	DEF_SYSFS = -DUSE_SYSFS
	LIB_SYSFS = $(call FUNC_LIB,$(USE_SYSFS),$(LDFLAG_SYSFS))
endif

# USE_IDN: DEF_IDN, LIB_IDN
#判断是否加载IDN(综合数字网)库
ifneq ($(USE_IDN),no)
	DEF_IDN = -DUSE_IDN
	LIB_IDN = $(call FUNC_LIB,$(USE_IDN),$(LDFLAG_IDN))
endif

# WITHOUT_IFADDRS: DEF_WITHOUT_IFADDRS
#判断getifaddrs函数是否是默认情况
ifneq ($(WITHOUT_IFADDRS),no)
	DEF_WITHOUT_IFADDRS = -DWITHOUT_IFADDRS
endif

# ENABLE_RDISC_SERVER: DEF_ENABLE_RDISC_SERVER
#判断RDISD服务器是否在默认情况下
ifneq ($(ENABLE_RDISC_SERVER),no)
	DEF_ENABLE_RDISC_SERVER = -DRDISC_SERVER
endif

# ENABLE_PING6_RTHDR: DEF_ENABLE_PING6_RTHDR
#判断ping6路由选择情况是否默认情况
ifneq ($(ENABLE_PING6_RTHDR),no)
	DEF_ENABLE_PING6_RTHDR = -DPING6_ENABLE_RTHDR
ifeq ($(ENABLE_PING6_RTHDR),RFC3542)
	DEF_ENABLE_PING6_RTHDR += -DPINR6_ENABLE_RTHDR_RFC3542
endif
endif

# -------------------------------------
IPV4_TARGETS=tracepath ping clockdiff rdisc arping tftpd rarpd
IPV6_TARGETS=tracepath6 traceroute6 ping6
TARGETS=$(IPV4_TARGETS) $(IPV6_TARGETS)

#预定义C编译选项
CFLAGS=$(CCOPTOPT) $(CCOPT) $(GLIBCFIX) $(DEFINES)
#加载库
LDLIBS=$(LDLIB) $(ADDLIB)

#显示节点名称
UNAME_N:=$(shell uname -n)
LASTTAG:=$(shell git describe HEAD | sed -e 's/-.*//')
#显示时间
TODAY=$(shell date +%Y/%m/%d)
DATE=$(shell date --date $(TODAY) +%Y%m%d)
TAG:=$(shell date --date=$(TODAY) +s%Y%m%d)


# -------------------------------------
#指定伪命令
.PHONY: all ninfod clean distclean man html check-kernel modules snapshot

#编译所有目标
all: $(TARGETS)

%.s: %.c
	$(COMPILE.c) $< $(DEF_$(patsubst %.o,%,$@)) -S -o $@
%.o: %.c
	$(COMPILE.c) $< $(DEF_$(patsubst %.o,%,$@)) -o $@
$(TARGETS): %: %.o
	$(LINK.o) $^ $(LIB_$@) $(LDLIBS) -o $@
#
#COMPILE.c=$(CC)$(CFLAGS)$(CPPFLAGS) -c
#$<依赖目标中的第一个目标名字
#$@表示目标
#$^所有依赖目标的集合
#在$(patsubst %.o,%,$@)中,patsubst把目标中的变量符合后缀是.o的全部删除,DEF_ping
#LINK.o把.o文件链接在一起的命令行,缺省值是$(CC)$(LDFLAGS)$(TARGET_ARCH)
#
#

# -------------------------------------
#iputils软件包(linux下一些网络工具,包含ping,tracepath,arping,tftpd,rarpd,clocldiff,rdisc)
# arping
#向相邻主机发送ARP请求
DEF_arping = $(DEF_SYSFS) $(DEF_CAP) $(DEF_IDN) $(DEF_WITHOUT_IFADDRS)
LIB_arping = $(LIB_SYSFS) $(LIB_CAP) $(LIB_IDN)

#条件语句,如果默认arping设备
ifneq ($(ARPING_DEFAULT_DEVICE),)
DEF_arping += -DDEFAULT_DEVICE=\"$(ARPING_DEFAULT_DEVICE)\"
endif

# clockdiff
#clockdiff用来测算目的主机跟本地主机的时间差
DEF_clockdiff = $(DEF_CAP)
LIB_clockdiff = $(LIB_CAP)

# ping / ping6
#使用 ping可以测试计算机名和计算机的ip地址，验证与远程计算机的连接。ping程序由ping.c ping6.cping_common.c ping.h 文件构成
DEF_ping_common = $(DEF_CAP) $(DEF_IDN)
DEF_ping  = $(DEF_CAP) $(DEF_IDN) $(DEF_WITHOUT_IFADDRS)
LIB_ping  = $(LIB_CAP) $(LIB_IDN)
DEF_ping6 = $(DEF_CAP) $(DEF_IDN) $(DEF_WITHOUT_IFADDRS) $(DEF_ENABLE_PING6_RTHDR) $(DEF_CRYPTO)
LIB_ping6 = $(LIB_CAP) $(LIB_IDN) $(LIB_RESOLV) $(LIB_CRYPTO)

ping: ping_common.o
ping6: ping_common.o
ping.o ping_common.o: ping_common.h
ping6.o: ping_common.h in6_flowlabel.h

# rarpd
#逆地址解析
DEF_rarpd =
LIB_rarpd =

# rdisc
#路由器发现守护程序
DEF_rdisc = $(DEF_ENABLE_RDISC_SERVER)
LIB_rdisc =

# tracepath
#测试IP数据报文从源主机传到目的主机的路由
DEF_tracepath = $(DEF_IDN)
LIB_tracepath = $(LIB_IDN)

# tracepath6
DEF_tracepath6 = $(DEF_IDN)
LIB_tracepath6 =

# traceroute6
DEF_traceroute6 = $(DEF_CAP) $(DEF_IDN)
LIB_traceroute6 = $(LIB_CAP) $(LIB_IDN)

# tftpd
#简单文件传送协议(TFTP的服务端程序)
DEF_tftpd =
DEF_tftpsubs =
LIB_tftpd =

tftpd: tftpsubs.o
tftpd.o tftpsubs.o: tftp.h

# -------------------------------------
# ninfod
ninfod:
#set  -e的作用:返回值非零,脚本立即退出
	@set -e; \
		if [ ! -f ninfod/Makefile ]; then \
			cd ninfod; \
			./configure; \
			cd ..; \
		fi; \
#fi作用:结束if,then条件判断
		$(MAKE) -C ninfod

# -------------------------------------
# modules / check-kernel are only for ancient kernels; obsolete
#只有老式的或过时的内核时进行模块/内核检测
check-kernel:
#ineq的作用是判断()中的内容是否相等
ifeq ($(KERNEL_INCLUDE),)
	@echo "Please, set correct KERNEL_INCLUDE"; false
else
	@set -e; \
	if [ ! -r $(KERNEL_INCLUDE)/linux/autoconf.h ]; then \
		echo "Please, set correct KERNEL_INCLUDE"; false; fi
endif

#模块/内核检测
modules: check-kernel
	$(MAKE) KERNEL_INCLUDE=$(KERNEL_INCLUDE) -C Modules

# -------------------------------------
man:
	$(MAKE) -C doc man

html:
	$(MAKE) -C doc html

#删除命令
clean:
	@rm -f *.o $(TARGETS)
	@$(MAKE) -C Modules clean
	@$(MAKE) -C doc clean
	@set -e; \
		if [ -f ninfod/Makefile ]; then \
			$(MAKE) -C ninfod clean; \
		fi

distclean: clean
	@set -e; \
		if [ -f ninfod/Makefile ]; then \
			$(MAKE) -C ninfod distclean; \
		fi

# -------------------------------------
#快照
snapshot:
	@if [ x"$(UNAME_N)" != x"pleiades" ]; then echo "Not authorized to advance snapshot"; exit 1; fi
	@echo "[$(TAG)]" > RELNOTES.NEW
	@echo >>RELNOTES.NEW
	@git log --no-merges $(LASTTAG).. | git shortlog >> RELNOTES.NEW
	@echo >> RELNOTES.NEW
	@cat RELNOTES >> RELNOTES.NEW
	@mv RELNOTES.NEW RELNOTES
	@sed -e "s/^%define ssdate .*/%define ssdate $(DATE)/" iputils.spec > iputils.spec.tmp
	@mv iputils.spec.tmp iputils.spec
	@echo "static char SNAPSHOT[] = \"$(TAG)\";" > SNAPSHOT.h
	@$(MAKE) -C doc snapshot
	@$(MAKE) man
	@git commit -a -m "iputils-$(TAG)"
	@git tag -s -m "iputils-$(TAG)" $(TAG)
	@git archive --format=tar --prefix=iputils-$(TAG)/ $(TAG) | bzip2 -9 > ../iputils-$(TAG).tar.bz2

