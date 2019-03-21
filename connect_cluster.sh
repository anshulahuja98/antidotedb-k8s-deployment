#!/bin/bash
mapfile -t POD_IPS < <(kubectl get pods -l app=antidotedb -o yaml | grep podIP: | grep -E  -o '\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?(\.|$)){4}\b')
mapfile -t POD_NAMES < <(kubectl get pods -l app=antidotedb -o yaml | grep name: | grep -E -o "antidotedb-deployment-.+-.+")


echo "antidote_dc_manager:create_dc(['antidote@"${POD_IPS[0]}"']),
rpc:call('antidote@"${POD_IPS[1]}"', antidote_dc_manager,create_dc, ['antidote@"${POD_IPS[1]}"']),
{ok, MyDescriptor} = antidote_dc_manager:get_connection_descriptor(),
{ok, RemoteDescriptor} = rpc:call('antidote@"${POD_IPS[0]}"', antidote_dc_manager,get_connection_descriptor, []),
Descriptors = [MyDescriptor, RemoteDescriptor],
antidote_dc_manager:subscribe_updates_from(Descriptors),
rpc:call('antidote@"${POD_IPS[0]}"', antidote_dc_manager,subscribe_updates_from, [Descriptors])." > connect-commands.txt


echo 'echo $(</var/connect-commands.txt) " " | /opt/antidote/erts-10.3/bin/to_erl /tmp/erl_pipes/antidote\@'${POD_IPS[0]}/'' > run_remote_shell.sh



kubectl cp connect-commands.txt "${POD_NAMES[0]}":/var/
kubectl cp run_remote_shell.sh "${POD_NAMES[0]}":/var/



kubectl exec -it "${POD_NAMES[0]}" bash /var/run_remote_shell.sh
