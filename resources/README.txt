Documentation:

Страницы (Pages):
SplashPanel это экран который должен быть по умолчанию,
    - RegistrationPage ()
    - LoginPage ()

    Процедура создания нового аккаунта:
    1. Открыт "ГлавныйЭкран" приложения
    2. На "ГлавныйЭкране" есть "НавигационноеМеню", и "ЭкранЗаставки"
    3. В "НавигационноеМеню" есть пункты:
       1. "Аккаунт":
          1. В пункте "Аккаунт" есть кнопка "Вход".
             1. При нажатии на кнопку "Вход" открывается "формаАвторизации"
                1. Поле "Логин" (уже указан логин, если перед авторизацией была регистрация)
                2. Поле "Пароль" (пустое в любом случае)
                3. Кнопка "Войти"
                   1. Если:
                      1. Заполнить все поля и нажать на кнопку "Войти", то:
                         1. Выполняется запрос в бд на наличие указанного "аккаунта", происходит проверка полей:
                             1. Поле Логин
                             2. Поле Почта
                             3. Поле Пароль (процесс дешифровки хэшированного пароля)
                         2. "ФормаАвторизации" закрывается
                         3. открывается ГлавныйЭкран с 3-я вкладками:
                            1. вкладка Вебсайты (по умолчанию)
                            2. вкладка Почты
                               1. Должна отобразиться запись о почте, указанной при регистрации
                            3. вкладке "ИнтернетПодключения"
                      2. Не заполнить поле "Логин" и нажать на кнопку "Войти", то:
                         1. Выводится уведомление:
                            1. "Укажите, пожалуйста, Логин"
                         2. "ФормаАвторизации" остается открытой
                      3. Не заполнить поле "Пароль" и нажать на кнопку "Войти", то:
                         1. Выводится уведомление:
                            1. "Укажите, пожалуйста, пароль"
                         2. "ФормаАвторизации" остается открытой
                4. Кнопка "Зарегистрироваться" (присутствует, если перед авторизацией не было регистрации)
                   1. При нажатии на кнопку "Зарегистрироваться":
                      1. Открывается "формаРегистрации" (в ней 4 поля и 1 кнопка):
                         1. Поле "Логин"
                         2. Поле "Почта"
                         3. Поле "Пароль"
                         4. Поле "Подтверждение пароля"
                         5. Кнопка "Зарегистрироваться"
                            1. Если:
                               1. Заполнить все поля и нажать на кнопку "Зарегистрироваться", то:
                                  1. Выполняется запуск процедуры "регистрации нового пользователя"
                                     1. Данные о пользователе заносится в базу данных
                                     2. Выводится уведомление:
                                        1. "Регистрации пользователя прошла успешно!"
                                  2. Выполняется завершение процедуры "регистрации нового пользователя"
                                     1. "ФормаРегистрации" закрывается
                                     2. Открывается "формаАвторизации"
                               2. Не заполнить ни одно поле и нажать на кнопку "Зарегистрироваться", то:
                                  1. Выводится уведомление:
                                     1. "Поля не заполнены, заполните пустые поля"
                                  2. "ФормаРегистрации" остается открытой
                               3. Заполнить поля частично и нажать на кнопку "Зарегистрироваться", то:
                                  1. Выводится уведомление с указанием какое поле не было заполнено:
                                     1. "Заполните, пожалуйста, поля: ..."
                                  2. "ФормаРегистрации" остается открытой
                               4. Заполнить все поля кроме "Логин" и нажать на кнопку "Зарегистрироваться", то:
                                  1. Выводится уведомление:
                                     1. "Укажите, пожалуйста, Ваш логин"
                                  2. "ФормаРегистрации" остается открытой
                               5. Заполнить все поля кроме "Почта" и нажать на кнопку "Зарегистрироваться", то:
                                  1. Выводится уведомление:
                                     1. "Укажите, пожалуйста, Вашу почту"
                                  2. "ФормаРегистрации" остается открытой
                               6. Заполнить все поля кроме "Пароль" и нажать на кнопку "Зарегистрироваться", то:
                                  1. Выводится уведомление:
                                     1. "Укажите, пожалуйста, пароль"
                                  2. "ФормаРегистрации" остается открытой


    - CategoriesPage ()

    - WebsitesPage (сайты) таблица с 7 колонками:
      1. порядковый номер записи таблицы
      2. название сайта
      3. url адрес сайта
      4. имя пользователя, которым пользователь зарегистрировался на этом сайте
      5. почта пользователя
      6. пароль (отображается в виде 4х звездочек)
       	   в этой же колонке должно быть две иконки:
      	1. Глаз - чтобы отобразить пароль
      	2. Два Квадратика - обозначающие возможно скопировать пароль
      7. описание сайта
      8. соль пароля (не отображается в таблице)
      9. категория пользователя (не отображается в таблице)

    Процедура создания нового сайта:



    - EmailsPage (почты) таблица с 4-я колонками:
      	1. порядковый номер записи таблицы
      	2. адрес электронной почты
      	3. пароль (отображается в виде 4х звездочек)
      	   в этой же колонке должно быть две иконки:
      		1. Глаз - чтобы отобразить пароль
      		2. Два Квадратика - обозначающие возможно скопировать пароль
      	4. описание почты
      	5. соль пароля (не отображается в таблице)
      	6. категория пользователя (не отображается в таблице)

        Процедура создания новой почты:
        1. После успешной авторизации:
           1. Открывается диалоговое окно, с вопросом:
              1. Текст: "Установить указанную почту для работы по умолчанию?"
              2. Поле выбора "Почты" (где указана ранее созданная при регистрации почта)
                 1. Идет запрос в бд на поиск записи о почте в созданном аккаунте
                    1. Если:
                       1. Запись найдена:
                          1. Отобразить в поле выбора данные о почте
                       2. Запись не найдена:
                          1. ничего не отображать
              3. Кнопка "Да, использовать почту по умолчанию"
                 1. Запуск процедуры "добавленияРанееСозданнойПочты"
                    1. Открывается "формаСозданияИРедактированияПочты" с полями:
                       1. Поле АдресПочты (Заполнено записью из accounts.email)
                       2. Поле Пароль (Пустое)
                       3. Поле Подтвердить пароль (Пустое)
                       4. Поле ОписаниеПочты (Пустое)
                       5. Поле Пользователь (User_id) (Заполнено)
                          1. Кнопка "Тест" (отвечает за проверку, существует ли такой пользователь в бд)
                       6. Поле Аккаунт (Account_id) (Заполнено)
                          1. Кнопка "Тест" (отвечает за проверку, существует ли такой аккаунт в бд)
                       7. Кнопка "Подтвердить"
                    2. Закрывается "формаСозданияИРедактированияПочты"
                    3. Выполняется запись в бд измененной информации о почте
                 2. Завершение процедуры "добавленияРанееСозданнойПочты"
              4. Кнопка "Нет, создать новую почту"
                 1. Запуск процедуры "созданиеНовойПочты"
                    1. Открывается "формаСозданияИРедактированияПочты" с полями:
                       1. Поле АдресПочты (Пустое)
                       2. Поле Пароль (Пустое)
                       3. Поле Подтвердить пароль (Пустое)
                       4. Поле ОписаниеПочты (Пустое)
                       5. Поле Пользователь (User_id) (пустое)
                          5.1 Кнопка "Тест" (отвечает за проверку, существует ли такой пользователь в бд)
                       6. Поле Аккаунт (Account_id) (пустое)
                          6.1 Кнопка "Тест" (отвечает за проверку, существует ли такой аккаунт в бд)
                       7. Кнопка "Подтвердить"
                    2. Закрывается "формаСозданияИРедактированияПочты"
                    3. Выполняется запись в бд измененной информации о почте
                 2. Завершение процедуры "добавленияРанееСозданнойПочты"


    - NetworkConnectionsPage (сетевымиПодключения) таблица с х колонками:
      	1. порядковый номер записи таблицы
      	2. название соединения
      	3. ipv4 адрес
      	4. ipv6 адрес
      	5. имя пользователя для подключения к данной сети
      	6. пароль (отображается в виде 4х звездочек)
         	   в этой же колонке должно быть две иконки:
      		1. Глаз - чтобы отобразить пароль
      		2. Два Квадратика - обозначающие возможно скопировать пароль
      	7. описание подключения
      	8. соль пароля (не отображается в таблице)
      	9. категория пользователя (не отображается в таблице)


    - SettingsPage (настройки):
        1.

