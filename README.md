# 🚔 QB 10-System HUD

![QBCore](https://img.shields.io/badge/Framework-QBCore-blue?style=for-the-badge)
![Version](https://img.shields.io/badge/Version-1.5-brightgreen?style=for-the-badge)
![ox_inventory](https://img.shields.io/badge/Inventory-ox_inventory-orange?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Stable-success?style=for-the-badge)

A modern, lightweight and fully synchronized 10-system HUD for FiveM servers running **QBCore**,  
designed specifically for law enforcement environments.

This resource provides a clean and immersive way to display all online officers, their callsigns, radio channels, departments and live radio activity — with a strong focus on stability, performance and usability.

---

# 🔥 QB-10HUD SYSTEM v1.5

## 🆕 Latest Update

### 📱 Police Tablet Requirement (RP Enhancement)
Officers must now own a dedicated dispatcher tablet item (`mokdan`) in order to open the system.  
This enhances roleplay realism and adds economic value to police gameplay.

### 💾 Persistent SQL Data Storage
Personal officer codes are now saved directly to the database.  
Players no longer need to re-enter their code after reconnecting.

### 🖼️ Fixed Headshot System
The FiveM headshot rendering system has been fully rebuilt and stabilized.  
No more broken or inconsistent player images.

### ⚡ Performance Optimization
Internal logic improvements and structural cleanup for better efficiency and long-term stability.

### 📦 ox_inventory Support
The system now fully supports **ox_inventory** in addition to QBCore inventory.

---

# ✨ Core Features

## 📋 Live Officer List
- Real-time display of all connected officers  
- Instant updates on join, leave, job change or reconnect  

## 🏢 Department Grouping
- Officers grouped dynamically by department (based on job grade)  
- Fully configurable department names  
- Expand / collapse department sections  
- Internal callsign-based priority sorting  

## 🎙️ Radio Integration
- Live radio channel display  
- Visual indicator when an officer is actively speaking  
- Fully compatible with:
  - pma-voice  
  - qb-radio  

## 🖼️ Automatic Player Headshots
- Native FiveM headshot rendering  
- No manual image uploads required  

## ⚙️ In-Game Settings (F10)
- Toggle HUD visibility  
- Set callsign & custom color  
- Drag & save HUD position  
- Resize (scale) HUD  
- All preferences saved locally  

## 🎨 Modern UI Design
- Clean dark interface  
- Smooth hover animations  
- Clear visual hierarchy  
- RTL support (Hebrew-friendly)  

## 🚀 Stability Focused
- No unnecessary loops or spam updates  
- Server-side cleanup to prevent ghost players  
- Safe handling of reconnects and drops  

---

# 📦 Dependencies

Required:
- qb-core  
- qb-radio  
- pma-voice
- MugShotBase64

Optional (Supported):
- ox_inventory  
- qb-inventory
---

# 🛠️ Installation

1. Download or clone this repository  
2. Place the folder inside your `resources` directory  
3. Add to your `server.cfg`:
4. run player_hud.sql
```
ensure qb-10hud
```

4. Make sure dependencies start **before** this resource.

---

# 📌 Tablet Item Requirement (mokdan)

To access the dispatcher system, officers must own an item named:

```
mokdan
```

## ➕ Adding to QBCore

Add this to:

`qb-core/shared/items.lua`

```lua
mokdan = {
    name = 'mokdan',
    label = 'מוקדן משטרת ישראל',
    weight = 1500,
    type = 'item',
    image = 'mokdan.png',
    unique = true,
    useable = true,
    shouldClose = true,
    combinable = nil,
    description = 'מוקדן למשטרת ישראל'
},
```

## ➕ Adding to ox_inventory

Add a matching item inside:

`ox_inventory/data/items.lua`

Make sure the item name remains:

```
mokdan
```

---

## 🖼️ Item Image

Download the image and place it inside your inventory images folder:

```
mokdan.png
```

![item](https://cdn.discordapp.com/attachments/1464239100243607757/1474119194848002091/mokdan.png?ex=6998affb&is=69975e7b&hm=8697193c9f514d324e228ac8a8089b38f953a846f02a1e0b9d0fa74fe0599828&)

---

# 📸 Preview

![Preview 1](https://media.discordapp.net/attachments/1463798659903782922/1472501521236099174/image.png?ex=69981368&is=6996c1e8&hm=cd1c4f0c1b18fbd0d662634f14ddc89f5bdcc5f297dca2286e24cb5c8ab5807a&=&format=webp&quality=lossless&width=1534&height=864)
![Preview 2](https://media.discordapp.net/attachments/1463798659903782922/1472501521911513252/image.png?ex=69981368&is=6996c1e8&hm=938098b26aa868f79bfed0f4bc6004067711672bed34c1325c94e195e9cec9aa&=&format=webp&quality=lossless&width=1534&height=864)
![Preview 3](https://media.discordapp.net/attachments/1463798659903782922/1469739056626925578/20260120174149_1.jpg?ex=6997e9e9&is=69969869&hm=8ab88103bef58366712183576f15d63dda9d64bfa7bbcf1f610429ab3afbfadb&=&format=webp&width=1535&height=863)

---

# 🛠 Support

For support or questions, contact me on Discord:

**sol__**

---

⭐ If you like this project, consider leaving a star.
