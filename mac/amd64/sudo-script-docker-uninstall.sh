
FLDRS=$(cat <<LIST
~/Library/Group\ Containers/group.com.docker
~/Library/Containers/com.docker.docker
~/.docker
/Library/Application\ Support/com.docker.docker/access.json
LIST)
/Applications/Docker.app/Contents/MacOS/uninstall
for T in $FLDRS; 
do
  rm -rf $T
done
