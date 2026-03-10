# CodeIgniter 4 Docker Environment

A Docker-based LEMP stack (Linux, Nginx, MySQL, PHP) pre-configured for CodeIgniter 4.

## What's Inside

| Service  | Container     | Details                              |
|----------|---------------|--------------------------------------|
| Nginx    | `ci4-nginx`   | Stable Alpine, port **8080**         |
| PHP-FPM  | `ci4-php`     | PHP 8.2 with all CI4-required modules|
| MySQL    | `ci4-mysql`   | MySQL 8.0, port **3306**             |

## Quick Start

```bash
# 1. Copy the environment file (edit credentials if you like)
cp .env.example .env

# 2. Build and start the containers
docker compose up -d --build

# 3. Open in your browser
#    http://localhost:8080
#    You should see the stack-verification page.
```

## Installing CodeIgniter 4

```bash
# Shell into the PHP container
docker compose exec php bash

# Inside the container — install CodeIgniter via Composer
composer create-project codeigniter4/appstarter .

# Exit the container
exit
```

Then edit `src/.env` (CodeIgniter's own env file) and set the database connection:

```
database.default.hostname = mysql
database.default.database = codeigniter
database.default.username = ci4user
database.default.password = ci4password
database.default.DBDriver = MySQLi
database.default.port     = 3306
```

Refresh http://localhost:8080 — you should see the CodeIgniter welcome page.

## Folder Structure

```
codeigniter-docker/
├── docker/
│   ├── nginx/
│   │   └── default.conf        # Nginx site config
│   ├── php/
│   │   ├── Dockerfile          # PHP-FPM build with extensions
│   │   └── php-local.ini       # PHP overrides
│   └── mysql/
│       └── my.cnf              # MySQL config
├── src/                        # Your CodeIgniter project goes here
│   └── public/
│       └── index.php           # Temporary verification page
├── docker-compose.yml
├── .env                        # MySQL credentials
├── .env.example
└── README.md
```

## Useful Commands

```bash
# Start containers
docker compose up -d

# Stop containers
docker compose down

# Rebuild after Dockerfile changes
docker compose up -d --build

# View logs
docker compose logs -f

# Shell into PHP container
docker compose exec php bash

# Shell into MySQL
docker compose exec mysql mysql -u ci4user -pci4password codeigniter
```

## Default Credentials

| Variable             | Value          |
|----------------------|----------------|
| MYSQL_ROOT_PASSWORD  | rootpassword   |
| MYSQL_DATABASE       | codeigniter    |
| MYSQL_USER           | ci4user        |
| MYSQL_PASSWORD       | ci4password    |

Change these in `.env` before first build if desired.
