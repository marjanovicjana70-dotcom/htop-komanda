#!/bin/bash

declare -a ALL_CPUS
declare -a PREV
declare -a CURR

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
for "$key" in "${!CURR[@]}";
do
val="${CURR[$key]}"
PREV[$key]="$val"

done


}

function proc_info(){
local key user nice system idle iowait
local irq softirq steal guest guest_nice

CURR=()

for "$key" in "${ALL_CPUS[@]}";
do

CURR[$key]=

done

while read -r key user nice system idle iowait \ irq softirq guest guest_nice;
do

if [[ "$key" != "cpu*" ]];
then

continue

elif [[ "$key" == "cpu" ]];
then

continue

fi  





done < /proc/stat



}

function cpu_count(){

ALL_CPUS=(/sys/devices/virtual/cpuid/cpu[0-9]*)
ALL_CPUS=("${ALL_CPUS[@]##*/cpu}")



}


function main(){


curr_to_prev
proc_info


}


#main "$@"