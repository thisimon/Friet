CC=gcc
CFLAGS= -I include

VPATH = source

LIBS=-lm

all: friet.o

friet.o: friet.c include/friet.h
	$(CC) $(CFLAGS) -c $<

.PHONY: clean

clean:
	rm -f *.o *~ *.exe