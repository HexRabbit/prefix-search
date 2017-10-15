TESTS = \
    test_cpy \
    test_ref

RAND_TEXT = bad_input.txt match_input.txt

CFLAGS = -Wall -g -Werror

# Control the build verbosity                                                   
ifeq ("$(VERBOSE)","1")
    Q :=
    VECHO = @true
else
    Q := @
    VECHO = @printf
endif

GIT_HOOKS := .git/hooks/applied

.PHONY: all clean bench

all: $(GIT_HOOKS) $(TESTS)

$(GIT_HOOKS):
	@scripts/install-git-hooks
	@echo

OBJS_LIB = \
    tst.o

OBJS := \
    $(OBJS_LIB) \
    test_cpy.o \
    test_ref.o

deps := $(OBJS:%.o=.%.o.d)

test_%: test_%.o $(OBJS_LIB)
	$(VECHO) "  LD\t$@\n"
	$(Q)$(CC) $(LDFLAGS) -o $@ $^

%.o: %.c
	$(VECHO) "  CC\t$@\n"
	$(Q)$(CC) -o $@ $(CFLAGS) -c -MMD -MF .$@.d $<

clean:
	$(RM) $(TESTS) $(OBJS)
	$(RM) $(deps)
	$(RM) *.txt

bench: $(TESTS) 
	-rm output.txt
	./generate_input.py 10000
	for method in $(TESTS);\
	do \
		echo "match" >> output.txt; \
		./$$method < match_input.txt > /dev/null; \
		echo "bad" >> output.txt; \
		./$$method < bad_input.txt > /dev/null; \
	done

perf_test: $(TESTS)
	for method in $(TESTS);\
	do \
		perf stat -cache-misses,cache-references,branch-misses,branches,instructions,cycles ./$$method < match_input.txt > /dev/null; \
		perf stat -cache-misses,cache-references,branch-misses,branches,instructions,cycles ./$$method < bad_input.txt > /dev/null; \
	done


-include $(deps)
