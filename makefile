clean:
	rm -f *.o
	rm -f *~
	rm -f src/*.o
	rm -f src/*~
	rm -f snake
all: snake create start
snake:
	nasm src/snake.s -o snake

create:
	dd if=/dev/zero of=image.img bs=512 count=2880
	dd if=snake of=image.img

start:
	qemu -fda image.img
