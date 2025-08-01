# Fuck You, DPI!
Dynamically bypass deep packet inspection (DPI) in Android.

### What is it?
FuckYouDPI is a tool that dynamically bypasses Deep Packet Inspection (DPI) in Android. It comes as a systemless module.

### How does it work?
FuckYouDPI runs TPWS, and runs the internet connection of user-specified target apps through that TPWS instance. That way, DPI is bypassed without other things like VPNs.
* TPWS is a tool that bypasses DPI for user-specified domains. Target domains are user-specified on FuckYouDPI too.

### Requirements
* Android 8.1 Oreo or newer.
* Magisk, KernelSU or APatch installed.
* KsuWebUI (only for Magisk).

### How to install and uninstall?
FuckYouDPI can be installed and uninstalled just like any other Magisk/KernelSU/APatch module.

### Pros and cons
* Pros:
  * Applies dynamically, doesn't touch unspecified apps and domains.
  * Automatic after configuration, no fake VPN or setting proxy yourself.
  * Harder to detect.
  * Easily manageable and updatable.
* Cons:
  * **Requires root**, so not installable on devices that have fully locked bootloaders.

### Using `fydpiutil`, the command line utility of FuckYouDPI
`fydpiutil` is the integrated command line utility of this module. You can use it on a rooted session of a terminal app (like Termux). With `fydpiutil`;
* Apply or deapply to an app.
* Enable or disable to a domain.
* Enable or disable a trick.
* For usage, refer to the [FuckYouDPI wiki](https://github.com/mrdoge0/FuckYouDPI/wiki/Usage-of-fydpiutil).

### How to build?
* Clone the repository.
  ```git clone https://github.com/mrdoge0/FuckYouDPI --depth=1 -b main && cd FuckYouDPI```
* TPWS binaries in the repository are directly built from the [bol-van](https://github.com/bol-van)'s official [Zapret](https://github.com/bol-van/zapret) source, but if you're too paranoid, you can build them yourself. Just be sure that you're building **static** binaries.
* Pack everything.
  ```zip -r out.zip *```
* Enjoy.

### Special thanks for
* [bol-van](https://github.com/bol-van) for creating [TPWS](https://github.com/bol-van/zapret/tree/master/tpws).
* [Zackptg5](https://github.com/Zackptg5) for creating [Magisk Module Template Extended (MMT Extended)](https://github.com/Zackptg5/MMT-Extended).
