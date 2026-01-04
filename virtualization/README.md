# Modul de Virtualizare LXD

Acest modul oferă scripturi pentru gestionarea unui mediu de virtualizare bazat pe LXD, conceput pentru testarea comenzilor shell distribuite și pentru crearea rapidă de medii de testare.

## Structura Proiectului

```
virtualization/
├── shared/                 # Module comune partajate de toate scripturile
│   ├── config.sh          # Configurări globale și variabile
│   ├── output.sh          # Funcții de logging (print_info, print_warn, print_error)
│   ├── checks.sh          # Validări comune (check_root, check_prerequisites)
│   └── utils.sh           # Utilitare comune (get_container_ip, etc.)
│
├── setup-lxd/             # Configurare inițială LXD
│   ├── setup-lxd-environment.sh  # Script principal
│   ├── lxd.sh                    # Instalare și inițializare LXD
│   └── container.sh              # Crearea și configurarea containerului de bază
│
├── create-nodes/          # Crearea nodurilor de test
│   ├── create-test-nodes.sh      # Script principal
│   ├── validation.sh             # Validarea argumentelor
│   ├── containers.sh             # Gestionarea containerelor
│   └── network.sh                # Configurare rețea și /etc/hosts
│
├── cleanup/               # Curățarea mediului
│   ├── cleanup-lxd.sh            # Script principal
│   ├── validation.sh             # Validarea argumentelor
│   ├── containers.sh             # Găsirea și ștergerea containerelor
│   └── cleanup.sh                # Curățare /etc/hosts și SSH known_hosts
│
└── ssh-setup/             # Configurare acces SSH
    ├── setup-ssh-access.sh       # Script principal
    ├── validation.sh             # Validarea argumentelor
    ├── prerequisites.sh          # Verificare și instalare dependințe
    ├── keys.sh                   # Generare chei SSH
    ├── containers.sh             # Găsirea containerelor
    └── distribution.sh           # Distribuirea cheilor și testare
```

## Modulul Shared

Toate scripturile utilizează modulele din directorul `shared/` pentru funcționalitate comună:

### config.sh
- **Culori pentru output**: RED, GREEN, YELLOW, NC
- **Configurări LXD**: BASE_CONTAINER, IMAGE, NETWORK_SUBNET, NETWORK_ADDRESS
- **Configurări SSH**: SSH_USER, SSH_PASS
- **Configurări sistem**: HOSTS_FILE, HOSTS_MARKER

### output.sh
- `print_info()` - Afișează mesaje informative (verde)
- `print_warn()` - Afișează avertismente (galben)
- `print_error()` - Afișează erori (roșu)

### checks.sh
- `check_root()` - Verifică dacă scriptul rulează ca root
- `check_prerequisites()` - Verifică dacă sistemul este Ubuntu/Debian
- `check_base_container()` - Verifică dacă containerul de bază există

### utils.sh
- `get_matching_containers()` - Găsește containere după pattern
- `get_container_ip()` - Obține IP-ul unui container

## Scripturi Principale

### 1. setup-lxd-environment.sh

**Scop**: Configurează mediul LXD și creează containerul de bază Ubuntu 20.04.

**Utilizare**:
```bash
sudo ./setup-lxd/setup-lxd-environment.sh
```

**Ce face**:
1. Instalează LXD prin snap (dacă nu este instalat)
2. Inițializează LXD cu configurare personalizată de rețea (10.200.200.0/24)
3. Creează containerul de bază "base-ubuntu"
4. Instalează OpenSSH server în container
5. Creează utilizatorul "student" cu parolă "student"
6. Configurează sudo fără parolă pentru utilizatorul student
7. Configurează SSH pentru autentificare cu parolă
8. Oprește containerul (pregătit pentru clonare)

**Module**:
- `lxd.sh` - Instalare și inițializare LXD
- `container.sh` - Crearea și configurarea containerului de bază

