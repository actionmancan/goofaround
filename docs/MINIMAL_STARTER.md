# Minimal Starter Build - Proof of Concept

**Goal**: Test the system with 1 camera + 1 light for ~$200-250

This is the **smartest** way to start - validate everything works before buying more hardware!

---

## 🎯 What You'll Prove

✅ Podman Quadlets work on your hardware  
✅ Home Assistant connects to devices  
✅ Frigate can handle your camera  
✅ Zigbee2MQTT pairs devices  
✅ You understand the system  
✅ **Then** expand with confidence!

---

## 💰 Absolute Minimum Build (~$200-250)

### Option A: Use What You Have (~$50-80)

**If you already have a PC/laptop:**

#### Server: Your Existing Computer ($0)
- Any PC/laptop from last 10 years
- Minimum: 4GB RAM, dual-core CPU
- Install Linux (Fedora/Ubuntu)
- **Cost**: FREE

#### Camera: Wyze Cam v3 ($25-35)
- **Where**: wyze.com, Best Buy
- **Price**: $25-35 (often on sale)
- **Why**: Cheap, flash with RTSP firmware
- **RTSP Firmware**: github.com/gtxaspec/wz_mini_hacks
- **Limitation**: Wi-Fi only (not ideal, but works for testing)

**OR: Cheap ONVIF Camera ($40-50)**
- **Amcrest IP2M-841** (Wi-Fi, ONVIF/RTSP)
- **Where**: eBay (used), Newegg
- **Price**: ~$40-50

#### Smart Bulb: IKEA Trådfri ($8-10)
- **Where**: IKEA stores or IKEA.com
- **Price**: $8-10
- **Why**: Cheapest Zigbee bulb that works perfectly

#### Zigbee Coordinator: Sonoff Dongle ($28-30)
- **Where**: CloudFree.shop (US reseller) ⭐ FAST
- **Price**: $28-30 with fast shipping
- **Ship time**: 3-5 days from US
- **Alternative**: AliExpress Premium Shipping (5-7 days, ~$30-35)

**Total Option A: $65-95** (if you have a computer, with fast shipping)

---

### Option B: Used Mini PC Build (~$200-250)

#### Server: Used Dell Optiplex Micro ($120-160)
- **Where**: 
  - **eBay** - Search "Dell Optiplex 3040 Micro i3"
  - **Facebook Marketplace** - Local pickup, no shipping
  - **r/homelabsales** - Often great deals
- **Specs to look for**:
  - i3-6100T or better (i5 preferred)
  - 8GB RAM minimum
  - 128GB SSD minimum (or add $25 for 256GB)
- **Price Range**: $120-160
- **Why**: 
  - Reliable enterprise hardware
  - Low power (~15-20W)
  - Quiet
  - Can upgrade RAM later

**Search Terms for eBay**:
- "Dell Optiplex 3040 Micro"
- "Dell Optiplex 7040 Micro"  
- "HP EliteDesk 800 G2 Mini"
- "Lenovo ThinkCentre M710q Tiny"

#### Camera: Used PoE Camera ($30-50)
- **Where**: eBay, Facebook Marketplace, r/homelabsales
- **Search for**:
  - "Reolink RLC-410" (used)
  - "Amcrest IP camera PoE"
  - "Hikvision 4MP PoE" (older models)
- **Price**: $30-50
- **Why**: Test before buying new

**OR: New Cheap PoE Camera ($50-60)**
- **Amcrest IP4M-1041B**
  - **Where**: eBay (new), Newegg
  - **Price**: ~$50-60 single

#### Network: Skip PoE Switch ($0)
- **Use PoE Injector**: $10-15 (TP-Link TL-PoE150S)
  - **Where**: Newegg, Best Buy, Monoprice
  - Powers 1 camera without a switch
  - Add switch later when you expand

#### Smart Bulb: IKEA Trådfri ($8-10)
- **Where**: IKEA
- **Price**: $8-10

#### Zigbee Coordinator: Sonoff Dongle ($18)
- **Where**: itead.cc, AliExpress  
- **Price**: $15-20

**Total Option B: $188-285** (with fast shipping from US sellers)

---

## 🎓 Testing Phase (1-2 weeks)

### Week 1: Setup & Deploy
```bash
# On your server
cd ~/Documents/GitHub
git clone [your repo]
cd goofaround

# Setup
make setup
make init-configs

# Update configs for 1 camera
vim configs/frigate/config.yml
vim configs/zigbee2mqtt/configuration.yaml

# Deploy
make test
make deploy
```

