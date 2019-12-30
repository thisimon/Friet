CC=gcc
CFLAGS= -I include -I ../friet/include

VPATH = source

LIBS=-lm

all: trail_diff.o trail_lin.o util.o

util.o: util.c ../friet/include/friet.h include/util.h
	$(CC) $(CFLAGS) -c $<

trail_diff.o: trail_diff.c ../friet/include/friet.h include/util.h include/trail_diff.h
	$(CC) $(CFLAGS) -c $<

trail_lin.o: trail_lin.c ../friet/include/friet.h include/util.h include/trail_lin.h
	$(CC) $(CFLAGS) -c $<

.PHONY: clean

clean:
	rm -f *.o *~ *.exe