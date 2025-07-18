INSERT INTO messages (message_type, title, content, format)
VALUES ('welcome',
        'Добро пожаловать в PassKeeper!',
        $html$
             <h2 style="margin-top:0">👋 Добро пожаловать в PassKeeper</h2>

             <p>Вы используете <strong>альфа-версию</strong> нашего приложения. Спасибо за участие в тестировании!</p>

             <hr>

             <h3>🔐 Безопасность</h3>
             <ul>
               <li>Все пароли шифруются на сервере</li>
               <li>Уникальный AES-ключ на каждого пользователя</li>
               <li>Авторизация через JWT токены</li>
             </ul>

             <h3>🎯 Что реализовано</h3>
             <ul>
               <li>Регистрация, логин, никнейм, email</li>
               <li>Добавление сайтов, email-аккаунтов и сетевых подключений</li>
               <li>Автоматическая расшифровка</li>
             </ul>

             <div style="text-align:center; margin: 20px 0;">
               <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/7/72/Password_icon.svg/240px-Password_icon.svg.png" width="120" alt="Secure Image" />
             </div>

             <p>Если что-то не работает — <a href="https://t.me/inIT_team" target="_blank">напишите в Telegram команде “InIT”</a></p>
           $html$,
        'html');