echo ">>Number of Processes:"
read proc
echo ">>Burst Times:"
read -a burst
echo -e "\nCPU Scheduling options:
1. Shortest Job First
2. Round Robin\n"

echo ">>Chosen option:"
read opt


SJF () {
echo "----"

ww=0
wait+=( "0" )
for((i=0;i<$proc;i++))
do
tempburst+=("${burst[i]}")
done
for((i=0;i<$proc;i++))
do
pnum+=("$i")
done
#############################################


for((i=0;i<$proc;i++))
do
for((j=0;j<$(($proc-1));j++))
do
if [ ${burst[j]} -gt  ${burst[j+1]} ]
then

tep=${burst[j]} 
burst[j]=${burst[j+1]}
burst[j+1]=$tep

tp=${pnum[j]} 
pnum[j]=${pnum[j+1]}
pnum[j+1]=$tp

fi
done
done
ww=${burst[0]}
time=0
for((k=1;k<$proc;k++))
do
lo=$(($k-1))
time=$(($time+${burst[lo]}))


for((i=$(($k+0));i<$proc;i++))
do
for((j=$(($k+0));j<$(($proc-1));j++))
do
if [ ${burst[j]} -gt  ${burst[j+1]} ]
then

tep=${burst[j]} 
burst[j]=${burst[j+1]}
burst[j+1]=$tep

tp=${pnum[j]} 
pnum[j]=${pnum[j+1]}
pnum[j+1]=$tp

fi
done
done


mm=$(($ww-0))
if [ $mm -lt 0 ]
then
mm=0
fi
wait+=( "$mm" )
ww=$(($ww+${burst[k]}))
done

#####Output
echo -n -e "\nScheduling order: "
for((i=0;i<$proc;i++))
do
echo -n "P"$((${pnum[i]}+1))" "
done
##echo ${pnum[*]}

echo -e "\n\nStart time for each process: "${wait[*]}"\n"

echo -n "Average wait time: "
sum=0
for((i=0;i<$proc;i++))
do
sum=$(($sum+${wait[i]}))
done
avg=$(($sum/$proc))
echo -n -e $avg"\n\n"

for((i=0;i<$proc;i++))
do
mw=$((${burst[i]}+${wait[i]}))
turn+=( "$mw" )
done

echo "Turnaround: "${turn[*]}
}


RR () {
echo ">>Quantum:"
read Q
echo "----"

iburst=(${burst[*]})
queue=(0)
order=()
processed=0
i=0

while true
do
if [[ ${iburst[i]} -ge  $Q ]]
then
iburst[i]=$((${iburst[i]}-$Q))
queue[${#queue[@]}]=$((${queue[-1]}+$Q))
order[${#order[@]}]=$(($i+1))
if [[ ${iburst[i]} -eq  0 ]]
then
processed=$((processed+1))
fi

elif [[ ${iburst[i]} -ne  0 ]]
then
queue[${#queue[@]}]=$((${queue[-1]}+${iburst[i]}))
iburst[i]=0
processed=$((processed+1))
order[${#order[@]}]=$(($i+1))
fi

if [[ processed -eq  proc ]]
then
break
fi


i=$((i+1))
if [ $i = $proc ]
then
i=0
fi
done


echo -n -e "\nScheduling order: "
for((i=0;i<${#order[*]};i++))
do
echo -n -e "P"${order[i]}" "
done
#echo ${order[*]}


echo -n -e "\n\nStart time for each process: "${queue[@]::${#queue[@]}-1}"\n"

sum=0
for((i=0;i<$proc;i++))
do
sum=$(($sum+${queue[i]}))
done
avg=$(($sum/$proc))
echo -e "\nAverage first service time: "$avg"\n"

echo -e "Turnaround: "${queue[@]:1}
}





###########################
if [ $opt -eq 1 ]
then
SJF
fi
if [ $opt -eq 2 ]
then
RR
fi
