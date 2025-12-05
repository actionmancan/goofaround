# Fedora Installation Troubleshooting Guide

This document captures the troubleshooting steps taken during Fedora installation on a Dell Optiplex system.

## Issues Encountered and Solutions

### Issue 1: USB Boot Error - "Fedora-WS-Live-43 does not exist"

**Symptoms:**
- System enters emergency mode during boot
- Error message: `/dev/disk/by-label/Fedora-WS-Live-43 does not exist`
- Error message: `/dev/root does not exist`
- Warning: "Not all disks have been found"

**Root Cause:**
The USB drive was not properly created with the correct Fedora filesystem label. The USB had GRUB bootloader files but was missing the proper Fedora installation media structure.

**Solution:**
1. Downloaded Fedora Media Writer from https://getfedora.org/en/workstation/download/
2. Downloaded Fedora ISO image
3. Used Fedora Media Writer to properly create the bootable USB:
   - Select "Custom Image"
   - Choose downloaded Fedora ISO
   - Select USB drive
   - Click "Write to Disk"
4. This ensures proper labeling (`Fedora-WS-Live-XX`) and boot structure

**Alternative Method (Command Line):**
```bash
# On macOS
diskutil list  # Identify USB drive
diskutil unmountDisk /dev/diskX
sudo dd if=/path/to/Fedora-Workstation-Live-x86_64-XX.iso of=/dev/rdiskX bs=1m
diskutil eject /dev/diskX
```

**Note:** Using `dd` directly may not set proper labels. Fedora Media Writer is recommended.

---

### Issue 2: Fedora Media Writer Won't Open on macOS

**Symptoms:**
- App won't launch after installation
- macOS security warning

**Root Cause:**
macOS Gatekeeper quarantines downloaded applications from unidentified developers.

**Solution:**
```bash
# Remove quarantine attribute
xattr -d com.apple.quarantine /Applications/FedoraMediaWriter.app

# Then open the app
open -a FedoraMediaWriter
```

**Alternative:**
- Right-click app in Finder → "Open"
- Approve in System Settings → Privacy & Security if prompted

---

### Issue 3: "No Disks Selected" in Fedora Installer

**Symptoms:**
- Fedora installer starts successfully
- Installation screen shows "No disks selected"
- Cannot proceed with installation

**Root Cause:**
Dell Optiplex systems (and many pre-built PCs) ship with Intel RST (Rapid Storage Technology) enabled in RAID mode. Linux installers cannot detect disks in RAID mode without proprietary drivers.

**Solution:**
1. **Enter BIOS:**
   - Power on Dell Optiplex
   - Press **F2** repeatedly during boot (or F12 for boot menu, then select "BIOS Setup")

2. **Change SATA Mode:**
   - Navigate to **"System Configuration"** or **"Advanced"** tab
   - Find **"SATA Operation"** or **"SATA Mode"**
   - Change from **"RAID On"** or **"Intel RST"** to **"AHCI"**
   - Save and Exit (F10)
   - Confirm save

3. **Reboot:**
   - Boot from Fedora USB again
   - Installer should now detect the disk

**Important Notes:**
- This change is safe for fresh Linux installations
- If Windows was previously installed, changing to AHCI may cause Windows boot issues (not applicable for fresh Fedora install)
- AHCI is the standard mode for Linux and provides better compatibility

---

### Issue 4: Fedora Won't Boot After Installation

**Symptoms:**
- Installation completes successfully
- System reboots but doesn't boot into Fedora
- May show "No bootable device" or boot loop
- May boot to BIOS/UEFI instead of Fedora

**Common Causes and Solutions:**

#### 1. Boot Order Issue (Most Common)

**Problem:** BIOS is trying to boot from USB or wrong device first.

**Solution:**
1. Enter BIOS (F2 during boot)
2. Go to **"Boot"** or **"Boot Sequence"** tab
3. Set **"Hard Drive"** or your Fedora disk as **first boot device**
4. Remove USB drive from boot sequence (or set it last)
5. Save and Exit (F10)
6. Reboot

#### 2. Secure Boot Blocking GRUB

**Problem:** Secure Boot is preventing GRUB bootloader from loading.

**Solution:**
1. Enter BIOS (F2)
2. Go to **"Security"** tab
3. Find **"Secure Boot"** and disable it
4. Save and Exit
5. Reboot

**Note:** You can re-enable Secure Boot after configuring it properly, but disable it for initial boot.

#### 3. UEFI vs Legacy BIOS Mismatch

**Problem:** Installation was done in UEFI mode but BIOS is set to Legacy, or vice versa.

**Solution:**
1. Enter BIOS (F2)
2. Go to **"Boot"** tab
3. Check **"Boot Mode"** or **"UEFI/Legacy Boot"**
4. Ensure it matches how you installed:
   - If installed in UEFI mode: Set to **"UEFI"**
   - If installed in Legacy mode: Set to **"Legacy"** or **"CSM"**
5. Save and Exit
6. Reboot

