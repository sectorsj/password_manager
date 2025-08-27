-- Функция для удаления записи из таблицы network_connections
DROP FUNCTION IF EXISTS public.delete_network_connection(
    BIGINT,
    BIGINT
);

CREATE OR REPLACE FUNCTION public.delete_network_connection(
    p_connection_id BIGINT,
    p_user_id BIGINT
)
RETURNS VOID AS $$
BEGIN
    DELETE FROM network_connections
    WHERE id = p_connection_id
    AND user_id = p_user_id;
END;
$$ LANGUAGE plpgsql;