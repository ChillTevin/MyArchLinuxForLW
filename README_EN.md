<div align="center">
  <img src="https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/rainbow.png" width="100%">

  # 🚀 TOMEX MANAGER 
  ### *The Ultimate Cloud-Based Script Manager for Arch Linux*

  <table>
    <tr>
      <td bgcolor="#1e1e2e"><a href="README.md"><font color="#ffffff">🇪🇸 ESPAÑOL</font></a></td>
      <td bgcolor="#5b21b6"><b><a href="README_EN.md"><font color="#ffffff">🇺🇸 ENGLISH</font></a></b></td>
    </tr>
  </table>

  <br>

  ![Arch](https://img.shields.io/badge/OS-Arch_Linux-1793d1?style=for-the-badge&logo=arch-linux)
  ![License](https://img.shields.io/badge/License-MIT-purple?style=for-the-badge)
  ![TUI](https://img.shields.io/badge/Interface-Kinetic_TUI-51efff?style=for-the-badge)

  <img src="https://server.wallpaperalchemy.com/storage/wallpapers/200/arch-linux-wallpaper-4k-card.png" width="100%" alt="Arch Linux Banner">
</div>

---

## 💎 Project Vision
**TOMEX** is not just a collection of scripts; it is a **portable command center**. Inspired by the legendary **Utility CDs** from the 2000s, this project aims to provide an "all-in-one" experience for students and Linux enthusiasts who need a ready-to-work system in seconds.

### 🎯 Optimized for "Legacy" Hardware (Old PCs)
This project was born with a specific mission: **Reviving old computers**. 
> 💻 **Ultra-Lightweight:** By using a minimal TUI (Terminal User Interface) and "Ghost" cloud execution, TOMEX consumes almost **zero RAM** while running. 
> ⚙️ **Efficiency:** It skips heavy desktop environments and focuses on high-performance tools, making it exceptionally smooth on old laptops or low-resource desktop PCs.

---

## 🔥 Key Features & Script Details

### 🌍 `Dynamic Multilingual System`
Instantly toggle between **English** and **Spanish**. The UI strings update in real-time without closing the app, making it accessible for international students.

### ☁️ `Ghost-Execution` (Cloud Power)
Our main installer scripts are fetched directly from GitHub:
- **InstallerApp.sh (GUI):** A visual selector for those who prefer a more intuitive interface.
- **InstallerAppCLI.sh (CLI):** A high-speed, arrow-key-based menu for power users.
- 🚫 **No Clutter:** Scripts run from memory or `/tmp`, keeping your system clean of residual files.

### ⚡ `Smart-Logic & Dependencies`
TOMEX is intelligent. Before any installation, it performs a **Pre-Flight Check**:
1. It syncs your Arch mirrors to avoid **404 errors**.
2. It ensures `git`, `base-devel`, and `wget` are present.
3. It elevates privileges using `sudo` only when strictly necessary.

---

## 🛠️ Quick Start Guide

To unleash the magic of **TOMEX**, simply run this command in your Arch Linux terminal:

```bash
# Only copy and paste
wget https://raw.githubusercontent.com/ChillTevin/MyArchLinuxForLW/refs/heads/main/TOMEX.sh
sudo chmod +x TOMEX.sh
./TOMEX.sh

