#!/usr/bin/env bash

## Must be ran as root

#####################################
## Install NewRelic Infrastructure ##
#####################################

#THIS PORTION IS DISABLED AS NR DOES NOT YET SUPPORT UBUNTU 18.

# adding requisit packages
#apt-get -y install ca-certificates

# Create a configuration file and add your license key
#echo "license_key: ENTER-NEWRELIC-KEY-HERE" | tee -a /etc/newrelic-infra.yml

# You can add extra configurations that fine-tune your agent’s behavior and collect custom attributes.
# Enable New Relic’s GPG key
#curl https://download.newrelic.com/infrastructure_agent/gpg/newrelic-infra.gpg | apt-key add -

# Create the agent’s apt repo using the command for your distribution version
#printf "deb [arch=amd64] http://download.newrelic.com/infrastructure_agent/linux/apt xenial main" | tee -a /etc/apt/sources.list.d/newrelic-infra.list

# Update your apt cache
#apt-get update

# Run the install script
#apt-get -y install newrelic-infra --allow-unauthenticated
