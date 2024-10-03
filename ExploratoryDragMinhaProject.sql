#Exploratory drag_minha_project
 select COMR,COUNT(COMR)  from drag_minha_staging2
 group by COMR
 order by COUNT(COMR) DESC;
 ------------------------------------
 with alem_cte as (
 select Alem ,count(Alem) as count_number from drag_minha_staging2
 group by Alem
 order by count(Alem) desc
 ),
 max_number as (
 select max(count_number) max_number from  alem_cte
 )
 select Alem,count_number from alem_cte
 join max_number
 on count_number=max_number;
 select * from drag_minha_staging2;
 WITH CTE_GENRV_MAX as (
 SELECT GENRV,COUNT(GENRV) as count_number
 FROM drag_minha_staging2
 group by GENRV
 order by COUNT(GENRV) desc
 ),MAX_NUMBER_GENRV as( select max(count_number) as max_number
 from CTE_GENRV_MAX
)select GENRV,count_number from CTE_GENRV_MAX
 inner JOIN MAX_NUMBER_GENRV 
 on count_number=max_number;
 ---------------------------
 with MARQUE_CTE  as( 
 select COMR as commune,MARQV as marquev,count(MARQV) as marque_number
 FROM drag_minha_staging2
 group by COMR,MARQV
 order by 2 desc
 ),MARQUE_CLASSEMENT as(
 select commune,marquev,dense_rank() over (partition by marquev order by marque_number DESC) as ranking_marque
  from MARQUE_CTE)
 select commune,marquev,ranking_marque from MARQUE_CLASSEMENT 
 order by 2; 
 select COMR,MARQV,count(MARQV) from drag_minha_staging2
 group by COMR,MARQV
 order by 3 desc;


 

 

 







    
    