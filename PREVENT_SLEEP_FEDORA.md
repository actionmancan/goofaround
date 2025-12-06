# Prevent Fedora Machine from Sleeping

Complete guide to keep your Fedora home server always awake and listening.

---

## Method 1: Disable Sleep/Suspend (Recommended)

### Disable Sleep via systemd-logind

```bash
# Edit logind configuration
sudo nano /etc/systemd/logind.conf
```

Find and uncomment/modify these lines:
```ini
HandleSuspendKey=ignore
HandleHibernateKey=ignore
HandleLidSwitch=ignore
HandleLidSwitchExternalPower=ignore
HandleLidSwitchDocked=ignore
IdleAction=ignore
```

**Or use sed to do it automatically:**
```bash
# Backup original config
sudo cp /etc/systemd/logind.conf /etc/systemd/logind.conf.backup

# Disable all sleep/hibernate actions
sudo sed -i 's/#HandleSuspendKey=suspend/HandleSuspendKey=ignore/' /etc/systemd/logind.conf
sudo sed -i 's/#HandleHibernateKey=hibernate/HandleHibernateKey=ignore/' /etc/systemd/logind.conf
sudo sed -i 's/#HandleLidSwitch=suspend/HandleLidSwitch=ignore/' /etc/systemd/logind.conf
sudo sed -i 's/#HandleLidSwitchExternalPower=ignore/HandleLidSwitchExternalPower=ignore/' /etc/systemd/logind.conf
sudo sed -i 's/#HandleLidSwitchDocked=ignore/HandleLidSwitchDocked=ignore/' /etc/systemd/logind.conf
sudo sed -i 's/#IdleAction=ignore/IdleAction=ignore/' /etc/systemd/logind.conf

# Add the settings if they don't exist
echo "HandleSuspendKey=ignore" | sudo tee -a /etc/systemd/logind.conf
echo "HandleHibernateKey=ignore" | sudo tee -a /etc/systemd/logind.conf
echo "HandleLidSwitch=ignore" | sudo tee -a /etc/systemd/logind.conf
echo "HandleLidSwitchExternalPower=ignore" | sudo tee -a /etc/systemd/logind.conf
echo "HandleLidSwitchDocked=ignore" | sudo tee -a /etc/systemd/logind.conf
echo "IdleAction=ignore" | sudo tee -a /etc/systemd/logind.conf

# Reload systemd-logind
sudo systemctl restart systemd-logind
```

---

## Method 2: Disable Screen Blanking (If Using GUI)

### For GNOME (Fedora Workstation)

```bash
# Disable screen blanking
gsettings set org.gnome.desktop.session idle-delay 0

# Disable automatic suspend
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing'

# Disable screen lock
gsettings set org.gnome.desktop.screensaver lock-enabled false
gsettings set org.gnome.desktop.screensaver idle-activation-enabled false
```

### Via GUI (if you have desktop access):
1. Open **Settings** → **Power**
2. Set **Automatic Suspend** to **Never**
3. Set **Screen Blank** to **Never**
4. Open **Settings** → **Privacy** → **Screen Lock**
5. Turn off **Automatic Screen Lock**

---

## Method 3: Disable Sleep via systemd (All Methods)

### Create a systemd override

```bash
# Create override directory
sudo mkdir -p /etc/systemd/system/systemd-logind.service.d/

# Create override file
sudo nano /etc/systemd/system/systemd-logind.service.d/override.conf
```

Add this content:
```ini
[Service]
Environment="SYSTEMD_LOG_LEVEL=debug"
```

Then reload:
```bash
sudo systemctl daemon-reload
sudo systemctl restart systemd-logind
```

---

## Method 4: Disable Sleep via BIOS/UEFI

If sleep is still happening, check BIOS settings:

1. **Enter BIOS** (F2 during boot on Dell Optiplex)
2. **Power Management** section:
   - Disable **ACPI Suspend Type** or set to **S1** (not S3)
   - Disable **Wake on LAN** sleep (if you want it always on)
   - Disable **Deep Sleep**
3. **Save and Exit**

---

## Method 5: Prevent Sleep via systemctl (Additional Safety)

```bash
# Mask sleep targets (prevents them from being activated)
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

# Verify they're masked
systemctl status sleep.target
# Should show: "Loaded: masked"
```

---

## Method 6: Disable Network Sleep (Important for Servers)

```bash
# Check current network sleep settings
cat /sys/class/net/*/power/control

# Disable network sleep for all interfaces
for iface in /sys/class/net/*; do
    echo "on" | sudo tee "$iface/power/control"
done

# Make it permanent - create a systemd service
sudo nano /etc/systemd/system/disable-network-sleep.service
```

