#!/bin/bash
set -e

# Wait for Keycloak to be ready

delay=3
max_tries=10
tries=0

while ! curl -sf -o /dev/null http://identity-provider:9000/health/ready; do
    if [ $tries -ge $max_tries ]; then
        echo "Keycloak did not become ready in time. Exiting."
        exit 1
    fi

    echo "Waiting for Keycloak to be ready... (try $((tries+1))/$max_tries)"
    sleep $((delay + tries * 2))
    tries=$((tries + 1))
done

echo "Keycloak is ready."

# Try login with temporary admin
TEMP_LOGIN_EXISTS=true
if ! /opt/keycloak/bin/kcadm.sh config credentials \
      --server http://identity-provider:8080 \
      --realm master \
      --user "keycloak_temp_admin" \
      --password "$KEYCLOAK_PASSWORD"; then
    TEMP_LOGIN_EXISTS=false
fi

# Exit if keycloak is already initialized
if [ "$TEMP_LOGIN_EXISTS" = false ]; then
    echo "Permanent admin already exists. Skipping."
    exit 0
fi

# Create new admin
/opt/keycloak/bin/kcadm.sh create users -r master \
  -s username="$KEYCLOAK_USERNAME" \
  -s enabled=true

/opt/keycloak/bin/kcadm.sh set-password -r master \
  --username "$KEYCLOAK_USERNAME" \
  --new-password "$KEYCLOAK_PASSWORD"

/opt/keycloak/bin/kcadm.sh add-roles \
  --uusername "$KEYCLOAK_USERNAME" \
  --rolename admin \
  -r master

echo "Admin user '$KEYCLOAK_USERNAME' created successfully."

# Delete temporary admin
TEMP_ID=$(/opt/keycloak/bin/kcadm.sh get users -r master -q username=keycloak_temp_admin --fields id --format csv | tr -d '"[:space:]"')
/opt/keycloak/bin/kcadm.sh delete users/$TEMP_ID -r master

echo "Temporary admin deleted successfully."

# Exit successfully
exit 0