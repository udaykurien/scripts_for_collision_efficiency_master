#!/bin/bash

# This script sequentially launches multiples instances of the simulation

pathBase="/home/ukurien/projects/def-yaumanko/ukurien/ED50"

echo Press 1 for simulation with monodisperse 
echo Press 2 for bi disperse
read varChoice

if [ $varChoice -eq 1 ]
then
	# Gathering info on data to be prepped
	echo Enter the smallest droplet size for which the simulation was run
	read dropSizeLB
	echo Enter the largest drop size for which the simulation was run
	read dropSizeUB
	echo Enter the increments through which the droplet size was changed
	read dropSizeInc

	echo Please specify gomic flags used 
	read gomicFlag
	echo Please specify ihydro flag
	read iHydro

        
	# gomic = 0 and ihydro = 0
	# ------------------------
	if [ "$gomicFlag" == "0" ] && [ "$iHydro" == "0" ] 
	then
		# Initiating loop to cycle through paths
		for (( dropSize=$dropSizeLB; dropSize<=$dropSizeUB;dropSize=$dropSize+$dropSizeInc))
		do			
			# Following path
			# --------------
			pathModel="Rr$dropSize$dropSize"
			pathFinal="$pathBase/$pathModel/gomic0"
			
			echo Entering $pathFinal :
			cd $pathFinal
			echo
			
			# Launch simulation from within directory
			# ---------------------------------------
			echo Launching simulation :
			./compileandrun_graham
			echo
		done

	# gomic = 1 and ihydro = 0
	# ------------------------
	elif [ "$gomicFlag" == "1" ] && [ "$iHydro" == "0" ]
	then
		#Initiating loop to cycle through paths
		for (( dropSize=$dropSizeLB; dropSize<=$dropSizeUB;dropSize=$dropSize+$dropSizeInc))
		do			
		
			# Following path
			# --------------
			pathModel="Rr$dropSize$dropSize"
			pathFinal="$pathBase/$pathModel/gomic1"

			echo Entering $pathFinal:
			cd $pathFinal
			echo

			# Launch simulation from within directory
			# ---------------------------------------
			echo Launching simulation:
			./compileandrun_graham
			echo
		done

	# gomic = 2 and ihydro = 0
	# -----------------------
	elif [ "$gomicFlag" == "2" ] && [ "$iHydro" == "0" ]
	then
		#Initiating loop to cycle through paths
		for (( dropSize=$dropSizeLB; dropSize<=$dropSizeUB;dropSize=$dropSize+$dropSizeInc))
		do			
		
			# Following path
			# --------------
			pathModel="Rr$dropSize$dropSize"
			pathFinal="$pathBase/$pathModel/gomic2ihydro0"

			echo Entering $pathFinal:
			cd $pathFinal
			echo

			# Launch simulation from within directory
			# ---------------------------------------
			echo Launching simulation:
			./compileandrun_graham
			echo
		done

	# gomic = 2 and ihydro = 1
	# ------------------------
	elif [ "$gomicFlag" == "2" ] && [ "$iHydro" == "1" ]
	then
		#Initiating loop to cycle through paths
		for (( dropSize=$dropSizeLB; dropSize<=$dropSizeUB;dropSize=$dropSize+$dropSizeInc))
		do			
		
			# Following path
			# --------------
			pathModel="Rr$dropSize$dropSize"
			pathFinal="$pathBase/$pathModel/gomic2ihydro1"

			echo Entering $pathFinal:
			cd $pathFinal
			echo

			# Launch simulation from within directory
			# ---------------------------------------
			echo Launching simulation:
			./compileandrun_graham
			echo
		done
	fi

elif [ $varChoice -eq 2 ]
then
	echo Code for this part has not been written as yet.
fi

# Display submitted jobs
# ----------------------
squeue -u ukurien


