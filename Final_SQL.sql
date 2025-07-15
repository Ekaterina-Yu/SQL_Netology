-- Испр. 2, 5, 7, 8, 9, 10



--1. Получите количество проектов, подписанных в 2023 году.
--В результат вывести одно значение количества.


SELECT COUNT (*) AS "Количество проектов в 2023 году"
FROM project
WHERE sign_date::date BETWEEN '01.01.2023' AND '31.12.2023'



-- 2. Получите общий возраст сотрудников, нанятых в 2022 году.
-- Результат вывести одним значением в виде "... years ... month ... days"
-- Использование более 2х функций для работы с типом данных дата и время будет являться ошибкой.


SELECT SUM(AGE (current_date, birthdate)) AS "Суммарный возраст"
FROM person p 
LEFT JOIN employee e ON p.person_id = e.person_id 
WHERE hire_date::date BETWEEN '01.01.2022' AND '31.12.2022'

 

-- 3. Получите сотрудников, у которого фамилия начинается на М, всего в фамилии 8 букв и который работает дольше других.
-- Если таких сотрудников несколько, выведите одного случайного.
-- В результат выведите два столбца, в первом должны быть имя и фамилия через пробел, во втором дата найма.


SELECT CONCAT(p.first_name, ' ' , p.last_name) AS "Имя Фамилия", e.hire_date AS "Дата найма"
FROM employee e 
LEFT JOIN person p ON e.person_id = p.person_id 
WHERE p.last_name ILIKE 'М%' AND LENGTH(p.last_name) = 8 AND e.dismissal_date IS NULL
ORDER BY e.hire_date 
LIMIT 1


-- 4. Получите среднее значение полных лет сотрудников, которые уволены и не задействованы на проектах.
-- В результат вывести одно среднее значение. Если получаете null, то в результат нужно вывести 0.

SELECT COALESCE(EXTRACT(YEAR FROM(AVG(AGE(current_date, birthdate)))), 0) AS "Средний возраст"
FROM (
	SELECT project_id, UNNEST(employees_id || project_manager_id) 
	FROM project) pj
RIGHT JOIN employee e ON pj.unnest = e.employee_id 
LEFT JOIN person p ON e.person_id = p.person_id
WHERE pj.unnest IS NULL AND dismissal_date IS NOT NULL
 


-- 5. Чему равна сумма полученных платежей от контрагентов из Жуковский, Россия.
-- В результат вывести одно значение суммы.

SELECT SUM(pp.amount) AS "Платежи из Жуковского, РФ"
FROM project_payment pp 
LEFT JOIN project p ON pp.project_id = p.project_id 
LEFT JOIN customer c ON p.customer_id = c.customer_id 
LEFT JOIN address a ON c.address_id = a.address_id 
LEFT JOIN city c2 ON a.city_id = c2.city_id 
LEFT JOIN country c3 ON c2.country_id = c3.country_id 
WHERE c2.city_name = 'Жуковский' AND c3.country_name = 'Россия' AND fact_transaction_timestamp IS NOT NULL 


-- 6. Пусть руководитель проекта получает премию в 1% от стоимости завершенных проектов.
-- Если взять завершенные проекты, какой руководитель проекта получит самый большой бонус?
-- В результат нужно вывести идентификатор руководителя проекта, его ФИО и размер бонуса.
-- Если таких руководителей несколько, предусмотреть вывод всех.


WITH cte_sum AS (
	SELECT p2.full_fio, project_manager_id, SUM(p.project_cost / 100) AS "total"
	FROM project p 
	LEFT JOIN employee e ON p.project_manager_id = e.employee_id
	LEFT JOIN person p2 ON e.person_id = p2.person_id
	WHERE status = 'Завершен'
	GROUP BY p.project_manager_id, p2.full_fio) 
SELECT cte_sum.full_fio AS "ФИО руководителя", project_manager_id AS "Идентификатор руководителя", MAX(total) AS "Бонус"
FROM cte_sum 
GROUP BY cte_sum.project_manager_id, cte_sum.full_fio
HAVING MAX(total) >= (SELECT MAX(total) FROM cte_sum)
	
	
	
