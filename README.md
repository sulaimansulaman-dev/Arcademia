# Arcademia – Portable Programming Arcade Console
Arcademia is an educational, arcade-style coding game built with **Godot Engine 4** and **GDScript**, designed to teach Grade 5 learners the fundamentals of programming through a visual block-based interface inspired by Blockly/Scratch.

The game runs on a **custom arcade machine** (HP EliteDesk + joystick + physical buttons) or a normal PC. Learners help *Astronaut Alex* collect spaceship parts by writing code that controls movement, jumps, loops, and conditionals.

---

## 🌟 Features
- 🎮 **Arcade Machine Support**  
  Physical joystick + 8 arcade buttons mapped to all major game and Blockly actions.

- 🚀 **Space-Themed Coding Adventure**  
  Guide Alex across platforms, obstacles, and gaps to collect spaceship parts.

- 🧩 **Blockly-Style Programming**  
  - Move & jump blocks  
  - Repeat loops  
  - Conditionals (if/else, repeat until)  
  - Sequencing & basic logic  

- 👤 **Student & Teacher Accounts**  
  - JSON-based user database  
  - 5-digit PIN system  
  - Student progress tracking  
  - Teacher dashboard & student management panel

- 🎨 **Avatar Creator**  
  Customizable skin, hair, clothing, accessories, and full suits.

- 🔊 **Dynamic Audio System**  
  Background music + context-based sound effects.

- 📁 **Offline & Lightweight**  
  Fully functional with no internet required; ideal for South African schools.

---

## 🕹 Arcade Controls (HP EliteDesk Machine)
- **Joystick** → Move mouse cursor  
- **Left Button** → Left-click  
- **Right Button** → Right-click  
- **Run** → Execute program  
- **Clear** → Remove all blocks  
- **Reset** → Restart the current level  
- **Change** → Switch block categories (movement / loops / conditionals)  
- **Help** → Open hint panel  
- **Back** → Return to previous screen

---

## 🔧 Technology Stack
- **Engine:** Godot 4 (GDScript)
- **Logic:** Blockly HTML/JS integration for block rendering
- **Database:** JSON (students, teachers, scores)
- **Platform:** Windows (Arcade machine) / Desktop
- **External Tools:** JoyToKey for input mapping

---

## 📂 Project Structure (Short Overview)
/avatar creation/ – Avatar creator scenes & scripts
/game/ – Main game logic & levels
/blockly/ – Block-based coding interface
/scripts/ – Gameplay scripts (Player.gd, Blocks.gd, Globals.gd)
/ui/ – Main menu, login, buttons, backgrounds
/assets/ – Music, SFX, fonts, sprites

---

## 🚀 How to Run the Project (PC)
1. Install **Godot 4.x Standard** (not .NET version)  
2. Open the project folder in Godot  
3. Press **Play ▶** to launch  
4. Use keyboard & mouse or map a controller via JoyToKey

---

## 🧑‍🏫 Teacher Mode
- Create teacher account  
- Manage student profiles  
- View progress, scores, and completed levels  
- Reset passwords & update records  

---

## 🎮 Student Mode
- Create avatar  
- Sign up with 5-digit PIN  
- Play through Levels 1–4  
- Learn sequencing, loops, conditionals and logic  
- Earn scores and track progress in main menu

---

## 📘 Levels Overview
| Level | Concept | Description |
|-------|---------|-------------|
| 1 | Sequencing | Move right, jump, simple logic |
| 2 | Loops | Repeat X times |
| 3 | Conditionals | Gap detection, if/else |
| 4 | Repeat-Until | Automated logic loops, advanced logic |

---

## 👥 Development Team
Full team list included in `/docs/User Manual` and `/docs/Developers Manual`.

---

## 📄 Documentation
- **User Manual** – Full gameplay & interface guide  
- **Developer Manual** – Engine setup, file structure, GDScript explanations, joystick mapping  

---

## 📝 License
This project is developed for educational and research purposes. 
---

## ❤️ Acknowledgements
- Godot Engine community  
- Educators testing the arcade prototype  
- All contributors to Arcademia  
