kernel_mod= cp210x.ko

all: $(kernel_mod)

obj-m := cp210x.o

$(kernel_mod):
	make -C $(KSRC) M=$(PWD) modules

install: $(kernel_mod)
	mkdir -p $(DESTDIR)/cp210x/
	install $< $(DESTDIR)/cp210x/

clean:
	rm -rf *.o $(kernel_mod) *.cmd
