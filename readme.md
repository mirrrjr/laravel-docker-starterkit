# Laravel & Docker starterkit

## local.sh sozlash

```bash
chmod +x local.sh
```

## Laravel proyektni sozlash

```bash
./local.sh ssh

cp .env.example .env

composer install

npm install
```

## .env faylni sozlash

```env
DB_CONNECTION=mysql
DB_HOST=database
DB_PORT=3306
DB_DATABASE=hh
DB_USERNAME=user
DB_PASSWORD=password

REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

MAIL_MAILER=smtp
MAIL_HOST=mailhog
MAIL_PORT=1025
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
MAIL_FROM_ADDRESS="foo@bar"
MAIL_FROM_NAME="${APP_NAME}"
```

```bash
php artisan key:generate

php artisan storage:link

php artisan migrate

exit
```

## SETUP PERMISSIONS

```bash
docker compose exec app chmod -R 775 storage bootstrap/cache
docker compose exec app chown -R www-data:www-data storage bootstrap/cache
sudo chown -R $USER:$USER ./src
```

## Docker-ni ishga tushirish

```bash
./local.sh start
```

> Foydali docker komandalari:

```bash
 docker stop $(docker ps -q)
 docker rm $(docker ps -a -q)
 docker rmi $(docker images -q)
 ```
