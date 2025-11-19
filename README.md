# 🕹️ Jogo da Velha - Assembly x86 (8086)

![Language](https://img.shields.io/badge/Language-Assembly%20x86-red)
![Platform](https://img.shields.io/badge/Platform-DOS%20(16--bit)-blue)
![License](https://img.shields.io/badge/License-MIT-green)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen)

> Um clássico Jogo da Velha desenvolvido inteiramente em **Assembly 8086**, rodando nativamente em modo texto (DOS).

Este projeto foi criado com foco em **lógica de programação de baixo nível**, manipulação direta de memória e interrupções de BIOS, otimização de rotinas e implementação de uma **Inteligência Artificial Híbrida** (Estratégia + RNG).

---

## 📸 Screenshots

| Menu Principal | Tabuleiro do Jogo |
|:---:|:---:|
| <img width="537" height="357" alt="image" src="https://github.com/user-attachments/assets/6d9eaf65-f854-4b32-8ef8-af29fe0bc4fa" /> | <img width="392" height="170" alt="image" src="https://github.com/user-attachments/assets/dfe9db92-b4c0-409d-b94c-3017f9abfe54" />|


> Ambiente de desenvolvimento e execução.

<img width="1918" height="1030" alt="image" src="https://github.com/user-attachments/assets/d4eb41b5-66d8-4035-bc01-041939a0d509" />


---

## 📌 Funcionalidades

### 🎮 Modos de Jogo

* **Jogador vs Jogador (PvP):**
  
    * Dois usuários alternam turnos controlando 'X' e 'O'.
    
    * Validação de inputs em tempo real (apenas números 1-9).
    
* **Jogador vs IA (PvIA):**
  
    * O jogador desafia a CPU.
    
    * A IA possui comportamento defensivo (bloqueio) e ofensivo (vitória), além de variabilidade de jogadas.

### 💻 Aspectos Técnicos

* **Interface Gráfica (Modo Texto):** Utiliza `INT 10h` para controle de vídeo e posicionamento de cursor, desenhando o tabuleiro ASCII manualmente.

* **Feedback Visual:** Mensagens de vitória, empate ("Velha") e erro de jogada.

* **Gerenciamento de Estado:** Reinício automático de variáveis e limpeza da matriz `MATRIZ` após cada partida.

---

## 🧠 A Inteligência Artificial

A IA deste projeto não se baseia apenas em aleatoriedade. Ela implementa uma heurística simples combinada com **RNG (Random Number Generation)** baseado em hardware.

### Estratégia de Decisão
A rotina `ESCOLHADAIA` segue a seguinte prioridade:

1.  **Fase de Abertura (Turnos < 3):** A IA joga de forma aleatória para garantir que cada partida seja única.

2.  **Vitória Imediata:** A macro `TESTA_CASA_IA` verifica se a IA tem 2 símbolos alinhados. Se sim, ela marca o terceiro para vencer.

3.  **Bloqueio Crítico:** Se o jogador humano tiver 2 símbolos alinhados, a IA identifica a ameaça e bloqueia a posição.

4.  **Jogada Aleatória (Fallback):** Se não houver risco ou chance de vitória, a IA escolhe uma casa livre baseada nos **milissegundos do relógio do sistema** (`INT 21h, AH=2Ch`), garantindo "aleatoriedade real".

