#!/bin/bash

VERSION=1.2.1
# DEFINE_SCRIPT_DIR()
# ARG_POSITIONAL_SINGLE([input],[The input template file])
# ARG_OPTIONAL_SINGLE([output],[o],[Name of the output file (pass '-' for stdout)],[-])
# ARG_OPTIONAL_BOOLEAN([standalone],[],[Whether the parsing code is in a standalone file.])
# ARG_OPTIONAL_REPEATED([search],[I],[Directories to search for the wrapped scripts (directory of the template will be added to the end of the list)],["."])
# ARG_OPTIONAL_SINGLE([debug],[],[(developer option) Tell autom4te to trace a macro])
# ARG_VERSION([echo "argbash v$VERSION"])
# ARG_HELP([Argbash is an argument parser generator for Bash.])

# ARGBASH_GO()
# needed because of Argbash --> m4_ignore([
### START OF CODE GENERATED BY ARGBASH v1.2.1 one line above ###
# Argbash is a bash code generator used to get arguments parsing right.
# Argbash is FREE SOFTWARE, know your rights: https://github.com/matejak/argbash
# THE DEFAULTS INITIALIZATION --- POSITIONALS
# THE DEFAULTS INITIALIZATION --- OPTIONALS
_ARG_OUTPUT="-"
_ARG_STANDALONE=off
_ARG_SEARCH=(".")
_ARG_DEBUG=

# THE PRINT HELP FUNCION
function print_help
{
	echo "Argbash is an argument parser generator for Bash."
	echo "Usage: $0 [--output <arg>] [--(no-)standalone] [--search] [--debug <arg>] [--version] [--help] <input>"
	echo -e "\t<input>: The input template file"
	echo -e "\t-o,--output: Name of the output file (pass '-' for stdout) (default: '"-"')"
	echo -e "\t--standalone,--no-standalone: Whether the parsing code is in a standalone file. (off by default)"
	echo -e "\t-I,--search: Directories to search for the wrapped scripts (directory of the template will be added to the end of the list) (default array: (".") )"
	echo -e "\t--debug: (developer option) Tell autom4te to trace a macro (default: '')"
	echo -e "\t-v,--version: Prints version"
	echo -e "\t-h,--help: Prints help"
}

# THE PARSING ITSELF
while test $# -gt 0
do
	_key="$1"
	case "$_key" in
		-o|--output)
			test $# -lt 2 && { echo "Missing value for the optional argument '$_key'." >&2; exit 1; }
			_ARG_OUTPUT="$2"

			shift
			;;
		--no-standalone|--standalone)
			_ARG_STANDALONE="on"

			test "${1:0:5}" = "--no-" && _ARG_STANDALONE="off"
			;;
		-I|--search)
			test $# -lt 2 && { echo "Missing value for the optional argument '$_key'." >&2; exit 1; }
			_ARG_SEARCH+=("$2")

			shift
			;;
		--debug)
			test $# -lt 2 && { echo "Missing value for the optional argument '$_key'." >&2; exit 1; }
			_ARG_DEBUG="$2"

			shift
			;;
		-v|--version)
			echo "argbash v$VERSION"
			exit 0
			;;
		-h|--help)
			print_help
			exit 0
			;;
		*)
			POSITIONALS+=("$1")
			;;
	esac
	shift
done

