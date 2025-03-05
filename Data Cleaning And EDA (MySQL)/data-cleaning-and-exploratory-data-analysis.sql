-- Step 1 - Remove duplicates
-- Step 2 - Standardized Data
-- Step 3 - Null values or blank values
-- Step 4 - Remove Any Columns

create table layoffs_stagging
select * from layoffs;

insert layoffs_stagging
select * from layoffs;


-- ***********************************************
select * from layoffs_stagging where company = 'Casper';
-- Step 1 Removing Duplicates

select * , 
row_number() over(partition by company,location, industry , total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num
from layoffs_stagging ;


with duplicate_cte as(
	select * , 
row_number() over(partition by company,location, industry , total_laid_off,percentage_laid_off,`date`,stage,country , funds_raised_millions) as row_num
from layoffs_stagging 
) select * from duplicate_cte 
where row_num >1;


CREATE TABLE `layoffs_stagging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

insert layoffs_stagging2
select * , 
row_number() 
over(partition by company,location, 
industry , total_laid_off,
percentage_laid_off,
`date`,stage,country,
funds_raised_millions) as row_num
from layoffs_stagging ;


select * from layoffs_stagging2;

delete from layoffs_stagging2 where row_num>1;

select * from layoffs_stagging2 where row_num>1;


-- *******************************************

-- Standardize The Data	

select company , trim(company) 
from layoffs_stagging2;


update layoffs_stagging2 
set company = trim(company);


select distinct(industry) from layoffs_stagging2 order by industry;

select * from layoffs_stagging2 where industry like 'Crypto%';

update layoffs_stagging2 
set industry = 'Crypto'
where industry like 'Crypto%';

select distinct(location) from layoffs_stagging2 order by 1;

select distinct(country) from layoffs_stagging2 order by 1;

select distinct(country), trim(trailing '.' from country ) 
from layoffs_stagging2 order by 1;

update layoffs_stagging2 
set country = trim(trailing '.' from country)
where country like "United States%";


select *
from layoffs_stagging2;


update layoffs_stagging2
set `date` = str_to_date(`date`,'%m/%d/%Y');

alter table layoffs_stagging2 modify column `date` Date;

update layoffs_stagging2
set industry = null where 
industry = '';

select * from layoffs_stagging2 where industry is null or industry='';

select *  from layoffs_stagging2 where company = 'Airbnb';

select distinct * from layoffs_stagging2;

select t1.industry,t2.industry
 from layoffs_stagging2 t1 
join layoffs_stagging2 t2 
on t1.company = t2.company 
where (t1.industry is null or t1.industry ='') 
and t2.industry is not null;

update  layoffs_stagging2 t1 
join layoffs_stagging2 t2 
on t1.company = t2.company
set t1.industry = t2.industry 
where (t1.industry is null or t1.industry ='') 
and t2.industry is not null;


select * from layoffs_stagging2 where total_laid_off is null and percentage_laid_off is null;

delete from layoffs_stagging2 where total_laid_off is null and percentage_laid_off is null;


select * from layoffs_stagging2;

alter table layoffs_stagging2 drop column row_num;



-- ************************************


-- Exploratory Data Analysis



select max(total_laid_off) , max(percentage_laid_off)
from layoffs_stagging2;

select industry , sum(total_laid_off) from layoffs_stagging2 group by industry order by 2 desc;

select country, sum(total_laid_off) from layoffs_stagging2 group by country order by 2 desc;

select `date` , sum(total_laid_off)
from layoffs_stagging2
group by `date`
order by 1 desc ;


select substring(`date` , 1,7) as `Month` , sum(total_laid_off) as Total_lay_offs
from layoffs_stagging2
where substring(`date`,1,7)
group by `Month`
order by 1 asc;



with Rolling_total as(
select substring(`date` , 1,7) as `Month` , sum(total_laid_off) as Total_lay_offs
from layoffs_stagging2
where substring(`date`,1,7)
group by `Month`
order by 1 asc)
select `Month` , Total_lay_offs , sum(Total_lay_offs) over(order by `Month`) as Rolling_Total
from Rolling_total;


with Company_year(company,years,total_laid_off) as
(
select company,year(`date`),sum(total_laid_off)
from layoffs_stagging2
group by company,year(`date`)
),Company_Year_Rank as (
select * , 
dense_rank() over (partition by years order by total_laid_off desc) as ranking
from Company_year 
where years is not null
order by ranking asc)
select * 
from Company_Year_Rank
where ranking<=5
order by ranking ;
