####################
# - Production
####################
FROM docker.io/debian:bookworm-slim

# Install System Dependencies
RUN apt-get update && apt-get install python3 curl -y

# Install Quarto
ADD https://github.com/quarto-dev/quarto-cli/releases/download/v1.4.553/quarto-1.4.553-linux-amd64.deb /quarto.deb
RUN dpkg -i /quarto.deb && rm /quarto.deb

# Install UV (faster pip)
ADD https://astral.sh/uv/install.sh /install.sh
RUN chmod +x /install.sh && /install.sh && rm /install.sh

# Copy App
COPY . /app
WORKDIR /app

# Install Python Dependencies
RUN /root/.cargo/bin/uv venv && VIRTUAL_ENV=.venv /root/.cargo/bin/uv pip install --no-cache -r requirements-dev.lock

# Build Quarto Book
WORKDIR /app/book
RUN . ../.venv/bin/activate && quarto render --to html

####################
# - Production
####################
FROM ghcr.io/static-web-server/static-web-server:2
COPY --from=0 /app/book/_book /app 

# Set Server Options
ENV SERVER_PORT 8787
ENV SERVER_ROOT /app
ENV SERVER_LOG_LEVEL info

# Set User
USER 5030