POSITIONAL_NAMES=('_ARG_INPUT' )
test ${#POSITIONALS[@]} -lt 1 && { ( echo "FATAL ERROR: Not enough positional arguments --- we require exactly 1, but got only ${#POSITIONALS[@]}."; print_help ) >&2; exit 1; }
test ${#POSITIONALS[@]} -gt 1 && { ( echo "FATAL ERROR: There were spurious positional arguments --- we expect exactly 1, but got ${#POSITIONALS[@]} (the last one was: '${POSITIONALS[@]: -1}')."; print_help ) >&2; exit 1; }
for (( ii = 0; ii < ${#POSITIONALS[@]}; ii++))
do
	eval "${POSITIONAL_NAMES[$ii]}=\"${POSITIONALS[$ii]}\"" || { echo "Error during argument parsing, possibly an Argbash bug." >&2; exit 1; }
done

# OTHER STUFF GENERATED BY Argbash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

### END OF CODE GENERATED BY Argbash (sortof) ### ])
# [ <-- needed because of Argbash

#

# MS Windows compatibility fix
DISCARD=/dev/null
test -e $DISCARD || DISCARD=NUL

set -o pipefail

INFILE="$_ARG_INPUT"

M4DIR="$SCRIPT_DIR/../src"
test -n "$_ARG_DEBUG" && DEBUG="-t $_ARG_DEBUG"

OUTPUT_M4="$M4DIR/output.m4"
test "$_ARG_STANDALONE" = "on" && OUTPUT_M4="$M4DIR/output-standalone.m4"

function do_stuff
{
	echo "$WRAPPED_DEFNS" \
		| cat - "$M4DIR/stuff.m4" "$OUTPUT_M4" "$INFILE" \
		| autom4te $DEBUG -l m4sugar -I "$M4DIR" \
		| grep -v '^#\s*needed because of Argbash -->\s*$' \
		| grep -v '^#\s*<-- needed because of Argbash\s*$'
	_ret=$?
	if test $_ret != 0
	then
		echo "Error during autom4te run, aborting!" >&2;
		exit $_ret;
	fi
}

test -f "$INFILE" || { echo "'$INFILE' is supposed to be a file!"; exit 1; }
test -n "$_ARG_OUTPUT" || { echo "The output can't be blank - it is not a legal filename!"; exit 1; }
OUTFILE="$_ARG_OUTPUT"
autom4te --version > $DISCARD 2>&1 || { echo "You need the 'autom4te' utility (it comes with 'autoconf'), if you have bash, that one is an easy one to get." 2>&1; exit 1; }
SEARCHDIRS=("." "$(dirname "$INFILE")")
_ARG_SEARCH+=("$(dirname "$INFILE")")
WRAPPED_DEFNS=""

function settle_wrapped_fname
{
	# Get arguments to ARGBASH_WRAP
	_srcfiles="$(echo 'm4_changecom()m4_define([ARGBASH_WRAP])' $(cat "$INFILE") \
			| autom4te -l m4sugar -t 'ARGBASH_WRAP:$1')"

	test -n "$_srcfiles" || return
	# We should use an newline IFS just for this for. Or use an array.
	for srcstem in $_srcfiles
	do
		_found=no
		for searchdir in ${_ARG_SEARCH[@]}
		do
			test -f $searchdir/$srcstem.m4 && { _found=yes; ext=m4; break; }
			test -f $searchdir/$srcstem.sh && { _found=yes; ext=sh; break; }
		done
		# The last searchdir is a correct one
		test $_found = yes || { echo "Couldn't find wrapped file of stem '$srcstem' in any of dirrectories: ${_ARG_SEARCH[@]}" >&2; exit 2; }
		WRAPPED_DEFNS="${WRAPPED_DEFNS}m4_define([_SCRIPT_$srcstem], [[$searchdir/$srcstem.$ext]])"
	done
}

function get_parsing_code
{
	# Get the argument of INCLUDE_PARSING_CODE
	_srcfile="$(echo 'm4_changecom()m4_define([INCLUDE_PARSING_CODE])' $(cat "$INFILE") \
			| autom4te -l m4sugar -t 'INCLUDE_PARSING_CODE:$1' \
			| tail -n 1)"
	test -n "$_srcfile" || return 1
	_thatfile="$(dirname "$INFILE")/$_srcfile"
	test -f "$_thatfile" && echo $_thatfile && return
	# Take out everything after last dot (http://stackoverflow.com/questions/125281/how-do-i-remove-the-file-suffix-and-path-portion-from-a-path-string-in-bash)
	_thatfile="${_thatfile%.*}.m4"
	test -f "$_thatfile" && echo $_thatfile && return
	# if we are here, we are out of luck
	test -n "$_srcfile" && echo "Strange, we think that there was a source file '$_srcfile' that should be included, but we haven't found it in directory '$(dirname "$_thatfile")'" >&2 && return 1
}

# So let's settle the parsing code first. Hopefully we won't create a loop.
parsing_code="$(get_parsing_code)"
# Just if the original was m4, we replace .m4 with .sh
test -n "$parsing_code" && parsing_code_out="${parsing_code:0:-2}sh"
test "$_ARG_STANDALONE" = off && test -n "$parsing_code" && ($0 --standalone "$parsing_code" -o "$parsing_code_out")

# We may use some of the wrapping stuff, so let's fill the WRAPPED_DEFNS
settle_wrapped_fname

if test "$OUTFILE" = '-'
then
	do_stuff
else
	# vvv This should catch most of the cases when we want to overwrite the source file
	# vvv and we don't want to leave a file (not even an empty one) when something goes wrong.
	TEMP_OUTFILE=temp_$$
	trap "rm -f $TEMP_OUTFILE" EXIT
	do_stuff > "$TEMP_OUTFILE"
	mv "$TEMP_OUTFILE" "$OUTFILE"
	chmod a+x "$OUTFILE"
fi

# # ] <-- needed because of Argbash
