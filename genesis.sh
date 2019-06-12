#!/bin/bash

# This script clones an initial copy of the model in the appropriate file hierarchy
# for other scripts to operate on. Important flags and values (EDR, drop size etc.)
# are modified to fit the hierarchy.

echo "Enter path to parent model:"
read parentPath
echo "Enter lowerbound EDR:"
read lbEDR
echo "Enter upperbound EDR:"
echo ubEDR
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




