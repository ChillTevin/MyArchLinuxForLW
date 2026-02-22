<div align="center">
  <img src="https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/rainbow.png" width="100%">

  # 💜 𝓣𝓞𝓜𝓔𝓧  𝓐𝓡𝓒  𝓗  𝓥11
  ### *重新定义 Arch Linux 管理：美学、自动化与深度专注*

   <table>
    <tr>
      <td bgcolor="#1e1e2e"><a href="README.md"><font color="#ffffff">🇪🇸 ESPAÑOL</font></a></td>
      <td bgcolor="#5b21b6"><b><a href="README_EN.md"><font color="#ffffff">🇺🇸 ENGLISH</font></a></b></td>
      <td bgcolor="#1e1e2e"><a href="README_CN.md"><font color="#ffffff">🇨🇳 中文</font></a></td>
    </tr>
  </table>


  <br>

  ![Arch](https://img.shields.io/badge/OS-Arch_Linux-1793d1?style=for-the-badge&logo=arch-linux)
  ![License](https://img.shields.io/badge/License-MIT-purple?style=for-the-badge)
  ![TUI](https://img.shields.io/badge/Interface-Kinetic_TUI-51efff?style=for-the-badge)
  ![Version](https://img.shields.io/badge/Version-11.0-9333ea?style=for-the-badge)
  ![Shell](https://img.shields.io/badge/Script-Bash_Modern-f1e05a?style=for-the-badge&logo=gnu-bash)
</div>

---

## 💎 项目愿景

**TOMEX Arch V11** 不仅仅是一个简单的软件包安装程序；它是一份**效率宣言**。在 Arch Linux 配置过程往往变得繁琐且重复的世界里，TOMEX 充当了原始终端能力与现代界面便捷性之间的桥梁。

我们的灵感源自 2000 年代初传奇的**万能工具盘 (All-in-One Utility CDs)**，但通过当代 *Cyber-Violet* 美学进行了重构。该项目旨在让任何用户（尤其是学生）都能在几秒钟内拥有一套专业级的系统环境，消除技术摩擦，为最重要的事留出空间：**学习与创造。**

### 🎯 目标群体
* 🎓 **工程与计算机专业学生：** 需要一个稳定、快速且开发工具触手可及的系统。
* 💻 **美学爱好者 (Ricing)：** 追求不仅功能强大，且视觉上充满灵感的终端界面。
* 💾 **轻量化硬件用户：** 需要榨干每一滴 CPU 性能，而不愿被沉重的图形化管理应用所累。
* 💜 **极简主义者：** 寻求一个连贯、专业且无干扰的数字“家园”。

---

## 🧘‍♂️ "The Learning Chill" 哲学

本项目是 **"The Learning Chill"** 概念的载体。这是一种将高性能学习与冷静思考状态和谐统一的理念。我们相信，你编程或学习时所处的环境直接影响你的专注力。

> “操作系统不应成为障碍，而应是你大脑的延伸。”

* **实时美学时钟：** 以极简的方式提醒时间的流逝，辅助波莫多罗 (Pomodoro) 技巧，让你无需离开终端即可掌控工作流。
* **治愈系配色：** 深紫色、电光青与金色的运用并非偶然；它们旨在减少长时间学习带来的视觉疲劳。
* **抗压力自动化：** 如果缺少依赖，脚本会自动解决。不再有安装到一半因依赖报错而产生的焦虑。

---

## 🔥 核心竞技特性

### 🌍 `瞬时动态多语言`
TOMEX 是数字世界的公民。我们实现了一个实时翻译引擎，允许在 **中文、西班牙语和英语** 之间瞬间切换整个脚本的视觉架构（标题、选项、说明和页脚），无需重启脚本。

### ☁️ `云端执行架构 (Ghost-Execution)`
我们采用了一种智能部署方案，最大限度地减少本地系统的混乱：
-   **模块化安装：** 只有在你需要时才会下载重型组件。
-   **热更新：** 直接与 GitHub 仓库连接，确保你始终获得最新的安装逻辑，无需频繁手动 `git pull`。
-   **精细权限管理：** 仅在必要时请求 `sudo` 提升，确保系统安全性。

### 🖥️ `全能桌面环境选择器`
这可能是 Arch Linux 领域最雄心勃勃的桌面环境 (DE) 管理器。只需一键，即可部署以下完整基础设施：
* **经典主流：** GNOME, KDE Plasma, Xfce.
* **轻量高效：** LXDE, LXQt, MATE.
* **现代美学：** Budgie, Cinnamon, Deepin, Pantheon.
* **独特体验：** UKUI, Enlightenment, Trinity, Cutefish, Sugar, Lumina, 以及 Phosh.

*系统不仅负责下载环境，还会自动启用相应的显示管理器 (GDM, SDDM 或 LightDM)。*

### ⚡ `智能逻辑与 Wine 管理`
TOMEX 会自动检测你的硬件和基础库。包含管理 **Wine** 兼容层（Glibc 和 Bionic 模式）的专用工具，为 Windows 应用提供接近原生的性能优化。

---

## 🛠️ 安装与使用指南

要在您的系统上开启 **TOMEX V11** 的魔法，请确保互联网连接正常，并执行以下步骤：

### 1. 前置要求
建议使用 **Nerd Font** 字体（如 *JetBrainsMono Nerd Font*），以确保所有图标和符号正常显示。

### 2. 快速启动
在您的终端中复制并粘贴以下命令：

```bash
# 克隆仓库
git clone [https://github.com/ChillTevin/MyArchLinuxForLW.git](https://github.com/ChillTevin/MyArchLinuxForLW.git)

# 进入目录
cd MyArchLinuxForLW

# 赋予执行权限
chmod +x TOMEX.sh

# 开启体验
./TOMEX.sh