-- Active: 1754396778746@@127.0.0.1@5432@passkeeper
-- Функция для удаления записи из таблицы emails
DROP FUNCTION IF EXISTS delete_email(
    BIGINT,
    BIGINT
);

CREATE OR REPLACE FUNCTION public.delete_email(
    p_email_id BIGINT,
    p_user_id BIGINT
)
RETURNS VOID AS $$
BEGIN
    DELETE FROM emails
    WHERE id = p_email_id 
    AND user_id = p_user_id;
END;
$$ LANGUAGE plpgsql;