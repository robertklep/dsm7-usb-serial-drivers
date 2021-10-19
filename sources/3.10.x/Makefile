kernel_mod = ch341.ko cp210x.ko pl2303.ko

all: $(kernel_mod)

obj-m := ch341.o cp210x.o pl2303.o

$(kernel_mod):
	make -C $(KSRC) M=$(PWD) modules

install: $(kernel_mod)
	mkdir -p $(DESTDIR)/3.10.x/ 2>/dev/null
	install $< $(DESTDIR)/3.10.x/

clean:
	rm -rf *.o $(kernel_mod) *.cmd
