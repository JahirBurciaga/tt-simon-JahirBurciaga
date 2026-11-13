![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg) ![](../../workflows/fpga/badge.svg)

# Simon Says en silicio — Tiny Tapeout

Juego de memoria **Simon Says** diseñado en Verilog, probado en una FPGA Basys 3 y enviado a fabricar como chip en
[Tiny Tapeout](https://tinytapeout.com) (SkyWater 130 nm, shuttle SKY 26e).

- **Módulo superior:** `tt_um_jahirburciaga_simon`
- **Área:** 1 tile (≈160 × 110 µm)
- **Reloj:** 50 kHz externo
- **Autor:** Jahir Burciaga, Elena Ochoa, Vivian Higareda — Diseño de Sistemas Digitales VLSI, UACJ
- **Basado en:** [tt10-simon-game](https://github.com/urish/tt10-simon-game) de Uri Shaked (Apache-2.0)
- **Hoja de datos (inglés):** [docs/info.md](docs/info.md)

---

## Cómo se juega

1. Después del reset, los LEDs se quedan encendidos con uno apagado que va girando, esperando a que presiones cualquier botón. El tiempo que tardas en presionarlo sirve como semilla para que cada juego tenga una secuencia distinta.
2. El juego muestra una secuencia: se enciende un LED y suena su tono.
3. Repites la secuencia con los botones, en el mismo orden.
4. Si aciertas, suena una melodía de "nivel superado", el puntaje sube 1 y la secuencia crece un color.
5. Si te equivocas, suena la melodía de "game over", los 4 LEDs parpadean y el juego espera un botón para empezar de nuevo.

El puntaje se muestra en un display de 7 segmentos de 2 dígitos (00 a 99).

## Cómo funciona por dentro

```
                 ┌──────────────── tt_um_jahirburciaga_simon (src/project.v) ────────────────┐
 ui[3:0] btn ───►│  ┌──────────────── simon (src/simon.v) ────────────────────────────────┐   │──► uo[3:0] LEDs
 ui[4] seginv ──►│  │  Máquina de estados: encendido → mostrar secuencia → esperar         │   │──► uo[4]   bocina
 clk 50 kHz ────►│  │  botones → nivel superado / game over                                 │   │──► uo[6:5] dígitos
 rst_n ─────────►│  │   ┌──────────────┐  ┌──────────────┐  ┌──────────────────────────┐   │   │──► uio[6:0] segmentos
                 │  │   │ galois_lfsr  │  │  sound_gen   │  │          score           │   │   │
                 │  │   │ LFSR 16 bits │  │ onda cuadrada│  │ contador BCD + multiplex │   │   │
                 │  │   └──────────────┘  └──────────────┘  └──────────────────────────┘   │   │
                 │  └──────────────────────────────────────────────────────────────────────┘   │
                 └─────────────────────────────────────────────────────────────────────────────┘
```

| Archivo | Qué hace |
|---|---|
| `src/project.v` | Wrapper de Tiny Tapeout: conecta el juego a los 24 pines, invierte el reset (`rst_n` es activo en bajo) y fija `uio_oe = 0111_1111`. |
| `src/simon.v` | Máquina de estados del juego (9 estados), contador de milisegundos y memoria de la secuencia (hasta 100 pasos). |
| `src/galois_lfsr.v` | Generador pseudoaleatorio LFSR de 16 bits (taps 16, 15, 13, 4). Corre libre mientras se espera el primer botón; al iniciar se captura su valor y la secuencia se regenera desde ahí en cada ronda, así no se guarda en memoria. |
| `src/sound_gen.v` | Genera una onda cuadrada de la frecuencia pedida con un acumulador de 16 bits. |
| `src/score.v` | Puntaje en BCD (decenas y unidades) y multiplexado de los 2 dígitos del display. |

**Tiempos (a 50 kHz):** cada color de la secuencia dura 300 ms con 100 ms de pausa; cada botón presionado suena 300 ms;
la melodía de nivel superado son 6 notas de 150 ms.

**Tonos por color:**

| Botón / LED | Nota | Frecuencia |
|---|---|---|
| 1 | G3 | 196 Hz |
| 2 | C4 | 262 Hz |
| 3 | E4 | 330 Hz |
| 4 | G5 | 784 Hz |

### Cambios respecto al diseño original

Para que el diseño cupiera en **1 tile** (el original necesitaba 2 con el flujo LibreLane actual):

| Cambio | Original | Esta versión |
|---|---|---|
| Fuente de reloj | Externa o oscilador de anillo interno (`clk_sel`) | Solo externa de 50 kHz |
| LFSR | 32 bits | 16 bits |
| Contador del generador de sonido | 32 bits | 16 bits |
| Contador de milisegundos | 16 bits | 8 bits |
| Compuertas / flip-flops (estimado con Yosys) | ≈ 1,994 / 208 | ≈ 1,504 / 139 |

El comportamiento del juego no cambia: las mismas pruebas de cocotb pasan en las dos versiones.

## Pinout

| Pin | Señal | Descripción |
|---|---|---|
| `ui[0]`–`ui[3]` | `btn1`–`btn4` | Botones (activos en alto, con pull-down externo) |
| `ui[4]` | `seginv` | 1 = display de ánodo común, 0 = cátodo común |
| `uo[0]`–`uo[3]` | `led1`–`led4` | LEDs del juego |
| `uo[4]` | `speaker` | Bocina / buzzer pasivo |
| `uo[5]` | `dig1` | Común del dígito de decenas |
| `uo[6]` | `dig2` | Común del dígito de unidades |
| `uio[0]`–`uio[6]` | `seg_a`–`seg_g` | Segmentos del display (configurados como salida) |
| `ui[5]`–`ui[7]`, `uo[7]`, `uio[7]` | — | Sin uso |

## Cómo simular

Las pruebas usan [cocotb](https://www.cocotb.org/) con Icarus Verilog. En Linux o WSL2 (Ubuntu):

```sh
# 1. Instalar el simulador (una sola vez)
sudo apt install -y iverilog python3-venv

# 2. Crear el entorno de Python e instalar cocotb (una sola vez)
python3 -m venv venv
source venv/bin/activate
pip install -r test/requirements.txt

# 3. Correr las pruebas
cd test
make -B
```

Resultado esperado:

| Prueba | Qué verifica | Resultado |
|---|---|---|
| `test_simon` | Reset, display vacío, primer LED y puntaje "01" | PASS |
| `test_long_game_sequence` | 5 rondas completas leyendo los LEDs y presionando los botones | PASS |
| `test_pseudo_randomness` | Que los 4 colores salgan con la misma probabilidad (desactivada por defecto, tarda varios minutos) | SKIP |

Para correr la prueba de aleatoriedad, quita `skip=True` de su decorador en `test/test.py` y corre
`make -B COCOTB_TESTCASE=test_pseudo_randomness`.

**Ver las formas de onda:** la simulación guarda `test/tb.fst`. Ábrelo con [Surfer](https://surfer-project.org/) o GTKWave
(`gtkwave test/tb.fst`). Señales útiles: `btn`, `led`, `seg`, `dig1`, `dig2` y `speaker`.

Más detalles en [test/README.md](test/README.md).

## Cómo probar el chip físico

Material necesario:

- 4 botones, cada uno con resistencia pull-down de 10 kΩ a `ui[0]`–`ui[3]`.
- 4 LEDs con resistencia de 330 Ω en `uo[0]`–`uo[3]`.
- Buzzer pasivo en `uo[4]` (con transistor NPN si es magnético).
- Display de 7 segmentos de 2 dígitos: segmentos a `uio[0]`–`uio[6]` con resistencias de 1 kΩ, común de decenas a `uo[5]` y de unidades a `uo[6]`.

Pasos en la DevKit de Tiny Tapeout:

1. Seleccionar el proyecto `tt_um_jahirburciaga_simon`.
2. Configurar el reloj del proyecto a **50 kHz**.
3. Poner `ui[4]` según el display: 1 para ánodo común, 0 para cátodo común.
4. Dar reset (`rst_n` en bajo y luego en alto).
5. Presionar cualquier botón para empezar a jugar.

Todas las señales son de 3.3 V. No conectes 5 V a los pines.

## Prueba en FPGA (Basys 3)

Antes del chip, el juego se probó en una Basys 3 (Artix-7) con Vivado. Para la FPGA no se usa `project.v`: un wrapper
propio instancia `simon`, divide el reloj de 100 MHz a 50 kHz, sincroniza los botones y adapta el display de la tarjeta
(ánodo común, activo en bajo). Los botones de la tarjeta (arriba, izquierda, derecha y abajo) son `btn1`–`btn4`, y el
botón central es el reset.

## Estructura del repositorio

```
├── info.yaml          # Datos del proyecto para Tiny Tapeout (pinout, archivos, módulo superior)
├── src/               # Código Verilog del chip + config.json (configuración del flujo LibreLane)
├── test/              # Pruebas de cocotb (tb.v, test.py, Makefile)
├── docs/info.md       # Hoja de datos (inglés)
└── .github/workflows/ # GitHub Actions: gds, test, docs, fpga
```

## Verificación automática

Cada `git push` corre las GitHub Actions:

- **gds:** síntesis, colocación, ruteo, DRC/LVS y generación del GDS con LibreLane (Yosys + OpenROAD), PDK SkyWater 130 nm.
  En el *Summary* de la corrida están el layout, la vista 3D y las estadísticas del chip.
- **test:** corre las pruebas de cocotb.
- **docs:** genera la hoja de datos.

## Créditos y licencia

Diseño original: [tt10-simon-game](https://github.com/urish/tt10-simon-game), © Uri Shaked. Adaptación para 1 tile y
documentación: Jahir Burciaga (UACJ). Licencia [Apache-2.0](LICENSE).
