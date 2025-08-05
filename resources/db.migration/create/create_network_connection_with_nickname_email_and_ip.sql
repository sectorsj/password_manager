CREATE OR REPLACE FUNCTION public.create_network_connection_with_nickname_email_and_ip(
  p_account_id bigint,
  p_user_id bigint,
  p_category_id bigint,
  p_nickname text,
  p_encrypted_password text,
  p_network_connection_name varchar,
  p_ipv4 varchar DEFAULT NULL,
  p_ipv6 varchar DEFAULT NULL,
  p_network_connection_description text DEFAULT NULL,
  p_email_address text DEFAULT NULL,
  p_email_encrypted_password text DEFAULT NULL,
  p_email_description text DEFAULT NULL
)
RETURNS bigint
LANGUAGE plpgsql
AS $function$
DECLARE
  nickname_id       BIGINT;
  email_id          BIGINT;
  new_connection_id BIGINT;
BEGIN
  -- ========== 1. Никнейм ==========
  IF p_nickname IS NULL OR LENGTH(TRIM(p_nickname)) = 0 THEN
    RAISE EXCEPTION 'Никнейм не может быть пустым';
  END IF;

  -- Проверка существования никнейма
  SELECT id INTO nickname_id FROM nicknames
  WHERE nickname = p_nickname;

  IF nickname_id IS NULL THEN
    INSERT INTO nicknames (nickname, account_id, user_id)
    VALUES (p_nickname, p_account_id, p_user_id)
    RETURNING id INTO nickname_id;
  END IF;

  -- Привязка к пользователю
  INSERT INTO user_nicknames (user_id, nickname_id)
  VALUES (p_user_id, nickname_id)
  ON CONFLICT DO NOTHING;

  -- ========== 2. Email ==========
  -- Если email не указан явно — подставим почту по account_id
  IF p_email_address IS NULL OR LENGTH(TRIM(p_email_address)) = 0 THEN
    SELECT email_address INTO p_email_address
    FROM emails
    WHERE account_id = p_account_id
    LIMIT 1;
  END IF;

  -- Если удалось получить email — ищем или создаём email_id
  IF p_email_address IS NOT NULL AND LENGTH(TRIM(p_email_address)) > 0 THEN
    -- Получаем email_id, если уже есть такой email
    SELECT id INTO email_id
    FROM emails
    WHERE email_address = p_email_address
    LIMIT 1;

    -- Если email не найден — создаём
    IF email_id IS NULL THEN
      INSERT INTO emails (
        email_address,
        encrypted_password,
        account_id,
        user_id,
        category_id,
        email_description
      )
      VALUES (
        p_email_address,
        COALESCE(p_email_encrypted_password, ''),
        p_account_id,
        p_user_id,
        3,
        COALESCE(p_email_description, 'Добавлено при создании подключения')
      )
      RETURNING id INTO email_id;
    END IF;

    -- Привязка к пользователю
    INSERT INTO user_emails (user_id, email_id)
    VALUES (p_user_id, email_id)
    ON CONFLICT DO NOTHING;
  END IF;

  -- ========== 3. IP ==========

  IF p_ipv4 IS NOT NULL AND LENGTH(TRIM(p_ipv4)) = 0 THEN
    p_ipv4 := NULL;
  END IF;

  IF p_ipv6 IS NOT NULL AND LENGTH(TRIM(p_ipv6)) = 0 THEN
    p_ipv6 := NULL;
  END IF;

  -- ========== 4. Подключение ==========

  INSERT INTO network_connections (
    account_id,
    category_id,
    encrypted_password,
    network_connection_name,
    ipv4,
    ipv6,
    network_connection_description,
    user_id,
    nickname_id,
    email_id
  )
  VALUES (
    p_account_id,
    p_category_id,
    p_encrypted_password,
    p_network_connection_name,
    p_ipv4,
    p_ipv6,
    p_network_connection_description,
    p_user_id,
    nickname_id,
    email_id
  )
  RETURNING id INTO new_connection_id;

  RETURN new_connection_id;
END;
$function$;