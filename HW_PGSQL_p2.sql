--=============== МОДУЛЬ 6. POSTGRESQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Напишите SQL-запрос, который выводит всю информацию о фильмах 
--со специальным атрибутом "Behind the Scenes".

-- EXPLAIN ANALYZE -- Seq Scan on film f  (cost=0.00..67.50 rows=538 width=78) (actual time=0.014..0.396 rows=538 loops=1)
SELECT film_id, title, special_features 
FROM film f 
WHERE special_features @> ARRAY['Behind the Scenes']


--ЗАДАНИЕ №2
--Напишите еще 2 варианта поиска фильмов с атрибутом "Behind the Scenes",
--используя другие функции или операторы языка SQL для поиска значения в массиве.

-- EXPLAIN ANALYZE --Seq Scan on film f  (cost=0.00..67.50 rows=538 width=78) (actual time=0.011..0.328 rows=538 loops=1)
SELECT film_id, title, special_features 
FROM film f
WHERE 'Behind the Scenes' = ANY(special_features)


-- EXPLAIN ANALYZE -- Seq Scan on film f  (cost=0.00..67.50 rows=538 width=78) (actual time=0.011..0.385 rows=538 loops=1)
SELECT film_id, title, special_features 
FROM film f 
WHERE special_features && ARRAY['Behind the Scenes']

--ЗАДАНИЕ №3
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов 
--со специальным атрибутом "Behind the Scenes.
--Обязательное условие для выполнения задания: используйте запрос из задания 1, 
--помещенный в CTE. CTE необходимо использовать для решения задания.


-- EXPLAIN ANALYZE -- Sort  (cost=719.27..720.77 rows=599 width=44) (actual time=7.864..7.884 rows=600 loops=1)
WITH cte_btscenes AS (
	SELECT film_id, title, special_features 
	FROM film
	WHERE special_features @> ARRAY['Behind the Scenes'])
SELECT CONCAT(last_name, ' ', first_name) AS  "Полное имя покупателя", COUNT(i.film_id) AS "Количество фильмов" 
FROM cte_btscenes cb
LEFT JOIN inventory i ON cb.film_id = i.film_id 
LEFT JOIN rental r ON i.inventory_id = r.inventory_id
LEFT JOIN customer c ON r.customer_id = c.customer_id 
GROUP BY c.customer_id
ORDER BY c.customer_id	



--ЗАДАНИЕ №4
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов
-- со специальным атрибутом "Behind the Scenes".

--Обязательное условие для выполнения задания: используйте запрос из задания 1,
--помещенный в подзапрос, который необходимо использовать для решения задания.

-- EXPLAIN ANALYZE -- Sort  (cost=719.27..720.77 rows=599 width=44) (actual time=7.797..7.816 rows=600 loops=1)
SELECT CONCAT(last_name, ' ', first_name) AS  "Полное имя покупателя", COUNT(i.film_id) AS "Количество фильмов" 
FROM (
	SELECT film_id, title, special_features 
	FROM film 
	WHERE special_features @> ARRAY['Behind the Scenes']) b
LEFT JOIN inventory i ON b.film_id = i.film_id 
LEFT JOIN rental r ON i.inventory_id = r.inventory_id
LEFT JOIN customer c ON r.customer_id = c.customer_id 
GROUP BY c.customer_id
ORDER BY c.customer_id



--ЗАДАНИЕ №5
--Создайте материализованное представление с запросом из предыдущего задания
--и напишите запрос для обновления материализованного представления


CREATE MATERIALIZED VIEW film_counter_with_btscenes AS
	SELECT CONCAT(last_name, ' ', first_name) AS  "Полное имя покупателя", COUNT(i.film_id) AS "Количество фильмов" 
	FROM (
		SELECT film_id, title, special_features 
		FROM film 
		WHERE special_features @> ARRAY['Behind the Scenes']) b
	LEFT JOIN inventory i ON b.film_id = i.film_id 
	LEFT JOIN rental r ON i.inventory_id = r.inventory_id
	LEFT JOIN customer c ON r.customer_id = c.customer_id 
	GROUP BY c.customer_id
	ORDER BY c.customer_id

REFRESH MATERIALIZED VIEW film_counter_with_btscenes

--ЗАДАНИЕ №6
--С помощью explain analyze проведите анализ стоимости выполнения запросов из предыдущих заданий и ответьте на вопросы:
--1. с каким оператором или функцией языка SQL, используемыми при выполнении домашнего задания: 
--поиск значения в массиве затрачивает меньше ресурсов системы;


-- Оператор ANY (SOME)


--2. какой вариант вычислений затрачивает меньше ресурсов системы: 
--с использованием CTE или с использованием подзапроса.


-- Если CTE не переиспользуется в рамках запроса, то одинаково

	



--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выполняйте это задание в форме ответа на сайте Нетологии

--ЗАДАНИЕ №2
--Используя оконную функцию выведите для каждого сотрудника
--сведения о самой первой продаже этого сотрудника.





--ЗАДАНИЕ №3
--Для каждого магазина определите и выведите одним SQL-запросом следующие аналитические показатели:
-- 1. день, в который арендовали больше всего фильмов (день в формате год-месяц-день)
-- 2. количество фильмов взятых в аренду в этот день
-- 3. день, в который продали фильмов на наименьшую сумму (день в формате год-месяц-день)
-- 4. сумму продажи в этот день
