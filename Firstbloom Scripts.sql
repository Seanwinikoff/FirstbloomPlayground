--count all products with the top 10 tasting notes
--top 10 tasting notes AS top_tasting_notes-- DONE!
select count(cpptc.tasting_note_id), 
cpptc.tasting_note_id
from 
compiled_purchaseable_product_taste_categories cpptc  
group by 
cpptc.tasting_note_id
order by 
count desc 
limit 10

select count(product_release_varieties.variety_id), varieties.name
from product_release_varieties  
join varieties  
on varieties.id = product_release_varieties.variety_id  
group by product_release_varieties.variety_id, varieties.name 
order by count desc 
limit 10

select p.id, p.product_name product_names
from products p 
order by id desc

select tn.id, tn.name as tasting_notes
from tasting_notes tn 
order by id desc

------------------------------------------------------------------------------------------------------

--products with top 10 notes 
with top_taste_categories as (
		select sum(cpptc.count), cpptc.tasting_note_id
		from compiled_purchaseable_product_taste_categories cpptc  
		group by cpptc.tasting_note_id 
		order by 
		sum desc
		limit 10) 
select cpptc.tasting_note_id, tasting_notes.name, cpptc.product_id, products.product_name  
from compiled_purchaseable_product_taste_categories cpptc
join products on cpptc.product_id = products.id 
join tasting_notes on cpptc.tasting_note_id = tasting_notes.id
where cpptc.tasting_note_id in (select cpptc.tasting_note_id from top_taste_categories)  
order by 
cpptc.product_id  desc  
limit 10
		

select count(product_release_varieties.variety_id), varieties.name
from product_release_varieties  
join varieties  
on varieties.id = product_release_varieties.variety_id  
group by product_release_varieties.variety_id, varieties.name 
order by count desc 
limit 10

--------------------------------------------------------------------------------------------------------

--find causality between region and popularity of product sale
--correlation between top products sold and varietals come from 
with top_varietals as (
	select count(product_release_varieties.variety_id), varieties.name
	from product_release_varieties  
	join varieties  
	on varieties.id = product_release_varieties.variety_id  
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

