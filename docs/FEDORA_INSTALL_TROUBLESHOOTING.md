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

*Last Updated: December 2024*

