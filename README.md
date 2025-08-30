# oc-apt
OpenComputer APT Manager for Minecraft 1.7.10

APT-подобный пакетный менеджер для OpenComputers мода. Позволяет легко устанавливать, обновлять и удалять программы на ваших компьютерах в игре.

## Особенности

- 📦 Установка и удаление пакетов одной командой
- 🔄 Автоматическое разрешение зависимостей
- 📋 Управление репозиториями
- 🔍 Поиск доступных пакетов
- 📊 Просмотр информации о пакетах
- 💾 Локальная база данных установленных пакетов

## Установка

1. Скопируйте файл `oc-apt.lua` в `/usr/bin/` или `/bin/`
2. Сделайте его исполняемым: `chmod +x /usr/bin/oc-apt.lua`
3. Создайте символическую ссылку: `ln -s /usr/bin/oc-apt.lua /usr/bin/apt`

## Использование

### Основные команды

```bash
# Обновить список пакетов
apt update

# Установить пакет
apt install <package_name>

# Удалить пакет
apt remove <package_name>

# Поиск пакетов
apt search <query>

# Показать информацию о пакете
apt show <package_name>

# Список установленных пакетов
apt list --installed

# Обновить все пакеты
apt upgrade
```

### Управление репозиториями

```bash
# Добавить репозиторий
apt add-repo <url>

# Удалить репозиторий
apt remove-repo <url>

# Список репозиториев
apt list-repos
```

## Структура пакета

Пакеты представлены в формате JSON:

```json
{
  "name": "example-package",
  "version": "1.0.0",
  "description": "Пример пакета",
  "author": "username",
  "dependencies": ["dependency1", "dependency2"],
  "files": {
    "/usr/bin/example.lua": "https://example.com/files/example.lua",
    "/etc/example.conf": "https://example.com/files/example.conf"
  },
  "install_script": "https://example.com/install.lua",
  "remove_script": "https://example.com/remove.lua"
}
```

## Репозитории

По умолчанию использует официальный репозиторий. Можно добавлять свои репозитории.

## Лицензия

MIT License
