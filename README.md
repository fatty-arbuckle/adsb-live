# AdbsLive

**TODO: Add description**

#### Build aircraft registry DB
```bash
cd app/aircraft_registry/docker
docker build -t aircraft-registry-db -f Dockerfile.db .
```

#### Run aircraft registry DB
`docker run -p 5432:5432 --rm aircraft-registry-db`

#### Run a pgadmin server
`docker run --rm -p 80:80 -e "PGADMIN_DEFAULT_PASSWORD=password" -e "PGADMIN_DEFAULT_EMAIL=admin" dpage/pgadmin4`
