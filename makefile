CC=gcc
CFLAGS= -I friet/include -I trail_analysis/include

VPATH = friet trail_analysis

LIBS=-lm

main.o: main.c friet/include/friet.h trail_analysis/include/util.h trail_analysis/include/trail_diff.h trail_analysis/include/trail_lin.h
	$(CC) $(CFLAGS) -c $<

main: main.o
	$(CC) $(CFLAGS) -o main main.o friet/friet.o trail_analysis/util.o trail_analysis/trail_diff.o trail_analysis/trail_lin.o $(LIBS)

all: 
	$(MAKE) -C friet
	$(MAKE) -C trail_analysis
	$(MAKE) main 

.PHONY: clean main

clean:
	rm -f *.o *~ *.exe
	rm -f friet/*.o friet/*.exe
	rm -f trail_analysis/*.o trail_analysis/*.exe