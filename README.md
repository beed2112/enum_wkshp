# Docker Enumeration Lab — Single Target

This version avoids host port conflicts by running all services inside one container on a custom Docker bridge network.

## Fixed target IP
- `172.28.21.12`



## Quick start
```bash
git clone https://github.com/beed2112/enum_wkshp.git
cd enum_wkshp
docker-compose up --build -d
docker-compose ps
docker inspect enumlab-target --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'
```
## Check it
`ping -c 3 172.28.21.12`


## Stop
```bash
docker-compose down
```

## Rebuild
```bash
docker-compose down -v --remove-orphans
docker-compose up --build -d
```



## Workshop flags

This lab includes simple HTB-style confirmation flags for each active service



Flag format:
```text
enum-wkshp{...}
```
