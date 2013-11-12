clean:
	@rm -f *.o
	@echo RM      *.o
	@rm -f *~
	@echo RM      *~
	@rm -f src/*.o
	@echo RM      src/ *.o
	@rm -f src/*~
	@echo RM      src/*~
	@rm -f snake
	@echo RM      snake
all: clean snake create start
snake:
	@nasm src/snake.s -o snake
	@echo NASM    src/snake.s

create:
	dd if=/dev/zero of=image.img bs=512 count=2880
	dd if=snake of=image.img

start:
	qemu -fda image.img