### Week 2: Test Everything

**Test Camera**:
- [ ] Can you see live stream in Frigate?
- [ ] Does motion detection work?
- [ ] Are recordings saving?
- [ ] Is object detection working (person, car)?

**Test Smart Bulb**:
- [ ] Does Zigbee2MQTT discover it?
- [ ] Does it appear in Home Assistant?
- [ ] Can you control it from Home Assistant?
- [ ] Does on/off work reliably?

**Test Automation**:
- [ ] Create simple automation (motion → light on)
- [ ] Does it work reliably?
- [ ] Check logs for errors

**Test System**:
- [ ] Does everything restart after reboot?
- [ ] Are services stable?
- [ ] Is CPU/RAM usage acceptable?

---

## 📊 Success Metrics

After 1-2 weeks, ask yourself:

### ✅ Keep Going If:
- Camera streams reliably
- Motion detection works
- Light responds quickly
- You understand the system
- You're excited to expand
- Server handles load fine

### 🤔 Re-evaluate If:
- Camera streams are choppy (might need better server)
- Zigbee device drops (might need better coordinator placement)
- System feels slow (might need more RAM)
- Too complicated (might want different solution)

---

## 🚀 Expansion Path After Testing

### Phase 2: Add More (~$150-200)
If test phase successful:
- [ ] 2-3 more cameras
- [ ] 3-5 more smart bulbs
- [ ] PoE switch (if using PoE cameras)
- [ ] 2TB storage drive

### Phase 3: Polish (~$100-150)
- [ ] Better cameras for important areas
- [ ] Smart switches for permanent installs
- [ ] Sensors (door, motion)
- [ ] UPS for power protection

### Phase 4: Optimize (~$100)
- [ ] Coral TPU for better AI
- [ ] More storage
- [ ] Additional sensors

---

## 🛒 Where to Buy - FAST SHIPPING (Arrive by End of Week)

### **Priority: Local Pickup (Same Day!)**

1. **Facebook Marketplace** ⭐ FASTEST
   - Search: "Dell Optiplex Micro" or "Mini PC"
   - Filter: "Available today"
   - **Pickup today**: Test it, pay cash, done!
   - **Price**: $100-160 for mini PC
   - **Pro tip**: Bring USB drive with Linux, test before buying

2. **IKEA** (If near you)
   - **Smart bulb**: $8-10, in stock
   - **Pickup today** or same-day delivery (some cities)
   - Check stock: IKEA.com → "Check stock"

3. **Best Buy** (In-store pickup)
   - **Smart bulbs**: Sengled, Philips Hue ($10-25)
   - **Wyze Cam**: Sometimes in stock ($25-35)
   - Order online → Pickup same day
   - bestbuy.com → Filter "Store Pickup"

4. **Microcenter** (If near you - 25 US locations)
   - **Mini PCs**: Often have refurb/open box
   - **PoE injectors**: $10-15
   - **Ethernet cables**: $5-10
   - **Same day pickup**

5. **Local Corporate Surplus/Liquidators**
   - Google: "IT liquidation near me" or "computer recycling"
   - Often have Dell/HP mini PCs: $80-150
   - **Same day pickup**
   - Call first to check stock

### **Fast Online Shipping (2-3 Days)**

1. **Best Buy** (Free 2-day shipping)
   - Smart bulbs: 2 days
   - Some cameras: 2 days
   - bestbuy.com

2. **B&H Photo** (Free expedited to most states)
   - **Ships same day if ordered by 2pm ET**
   - **Usually arrives in 2-3 days**
   - Cameras, PoE injectors, network gear
   - bhphotovideo.com

3. **Newegg** (Fast shipping available)
   - **Newegg Prime**: 2-day shipping
   - Mini PCs, PoE injectors, cables
   - Choose "ships from US" (not marketplace)
   - newegg.com

4. **eBay** (Fast shipping sellers)
   - Filter: "Ships from United States"
   - Filter: "Get it fast"
   - Look for: "Free 3-day shipping"
   - Many refurbishers have 2-3 day shipping

### **Zigbee Coordinator (PROBLEM: Slow from China)**

**Option 1: Pay for Fast Shipping ($35 total)**
- **Sonoff Dongle from AliExpress**: 
  - Choose "AliExpress Premium Shipping" ($10-15 extra)
  - **Arrives in 5-7 days** (might make it!)
  - Total: ~$30-35