### 2. create-test-nodes.sh

**Scop**: Clonează containerul de bază pentru a crea multiple noduri de test.

**Utilizare**:
```bash
sudo ./create-nodes/create-test-nodes.sh <număr_noduri> <prefix_nume>
```

**Exemple**:
```bash
sudo ./create-nodes/create-test-nodes.sh 5 foo    # Creează foo1, foo2, foo3, foo4, foo5
sudo ./create-nodes/create-test-nodes.sh 3 test   # Creează test1, test2, test3
```

**Ce face**:
1. Verifică existența containerului de bază
2. Clonează containerul de bază de N ori
3. Pornește toate containerele
4. Configurează hostname-ul unic pentru fiecare container
5. Așteaptă ca toate containerele să obțină IP-uri
6. Actualizează /etc/hosts cu IP-urile containerelor

**Module**:
- `validation.sh` - Validarea argumentelor (număr și prefix)
- `containers.sh` - Clonarea și configurarea containerelor
- `network.sh` - Așteptare IP-uri și actualizare /etc/hosts

### 3. setup-ssh-access.sh

**Scop**: Configurează accesul SSH fără parolă la containere prin distribuirea cheilor SSH.

**Utilizare**:
```bash
./ssh-setup/setup-ssh-access.sh <pattern>
```

**Exemple**:
```bash
./ssh-setup/setup-ssh-access.sh "foo*"        # Toate containerele care încep cu "foo"
./ssh-setup/setup-ssh-access.sh "foo[1-5]"    # Containerele foo1 până la foo5
./ssh-setup/setup-ssh-access.sh "test*"       # Toate containerele care încep cu "test"
```

**Ce face**:
1. Instalează sshpass și expect (dacă nu sunt instalate)
2. Generează chei SSH RSA 4096-bit (dacă nu există)
3. Găsește toate containerele care se potrivesc cu pattern-ul
4. Distribuie cheia publică SSH la fiecare container
5. Testează conexiunea SSH la fiecare container
6. Afișează instrucțiuni pentru utilizare (inclusiv comenzi pdsh)

**Module**:
- `validation.sh` - Validarea argumentelor
- `prerequisites.sh` - Instalare sshpass și expect
- `keys.sh` - Generare chei SSH
- `containers.sh` - Găsirea containerelor care rulează
- `distribution.sh` - Distribuirea cheilor și testare acces

### 4. cleanup-lxd.sh

**Scop**: Șterge containerele care se potrivesc unui pattern și curăță configurările asociate.

**Utilizare**:
```bash
sudo ./cleanup/cleanup-lxd.sh <pattern>
```

**Exemple**:
```bash
sudo ./cleanup/cleanup-lxd.sh "foo*"     # Șterge toate containerele care încep cu "foo"
sudo ./cleanup/cleanup-lxd.sh "test*"    # Șterge toate containerele care încep cu "test"
```

**Ce face**:
1. Găsește toate containerele care se potrivesc cu pattern-ul
2. Afișează lista și cere confirmare (trebuie tastat "yes")
3. Oprește toate containerele găsite
4. Șterge toate containerele
5. Curăță intrările din /etc/hosts (creează backup)
6. Curăță SSH known_hosts pentru utilizatorul curent și root

**Protecție**: Containerul "base-ubuntu" nu va fi niciodată șters.

**Module**:
- `validation.sh` - Validarea argumentelor
- `containers.sh` - Găsirea, confirmarea, oprirea și ștergerea containerelor
- `cleanup.sh` - Curățare /etc/hosts și SSH known_hosts

## Flux de Lucru Tipic

### Configurare Inițială (o singură dată)

```bash
# 1. Configurează LXD și creează containerul de bază
sudo ./setup-lxd/setup-lxd-environment.sh
```

### Crearea Mediului de Test

