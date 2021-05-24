#!/bin/bash -x

COMPDB="compile_commands.json"
SYMDB="find_all_symbols_db.yaml"
MAPFILE="iwyu.imp"
SYMTMP="/tmp/iwyu/"

function allSources() {
	find -type f \( -name '*.[Cch]' -o -name '*.[cht]pp' -o -name '*.ut' \) -a \( ! -name '*.pb.*' \)
}

function allBodies() {
	find -type f \( -name '*.[Cc]' -o -name '*.[c]pp' \) -a \( ! -name '*.pb.*' \)
}

function allIncludes() { # [prefix]
	local pfx=${1}
	find -type d -name include | while read d ; do
		echo "-I${d}" | sed -e "s#^#${pfx}#"
	done
	sed -e "s#^#${pfx}#" <<- EOF
		-I../../include
		-I/opt/include
		-I/usr/include
		-I/usr/include/c++/8
		-I/usr/include/c++/8/backward
		-I/usr/include/x86_64-linux-gnu
		-I/usr/include/x86_64-linux-gnu/c++/8
		-I/usr/include/x86_64-linux-gnu/8/include
		-I/usr/include/x86_64-linux-gnu/8/include-fixed
		-I/usr/local/include
	EOF
}

function mustMake() { # target [dependency...]
	local target=${1}; shift
	local dependencies="$@"
	[ -f "${target}" ] || return 0
	for source in ${dependencies} ; do
		[ -f "${source}" ] || return 1 
		[ "${target}" -nt "${source}" ] || return 0
	done
	return 1
}

function remakeMapping() {
	mustMake ${MAPFILE} || return
	cat > ${MAPFILE} <<-EOF
		[
			{ symbol: ["std::stringstream","private","<sstream>","public"]  },
		]
	EOF
}

function remakeCompileDB() {
	mustMake ${COMPDB} || return
	make distclean
	make generate
	CPPFLAGS="-xc++ -std=c++11" bear make quick >/dev/null 2>&1
}

function remakeSymbolsDB() {
	remakeMapping
	remakeCompileDB
	mustMake ${SYMDB} ${COMPDB} || return
	rm -rf ${SYMTMP} ; mkdir ${SYMTMP}
	find-all-symbols-7 $(allIncludes -extra-arg=) -output-dir=${SYMTMP} -p=. $(allBodies)
	cat ${SYMTMP}/* > find_all_symbols_db.yaml
	rm -rf ${SYMTMP}
}

remakeMapping
remakeSymbolsDB
iwyu_tool -p . -- --mapping_file=iwyu.imp | fix_include --comments --noblank_lines --nosafe_headers

# vi: ft=sh ts=3 :
