Digdag Embulk Server
====================================

## What is this project?

This project help you to create ETL Server.


## Dependences

- [Digdag](https://github.com/treasure-data/digdag) (v0.9.24)
- [Embulk](https://github.com/embulk/embulk) (v0.9.7)

## Requirements

- Docker
- Docker Compose

## How to Develop

### 1. Copy .env.exmaple to .env and edit it

```sh
cp .env.example .env
vi .env # edit environment vars
```

### 2. Build images

```sh
docker-compose build
```

### 3. Run Digdag server on background

```sh
docker-compose up -d
```

Access http://localhost:65432/

## Login Containter

```
docker-compose exec digdag bin/sh
```