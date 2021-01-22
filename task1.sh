#!/bin/bash

clear

function debug(){
	for i in $@
	do
		if [ -z "$line" ]; then
			local line=$i
		else
			local cmd="$cmd $i"
		fi
	done
	echo "-----------------------------------------------------------------------------------------"
	echo $line: $cmd
	$cmd
	#return
	if [ 0 = $? ]; then
		echo OK
	else
		echo FAIL
	fi
}


function rem_netns(){ #netns id range
	for i in $@
	do
		debug $LINENO ip netns delete netns$i
	done
}

function create_netns(){ #netns id range
	for i in $@
	do
		debug $LINENO ip netns add netns$i
	done
}

function show(){  #netns id range

	for i in $@
	do
		local name=netns$i
		echo "------------------------------------  netns$i  ------------------------------------------"
		debug $LINENO ip netns exec $name ip a
		echo "-----------------------------------------------------------------------------------------"
		debug $LINENO ip netns exec $name ip route
	done
}
rem_netns  {1..6}

create_netns  {1..6}

# create links
debug $LINENO ip -n netns1 link add veth11 type veth peer name veth15 netns netns5
debug $LINENO ip -n netns2 link add veth22 type veth peer name veth25 netns netns5
debug $LINENO ip -n netns3 link add veth33 type veth peer name veth36 netns netns6
debug $LINENO ip -n netns4 link add veth44 type veth peer name veth46 netns netns6
debug $LINENO ip -n netns5 link add vethx  type veth peer name vethy netns netns6


#set ip address
 debug $LINENO ip -n netns1 addr add 192.168.7.1/24 brd 192.168.7.255 dev veth11 
 debug $LINENO ip -n netns2 addr add 192.168.7.2/24 brd 192.168.7.255 dev veth22 
 debug $LINENO ip -n netns3 addr add 192.168.7.3/24 brd 192.168.7.255 dev veth33 
 debug $LINENO ip -n netns4 addr add 192.168.7.4/24 brd 192.168.7.255 dev veth44
 
 #create bridge
 debug $LINENO ip -n netns5 link add name brx type bridge
 debug $LINENO ip -n netns5 link set vethx master brx
 debug $LINENO ip -n netns5 link set veth15 master brx
 debug $LINENO ip -n netns5 link set veth25 master brx
 debug $LINENO ip -n netns6 link add name bry type bridge
 debug $LINENO ip -n netns6 link set vethy master bry
 debug $LINENO ip -n netns6 link set veth36 master bry
 debug $LINENO ip -n netns6 link set veth46 master bry
 
 #set filtering
 debug $LINENO ip -n netns5 link set dev brx type bridge vlan_filtering 1
 debug $LINENO ip -n netns6 link set dev bry type bridge vlan_filtering 1

 debug $LINENO bridge -n netns5 vlan add vid 10 pvid untagged dev veth15
 debug $LINENO bridge -n netns5 vlan add vid 20 pvid untagged dev veth25
 debug $LINENO bridge -n netns6 vlan add vid 10 pvid untagged dev veth36
 debug $LINENO bridge -n netns6 vlan add vid 20 pvid untagged dev veth46
 debug $LINENO bridge -n netns5 vlan add vid 10 pvid 10 dev vethx
 debug $LINENO bridge -n netns5 vlan add vid 20 pvid 20 dev vethx
 debug $LINENO bridge -n netns6 vlan add vid 10 pvid 10 dev vethy
 debug $LINENO bridge -n netns6 vlan add vid 20 pvid 20 dev vethy
 debug $LINENO bridge -n netns5 vlan del vid 1 dev vethx
 debug $LINENO bridge -n netns6 vlan del vid 1 dev vethy
 debug $LINENO bridge -n netns5 vlan del vid 1 dev veth15
 debug $LINENO bridge -n netns5 vlan del vid 1 dev veth25
 debug $LINENO bridge -n netns6 vlan del vid 1 dev veth36
 debug $LINENO bridge -n netns6 vlan del vid 1 dev veth46
 debug $LINENO bridge -n netns5 vlan del vid 1 dev brx self
 debug $LINENO bridge -n netns6 vlan del vid 1 dev bry self
 
 # up all interfaces
 debug $LINENO ip -n netns1 link set lo up
 debug $LINENO ip -n netns2 link set lo up
 debug $LINENO ip -n netns3 link set lo up
 debug $LINENO ip -n netns4 link set lo up
 debug $LINENO ip -n netns5 link set lo up
 debug $LINENO ip -n netns6 link set lo up
 debug $LINENO ip -n netns1 link set veth11 up
 debug $LINENO ip -n netns2 link set veth22 up
 debug $LINENO ip -n netns3 link set veth33 up
 debug $LINENO ip -n netns4 link set veth44 up
 debug $LINENO ip -n netns5 link set veth15 up
 debug $LINENO ip -n netns5 link set veth25 up
 debug $LINENO ip -n netns5 link set vethx up
 debug $LINENO ip -n netns6 link set veth36 up
 debug $LINENO ip -n netns6 link set veth46 up
 debug $LINENO ip -n netns6 link set vethy up
 debug $LINENO ip -n netns5 link set brx up
 debug $LINENO ip -n netns6 link set bry up

 
#sudo ip netns exec netns1 ping 192.168.7.3
#sudo ip netns exec netns6 tcpdump -i bry -nn -e  vlan

