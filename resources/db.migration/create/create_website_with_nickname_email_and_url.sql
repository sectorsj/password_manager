-- PostgreSQL function to create a website with nickname, email, and URL
-- This function checks for existing nicknames and emails, creates them if necessary,
CREATE OR REPLACE FUNCTION public.create_website_with_nickname_email_and_url(
  p_account_id                  BIGINT,
  p_user_id                     BIGINT,
  p_category_id                 BIGINT,
  p_nickname                    TEXT,
  p_encrypted_password          TEXT,
  p_website_name                VARCHAR,
  p_website_url                 VARCHAR,
  p_website_description         TEXT DEFAULT NULL,
  p_email_address               TEXT DEFAULT NULL,
  p_email_encrypted_password    TEXT DEFAULT NULL,
  p_email_description           TEXT DEFAULT NULL
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $function$
DECLARE
  v_nickname_id    BIGINT; -- Переименовано, чтобы избежать конфликта
  v_email_id       BIGINT; -- Переименовано
  new_website_id   BIGINT;
BEGIN
  -- ========== 1. Никнейм ==========
  IF p_nickname IS NULL OR LENGTH(TRIM(p_nickname)) = 0 THEN
    RAISE EXCEPTION 'Никнейм не может быть пустым';
  END IF;

  SELECT id INTO v_nickname_id
  FROM nicknames
  WHERE nickname = p_nickname;

  IF v_nickname_id IS NULL THEN
    INSERT INTO nicknames (nickname, account_id, user_id)
    VALUES (p_nickname, p_account_id, p_user_id)
    RETURNING id INTO v_nickname_id;
  END IF;

  INSERT INTO user_nicknames (user_id, nickname_id)
  VALUES (p_user_id, v_nickname_id)
  ON CONFLICT DO NOTHING;

  -- ========== 2. Email ==========
  IF p_email_address IS NULL OR LENGTH(TRIM(p_email_address)) = 0 THEN
    SELECT email_address INTO p_email_address
    FROM emails
    WHERE account_id = p_account_id
    ORDER BY created_at ASC
    LIMIT 1;
  END IF;

  IF p_email_address IS NOT NULL AND LENGTH(TRIM(p_email_address)) > 0 THEN
    SELECT id INTO v_email_id
    FROM emails
    WHERE email_address = p_email_address
    LIMIT 1;

    IF v_email_id IS NULL THEN
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
        COALESCE(p_email_description, 'Добавлено при создании вебсайта')
      )
      RETURNING id INTO v_email_id;
    END IF;

    INSERT INTO user_emails (user_id, email_id)
    VALUES (p_user_id, v_email_id)
    ON CONFLICT DO NOTHING;
  ELSE
    v_email_id := NULL;
  END IF;

  -- ========== 3. Проверка уникальности ==========
  IF EXISTS (
    SELECT 1 FROM websites w
    WHERE w.user_id = p_user_id
      AND w.nickname_id = v_nickname_id -- Используем переименованную переменную
      AND ((w.email_id = v_email_id) OR (w.email_id IS NULL AND v_email_id IS NULL))
      AND w.website_url = p_website_url
  ) THEN
    RAISE EXCEPTION 'Такой сайт уже добавлен с этим никнеймом и почтой';
  END IF;

  -- ========== 4. Сохранение вебсайта ==========
  INSERT INTO websites (
    account_id,
    category_id,
    encrypted_password,
    website_name,
    website_url,
    website_description,
    user_id,
    nickname_id,
    email_id
  )
  VALUES (
    p_account_id,
    p_category_id,
    p_encrypted_password,
    p_website_name,
    p_website_url,
    p_website_description,
    p_user_id,
    v_nickname_id, -- Используем переименованную переменную
    v_email_id -- Используем переименованную переменную
  )
  RETURNING id INTO new_website_id;

  RETURN new_website_id;
END;
$function$;