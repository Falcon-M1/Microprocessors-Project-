# 8086 Assembly Brick Breaker & Serial Arcade

A retro **Brick Breaker (Breakout)** arcade game and **Dual-Pane Serial Chat** client written in 16-bit x86 Assembly (Real Mode) for MS-DOS.

The project features direct VGA Mode 13h pixel graphics, custom ball physics with angle deflections, and peer-to-peer multiplayer communication through direct 8250/16550 UART COM1 serial port programming.

---

## Key Features

* **Single-Player Mode:** Classic Breakout gameplay with 40 color-indexed bricks, directional paddle bounces, live score tracking, and a 3-life game loop.
* **Real-Time Serial Multiplayer:** Low-latency P2P multiplayer over a COM1 null-modem serial connection. The Host handles ball physics and synchronization while the Joined player controls an adversarial paddle.
* **Dual-Pane Serial Terminal Chat:** Text-mode (80x25) split-screen terminal. The top pane displays locally sent keystrokes, while the bottom pane displays remotely received data, with independent line scrolling through BIOS interrupts.
* **Direct Hardware Interfacing:**

  * **Video:** Direct BIOS `INT 10h` subroutines for VGA Mode 13h (320x200, 256 colors) and Mode 03h (80x25 text).
  * **Serial Communication:** Direct I/O port programming (`0x3F8`–`0x3FD`) for COM1, bypassing OS serial drivers.
  * **Keyboard I/O:** Non-blocking scan-code polling via `INT 16h`.

---

## Game Modes & Controls

### Main Menu

| Key   | Action                          |
| ----- | ------------------------------- |
| `S`   | Launch Single-Player Mode       |
| `M`   | Launch Multiplayer Mode         |
| `C`   | Launch Split-Screen Serial Chat |
| `Esc` | Exit program to DOS             |

### In-Game Controls

| Key     | Action                                    |
| ------- | ----------------------------------------- |
| `A`     | Move paddle left                          |
| `D`     | Move paddle right                         |
| `Space` | Release / launch ball                     |
| `Esc`   | Quit current game and return to Main Menu |

---

## Technical Specifications & Architecture

### System Architecture

* **Target Architecture:** Intel 8086 / 8088 / 80286+ (x86 16-bit Real Mode)
* **Memory Model:** `.MODEL SMALL`
* **Code Segment:** Up to 64 KB
* **Data Segment:** Up to 64 KB
* **Stack Size:** 64 bytes

### Interrupts Used

| Interrupt          | Purpose                      |
| ------------------ | ---------------------------- |
| `INT 10h`          | Video display services       |
| `INT 10h / AH=00h` | Set video mode               |
| `INT 10h / AH=0Ch` | Plot pixel                   |
| `INT 10h / AH=02h` | Set cursor position          |
| `INT 10h / AH=06h` | Scroll text window           |
| `INT 16h / AH=01h` | Non-blocking keyboard status |
| `INT 16h / AH=00h` | Read keyboard input          |
| `INT 21h / AH=09h` | Print string                 |
| `INT 21h / AH=02h` | Output character             |
| `INT 21h / AH=4Ch` | Terminate program            |

---

## UART Serial Configuration

The UART controller is initialized through direct I/O port manipulation.

The project uses **COM1**, whose base I/O address is `0x3F8`.

```assembly
Port 0x3FB (LCR)  <- 10000000b  ; Enable Divisor Latch Access Bit (DLAB)
Port 0x3F8 (DLL)  <- 0x0C       ; Baud Rate Divisor Latch Low
Port 0x3F9 (DLM)  <- 0x00       ; Baud Rate Divisor Latch High
Port 0x3FB (LCR)  <- 00011011b  ; 8 Data Bits, 1 Stop Bit, Even Parity
```

### UART Configuration

* **Port:** COM1
* **Base Address:** `0x3F8`
* **Baud Rate:** 9600
* **Data Bits:** 8
* **Stop Bits:** 1
* **Parity:** Even
* **UART:** Compatible with 8250/16550

---

## Multiplayer Serial Protocol

The multiplayer protocol uses compact command bytes and packed state information to synchronize the two game instances.

| Hex / Bitfield            | Meaning / Action                                           |
| ------------------------- | ---------------------------------------------------------- |
| `0x01` (`00000001b`)      | Handshake: Host broadcast / Win confirmation               |
| `0x02` (`00000010b`)      | Handshake: Client acknowledgement / Loss confirmation      |
| `0x03` (`00000011b`)      | Trigger remote score increment                             |
| `11111110b`               | Client paddle movement: Left                               |
| `11111111b`               | Client paddle movement: Right                              |
| `1110xxxxb`               | Host update: Paddle stationary + Ball `(Vx, Vy)` payload   |
| `111100xxb`               | Host update: Paddle moving left + Ball `(Vx, Vy)` payload  |
| `111101xxb` / `111111xxb` | Host update: Paddle moving right + Ball `(Vx, Vy)` payload |
| `AH` register byte        | Destroyed brick index payload                              |

### Multiplayer Architecture

The **Host** acts as the authoritative game state controller:

1. Host calculates ball physics.
2. Host detects brick and paddle collisions.
3. Host updates the game score.
4. Host sends relevant state changes through COM1.
5. Client sends paddle movement commands.
6. Client renders the synchronized game state.

