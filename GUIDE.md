# Guide — Kali Docker Enumeration Lab

This lab runs a **single target container** on a custom Docker bridge network.

## Target IP

Your scan target for this lab is:

```bash
172.28.21.12
```

Do not scan `127.0.0.1` for this lab. Scan the Docker target IP above.

---

## 1) Install Docker on Kali

```bash
sudo apt update
sudo apt install -y docker.io docker-compose-v2 git
sudo systemctl enable docker --now
sudo usermod -aG docker $USER
newgrp docker
docker ps
docker compose version
git --version
```

If `docker-compose-v2` is not available on your Kali build, install the compose plugin package your repo offers and verify `docker compose version`.

---

## 2) Clone the repo

```bash
git clone https://github.com/beed2112/enum_wkshp.git
cd enum_wkshp
```

---

## 3) Build and start the target

```bash
docker compose up --build -d
```

---

## 4) Confirm it is running

```bash
docker compose ps
docker ps
docker inspect enumlab-target --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'
```

Expected IP:

```bash
172.28.21.12
```

---

## 5) Basic checks

### See container status
```bash
docker compose ps
```

### See logs
```bash
docker compose logs
docker compose logs -f enumtarget
```

### Verify the target answers
```bash
ping -c 1 172.28.21.12

```

---
## 6) Use the lab

## 7) Stop the lab

```bash
docker compose down
```

---

## 8) Remove and rebuild from scratch

```bash
docker compose down -v --remove-orphans
docker compose up --build -d
```

---

## Troubleshooting

### Docker permission denied
```bash
sudo usermod -aG docker $USER
newgrp docker
docker ps
```

### Container did not start
```bash
docker compose logs
```

### Target IP not present
Check the network and container inspect output:
```bash
docker network ls
docker network inspect docker_enum_lab_single_target_enumlab_net
docker inspect enumlab-target
```

### Ping works but services do not
Give the services a few more seconds, then run:
```bash
docker compose logs -f enumtarget
```



## Workshop flags

This lab includes simple HTB-style confirmation flags:


Flag format:
```text
enum-wkshp{...}
```
