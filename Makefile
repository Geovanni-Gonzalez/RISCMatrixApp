# Makefile for RISCMatrixApp
# Target: Raspberry Pi (ARMv7)

# Toolchain definitions (can be overridden)
# For native ARM (RPi): make
# For WSL/x86 (Cross): make AS=arm-linux-gnueabihf-as LD=arm-linux-gnueabihf-ld

AS = as
LD = ld

OBJS = src/main.o src/utils.o src/memory.o src/matrix.o

all: matrix_app

matrix_app: $(OBJS)
	$(LD) -o matrix_app $(OBJS)

src/main.o: src/main.s src/macros.s
	$(AS) -o src/main.o src/main.s

src/utils.o: src/utils.s
	$(AS) -o src/utils.o src/utils.s

src/memory.o: src/memory.s
	$(AS) -o src/memory.o src/memory.s

src/matrix.o: src/matrix.s
	$(AS) -o src/matrix.o src/matrix.s

clean:
	rm -f src/*.o matrix_app