This approach avoids requiring both machines to independently simulate the ball.

---

## Installation & Running in DOSBox

### Prerequisites

* [DOSBox](https://www.dosbox.com/) or DOSBox-Staging / DOSBox-X
* Borland Turbo Assembler (**TASM**) and Turbo Linker (**TLINK**)
* Or **MASM 6.11**

### Build Instructions

Place `game.asm` inside your DOS working directory and assemble/link the program:

```dos
tasm /zi game.asm
tlink /v game.obj
game.exe
```

---

## Testing Multiplayer & Chat Locally

The serial multiplayer and chat functionality can be tested on a single computer by running two DOSBox instances connected through a virtual null-modem TCP loopback.

### 1. Configure Instance 1 — Host

Configure COM1 as the null-modem server:

```ini
[serial]
serial1=nullmodem port:5000 server:1
```

### 2. Configure Instance 2 — Client

Configure COM1 as the null-modem client:

```ini
[serial]
serial1=nullmodem port:5000 server:0
```

### 3. Launch the Program

1. Start **DOSBox Instance 1**.
2. Run `game.exe`.
3. Select `M` for Multiplayer or `C` for Chat.
4. Start **DOSBox Instance 2**.
5. Run `game.exe`.
6. Select the same mode.
7. The two instances communicate through the virtual serial connection on TCP port `5000`.

---

## Game Mechanics

### Brick Layout

The game contains **40 bricks**, arranged in a 4 × 10 grid:

```text
[Bricks Grid: 40 Bricks]

+-------------------------------------------------------+
| [#01] [#02] [#03] [#04] [#05] [#06] [#07] [#08] ... |
| [#11] [#12] [#13] [#14] [#15] [#16] [#17] [#18] ... |
|                                                       |
|                     O (Ball: Vx, Vy)                  |
|                                                       |
|            [====== Joined Player Paddle ======]       |
|                         Multiplayer                   |
|                                                       |
|                                                       |
|            [========= Host / P1 Paddle ========]      |
|                         Main Player                  |
+-------------------------------------------------------+
```

### Ball Deflection Physics

The paddle collision determines the ball's horizontal velocity.

* Hitting the **center** of the paddle keeps:

```text
Vx = 0
```

* Hitting the **left side** produces:

```text
Vx = -1
```

* Hitting the **right side** produces:

```text
Vx = 1
```

The vertical velocity is inverted when the ball collides with the paddle.

This creates different reflection angles depending on where the ball hits the paddle.

---

## Brick Collision System

The game maintains a **40-byte boolean array** named `IsDestroied` to track the state of every brick.

Each element represents one brick:

```text
0 → Brick is active
1 → Brick is destroyed
```

When the ball collides with a brick:

1. The brick is marked as destroyed.
2. The ball's vertical velocity `Vy` is inverted.
3. The score is updated.
4. The destroyed brick index can be transmitted to the multiplayer client.
5. An acoustic beep is generated through the DOS speaker mechanism.

---

## Score & Lives

The single-player game uses a **3-life game loop**.

The score is updated whenever a brick is destroyed, and the game recalculates the decimal score representation during gameplay.

---

## Serial Chat

The project also provides a dual-pane serial terminal mode.

The screen is divided into two independent text regions:

```text
+------------------------------------------------+
|              LOCAL / SENT DATA                 |
|                                                |
|  > Hello from Host                             |
|  > How are you?                                |
|                                                |
|------------------------------------------------|
|              REMOTE / RECEIVED DATA            |
|                                                |
|  < Hello from Client                           |
|  < I'm ready!                                  |
|                                                |
+------------------------------------------------+
```

### Chat Features

* 80x25 text mode.
* Separate local and remote panes.
* Keyboard input through BIOS `INT 16h`.
* Serial communication through COM1.
* Independent line scrolling.
* Direct UART hardware access.

---

## Hardware-Level Design

This project demonstrates low-level interaction with classic PC hardware without relying on modern operating-system APIs.

### Video

Graphics are rendered using VGA **Mode 13h**:

```text
Resolution: 320 × 200
Colors:     256
```

Individual pixels can be drawn through BIOS video services.

### Keyboard

Keyboard input uses BIOS `INT 16h`.

The game primarily relies on the non-blocking keyboard status function so that the main game loop can continue running while checking for user input.

### Serial Communication

The UART is accessed directly using x86 `IN` and `OUT` instructions.

The main COM1 registers are located at:

```text
0x3F8  Data Register
0x3F9  Interrupt Enable Register
0x3FA  Interrupt Identification / FIFO Control
0x3FB  Line Control Register
0x3FC  Modem Control Register
0x3FD  Line Status Register
```

This provides direct hardware-level serial communication between the two DOSBox instances.

---

## Project Goals

This project demonstrates several low-level programming concepts:

* 8086 Assembly programming
* x86 Real Mode
* BIOS interrupts
* DOS interrupts
* VGA graphics
* Pixel-level rendering
* Keyboard polling
* UART programming
* Serial communication
* Null-modem networking
* Multiplayer state synchronization
* Basic game physics
* Collision detection
* Memory management in the 16-bit environment
* Direct hardware I/O

---

## License

This project is intended for educational and experimental purposes.
