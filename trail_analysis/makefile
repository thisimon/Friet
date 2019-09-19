IDIR = ./include
CC=gcc
CFLAGS=-I $(IDIR)

SRCDIR= ./source

LIBS=-lm

_DEPS = util.h friet.h trail_diff.h trail_lin.h
DEPS = $(patsubst %,$(IDIR)/%,$(_DEPS))

_SRC = util.o friet.o trail_diff.o trail_lin.o
SRC = $(patsubst %,$(SRCDIR)/%,$(_SRC))

_MAIN = main.o
MAIN = $(patsubst %,$(SRCDIR)/%,$(_MAIN))

$(ODIR)/%.o: %.c $(DEPS)
	$(CC) -c -o $@ $< $(CFLAGS)

all: $(MAIN) $(SRC)
	$(CC) -o main $^ $(CFLAGS) $(LIBS)

.PHONY: clean

clean:
	rm -f $(SRCDIR)/*.o *~ *.exe