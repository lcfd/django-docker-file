ARG PYTHON_BASE=3.12-slim

# Build stage
FROM python:$PYTHON_BASE AS builder

RUN pip install -U pdm
ENV PDM_CHECK_UPDATE=false
COPY pyproject.toml pdm.lock /project/

WORKDIR /project
RUN pdm install --check --prod --no-editable

# Run stage
FROM python:$PYTHON_BASE

COPY --from=builder /project/.venv/ /project/.venv
ENV PATH="/project/.venv/bin:$PATH"
COPY . /project

# Caddy

RUN apt update && \
  apt install -y debian-keyring debian-archive-keyring apt-transport-https curl systemd && \
  curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg && \
  curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list && \
  apt install -y caddy && \
  mkdir -p /etc/caddy && \
  cp /project/Caddyfile /etc/caddy/Caddyfile

RUN chmod +x /project/start.sh

# Volumes

VOLUME /project/static /project/media

EXPOSE 8001

# Run Django
# Don't use CMD, it won't work
ENTRYPOINT ["/project/start.sh"]
