SELECT * FROM drag_minha.project_drag_minha;

# create drag_minha_staging
 create table drag_minha_staging
 like project_drag_minha;
 ALTER TABLE drag_minha_staging
ADD COLUMN id INT AUTO_INCREMENT PRIMARY KEY FIRST;


 -------------------------------
 select * from drag_minha_staging;
  select NOMPRO from drag_minha_staging2;

 -------------------------------
 insert  drag_minha_staging
 select * from project_drag_minha;
--------------------------------
select * from drag_minha_staging;
--------------------------------
with remove_duplicate as (
select *, 
row_number()
over (partition by id,NOMPRO,DATENAIS,COMR,ImmatImp,TYPEV,STYPV,GENRV,MARQV,DAETC) as removing_duplicate from drag_minha_staging 
)
select * from remove_duplicate
where removing_duplicate >1;
with remove_duplicate as (

select *, 
row_number()
over (partition by NOMPRO,DATENAIS) as removing_duplicate from drag_minha_staging 
)
select * from remove_duplicate
where removing_duplicate >1;
---------------------------------
CREATE TABLE `drag_minha_staging2` (
  `id` int auto_increment primary key,
  `NOMPRO` text,
  `NOMPAR` text,
  `DATENAIS` int DEFAULT NULL,
  `NOMPERE` text,
  `NOMMERE` text,
  `ADRPR` text,
  `COMR` text,
  `ImmatImp` text,
  `TYPEV` text,
  `STYPV` text,
  `GENRV` text,
  `MARQV` text,
  `DAETC` int DEFAULT NULL,
  `Nom` text,
  `Prenom` text,
  `NomAr` text,
  `PrenomAr` text,
  `date_naissance` text,
  `Alem` text,
  `Awem` text,
  `removing_duplicate` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
insert into drag_minha_staging2 
select *, 
row_number()
over (partition by NOMPRO,DATENAIS,COMR,ImmatImp,TYPEV,STYPV,GENRV,MARQV,DAETC) as removing_duplicate 
from drag_minha_staging;
----------------------------------
delete from drag_minha_staging2
where removing_duplicate>1;
----------------------------------
select * from drag_minha_staging2
where removing_duplicate >1;
-----------------------------------
select * from drag_minha_staging2;

# Seperate name and surname 
SELECT
    drag_minha_staging2.NOMPRO,
	LENGTH(NOMPRO) - LENGTH(REPLACE(NOMPRO, ' ', '')) as occurrence_space
    #TRIM(SUBSTRING_INDEX(NOMPRO,' ', 1)) AS first_word,
    #TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(NOMPRO, ' ', 2), ' ', -1)) AS second_word
    #TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(full_text, ' ', 3), ' ', -1)) AS third_word,
	#TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(full_text, ' ', 4), ' ', -1)) AS fourth_word
FROM
    drag_minha_staging2
    group by(NOMPRO);

    
CREATE temporary TABLE `name_surname_temp` (
  `id` int auto_increment primary key,
  `NOMPRO` text,
  `occurrence_space` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

#------------------------------------------
CREATE temporary TABLE `name_surname_temp2` (
  `id` int auto_increment primary key,
  `NOMPRO` text,
  `occurrence_space` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE temporary TABLE `name_surname_temp3` (
  `id` int auto_increment primary key,
  `NOMPRO` text,
  `last_name` text,
  `first_name` text
  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

#--------------------------------------------
select * from name_surname_temp2;
select NOMPRO ,
LENGTH(NOMPRO) - LENGTH(REPLACE(NOMPRO, ' ', '')) as occurrence_space ,
replace(substring_index(NOMPRO,' ',2),' ','') ,
case 
when 
(occurrence_space=2) and (substring_index(NOMPRO,' ',2) like 'EL%' 
or substring_index(NOMPRO,' ',2) like 'YAICH%' OR
substring_index(NOMPRO,' ',2) like 'OULD%' OR
substring_index(NOMPRO,' ',2) like 'BEN%' OR 
substring_index(NOMPRO,' ',2) like 'HADJ%' )
then 
occurrence_space=2 and (substring_index(NOMPRO,' ',2) like 'EL%' 
or substring_index(NOMPRO,' ',2) like 'YAICH%' OR
substring_index(NOMPRO,' ',2) like 'OULD%' OR
substring_index(NOMPRO,' ',2) like 'BEN%' OR 
substring_index(NOMPRO,' ',2) like 'HADJ%' )
end as split
from name_surname_temp;



call truncate_temp_table();
insert into  name_surname_temp select 
    id,
	NOMPRO,
    LENGTH(NOMPRO) - LENGTH(REPLACE(NOMPRO, ' ', '')) as occurrence_space 
 FROM drag_minha_staging2;   
 #--------------------------------------
 insert into  name_surname_temp2 select 
    id,
	NOMPRO,
    LENGTH(NOMPRO) - LENGTH(REPLACE(NOMPRO, ' ', '')) as occurrence_space 
 FROM name_surname_temp;   
 #--------------------------------------  
update name_surname_temp
set NOMPRO=
concat(substring_index(NOMPRO,' ',1),
substring_index(substring_index(NOMPRO,' ',2),' ',-1)," ", substring_index(NOMPRO,' ',-1))
 where(occurrence_space=2
and (NOMPRO like 'OULD%' or NOMPRO like 'HADJ%' or NOMPRO like 'YAICH%' 
or NOMPRO like 'EL%') );
#---------------------------------------
update name_surname_temp
set NOMPRO=concat(substring_index(NOMPRO,' ',1)," ",
substring_index(substring_index(NOMPRO,' ',-2),' ',1),substring_index(NOMPRO,' ',-1))
 where(occurrence_space=2 and (NOMPRO like '%EDDINE' or NOMPRO like '%sid ahmed%' 
 or NOMPRO like '%sid ali%'));
 #---------------------------------
#update name_surname_temp

    
DROP TEMPORARY TABLE IF EXISTS name_surname_temp;
DROP TEMPORARY TABLE IF EXISTS name_surname_temp2;
DROP TEMPORARY TABLE IF EXISTS name_surname_temp3;

DELIMITER //
create procedure split_name_surname()
begin 
insert into name_surname_temp3
select id,NOMPRO,
case 
when occurrence_space=1 then 
TRIM(SUBSTRING_INDEX(NOMPRO,' ', 1)) 
when occurrence_space=2 and NOMPRO NOT LIKE 'BEN %' and NOMPRO not like 'AHMED %' and
NOMPRO not like 'SEFIANE TSOURI %' and NOMPRO NOT LIKE 'ABBAS ORABI %'
and NOMPRO NOT LIKE 'MOHAMED BOUCHNAK %' and  NOMPRO NOT LIKE 'MOHAMED BOUZIANE %' 
and NOMPRO not like 'Abdelkader%' and NOMPRO not like 'chiker %'
and  NOMPRO not like 'beni  %'  and NOMPRO not like 'BRAHIM ERRAHMANI %' and 
NOMPRO not like 'HASSANE DAOUADJI %'and  NOMPRO not like 'LE BEN %'
and NOMPRO not like 'OUAD %' and NOMPRO not  like 'SI  %' and NOMPRO not like 'SAID %'then
TRIM(substring_index(NOMPRO,' ',1))
when occurrence_space=2 and NOMPRO like 'BEN %' or NOMPRO  like 'AHMED %'
 or NOMPRO  like 'SEFIANE TSOURI %' or NOMPRO LIKE 'MOHAMED BOUZIANE %' OR
 NOMPRO  LIKE 'MOHAMED BOUCHNAK %' or NOMPRO  LIKE 'ABBAS ORABI %'
 or  NOMPRO like 'Abdelkader%' or NOMPRO like 'chiker %'
 or NOMPRO like 'beni  %' or NOMPRO like 'BRAHIM ERRAHMANI %' or
 NOMPRO like 'HASSANE DAOUADJI %' or NOMPRO like 'LE BEN %'
 or NOMPRO like 'OUAD %' or NOMPRO like 'SI  %' or NOMPRO like 'SAID %'
 then
TRIM(substring_index(NOMPRO,' ',2))
 when 
 occurrence_space=3  and (NOMPRO like 'AIT %' or NOMPRO like 'EL %' 
 or NOMPRO  like 'HADJ %' OR NOMPRO  like 'TSOURI%') and NOMPRO not like 'EL MOK%' 
 then 
 substring_index(NOMPRO,' ',3)
 when 
  occurrence_space=3 and  NOMPRO LIKE 'EL MOKR%'
  then
  substring_index(NOMPRO,' ',2)
 else
 substring_index(NOMPRO,' ',1)

end last_name,
case 
when occurrence_space=1 then
TRIM(SUBSTRING_INDEX(NOMPRO, ' ', -1))
when occurrence_space=2 AND NOMPRO NOT like 'BEN %' and
 NOMPRO NOT LIKE 'MOHAMED BOUZIANE %' 
and NOMPRO not like 'AHMED %' and NOMPRO NOT LIKE 'SEFIANE TSOURI %' 
AND NOMPRO NOT LIKE 'MOHAMED BOUCHNAK %' and NOMPRO NOT LIKE 'ABBAS ORABI %' and
 NOMPRO not like 'Abdelkader%' and NOMPRO not like 'chiker %' 
 and  NOMPRO not like 'beni  %' and NOMPRO not like 'BRAHIM ERRAHMANI %' 
 and NOMPRO not like 'HASSANE DAOUADJI %' and NOMPRO not like 'LE BEN %' and NOMPRO not like 'OUAD %' 
and  NOMPRO not like 'SI  %' and  NOMPRO not like 'SAID %' then 
TRIM(SUBSTRING_INDEX(NOMPRO, ' ', -2))
when
 occurrence_space=2 and
 (NOMPRO  like 'BEN %' OR NOMPRO  like 'AHMED %'OR 
NOMPRO  LIKE 'MOHAMED BOUZIANE %' or NOMPRO  LIKE 'SEFIANE TSOURI %') or
NOMPRO  LIKE 'MOHAMED BOUCHNAK %' or  NOMPRO  LIKE 'ABBAS ORABI %'
or NOMPRO like 'Abdelkader%' or NOMPRO like 'chiker %' or 
NOMPRO like 'BRAHIM ERRAHMANI %'or  NOMPRO like 'HASSANE DAOUADJI %' or 
NOMPRO like 'LE BEN %' or NOMPRO like 'SI  %' or NOMPRO like 'SAID %' or 
NOMPRO like 'OUAD %' then 
TRIM(substring_index(NOMPRO,' ',-1))
when 
 occurrence_space=3  and (NOMPRO like 'AIT %' or NOMPRO like 'EL %' 
 or NOMPRO  like 'HADJ %' OR NOMPRO  like 'TSOURI%') and NOMPRO not like 'EL MOK%' 
 then 
 substring_index(NOMPRO,' ',-1)
 when 
  occurrence_space=3 and  NOMPRO LIKE 'EL MOKR%'
  then
  substring_index(NOMPRO,' ',-2)
 else
 substring_index(NOMPRO,' ',-3)
end as first_name
from name_surname_temp2;
END//
DELIMITER ;


call split_name_surname();
DROP PROCEDURE IF EXISTS split_name_surname;
----------------------------------------
select  * from name_surname_temp3;
select  * from drag_minha_staging2 ;

alter table drag_minha_staging2 
add column NOM TEXT
after NOMPRO;
alter table drag_minha_staging2 
add column PRENOM text
after NOM;
--------------------------------------
 update drag_minha_staging2
 inner join name_surname_temp3
 on drag_minha_staging2.id=name_surname_temp3.id
 set drag_minha_staging2.NOM=name_surname_temp3.last_name,
     drag_minha_staging2.PRENOM=name_surname_temp3.first_name;
-------------------------------------------
select * 
from drag_minha_staging2;
--------------------------
alter table drag_minha_staging2
drop column NOMPAR;
-------------------------
# Standardize the date
alter table drag_minha_staging2
modify column DATENAIS text;
update drag_minha_staging2
set DATENAIS=lpad(DATENAIS,8,'0') ; 
update drag_minha_staging2
 set DATENAIS=
concat(substring(DATENAIS,1,2),'/',
substring(DATENAIS,3,2),'/'
,substring(DATENAIS,5,4));

select DATENAIS ,str_to_date(DATENAIS,'%d/%m/%Y')
FROM drag_minha_staging2;
update drag_minha_staging2
set DATENAIS=str_to_date(DATENAIS,'%d/%m/%Y');
alter table drag_minha_staging2
modify column DATENAIS DATE;
----------------------------------------
select * from drag_minha_staging2;
----------------------------------------
alter table drag_minha_staging2
drop column NOMPERE;
-------------------------------------
alter table drag_minha_staging2
drop column NOMMERE;
-------------------------------------
alter table drag_minha_staging2
drop column ADRPR;
-------------------------------------
select distinct COMR
from drag_minha_staging2
order by 1;
update drag_minha_staging2
set COMR='Beni TAMOU'
where COMR like '%beniTamou%';
update drag_minha_staging2
set COMR='El Affroun'
where COMR like '%Elaffroun%';
-----------------------------------------
select distinct MARQV
 from drag_minha_staging2 
 order by 1;
 update drag_minha_staging2
 set MARQV=trim(MARQV);
 update drag_minha_staging2
set MARQV='CHANA'
where MARQV like '%CHANNA%' ;
 update drag_minha_staging2
set MARQV='CHEVROLET'
where MARQV like '%VROLET' OR MARQV LIKE '%VROULET' or MARQV LIKE 'CHEVROLET       %';
 update drag_minha_staging2
set MARQV='DAIHATSU'
where MARQV like '%DAIHTSU%' or MARQV like '%DAIHATSI%'
or MARQV like '%DAIHATSU        %';
update drag_minha_staging2
set MARQV='dongfeng'
where MARQV like '%DDNGFENG%' or MARQV like '%DANGFANG%' 
or MARQV like '%DDNGFENG%' OR MARQV LIKE 'DONG%';
update drag_minha_staging2
set MARQV='FOTON'
where MARQV like '%FUTIAN%' ;
update drag_minha_staging2
set MARQV='CITROEN'
where MARQV like '%CITROEN         %' ;
update drag_minha_staging2
set MARQV='GREATWALL'
where MARQV like '%WALL' ;
update drag_minha_staging2
set MARQV='HONDA'
where MARQV like '%HOUNDA%' or MARQV like '%HONDA           %';
update drag_minha_staging2
set MARQV='HYUNDAI'
where MARQV like '%HYUNNDAI%' ;
update drag_minha_staging2
set MARQV='JAC'
where MARQV like '%J A C%' ;
update drag_minha_staging2
set MARQV='KIA MOTORS'
where MARQV like '%KIA%' ;
update drag_minha_staging2
set MARQV='MAGI'
where MARQV like '%MAG%' ;
update drag_minha_staging2
set MARQV='MARUTI'
where MARQV like '%MAUTI%' ;
update drag_minha_staging2
set MARQV='PEUGEOT'
where MARQV like '%PEUGOET%' or MARQV like '%PEUGOET%'
or MARQV like '%PUGEOT%';
update drag_minha_staging2
set MARQV='RENAULT'
where MARQV like '%RENAULR%';
update drag_minha_staging2
set GENRV=trim(GENRV);
update drag_minha_staging2
set GENRV='REMQ'
where GENRV='REMO';
update drag_minha_staging2
set MARQV='VOLKSWAGEN'
where MARQV like '%VOLKSWOGEN%' or MARQV like '%VW%'
 or MARQV like '%W.V%' or MARQV like '%V.W%';
 update drag_minha_staging2
 set  MARQV='MARQUE NON INDIQUE'
 where MARQV like '?%';
 ALTER TABLE drag_minha_staging2
 DROP COLUMN NomAr;
 ALTER TABLE drag_minha_staging2
 DROP COLUMN PrenomAr;
 ALTER TABLE drag_minha_staging2
 DROP COLUMN date_naissance;
 ALTER TABLE drag_minha_staging2
 DROP COLUMN removing_duplicate;
 -------------------------------------
  select * from drag_minha_staging2;
 -------------------------------------


 

 

 







    
    

    
    
    
    
    
    
