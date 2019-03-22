#!/bin/bash

# Makes an array of the Pod IP Addresses
mapfile -t POD_IPS < <(kubectl get pods -l app=antidotedb -o yaml | grep podIP: | grep -E  -o '\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?(\.|$)){4}\b')
# Makes an array of the Pod Names
mapfile -t POD_NAMES < <(kubectl get pods -l app=antidotedb -o yaml | grep name: | grep -E -o "antidotedb-deployment-.+-.+")

# Creates a dynamic connect command to connect the various pods
# Script for pod[0] which gets the descriptors of the other pods in the cluster 
# and also subscribes them to updates from the rest of the cluster
# This command is saved in file: connect-commands.txt to be sent to pod[0]
echo "antidote_dc_manager:create_dc(['antidote@"${POD_IPS[0]}"']),
rpc:call('antidote@"${POD_IPS[1]}"', antidote_dc_manager,create_dc, ['antidote@"${POD_IPS[1]}"']),
{ok, MyDescriptor} = antidote_dc_manager:get_connection_descriptor(),
{ok, RemoteDescriptor} = rpc:call('antidote@"${POD_IPS[1]}"', antidote_dc_manager,get_connection_descriptor, []),
Descriptors = [MyDescriptor, RemoteDescriptor],
antidote_dc_manager:subscribe_updates_from(Descriptors),
rpc:call('antidote@"${POD_IPS[1]}"', antidote_dc_manager,subscribe_updates_from, [Descriptors])." > connect-commands.txt

# Command to connect to the antidote pipline on pod[0] and runs the script generated above in file: connect-commands.txt
# This command is saved in file run_remote_shell.sh to be sent to pod[0]
echo 'echo $(</var/connect-commands.txt) " " | /opt/antidote/erts-10.3/bin/to_erl /tmp/erl_pipes/antidote\@'${POD_IPS[0]}/'' > run_remote_shell.sh

# Copies connect-commands.txt generated above to /var of pod[0]
kubectl cp connect-commands.txt "${POD_NAMES[0]}":/var/
# Copies run_remote_shell.sh generated above to /var of pod[0] 
kubectl cp run_remote_shell.sh "${POD_NAMES[0]}":/var/

# Runs run_remote_shell.sh on pod[0]
kubectl exec -it "${POD_NAMES[0]}" bash /var/run_remote_shell.sh
