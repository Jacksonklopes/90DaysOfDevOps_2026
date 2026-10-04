# Day 13 – Linux Volume Management (LVM)

## 🎯 Goal

* Learn how LVM manages storage using Physical Volumes, Volume Groups, and Logical Volumes.
* Create, mount, and extend a logical volume.

---

## 🔐 Step 1 – Switch to Root

```bash
sudo -i
```
<img width="277" height="40" alt="Switch to root" src="https://github.com/user-attachments/assets/230b24b9-4aab-49a1-b948-28d6fd2a9fb3" />

- Switched to the root user for LVM operations.

---

## 📌 Task 1 – Check Current Storage

```bash
lsblk
```
<img width="712" height="470" alt="lsblk output" src="https://github.com/user-attachments/assets/7774da66-e076-4320-b2c9-ee2f02e75080" />

- Checked the available disks and partitions.

```bash
pvs
```
- Checked existing Physical Volumes.

```bash
vgs
```
- Checked existing Volume Groups.

```bash
lvs
```
- Checked existing Logical Volumes.

```bash
df -h
```
- Checked filesystem usage.

---

## 📌 Task 2 – Create Physical Volumes

```bash
pvcreate /dev/nvme1n1
pvcreate /dev/nvme2n1
pvs
```
<img width="490" height="110" alt="Physical Volumes" src="https://github.com/user-attachments/assets/a16bc255-5308-499e-9dd0-3bbc1de8d1ee" />

- Created Physical Volumes from the 10 GiB and 12 GiB EBS disks.

## 📌 Task 3 – Create Volume Group

```bash
vgcreate devops-vg /dev/nvme1n1 /dev/nvme2n1
vgs
```
<img width="536" height="107" alt="red-4" src="https://github.com/user-attachments/assets/e27ca9c8-91d9-42e2-a687-8de19c656603" />

- Combined both Physical Volumes into one Volume Group na
med `devops-vg`.

## 📌 Task 4 – Create Logical Volume

```bash
lvcreate -L 500M -n app-data devops-vg
lvs

```
<img width="749" height="105" alt="red-5" src="https://github.com/user-attachments/assets/c07806e0-53de-4d13-a58a-186c4e3e0031" />

- Created a 500 MB Logical Volume named `app-data`.

## 📌 Task 5 – Format and Mount

```bash
mkfs.ext4 /dev/devops-vg/app-data
```
<img width="499" height="178" alt="red-6" src="https://github.com/user-attachments/assets/2e753b02-82f9-4943-b485-302692fca487" />

- Formatted the Logical Volume with the ext4 filesystem.

```bash
mkdir -p /mnt/app-data
```
- Created a directory to use as the mount point.

```bash
mount /dev/devops-vg/app-data /mnt/app-data
```
- Mounted the Logical Volume to `/mnt/app-data`.

```bash
df -h /mnt/app-data
```

<img width="552" height="79" alt="red-7" src="https://github.com/user-attachments/assets/13db9ad2-5874-4cd1-ba23-13f9729ee1d6" />

- Verified the mounted volume and its available space.

## 📌 Task 6 – Extend the Volume

```bash
lvextend -L +2G /dev/devops-vg/app-data
```
<img width="846" height="125" alt="red-8" src="https://github.com/user-attachments/assets/d1f1be79-77db-4629-bc6a-a1dbe2348303" />

- Increased the Logical Volume by 2 GB.

```bash
resize2fs /dev/devops-vg/app-data
```
<img width="737" height="137" alt="red-9" src="https://github.com/user-attachments/assets/d91a3a88-3453-4d73-8deb-9c3cf35608dc" />

- Expanded the ext4 filesystem to use the new space.

```bash
df -h /mnt/app-data
```
- you can now verify the new filesystem size.

## 🧠 What I Learned

* Learned how to check disks and storage using `lsblk`, `pvs`, `vgs`, `lvs`, and `df -h`.
* Learned how to use two AWS EBS disks as LVM storage.
* Learned how to create Physical Volumes from the EBS disks using `pvcreate`.
* Learned how to combine both disks into the `devops-vg` storage group using `vgcreate`.
* Learned how to create a 500 MB `app-data` Logical Volume using `lvcreate`.
* Learned how to format the Logical Volume with `ext4` using `mkfs.ext4`.
* Learned how to create a mount point and mount the volume using `mount`.
* Learned how to increase the Logical Volume by 2 GB using `lvextend`.
* Learned how to expand the filesystem after increasing the volume using `resize2fs`.
* Learned how to verify the final storage size using `df -h`.

## 🛠️ Commands Used

| Command | Purpose |
|---|---|
| `sudo -i` | Switch to root user |
| `lsblk` | Check disks and partitions |
| `pvs` | Check Physical Volumes |
| `vgs` | Check Volume Groups |
| `lvs` | Check Logical Volumes |
| `df -h` | Check filesystem usage |
| `pvcreate /dev/nvme1n1` | Create a Physical Volume |
| `pvcreate /dev/nvme2n1` | Create a Physical Volume |
| `vgcreate devops-vg /dev/nvme1n1 /dev/nvme2n1` | Create a Volume Group |
| `lvcreate -L 500M -n app-data devops-vg` | Create a 500 MB Logical Volume |
| `mkfs.ext4 /dev/devops-vg/app-data` | Create an ext4 filesystem |
| `mkdir -p /mnt/app-data` | Create a mount directory |
| `mount /dev/devops-vg/app-data /mnt/app-data` | Mount the Logical Volume |
| `lvextend -L +2G /dev/devops-vg/app-data` | Increase the Logical Volume by 2 GB |
| `resize2fs /dev/devops-vg/app-data` | Expand the filesystem |
| `umount /mnt/app-data` | Unmount the volume |
| `lvremove /dev/devops-vg/app-data` | Remove the Logical Volume |
| `vgremove devops-vg` | Remove the Volume Group |
| `pvremove /dev/nvme1n1` | Remove the Physical Volume |
| `pvremove /dev/nvme2n1` | Remove the Physical Volume |
| `pvs` / `vgs` / `lvs` | Verify LVM removal |


## LVM — Why Each Step Is Needed

**Why `lsblk`?**
To see available disks and their sizes.

**Why create a Physical Volume (PV)?**
To prepare a disk for use by LVM.

**Why create a Volume Group (VG)?**
To combine multiple Physical Volumes into one storage pool, used to create Logical Volumes.

**Why LVM?**
To manage and resize storage flexibly.

**Why format with ext4?**
A freshly created Logical Volume is just raw, unformatted disk space — formatting with ext4 makes it usable for actually storing files.

**Why resize the filesystem after extending the LVM?**
Extending the Logical Volume only adds raw space — the filesystem itself still needs to be resized separately so it can actually use the newly added space.
