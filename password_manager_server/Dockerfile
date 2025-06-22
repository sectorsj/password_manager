# FROM dart:stable AS build
FROM ghcr.io/cirruslabs/flutter:latest AS build

# Рабочая директория в контейнере
WORKDIR /app

# Копируем pubspec и lock-файлы сначала (для кеша)
COPY password_manager_server/pubspec.* ./

# Копируем весь проект сервера
COPY password_manager_server/. .

# Копируем зависимость из общего каталога
COPY common ../common

RUN flutter pub get
RUN apt-get update && apt-get install -y bash
RUN dart compile exe bin/server.dart -o bin/server

# Финальный минимальный контейнер
FROM debian:bookworm-slim

COPY --from=build /app/bin/server /app/server

ENV PORT=8080
EXPOSE 8080
ENTRYPOINT ["/app/server"]
