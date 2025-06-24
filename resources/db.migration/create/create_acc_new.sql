SELECT public.create_account_with_user_nickname_and_email(
               'Alice100',
               'alice@mail.ru',
               'UvrQ+SywNvGoaHXQMjcQkEq+guS4G7QUzYqmUA==',
               'gj4TXUZUbCJ/psarc7+WRoeY/WvToTEfkGIX/FkMeJE=',
               'alice',
               '123-456-789',
               'Это аккаунт Алисы'
       );

-- curl -X POST http://192.168.0.245:8080/register \
-- -H "Content-Type: application/json" \
-- -d '{
--     "account_login": "Alice123",
--     "email_address": "alice@example.com",
--     "password": "encrypted_password_here",
--     "secret_phrase": "секретная фраза Алисы",
--     "user_name": "Alice",
--     "user_phone": "1234567890",
--     "user_description": "Обычный пользователь"
--   }'