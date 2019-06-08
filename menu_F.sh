#!/bin/bash

# This script launches 1.Prep, 2.Back up or 3. Launch subscripts based on user specification

scriptPath="/home/ukurien/projects/def-yaumanko/ukurien/ED50/Scripts/Final"

echo Do you want to:
echo 1: Prep for next run
echo 2. Back up data
echo 3. Launch simulation
echo 4. Cancel
read varChoice

if [ $varChoice -eq 1 ]
then
	# Launch preparation script
	echo Transferring control to prep script
	sleep 2
	$scriptPath/prep_for_next_run_F.sh

elif [ $varChoice -eq 2 ]
then
	# Launch back up script
	echo Transferring control to back up script
	sleep 2
	echo Work in progress

elif [ $varChoice -eq 3 ]
then
	# Launch simulation
	echo Transferring control to simulation launch script
	sleep 2
	$scriptPath/launch_simulation_F.sh

else
	echo Cancelling

fi

