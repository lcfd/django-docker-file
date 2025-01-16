<center>
  <h1>
    Django Dockerfile
  </h1>
</center>

<center>
A simple repository of configurations
</center>

## Why

After many years of Django deployments I've decided to collect my knowledge in a single repository.
It's a living configuration and is the reflection of the tools I'm using to deploy my applications.

Anyway I the goal is to break down all the piece needed to deploy Django and document them so any piece can be used—as much as possible—everywhere.

Any feedback is welcome.

## Good to know

- Static and media files are hosted and served directly from the hosting machine
- Caddy leaves in the same container of Django—check the Dockerfile
- The base Docker image for Django is `3.12-slim`

## Setup in your project

- Copy `Dockerfile`, `Caddyfile` and `.dockerignore` in your Django project
  - It should be the same place of `pyproject.toml`
- Set the `static` and `media` config variables in the Django's `settings.py` file

## Environment Variables

Those variables are for production. They are used in the below settings.

```bash
# 1 = init service.
# 0 = after the first service, for horizontal deployments
# For example: start.sh will run migrations
IS_INIT=1

DEBUG=False

APP_NAME=yourname

ALLOWED_HOSTS=*
CSRF_TRUSTED_ORIGINS=https://*.mydomain.com
CORS_ALLOWED_ORIGINS=https://...
# CSRF_COOKIE_DOMAIN=.yourdomain.xyz
DATABASE_URL=postgres://asdfasdf:asdfasdf:5432/postgres
SECRET_KEY=asdfasdfasdfasdfasdfasdf

# Superuser
DJANGO_SUPERUSER_EMAIL=your@superuser.email
DJANGO_SUPERUSER_PASSWORD=password
DJANGO_SUPERUSER_USERNAME=username

LANGUAGE_CODE=en-us
TIME_ZONE="UTC"
MEDIA_URL=media/
STATIC_URL=static/
# MEDIA_ROOT=path
# STATIC_ROOT=path

SESSION_COOKIE_SECURE=False
CSRF_COOKIE_SECURE=False
SECURE_SSL_REDIRECT=False

EMAIL_HOST=localhost
EMAIL_PORT=25
EMAIL_HOST_USER=
EMAIL_HOST_PASSWORD=
EMAIL_USE_TLS=False
SERVER_EMAIL=root@localhost
DEFAULT_FROM_EMAIL=django@localhost
```

### Django settings

I suggest you to:

- Install [django-environ](https://github.com/joke2k/django-environ)
- Copy and paste those settings chunk by chunk and not all at the same time.
- Read [Django docs for production](https://docs.djangoproject.com/en/5.0/howto/deployment/checklist/#critical-settings)

```python
import environ

env = environ.Env(
    DEBUG=(bool, False),
    APP_NAME=(str, "APPNAME"),
    ALLOWED_HOSTS=(list[str], ["*"]),
    SECRET_KEY=(str, "asdfasdfasdfasdfasdfasdf"),
    CSRF_TRUSTED_ORIGINS=(list[str], []),
    CORS_ALLOWED_ORIGINS=(list[str], []),
    DATABASE_URL=(str, False),
    LANGUAGE_CODE=(str, "en-us"),
    TIME_ZONE=(str, "UTC"),
    MEDIA_ROOT=(str, BASE_DIR / "media"),
    MEDIA_URL=(str, "media/"),
    STATIC_URL=(str, "static/"),
    STATIC_ROOT=(str, BASE_DIR / "static"),
    SESSION_COOKIE_SECURE=(bool, False),
    CSRF_COOKIE_SECURE=(bool, False),
    CSRF_COOKIE_DOMAIN=(str, None),
    SECURE_SSL_REDIRECT=(bool, False),
    EMAIL_HOST=(str, "localhost"),
    EMAIL_PORT=(int, 25),
    EMAIL_HOST_USER=(str, ""),
    EMAIL_HOST_PASSWORD=(str, ""),
    EMAIL_USE_TLS=(bool, False),
    SERVER_EMAIL=(str, "root@localhost"),
    DEFAULT_FROM_EMAIL=(str, "django@localhost"),
)

# Usage

DEBUG = env("DEBUG")
APP_NAME = env("APP_NAME")
SECRET_KEY = env("SECRET_KEY")
ALLOWED_HOSTS = env.list("ALLOWED_HOSTS")
CSRF_TRUSTED_ORIGINS = env.list("CSRF_TRUSTED_ORIGINS")

database_url = env("DATABASE_URL")

if database_url:
    DATABASES = {
        "default": env.db(),
    }
else:
    DATABASES = {
        "default": {
            "ENGINE": "django.db.backends.sqlite3",
            "NAME": BASE_DIR / 'db.sqlite3'
        }
    }

LANGUAGE_CODE = env("LANGUAGE_CODE")
TIME_ZONE = env("TIME_ZONE")

MEDIA_ROOT = env("MEDIA_ROOT")
MEDIA_URL = env("MEDIA_URL")
STATIC_URL = env("STATIC_URL")
STATIC_ROOT = env("STATIC_ROOT")

SESSION_COOKIE_SECURE = env("SESSION_COOKIE_SECURE")
CSRF_COOKIE_SECURE = env("CSRF_COOKIE_SECURE")
# I used it for subdomains on the same domain
CSRF_COOKIE_DOMAIN = env("CSRF_COOKIE_DOMAIN")

SECURE_SSL_REDIRECT = env("SECURE_SSL_REDIRECT")

EMAIL_HOST = env("EMAIL_HOST")
EMAIL_PORT = env("EMAIL_PORT")
EMAIL_HOST_USER = env("EMAIL_HOST_USER")
EMAIL_HOST_PASSWORD = env("EMAIL_HOST_PASSWORD")
EMAIL_USE_TLS = env("EMAIL_USE_TLS")
SERVER_EMAIL = env("SERVER_EMAIL")
DEFAULT_FROM_EMAIL = env("DEFAULT_FROM_EMAIL")
```

## On Coolify

Your project will be exposed on the `8001` port by Caddy.

- In `Ports Mappings` set `your_port:8001`
- In `Ports Exposes` set `8001`.

### Domain and Ports

Set your domain in `Domains`.
Set `Ports Exposes` with the port number used by Caddy.

### Volumes

If you are storing uploaded files ([media files](https://docs.djangoproject.com/en/5.1/topics/files/)) on the filesystem you need a Docker volume.

1. Go to `Storages`
2. `+ Add` to create new volumes
3. Add one volume for `media` with `Destination Path` set to `/project/media`

### Env variables

1. Go to the `Environment Variables` tab of your service configuration
2. Set the variables seen above

### Database

Create a new service using `postgresql`.
The containers will be on the same network so the the configurations in the `Environment Variables` section should work right away.

**Remember** to use the password provided in the General tab.

### Build

If your Django project leves in a subfolder of the repository:

- Set `Base Directory` to: `/your-folder-name`
- Set `Dockerfile Location` to: `/Dockerfile` (assuming that it's at the root of your project)
- Set `Watch Paths` to: `your-folder-name/*`

## Extra

#### Useful commands for automated tasks

- `python manage.py createsuperuser --noinput`
- `python manage.py collectstatic --noinput`
