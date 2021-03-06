#!/bin/bash

#===============================================================================
# Magic Script Compiler 1.0
# Copyright (c) 2016, Deepera Co., Ltd
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
# 
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
# 
# * Neither the name of deepfox nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#===============================================================================

#M=============================================================================S
# MAGIC-SCRIPT source codes
#M=============================================================================S
__initialize__() {
    prog=${1:-$0}

    MS_WORK_DIR=$PWD
    MS_PROG_DIR=$(dirname $prog)
    MS_PROG=$(basename $prog)

    case "$MS_PROG" in
    *.sh)
        MS_NS=${MS_PROG%.sh}
        MS_COMPILED="no"
        ;;
    *)
        MS_NS=$MS_PROG
        MS_COMPILED="yes"
        ;;
    esac

    export MS_WORK_DIR MS_PROG_DIR MS_PROG MS_NS MS_COMPILED
}


__sub_scripts__() {
    scripts_dir=${1:-$MS_PROG_DIR/$MS_NS.d}
    if [ -d "$scripts_dir" ]; then
        cd $scripts_dir
        find -L . -type f -name "*.sh" | sort | tr '\n' ' '
        cd $OLDPWD
    fi
}


__source_all__() {
    sub_scripts=$(__sub_scripts__)
    if [ ! -z "$sub_scripts" ]; then
        for sub_script in $sub_scripts; do
            source $MS_PROG_DIR/$MS_NS.d/$sub_script
        done
    fi
}


__initialize_compiler__() {
    export MS_SUB_SCRIPTS=$(__sub_scripts__)
    export MS_MAGIC_SPLIT_LINE=$(printf "#M%77sS" | tr ' ' '=')
    export MS_MAGIC_LEADING="# Compiled by MAGIC-SCRIPT from source:"
    export MS_MAGIC_PATTERN="[#] Compiled by MAGIC-SCRIPT from source: *.sh"
}


__expand__() {
    script=$1
    printf "$MS_MAGIC_SPLIT_LINE\n"
    printf "$MS_MAGIC_LEADING ${script#./}\n"
    printf "$MS_MAGIC_SPLIT_LINE\n"
    cat $MS_PROG_DIR/$MS_NS.d/$script
    printf "$MS_MAGIC_SPLIT_LINE\n"
}


__make__() {
    if [ "$MS_COMPILED" == "yes" ]; then
        >&2 echo "ERROR: Cannot make $MS_PROG_DIR/$MS_PROG."
        exit 127
    fi

    tmp_file=$(TMPDIR=$MS_WORK_DIR; mktemp -t __tmp_make_${MS_NS}.XXXXX)

    while IFS='' read -r line; do
        case "$line" in
        "__main__ \"\$@\"")
            for sub_script in $MS_SUB_SCRIPTS; do
                >>$tmp_file printf "%s\n\n\n" "$(__expand__ $sub_script)"
            done
            printf "%s\n" "$line" >>$tmp_file
            ;;
        *)
            printf "%s\n" "$line" >>$tmp_file
        esac
    done <$MS_PROG_DIR/$MS_PROG

    chmod +x $tmp_file

    if [ -e "$MS_WORK_DIR/$MS_NS" ]; then
        >&2 printf "WARNING: The compiled script is named as "
        >&2 printf "'$(basename $tmp_file)' because '$MS_NS' already exists.\n"
    else
        mv $tmp_file $MS_WORK_DIR/$MS_NS
    fi
}


