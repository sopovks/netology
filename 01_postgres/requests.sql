-- 1. общее количество проданных полисов по годам
select date_part('year', sale_date), count(*)  from policies group by date_part('year', sale_date);

-- 2. общее количество проданных полисов по городам
select city, count(*)  from policies t1 join sale_points t2 on t1.sale_point_id=t2.id
	group by city order by 2 desc;

-- 3. общие сборы агентов
select full_name, sum(premium) from policies t1 join agents t2 on t1.agent_id=t2.id
	group by full_name order by 2 desc;
	
-- 4. агент формально привязан к точке продаж (т.е. городу) но может осуществлять продажи и в других городах
-- выведем список: агент, его родной город, кол-во продаж в родном городе, кол-во продаж в других городах
select full_name, city as "own city",
	(select count(premium) from policies t2 where t2.agent_id=t1.id and t2.sale_point_id=t1.sale_point_id) as " in own city",
	(select count(premium) from policies t2 where t2.agent_id=t1.id and t2.sale_point_id<>t1.sale_point_id) as "in other cities"
from agents t1 join sale_points t2 on t1.sale_point_id=t2.id
	
-- 5. средняя стоимость полисов по категориям
select category, avg(premium)  from policies t1 join products t2 on t1.product_id=t2.id
	group by category order by 2 desc;

-- 6. для каждого города посмотрим максимальную премию по категориям продуктов, исключая property
select
	city, category, max(premium)
from
	policies t1 join products t2 on product_id=t2.id join sale_points t3 on sale_point_id=t3.id
group by
	city, category
having
	category != 'Property'
order by
	1,3 desc,2

-- 7. для каждой категории выведем продукты, отранжированные по кол-ву сборов
select category, product_name,
ROW_NUMBER() OVER (PARTITION BY category ORDER BY premium desc) as product_rank,
premium
from (
	select category, product_name, product_id, sum(premium) as premium from policies t1 join products t2 on t1.product_id=t2.id group by product_id, product_name, category
) as sub
order by 1,product_rank

-- 8. для каждого полиса посмотрим отклонение возраста клиента от среднего возраста для этого продукта
select product_name, age, age-avg(age) over (partition by product_name) from 
(select
	product_name, extract(year from (age(birth_date))) as age
from
	policies t1 join clients t2 on t1.client_id=t2.id join products t3 on t1.product_id=t3.id) as sub
order by product_name

-- 9. для каждого агента выведем топ 3 продукта, отранжированных по сборам
select * from (select full_name, product_name, premium, row_number() over (partition by full_name order by premium desc) as sales_rank from
(select
	full_name, product_name, sum(premium) as premium
from 
	policies, products, agents where product_id=products.id and agent_id=agents.id
group by full_name, product_name) as sub
order by 1,sales_rank) as sub2 where sales_rank <=3

-- 10. для каждого агента в каждом городе посмотрим отклоенение его премии от его средней премии в этом городе и от общей средней премии по городу
select 
	full_name, 
	city, 
	premium - avg(premium) over(partition by city, full_name), 
	premium - avg(premium) over(partition by city) 
	from (select
	full_name, city, premium
from
	policies t1 join agents t2 on agent_id=t2.id join sale_points t3 on t1.sale_point_id=t3.id) as sub
order by
	1,2