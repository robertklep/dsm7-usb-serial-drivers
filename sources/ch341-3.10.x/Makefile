kernel_mod= ch341.ko

all: $(kernel_mod)

obj-m := ch341.o

$(kernel_mod):
	make -C $(KSRC) M=$(PWD) modules

install: $(kernel_mod)
	mkdir -p $(DESTDIR)/ch341/
	install $< $(DESTDIR)/ch341/

clean:
	rm -rf *.o $(kernel_mod) *.cmd
