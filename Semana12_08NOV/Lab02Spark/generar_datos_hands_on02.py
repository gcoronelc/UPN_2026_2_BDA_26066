"""Genera los dos CSV didácticos de la semana 12 con datos deterministas."""
import csv
from pathlib import Path
SECT = ["Agua", "Energia", "Residuos"]
REG = ["Lima", "La Libertad", "Arequipa", "Piura"]
COLUMNAS = ["id_registro", "fecha", "region", "sector", "consumo_unidades"]
def generar(nombre, cantidad):
    with Path(nombre).open("w", encoding="utf-8", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(COLUMNAS)
        for i in range(cantidad):
            writer.writerow([f"C{i+1:06d}", f"2026-10-{1+i%28:02d}",
                             REG[i%4], SECT[i%3], 10+(i%41)])
if __name__ == "__main__":
    generar("datos_consumo_24.csv", 24)
    generar("datos_consumo_100k.csv", 100000)
    print("Se generaron 24 y 100 000 registros simulados.")
