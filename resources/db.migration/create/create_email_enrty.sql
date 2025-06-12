-- SELECT public.create_email_entry
--     'first@mail.ru',        --
--     'Мой First email',      --
--     '100',                  --
--     'WiFi Home',            --
--     106,                    --
--     1,                      --
--     NULL,                   --
--     'Основное подключение'  --
-- );

CREATE OR REPLACE FUNCTION create_email_entry(
    p_email_address character varying,
    p_email_description text,
    p_encrypted_password text,
    p_account_id bigint,
    p_category_id bigint DEFAULT NULL,
    p_user_id bigint DEFAULT NULL
)
    RETURNS bigint AS
$$
DECLARE
    v_email_id bigint;
BEGIN
    INSERT INTO emails (email_address,
                        email_description,
                        encrypted_password,
                        account_id,
                        category_id,
                        user_id)
    VALUES (p_email_address,
            p_email_description,
            p_encrypted_password,
            p_account_id,
            p_category_id,
            p_user_id)
    RETURNING id INTO v_email_id;

    RETURN v_email_id;
END;
$$ LANGUAGE plpgsql;