```bash
# 2. Creează 5 noduri de test cu prefixul "node"
sudo ./create-nodes/create-test-nodes.sh 5 node

# 3. Configurează SSH fără parolă pentru toate nodurile
./ssh-setup/setup-ssh-access.sh "node*"

# 4. Testează conexiunea SSH
ssh student@node1
# sau folosește comenzi paralele cu pdsh
pdsh -w node[1-5] -l student 'hostname'
```

### Curățarea Mediului

```bash
# Șterge toate nodurile de test
sudo ./cleanup/cleanup-lxd.sh "node*"
```

## Configurări Implicite

Toate configurările sunt definite în `shared/config.sh`:

| Configurare | Valoare | Descriere |
|------------|---------|-----------|
| BASE_CONTAINER | base-ubuntu | Numele containerului de bază |
| IMAGE | ubuntu:20.04 | Imaginea Ubuntu utilizată |
| SSH_USER | student | Utilizatorul SSH în containere |
| SSH_PASS | student | Parola utilizatorului SSH |
| NETWORK_SUBNET | 10.200.200.0/24 | Subrețeaua LXD |
| NETWORK_ADDRESS | 10.200.200.1/24 | Adresa gateway-ului LXD |
| HOSTS_FILE | /etc/hosts | Fișierul hosts al sistemului |
| HOSTS_MARKER | # LXD Test Nodes | Marcaj pentru intrări în /etc/hosts |

## Modificarea Configurărilor

Pentru a schimba configurările implicite, editează `shared/config.sh`:

```bash
# Exemplu: Schimbă utilizatorul și parola SSH
SSH_USER="myuser"
SSH_PASS="mypassword"

# Exemplu: Folosește o altă subrețea
NETWORK_SUBNET="10.100.100.0/24"
NETWORK_ADDRESS="10.100.100.1/24"
```

## Cerințe de Sistem

- **OS**: Ubuntu/Debian Linux
- **Privilegii**: Root/sudo pentru majoritatea operațiunilor
- **Spațiu**: Minim 2GB pentru containerul de bază + ~500MB per container
- **Software**:
  - LXD (instalat automat prin snap)
  - sshpass (instalat automat de setup-ssh-access.sh)
  - expect (instalat automat de setup-ssh-access.sh)

## Troubleshooting

### Containerele nu obțin IP-uri

```bash
# Verifică statusul rețelei LXD
lxc network list
lxc network show lxdbr0

# Repornește containerul
sudo lxc restart <container_name>
```

### SSH nu funcționează

```bash
# Verifică dacă containerul rulează
lxc list

# Verifică serviciul SSH în container
lxc exec <container_name> -- systemctl status ssh

# Regenerează cheile SSH
rm ~/.ssh/id_rsa*
./ssh-setup/setup-ssh-access.sh "<pattern>"
```

### Probleme cu permisiunile LXD

```bash
# Adaugă utilizatorul la grupul lxd
sudo usermod -aG lxd $USER
newgrp lxd

# Sau folosește sudo pentru comenzile lxc
sudo lxc list
```

## Comenzi Utile

```bash
# Listează toate containerele
lxc list

# Conectează-te la un container
lxc exec <container_name> -- bash

# Oprește un container
lxc stop <container_name>

# Pornește un container
lxc start <container_name>

# Șterge un container
lxc delete <container_name> --force

# Verifică statusul rețelei
lxc network list

# Verifică informații despre un container
lxc info <container_name>
```

## Avantajele Arhitecturii Modulare

1. **Reutilizare**: Module comune sunt folosite de toate scripturile
2. **Mentenabilitate**: Fiecare funcționalitate este izolată într-un fișier separat
3. **Testabilitate**: Module individuale pot fi testate independent
4. **Extensibilitate**: Ușor de adăugat noi funcționalități
5. **Claritate**: Codul este organizat logic și ușor de înțeles
6. **Fără duplicări**: O singură implementare pentru funcționalitate comună

## Licență

Acest modul face parte din proiectul ITBI.
