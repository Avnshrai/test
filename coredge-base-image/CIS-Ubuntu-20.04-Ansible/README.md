This repo is a copy of https://github.com/alivx/CIS-Ubuntu-20.04-Ansible and is modified for CIS Hardening for docker containers and only level_2 is tested yet and is working fine.

Removed Multiple checks which were not working on Docker Container
1. Ensure mounting of FAT filesystems is limited
2. Disable IPv6 - Disable ipv6 ufw policies if ipv6 is not enabled
3. Ensure auditing for processes that start prior to auditd is enabled - change /etc/default/grub
4. Ensure mounting of FAT filesystems is limited | modprobe
5. Ensure auditing for processes that start prior to auditd is enabled - change /etc/default/grub
6. Ensure audit_backlog_limit is sufficient - change /etc/default/grub

Why we need CIS Hardened Image or system? 

CIS hardened Ubuntu: cyber attack and malware prevention for mission-critical systems
CIS benchmarks lock down your systems by removing:
1. non-secure programs.
2. disabling unused filesystems.
3. disabling unnecessary ports or services.
4. auditing privileged operations.
5. restricting administrative privileges.


CIS benchmark recommendations are adopted in virtual machines in public and private clouds. They are also used to secure on-premises deployments. For some industries, hardening a system against a publicly known standard is a criteria auditors look for. CIS benchmarks are often a system hardening choice recommended by auditors for industries requiring PCI-DSS and HIPPA compliance, such as banking, telecommunications and healthcare.
If you are attempting to obtain compliance against an industry-accepted security standard, like PCI DSS, APRA or ISO 27001, then you need to demonstrate that you have applied documented hardening standards against all systems within the scope of assessment.


The Ubuntu CIS benchmarks are organised into different profiles, namely **‘Level 1’** and **‘Level 2’** intended for server and workstation environments.


**A Level 1 profile** is intended to be a practical and prudent way to secure a system without too much performance impact.
* Disabling unneeded filesystems,
* Restricting user permissions to files and directories,
* Disabling unneeded services.
* Configuring network firewalls.

**A Level 2 profile** is used where security is considered very important and it may have a negative impact on the performance of the system.

* Creating separate partitions,
* Auditing privileged operations

