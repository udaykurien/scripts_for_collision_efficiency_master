#!/bin/bash

# This script clones an initial copy of the model in the appropriate file hierarchy
# for other scripts to operate on. Important flags and values (EDR, drop size etc.)
# are modified to fit the hierarchy.

echo "Enter path to parent model:"
read parentPath
echo

echo "Enter lowerbound EDR:"
read lbEDR
echo "Enter upperbound EDR:"
read ubEDR
echo "Enter EDR increments:"
read incEDR
echo

echo "Enter lowerbound drop size:"
read lbDropSize
echo "Enter upperbound drop size:"
read ubDropSize
echo "Enter dropsize increments:"
read incDropSize
echo

echo "Enter the value of nstop:"
read nstop
echo "Enter the wall time:"
read sbatch
echo 

echo "Enter location of cloned models:"
read baseClonePath

# Implementation of genesis:
# Nested loops: Outer loop -> EDR, Inner loop -> Drop size
# SED used to modify content of clones

# Outer loop
# ----------
for  EDR in $(seq $lbEDR $incEDR $ubEDR)
do
	# Inner loop
	# ----------
	for (( DropSize=$lbDropSize; DropSize<=$ubDropSize; DropSize=$DropSize+$incDropSize ))
	do
		finalClonePath="$baseClonePath/$EDR/Rr$DropSize$DropSize"
		mkdir -pv $finalClonePath
		cp -rv $parentPath/ $finalClonePath/
		cd $finalClonePath/gomic0

		# Checking and modifying cloned content to generate multiple model instances
		# -------------------------------------------------------------------------
		# Implementation:
		# 1. Use grep to check for the pattern
		# 2. If the pattern is present (grep exit status = 0) no changes are made
		# 3. If the pattern is absent (grep exit status != 0). SED is used to update the pattern

		
		# Illustration of implementation on nstop (contained within main.F90)
		# -------------------------------------------------------------------
		# Checking if pattern is present
		grep -q "nstop    = $nstop" main.F90
		
		# Recording exit status
		exitStatus1=$?

		# Modification of file parameters (via sed) contingent on exit status
		if [ $exitStatus1 -gt 0 ]
		then
			sed -i "148 c nstop    = $nstop              ! number of timesteps in current restart block" main.F90
		fi
		#--------------------------------------------------------------------
		# This implementation is here on forth applied to other file contents

		# sbatch
		# ------
		grep -q "#SBATCH --time=$sbatch" run_graham.sh
		exitStatus1=$?
		if [ $exitStatus1 -gt 0 ]
		then
			sed -i "s/#SBATCH --time=[0-9][0-9]:[0-9][0-9]:[0-9][0-9]/#SBATCH --time=$sbatch/" run_graham.sh
		fi
		
		# gomic
		# -----
		grep -q "gomic= 0" param.inc
		exitStatus1=$?
		if [ $exitStatus1 -gt 0 ]
		then
			sed -i "s/gomic= [0-9]/gomic= 0/" param.inc
		fi
		
		# ihydro
		# ------
		grep -q "ihydro   = 0" main.F90
		exitStatus1=$?
		if [ $exitStatus1 -gt 0 ]
		then
			sed -i "s/ihydro   = [0-9]/ihydro   = 0/" main.F90
		fi

		# drop radius
		# -----------
		grep -q "r=${DropSize}.d-6" idrops.F90
		exitStatus1=$?
		if [ $exitStatus1 -gt 0 ]
		then
			sed -i "s/r=[0-9][0-9].d-6/r=${DropSize}.d-6/" idrops.F90
		fi

		# EDR
		# ---
		grep -q "edr      = $EDR" main.F90
		exitStatus1=$?
		if [ $exitStatus1 -gt 0 ]
		then
			sed -i "s/edr      = [0-9].[0-9][0-9]/edr      = $EDR/" main.F90
		fi

	done
done


		





