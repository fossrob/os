# os

## flameshot

workaround to get it to ask for screenshot permission:
- open flameshot
- open the config window
- make sure the config window has focus
- use the shortcut key combination

https://coreos.github.io/rpm-ostree/administrator-handbook/

https://coreos.github.io/rpm-ostree/compose-server/

https://coreos.github.io/rpm-ostree/container/

https://github.com/coreos/coreos-assembler
https://www.osbuild.org/news/2020-06-01-how-to-ostree-anaconda.html


https://coreos.github.io/rpm-ostree/treefile/

- recommends: boolean, optional: Install Recommends, defaults to true.
- units: Array of strings, optional: Systemd units to enable by default
- cliwrap: boolean, optional. Defaults to false. If enabled, rpm-ostree will replace binaries such as /usr/bin/rpm with wrappers that intercept unsafe operations, or adjust functionality.
The default is false out of conservatism; you likely want to enable this.
- readonly-executables: boolean, optional. Defaults to false (for backcompat). If enabled, rpm-ostree will remove the write bit from all executables.
The default is false out of conservatism; you likely want to enable this.
- remove-files: Array of files to delete from the generated tree.
- container: boolean, optional: Defaults to false. If true, then rpm-ostree will not do any special handling of kernel, initrd or the /boot directory. This is useful if the target for the tree is some kind of container which does not have its own kernel. This also implies several other options, such as tmp-is-dir: true and selinux: false.






Normally, RPM does not allow one package to overwrite files from another. But it can make sense to relax this restriction in some cases; for example, where one just wants to overwrite one kernel module without rebuilding the whole kernel package. The install --force-replacefiles option allows this.

# rpm-ostree install --force-replacefiles <pkg>


See man rpm-ostree for more. For example, there is an rpm-ostree initramfs command that enables local initramfs generation by rerunning dracut.


Another example with the kernel package; note you need to override exactly the set of installed packages:

$ ls -al kernel*.rpm
-rw-r--r--. 1 root root  8085596 Jan 27 22:02 kernel-4.18.0-123.el8.x86_64.rpm
-rw-r--r--. 1 root root 40709632 Jan 27 22:02 kernel-core-4.18.0-123.el8.x86_64.rpm
-rw-r--r--. 1 root root 32533504 Jan 27 22:02 kernel-modules-4.18.0-123.el8.x86_64.rpm
-rw-r--r--. 1 root root  8790996 Jan 27 22:02 kernel-modules-extra-4.18.0-123.el8.x86_64.rpm
$ rpm-ostree override replace ./kernel*.rpm


Filesystem layout

The only writable directories are /etc and /var. In particular, /usr has a read-only bind mount at all times. Any data in /var is never touched, and is shared across upgrades.

At upgrade time, the process takes the new default /etc, and adds your changes on top. This means that upgrades will receive new default files in /etc, which is quite a critical feature.

https://ostreedev.github.io/ostree/adapting-existing/


https://coreos.github.io/rpm-ostree/container/

Installing packages

You can use e.g. rpm-ostree install to install packages. This functions the same as with e.g. dnf or microdnf. It’s also possible to use rpm directly, e.g. rpm -Uvh https://mirror.example.com/iptables-1.2.3.rpm

Using “ostree container commit”

In a container build, it’s a current best practice to invoke this at the end of each RUN instruction (or equivalent). This will verify compatibility of /var, and also clean up extraneous files in e.g. /tmp

Creating base images

There is now an rpm-ostree compose image command which generates a new base image using a treefile:

$ rpm-ostree compose image --initialize --format=ociarchive workstation-ostree-config/fedora-silverblue.yaml fedora-silverblue.ociarchive

The --initialize command here will create a new image unconditionally. If not provided, the target image must exist, and will be used for change detection. You can also directly push to a registry:

$ rpm-ostree compose image --initialize --format=registry workstation-ostree-config/fedora-silverblue.yaml quay.io/example/exampleos:latest


Use a command like this to generate chunked images:

$ rpm-ostree compose container-encapsulate --repo=/path/to/repo fedora/35/x86_64/silverblue docker://quay.io/myuser/fedora-silverblue:35