**Option 2: Buy from US Reseller (Faster but pricier)**
- **CloudFree.shop** (US-based Sonoff reseller)
  - Sonoff Zigbee Dongle: ~$28-30 shipped
  - **Ships within 1 business day**
  - **Arrives in 3-5 days**
  - cloudfree.shop

**Option 3: Get ConBee II Instead (In Stock US)**
- **Buy from US retailers**:
  - eBay (some US sellers): ~$35-45
  - Search: "ConBee II USB" + filter "Ships from US"
  - **Arrives 2-4 days**

**Option 4: Buy Philips Hue Bridge Instead (Plan B)**
- **Best Buy, Target, B&H**: $50-60
  - Includes bridge (works as coordinator)
  - **Available for same-day pickup**
  - Can use with Home Assistant
  - Limitation: Only Hue ecosystem initially
  - Can add real Zigbee coordinator later

### **Recommended Fast Path (1 Week)**

**TODAY/TOMORROW**:
- [ ] Facebook Marketplace: Buy used mini PC (pickup today)
- [ ] IKEA: Get Trådfri bulb (pickup or order for delivery)
- [ ] Best Buy: Order smart bulb for pickup (if no IKEA)

**TODAY (Order Online)**:
- [ ] B&H Photo: Order camera (2-3 day ship)
- [ ] CloudFree.shop: Order Sonoff dongle (3-5 day ship)
  - OR Best Buy: Get Hue Bridge for pickup (fallback)

**THIS WEEKEND**:
- Install Linux on mini PC
- Set up project

**EARLY NEXT WEEK** (Monday-Tuesday):
- Camera arrives
- Zigbee coordinator arrives
- Start testing!

---

## 💡 Pro Tips for Minimal Start

### 1. Start with What You Have
- Old laptop? Use it!
- Old desktop? Install Linux!
- Even a Raspberry Pi 4 (4GB+) works for 1-2 cameras

### 2. Buy Used, Test, Then Invest
- Enterprise hardware is built to last
- Dell/HP business machines are bombproof
- Easy to find parts

### 3. Use Wi-Fi Cameras First (if needed)
- Not ideal, but works for testing
- Cheap Wyze cameras with RTSP firmware
- Move to PoE later when expanding

### 4. Test at IKEA First
- IKEA has Trådfri display models
- Make sure you like smart bulbs
- Then buy to test with your system

### 5. Don't Buy Storage Yet
- Linux root partition enough for testing
- Buy surveillance drive after you know recording retention needs

---

## 📝 Minimal Shopping List

Print this and check off as you buy:

### Required (~$50-160):
- [ ] **Server** - Used mini PC or use existing computer
- [ ] **Camera** - 1x cheap PoE or Wi-Fi camera  
- [ ] **Zigbee Coordinator** - Sonoff USB dongle
- [ ] **Smart Bulb** - 1x IKEA Trådfri

### Optional (~$10-50):
- [ ] PoE Injector (if using PoE camera without switch)
- [ ] USB flash drive (backup configs)
- [ ] Ethernet cable (if needed)

---

## 🎯 Example: Absolute Minimum

**Total: $51** (using existing computer)

Shopping list:
1. **Wyze Cam v3**: $25 (wyze.com)
2. **IKEA Trådfri Bulb**: $8 (IKEA)
3. **Sonoff Zigbee Dongle**: $18 (AliExpress)

**What you can test**:
- Full Home Assistant setup
- Camera recording and detection
- Smart bulb control
- Automation (camera motion → light on)
- System stability
- **All the software and configuration**

Then if it works, invest in:
- Better server ($150-400)
- Better cameras ($40-80 each)
- PoE switch ($50-75)
- More smart devices

---

## 🧪 The Test-Driven Hardware Approach

This mirrors your TDD software approach:

### 1. Red (Hypothesis)
"I think this home automation system will work for me"

### 2. Green (Minimal Viable Test)
- Deploy minimal system
- Test core functionality
- Validate assumptions

### 3. Refactor (Expand & Optimize)
- Add more cameras where needed
- Upgrade components that bottleneck
- Optimize based on real usage

**Just like TDD: Don't write code (buy hardware) you don't need yet!**

---

## ❓ FAQ

**Q: Is a used Dell Optiplex really good enough?**  
A: Yes! A 6th gen i5 can handle 4-6 cameras with CPU detection. Later add Coral TPU for more.

**Q: Can I really test with just Wi-Fi cameras?**  
A: Yes for testing. Wyze v3 with RTSP firmware works. Switch to PoE when expanding.

