## Base Image Used

The base image used as the foundation for this project is the **ubuntu:focal**, It has been carefully selected to provide a solid starting point for building the desired environment. The coredge ubuntu base image includes all the essential components and dependencies.

## Hardening Done

To enhance the security of the base image, several hardening measures have been implemented. These measures include:

**Removal of unnecessary packages and services**

**Application of security patches and updates**

**Configuration of appropriate access controls and permissions**

**Implementation of secure network settings**

**Implementation of security best practices and guidelines**

These hardening steps aim to minimize potential vulnerabilities and strengthen the overall security of the base image.

These are all the checks which we are taking care of in level-2 CIS Ubuntu Hardening right now in our base image v1

```shell 
Ensure mounting of FAT filesystems is limited
Ensure nodev option set on /var/tmp partitions
Ensure /var/tmp partitions
Ensure separate partition exists for /var/log
Ensure separate partition exists for /home
Ensure all AppArmor Profiles are in enforce or complain mode
Ensure all AppArmor Profiles are enforcing
Disable IPv6 - change /etc/default/grub to remove disabling IPv6
Disable IPv6 - change sysctl
Ensure DCCP is disabled
Ensure SCTP is disabled
Ensure RDS is disabled
Ensure TIPC is disabled
Ensure auditd is installed
Ensure auditd service is enabled
Ensure audit log storage size is configured
Ensure audit logs are not automatically deleted
Ensure system is disabled when audit logs are full | admin_space_left_action
Ensure system is disabled when audit logs are full | space_left_action
Ensure system is disabled when audit logs are full | action_mail_acct
Ensure events that modify date and time information are collected
Ensure events that modify user/group information are collected
Ensure events that modify the system's network environment are collected
Ensure events that modify the system's Mandatory Access Controls are collected
Ensure login and logout events are collected
Ensure session initiation information is collected
Ensure discretionary access control permission modification events are collected
Ensure unsuccessful unauthorized file access attempts are collected
Ensure use of privileged commands is collected | get data
Ensure use of privileged commands is collected | apply
Ensure successful file system mounts are collected
Ensure file deletion events by users are collected
Ensure changes to system administration scope (sudoers) is collected
Ensure system administrator command executions (sudo) are collected
Ensure kernel module loading and unloading is collected
Ensure the audit configuration is immutable
Ensure the audit configuration is immutable
```

 

These checks for **level_2 CIS hardening** is not yet integrated in base image **"coredgeio/ubuntu-base-beta:v1"**, and will be implemented in the next release of our base image→

```shell
Ensure mounting of FAT filesystems is limited
Disable IPv6 - Disable ipv6 ufw policies if ipv6 is not enabled
Ensure auditing for processes that start prior to auditd is enabled - change /etc/default/grub
Ensure mounting of FAT filesystems is limited | modprobe
Ensure auditing for processes that start prior to auditd is enabled - change /etc/default/grub
Ensure audit_backlog_limit is sufficient - change /etc/default/grub
```


## Base Image Size, Name and User

The coredge ubuntu base image has a **size of approximately 78.4 MB**. This size refers to the disk space occupied by the image when stored or deployed.
and it has a **default user "core"**

The base image is identified by the name **"coredgeio/ubuntu-base-beta:v1"**.

