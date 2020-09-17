#!/bin/bash
# $1 device path $2 mount point

if [ "$1" == "" ]; then
	echo "please input the proper parameters"
	echo "ex) ./benchmark /dev/sdb1 /mnt"
	exit
fi
if [ "$2" == "" ]; then
	echo "please input the proper parameters"
	echo "ex) ./benchmark /dev/sdb1 /mnt"
	exit
fi

dev=$(echo ${1:5} | cut -c 1-3)

echo $dev
echo deadline > /sys/block/$dev/queue/scheduler
#echo 3 > /sys/block/$dev/queue/nomerges

umount $1 2&> /dev/null
umount $2 2&> /dev/null

mkfs.f2fs $1 -f > /dev/null
mount $1 $2 > /dev/null

fio --name=job1 --ioengine=libaio --rw=randwrite --numjobs=8 --bs=4k --size=10m --directory=$2 --iodepth=4 --fsync=1 --nrfiles=1 --group_reporting > ./write_result_samsung.txt

write_throuput=$(cat ./write_result_samsung.txt | tail -4 | awk '{print $2}' | head -1 | cut -d '=' -f 2)
write_avg=$(cat ./write_result_samsung.txt | head -18 | tail -1 | awk '{print $5}' | cut -d '=' -f 2 | cut -d ',' -f 1)

echo 3 > /proc/sys/vm/drop_caches

fio --name=job1 --ioengine=sync --rw=read --numjobs=8 --bs=128k --size=10m --directory=$2 --nrfiles=1 --group_reporting > ./read_result_samsung.txt

read_throuput=$(cat ./read_result_samsung.txt | tail -4 | awk '{print $2}' | head -1 | cut -d '=' -f 2)
read_avg=$(cat ./read_result_samsung.txt | head -9 | tail -1 | awk '{print $5}' | cut -d '=' -f 2 | cut -d ',' -f 1)

./write_result_samsung.txt
./read_result_samsung.txt

echo "Write Throughput = " $write_throuput 
echo "Write Avg. Latency = " $write_avg 
echo "Read_Throughput = " $read_throuput 
echo "Read Avg. latency = " $read_avg
