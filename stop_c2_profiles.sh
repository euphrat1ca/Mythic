#!/bin/bash
RED='\033[1;31m'
NC='\033[0m' # No Color
GREEN='\033[1;32m'
BLUE='\033[1;34m'
if [ "$EUID" -ne 0 ]
  then echo -e "${RED}[-]${NC} Please run as root"
  exit
fi
if [ $# -eq 0 ]
then
	# if no arguments supplied, try to stop all c2 profiles
	profiles=(./C2_Profiles/*)
else
	# if any arguments supplied, try to stop only the specified c2 profiles
	profiles=( "$@" )
	profiles=("${profiles[@]/#/.\/C2_Profiles\/}")
fi

# build out the standard image for c2 profiles
# now loop through the profiles to build out their variations
for p in "${profiles[@]}"
do
	realpath=$(realpath "$p")
	p=$(echo "${p/.\/C2_Profiles\//}")
	tag=$(echo "$p" | tr '[:upper:]' '[:lower:]')
	tag=$(echo "${tag/' '/}")
	tag=$(echo "${tag/'_'/}")
	if [ -d "$realpath" ]
	then
		# only try to do this if the specified directory actually exists
		echo -e "${BLUE}[*]${NC} Trying to stop $p's container..."
		if [ "$(docker ps -a | grep $tag )" ]
		then
			output=`docker stop "$tag" 2>/dev/null`
			if [ $? -ne 0 ]
			then
				echo -e "${RED}[-]${NC} Failed to stop container $tag"
			else
			  echo -e "${GREEN}[+]${NC} Successfully stopped $tag's container"
			fi
		else
		  echo -e "${GREEN}[+]${NC} $tag's container not running"
		fi
		echo -e "${BLUE}[*]${NC} Deleting $p's container..."
		output=`docker container rm $(docker ps -a -q --filter name="$tag") 2>/dev/null`
	else
	  echo -e "${RED}[-]${NC} $tag is not in the C2_Profiles folder"
	fi
done
