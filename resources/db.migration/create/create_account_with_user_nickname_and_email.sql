CREATE OR REPLACE FUNCTION create_account_with_user_nickname_and_email(
    p_account_login TEXT,
    p_email_address TEXT,
    p_encrypted_password TEXT,
    p_aes_key TEXT,
    p_username TEXT,
    p_user_phone TEXT DEFAULT NULL,
    p_user_description TEXT DEFAULT NULL
)
    RETURNS TABLE
            (
                account_id INTEGER,
                user_id    INTEGER,
                email_id   INTEGER
            )
AS
$$
DECLARE
    v_account_id  INTEGER;
    v_user_id     INTEGER;
    v_email_id    INTEGER;
    v_nickname_id INTEGER;
BEGIN
    -- Проверка уникальности логина
    IF EXISTS (SELECT 1 FROM accounts WHERE account_login = p_account_login) THEN
        RAISE EXCEPTION 'Логин "%" уже используется', p_account_login;
    END IF;

    -- Проверка уникальности email
    IF EXISTS (SELECT 1 FROM emails WHERE email_address = p_email_address) THEN
        RAISE EXCEPTION 'Email "%" уже используется', p_email_address;
    END IF;

    -- Проверка уникальности nickname
    IF EXISTS (SELECT 1 FROM nicknames WHERE nickname = p_username) THEN
        RAISE EXCEPTION 'Псевдоним "%" уже используется', p_username;
    END IF;

    -- Вставка в accounts
    INSERT INTO accounts (account_login, encrypted_password, aes_key)
    VALUES (p_account_login, p_encrypted_password, p_aes_key)
    RETURNING id INTO v_account_id;

    RAISE NOTICE '✅ Account создан с id: %', v_account_id;

    -- Вставка в users
    INSERT INTO users (account_id, user_phone, user_description)
    VALUES (v_account_id, p_user_phone, p_user_description)
    RETURNING id INTO v_user_id;

    RAISE NOTICE '✅ User создан с id: %', v_user_id;

    -- Вставка в nicknames с user_id
    INSERT INTO nicknames (nickname, account_id, user_id)
    VALUES (p_username, v_account_id, v_user_id)
    RETURNING id INTO v_nickname_id;

    RAISE NOTICE '✅ Nickname создан с id: %', v_nickname_id;

    -- Вставка в emails
    INSERT INTO emails (account_id, email_address)
    VALUES (v_account_id, p_email_address)
    RETURNING id INTO v_email_id;

    RAISE NOTICE '✅ Email создан с id: %', v_email_id;

    -- Обновляем account с email_id
    UPDATE accounts SET email_id = v_email_id WHERE id = v_account_id;

    -- Возвращаем идентификаторы
    RETURN QUERY SELECT v_account_id, v_user_id, v_email_id;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE '❌ Ошибка при создании аккаунта: %', SQLERRM;
        RAISE;
END;
$$ LANGUAGE plpgsql;