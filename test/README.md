# Pruebas del Simon Says (cocotb)

Banco de pruebas en [cocotb](https://www.cocotb.org/) para `tt_um_jahirburciaga_simon`.

- `tb.v`: testbench en Verilog. Instancia el chip y expone señales con nombre (`btn`, `seginv`, `led`, `seg`, `dig1`, `dig2`) para que las pruebas sean fáciles de leer.
- `test.py`: las pruebas. La clase `SimonDriver` presiona botones, lee qué LED está encendido y decodifica el display de 7 segmentos.
- `Makefile`: lista de archivos (`PROJECT_SOURCES`) y configuración del simulador.

## Instalación (una sola vez)

En Linux o WSL2 (Ubuntu), desde la raíz del repositorio:

```sh
sudo apt install -y iverilog python3-venv
python3 -m venv venv
source venv/bin/activate
pip install -r test/requirements.txt
```

## Correr las pruebas

```sh
source venv/bin/activate   # en cada terminal nueva
cd test
make -B
```

| Prueba | Qué verifica | Duración simulada |
|---|---|---|
| `test_simon` | Reset, display vacío, primer LED de la secuencia y puntaje "01" | ≈ 1.2 s |
| `test_long_game_sequence` | 5 rondas: lee la secuencia de LEDs, presiona los botones y revisa el puntaje | ≈ 18 s |
| `test_pseudo_randomness` | Distribución de colores en muchos reinicios (desactivada por defecto) | varios minutos |

Correr una sola prueba: `make -B COCOTB_TESTCASE=test_simon`.

Más rondas en la prueba larga: `make -B GAME_SEQUENCE_TEST_LENGTH=10`.

## Ver las formas de onda

La simulación guarda `tb.fst`. Ábrelo con [Surfer](https://surfer-project.org/) o con `gtkwave tb.fst`.
Señales útiles: `clk`, `rst_n`, `btn`, `led`, `seg`, `dig1`, `dig2` y `speaker` (bocina).

## Simulación gate-level

Para simular el netlist ya sintetizado, descarga el artifact de la Action `gds`, copia el netlist del diseño como
`gate_level_netlist.v` en esta carpeta y corre:

```sh
make -B GATES=yes
```
