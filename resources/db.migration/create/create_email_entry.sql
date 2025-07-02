CREATE OR REPLACE FUNCTION public.create_email_entry(
    p_email_address character varying,
    p_email_description text,
    p_encrypted_password text,
    p_account_id bigint,
    p_category_id bigint DEFAULT NULL,
    p_user_id bigint DEFAULT NULL
)
    RETURNS bigint
    LANGUAGE plpgsql
AS
$function$
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

    -- 👉 добавляем связь с users
    IF p_user_id IS NOT NULL THEN
        INSERT INTO user_emails(user_id, email_id)
        VALUES (p_user_id, v_email_id);
    END IF;

    RETURN v_email_id;
END;
$function$;