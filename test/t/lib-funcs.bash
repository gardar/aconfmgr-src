# Test case configuration functions

###############################################################################
# Test phases

function TestPhase_Setup() {
	LogLeave
	LogEnter 'Setting up test case...\n'
}

function TestPhase_Run() {
	LogLeave
	LogEnter 'Running test...\n'
}

function TestPhase_Check() {
	LogLeave
	LogEnter 'Checking results...\n'
}

function TestDone() {
	LogLeave
	test "$log_indent" == :: || FatalError 'Unbalanced log level!\n'
	LogLeave 'Test %s: %s!\n' "$(Color C "$test_name")" "$(Color G success)"
	Exit 0
}

###############################################################################
# Packages

function TestAddPackage() {
	local name=$1
	local kind=$2
	local inst_as=$3

	printf '%s\t%s\t%s\n' "$name" "$kind" "$inst_as" >> "$test_data_dir"/packages.txt
}

###############################################################################
# Files

# Helper function - create path to and write file
function TestWriteFile() {
	local fn=$1
	local data=$2

	mkdir -p "$(dirname "$fn")"
	printf "%s" "$data" > "$fn"
}

# Add a file to the virtual filesystem.
function TestAddFile() {
	local path=$1
	local contents=$2
	local mode=${3:-}
	local owner=${4:-}
	local group=${5:-}

	TestWriteFile "$test_data_dir"/files/"$path" "$contents"
	if [[ -n "$mode"  ]] ; then TestWriteFile "$test_data_dir"/file-props/"$path".mode  "$mode"  ; fi
	if [[ -n "$owner" ]] ; then TestWriteFile "$test_data_dir"/file-props/"$path".owner "$owner" ; fi
	if [[ -n "$group" ]] ; then TestWriteFile "$test_data_dir"/file-props/"$path".group "$group" ; fi
}

# Add a directory to the virtual filesystem.
function TestAddDir() {
	local path=$1
	local mode=${2:-}
	local owner=${3:-}
	local group=${4:-}

	mkdir -p "$test_data_dir"/files/"$path"
	if [[ -n "$mode"  ]] ; then TestWriteFile "$test_data_dir"/file-props/"$path".mode  "$mode"  ; fi
	if [[ -n "$owner" ]] ; then TestWriteFile "$test_data_dir"/file-props/"$path".owner "$owner" ; fi
	if [[ -n "$group" ]] ; then TestWriteFile "$test_data_dir"/file-props/"$path".group "$group" ; fi
}

# Add a symlink to the virtual filesystem.
function TestAddLink() {
	local path=$1
	local target=$2
	local owner=${3:-}
	local group=${4:-}

	local fn="$test_data_dir"/files/"$path"
	mkdir -p "$(dirname "$fn")"
	ln -s "$target" "$fn"

	if [[ -n "$owner" ]] ; then TestWriteFile "$test_data_dir"/file-props/"$path".owner "$owner" ; fi
	if [[ -n "$group" ]] ; then TestWriteFile "$test_data_dir"/file-props/"$path".group "$group" ; fi
}

function TestAddPackageFile() {
	local package=$1
	local path=$2

	printf '%s\n' "$path" >> "$test_data_dir"/package-files.txt
}

function TestAddModifiedFile() {
	local path=$1
	local package=$2
	local property=$3 # as emitted by paccheck
	local old_value=$4

	printf '%s: '\''%s'\'' %s mismatch (expected %s)\n' \
		   "$package" "$path" "$property" "$old_value" \
		   >> "$test_data_dir"/modified-files.txt
	TestAddPackageFile "$package" "$path"
}

###############################################################################
# Configuration

# Add a line to the configuration
function TestAddConfig() {
	(
		printf "%s " "$@"
		printf '\n'
	) >> "$config_dir"/50-aconfmgr-test-config.sh
}

# Verify that the generated 99-unsorted.sh configuration, stripped of
# blank and comment lines, matches stdin.
function TestExpectConfig() {
	touch "$config_dir"/99-unsorted.sh
	diff -u <(grep '^[^#]' "$config_dir"/99-unsorted.sh || true) /dev/stdin
}
