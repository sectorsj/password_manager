CREATE OR REPLACE FUNCTION create_account_with_user_and_email(
    p_account_login VARCHAR,
    p_email_address VARCHAR,
    p_encrypted_password TEXT,
    p_username VARCHAR DEFAULT NULL,
    p_phone VARCHAR DEFAULT NULL,
    p_user_description VARCHAR DEFAULT NULL
)
    RETURNS TABLE
            (
                account_id BIGINT,
                user_id    BIGINT,
                email_id   BIGINT
            )
AS
$$
DECLARE
    new_account_id BIGINT;
    new_user_id    BIGINT;
    new_email_id   BIGINT;
BEGIN
    -- Проверка: логин аккаунта должен быть уникальным
    IF EXISTS (SELECT 1 FROM accounts WHERE account_login = p_account_login) THEN
        RAISE EXCEPTION 'Account login "%" already exists', p_account_login
            USING ERRCODE = 'unique_violation';
    END IF;

    -- Проверка: email должен быть уникальным
    IF EXISTS (SELECT 1 FROM emails WHERE email_address = p_email_address) THEN
        RAISE EXCEPTION 'Email "%" already exists', p_email_address
            USING ERRCODE = 'unique_violation';
    END IF;

    -- Создание аккаунта
    INSERT INTO accounts (account_login, account_email)
    VALUES (p_account_login, p_email_address)
    RETURNING id INTO new_account_id;

    -- Создание пользователя
    INSERT INTO users (account_id, user_name, user_phone, user_description)
    VALUES (new_account_id, p_username, p_phone, p_user_description)
    RETURNING id INTO new_user_id;

    -- Создание email, связанной с аккаунтом и пользователем
    INSERT INTO emails (email_address, encrypted_password, account_id, user_id)
    VALUES (p_email_address, p_encrypted_password, new_account_id, new_user_id)
    RETURNING id INTO new_email_id;

    RETURN QUERY SELECT new_account_id, new_user_id, new_email_id;
END;
$$ LANGUAGE plpgsql;


-- Заполнение БД
SELECT *
FROM create_account_with_user_and_email(
        'sectorsj',
        'sectorsj@email.com',
        '100',
        'Sector85',
        '8(900) 000-00-00',
        'Описание пользователя SectorSj'
     );

SELECT *
FROM create_account_with_user_and_email(
        'Alice100',
        'alice@email.ru',
        '100',
        'alice',
        '8(900) 123-45-67',
        'Описание пользователя Алиса'
     );