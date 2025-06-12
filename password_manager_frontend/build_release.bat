@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

:: Проверка FLUTTER_HOME
if not defined FLUTTER_HOME (
    echo ❌ Переменная окружения FLUTTER_HOME не установлена.
    pause
    exit /b 1
)

set FLUTTER=%FLUTTER_HOME%\bin\flutter.bat

echo ============================
echo Сборка Flutter Windows Release
echo ============================

:: Переход в директорию скрипта
cd /d "%~dp0"

:: Удаление старого лога
if exist build_log.txt del /f /q build_log.txt

:: Убираем миллисекунды и запятые из времени
for /f "tokens=1 delims=," %%a in ("%time%") do set TIME_LOG=%%a

:: Логирование начала сборки
echo --- Начало сборки: %DATE% %TIME_LOG% --- >> build_log.txt

:: Очистка
echo --- flutter clean --- >> build_log.txt
call "%FLUTTER%" clean >> build_log.txt 2>&1

:: pub get
echo --- flutter pub get --- >> build_log.txt
call "%FLUTTER%" pub get >> build_log.txt 2>&1

:: Сборка
echo --- flutter build windows --- >> build_log.txt
call "%FLUTTER%" build windows --target=lib/client.dart >> build_log.txt 2>&1

:: Проверка
set "OUTPUT_EXE=build\windows\x64\runner\Release\password_manager_frontend.exe"
if exist "!OUTPUT_EXE!" (
    echo ✅ Сборка завершена успешно!
    echo --- УСПЕШНАЯ СБОРКА: %DATE% %TIME_LOG% --- >> build_log.txt
    start "" "build\windows\x64\runner\Release"
) else (
    echo ❌ Сборка не удалась. См. build_log.txt
    echo --- ОШИБКА СБОРКИ: %DATE% %TIME_LOG% --- >> build_log.txt
    start "" build_log.txt
)

pause