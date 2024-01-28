kernel_mod = ch341.ko cp210x.ko rndis_host.ko pl2303.ko ti_usb_3410_5052.ko

all: $(kernel_mod)

obj-m := ch341.o cp210x.o rndis_host.o pl2303.o ti_usb_3410_5052.o

$(kernel_mod):
	make -C $(KSRC) M=$(PWD) modules

install: $(kernel_mod)
	mkdir -p $(DESTDIR)/4.4.x/ 2>/dev/null
	install $< $(DESTDIR)/4.4.x/

clean:
	rm -rf *.o $(kernel_mod) *.cmd
