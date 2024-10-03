-- Exploratory Data Analysis
select  max(total_laid_off),max(percentage_laid_off)
          from world_layoffs.layoffs_staging2;
select * from   layoffs_staging2
  where percentage_laid_off=1
order by total_laid_off DESC;
select company,sum(total_laid_off) 
from   layoffs_staging2
group by company
ORDER BY 2 desc;
select industry,sum(total_laid_off) 
from   layoffs_staging2
group by industry
ORDER BY 2 desc;

select country,sum(total_laid_off) 
from   layoffs_staging2
group by country
ORDER BY 2 desc;
select `date`,sum(total_laid_off) 
from   layoffs_staging2
group by `date`
ORDER BY 1 asc;
select substring(`date`,1,7) as dates ,sum(total_laid_off) as total_laid_off
from layoffs_staging2
where substring(`date`,1,7) is not null
group by dates 
order by dates asc;

with DATE_CTE as (
select substring(`date`,1,7) as dates,sum(total_laid_off) as total_rolling
from layoffs_staging2
where substring(`date`,1,7) is not null
group by dates 
order by 1 asc
)
select dates,total_rolling,sum(total_rolling) over (order by dates asc)as rolling_total_layoffs
from DATE_CTE
order by dates asc;


select company ,year(`date`),sum(total_laid_off)
from layoffs_staging2
group by company,year(`date`)
order by 3 desc;

with Company_year(company,years,total_laid_off) as (
select company ,year(`date`),sum(total_laid_off)
from layoffs_staging2
group by company,year(`date`)
order by 3 desc
),company_year_rank as(
select * ,dense_rank() over (partition by years order by total_laid_off desc) as ranking
from Company_year)
select company,years,total_laid_off,ranking
from company_year_rank
where ranking <=5 and years is not null
order by years asc,total_laid_off desc;
)







  