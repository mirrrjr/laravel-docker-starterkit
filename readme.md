# Laravel Docker Starter Kit

Laravel 13 uchun ishga tayyor, universal Docker muhiti. Starter kit PHP-FPM,
Nginx, MySQL, Redis va Mailpit bilan birga keladi.

## Talablar

- Docker Engine 24+ va Docker Compose v2 (`docker compose version` ishlashi kerak);
- Linux/macOS/WSL terminali;
- 8000, 3306, 6379, 8025 va 1025 portlari bo'sh bo'lishi kerak.

Docker Desktop ishlatayotgan Windows foydalanuvchilari buyruqlarni WSL ichida
ishga tushirishi tavsiya qilinadi. PHP, Composer, Node.js yoki MySQL ni hostga
o'rnatish shart emas.

## Tez boshlash

```bash
git clone <repository-url> my-project
cd my-project
chmod +x local.sh
./local.sh init
```

`init` quyidagilarni bajaradi: `src/.env` ni namunadan yaratadi, imagelarni
build qiladi, servislarni ishga tushiradi, Composer va npm paketlarini
o'rnatadi, Laravel `APP_KEY` qiymatini yaratadi va migratsiyalarni bajaradi.

So'ng quyidagi manzillar ochiladi:

| Xizmat                | Manzil                |
| --------------------- | --------------------- |
| Laravel               | http://localhost:8000 |
| Mailpit (test xatlar) | http://localhost:8025 |
| MySQL                 | `127.0.0.1:3306`      |
| Redis                 | `127.0.0.1:6379`      |

Ilk ishga tushishda `src/.env` dagi standart `DB_PASSWORD=secret` va
`DB_ROOT_PASSWORD=root` qiymatlarini faqat lokal development uchun ishlating.
Real loyiha yoki umumiy kompyuterda ularni kuchli maxfiy qiymatlarga almashtiring.

## Kunlik buyruqlar

Har bir buyruq Compose'ga aynan `src/.env` faylini beradi. Bu Docker'dagi MySQL
qiymatlari va Laravel'dagi `DB_*` qiymatlari doimo bir xil bo'lishini ta'minlaydi.

```bash
./local.sh up                         # servislarni fon rejimida boshlash
./local.sh down                       # servislarni o'chirish (ma'lumotlar saqlanadi)
./local.sh rebuild                    # Docker image'larni qayta build qilish
./local.sh logs app                   # tanlangan servis logini ko'rish
./local.sh shell                      # app container ichida shell
./local.sh artisan migrate
./local.sh artisan test
./local.sh composer require laravel/sanctum
./local.sh npm run dev -- --host 0.0.0.0
```

Vite development server kerak bo'lsa, alohida terminalda `./local.sh npm run dev
-- --host 0.0.0.0` buyrug'ini ishga tushiring va `src/.env` ga
`VITE_HOST=0.0.0.0` qo'shing. Production uchun `./local.sh npm run build` dan
foydalaning.

`npm` bilan bog'liq xato chiqsa

```bash
docker compose --env-file ./src/.env exec -u root app bash`

mkdir -p /home/laravel
chown -R laravel:laravel /home/laravel
```

### PHPMyAdmin

PHPMyAdmin odatiy ishga tushirishga kiritilmagan. Kerak bo'lsa:

```bash
docker compose --env-file src/.env --profile tools up -d phpmyadmin
```

U http://localhost:8888 manzilida bo'ladi. Login ma'lumotlari `src/.env` dagi
`DB_USERNAME` va `DB_PASSWORD` qiymatlaridir.

## Muhitni sozlash

Loyihaga tegishli barcha sozlamalar `src/.env` da bo'ladi. Bu fayl Git'ga
kiritilmaydi; ulashish uchun `src/.env.example` ni tahrirlang. Muhim qiymatlar:

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

`DB_HOST`, `REDIS_HOST` va `MAIL_HOST` qiymatlari container servis nomlari,
shuning uchun `localhost` emas. `.env` o'zgarganidan keyin Laravel konfiguratsiya
cache'ini tozalang va Compose'ni qayta yarating:

```bash
./local.sh artisan optimize:clear
./local.sh rebuild
```

Port to'qnashuvi bo'lsa, xuddi shu faylga masalan `APP_PORT=8080`,
`FORWARD_DB_PORT=3307` yoki `PMA_PORT=8889` qo'shing. Laravel manzilini ham
mos ravishda `APP_URL=http://localhost:8080` qilib o'zgartiring.

`.env` dagi MySQL parolini allaqachon ishga tushgan database uchun o'zgartirish
faqat yangi database volume yaratilganda ta'sir qiladi. Lokal ma'lumotlarni
o'chirish mumkin bo'lsa, quyidagidan foydalaning (**barcha MySQL/Redis lokal
ma'lumotlari o'chadi**):

```bash
docker compose --env-file src/.env down -v
./local.sh up
./local.sh artisan migrate
```

## Arxitektura

- **web** — Nginx, faqat `public/` katalogini HTTP orqali beradi.
- **app** — PHP 8.4-FPM, Composer, Node 22/npm, `pdo_mysql`, `redis`, GD, Intl
  va Laravel uchun zarur extensionlar.
- **database** — MySQL 8.4, named volume'da saqlanadi.
- **redis** — Redis 7, named volume'da saqlanadi.
- **mailpit** — development xatlarini ushlab ko'rsatadi.

`docker compose --env-file src/.env config` buyrug'i bilan Compose yakuniy
konfiguratsiyasini tekshirish mumkin. Production deploy uchun ushbu development
stackni to'g'ridan-to'g'ri ishlatmang: maxfiy qiymatlarni secret manager orqali
bering, development portlarini yopib qo'ying va alohida production image yarating.
