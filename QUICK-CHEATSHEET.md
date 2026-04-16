# Quick Cheat Sheet

## Start
```bash
git clone https://github.com/beed2112/enum_wkshp.git
cd enum_wkshp
docker compose up --build -d
```

## Verify
```bash
docker compose ps
docker inspect enumlab-target --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'
ping -c 1 172.28.21.12
```

## Use
```bash
nmap 


## Stop
```bash
docker compose down
```



## Workshop flags

This lab includes simple HTB-style confirmation flags:

```

Flag format:
```text
enum-wkshp{...}
```
