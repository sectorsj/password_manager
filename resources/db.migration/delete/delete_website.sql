-- Функция для удаления записи из таблицы websites
DROP FUNCTION IF EXISTS public.delete_website(
    BIGINT,
    BIGINT
);

CREATE OR REPLACE FUNCTION public.delete_website(
    p_website_id BIGINT,
    p_user_id BIGINT
)
RETURNS VOID AS $$
BEGIN
    DELETE FROM websites
    WHERE id = p_website_id
    AND user_id = p_user_id;
END;
$$ LANGUAGE plpgsql;