-- 7. Получите накопительный итог планируемых авансовых платежей на каждый месяц в отдельности.
-- Выведите в результат те даты планируемых платежей, которые идут после преодаления накопительной суммой значения в 30 000 000
-- Пример:
-- дата		накопление
-- 2022-06-14	28362946.20
-- 2022-06-20	29633316.30
-- 2022-06-23	34237017.30
-- 2022-06-24	46248120.30
-- В результат должна попасть дата 2022-06-23


SELECT * 
FROM (
	SELECT payment_type AS "Тип платежа", plan_payment_date AS "Плановая дата платежа", 
		SUM(amount) OVER(PARTITION BY date_trunc('month', plan_payment_date) ORDER BY plan_payment_date) AS "Накопление"
	FROM project_payment pp 
	WHERE payment_type = 'Авансовый')
WHERE "Накопление" > 30000000



-- 8. Используя рекурсию посчитайте сумму фактических окладов сотрудников из структурного подразделения с id равным 17 и всех дочерних подразделений.
-- В результат вывести одно значение суммы.


WITH RECURSIVE sal AS (
	SELECT *, 1 as level
	FROM company_structure
	WHERE unit_id = 17
	UNION
	SELECT cs.*, level + 1 as level
	FROM sal
	JOIN company_structure cs on cs.parent_id = sal.unit_id)
SELECT SUM(salary * rate) AS "Сумма"
FROM sal
LEFT JOIN position p ON sal.unit_id = p.unit_id 
LEFT JOIN employee_position ep ON p.position_id = ep.position_id


-- 9. Задание выполняется одним запросом.
--
-- Сделайте сквозную нумерацию фактических платежей по проектам на каждый год в отдельности в порядке даты платежей.
-- Получите платежи, сквозной номер которых кратен 5.
-- Выведите скользящее среднее размеров платежей с шагом 2 строки назад и 2 строки вперед от текущей.
-- Получите сумму скользящих средних значений.
-- Получите сумму стоимости проектов на каждый год.
-- Выведите в результат значение года (годов) и сумму проектов, где сумма проектов меньше, чем сумма скользящих средних значений.

SELECT date_trunc('year', fact_transaction_timestamp) AS "Год", SUM(amount) AS "Сумма"
	FROM(
		SELECT *, AVG(amount) OVER (ORDER BY fact_transaction_timestamp ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING) as "average_value"
		FROM (
			SELECT *, ROW_NUMBER() OVER (ORDER BY fact_transaction_timestamp) AS number
				FROM project_payment pp
				WHERE fact_transaction_timestamp IS NOT NULL)
		WHERE number % 5 = 0)
GROUP BY date_trunc('year', fact_transaction_timestamp)
HAVING SUM(amount) < SUM(average_value)


-- 10. Создайте материализованное представление, которое будет хранить отчет следующей структуры:
-- идентификатор проекта
-- название проекта
-- дата последней фактической оплаты по проекту
-- размер последней фактической оплаты
-- ФИО руководителей проектов
-- Названия контрагентов
-- В виде строки названия типов работ по каждому контрагенту


CREATE MATERIALIZED VIEW Last_payment_report AS
SELECT p.project_id AS "Идентификатор проекта", project_name AS "Название проекта", fact_transaction_timestamp AS "Дата последней оплаты", amount AS "Сумма последней оплаты",  
	full_fio AS "ФИО руководителя", customer_name AS "Название контрагента", STRING_AGG(DISTINCT tow.type_of_work_name, ', ') AS "Типы работ"
FROM (
	SELECT project_id, fact_transaction_timestamp, amount
	FROM project_payment pp
	WHERE fact_transaction_timestamp = (SELECT MAX(fact_transaction_timestamp)
    	FROM project_payment pp2
    	WHERE pp.project_id = pp2.project_id
     		AND fact_transaction_timestamp IS NOT NULL)) pp3
LEFT JOIN project p ON pp3.project_id = p.project_id 
LEFT JOIN employee e ON p.project_manager_id = e.employee_id 
LEFT JOIN person p2 ON e.person_id = p2.person_id 
LEFT JOIN customer c ON p.customer_id = c.customer_id 
LEFT JOIN customer_type_of_work ctow ON c.customer_id = ctow.customer_id 
LEFT JOIN type_of_work tow ON ctow.type_of_work_id = tow.type_of_work_id
GROUP BY p.project_id, pp3.fact_transaction_timestamp, pp3.amount, p2.full_fio, c.customer_name
