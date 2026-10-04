# Laravel Docker Starter Kit

A ready-to-use, universal Docker environment for Laravel 13. The starter kit comes with PHP-FPM, Nginx, MySQL, Redis, and Mailpit.

## Requirements

- Docker Engine 24+ and Docker Compose v2 (`docker compose version` must work);
- A Linux/macOS/WSL terminal;
- Ports 8000, 3306, 6379, 8025, and 1025 must be free.

Windows users running Docker Desktop are advised to run the commands inside WSL. You don't need to install PHP, Composer, Node.js, or MySQL on the host.

## Quick start

```bash
git clone <repository-url> my-project
cd my-project
chmod +x local.sh
./local.sh init
```

`init` does the following: creates `src/.env` from the example file, builds the images, starts the services, installs Composer and npm packages, generates the Laravel `APP_KEY`, and runs the migrations.

The following addresses then become available:

| Service              | Address               |
| -------------------- | --------------------- |
| Laravel              | http://localhost:8000 |
| Mailpit (test mails) | http://localhost:8025 |
| MySQL                | `127.0.0.1:3306`      |
| Redis                | `127.0.0.1:6379`      |

On the first run, use the default `DB_PASSWORD=secret` and `DB_ROOT_PASSWORD=root` values in `src/.env` for local development only. For a real project or a shared computer, replace them with strong secrets.

## Daily commands

Every command passes exactly the `src/.env` file to Compose. This ensures that the MySQL values in Docker and the `DB_*` values in Laravel are always identical.

```bash
./local.sh up                         # start services in the background
./local.sh down                       # stop services (data is preserved)
./local.sh rebuild                    # rebuild the Docker images
./local.sh logs app                   # view the log of a chosen service
./local.sh shell                      # shell inside the app container
./local.sh artisan migrate
./local.sh artisan test
./local.sh composer require laravel/sanctum
./local.sh npm run dev -- --host 0.0.0.0
```

If you need the Vite development server, run `./local.sh npm run dev -- --host 0.0.0.0` in a separate terminal and add `VITE_HOST=0.0.0.0` to `src/.env`. For production, use `./local.sh npm run build`.

If an `npm`-related error occurs:

```bash
docker compose --env-file ./src/.env exec -u root app bash

mkdir -p /home/laravel
chown -R laravel:laravel /home/laravel
```

### PHPMyAdmin

PHPMyAdmin is not included in the default startup. If you need it:

```bash
docker compose --env-file src/.env --profile tools up -d phpmyadmin
```

It will be available at http://localhost:8888. The login credentials are the `DB_USERNAME` and `DB_PASSWORD` values in `src/.env`.

## Environment configuration

All project-specific settings live in `src/.env`. This file is not committed to Git; to share changes, edit `src/.env.example`. Key values:

```dotenv
APP_URL=http://localhost:8000
DB_CONNECTION=mysql
DB_HOST=database
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=laravel
DB_PASSWORD=secret
DB_ROOT_PASSWORD=root
REDIS_HOST=redis
MAIL_HOST=mailpit
MAIL_PORT=1025
```

The `DB_HOST`, `REDIS_HOST`, and `MAIL_HOST` values are container service names, so they are not `localhost`. After changing `.env`, clear the Laravel configuration cache and recreate Compose:

```bash
./local.sh artisan optimize:clear
./local.sh rebuild
```

If there is a port conflict, add something like `APP_PORT=8080`, `FORWARD_DB_PORT=3307`, or `PMA_PORT=8889` to the same file. Also change the Laravel address accordingly, e.g. `APP_URL=http://localhost:8080`.

Changing the MySQL password in `.env` for an already-initialized database only takes effect when a new database volume is created. If your local data can be deleted, use the following (**all local MySQL/Redis data will be deleted**):

```bash
docker compose --env-file src/.env down -v
./local.sh up
./local.sh artisan migrate
```

## Architecture

- **web**: Nginx, serves only the `public/` directory over HTTP.
- **app**: PHP 8.4-FPM, Composer, Node 22/npm, `pdo_mysql`, `redis`, GD, Intl, and the other extensions Laravel requires.
- **database**: MySQL 8.4, stored in a named volume.
- **redis**: Redis 7, stored in a named volume.
- **mailpit**: captures and displays development emails.

You can check the final Compose configuration with the `docker compose --env-file src/.env config` command. Do not use this development stack directly for production deployment: provide secrets through a secret manager, close the development ports, and build a separate production image.

---

Note: in the original, the `npm` troubleshooting code block had a stray backtick at the end and was missing a colon before it. I fixed both in the translation.
