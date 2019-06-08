#!/bin/bash

# This script preps for the next model run

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

	echo Please specify gomic flag used 
	echo Note the following:
	echo gomic = 0 will spawn gomic1 with appropriately modified flags and restart files  
	echo gomic = 1 will spawn 1. gomic2ihydro0 and 2. gomic2ihydro1 with appropriately modified flags and restart files
	echo gomic = 2 will appopriately modify the restart files of 1. gomic2ihydro0 and 2. gomic2ihydro1 for the next iteration of the simulation. Additionally, you will be presented with the option to modify simulation run times
	read gomicFlag


	if [ $gomicFlag -eq 0 ] 
	then
		# Initiating loop to cycle throug paths
		for (( dropSize=$dropSizeLB; dropSize<=$dropSizeUB;dropSize=$dropSize+$dropSizeInc))
		do			
			# Cloning model and output files to new directory
			# -----------------------------------------------
			pathModel="Rr$dropSize$dropSize"
			echo $pathModel
			pathOrigin="$pathBase/$pathModel/gomic0"
			pathDestination="$pathBase/$pathModel/gomic1"
			
			echo Creating gomic1
			mkdir -p $pathDestination
			echo
			
			echo Cloning gomic0 to gomic1
			cp -r $pathOrigin/* $pathDestination/
			echo

			# Naming restart files
			# --------------------
			cd $pathDestination/
			echo Renaming turbulent restart file,in gomic1, from Zk4.out.ncf to Zk.in.ncf
			mv Zk4.out.ncf Zk.in.ncf
			echo

			# Modifying model flags for next run
			# ----------------------------------
			echo Changing value of gomic flag from 0 to 1, in gomic1
			sed -i 's/gomic= 0/gomic= 1/g' param.inc
			echo	
		done


	elif [ $gomicFlag -eq 1 ]
	then
		#Initiating loop to cycle through paths
		for (( dropSize=$dropSizeLB; dropSize<=$dropSizeUB;dropSize=$dropSize+$dropSizeInc))
		do			
		
			# Cloning model and output files to new directories
			# -------------------------------------------------
			pathModel="Rr$dropSize$dropSize"
			pathOrigin=$pathBase/$pathModel/gomic1
			pathDestination1=$pathBase/$pathModel/gomic2ihydro0
			pathDestination2=$pathBase/$pathModel/gomic2ihydro1
			
			echo Creating gomic2ihydro0
			mkdir -p $pathDestination1
			echo

			echo Creating gomic2ihydro1
			mkdir -p $pathDestination2
			echo

			echo Cloning gomic1 to gomic2ihydro0
			cp -r $pathOrigin/* $pathDestination1/
			echo

			echo Cloning gomic1 to gomic2ihydro1
			cp -r $pathOrigin/* $pathDestination2/
			echo

			
			# Shifting into gomic2ihydro0 folder
			#-----------------------------------
			cd $pathDestination1

			# Naming restart files
			# --------------------
			echo Naming droplet distribution and turbulent restart files in gomic2ihydro0
			rm Zk.in.ncf
			mv Zk4.out.ncf Zk.in.ncf
			mv drop4.out.ncf drop.in.ncf
			echo

			# Modifying model flags for next run
			# ----------------------------------
			echo Changing flags gomic and ihydro from 1 and 0 to 2 and 1, respectively
			sed -i 's/gomic= 1/gomic= 2/g' param.inc
			sed -i 's/ihydro   = 0/ihydro   = 0/g' main.F90
			echo

			# Shifting into gomic2ihydro1 folder
			# ----------------------------------
			cd $pathDestination2

			# Naming restart files
			# --------------------
			echo Naming droplet distribution and turbulent restart files in gomic2ihydro1
			rm Zk.in.ncf
			mv Zk4.out.ncf Zk.in.ncf
			mv drop4.out.ncf drop.in.ncf
			echo 

			# Modifying model flags for next run
			# ----------------------------------
			echo Changing flags gomic and ihydro from 1 and 0 to 2 and 1, respectively
			sed -i 's/gomic= 1/gomic= 2/g' param.inc
			sed -i 's/ihydro   = 0/ihydro   = 1/g' main.F90
			echo
		done

	elif [ $gomicFlag -eq 2 ]
	then
		# Current simulation time /(obtained from Rr1010/)
		echo The current nstop and sbatch are \(obtained from Rr1010\):
		nStop=$(grep nstop main.F90)
		echo nStop
		sBatch=$(grep 'SBATCH --time' run_graham.sh) 
		echo sBatch
		echo
		# Allow the user to modify the simulation run time
		echo Do you want to change nstop and sbatch? \(y/n\)
		read varTimeStep
		if [ "$varTimeStep" == "y" ]
			echo Enter new nstop
			read nstopNew
			echo Enter new sbatch
			read sbatchNew
			sed -i ""

		# Initiating loop to cycle through paths
		for (( dropSize=$dropSizeLB; dropSize<=$dropSizeUB; dropSize=$dropSize+$dropSizeInc))
		do
			# Generating path variable
			# ------------------------
			pathModel="Rr$dropSize$dropSize"
			pathDestination1=$pathBase/$pathModel/gomic2ihydro0
			pathDestination2=$pathBase/$pathModel/gomic2ihydro1

			# Shifting into gomic2ihydro0
			# ---------------------------
			cd $pathDestination1

			# Renaming restart file, deprecating and preserving last restart file
			# -------------------------------------------------------------------

			# Count the number of old restart files and store them in variable counter
			counterZk=$(ls -l Zk.in.ncf* | wc -l)
			counterDrop=$(ls -l drop.in.ncf* | wc -l)
			
			# Appending the count to the now obsolete restart files
			mv Zk.in.ncf Zk.in.ncf.old$counterZk
			mv drop.in.ncf drop.in.ncf.old$counterDrop

			# Naming new restart files
			mv Zk4.out.ncf Zk.in.ncf
			mv drop4.out.ncf drop.in.ncf
		done



	fi
elif [ $varChoice -eq 2 ]
then
	echo Code for this part has not been written as yet.
fi


