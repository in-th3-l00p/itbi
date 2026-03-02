# proiectul ala cu pdsh pdcp la itbi ^-^
Acest proiect reimplementează în Bash trei comenzi din suita pdsh folosite în administrarea sistemelor distribuite: pdsh (execuție paralelă de comenzi pe noduri remote), pdcp (copiere fișiere către noduri) și rpdcp (copiere fișiere de pe noduri înapoi local). Infrastructura de testare este bazată pe containere LXD, iar scripturile de setup automatizează complet configurarea mediului — de la instalarea LXD până la distribuirea cheilor SSH.

## Comenzile implementate

### `mypdsh.sh` — Parallel Distributed Shell
Execută o comandă SSH în paralel pe mai multe noduri. Suportă sintaxa `node[1-5]` pentru specificarea unui interval de noduri.
```bash
./mypdsh.sh -w <noduri> "<comandă>"
```

### `mypdcp.sh` — Parallel Distributed Copy
Copiază fișiere sau directoare de pe mașina locală pe mai multe noduri simultan. Suportă excluderea unor noduri cu `-x`.
```bash
./mypdcp.sh -w <noduri> [-x <excluderi>] <sursă> <destinație>
```

### `myrpdcp.sh` — Reverse Parallel Distributed Copy
Copiază fișiere de pe noduri înapoi pe mașina locală. Fiecare nod primește propriul subfolder în destinație.
```bash
./myrpdcp.sh -w <noduri> <sursă_remotă> <destinație_locală>
```