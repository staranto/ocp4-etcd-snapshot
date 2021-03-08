## etcd-snapshot

## Take a scheduled snapshot of the OCP etcd datastore and core k8s manifests.

---

## Abstract

By default, Kubernetes stores cluster state information in a etcd datastore.  This datastore is usally distributed across each of the master nodes.  The data is highly dynamic and should be backed up very frequently in case a restore is needed.

Red Hat OpenShift Container Platform (OCP) provides a utility for taking point in time etcd backups ([/usr/local/bin/cluster-backup.sh](https://docs.openshift.com/container-platform/4.7/backup_and_restore/backing-up-etcd.html)).  This script is available on each master node and will create a local backup of the etcd datastore and a set of critical k8s manifests.

There are several problems with this approach:
1. The backup is kept on the local system.  If that system fails, the backup is no longer available.
2. There is no facility to manage a history of backup sets.
3. There is no native facility to manage scheduling of backups.

## etcd-snapshot

This utility will accomplish three goals:
1. Create a regular schedule of backups.
2. Synchornize backup sets to nodes and external storage.
3. Purge stale backup sets that are no longer viable.

### Operating Modes

There are two operating modes available.  Both can be configured and used, but the intent is that only one is.  They are functionally equivalent, though systemd Mode requires hand-coding to sync backup sets to external storage.  The preferred mode is Privileged Pod Mode.

#### systemd Mode

systemd Mode uses a unit file and timer to schedule the backup and, optionally, a second unit file and timer to schedule the syncing (e.g. "spraying") of the backup sets to other nodes and external storage.

#### Privileged Pod Mode

Privileged Pod Mode uses a Helm chart to deploy a privileged workload (CronJob) that schedule the backup and, optionally, synchronize the backup sets to other nodes and external storage.  Currently, only NFS external storage is supported.

### Deploying

#### Privileged Pod Mode

1. Access the cluster as a user with a binding to `ClusterRole/cluster-admins`.
1. Create a namespace to deploy the manifests to (eg. `oc new-project etcd-snapshot`).
1. Designate _**one**_ master node as the snapshot node by adding the `etcd-snapshot.example.com: snapshot` label.
1. If using sync mode, designate at _**least one**_ master node as a mirror node by adding the `etcd-snapshot.example.com: mirror` label.
1. If using sync mode, Create a secret called `.Values.sync.sshSecret` in the namespace from above that contains a `private` key with a value that is the encoded SSH private key used when originally configuring the OCP cluster.







4. Create a `my-values.yaml` file based off of the included `values.yaml`.
5. Choose the correct `.Values.mode` ("pv" | "sync").  PV mode will synchronize backup sets to external storage via a PersistentVolume that is created and mantained by the chart.  Sync mode will synchronize backup sets to other master nodes.
   1. PV Mode: Edit the `.Values.pv` section to reflect the target NFS service.
   2. Sync Mode:  This mode uses rsync over SSH to sync ("spray") the backup sets to other master nodes in the cluster.
      1. Designate master nodes to receive the backup sets by adding the `etcd-snapshot.example.com/role: mirror` label.
      2. 