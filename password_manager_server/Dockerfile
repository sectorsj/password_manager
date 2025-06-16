FROM dart:stable AS build

# Рабочая директория в контейнере
WORKDIR /app

# Копируем pubspec и lock-файлы сначала (для кеша)
COPY password_manager_server/pubspec.* ./

# Копируем весь проект сервера
COPY password_manager_server/. .

# Копируем зависимость из общего каталога
COPY common ../common

RUN dart pub get
RUN dart compile exe bin/server.dart -o bin/server

# Финальный минимальный контейнер
FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /app/bin/server /app/server

ENV PORT=8080
EXPOSE 8080
ENTRYPOINT ["/app/server"]
