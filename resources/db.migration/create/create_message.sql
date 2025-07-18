CREATE TABLE messages
(
    id           SERIAL PRIMARY KEY,

    -- Тип сообщения, например: 'banner', 'welcome', 'changelog'
    message_type TEXT NOT NULL,

    -- Заголовок сообщения (может быть null)
    title        TEXT,

    -- Основной текст (HTML/Markdown/Plain)
    content      TEXT NOT NULL,

    -- Формат сообщения (по умолчанию 'html')
    format       TEXT NOT NULL DEFAULT 'html', -- 'html' | 'markdown' | 'plain'

    -- Флаг активности (чтобы можно было скрывать старые сообщения)
    is_active    BOOLEAN       DEFAULT TRUE,

    -- Дата создания и последнего обновления
    created_at   TIMESTAMP     DEFAULT NOW(),
    updated_at   TIMESTAMP     DEFAULT NOW()
);

CREATE INDEX idx_app_messages_type_active
    ON messages (message_type, is_active);