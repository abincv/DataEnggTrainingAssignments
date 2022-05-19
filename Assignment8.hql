
--create database if not exists pokemonDB;

use pokemonDB;

--create external table if not exists pokemon_tbl
--(
--id int,Name string,Type_1 VARCHAR(50),Type_2 VARCHAR(50),Total int,HP int,Attack int,Defense int, Sp_Atk int,Sp_Def int,Speed int,Generation int,Legendary varchar(20)
--)
--ROW FORMAT DELIMITED
--FIELDS TERMINATED BY ','
--LINES TERMINATED BY '\n'
--STORED AS TEXTFILE
--tblproperties("skip.header.line.count" = "1");




--load data inpath '/Pokemon/pokemon.csv' overwrite into table pokemon_tbl;


--c.Find out the average HP (Hit Points) of all the Pokémon

select avg(hp)
from pokemon_tbl;

--d.Create and insert values of the existing table into a new table with an additional column power_rate into “powerful”, “moderate” and “powerless” from the table “Pokémon”

CREATE TABLE NEW_pokemon_tbl AS
SELECT *, if(total<200,'powerless',if(total<300,'Moderate','Powerful')) as power_rate
FROM pokemon_tbl;

--e) Find out top 10 Pokémon according to their HP

select name,hp
from pokemon_tbl
order by hp desc
limit 10;

--f) Find out top 10 Pokémon based on their Attack stat

select name,attack
from pokemon_tbl
order by attack desc
limit 10;

--g) Find out top 15 Pokémon based on their defence stat

select name,defense
from pokemon_tbl
order by defense desc
limit 15;

--h) Find out the top 20 Pokémon based on their total power

select name,total as total_power
from pokemon_tbl
order by total_power desc
limit 20;

--i) Find out the top 10 Pokémon having a drastic change in their attack and sp.attack

select name,attack,sp_atk, abs(sp_atk-attack) as change
from pokemon_tbl
order by change desc
limit 10;

--j) Find the top 10 Pokémon having a drastic change in their defence and special defence

select name,defense,sp_def, abs(sp_def-defense) as change
from pokemon_tbl
order by change desc
limit 10;
