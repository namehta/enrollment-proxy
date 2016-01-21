@ECHO OFF
REM Setup a new docker env if it doesn't exist
docker-machine create -d virtualbox demodev

REM Set the environment for the current session
FOR /f "tokens=*" %%i IN ('docker-machine env demodev') DO %%i

REM Start the docker containers via docker-compose
docker-compose up -d

REM Scale up the web and app containers
docker-compose scale app=3 ui=2

REM Have to run this for HAProxy to pick up the new containers.  It's a docker-compose bug
docker-compose up --force-recreate -d

echo. >> C:\Windows\System32\drivers\etc\hosts
FOR /f "tokens=*" %%i IN ('docker-machine ip demodev') DO (echo %%i demoapp.example.com) >> C:\Windows\System32\drivers\etc\hosts

TIMEOUT /T 15 /NOBREAK
curl http://demoapp.example.com/app/util/load?numRecords=33