#!/bin/bash

# This script clones an initial copy of the model in the appropriate file hierarchy
# for other scripts to operate on. Important flags and values (EDR, drop size etc.)
# are modified to fit the hierarchy.

echo "Enter path to parent model:"
read parentPath

echo "Enter lowerbound EDR:"
read lbEDR
echo "Enter upperbound EDR:"
read ubEDR
echo "Enter EDR increments:"
read incEDR

echo "Enter lowerbound drop size:"
read lbDropSize
echo "Enter upperbound drop size:"
read ubDropSize
echo "Enter dropsize increments:"
read incDropSize

echo "Enter location of cloned models:"
read baseClonePath

# Implementation of genesis:
# Nested loops: Outer loop -> EDR, Inner loop -> Drop size
# SED used to modify content of clones

# Outer loop
# ----------
for (( EDR=$lbEDR; EDR<=$ubEDR; EDR=$EDR+$incEDR ))
do
	# Inner loop
	# ----------
	for (( DropSize=$lbDropSize; DropSize<=$ubDropSize; DropSize=$DropSize+$incDropSize ))
	do
		finalClonePath="$baseClonePath/$EDR/Rr$DropSize$DropSize/gomic0"
		mkdir -pv $finalClonePath
		cp -rv $parentPath/ $finalClonePath/
		cd $finalClonePath

		# Checking and modifying cloned content to generate multiple model instances
		# -------------------------------------------------------------------------
		# Implementation:
		# Use grep to check for the pattern
		# If the pattern is present (grep exit status = 0) no changes are made
		# If the pattern is absent (grep exit status != 0). SED is used to update the pattern

		if !(grep "nstop    =$nstop" main.F90)
		then


