This setup runs a production-like keycloak instance locally over https by setting up host-signing, auto-creation of the admin user and starting of a PostgreSQL-DB for credential storage.

# Configuration
Follow the instructions below and make the following changes before you [start the docker services](#start-containers).

## Set Domain
This project allows for easy configuration of the hostdomain you want your keycloak console to be exposed at.

### In Production
To enter your host domain change line 6 in the [nginx.conf](nginx.conf) to `servername <your host domain>;`
Also add your ssl certificate and key in lines 7 and 8.

### For testing
If you want to test the setup locally add `server_name <local-mock-domain>;` in line 6 and add the following line to your operating systems hosts-file: `127.0.0.1 <local-mock-domain>`

#### Linux
/etc/hosts

#### Windows
C:\Windows\System32\drivers\etc\hosts

## Specify Environment Variables
For this setup there are the following Envirronment Variabels you must set in a .env-file in the root-directory.

KEYCLOAK_USERNAME -> Username of the admin-account of Keycloak
KEYCLOAK_PASSWORD -> Password of the admin-account of Keycloak
POSTGRES_KEYCLOAK_USERNAME -> Username of the admin-account of the Keycloak-Database
POSTGRES_KEYCLOAK_PASSWORD -> Password of the admin-account of the Keycloak-Database

# Start Containers
To start the setup after configuration follow the instructions below.

## Only On First Start
ONLY USE ON FIRST START!
This will automatically build the containers and create the users specified in the .env file.
`docker compose up -d postgres keycloak nginx && docker compose run --rm keycloak-init`

## General Restart
Use this to restart your services after your [docker network has been initialized](#only-on-first-start).
`docker compose up -d postgres keycloak nginx`