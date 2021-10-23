#TOOLCHAIN=~/toolchain/arm-none-eabi-bash-on-win10-/bin
#PREFIX=$(TOOLCHAIN)/arm-none-eabi-bash-on-win10-/arm-none-eabi-
PREFIX=arm-none-eabi-

ARCHFLAGS=-mthumb -mcpu=cortex-m0plus
CFLAGS=-I./includes/  -g -O2 -Wall -Werror -D "CPU_MKL46Z256VLL4"
#LDFLAGS=-specs=nosys.specs -Wl,--gc-sections,-Map,$(TARGET).map,-Tlink.ld
LDFLAGS=-specs=nano.specs -specs=nosys.specs -Wl,--gc-sections,-Map,$(TARGET).map,-Tlink.ld

#LDFLAGS=--specs=nano.specs -Wl,--gc-sections,-Map,$(TARGET).map,-Tlink.ld


CC=$(PREFIX)gcc
LD=$(PREFIX)gcc
OBJCOPY=$(PREFIX)objcopy
SIZE=$(PREFIX)size
RM=rm -f

TARGET=led_blinky

SRC=$(wildcard *.c )
OBJ=$(patsubst %.c, %.o, $(SRC))

SRC2=$(wildcard ./dep/*.c )
OBJ2=$(patsubst %.c, %.o, $(SRC2))

all: build size
build: elf srec bin
elf: $(TARGET).elf
srec: $(TARGET).srec
bin: $(TARGET).bin

clean:
	$(RM) $(TARGET).srec $(TARGET).elf $(TARGET).bin $(TARGET).map $(OBJ) $(OBJ2)

%.o: %.c
	$(CC) -c $(ARCHFLAGS) $(CFLAGS) -o $@ $<

$(TARGET).elf: $(OBJ) $(OBJ2)
	$(LD) $(LDFLAGS) -o $@ $(OBJ) -o $@ $(OBJ2)
	#$(LD) $(LDFLAGS) -o $@ $(OBJ2)
	


%.srec: %.elf
	$(OBJCOPY) -O srec $< $@

%.bin: %.elf
	    $(OBJCOPY) -O binary $< $@

size:
	$(SIZE) $(TARGET).elf
	

flash: build
	openocd -f openocd.cfg 
