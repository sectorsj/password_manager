CREATE OR REPLACE FUNCTION public.create_network_connection_entry(
    p_network_connection_name VARCHAR, -- обязательный
    p_encrypted_password TEXT, -- обязательный
    p_account_id BIGINT, -- обязательный
    p_user_id BIGINT, -- обязательный
    p_nickname_id BIGINT, -- обязательный
    p_email_id BIGINT, -- обязательный
    p_category_id BIGINT, -- обязательный
    p_ipv4 VARCHAR DEFAULT NULL, -- опциональный
    p_ipv6 VARCHAR DEFAULT NULL, -- опциональный
    p_network_connection_description TEXT DEFAULT NULL -- опциональный
)
    RETURNS BIGINT
    LANGUAGE plpgsql
AS
$$
DECLARE
    new_connection_id BIGINT;
BEGIN
    -- Проверка существования аккаунта
    IF NOT EXISTS (SELECT 1 FROM accounts WHERE id = p_account_id) THEN
        RAISE EXCEPTION 'Account ID % not found', p_account_id
            USING ERRCODE = 'foreign_key_violation';
    END IF;

    INSERT INTO network_connections (network_connection_name,
                                     encrypted_password,
                                     ipv4,
                                     ipv6,
                                     network_connection_description,
                                     account_id,
                                     user_id,
                                     nickname_id,
                                     email_id,
                                     category_id)
    VALUES (p_network_connection_name,
            p_encrypted_password,
            p_ipv4,
            p_ipv6,
            p_network_connection_description,
            p_account_id,
            p_user_id,
            p_nickname_id,
            p_email_id,
            p_category_id)
    RETURNING id INTO new_connection_id;

    RETURN new_connection_id;
END;
$$;

-- Функция в полном виде
-- 👇 Вставка нового подключения
SELECT public.create_network_connection_entry(
               'WiFi Home',
               'base64enc==',
               102,
               65,
               13,
               24,
               3,
               '192.168.1.1',
               NULL,
               'Основное подключение'
       );