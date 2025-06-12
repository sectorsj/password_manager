-- create_account.sql

-- Пример вызова функции создания аккаунта с пользователем и email
SELECT * FROM create_account_with_user_and_email(
        'alice_login',
        'alice@example.com',
        E'\\x313030',       -- '100' в строке → hex = 31 30 30
        E'\\x73616c74',             -- 'salt' в hex
        'Alice',
        '+89001234567',
        'Первый user созданный через psql'
);