__unmake__() {
    if [ "$MS_COMPILED" == "no" ]; then
        >&2 echo "ERROR: Cannot unmake $MS_PROG."
        exit 127
    fi

    tmp_dir=$(TMPDIR=$MS_WORK_DIR; mktemp -d -t __tmp_unmake_${MS_NS}.XXXXX)
    mkdir $tmp_dir/$MS_NS.d
    touch $tmp_dir/$MS_NS.sh
    main_buffer=$tmp_dir/__main_buffer
    magic_block_buffer=$tmp_dir/__magic_block_buffer

    parse_state="before_magic_blocks"
    while IFS='' read -r line; do
        # >&2 printf "[%24s] %s\n" "$parse_state" "$line"
        case "$parse_state" in
        before_magic_blocks)
            case "$line" in
            $MS_MAGIC_PATTERN)
                size=$(wc -c <$main_buffer)
                size_tail=$(tail -n1 $main_buffer | wc -c)
                size=$(expr $size "-" $size_tail)
                dd if=$main_buffer of=$tmp_dir/$MS_NS.sh bs=1 count=$size \
                    >/dev/null 2>&1
                >>$tmp_dir/$MS_NS.sh printf '__main__ "$@"\n'

                parse_state="entering_a_magic_block"
                sub_script=${line#$MS_MAGIC_LEADING }
                ;;
            __main__\ \"\$@\")
                >>$main_buffer printf '__main__ "$@"\n'
                mv $main_buffer $tmp_dir/$MS_NS.sh
                # We stop here because it is supposed to be the last line.
                break
                ;;
            *)
                >>$main_buffer printf "%s\n" "$line"
                ;;
            esac
            ;;
        entering_a_magic_block)
            case "$line" in
            $MS_MAGIC_SPLIT_LINE)
                parse_state="inside_a_magic_block"
                touch $magic_block_buffer
                ;;
            *)
                >&2 printf "ERROR: parse error around line:\n%s\n" "$line"
                ;;
            esac
            ;;
        inside_a_magic_block)
            case "$line" in
            $MS_MAGIC_SPLIT_LINE)
                sub_script_dir=$(dirname $sub_script)
                mkdir -p $tmp_dir/$MS_NS.d/$sub_script_dir
                mv $magic_block_buffer $tmp_dir/$MS_NS.d/$sub_script
                parse_state="between_magic_blocks"
                ;;
            *)
                >>$magic_block_buffer printf "%s\n" "$line"
                ;;
            esac
            ;;
        between_magic_blocks)
            case "$line" in
            $MS_MAGIC_PATTERN)
                parse_state="entering_a_magic_block"
                sub_script=${line#$MS_MAGIC_LEADING }
                ;;
            __main__\ \"\$@\")
                rm -f $main_buffer $magic_block_buffer
                # We stop here because it is supposed to be the last line.
                break
                ;;
            *)
                ;;
            esac
            ;;
        esac
    done <$MS_PROG_DIR/$MS_PROG

    chmod +x $tmp_dir/$MS_NS.sh

    if [ -e "$MS_WORK_DIR/$MS_NS.sh" ] | [ -e "$MS_WORK_DIR/$MS_NS.d" ]; then
        >&2 printf "WARNING: The uncompiled script and sub-scripts "
        >&2 printf "are placed under '$tmp_dir' because "
        >&2 printf "'$MS_NS.sh' or '$MS_NS.d' already exists.\n"
    else
        mv $tmp_dir/$MS_NS.sh $MS_WORK_DIR/$MS_NS.sh
        mv $tmp_dir/$MS_NS.d $MS_WORK_DIR/$MS_NS.d
        rm -rf $tmp_dir
    fi
}


__check_diff__() {
    file1=$1
    file2=$2
    printf "Checking if %s == %s... " "$file1" "$file2"
    diff "$file1" "$file2" >/dev/null 2>&1
    if [ "$?" == "0" ]; then
        printf "ok\n"
    else
        printf "FAILED\n"
    fi
}


