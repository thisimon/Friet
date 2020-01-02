CC=gcc
CFLAGS= -I include -I ../friet/include

VPATH = source

LIBS=-l

all: degree.o

degree.o: degree.c ../friet/include/friet.h include/degree.h
	$(CC) $(CFLAGS) -c $<

.PHONY: clean

clean:
	rm -f *.o *~ *.exe