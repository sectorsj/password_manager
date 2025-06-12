-- =====================================================
-- ПОЛНЫЙ АНАЛИЗ БАЗЫ ДАННЫХ
-- =====================================================

-- 1. ВСЕ ТАБЛИЦЫ СПИСКОМ
-- =====================================================
SELECT 'СПИСОК ВСЕХ ТАБЛИЦ' as info_type,
       ''                   as details,
       ''                   as extra_info
UNION ALL
SELECT '────────────────────────────────────────' as info_type,
       ''                                         as details,
       ''                                         as extra_info
UNION ALL
SELECT schemaname as info_type,
       tablename  as details,
       tableowner as extra_info
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY info_type, details;

-- 2. СТРУКТУРА КАЖДОЙ ТАБЛИЦЫ
-- =====================================================
DO
$$
    DECLARE
        table_rec RECORD;
        col_rec   RECORD;
    BEGIN
        -- Заголовок секции
        RAISE NOTICE '';
        RAISE NOTICE 'СТРУКТУРА ТАБЛИЦ';
        RAISE NOTICE '=====================================================';

        FOR table_rec IN
            SELECT tablename
            FROM pg_tables
            WHERE schemaname = 'public'
            ORDER BY tablename
            LOOP
                RAISE NOTICE '';
                RAISE NOTICE 'ТАБЛИЦА: %', table_rec.tablename;
                RAISE NOTICE '────────────────────────────────────────';

                -- Выводим структуру таблицы
                FOR col_rec IN
                    SELECT column_name,
                           data_type,
                           is_nullable,
                           column_default,
                           character_maximum_length
                    FROM information_schema.columns
                    WHERE table_name = table_rec.tablename
                      AND table_schema = 'public'
                    ORDER BY ordinal_position
                    LOOP
                        RAISE NOTICE '  % | % | % | Default: % | Max Length: %',
                            col_rec.column_name,
                            col_rec.data_type,
                            CASE WHEN col_rec.is_nullable = 'YES' THEN 'NULL' ELSE 'NOT NULL' END,
                            COALESCE(col_rec.column_default, 'нет'),
                            COALESCE(col_rec.character_maximum_length::text, 'нет');
                    END LOOP;
            END LOOP;
    END
$$;

-- 3. ДАННЫЕ ИЗ КАЖДОЙ ТАБЛИЦЫ (первые 100 записей)
-- =====================================================

-- accounts
SELECT 'ДАННЫЕ ТАБЛИЦЫ: accounts' as table_info, '────────────────────────────────────────' as separator
UNION ALL
SELECT 'Первые 100 записей:', ''
UNION ALL
SELECT '────────────────────────────────────────', '';

SELECT *
FROM accounts
LIMIT 100;

-- categories
SELECT 'ДАННЫЕ ТАБЛИЦЫ: categories' as table_info, '────────────────────────────────────────' as separator
UNION ALL
SELECT 'Первые 100 записей:', ''
UNION ALL
SELECT '────────────────────────────────────────', '';

SELECT *
FROM categories
LIMIT 100;

-- emails
SELECT 'ДАННЫЕ ТАБЛИЦЫ: emails' as table_info, '────────────────────────────────────────' as separator
UNION ALL
SELECT 'Первые 100 записей:', ''
UNION ALL
SELECT '────────────────────────────────────────', '';

SELECT *
FROM emails
LIMIT 100;

-- event_publication
SELECT 'ДАННЫЕ ТАБЛИЦЫ: event_publication' as table_info, '────────────────────────────────────────' as separator
UNION ALL
SELECT 'Первые 100 записей:', ''
UNION ALL
SELECT '────────────────────────────────────────', '';

SELECT *
FROM event_publication
LIMIT 100;

-- flyway_schema_history
SELECT 'ДАННЫЕ ТАБЛИЦЫ: flyway_schema_history' as table_info, '────────────────────────────────────────' as separator
UNION ALL
SELECT 'Первые 100 записей:', ''
UNION ALL
SELECT '────────────────────────────────────────', '';