__test__() {
    # Save context.
    orig_work_dir=$MS_WORK_DIR

    # Switch to a new context for testing.
    test_dir=$(TMPDIR=$MS_WORK_DIR; mktemp -d -t test_${MS_NS}.XXXXX)
    cp $MS_PROG_DIR/$MS_PROG $test_dir/$MS_PROG
    if [ "$MS_COMPILED" == "no" ] && [ -d "$MS_PROG_DIR/$MS_NS.d" ]; then
        cp -r $MS_PROG_DIR/$MS_NS.d $test_dir/$MS_NS.d
    fi
    cd $test_dir;
    __initialize__ $test_dir/$MS_PROG
    __initialize_compiler__

    test_dir_rel=${test_dir/#$orig_work_dir/"."}
    printf "$MS_MAGIC_SPLIT_LINE\n"
    printf "The working directory of this test is $test_dir_rel.\n\n"
    if [ "$MS_COMPILED" == "yes" ]; then
        printf "Unmaking ./$MS_NS to ./$MS_NS.sh... "
        ./$MS_NS __unmake__ >/dev/null
        printf "done\n"

        printf "Renaming the original file to ./$MS_NS.orig... "
        mv ./$MS_NS ./$MS_NS.orig
        printf "done\n"

        printf "Making ./$MS_NS.sh to ./$MS_NS... "
        ./$MS_NS.sh __make__ >/dev/null
        printf "done\n"

        __check_diff__ "$MS_NS" "$MS_NS.orig"
    elif [ "$MS_COMPILED" == "no" ]; then
        printf "Making ./$MS_NS.sh and ./$MS_NS.d to ./$MS_NS... "
        ./$MS_NS.sh __make__ >/dev/null
        printf "done\n"

        printf "Renaming the original files to "
        printf "./$MS_NS.sh.orig and ./$MS_NS.d.orig... "
        mv $MS_NS.sh $MS_NS.sh.orig
        mv $MS_NS.d $MS_NS.d.orig
        printf "done\n"

        printf "Unmaking $MS_NS to $MS_NS.sh and $MS_NS.d... "
        ./$MS_NS __unmake__ >/dev/null
        printf "done\n"

        __check_diff__ "$MS_NS.sh" "$MS_NS.sh.orig"
        for sub_script in $(__sub_scripts__ $MS_NS.d); do
            sub_script=${sub_script#./}
            __check_diff__ "$MS_NS.d/$sub_script" "$MS_NS.d.orig/$sub_script"
        done
    else
        >&2 echo "ERROR: Unknown error."
    fi

    clean=${1:-"clean"}
    case $clean in
    noclean)
        printf "\nWARNING: The test directory $test_dir_rel was not removed.\n"
        ;;
    *)
        printf "\nRemoving $test_dir_rel... "
        rm -rf $test_dir
        printf "done\n"
        ;;
    esac

    printf "$MS_MAGIC_SPLIT_LINE\n"

    # Restore context.
    cd $orig_work_dir
    __initialize__
    __initialize_compiler__
}


__main__() {
    export MS_ARGV="$*"

    __initialize__

    case "$1" in
    __make__ | __unmake__ | __test__)
        __initialize_compiler__
        func=$1; shift
        $func "$@"
        ;;
    *)
        if [ "$MS_COMPILED" == "no" ]; then
            __source_all__
        fi
        main "$@"
        ;;
    esac
}
#M=============================================================================S


#M=============================================================================S
# Compiled by MAGIC-SCRIPT from source: .ms.d/aloha.sh
#M=============================================================================S
#!/bin/bash


#-------------------------------------------------------------------------------
# Global settings and variables
#-------------------------------------------------------------------------------
# Disable debug mode by default
MS_DEBUG=${MS_DEBUG:-"no"}

# Error codes
MS_EC_FAILED=1
MS_EC_WRONG_ARGS=127
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# Core utiity functions
#-------------------------------------------------------------------------------
ms_debug() {
    test "$MS_DEBUG" == "yes"
}


ms_debug_info() {
    local info=$(echo "$*" | tr "\n" " ")
    if ms_debug; then
        >&2 printf "[%s] DEBUG: %s: %s\n" \
            "$(date +%FT%T%z)" "${FUNCNAME[1]}" "$*"
    fi
}


ms_output_block() {
    local type=$1

    local SPLIT_LINE=$(printf "#%79s" | tr ' ' '-')
    case $type in
    begin)
        local title="$2"
        printf "$SPLIT_LINE\n"
        if [ "$title" != "" ]; then
            printf "$title\n\n"
        fi
        ;;
    end)
        printf "$SPLIT_LINE\n"
        ;;
    *)
        >&2 printf "ERROR: Internal error.\n"
        exit $MS_EC_WRONG_ARGS
        ;;
    esac
}


