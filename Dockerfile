FROM crystallang/crystal

WORKDIR /app
COPY shard.yml shard.lock ./
RUN shards install
COPY . .
RUN crystal build --release src/madsci_telegram_bot.cr
EXPOSE 80

# Traefik labels
LABEL traefik.docker.network=web \
      traefik.enable=true \
      traefik.telegram_bot.frontend.rule=Host:telegram-bot.madscientists.co \
      traefik.telegram_bot.port=80 \
      traefik.telegram_bot.protocol=http

CMD ./madsci_telegram_bot
