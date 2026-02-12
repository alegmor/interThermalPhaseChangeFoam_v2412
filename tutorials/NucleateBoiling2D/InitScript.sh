#!/bin/bash
unset FOAM_SIGFPE
m4 system/blockMeshDict.m4 > system/blockMeshDict
blockMesh

#Need to check if makeAxialMesh is available
HAS_MAKEAXIALMESH=`command -v makeAxialMesh`
if [ ! $HAS_MAKEAXIALMESH ]
then
	echo "Need to install makeAxialMesh"
	mkdir -p $HOME/Downloads
	CURDIR=`pwd`
	cd $HOME/Downloads
	svn checkout svn://svn.code.sf.net/p/openfoam-extend/svn/trunk/Breeder_2.0/utilities/mesh/manipulation/MakeAxialMesh
	cd MakeAxialMesh
	./Allwmake
	cd $CURDIR
fi

makeAxialMesh -overwrite
# Force Axis patch type back to symmetryPlane after makeAxialMesh
perl -0777 -i -pe 's/(Axis\s*\{[^}]*type\s+)\w+(\s*;)/$1symmetryPlane$2/s' constant/polyMesh/boundary

collapseEdges -overwrite
mkdir -p 0
cp -r A/* 0/
mv 0/alpha1.org 0/alpha1
setFields
interThermalPhaseChangeFoam