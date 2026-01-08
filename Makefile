# Makefile for RISCMatrixApp
# Target: Raspberry Pi (ARMv7)

# Toolchain definitions (can be overridden)
# For native ARM (RPi): make
# For WSL/x86 (Cross): make AS=arm-linux-gnueabihf-as LD=arm-linux-gnueabihf-ld

AS = arm-linux-gnueabihf-as
LD = arm-linux-gnueabihf-ld
ASFLAGS = -g
LDFLAGS = -g

OBJS = src/main.o src/utils.o src/memory.o src/matrix.o

all: matrix_app

matrix_app: $(OBJS)
	$(LD) $(LDFLAGS) -o matrix_app $(OBJS)

src/main.o: src/main.s src/macros.s
	$(AS) $(ASFLAGS) -o src/main.o src/main.s

src/utils.o: src/utils.s
	$(AS) $(ASFLAGS) -o src/utils.o src/utils.s

src/memory.o: src/memory.s
	$(AS) $(ASFLAGS) -o src/memory.o src/memory.s

src/matrix.o: src/matrix.s
	$(AS) $(ASFLAGS) -o src/matrix.o src/matrix.s

clean:
	rm -f src/*.o matrix_app
