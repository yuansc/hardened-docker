#!/bin/bash
#
# Name:        sudo-script-docker-installer-wrapper.sh
# Description: this file deploy a Docker.img with a pre-configured hardened admin-settings.json
#
# Author:      Scott Yuan
#
# Usage:       sudo sudo-script-docker-install-wrapper.sh 
#                [ -f | --file ] <Docker.img>
#
DOCKER_DMG=$(pwd)/Docker.dmg

display_usage() {
cat << USAGE_MSG
  Usage:       sudo sudo-script-docker-install-wrapper.sh 
                 [ -f | --file ] <Docker.img>
USAGE_MSG
}

docker_install() {
  DOCKER_INSTALL=$1
  CMD="$DOCKER_INSTALL \
         --user=${SUDO_USER} \
         --allowed-org=cityofcalgaryaem \
         --admin-settings=${DOCKER_ADM}";
  if $CMD; then
    echo "Docker install command completed successfully [$msg]"
  else
    echo "Docker install command failed to complete [$msg]"
  fi
}

while [ "$1" != "" ]; do
  case $1 in
    -f | --file ) shift
                  DOCKER_DMG=$1
                  ;;
    *)            shift
                  display_usage
                  exit
                  ;;
  esac
  shift
done

export DOCKER_ADM=$(cat <<ADM_SETTINGS
{
  "configurationFileVersion": 2,
  "enhancedContainerIsolation": {
    "locked": true,
    "value": true
  },
  "kubernetes": {
     "locked": true,
     "enabled": false,
     "showSystemContainers": false,
     "imagesRepository": ""
  },
  "disableUpdate": {
    "locked": true,
    "value": false
  },
  "analyticsEnabled": {
    "locked": true,
    "value": false 
  },
  "extensionsEnabled": {
    "locked": true,
    "value": false
  },
  "scout": {
    "locked": true,
    "sbomIndexing": false,
    "useBackgroundIndexing": true
  },
  "allowExperimentalFeatures": {
    "locked": true,
    "value": false
  },
  "allowBetaFeatures": {
    "locked": true,
    "value": false
  },
  "blockDockerLoad": {
    "locked": true,
    "value": false
  },
  "filesharingAllowedDirectories": [
    {
      "path": "$HOME",
      "sharedByDefault": true
    },
    {
      "path":"$TMP",
      "sharedByDefault": true 
    }
  ], 
  "useVirtualizationFrameworkVirtioFS": {
    "locked": true,
    "value": true 
  },
  "useVirtualizationFrameworkRosetta": {
    "locked": true,
    "value": false
  },
  "useGrpcfuse": {
    "locked": true,
    "value": true 
  }
}
ADM_SETTINGS
);
DOCKER_ADM=$(echo $DOCKER_ADM | sed 's/ //g')
#echo $DOCKER_ADM 
#exit;

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root using 'sudo $0'"
  exit 1;
else
  if [ -f /Applications/Docker.app/Contents/MacOS/install ]; then
    echo "Docker.app already installed.  Reset admin-settings.json"
    docker_install "/Applications/Docker.app/Contents/MacOS/install"
  fi
  if [ -f $DOCKER_DMG ]; then
    echo "Installing Docker Desktop with $DOCKER_DMG file..."
    
    # Open $DOCKER_DMG disk image
    if hdiutil attach $DOCKER_DMG; then

      # Run the installer script
      docker_install "/Volumes/Docker/Docker.app/Contents/MacOS/install"

      if hdiutil detach /Volumes/Docker; then 
        echo "Installation completed"
      else
        echo "Unable to close $DOCKER_DMG"
      fi
    else
      echo "Unable to open $DOCKER_DMG for installation"
      exit 1;
    fi
  else
    echo "Missing $DOCKER_DMG file!"
    exit 1;
  fi
fi
