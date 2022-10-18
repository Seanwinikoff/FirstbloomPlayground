--countries and their cities/region ids
select product_release_varieties.coffee_region_id, 
	coffee_regions.city_id, 
	cities."name" as city, 
	coffee_regions.country_id, 
	countries."name" as country
from product_release_varieties
join coffee_regions 
	on product_release_varieties.coffee_region_id  = coffee_regions.id
join cities 
	on coffee_regions.city_id = cities.id
join countries 
	on coffee_regions.country_id = countries.id
group by product_release_varieties.coffee_region_id, 
	coffee_regions.city_id, 
	cities."name", 
	coffee_regions.country_id, 
	countries."name"
order by country

--count top 10 tasting notes
select count(cpptc.tasting_note_id), cpptc.tasting_note_id, tn.name
from compiled_purchaseable_product_taste_categories cpptc  
join tasting_notes tn on cpptc.tasting_note_id = tn.id
group by cpptc.tasting_note_id, tn."name" 
order by count desc 
limit 10

--10 most common varieties
select count(product_release_varieties.variety_id), varieties.name
from product_release_varieties  
join varieties on varieties.id = product_release_varieties.variety_id  
group by product_release_varieties.variety_id, varieties.name 
order by count desc 
limit 10

--10 best tasting notes
select tn.id, tn.name as tasting_notes
from tasting_notes tn 
order by id asc 
limit 10

--10 worst tasting notes
select tn.id, tn.name as tasting_notes
from tasting_notes tn 
order by id desc
limit 10

------------------------------------------------------------------------------------------------------
--products with top 10 notes 
with top_taste_categories as (
		select sum(cpptc.count), cpptc.tasting_note_id, tasting_notes."name"
		from compiled_purchaseable_product_taste_categories cpptc  
		join tasting_notes on cpptc.tasting_note_id = tasting_notes.id 
		group by cpptc.tasting_note_id, tasting_notes."name"  
		order by sum desc
		limit 10) 
select cpptc.tasting_note_id, tasting_notes.name, cpptc.product_id, products.product_name  
from compiled_purchaseable_product_taste_categories cpptc
join products on cpptc.product_id = products.id 
join tasting_notes on cpptc.tasting_note_id = tasting_notes.id
where cpptc.tasting_note_id in (select cpptc.tasting_note_id from top_taste_categories)  
order by cpptc.product_id  desc  
limit 10

----------------------------------------------------------------------------------------------------
--heat map of coffee product. regions/ heatmap for flavour profiles 
--comparing producing regions with their top flavor profiles	
with top_tasting_notes as (
		select sum(cppsltb.count), cppsltb.tasting_note_id, tasting_notes."name" 
		from compiled_country_second_level_taste_breakdowns cppsltb  
		join tasting_notes on cppsltb.tasting_note_id = tasting_notes.id 
		group by cppsltb.tasting_note_id, tasting_notes."name"  
		order by sum desc
		)
select ccsltb.tasting_note_id, tn.name as varietal, sum(ccsltb.count),  ccsltb.country_id, co.name as country  
from compiled_country_second_level_taste_breakdowns ccsltb 
join countries co on ccsltb.country_id = co.id
join tasting_notes tn on ccsltb.tasting_note_id = tn.id  
where ccsltb.tasting_note_id in (select ccsltb.tasting_note_id from top_tasting_notes)
group by ccsltb.tasting_note_id,ccsltb.country_id, co."name", tn."name"  
order by country asc 

--------------------------------------------------------------------------------------------------------
--find each region/country's best varietals
-- select count of times a varietal comes up in a region (use its id), varietal name  
select product_release_varieties.coffee_region_id, 
	count(product_release_varieties.variety_id) over (partition by product_release_varieties.variety_id), 
	--product_release_varieties.variety_id,
	varieties."name",
	--coffee_regions.city_id, 
	cities."name" as city, 
	--coffee_regions.country_id, 
	countries."name" as country
from product_release_varieties 
join coffee_regions 
	on product_release_varieties.coffee_region_id  = coffee_regions.id
join varieties 
	on product_release_varieties.variety_id = varieties.id 
join cities 
	on coffee_regions.city_id = cities.id
join countries 
	on coffee_regions.country_id = countries.id
--where 
group by product_release_varieties.coffee_region_id, 
	coffee_regions.city_id,
	product_release_varieties.variety_id,
	varieties."name",
	cities."name", 
	coffee_regions.country_id, 
	countries."name"
order by country, 
	count desc  

----------------------------------------------------------------------------------------------------------
--counting the different roasters in different countries
select count(r."name"),crl.country_id, c."name"
from roasters r
join coffee_roaster_locations crl on r.id = crl.country_id
join countries c on r.id = c.id
group by crl.country_id, c."name" 
order by count desc

--------------------------------------------------------------------------------------------------------
--Most popular product from each roaster 
select r.name, p.product_name
from roasters r 
join products p on r.id = p.id 
order by r."name" 
	
--------------------------------------------------------------------------------------------------------
--find causality between region and popularity of product sale
--correlation between top products sold and varietals come from 
with top_varietals as (
	select count(product_release_varieties.variety_id), varieties.name
	from product_release_varieties  
	join varieties on varieties.id = product_release_varieties.variety_id  
	group by product_release_varieties.variety_id, varieties.name 
	order by count desc 
	limit 10)
select products.product_name, prv.variety_id,
	varieties.name
from product_release_varieties prv 
left join products on prv.id = products.id 
left join product_releases on prv.id = product_releases.product_id  
left join varieties on prv.variety_id = varieties.id  
where prv.variety_id  in (select prv.producer_id from top_varietals)

--------------------------------------------------------------------------------------------------------
--how much did i spend on FB? (check order_items)
select oi.order_id, sum(oi.price_paid)
from order_items oi 
join orders o on oi.order_id = o.id 
where order_id = 3
group by oi.order_id

select customer_name, session_id 
from orders o 
where customer_name ='Sean Winikoff'

----------------------------------------------------------------------------------------------------
--look through the reviews as a way to gauge popularity in flavour profiles across coffees 
with top_ratings as (
	select fbupr.rating, fbupr.product_id, p.product_name 
	from first_bloom_user_product_reviews fbupr 
	join products p on fbupr.product_id = p.id 
	order by rating desc
	)
select 

----------------------------------------------------------------------------------------------------
--heat map of coffe product. regions/ heatmap for flavour profiles 
--comparing producing regions with their top flavor profiles
