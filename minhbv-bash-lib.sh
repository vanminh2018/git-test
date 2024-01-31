# /usr/bin/env bash
# Title:         minhbv-bash-lib
# Description:   minhbv-bash-lib
# Author:        minhbv <minhbui.ptit@gmail.com>
# Date:          2023-10-08
# Version:       1.0.0

# Usage:
# shellcheck source=/dev/null
# source "./lib/minhbv-bash-lib.sh"

# >>>>>>>>>>>>>>>>>>>>>>>> functions args_or_stdin >>>>>>>>>>>>>>>>>>>>>>>>
function args_or_stdin() {
    if [ $# -eq 0 ]; then
        # stdin
        while read -r line; do
            printf "%s" "$line"
        done
    else
        # arg
        printf "%s" "$1"
        shift
        while [ $# -gt 0 ]; do
            printf " %s" "$1"
            shift
        done
    fi
    # printf "\n"
}

# <<<<<<<<<<<<<<<<<<<<<<<< functions args_or_stdin <<<<<<<<<<<<<<<<<<<<<<<<

# >>>>>>>>>>>>>>>>>>>>>>>> functions animate >>>>>>>>>>>>>>>>>>>>>>>>
# Usage: animate framesArray interval
function animate() {
    local frames=("$@")

    ((lastIndex = ${#frames[@]} - 1))
    local mode=${frames[lastIndex]}
    unset "frames[lastIndex]"

    ((lastIndex = ${#frames[@]} - 1))
    local interval=${frames[lastIndex]}
    unset "frames[lastIndex]"

    # Comment out next two lines if you are using CTRL+C event handler.
    trap 'tput cnorm; echo' EXIT
    trap 'exit 127' HUP INT TERM

    tput civis # hide cursor
    tput sc    # save cursor position

    tput civis # hide cursor
    tput sc    # save cursor position

    index=0
    max="${#frames[@]}"
    indices=()
    direction="forward"
    readarray -t forwardIndices < <(seq 0 1 "${max}")
    readarray -t backwardIndices < <(seq "${max}" -1 0)

    while true; do
        if [ "${mode}" = "circular" ]; then
            direction="forward"
        elif [ "${mode}" = "pendular" ]; then
            if ((index >= max)); then
                direction="backward"
            elif ((index <= 0)); then
                direction="forward"
            fi
        else
            echo "Wrong mode! Valid modes: circular, pendular"
            exit 255
        fi

        if [ "${direction}" = "forward" ]; then
            indices=("${forwardIndices[@]}")
        else
            indices=("${backwardIndices[@]}")
        fi

        for index in "${indices[@]}"; do
            tput rc # restore cursor position
            echo "${frames[$index]}"
            sleep "${interval}"
        done
    done
}
# <<<<<<<<<<<<<<<<<<<<<<<< functions animate <<<<<<<<<<<<<<<<<<<<<<<<

# >>>>>>>>>>>>>>>>>>>>>>>> functions pacMan >>>>>>>>>>>>>>>>>>>>>>>>
# Usage: pacMan inputString interval pad
# Example: pacman "Hello World" 0.5 "*"
function pacMan() {
    local string="${1}"
    local interval="${2}"
    : "${interval:=0.2}"
    local pad="${3}"
    : "${pad:=.}"
    local length=${#string}
    local padding=""

    # Comment out next two lines if you are using CTRL+C event handler.
    trap 'tput cnorm; echo' EXIT
    trap 'exit 127' HUP INT TERM

    tput civis # hide cursor
    tput sc    # save cursor position

    for ((i = 0; i <= length; i++)); do
        tput rc
        echo "${padding}c${string:i:length}"
        sleep "$interval"
        tput rc
        echo "${padding}C${string:i:length}"
        sleep "${interval}"
        padding+="${pad}"
    done

    tput cnorm
    tput rc
    echo "${padding}"
}
# <<<<<<<<<<<<<<<<<<<<<<<< functions pacMan <<<<<<<<<<<<<<<<<<<<<<<<

# >>>>>>>>>>>>>>>>>>>>>>>> functions bannerColor >>>>>>>>>>>>>>>>>>>>>>>>
# Usage: bannerColor "my title" "red" "`"
function bannerColor() {
    case ${2} in
    black)
        color=0
        ;;
    red)
        color=1
        ;;
    green)
        color=2
        ;;
    yellow)
        color=3
        ;;
    blue)
        color=4
        ;;
    magenta)
        color=5
        ;;
    cyan)
        color=6
        ;;
    white)
        color=7
        ;;
    *)
        echo "color is not set"
        exit 1
        ;;
    esac

    local msg="${3} ${1} ${3}"
    local edge
    edge=${msg//?/$3}
    tput setaf ${color}
    tput bold
    echo "${edge}"
    echo "${msg}"
    echo "${edge}"
    tput sgr 0
    echo
}
# <<<<<<<<<<<<<<<<<<<<<<<< functions bannerColor <<<<<<<<<<<<<<<<<<<<<<<<

# >>>>>>>>>>>>>>>>>>>>>>>> functions bannerSimple >>>>>>>>>>>>>>>>>>>>>>>>
# Usage: bannerSimple "my title" "`"
function bannerSimple() {
    local msg="${2} ${1} ${2}"
    local edge
    edge=${msg//?/$2}
    echo "${edge}"
    echo "$(tput bold)${msg}$(tput sgr0)"
    echo "${edge}"
    echo
}
# <<<<<<<<<<<<<<<<<<<<<<<< functions bannerSimple <<<<<<<<<<<<<<<<<<<<<<<<

# >>>>>>>>>>>>>>>>>>>>>>>> functions input choice >>>>>>>>>>>>>>>>>>>>>>>>
# Usage: options=("one" "two" "three"); inputChoice "Choose:" 1 "${options[@]}"; choice=$?; echo "${options[$choice]}"
function inputChoice() {
    echo "${1}"
    shift
    echo "$(tput dim)""- Change option: [up/down], Select: [ENTER]" "$(tput sgr0)"
    local selected="${1}"
    shift

    ESC=$(echo -e "\033")
    cursor_blink_on() { tput cnorm; }
    cursor_blink_off() { tput civis; }
    cursor_to() { tput cup $(($1 - 1)); }
    print_option() { echo "$(tput sgr0)" "$1" "$(tput sgr0)"; }
    print_selected() { echo "$(tput rev)" "$1" "$(tput sgr0)"; }
    get_cursor_row() {
        IFS=';' read -rsdR -p $'\E[6n' ROW COL
        echo "${ROW#*[}"
    }
    key_input() {
        read -rs -n3 key 2>/dev/null >&2
        [[ $key = ${ESC}[A ]] && echo up
        [[ $key = ${ESC}[B ]] && echo down
        [[ $key = "" ]] && echo enter
    }

    for opt; do echo; done

    local lastrow
    lastrow=$(get_cursor_row)
    local startrow=$((lastrow - $#))
    trap "cursor_blink_on; echo; echo; exit" 2
    cursor_blink_off

    : selected:=0

    while true; do
        local idx=0
        for opt; do
            cursor_to $((startrow + idx))
            if [ ${idx} -eq "${selected}" ]; then
                print_selected "${opt}"
            else
                print_option "${opt}"
            fi
            ((idx++))
        done

        case $(key_input) in
        enter) break ;;
        up)
            ((selected--))
            [ "${selected}" -lt 0 ] && selected=$(($# - 1))
            ;;
        down)
            ((selected++))
            [ "${selected}" -ge $# ] && selected=0
            ;;
        esac
    done

    cursor_to "${lastrow}"
    cursor_blink_on
    echo

    return "${selected}"
}
# <<<<<<<<<<<<<<<<<<<<<<<< functions input choice <<<<<<<<<<<<<<<<<<<<<<<<

# >>>>>>>>>>>>>>>>>>>>>>>> functions multichoice >>>>>>>>>>>>>>>>>>>>>>>>
# Usage: multiChoice "header message" resultArray "comma separated options" "comma separated default values"
# Credit: https://serverfault.com/a/949806
function multiChoice {
    echo "${1}"
    shift
    echo "$(tput dim)""- Change Option: [up/down], Change Selection: [space], Done: [ENTER]" "$(tput sgr0)"
    # little helpers for terminal print control and key input
    ESC=$(printf "\033")
    cursor_blink_on() { printf "%s" "${ESC}[?25h"; }
    cursor_blink_off() { printf "%s" "${ESC}[?25l"; }
    cursor_to() { printf "%s" "${ESC}[$1;${2:-1}H"; }
    print_inactive() { printf "%s   %s " "$2" "$1"; }
    print_active() { printf "%s  ${ESC}[7m $1 ${ESC}[27m" "$2"; }
    get_cursor_row() {
        IFS=';' read -rsdR -p $'\E[6n' ROW COL
        echo "${ROW#*[}"
    }
    key_input() {
        local key
        IFS= read -rsn1 key 2>/dev/null >&2
        if [[ $key = "" ]]; then echo enter; fi
        if [[ $key = $'\x20' ]]; then echo space; fi
        if [[ $key = $'\x1b' ]]; then
            read -rsn2 key
            if [[ $key = [A ]]; then echo up; fi
            if [[ $key = [B ]]; then echo down; fi
        fi
    }
    toggle_option() {
        local arr_name=$1
        eval "local arr=(\"\${${arr_name}[@]}\")"
        local option=$2
        if [[ ${arr[option]} == 1 ]]; then
            arr[option]=0
        else
            arr[option]=1
        fi
        eval "$arr_name"='("${arr[@]}")'
    }

    local retval=$1
    local options
    local defaults

    IFS=';' read -r -a options <<<"$2"
    if [[ -z $3 ]]; then
        defaults=()
    else
        IFS=';' read -r -a defaults <<<"$3"
    fi

    local selected=()

    for ((i = 0; i < ${#options[@]}; i++)); do
        selected+=("${defaults[i]}")
        printf "\n"
    done

    # determine current screen position for overwriting the options
    local lastrow
    lastrow=$(get_cursor_row)
    local startrow=$((lastrow - ${#options[@]}))

    # ensure cursor and input echoing back on upon a ctrl+c during read -s
    trap "cursor_blink_on; stty echo; printf '\n'; exit" 2
    cursor_blink_off

    local active=0
    while true; do
        # print options by overwriting the last lines
        local idx=0
        for option in "${options[@]}"; do
            local prefix="[ ]"
            if [[ ${selected[idx]} == 1 ]]; then
                prefix="[x]"
            fi

            cursor_to $((startrow + idx))
            if [ $idx -eq $active ]; then
                print_active "$option" "$prefix"
            else
                print_inactive "$option" "$prefix"
            fi
            ((idx++))
        done

        # user key control
        case $(key_input) in
        space) toggle_option selected $active ;;
        enter) break ;;
        up)
            ((active--))
            if [ $active -lt 0 ]; then active=$((${#options[@]} - 1)); fi
            ;;
        down)
            ((active++))
            if [ "$active" -ge ${#options[@]} ]; then active=0; fi
            ;;
        esac
    done

    # cursor position back to normal
    cursor_to "$lastrow"
    printf "\n"
    cursor_blink_on

    indices=()
    for ((i = 0; i < ${#selected[@]}; i++)); do
        if ((selected[i] == 1)); then
            indices+=("${i}")
        fi
    done

    # eval $retval='("${selected[@]}")'
    eval "$retval"='("${indices[@]}")'
}
# <<<<<<<<<<<<<<<<<<<<<<<< functions multichoice <<<<<<<<<<<<<<<<<<<<<<<<

# >>>>>>>>>>>>>>>>>>>>>>>> functions progress >>>>>>>>>>>>>>>>>>>>>>>>
# Usage: progressBar "message" currentStep totalSteps
function progressBar() {
    local bar='████████████████████'
    local space='....................'
    local wheel=('\' '|' '/' '-')

    local msg="${1}"
    local current=${2}
    local total=${3}
    local wheelIndex=$((current % 4))
    local position=$((100 * current / total))
    local barPosition=$((position / 5))

    echo -ne "\r|${bar:0:$barPosition}$(tput dim)${space:$barPosition:20}$(tput sgr0)| ${wheel[wheelIndex]} ${position}% [ ${msg} ] "
}
# <<<<<<<<<<<<<<<<<<<<<<<< functions progress <<<<<<<<<<<<<<<<<<<<<<<<

# >>>>>>>>>>>>>>>>>>>>>>>> functions time format seconds >>>>>>>>>>>>>>>>>>>>>>>>
# Usage: formatSeconds 70 -> 1m 10s
# Credit: https://unix.stackexchange.com/a/27014
function formatSeconds {
    local T=$1
    local D=$((T / 60 / 60 / 24))
    local H=$((T / 60 / 60 % 24))
    local M=$((T / 60 % 60))
    local S=$((T % 60))
    local result=""

    ((D > 0)) && result="${D}d "
    ((H > 0)) && result="${result}${H}h "
    ((M > 0)) && result="${result}${M}m "
    ((S > 0)) && result="${result}${S}s "
    echo -e "${result}" | sed -e 's/[[:space:]]*$//'
}
# <<<<<<<<<<<<<<<<<<<<<<<< functions time format seconds <<<<<<<<<<<<<<<<<<<<<<<<

# >>>>>>>>>>>>>>>>>>>>>>>> functions urldecode >>>>>>>>>>>>>>>>>>>>>>>>
# Usage: urldecode url
# Credit: https://unix.stackexchange.com/a/187256
function urldecode() {
    local urlEncoded="${1//+/ }"
    printf '%b' "${urlEncoded//%/\\x}"
}
# <<<<<<<<<<<<<<<<<<<<<<<< functions urldecode <<<<<<<<<<<<<<<<<<<<<<<<

# >>>>>>>>>>>>>>>>>>>>>>>> functions urlencode >>>>>>>>>>>>>>>>>>>>>>>>
# Usage: urlencode url
# Credit: https://unix.stackexchange.com/a/187256
function urlencode() {
    local length="${#1}"
    for ((i = 0; i < length; i++)); do
        local c="${1:i:1}"
        case "${c}" in
        [a-zA-Z0-9.~_-]) printf "%s" "${c}" ;;
        *) printf '%%%02X' "'${c}" ;;
        esac
    done
}
# <<<<<<<<<<<<<<<<<<<<<<<< functions urlencode <<<<<<<<<<<<<<<<<<<<<<<<

# >>>>>>>>>>>>>>>>>>>>>>>> functions version compare >>>>>>>>>>>>>>>>>>>>>>>>
# Usage: versionCompare "1.2.3" "1.1.7"
function versionCompare() {
    function subVersion() {
        echo -e "${1%%"."*}"
    }
    function cutDot() {
        local offset=${#1}
        local length=${#2}
        echo -e "${2:((++offset)):length}"
    }
    if [ -z "${1}" ] || [ -z "${2}" ]; then
        echo "=" && exit 0
    fi
    local v1
    v1=$(echo -e "${1}" | tr -d '[:space:]')
    local v2
    v2=$(echo -e "${2}" | tr -d '[:space:]')
    local v1Sub
    v1Sub=$(subVersion "$v1")
    local v2Sub
    v2Sub=$(subVersion "$v2")
    if ((v1Sub > v2Sub)); then
        echo ">"
    elif ((v1Sub < v2Sub)); then
        echo "<"
    else
        versionCompare "$(cutDot "$v1Sub" "$v1")" "$(cutDot "$v2Sub" "$v2")"
    fi
}
# <<<<<<<<<<<<<<<<<<<<<<<< functions version compare <<<<<<<<<<<<<<<<<<<<<<<<

# >>>>>>>>>>>>>>>>>>>>>>>> functions STRINGS >>>>>>>>>>>>>>>>>>>>>>>>
regexString() {
    # Usage: regex "string" "regex"
    # regex '    hello' '^\s*(.*)'
    # hello
    [[ $1 =~ $2 ]] && printf '%s\n' "${BASH_REMATCH[1]}"
}

splitString() {
    # Usage: splitString "string" "delimiter"
    # splitString "apples,oranges,pears,grapes" ","
    # splitString "hello---world---my---name---is---john" "---"
    IFS=$'\n' read -d "" -ra arr <<<"${1//$2/$'\n'}"
    printf '%s\n' "${arr[@]}"
}
# <<<<<<<<<<<<<<<<<<<<<<<< functions STRINGS <<<<<<<<<<<<<<<<<<<<<<<<

# >>>>>>>>>>>>>>>>>>>>>>>> functions filename >>>>>>>>>>>>>>>>>>>>>>>>
function fullFilename() {
    printf "%s" "${1##*/}" #  parameter expansion retain after /
}

function baseFilename() {
    local filename basename
    filename="${1##*/}"       #  parameter expansion retain after /
    basename="${filename%.*}" # parameter expansion retain before .
    printf "%s" "${basename}"
}

function extensionFilename() {
    local filename extension
    filename="${1##*/}"         #  parameter expansion retain after /
    extension="${filename##*.}" # parameter expansion after .
    [[ "${filename}" = "${extension}" ]] && return 4
    printf "%s" "${extension}"
}

function pathFilename() {
    declare folderpath=${1:-.}
    folderpath=${1%/*}
    printf "%s" "${folderpath}"
}
# <<<<<<<<<<<<<<<<<<<<<<<< functions filename <<<<<<<<<<<<<<<<<<<<<<<<

# >>>>>>>>>>>>>>>>>>>>>>>> functions Run a command in the background >>>>>>>>>>>>>>>>>>>>>>>>
function runBackground() {
    # runBackground ./some_script.sh
    (nohup "$@" &>/dev/null &)
}
# <<<<<<<<<<<<<<<<<<<<<<<< functions Run a command in the background <<<<<<<<<<<<<<<<<<<<<<<<

# >>>>>>>>>>>>>>>>>>>>>>>> functions log >>>>>>>>>>>>>>>>>>>>>>>>
function log() {
    # LOG_FILENAME=
    if [[ "${LOG_FILENAME}" == "" ]]; then
        LOG_FILENAME="/dev/null"
    fi
    echo "$(date +'%Y-%m-%d %H:%M:%S %Z') $(basename "$0")[$$]: $*" &>>"${LOG_FILENAME}"
    echo "$(date +'%Y-%m-%d %H:%M:%S %Z') $(basename "$0")[$$]: $*"
}
# <<<<<<<<<<<<<<<<<<<<<<<< functions log <<<<<<<<<<<<<<<<<<<<<<<<

# >>>>>>>>>>>>>>>>>>>>>>>> functions postgres_query >>>>>>>>>>>>>>>>>>>>>>>>
function postgres_query() {
    # PGSQL_PASSWORD=
    # PGSQL_HOSTNAME=
    # PGSQL_PORT=
    # PGSQL_USERNAME=
    # PGSQL_DBNAME=
    SQL_QUERY=$*

    # -A -b -e -t -c
    # PGPASSWORD=${PGSQL_PASSWORD} psql -h "${PGSQL_HOSTNAME}" -p "${PGSQL_PORT}" \
    #     -U "${PGSQL_USERNAME}" -d "${PGSQL_DBNAME}" -A -b -t \
    #     -c "${SQL_QUERY}" 2>&1
    psql postgresql://"${PGSQL_USERNAME}":"${PGSQL_PASSWORD}"@"${PGSQL_HOSTNAME}":"${PGSQL_PORT}"/"${PGSQL_DBNAME}" \
        -A -b -t -c "${SQL_QUERY}" 2>&1
}
# <<<<<<<<<<<<<<<<<<<<<<<< functions postgres_query <<<<<<<<<<<<<<<<<<<<<<<<

# >>>>>>>>>>>>>>>>>>>>>>>> functions fs_query >>>>>>>>>>>>>>>>>>>>>>>>
function fs_query() {
    # FS_CLI_PORT=
    # FS_CLI_PASS=
    # FS_HOST=
    FS_QUERY=$*
    fs_cli -H "${FS_HOST}" -p "${FS_CLI_PASS}" -P "${FS_CLI_PORT}" -x "${FS_QUERY}"
}
# <<<<<<<<<<<<<<<<<<<<<<<< functions fs_query <<<<<<<<<<<<<<<<<<<<<<<<
