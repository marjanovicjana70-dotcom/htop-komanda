#!/bin/bash
ALL_CPUS=()
CURR=()
PREV=()


BAR_LEN=30
BAR_CHAR='|'
EMPTY=' '

if [[ -z "$NO_COLOR" ]]; then

    COLOR1=$'\e[31m'
	COLOR2=$'\e[35m'
	COLOR3=$'\e[36m'
	DIM=$'\e[2m'
	RST=$'\e[0m'

else 

    COLOR1=
	COLOR2=
	COLOR3=
	DIM=
	RST=


fi

function curr_to_prev(){
PREV=()

local key val 
for key in "${!CURR[@]}";
do
val="${CURR[$key]}"
PREV[$key]="$val"

done


}

function proc_info(){
local key user nice system idle iowait
local irq softirq steal guest guest_nice

CURR=()

for key in "${ALL_CPUS[@]}";
do

CURR[key]=

done

local cpu_number time_busy time_idle value

while read -r key user nice system idle iowait irq softirq steal guest guest_nice; do

if [[ "$key" != cpu* ]];
then

continue

elif [[ "$key" == 'cpu' ]];
then

continue

fi  



cpu_number="${key#cpu}"

time_busy=$((user + nice + system + irq + softirq + steal + guest + guest_nice))
time_idle=$((idle + iowait))

value="$time_busy $time_idle"

CURR[$cpu_number]="$value"

done < /proc/stat



}


function print_bar(){

local key=$1

local busy1 idle1 busy2 idle2 

read -r busy1 idle1 <<< "${PREV[$key]}"
read -r busy2 idle2 <<< "${CURR[$key]}"


local usage active

if [[ -z $busy1 || -z $busy2 ]];
then

usage=0
online=

else

local busySub=$(( busy2 - busy1 ))
local idleSub=$(( idle2 - idle1 ))
local total=$((busySub + idleSub))


usage=$(( 1000 * busySub / total))

online=1

fi


local int=$((usage / 10))
local frac=$((usage % 10))

local perc=$int.$frac

local bars=$((usage * BAR_LEN / 1000))


local i 
local s='['

for ((i = 0; i < bars; i++));
do

s+=$COLOR1$BAR_CHAR$RST

done

for ((i=bars; i<BAR_LEN; i++));
do

s+=$EMPTY

done

s+=']'

local state
if [[ -n $online ]];
then

printf -v perc '%-7s' "$perc%"
		state=$COLOR3$perc$RST


else 

state=${DIM}offline$RST

fi


echo "$s ${COLOR2}cpu$key$RST $state"

}



function visualize(){

echo "${DIM}CPU Usage on $COLOR3$HOSTNAME$RST"

local key
for key in "${!CURR[@]}";
do

print_bar "$key"

done
local now
printf -v now '%(%Y-%m-%dT%H:%M:%S%z)T'
echo "$DIM$now$RST"


}

function refresh(){

printf '\e[?1049l' 
printf '\e[?25h'

}

function updatews(){

COLUMNS=${COLUMNS:-80}

local all_cpus=("${!CURR[@]}")
local highest="${all_cpus[-1]}"

local i=$((2 + 4 + ${#highest} + 8))
	BAR_LEN=$((COLUMNS - i))

}

function cpu_count(){
    ALL_CPUS=(/sys/devices/virtual/cpuid/cpu[0-9]*)
    ALL_CPUS=("${ALL_CPUS[@]##*/cpu}")
}



function main(){

shopt -s checkwinsize


cpu_count
proc_info
echo "waiting.."
sleep 1


trap refresh EXIT
trap updatews WINCH

printf '\e[?1049h' 
printf '\e[?25l' 
printf '\e[H' 

updatews  

while true;
do

curr_to_prev
proc_info

printf "\e[H"

visualize

sleep 1

done


}


main "$@"