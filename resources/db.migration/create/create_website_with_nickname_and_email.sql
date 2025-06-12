CREATE OR REPLACE FUNCTION public.create_website_with_nickname_and_email(
    p_account_id bigint,
    p_user_id bigint,
    p_category_id bigint,
    p_nickname text,
    p_website_password text,
    p_website_name text,
    p_website_url text,
    p_website_description text DEFAULT NULL,
    p_email_address text DEFAULT NULL,
    p_email_password text DEFAULT NULL,
    p_email_description text DEFAULT NULL
)
    RETURNS bigint
    LANGUAGE plpgsql
AS
$function$
DECLARE
    nickname_id    BIGINT;
    email_id       BIGINT;
    new_website_id BIGINT;
BEGIN
    -- 1. Никнейм
    SELECT id INTO nickname_id FROM nicknames WHERE nickname = p_nickname;
    IF nickname_id IS NULL THEN
        INSERT INTO nicknames (nickname)
        VALUES (p_nickname)
        RETURNING id INTO nickname_id;
    END IF;

    INSERT INTO user_nicknames (user_id, nickname_id)
    VALUES (p_user_id, nickname_id)
    ON CONFLICT DO NOTHING;

    -- 2. Email (если указан)
    IF p_email_address IS NOT NULL AND LENGTH(TRIM(p_email_address)) > 0 THEN
        SELECT id INTO email_id FROM emails WHERE email_address = p_email_address;

        IF email_id IS NULL THEN
            INSERT INTO emails (email_address,
                                encrypted_password,
                                account_id,
                                user_id,
                                email_description)
            VALUES (p_email_address,
                    COALESCE(p_email_password, ''),
                    p_account_id,
                    p_user_id,
                    p_email_description)
            RETURNING id INTO email_id;
        END IF;

        INSERT INTO user_emails (user_id, email_id)
        VALUES (p_user_id, email_id)
        ON CONFLICT DO NOTHING;
    END IF;

    -- 3. Вставка в websites
    INSERT INTO websites (website_name,
                          website_url,
                          website_description,
                          encrypted_password,
                          website_email,
                          account_id,
                          category_id,
                          user_id,
                          nickname_id,
                          email_id)
    VALUES (p_website_name,
            p_website_url,
            p_website_description,
            p_website_password,
            p_email_address, -- будет отображаться на карточке
            p_account_id,
            p_category_id,
            p_user_id,
            nickname_id,
            email_id)
    RETURNING id INTO new_website_id;

    RETURN new_website_id;
END;
$function$;