#### 4. GRUB Not Installed Correctly

**Problem:** Bootloader wasn't installed during installation.

**Solution - Boot from USB and Repair:**
1. Boot from Fedora USB (same one used for installation)
2. Select **"Troubleshooting"** → **"Rescue a Fedora system"**
3. Mount your installed system:
   ```bash
   # Find your root partition
   lsblk
   # Mount it (replace /dev/sda2 with your root partition)
   mount /dev/sda2 /mnt
   # Mount boot partition if separate
   mount /dev/sda1 /mnt/boot
   # Chroot into installed system
   chroot /mnt
   ```
4. Reinstall GRUB:
   ```bash
   # For UEFI systems
   grub2-install /dev/sda  # Replace sda with your disk
   grub2-mkconfig -o /boot/grub2/grub.cfg
   
   # For Legacy BIOS systems
   grub2-install --target=i386-pc /dev/sda
   grub2-mkconfig -o /boot/grub2/grub.cfg
   ```
5. Exit chroot and reboot

#### 5. Boot Partition Not Set Correctly

**Problem:** EFI boot partition wasn't created or isn't properly configured.

**Solution:**
1. Boot from USB
2. Use **"Troubleshooting"** → **"Rescue a Fedora system"**
3. Check partitions:
   ```bash
   lsblk
   fdisk -l
   ```
4. Verify EFI partition exists (usually ~500MB, FAT32)
5. If missing, you may need to reinstall with proper partitioning

#### 6. Fast Boot / Quick Boot Enabled

**Problem:** Fast Boot skips some initialization that Linux needs.

**Solution:**
1. Enter BIOS (F2)
2. Find **"Fast Boot"** or **"Quick Boot"** in Boot settings
3. Disable it
4. Save and Exit
5. Reboot

#### 7. Check Boot Menu

**Quick Test:**
1. Press **F12** during boot (Dell boot menu)
2. Look for **"Fedora"** or **"Linux"** in boot options
3. If it appears, select it manually
4. If it works, fix boot order in BIOS

#### 8. Black Screen After Boot

**Problem:** System boots but shows black screen (graphics driver issue).

**Symptoms:**
- Boot process seems to work (no errors)
- Screen goes black after GRUB/bootloader
- May see cursor or nothing at all
- Common on systems with integrated graphics or older GPUs

**Solution 1: Boot with Nomodeset (Temporary Fix)**
1. Boot from Fedora USB again
2. At GRUB menu, press **`e`** to edit boot parameters
3. Find the line starting with `linux` or `linuxefi`
4. Add `nomodeset` to the end of that line (before `quiet` if present)
5. Press **Ctrl+X** or **F10** to boot
6. If this works, make it permanent (see Solution 2)

**Solution 2: Make Nomodeset Permanent**
1. Boot with nomodeset (Solution 1) to get into system
2. Edit GRUB configuration:
   ```bash
   sudo nano /etc/default/grub
   ```
3. Find the line: `GRUB_CMDLINE_LINUX=`
4. Add `nomodeset` to it:
   ```bash
   GRUB_CMDLINE_LINUX="rhgb quiet nomodeset"
   ```
   Or if you see `GRUB_CMDLINE_LINUX_DEFAULT`, edit that line instead.
5. Save the file (Ctrl+X, then Y, then Enter)
6. Update GRUB:
   ```bash
   sudo grub2-mkconfig -o /boot/grub2/grub.cfg
   ```
7. Reboot - nomodeset will now be permanent

**Solution 3: Install Graphics Drivers**
1. Boot with nomodeset to get into system
2. Identify your graphics card:
   ```bash
   lspci | grep VGA
   ```
3. Install appropriate drivers:
   ```bash
   # For Intel integrated graphics
   sudo dnf install -y xorg-x11-drv-intel
   
   # For NVIDIA (if applicable)
   sudo dnf install -y akmod-nvidia
   
   # For AMD (if applicable)
   sudo dnf install -y xorg-x11-drv-amdgpu
   ```
4. Reboot (remove nomodeset after drivers are installed)

**Solution 4: Try Different Display Port**
- If using HDMI, try VGA or DisplayPort
- Some systems have issues with specific ports
- Try connecting to different video output

**Solution 5: Boot to Text Mode**
1. At GRUB menu, press **`e`**
2. Find `linux` line and add `systemd.unit=multi-user.target` or `3`
3. Boot to text mode (no GUI)
4. Install graphics drivers from command line
5. Reboot to graphical mode: `sudo systemctl set-default graphical.target`

**Solution 6: Check if System is Actually Running**
- Press **Ctrl+Alt+F2** (or F3-F6) to switch to text console
- If you see login prompt, system is running but GUI isn't
- Log in and troubleshoot graphics from there

---

## Complete Installation Checklist

### Pre-Installation
- [ ] Download Fedora ISO from https://getfedora.org/
- [ ] Download Fedora Media Writer
- [ ] Create bootable USB using Fedora Media Writer
- [ ] Verify USB boots correctly

