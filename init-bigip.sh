#!/bin/bash
tmsh modify sys global-settings gui-setup disabled
tmsh modify /sys http auth-pam-validate-ip off
tmsh modify /sys ntp timezone Asia/Saigon
tmsh create net vlan public_vlan interfaces add { 1.1 { untagged } }
tmsh create net self public_ip address 10.1.10.10/24 vlan public_vlan
tmsh create net vlan private_vlan interfaces add { 1.2 { untagged } }
tmsh create net self private_ip address 10.1.20.10/24 vlan private_vlan
tmsh save sys config


 /usr/local/bin/SOAPLicenseClient --basekey GNLDR-KLKYC-TJQHK-MZWZR-HZRFYGD

tmsh create ltm node 10.1.20.101 address 10.1.20.101
tmsh create ltm node 10.1.20.102 address 10.1.20.102
tmsh create ltm pool testpool members add { 10.1.20.101:80 10.1.20.102:80 } monitor tcp
tmsh create ltm virtual testvs destination 10.1.10.10:80 ip-protocol tcp pool testpool profiles add { http } source-address-translation { type automap }
tmsh save sys config