**Q: What if I'm not near an IKEA?**  
A: Order online from IKEA.com, or get Sengled bulbs from Best Buy (~$10-15 each).

**Q: Should I buy storage drive now?**  
A: No. Test first. Linux root partition is fine for 1-2 days of 1 camera footage.

**Q: Used camera safe to buy?**  
A: Yes if it's an known brand (Reolink, Amcrest). Factory reset it. Check for ONVIF/RTSP support.

---

## ✅ Decision Time

After your 1-2 week test:

### 🎉 System Works! (Most likely outcome)
→ Check `docs/BLACK_FRIDAY_BUILD.md`  
→ Invest in proper hardware  
→ Expand with confidence

### 🤷 Not Sure Yet
→ Add 1-2 more devices  
→ Test another week  
→ No rush

### 🛑 Doesn't Work For You  
→ You only spent $50-250  
→ Sell hardware on eBay/r/homelabsales  
→ Try different solution

---

## 🚀 7-Day Fast Start Plan

### **Day 1-2 (Today/Tomorrow) - LOCAL SHOPPING**

**Morning:**
- [ ] Check Facebook Marketplace for mini PC
- [ ] Check local IKEA stock online
- [ ] Check Best Buy for smart bulbs (in-store pickup)

**Afternoon/Evening:**
- [ ] Buy mini PC from Facebook (test before buying!)
- [ ] Pick up smart bulb from IKEA or Best Buy
- [ ] Order Zigbee coordinator (CloudFree.shop or pay for fast AliExpress)

**Online Orders (ship while you shop local):**
- [ ] B&H Photo: Order camera for 2-3 day delivery
- [ ] Newegg: Order PoE injector (if using PoE camera)

### **Day 3-4 (Weekend) - SETUP**

**While waiting for shipments:**
- [ ] Install Linux on mini PC (Fedora or Ubuntu)
- [ ] Install Podman: `sudo dnf install podman`
- [ ] Clone project: `git clone [repo]`
- [ ] Run: `make setup`
- [ ] Run: `make init-configs`
- [ ] Test that containers work: `make test-unit`

### **Day 5-7 (Early Next Week) - DEPLOY**

**Monday/Tuesday - Hardware Arrives:**
- [ ] Camera arrives (B&H 2-3 day shipping)
- [ ] Zigbee coordinator arrives (CloudFree 3-5 days)
- [ ] Mount/position camera
- [ ] Plug in Zigbee coordinator

**Configure:**
- [ ] Update Frigate config with camera IP
- [ ] Update Zigbee2MQTT config
- [ ] Deploy: `make deploy`

**Test:**
- [ ] Camera streaming in Frigate? ✓
- [ ] Zigbee bulb pairs? ✓
- [ ] Appears in Home Assistant? ✓
- [ ] Can control bulb? ✓
- [ ] Simple automation works? ✓

### **End of Week - TESTING PHASE**

You now have a working system to evaluate!

**Remember**: The goal is to **validate the approach**, not build the complete system yet!

---

## 📦 Shopping Cart Summary (Fast Delivery)

### Local Pickup (Today/Tomorrow):
- [ ] **Mini PC**: Facebook Marketplace ($100-160)
- [ ] **Smart Bulb**: IKEA or Best Buy ($8-25)

### Online (2-5 Day Delivery):
- [ ] **Camera**: B&H Photo ($40-60)
- [ ] **Zigbee Coordinator**: CloudFree.shop ($28-30)
- [ ] **PoE Injector** (if needed): Newegg ($12-15)

### Alternative if Zigbee Coordinator Won't Arrive:
- [ ] **Hue Bridge**: Best Buy pickup ($50-60)
  - Use this temporarily
  - Order real Zigbee coordinator for later

**Total: $188-285** (arrived within 7 days!)

---

## 🚨 Can't Get Zigbee Coordinator in Time?

**Fallback Plan**:

1. **Skip smart home for now**
   - Focus on camera testing
   - Add bulb later when coordinator arrives
   - Still validates 80% of system

2. **Use Philips Hue Bridge temporarily**
   - Best Buy: Same-day pickup ($50-60)
   - Only works with Hue bulbs (not IKEA)
   - But gets you started testing
   - Add proper Zigbee2MQTT later

3. **Start with WiFi smart plug**
   - TP-Link Kasa plug: Best Buy ($15-25)
   - Works with Home Assistant (cloud initially)
   - Not ideal, but lets you test automations

Good luck with your 7-day build! 🎊