Это вкладки одноименных экранов. Они должны активироваться после успешной авторизации,
т.к. там будет привязка к таблице бд, с указанием нужного пользователя

Слой моделей (Model Layer):
    - Содержит классы, представляющие объекты предметной области (сущности).
    - Определяет структуру данных и связи между объектами.
    - Например, классы User, Website, Email, NetworkConnection и т.д.


итак с учетом всего вышесказанного, напиши полный код классов:
- email_form_page.dart
- website.dart
- auth_service.dart
- validators.dart
- server.dart
- database_connection.dart
- auth_routes.dart
- email_routes.dart
- network_connection_routes.dart
- websites_routes.dart
- session.dart



А может стоит:
accountId - подтянуть из текущего аккаунта после авторизации,
таким образом после авторизации нужно:
начинать две процедуры:
1. установить почту по умолчанию
2. установить пользователя по умолчанию

тоесть после регистрации в таблицах должны появиться записи:
- emails:
    1. id - автоинкремент
    2. email_address - accounts.email
    3. email_description - null
    4. password_hash - null
    5. salt - null
    6. account_id - accounts.id
    7. category_id - null
    8. user_id - accounts.account_login
- users:
    1. id - автоинкремент
    2. user_name - accounts.account_login
    3. phone - null
    4. user_description - null
    5. account_id - accounts.id
    6. email_id - emails.id


Пример использования метода (create_account_with_user_and_email):
SELECT * FROM create_account_with_user_and_email(
    'mylogin',
    'user@example.com',
    decode('cGFzc3dvcmQ=', 'base64'),  -- password_hash (base64)
    decode('c2FsdDEyMw==', 'base64'),  -- salt (base64)
    'Имя пользователя',
    '+79991234567',
    'Описание'
);