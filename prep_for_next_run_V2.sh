#!/bin/bash

# This script preps for the next model run

pathBase="/home/ukurien/projects/def-yaumanko/ukurien/Clones_1"

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

	echo Enter the lower value of EDR
	read lbEDR
	echo Enter the upper value of EDR
	read ubEDR
	echo Enter the increments in EDR
	read incEDR

	echo Please specify gomic flag used 
	echo Note the following:
	echo gomic = 0 will spawn gomic1 with appropriately modified flags and restart files  
	echo gomic = 1 will spawn 1. gomic2ihydro0 and 2. gomic2ihydro1 with appropriately modified flags and restart files
	echo gomic = 2 will appopriately modify the restart files of 1. gomic2ihydro0 and 2. gomic2ihydro1 for the next iteration of the simulation. Additionally, you will be presented with the option to modify simulation run times
	read gomicFlag


	if [ $gomicFlag -eq 0 ] 
	then
		# Initiating loop to cycle throug paths
		for EDR in $(seq $lbEDR $incEDR $ubEDR)
		do
			for (( dropSize=$dropSizeLB; dropSize<=$dropSizeUB;dropSize=$dropSize+$dropSizeInc))
			do			
				# Cloning model and output files to new directory
				# -----------------------------------------------
				pathModel="$EDR/Rr$dropSize$dropSize"
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
		done


	elif [ $gomicFlag -eq 1 ]
	then
		# Current simulation time /(obtained from Rr1010/)
		echo The current nstop and sbatch are \(obtained from Rr1010\):
		nStop=$(grep "nstop    =" $pathBase/Rr1010/gomic0/main.F90)
		echo "nstop: $nStop"
		sBatch=$(grep 'SBATCH --time' $pathBase/Rr1010/gomic0/run_graham.sh) 
		echo "SBATCH: $sBatch"
		echo
		# Allow the user to modify the simulation run time
		echo Do you want to change nstop and sbatch? \(y/n\)
		read varTimeStep
		if [ "$varTimeStep" == "y" ]
		then
			echo Enter new nstop
			read nstopNew
			echo Enter new sbatch
			read sbatchNew
		
		#Initiating loop to cycle through paths
		for EDR in $(seq $lbEDR $incEDR $ubEDR)
		do
			for (( dropSize=$dropSizeLB; dropSize<=$dropSizeUB;dropSize=$dropSize+$dropSizeInc))
			do			
			
				# Cloning model and output files to new directories
				# -------------------------------------------------
				pathModel="$EDR/Rr$dropSize$dropSize"
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
				mv Zk.in.ncf Zk.in.ncf.old1
				mv Zk4.out.ncf Zk.in.ncf
				mv drop4.out.ncf drop.in.ncf
				echo

				# Modifying model flags for next run
				# ----------------------------------
				echo Changing flags gomic and ihydro from 1 and 0 to 2 and 1, respectively
				sed -i 's/gomic= 1/gomic= 2/g' param.inc
				sed -i 's/ihydro   = 0/ihydro   = 0/g' main.F90
				echo

				# Modifying nstop and sbatch values
				# ---------------------------------
				sed -i "/#SBATCH --time=/ c #SBATCH --time=$sbatchNew" run_graham.sh
				sed -i "148 c nstop    =$nstopNew" main.F90  

				# Shifting into gomic2ihydro1 folder
				# ----------------------------------
				cd $pathDestination2

				# Naming restart files
				# --------------------
				echo Naming droplet distribution and turbulent restart files in gomic2ihydro1
				mv Zk.in.ncf Zk.in.ncf.old1
				mv Zk4.out.ncf Zk.in.ncf
				mv drop4.out.ncf drop.in.ncf
				echo 

				# Modifying model flags for next run
				# ----------------------------------
				echo Changing flags gomic and ihydro from 1 and 0 to 2 and 1, respectively
				sed -i 's/gomic= 1/gomic= 2/g' param.inc
				sed -i 's/ihydro   = 0/ihydro   = 1/g' main.F90
				echo
				
				# Modifying nstop and sbatch values
				# ---------------------------------
				sed -i "/#SBATCH --time=/ c #SBATCH --time=$sbatchNew" run_graham.sh
				sed -i "148 c nstop    =$nstopNew" main.F90  
			done
		done

	elif [ $gomicFlag -eq 2 ]
	then
		# Current simulation time /(obtained from Rr1010/)
		echo The current nstop and sbatch are \(obtained from Rr1010\):
		nStop=$(grep "nstop    =" $pathBase/Rr1010/gomic0/main.F90)
		echo "nstop: $nStop"
		sBatch=$(grep 'SBATCH --time' $pathBase/Rr1010/gomic0/run_graham.sh) 
		echo "SBATCH: $sBatch"
		echo
		# Allow the user to modify the simulation run time
		echo Do you want to change nstop and sbatch? \(y/n\)
		read varTimeStep
		if [ "$varTimeStep" == "y" ]
		then
			echo Enter new nstop
			read nstopNew
			echo Enter new sbatch
			read sbatchNew
			
		for EDR in $(seq $lbEDR $incEDR $ubEDR)
		do
			for (( dropSize=$dropSizeLB; dropSize<=$dropSizeUB; dropSize=$dropSize+$dropSizeInc))
			do
				# Generating path variable
				# ------------------------
				pathModel="$EDR/Rr$dropSize$dropSize"
				pathDestination1="$pathBase/$pathModel/gomic2ihydro0"
				pathDestination2="$pathBase/$pathModel/gomic2ihydro1"

				# Shifting into gomic2ihydro0
				# ---------------------------
				cd $pathDestination1
				
				# Making changes to SBATCH and nstop
				# ----------------------------------
				# The 'c' command tells sed to replace the entire line (which contains the pattern specified in sed) with a new pattern. 
				# Remember to use double quotes to allow the shell to expand the variables.
				sed -i "/#SBATCH --time=/ c #SBATCH --time=$sbatchNew" run_graham.sh
				# 148 -> line number to be changed, c -> replace entire line with pattern that follows. Double quotes to allow shell expansion of variables.
				# For more robust text editing consider using gawk.
				sed -i "148 c nstop    =$nstopNew" main.F90  
				
				
				# Shifting into gomic2ihydro1
				# ---------------------------
				cd $pathDestination2
				
				# Making changes to SBATCH and nstop
				# ----------------------------------
				# The 'c' command tells sed to replace the entire line (which contains the pattern specified in sed) with a new pattern. 
				# Remember to use double quotes to allow the shell to expand the variables.
				sed -i "/#SBATCH --time=/ c #SBATCH --time=$sbatchNew" run_graham.sh
				# 148 -> line number to be changed, c -> replace entire line with pattern that follows. Double quotes to allow shell expansion of variables.
				# For more robust text editing consider using gawk.
				sed -i "148 c nstop    =$nstopNew" main.F90  
			done
		done
		fi	

		# Initiating loop to cycle through paths
		for EDR in $(seq $lbEDR $incEDR $ubEDR)
		do
			for (( dropSize=$dropSizeLB; dropSize<=$dropSizeUB; dropSize=$dropSize+$dropSizeInc))
			do
				# Generating path variable
				# ------------------------
				pathModel="$EDR/Rr$dropSize$dropSize"
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
		done
	fi

elif [ $varChoice -eq 2 ]
then
	echo Code for this part has not been written as yet.
fi


