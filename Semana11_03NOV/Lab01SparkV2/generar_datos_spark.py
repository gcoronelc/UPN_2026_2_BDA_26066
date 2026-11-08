"""Datos ficticios para UPN, laboratorio Spark S11. No son cifras oficiales.
Uso: python generar_datos_spark.py [numero_filas]  (predeterminado 100000)
Para N=100000: 200 IDs duplicados exactos, 250 nulos,
120 metas invalidas y 700 sobrecumplimientos plausibles en las filas base (disjuntos).
"""
import csv, random, sys
from pathlib import Path

def generar(n=100000, destino=None, semilla=20261103):
    if n < 1000: raise ValueError("Utilice n >= 1000 para preservar las anomalías controladas")
    rng=random.Random(semilla)
    num_duplicados=min(200,n//100)
    base=n-num_duplicados
    # índices 0-based, grupos de anomalías mutuamente excluyentes
    faltantes=set(rng.sample(range(base), min(250,base//20)))
    libres=list(set(range(base))-faltantes)
    negativas=set(rng.sample(libres,min(120,base//40)))
    libres=list(set(libres)-negativas)
    sobre=set(rng.sample(libres,min(700,base//15)))
    zonas=['Norte','Centro','Sur','Oriente','Lima']
    sectores=['Agua','Energia','Residuos']
    instalaciones=[f'Planta {chr(65+i)}' for i in range(12)]
    import datetime
    inicio=datetime.date(2025,1,1)
    filas=[]
    for i in range(base):
        meta=round(rng.uniform(70,700),2)
        observado=round(meta*rng.uniform(.72,1.0),2)
        if i in negativas: meta=-round(rng.uniform(5,90),2)
        if i in sobre: observado=round(meta*rng.uniform(1.02,1.23),2)
        if i in faltantes: observado=''
        fecha=(inicio+datetime.timedelta(days=rng.randrange(365))).isoformat()
        filas.append([f'R{i+1:06d}',fecha,rng.choice(zonas),rng.choice(sectores),rng.choice(instalaciones),meta,observado])
    # Duplication explicitly exact, not a key collision with differing values
    for i in rng.sample(range(base),num_duplicados):filas.append(filas[i].copy())
    rng.shuffle(filas)
    destino=Path(destino or f'registros_operativos_simulados_{n}.csv')
    with destino.open('w',newline='',encoding='utf-8') as f:
        w=csv.writer(f);w.writerow(['id_registro','fecha','zona','sector','instalacion','meta_diaria','valor_observado']);w.writerows(filas)
    return destino

if __name__=='__main__':
    n=int(sys.argv[1]) if len(sys.argv)>1 else 100000
    print(generar(n))
