CREATE OR REPLACE FUNCTION create_website_entry(
    p_website_name TEXT,
    p_website_url TEXT,
    p_website_password TEXT,
    p_account_id BIGINT,
    p_user_id BIGINT,
    p_nickname_id BIGINT,
    p_email_id BIGINT,
    p_category_id BIGINT,
    p_website_description TEXT DEFAULT NULL
)
    RETURNS BIGINT
    LANGUAGE plpgsql
AS
$$
DECLARE
    new_website_id BIGINT;
BEGIN
    -- Проверка существования аккаунта
    IF NOT EXISTS (SELECT 1 FROM accounts WHERE id = p_account_id) THEN
        RAISE EXCEPTION 'Account ID % not found', p_account_id
            USING ERRCODE = 'foreign_key_violation';
    END IF;

    -- Вставка в websites
    INSERT INTO websites (website_name,
                          website_url,
                          encrypted_password,
                          website_description,
                          account_id,
                          user_id,
                          nickname_id,
                          email_id,
                          category_id)
    VALUES (p_website_name,
            p_website_url,
            p_website_password,
            p_website_description,
            p_account_id,
            p_user_id,
            p_nickname_id,
            p_email_id,
            p_category_id)
    RETURNING id INTO new_website_id;

    RETURN new_website_id;
END;
$$;

-- Заполнение БД
SELECT create_website_entry(
               'SC2',
               'https://star-craft2.com',
               'encryptedpassHERE==',
               112,
               56,
               3,
               13,
               4,
               'Это мой любимый сайт по SC2'
       );