Add this content:
```ini
[Unit]
Description=Disable network interface sleep
After=network.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'for iface in /sys/class/net/*; do echo on > "$iface/power/control"; done'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

Enable it:
```bash
sudo systemctl daemon-reload
sudo systemctl enable disable-network-sleep.service
sudo systemctl start disable-network-sleep.service
```

---

## Method 7: Keep SSH Connections Alive

Prevent SSH from timing out (helps keep system active):

```bash
# On Fedora server - edit SSH config
sudo nano /etc/ssh/sshd_config
```

Add or modify:
```
ClientAliveInterval 60
ClientAliveCountMax 3
TCPKeepAlive yes
```

Restart SSH:
```bash
sudo systemctl restart sshd
```

---

## Verify Sleep is Disabled

### Check current sleep settings:

```bash
# Check logind settings
cat /etc/systemd/logind.conf | grep -v "^#" | grep -v "^$"

# Check if sleep targets are masked
systemctl list-unit-files | grep -E "sleep|suspend|hibernate"

# Check current power state
systemctl status systemd-logind

# Check if system can sleep
systemctl status sleep.target suspend.target hibernate.target
```

### Test that sleep is disabled:

```bash
# Try to trigger sleep (should fail if disabled)
sudo systemctl suspend
# Should show error if properly disabled

# Check system uptime
uptime
# Should show continuous uptime
```

---

## Additional Server-Specific Settings

### Disable Automatic Updates Sleep (if enabled)

```bash
# Check if dnf-automatic is installed
rpm -q dnf-automatic

# If installed, make sure it doesn't trigger sleep
sudo systemctl status dnf-automatic.timer
```

### Keep Services Running

Your Podman services should already be set to restart, but verify:

```bash
# Check service restart policies
systemctl --user status homeserver-*.service

# All should show: Restart=always
```

---

## Quick One-Liner Setup

Run this complete setup script:

```bash
#!/bin/bash
# Complete sleep prevention setup

# Backup logind config
sudo cp /etc/systemd/logind.conf /etc/systemd/logind.conf.backup

# Disable sleep in logind
sudo sed -i 's/#HandleSuspendKey=suspend/HandleSuspendKey=ignore/' /etc/systemd/logind.conf
sudo sed -i 's/#HandleHibernateKey=hibernate/HandleHibernateKey=ignore/' /etc/systemd/logind.conf
sudo sed -i 's/#HandleLidSwitch=suspend/HandleLidSwitch=ignore/' /etc/systemd/logind.conf

# Add settings if missing
grep -q "HandleSuspendKey=ignore" /etc/systemd/logind.conf || echo "HandleSuspendKey=ignore" | sudo tee -a /etc/systemd/logind.conf
grep -q "HandleHibernateKey=ignore" /etc/systemd/logind.conf || echo "HandleHibernateKey=ignore" | sudo tee -a /etc/systemd/logind.conf
grep -q "HandleLidSwitch=ignore" /etc/systemd/logind.conf || echo "HandleLidSwitch=ignore" | sudo tee -a /etc/systemd/logind.conf

# Mask sleep targets
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

# Restart logind
sudo systemctl restart systemd-logind

# Disable network sleep
for iface in /sys/class/net/*; do
    echo "on" | sudo tee "$iface/power/control" 2>/dev/null
done

echo "✅ Sleep prevention configured!"
echo "Reboot to ensure all settings take effect: sudo reboot"
```

Save as `disable-sleep.sh`, make executable, and run:
```bash
chmod +x disable-sleep.sh
sudo ./disable-sleep.sh
```

---

## Troubleshooting

### If system still sleeps:

1. **Check BIOS settings** - Some BIOS settings override OS settings
2. **Check for other power management tools:**
   ```bash
   rpm -qa | grep -i power
   rpm -qa | grep -i sleep
   ```
3. **Check system logs:**
   ```bash
   journalctl -u systemd-logind | grep -i sleep
   journalctl | grep -i suspend
   ```
4. **Verify no other services are triggering sleep:**
   ```bash
   systemctl list-units | grep -i sleep
   systemctl list-units | grep -i suspend
   ```

### If SSH connections drop:

1. **Check network interface:**
   ```bash
   ip link show
   # Should all show UP state
   ```
2. **Check firewall:**
   ```bash
   sudo firewall-cmd --list-all
   ```
3. **Check system is actually running:**
   ```bash
   uptime
   systemctl status
   ```

---

## Recommended Settings Summary

For a home server, use these settings:

✅ **Disable all sleep/suspend** via systemd-logind  
✅ **Mask sleep targets** via systemctl  
✅ **Disable screen blanking** (if GUI)  
✅ **Disable network sleep**  
✅ **Keep SSH alive**  
✅ **Set BIOS to never sleep**  

---

## After Configuration

**Reboot to ensure all settings take effect:**
```bash
sudo reboot
```

**After reboot, verify:**
```bash
# Check uptime
uptime

# Check sleep targets are masked
systemctl status sleep.target

# Check logind settings
systemctl status systemd-logind
```

---

*Last Updated: December 2024*

