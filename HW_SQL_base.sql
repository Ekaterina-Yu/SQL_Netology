--=============== МОДУЛЬ 3. ОСНОВЫ SQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите для каждого покупателя его адрес проживания, 
--город и страну проживания.

SELECT CONCAT(last_name, ' ', first_name) AS  "Полное имя покупателя", country AS "Страна", city AS "Город"
FROM customer c 
LEFT JOIN address a ON c.address_id = a.address_id 
LEFT JOIN city ON a.city_id = city.city_id 
LEFT JOIN country ON city.country_id = country.country_id 

--ЗАДАНИЕ №2
--С помощью SQL-запроса посчитайте для каждого магазина количество его покупателей.

SELECT store_id AS "ID магазина", COUNT(customer_id) AS "Количество покупателей"
FROM customer
GROUP BY store_id 


--Доработайте запрос и выведите только те магазины, 
--у которых количество покупателей больше 300-от.
--Для решения используйте фильтрацию по сгруппированным строкам 
--с использованием функции агрегации.

SELECT store_id AS "ID магазина", COUNT(customer_id) AS "Количество покупателей"
FROM customer
GROUP BY store_id 
HAVING COUNT(customer_id) > 300




-- Доработайте запрос, добавив в него информацию о городе магазина, 
--а также фамилию и имя продавца, который работает в этом магазине.

SELECT c.store_id AS "ID магазина", COUNT(customer_id) AS "Количество покупателей", CONCAT(s2.last_name, ' ', s2.first_name) AS "Фамилия и имя продавца", c2.city AS "Город"
FROM customer c
LEFT JOIN store s ON c.store_id = s.store_id 
LEFT JOIN address a ON s.address_id = a.address_id 
LEFT JOIN city c2 ON a.city_id = c2.city_id 
LEFT JOIN staff s2 ON s.manager_staff_id = s2.staff_id 
GROUP BY c.store_id, manager_staff_id, s2.last_name, s2.first_name, c2.city
HAVING COUNT(customer_id) > 300



--ЗАДАНИЕ №3
--Выведите ТОП-5 покупателей, 
--которые взяли в аренду за всё время наибольшее количество фильмов

SELECT CONCAT(last_name, ' ', first_name) AS "Полное имя покупателя", COUNT(r.rental_id) AS "Количество фильмов"
FROM customer c 
LEFT JOIN rental r ON c.customer_id = r.customer_id 
GROUP BY c.customer_id 
ORDER BY COUNT(r.rental_id) DESC
LIMIT 5



--ЗАДАНИЕ №4
--Посчитайте для каждого покупателя 4 аналитических показателя:
--  1. количество фильмов, которые он взял в аренду
--  2. общую стоимость платежей за аренду всех фильмов (значение округлите до целого числа)
--  3. минимальное значение платежа за аренду фильма
--  4. максимальное значение платежа за аренду фильма

SELECT CONCAT(last_name, ' ', first_name) AS "Полное имя покупателя", COUNT(p.rental_id) AS "Количество фильмов", 
	ROUND(SUM(p.amount)) AS "Сумма платежей", MIN(p.amount) AS "Минимальный платёж", MAX(p.amount) AS "Максимальный платёж"
FROM customer c 
LEFT JOIN payment p ON c.customer_id = p.customer_id 
GROUP BY c.customer_id


--ЗАДАНИЕ №5
--Используя данные из таблицы городов, составьте все возможные пары городов так, чтобы 
--в результате не было пар с одинаковыми названиями городов. Решение должно быть через Декартово произведение.
 
SELECT c.city AS "Город 1", c2.city AS "Город 2"
FROM city c 
CROSS JOIN city c2 
WHERE c.city != c2.city

--ЗАДАНИЕ №6
--Используя данные из таблицы rental о дате выдачи фильма в аренду (поле rental_date) и 
--дате возврата (поле return_date), вычислите для каждого покупателя среднее количество 
--дней, за которые он возвращает фильмы. В результате должны быть дробные значения, а не интервал.
 
SELECT customer_id AS "ID покупателя", ROUND(AVG(return_date::date - rental_date::date), 2)
FROM rental r 
GROUP BY customer_id
ORDER BY customer_id 




--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Посчитайте для каждого фильма сколько раз его брали в аренду и значение общей стоимости аренды фильма за всё время.




--ЗАДАНИЕ №2
--Доработайте запрос из предыдущего задания и выведите с помощью него фильмы, которые отсутствуют на dvd дисках.





--ЗАДАНИЕ №3
--Посчитайте количество продаж, выполненных каждым продавцом. Добавьте вычисляемую колонку "Премия".
--Если количество продаж превышает 7300, то значение в колонке будет "Да", иначе должно быть значение "Нет".