ms_print_trace_stack() {
    local stack_size=${#FUNCNAME[@]}

    ms_output_block begin "Trace stack:"
    for (( i=1; i<$(expr $stack_size "-" 2); i++ )); do
        local func="${FUNCNAME[$i]}"
        local lineno="${BASH_LINENO[$(( i - 1 ))]}"
        local src="${BASH_SOURCE[$i]}"
        printf "%-20s at line %-5s in %-30s\n" $func $lineno $src
    done
    ms_output_block end
}


ms_die() {
    local message=${1:-"Unknown error."}
    local exit_code=${2:-$MS_EC_FAILED}
    local trace=${3:-$trace_default}

    >&2 printf "ERROR: $message\n"

    if ms_debug; then
        >&2 ms_print_trace_stack
    fi

    exit $exit_code
}


ms_assert() {
    "$@" >/dev/null 2>&1
    local exit_code="$?"
    if [ "$exit_code" != "0" ]; then
        ms_die "$(printf "Assertion '%s' failed." "$*")"
    fi
}


ms_print_usage() {
    local prog=""
    if [ "$1" == "-p" ]; then
        prog="$2"
        shift 2
    else
        prog=${FUNCNAME[1]}
    fi

    local argv=("$@")
    local usage="${argv[0]}"
    local die="${argv[1]}"

    case $die in
    "" | live | and_live | continue | and_continue)
        printf "Usage: %s %s\n" "$prog" "$usage"
        ;;
    die | die | and_die | exit | and_exit)
        printf "Usage: %s %s\n" "$prog" "$usage"
        local exit_code=${3:-$MS_EC_WRONG_ARGS}
        ms_die "Wrong arguments." $exit_code
        ;;
    *)
        printf "Usage: ${FUNCNAME[0]} ARGS_SPECS [live|die EXIT_CODE]\n"
        ms_die "Wrong arguments." $MS_EC_WRONG_ARGS
        ;;
    esac
}


ms_trap() {
    local handler="$1"; shift

    if [ "${handler#*\'}" != "$handler" ]; then
        ms_die "Does not support character ' in signal handler."
    fi

    for signal in "$@"; do
        local old_handler=$(echo $(trap -p $signal) | sed "s/.*'\(.*\)'.*/\1/g")
        local new_handler="$handler"
        if [ ! -z "$old_handler" ]; then
            new_handler="$new_handler; $old_handler"
        fi
        trap "$new_handler" $signal
    done
}


ms_datetime() {
    local fmt=$1
    case $fmt in
    "" | iso)
        date +%FT%T%z
        ;;
    simple)
        date +%Y%m%d%H%M%S
        ;;
    date)
        date +%Y-%m-%d
        ;;
    time)
        date +%H:%M:%S
        ;;
    *)
        ms_print_usage "[iso|simple|date|time]" die
        ;;
    esac
}


