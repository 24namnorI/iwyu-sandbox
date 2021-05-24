all: main

BODIES=$(shell find -type f \( -name '*.[Cc]' -o -name '*.[Cc]pp' -o -name '*.ut' \) )
SOURCES=$(shell find -type f \( -name '*.[CcHh]' -o -name '*.[CcHhTt]pp' -o -name '*.ut' \) )
OBJECTS=$(BODIES:.C=.o)
INCLUDES=  -I/usr/include
INCLUDES+= -I/usr/include/c++/8
INCLUDES+= -I/usr/include/c++/8/backward
INCLUDES+= -I/usr/include/x86_64-linux-gnu
INCLUDES+= -I/usr/include/x86_64-linux-gnu/c++/8
INCLUDES+= -I/usr/include/x86_64-linux-gnu/8/include
INCLUDES+= -I/usr/include/x86_64-linux-gnu/8/include-fixed
INCLUDES+= -I/usr/local/include
INCLUDES+= -I/opt/include

.PHONY=all generate quick clean depclean distclean fix_includes
generate:

quick: main

clean:
	$(RM) main $(OBJECTS)

depclean: clean

distclean: clean
	$(RM) compile_commands.json
	$(RM) find_all_symbols_db.yaml
	$(RM) iwyu.imp

compile_commands.json: makefile distclean generate
	CPPFLAGS="-x c++" bear make quick

/tmp/iwyu: compile_commands.json
	@[ -d "$@" ] || mkdir -p $@
	$(RM) $@/*
	find-all-symbols-7 \
		$(foreach i,$(INCLUDES),-extra-arg="$(i)") \
		-extra-arg="-xc++" \
		-extra-arg="-std=c++11" \
		-output-dir=$@ \
		-p=. $(BODIES)

find_all_symbols_db.yaml: /tmp/iwyu
	cat $</* > find_all_symbols_db.yaml

iwyu.imp:
	echo '[' >> $@
	echo '{ symbol: ["std::stringstream","private","<sstream>","public"] },' >> $@
	echo ']' >> $@

iwyu: find_all_symbols_db.yaml iwyu.imp
	#iwyu -Xiwyu --no_default_mappings -Xiwyu --verbose=2 $(BODIES)
	#iwyu_tool -p . -- --no_default_mappings --verbose=2 #| fix_include --comments --nosafe_headers
	iwyu_tool -p . -- --mapping_file=iwyu.imp --verbose=1 | fix_include --comments

%.o: %.C
	clang++ -std=c++11 $(INCLUDES) -c -o $@ $^

main: $(OBJECTS)
	clang++ -o main $^
	./main

# vi: ft=makefile ts=3 :
