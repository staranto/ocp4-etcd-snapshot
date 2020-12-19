# etcd-snapshot

Take a scheduled snapshot of the OCP etcd datastore.

## Notes
1. If `etcd-snapshot.sh` is modified, it must be encoded and stored in `etcd-snapshot-mc.yaml` and then the `MachineConfig` must be applied.
2. In `etcd-snapshot-mc.yaml` modify `Environment` entries in `etcd-snapshot.service` and the `OnCalendar` entry in `etcd-snapshot.timer` as needed.  In particular, the `Environment=HOST` entry must match the output of `hostname` on the "snapshot" master node. 
3. Because of a design limitation of `MachineConfigPool`, this `MachineConfg` must be applied to all master nodes.  However, the snapshot should only be executed on one node.  To implement this restriction, the `Environment=HOST` entry is used.  On non-matching nodes, the timer and service will still be executed, but will be a noop and simply exit immediately.
4. OCP nodes are required to use UTC.  The `OnCalendar` entry should probably include a timezone specification so that it's clear when you want the snapshot to run.
5. The upcoming `Red Hat OpenShift API's for Data Protection` service may replace this solution.

## Target directories

The etcd snapshots are stored in a target directory (`Environment=TGT_DIR`).  This directory should be chosen carefully.  A sane location would be under `/home/core`, though `/mnt` and `/tmp` are also allowed.  

If you choose `/tmp`, recognize that this is `tmpfs` backed and all contents will be lost if the node is booted.  The snapshot files should, therefore, be *aggressively* copied off the node.

## Copying snapshots off the node

Snapshot files should be synced off the snapshot node immediately after they are created.  There are two schemes --

1. rsync them onto a non-cluster machine using a cron -
        
     `rsync -avz --rsync-path "sudo rsync" core@master-0.ocpa.0.taranto.dev:/home/core/etcd-snapshots/ .`

2. *WORK IN PROGRESS* Apply the `etcd-snapshot-sync-mc.yaml` MachineConfig which will synchronize the files to non-snapshot master nodes.  Problem w/ssh key pair