ms_import() {
    if [ $# -eq 0 ]; then
        ms_print_usage "LIB_NAME1 [LIB_NAME2 LIB_NAME3...]" die
    elif [ $# -gt 1 ]; then
        for library in "$@"; do
            ms_import $library
        done
    else
        local library=$1
        eval "local imported=\${__MS_IMPORTED_${library}__}"
        if [ "$imported" == "yes" ]; then return; fi
    
        ms_${library}_import
        if [ "$?" != "0" ]; then
            ms_die "Importing library $library failed."
        fi
        eval "export __MS_IMPORTED_\${library}__=yes"
    
        if ms_debug; then
            ms_debug_info "Imported library $library."
        fi
    fi
}
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# Import function
#-------------------------------------------------------------------------------
ms_aloha_import() {
    ms_trap 'kill -9 -$$' INT

    export MS_TMP_DIR=$(mktemp -d -t ms.XXXXX)
    ms_trap "rm -rf \$MS_TMP_DIR" EXIT
}
#-------------------------------------------------------------------------------
#M=============================================================================S


#M=============================================================================S
# Compiled by MAGIC-SCRIPT from source: .ms.d/log.sh
#M=============================================================================S
#!/bin/bash


#-------------------------------------------------------------------------------
# Logging library functions
#-------------------------------------------------------------------------------
_ms_random_filename() {
    local prefix=$1
    printf "$prefix%s%06d" $(ms_datetime simple) $RANDOM
}

ms_log_setup() {
    local log_file="${1:-"/dev/null"}"
    MS_LOG_OUTPUT=$log_file
    ms_debug_info "Output log to $MS_LOG_OUTPUT."
}


_ms_log_log() {
    local level="$1"; shift
    >>$MS_LOG_OUTPUT printf "[%s] %-5s: %s: %s\n" \
        "$(ms_datetime iso)" "$level" "${FUNCNAME[2]}" "$*"
}


ms_log_info() {
    _ms_log_log "INFO" $*
}


ms_log_warn() {
    _ms_log_log "WARN" $*
}


ms_log_assign() {
    local name="$1"
    local value="$2"
    eval "$name=\$value"
    ms_log_info "$name=$value"
}
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# Import function
#-------------------------------------------------------------------------------
ms_log_import() {
    ms_import aloha
    export MS_LOG_OUTPUT="/dev/stderr"
}
#-------------------------------------------------------------------------------
#M=============================================================================S


#M=============================================================================S
# Compiled by MAGIC-SCRIPT from source: .ms.d/target.sh
#M=============================================================================S
#!/bin/bash


#-------------------------------------------------------------------------------
# Target library functions
#-------------------------------------------------------------------------------
_ms_target_check() {
    local success_condition="$1"

    ms_log_info "Checking success condition: $success_condition"
    $(eval $success_condition >>$MS_LOG_OUTPUT 2>&1)
    local exit_code=$?
    if [ "$exit_code" == "0" ]; then
        ms_log_info "Success condition is TRUE."
    else
        ms_log_info "Success condition is FALSE."
    fi
    return $exit_code
}


ms_target_task_run() {
    local description="$1"
    local command="$2"
    local success_condition="$3"

    ms_log_info "Task start: $description"
    printf "%-70s " "$description"

    if [ ! -z "$success_condition" ]; then
        _ms_target_check "$success_condition"
        if [ "$?" == "0" ]; then
            printf "skip\n"
            ms_log_info "Task finish: skip"
            return 0
        fi
    fi

    ms_log_info "Executing task: $command"
    $(eval $command >>$MS_LOG_OUTPUT 2>&1)
    local exit_code="$?"
    if [ "$exit_code" == "0" ]; then
        _ms_target_check "$success_condition"
        if [ "$?" == "0" ]; then
            ms_log_info "Task finish: ok"
            printf "ok\n"
        else
            ms_log_warn "Task execution is ok but success `
                        `condition is still FALSE."
            ms_log_info "Task finish: FAILED"
            printf "FAILED\n"
            return $MS_EC_FAILED
        fi
    else
        ms_log_info "Task finish: FAILED"
        printf "FAILED\n"
    fi
    return $exit_code
}


ms_target_check() {
    local description="$1"
    local check_command="$2"

    ms_log_info "Check start: $description"
    printf "%-70s " "$description"

    _ms_target_check "$check_command"
    local exit_code="$?"
    if [ "$exit_code" == "0" ]; then
        ms_log_info "Check result: yes"
        printf "yes\n"
    else
        ms_log_info "Check result: no"
        printf "no\n"
    fi
    return $exit_code
}


ms_target_demo() {
    local tmp_path="$HOME/NOT-EXIST"

    ms_output_block begin "ms_target_demo"
    ms_target_check "Checking if directory $tmp_path exists..." \
        "stat $tmp_path"
    ms_target_task_run "Removing directory $tmp_path..." \
        "rmdir $tmp_path" "! test -e $tmp_path"
    ms_target_task_run "Creating directory $tmp_path with wrong command..." \
        "true" "test -e $tmp_path"
    ms_target_task_run "Creating directory $tmp_path..." \
        "mkdir $tmp_path" "test -e $tmp_path"
    ms_target_task_run "Creating directory $tmp_path again..." \
        "mkdir $tmp_path" "test -e $tmp_path"
    ms_target_task_run "Removing directory $tmp_path..." \
        "rmdir $tmp_path" "! test -e $tmp_path"
    ms_target_task_run "Removing directory $tmp_path again..." \
        "rmdir $tmp_path" "! test -e $tmp_path"
    ms_output_block end
}


ms_target_import() {
    ms_import log
}
#-------------------------------------------------------------------------------
#M=============================================================================S


#M=============================================================================S
# Compiled by MAGIC-SCRIPT from source: .ms.d/utility.sh
#M=============================================================================S
#!/bin/bash


#-------------------------------------------------------------------------------
# Utility library functions
#-------------------------------------------------------------------------------
_ms_declare_list() {
    local type=$1
    case $type in
    functions) # functions
        declare -F | sed 's/^declare -f //'
        ;;
    variables) # variables
        declare -x | grep "^declare -x" | sed -e "s/.* \(.*\)=.*/\1/"
        ;;
    *)
        ms_print_usage "[functions|variables]" die
        ;;
    esac
}


_ms_word_in_string() {
    local argv=("$@")
    local word="${argv[0]}"
    local string="${argv[1]}"

    for piece in $string; do
        if [ "$piece" == "$word" ]; then return 0; fi
    done
    return 1
}


ms_utility_setup() {
    local argv=("$@")
    local prog=${argv[0]}
    local prefix=${argv[1]}
    local commands=${argv[2]}

    if [ "$prefix" == "" ] | [ "$commands" == "" ]; then
        ms_print_usage "PROG PREFIX COMMANDS" die
    fi

    local utility_funcs=$(_ms_declare_list functions | sed -n "/^$prefix/p")

    if [ "$utility_funcs" == "" ]; then
        ms_debug_info "WARN : No utility function found (prefix='$prefix')."
        return
    fi

    local defined_commands=""
    for command in $commands; do
        real_command=$(echo $command | sed "s/-/_/g")
        _ms_word_in_string "${prefix}_${real_command}" "$utility_funcs"
        if [ "$?" != "0" ]; then
            ms_debug_info "WARN : Utility function ${prefix}_${real_command}" \
                          "is not defined."
        else
            defined_commands="$defined_commands $command"
        fi
        defined_commands=${defined_commands# }
    done

    export MS_UTILITY_PROG=$prog
    export MS_UTILITY_PREFIX=$prefix
    export MS_UTILITY_COMMANDS=$defined_commands
    ms_debug_info "MS_UTILITY_PROG='$MS_UTILITY_PROG'"
    ms_debug_info "MS_UTILITY_PREFIX='$MS_UTILITY_PREFIX'"
    ms_debug_info "MS_UTILITY_COMMANDS='$MS_UTILITY_COMMANDS'"
}


ms_utility_print_help() {
    printf "Usage: %s %s\n" "$MS_UTILITY_PROG" \
           "$(echo $MS_UTILITY_COMMANDS | tr ' ' '|')"
}


ms_utility_run() {
    command=$1
    real_command=$(echo $command | sed "s/-/_/g")

    if [ "$command" == "" ]; then
        >&2 ms_utility_print_help
        ms_die "No command specified." $MS_EC_WRONG_ARGS
    fi

    _ms_word_in_string "$command" "$MS_UTILITY_COMMANDS"
    if [ "$?" == "0" ]; then
        shift
        ${MS_UTILITY_PREFIX}_${real_command} "$@"
    else
        >&2 ms_utility_print_help
        ms_die "Wrong command: $command." $MS_EC_WRONG_ARGS
    fi
}
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# Import function
#-------------------------------------------------------------------------------
ms_utility_import() {
    ms_import aloha
}
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# Demo functions
#-------------------------------------------------------------------------------
ms_utility_demo_help() {
    echo "This is $FUNCNAME."
}


ms_utility_demo_foo() {
    echo "This is $FUNCNAME."
}


ms_utility_demo_bar() {
    echo "This is $FUNCNAME."
}


ms_utility_demo_foo_bar() {
    echo "This is $FUNCNAME."
}


ms_utility_demo() {
    ms_utility_setup "ms_utility_demo" "ms_utility_demo" "help foo bar foo-bar"
    ms_utility_print_help
    ms_utility_run foo
    ms_utility_run bar
    ms_utility_run foo-bar
}
#-------------------------------------------------------------------------------
#M=============================================================================S


#M=============================================================================S
# Compiled by MAGIC-SCRIPT from source: main.sh
#M=============================================================================S
#!/bin/bash


main() {
    export MS_DEBUG="yes"
    ms_import aloha log target
    ms_log_setup $MS_NS.log

#    ms_log_setup
#    ms_utility_demo
    ms_target_demo
}
#M=============================================================================S


__main__ "$@"
