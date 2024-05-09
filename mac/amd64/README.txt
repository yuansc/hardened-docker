MacOS Install steps
* Manual install using Docker.dmg
  - be sure select the defalt (required password & privileged access); 
    of the Enhanced Container Isolation feature will locked the Docker Desktop
    for /var/run/sock.xxx communication issue with Docker Engine.  When this 
    issue occurred, Docker installation has been uninstall and clean up 
    manually (for a MacOS bug with Sonoma).

* Push both registry.json and admin-settings.json to 
  /Library/Application\ Support/com.docker.docker, mush owned by root
  with access mode '644'