SELECT *
FROM flyway_schema_history
LIMIT 100;

-- network_connections
SELECT 'ДАННЫЕ ТАБЛИЦЫ: network_connections' as table_info, '────────────────────────────────────────' as separator
UNION ALL
SELECT 'Первые 100 записей:', ''
UNION ALL
SELECT '────────────────────────────────────────', '';

SELECT *
FROM network_connections
LIMIT 100;

-- nicknames
SELECT 'ДАННЫЕ ТАБЛИЦЫ: nicknames' as table_info, '────────────────────────────────────────' as separator
UNION ALL
SELECT 'Первые 100 записей:', ''
UNION ALL
SELECT '────────────────────────────────────────', '';

SELECT *
FROM nicknames
LIMIT 100;

-- user_emails
SELECT 'ДАННЫЕ ТАБЛИЦЫ: user_emails' as table_info, '────────────────────────────────────────' as separator
UNION ALL
SELECT 'Первые 100 записей:', ''
UNION ALL
SELECT '────────────────────────────────────────', '';

SELECT *
FROM user_emails
LIMIT 100;

-- user_nicknames
SELECT 'ДАННЫЕ ТАБЛИЦЫ: user_nicknames' as table_info, '────────────────────────────────────────' as separator
UNION ALL
SELECT 'Первые 100 записей:', ''
UNION ALL
SELECT '────────────────────────────────────────', '';

SELECT *
FROM user_nicknames
LIMIT 100;

-- users
SELECT 'ДАННЫЕ ТАБЛИЦЫ: users' as table_info, '────────────────────────────────────────' as separator
UNION ALL
SELECT 'Первые 100 записей:', ''
UNION ALL
SELECT '────────────────────────────────────────', '';

SELECT *
FROM users
LIMIT 100;

-- websites
SELECT 'ДАННЫЕ ТАБЛИЦЫ: websites' as table_info, '────────────────────────────────────────' as separator
UNION ALL
SELECT 'Первые 100 записей:', ''
UNION ALL
SELECT '────────────────────────────────────────', '';

SELECT *
FROM websites
LIMIT 100;

-- 4. ВСЕ ИНДЕКСЫ
-- =====================================================
SELECT 'ВСЕ ИНДЕКСЫ' as index_info, '────────────────────────────────────────' as separator, '' as details
UNION ALL
SELECT schemaname as index_info,
       indexname  as separator,
       tablename  as details
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY index_info, separator;

-- 5. ВСЕ ФУНКЦИИ СПИСКОМ
-- =====================================================
SELECT 'ВСЕ ФУНКЦИИ' as function_info, '────────────────────────────────────────' as separator, '' as details
UNION ALL
SELECT n.nspname                     as function_info,
       p.proname                     as separator,
       pg_get_function_result(p.oid) as details
FROM pg_proc p
         JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
  AND p.prokind = 'f'
ORDER BY function_info, separator;

-- 6. КОД ВСЕХ ФУНКЦИЙ
-- =====================================================
DO
$$
    DECLARE
        func_rec RECORD;
    BEGIN
        RAISE NOTICE '';
        RAISE NOTICE 'КОД ФУНКЦИЙ';
        RAISE NOTICE '=====================================================';

        FOR func_rec IN
            SELECT p.proname,
                   pg_get_functiondef(p.oid) as function_definition
            FROM pg_proc p
                     JOIN pg_namespace n ON p.pronamespace = n.oid
            WHERE n.nspname = 'public'
              AND p.prokind = 'f'
            ORDER BY p.proname
            LOOP
                RAISE NOTICE '';
                RAISE NOTICE 'ФУНКЦИЯ: %', func_rec.proname;
                RAISE NOTICE '────────────────────────────────────────';
                RAISE NOTICE '%', func_rec.function_definition;
            END LOOP;
    END
$$;