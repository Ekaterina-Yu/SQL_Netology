--=============== МОДУЛЬ 5. РАБОТА С POSTGRESQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Сделайте запрос к таблице payment и с помощью оконных функций добавьте вычисляемые колонки согласно условиям:

--Пронумеруйте все платежи от 1 до N по дате платежа 1.1

SELECT CONCAT(first_name, ' ',last_name) AS "Полное имя покупателя", p.payment_date::date AS "Дата платежа", p.amount AS "Сумма текущ. платежа", 
	ROW_NUMBER() OVER (ORDER BY p.payment_date) AS "Нум. всех платежей по дате платежа"
FROM payment p
JOIN customer c ON p.customer_id  = c.customer_id


--Пронумеруйте платежи для каждого покупателя, сортировка платежей должна быть по дате платежа 1.2

SELECT CONCAT(first_name, ' ',last_name) AS "Полное имя покупателя", p.payment_date::date AS "Дата платежа", p.amount AS "Сумма текущ. платежа", 
	ROW_NUMBER() OVER (PARTITION BY c.customer_id ORDER BY p.payment_date) AS "Нум. платежей для покупателя"
FROM payment p
JOIN customer c ON p.customer_id  = c.customer_id 


--Посчитайте нарастающим итогом сумму всех платежей для каждого покупателя, сортировка должна 
--быть сперва по дате платежа, а затем по размеру платежа от наименьшей к большей 1.3

SELECT CONCAT(first_name, ' ',last_name) AS "Полное имя покупателя", p.payment_date::date AS "Дата платежа", p.amount AS "Сумма текущ. платежа", 
	SUM(amount) OVER(PARTITION BY p.customer_id ORDER BY p.payment_date, p.amount) AS "Сумма платажей на дату"
FROM payment p
JOIN customer c ON p.customer_id  = c.customer_id


--Пронумеруйте платежи для каждого покупателя по размеру платежа от наибольшего к
--меньшему так, чтобы платежи с одинаковым значением имели одинаковое значение номера. 1.4

SELECT CONCAT(first_name, ' ',last_name) AS "Полное имя покупателя", p.payment_date::date AS "Дата платежа", p.amount AS "Сумма текущ. платежа", 
	DENSE_RANK() OVER (PARTITION BY c.customer_id ORDER BY p.amount DESC) AS "Нум. платежей для покупателя"
FROM payment p
JOIN customer c ON p.customer_id  = c.customer_id 


--Можно составить на каждый пункт отдельный SQL-запрос, а можно объединить все колонки в одном запросе.


--ЗАДАНИЕ №2
--С помощью оконной функции выведите для каждого покупателя стоимость платежа и стоимость 
--платежа из предыдущей строки со значением по умолчанию 0.0 с сортировкой по дате платежа.

SELECT CONCAT(first_name, ' ',last_name) AS "Полное имя покупателя", p.payment_date::date AS "Дата платежа", p.amount AS "Сумма текущ. платежа",
	LAG(amount, 1, 0.0) OVER (PARTITION BY p.customer_id ORDER BY p.payment_date) AS "Сумма пред. платежа"
FROM payment p
JOIN customer c ON p.customer_id  = c.customer_id


--ЗАДАНИЕ №3
--С помощью оконной функции определите, на сколько каждый следующий платеж покупателя больше или меньше текущего.

SELECT CONCAT(first_name, ' ',last_name) AS "Полное имя покупателя", p.payment_date::date AS "Дата платежа", p.amount AS "Сумма текущ. платежа",
	LEAD(amount, 1, 0.0) OVER (PARTITION BY p.customer_id ORDER BY p.payment_date) AS "Сумма след. платежа", 
	LEAD(amount, 1, 0.0) OVER (PARTITION BY p.customer_id ORDER BY p.payment_date) - p.amount AS "Разница текущ. и след. платежа" 
FROM payment p
JOIN customer c ON p.customer_id  = c.customer_id


--ЗАДАНИЕ №4
--С помощью оконной функции для каждого покупателя выведите данные о его последней оплате аренды.

SELECT payment_id AS "Идентификатор посл. платежа", CONCAT(first_name, ' ',last_name) AS "Полное имя покупателя", p.payment_date::date AS "Дата платежа", p.amount AS "Сумма платежа"
FROM (
	SELECT *, FIRST_VALUE(payment_id) OVER (PARTITION BY customer_id ORDER BY payment_date DESC)
	FROM payment) p
JOIN customer c ON p.customer_id = c.customer_id 
WHERE payment_id = FIRST_VALUE 
 


--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--С помощью оконной функции выведите для каждого сотрудника сумму продаж за август 2005 года 
--с нарастающим итогом по каждому сотруднику и по каждой дате продажи (без учёта времени) 
--с сортировкой по дате.




--ЗАДАНИЕ №2
--20 августа 2005 года в магазинах проходила акция: покупатель каждого сотого платежа получал
--дополнительную скидку на следующую аренду. С помощью оконной функции выведите всех покупателей,
--которые в день проведения акции получили скидку




--ЗАДАНИЕ №3
--Для каждой страны определите и выведите одним SQL-запросом покупателей, которые попадают под условия:
-- 1. покупатель, арендовавший наибольшее количество фильмов
-- 2. покупатель, арендовавший фильмов на самую большую сумму
-- 3. покупатель, который последним арендовал фильм

