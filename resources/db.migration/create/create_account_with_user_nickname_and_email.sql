CREATE OR REPLACE FUNCTION public.create_account_with_user_nickname_and_email(
    p_account_login text,
    p_email_address text,
    p_encrypted_password text,
    p_aes_key text,
    p_username text,
    p_email_encrypted_password text,
    p_user_phone text DEFAULT NULL::text,
    p_user_description text DEFAULT NULL::text
)
    RETURNS TABLE
            (
                account_id integer,
                user_id    integer,
                email_id   integer
            )
    LANGUAGE plpgsql
AS
$function$
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

    RAISE NOTICE '? Account создан с id: %', v_account_id;

    -- Вставка в users
    INSERT INTO users (account_id, user_name, user_phone, user_description)
    VALUES (v_account_id, p_username, p_user_phone, p_user_description)
    RETURNING id INTO v_user_id;

    RAISE NOTICE '? User создан с id: %', v_user_id;

    -- Вставка в nicknames
    INSERT INTO nicknames (nickname, account_id, user_id)
    VALUES (p_username, v_account_id, v_user_id)
    RETURNING id INTO v_nickname_id;

    RAISE NOTICE '? Nickname создан с id: %', v_nickname_id;

    -- Вставка в emails (с шифрованным паролем)
    INSERT INTO emails (account_id, email_address, encrypted_password, user_id)
    VALUES (v_account_id, p_email_address, p_email_encrypted_password, v_user_id)
    RETURNING id INTO v_email_id;

    RAISE NOTICE '? Email создан с id: %', v_email_id;

    -- Обновляем account с email_id
    UPDATE accounts SET email_id = v_email_id WHERE id = v_account_id;

    -- Добавление связей
    INSERT INTO user_emails (user_id, email_id)
    VALUES (v_user_id, v_email_id);

    INSERT INTO user_nicknames (user_id, nickname_id)
    VALUES (v_user_id, v_nickname_id);

    RAISE NOTICE '? Связи user_emails и user_nicknames добавлены';

    RETURN QUERY SELECT v_account_id, v_user_id, v_email_id;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE '? Ошибка при создании аккаунта: %', SQLERRM;
        RAISE;
END;
$function$;