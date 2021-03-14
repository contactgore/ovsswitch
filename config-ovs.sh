#!/bin/sh
ovs_version=$(ovs-vsctl -V | grep ovs-vsctl | awk '{print $4}')
ovs_db_version=$(ovsdb-tool schema-version /usr/local/share/openvswitch/vswitch.ovsschema)

# give ovsdb-server and vswitchd some space...
sleep 3
# begin configuring
ovs-vsctl --no-wait -- init
ovs-vsctl --no-wait -- set Open_vSwitch . db-version="${ovs_db_version}"
ovs-vsctl --no-wait -- set Open_vSwitch . ovs-version="${ovs_version}"
ovs-vsctl --no-wait -- set Open_vSwitch . system-type="docker-ovs"
ovs-vsctl --no-wait -- set Open_vSwitch . system-version="2.7.1"
ovs-vsctl --no-wait -- set Open_vSwitch . external-ids:system-id=`cat /proc/sys/kernel/random/uuid`
ovs-vsctl --no-wait -- set-manager ptcp:6640
ovs-appctl -t ovsdb-server ovsdb-server/add-remote db:Open_vSwitch,Open_vSwitch,manager_options
#ovs-vsctl --no-wait -- set Open_vSwitch . other_config:hw-offload=true
#ovs-vsctl --no-wait -- set Open_vSwitch . other_config:tc-policy=both
ovs-vsctl add-br br0
ovs-vsctl set-fail-mode br0 secure
ovs-vsctl add-port br0 tun0 -- set Interface tun0 type=internal
ovs-vsctl add-port br0 vxlan0 -- set Interface vxlan0 type=vxlan options:dst_port=4789 options:key=flow options:remote_ip=flow