### BIOS Configuration (Dell Optiplex)
- [ ] Enter BIOS (F2 during boot)
- [ ] Change SATA Operation: RAID → AHCI
- [ ] (Optional) Disable Secure Boot if needed
- [ ] Save and exit BIOS

### Installation
- [ ] Boot from USB
- [ ] Verify disk is detected
- [ ] Complete Fedora installation
- [ ] Reboot into installed system

### Post-Installation
- [ ] Update system: `sudo dnf update -y`
- [ ] Install Podman: `sudo dnf install -y podman`
- [ ] Install Python: `sudo dnf install -y python3 python3-pip python3-venv`
- [ ] Clone project repository
- [ ] Run `make setup` and `make init-configs`

---

## Additional Troubleshooting Tips

### If Disk Still Not Detected After AHCI Change

1. **Check Disk in BIOS:**
   - Verify disk appears in BIOS under "System Information" or "Storage"
   - If not visible, check physical connections

2. **Disable Secure Boot:**
   - In BIOS Security tab, disable Secure Boot
   - Some systems require this for Linux installation

3. **Try Manual Partitioning:**
   - In Fedora installer, select "Custom" or "Manual" partitioning
   - This sometimes reveals disks that auto-detection misses

4. **Check Boot Mode:**
   - Ensure UEFI boot mode matches disk partition scheme
   - Try switching between UEFI and Legacy BIOS if needed

5. **NVMe Driver Issues:**
   - Some NVMe drives need additional drivers
   - Try booting with `nomodeset` kernel parameter
   - Press `e` at GRUB menu, add `nomodeset` to kernel line

---

## System Information

**Hardware:** Dell Optiplex (model not specified)
**OS:** Fedora Workstation (version installed via USB)
**Installation Date:** December 2024

---

## References

- Fedora Download: https://getfedora.org/
- Fedora Media Writer: https://getfedora.org/en/workstation/download/
- Dell Optiplex BIOS Guide: Dell support documentation
- Intel RST to AHCI: Common Linux installation requirement

---

## Lessons Learned

1. **Always use Fedora Media Writer** for creating bootable USBs - it handles all the details automatically
2. **Dell Optiplex systems require AHCI mode** - RAID mode won't work with Linux installers
3. **macOS Gatekeeper** requires removing quarantine attributes for downloaded apps
4. **BIOS settings are critical** - SATA mode is often overlooked but essential for Linux installation

---

### Issue 5: Setting Up SSH Access

**Goal:** Enable SSH access from Mac to Fedora machine for remote management.

#### Step 1: Install and Enable SSH on Fedora

```bash
# Install SSH server
sudo dnf install -y openssh-server

# Start SSH service
sudo systemctl start sshd

# Enable SSH to start on boot
sudo systemctl enable sshd

# Configure firewall to allow SSH
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --reload

# Verify SSH is running
sudo systemctl status sshd
```

#### Step 2: Find Fedora IP Address

On Fedora machine:
```bash
hostname -I
# Or
ip addr show
```

Look for IP address like `192.168.1.167`

#### Step 3: Test Connectivity from Mac

From Mac terminal:
```bash
# Test ping
ping -c 3 192.168.1.167

# Test SSH port
nc -zv 192.168.1.167 22
```

#### Step 4: Enable Password Authentication (Temporary)

If SSH connection is refused or password auth is disabled:

On Fedora:
```bash
sudo nano /etc/ssh/sshd_config
```

Ensure these lines are set:
```
PasswordAuthentication yes
PubkeyAuthentication yes
```

Then restart SSH:
```bash
sudo systemctl restart sshd
```

#### Step 5: Set Up SSH Keys (Recommended)

**On Mac:**

1. Generate SSH key (if you don't have one):
   ```bash
   ssh-keygen -t ed25519 -C "your_email@example.com"
   ```
   (Press Enter to accept defaults)

2. Copy public key to Fedora:
   ```bash
   ssh-copy-id username@192.168.1.167
   ```
   (Enter password when prompted)

3. Test passwordless SSH:
   ```bash
   ssh username@192.168.1.167
   ```

**Using Cursor Remote SSH:**

1. In Cursor on Mac, press `Cmd+Shift+P`
2. Type "Remote-SSH: Connect to Host"
3. Enter: `username@192.168.1.167`
4. Cursor will connect and allow editing files remotely

#### Troubleshooting SSH Issues

**"Connection refused":**
- SSH server not running: `sudo systemctl start sshd`
- Firewall blocking: `sudo firewall-cmd --add-service=ssh --permanent && sudo firewall-cmd --reload`

**"Permission denied":**
- Password authentication disabled: Enable in `/etc/ssh/sshd_config`
- Wrong password: Verify username and password
- Set up SSH keys for passwordless access

**"No route to host":**
- Machines on different networks: Ensure both on same WiFi network
- Wrong IP address: Check IP with `hostname -I` on Fedora

---

*Last Updated: December 2024*

