CREATE OR REPLACE FUNCTION public.create_network_connection_with_nickname_and_email(
    p_account_id BIGINT,
    p_user_id BIGINT,
    p_category_id BIGINT,
    p_nickname TEXT,
    p_encrypted_password TEXT,
    p_network_connection_name VARCHAR,
    p_ipv4 VARCHAR DEFAULT NULL,
    p_ipv6 VARCHAR DEFAULT NULL,
    p_network_connection_description TEXT DEFAULT NULL,
    p_email_address TEXT DEFAULT NULL,
    p_email_encrypted_password TEXT DEFAULT NULL,
    p_email_description TEXT DEFAULT NULL
)
    RETURNS BIGINT
    LANGUAGE plpgsql
AS
$$
DECLARE
    nickname_id         BIGINT;
    email_id            BIGINT;
    new_connection_id   BIGINT;
    v_email_description TEXT;
BEGIN
    -- 1. Проверка и добавление никнейма
    SELECT id
    INTO nickname_id
    FROM nicknames
    WHERE nickname = p_nickname;

    IF nickname_id IS NULL THEN
        INSERT INTO nicknames (nickname, account_id, user_id)
        VALUES (p_nickname, p_account_id, p_user_id)
        RETURNING id INTO nickname_id;
    END IF;

    INSERT INTO user_nicknames (user_id, nickname_id)
    VALUES (p_user_id, nickname_id)
    ON CONFLICT DO NOTHING;

    -- 2. Проверка и добавление email (если указан)
    IF p_email_address IS NOT NULL AND LENGTH(TRIM(p_email_address)) > 0 THEN
        SELECT id
        INTO email_id
        FROM emails
        WHERE email_address = p_email_address;

        IF email_id IS NULL THEN
            -- дефолтное описание, если не указано
            v_email_description :=
                    COALESCE(p_email_description, 'почта создана при создании нового сетевого подключения');

            INSERT INTO emails (email_address,
                                encrypted_password,
                                account_id,
                                user_id,
                                email_description)
            VALUES (p_email_address,
                    COALESCE(p_email_encrypted_password, ''),
                    p_account_id,
                    p_user_id,
                    v_email_description)
            RETURNING id INTO email_id;
        END IF;

        INSERT INTO user_emails (user_id, email_id)
        VALUES (p_user_id, email_id)
        ON CONFLICT DO NOTHING;
    END IF;

    -- 3. Вставка новой записи в network_connections
    INSERT INTO network_connections (account_id,
                                     category_id,
                                     encrypted_password,
                                     network_connection_name,
                                     ipv4,
                                     ipv6,
                                     network_connection_description,
                                     user_id,
                                     nickname_id,
                                     email_id)
    VALUES (p_account_id,
            p_category_id,
            p_encrypted_password,
            p_network_connection_name,
            p_ipv4,
            p_ipv6,
            p_network_connection_description,
            p_user_id,
            nickname_id,
            email_id)
    RETURNING id INTO new_connection_id;

    RETURN new_connection_id;
END;
$$;