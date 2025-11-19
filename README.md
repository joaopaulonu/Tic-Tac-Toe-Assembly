# 🕹️ Tic-Tac-Toe - Assembly x86 (8086)

![Language](https://img.shields.io/badge/Language-Assembly%20x86-red)
![Platform](https://img.shields.io/badge/Platform-DOS%20(16--bit)-blue)
![License](https://img.shields.io/badge/License-MIT-green)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen)

> A classic Tic-Tac-Toe game developed entirely in **8086 Assembly**, running natively in text mode (DOS).

This project was created with a focus on **low-level programming logic**, direct memory manipulation, BIOS interrupts, routine optimization, and the implementation of a **Hybrid Artificial Intelligence** (Strategy + RNG).

---

## 📸 Screenshots

| Main Menu | Game Board |
|:---:|:---:|
| <img width="537" height="357" alt="image" src="https://github.com/user-attachments/assets/6d9eaf65-f854-4b32-8ef8-af29fe0bc4fa" /> | <img width="392" height="170" alt="image" src="https://github.com/user-attachments/assets/dfe9db92-b4c0-409d-b94c-3017f9abfe54" />|


> Development and execution environment.

<img width="1918" height="1030" alt="image" src="https://github.com/user-attachments/assets/d4eb41b5-66d8-4035-bc01-041939a0d509" />


---

## 📌 Features

### 🎮 Game Modes

* **Player vs. Player (PvP):**
  
    * Two users take turns controlling 'X' and 'O'.
    
    * Real-time input validation (numbers 1-9 only).
    
* **Player vs. AI (PvAI):**
  
    * The player challenges the CPU.
    
    * The AI features defensive (blocking) and offensive (winning) behaviors, as well as move variability.

### 💻 Technical Aspects

* **Graphical Interface (Text Mode):** Uses `INT 10h` for video control and cursor positioning, manually drawing the ASCII board.

* **Visual Feedback:** Messages for victory, draw, and invalid moves.

* **State Management:** Automatic variable reset and clearing of the `MATRIZ` matrix after each match.

---

## 🧠 The Artificial Intelligence

The AI in this project is not based solely on randomness. It implements a simple heuristic combined with hardware-based **RNG (Random Number Generation)**.

### Decision Strategy
The `ESCOLHADAIA` routine follows this priority:

1.  **Opening Phase (Turns < 3):** The AI plays randomly to ensure that every match feels unique.

2.  **Immediate Victory:** The `TESTA_CASA_IA` macro checks if the AI has 2 aligned symbols. If so, it marks the third to win.

3.  **Critical Block:** If the human player has 2 aligned symbols, the AI identifies the threat and blocks the position.

4.  **Random Move (Fallback):** If there is no immediate risk or chance of victory, the AI selects a free spot based on the **system clock milliseconds** (`INT 21h, AH=2Ch`), ensuring "true randomness."
