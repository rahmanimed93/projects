# Data cleaning project

select * from world_layoffs.layoffs;
 
# Create a staging layoffs
create table layoffs_staging
like layoffs; 
 
 
select * from layoffs_staging; 
--------------------------------
insert layoffs_staging 
select * from layoffs;
--------------------------------
# 1 Remove duplicates
select *,row_number() over (
partition by company,location,industry,total_laid_off,percentage_laid_off, `date`,stage,country,funds_raised_millions) as removing_duplicate
from layoffs_staging;
#each row is more then 1 means that there's a duplicate
#here we use cte function .
with remove_duplicate as 
(
select *,row_number() over (
partition by company,location,industry,total_laid_off,percentage_laid_off, `date`,stage,country,funds_raised_millions) as removing_duplicate
from layoffs_staging
)
select * from
remove_duplicate
where removing_duplicate>2;

select * from layoffs_staging
where company="Yahoo";
#################
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `removing_duplicate` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

insert into layoffs_staging2
select *,row_number() over (
partition by company,location,industry,total_laid_off,percentage_laid_off, 
`date`,stage,country,funds_raised_millions) as removing_duplicate
from layoffs_staging;

###############
delete from layoffs_staging2
where removing_duplicate>1;
###############
select * from layoffs_staging2 
 where removing_duplicate>1;
############## 
select * from layoffs_staging2 
 where removing_duplicate=1;
 -----------------------------------------------
 # 2 Standardizing data (finding issue in our data and fixing it column by column)
 select trim(company) from layoffs_staging2;
 update layoffs_staging2
 set layoffs_staging2.company=trim(layoffs_staging2.company);
 
 select * from layoffs_staging2;
 ------------------------------------------
 select distinct industry from
 layoffs_staging2
 order by 1;
--------------------------

select * from layoffs_staging2
where industry like '%Crypto%';

update layoffs_staging2
set industry ="Crypto"
where industry like "%Crypto%";
select * from layoffs_staging2;

------------------------------
select distinct location from
 layoffs_staging2
 order by 1;
---------------------------------
select distinct country from
 layoffs_staging2
 order by 1;
 update layoffs_staging2
 set country="United States"
 where country like "%united states%";
 select distinct country from
 layoffs_staging2
 order by 1;
 select * from layoffs_staging2
 where country = "United States.";
 -------------------------------------------
 select `date`,str_to_date(`date`,'%m/%d/%Y')
 from layoffs_staging2;
 update layoffs_staging2
 set `date`=str_to_date(`date`,'%m/%d/%Y');
  select `date`
 from layoffs_staging2;
 #change the data type date
 alter table 
 layoffs_staging2 modify column `date` date;
 ####################
 # 3 Remonving blank and null
 select * from layoffs_staging2
 where total_laid_off is null
 and layoffs_staging2.percentage_laid_off is null;
 
 select   *  from layoffs_staging2
 where industry is null or industry="";
 -------------------------------
 select * from layoffs_staging2
 where company='Airbnb';
 update  layoffs_staging2
 set industry='Travel'
 where company='Airbnb';
  select * from layoffs_staging2
 where company='Carvana';
 update  layoffs_staging2
 set industry='Transportation'
 where company='Carvana';
 ---------------------------------------
 select * from layoffs_staging2
 where company='Juul';
 ------------------------------
 -- set blank columns in industry to null
 update layoffs_staging2 
 set industry=null
 where industry='';
 select * from layoffs_staging2 
 where industry is null
 order by industry
 ;
 
 ---------------------------
 select * from layoffs_staging2 t1
 inner join layoffs_staging2 t2
 on (t1.company=t2.company) and (t2.location=t2.location)
 where t1.industry is null
 and t2.industry is not null;
 -- we need to update these null values
 update layoffs_staging2 t1
 join layoffs_staging2 t2
 on (t1.company=t2.company) and (t1.location=t2.location)
 set t1.industry=t2.industry
 where t1.industry is null
 and t2.industry is not null;
 ---------- checking
  select * from layoffs_staging2 
 where industry is null or industry=''
 order by industry ;
 -----------------------------------
 select * from layoffs_staging2
 where total_laid_off is null
 and layoffs_staging2.percentage_laid_off is null;
 
#Drop row table
alter table layoffs_staging2
drop column removing_duplicate;
  
 
 delete  from layoffs_staging2
 where total_laid_off is null
 and layoffs_staging2.percentage_laid_off is null;
 
 select * from world_layoffs.layoffs_staging2;
  
 
 
