-- parcels: load parcels data, find neighborhoods, then match crimes, complaints, violations, and permits
CREATE TABLE parcels (
       parcel_name        varchar(100),
       poly	     	  varchar(10000),
       area_m	     	  float8,
       condition	  varchar(50),
       dumping		  varchar(10),
       fire		  varchar(10),
       improved		  varchar(10),
       maintained	  varchar(10),
       needs_boarding	  varchar(10),
       notes		  varchar(500),
       occupancy	  varchar(50),
       photo_url	  varchar(500),
       structure	  varchar(10),
       units		  varchar(50),
       use		  varchar(50),
       poly_geom     	  geometry,
       nhood	     	  varchar(100),
       crime_count	  int,
       complaint_count	  int,
       violation_count	  int,
       state		  varchar(25)
);

-- to get the data:
--   1. get the Motor City Mapping (MCM) shapefile from http://portal.datadrivendetroit.org/
--   2. load the shapefile into python using the basemap package
--   3. create and save dataframe into parcels.csv
\copy parcels(parcel_name, poly, area_m, condition, dumping, fire, improved, needs_boarding, notes, occupancy, photo_url, structure, units, use) from 'parcels.csv' csv header;

-- get postGIS objects
update parcels set poly_geom = st_geomfromtext(poly);

-- find neighborhoods corresponding to parcels
-- first check based on containment

update parcels set nhood = n.nhood from neighborhoods as n where st_contains(n.poly_geom, parcels.poly_geom);

-- then check based on closest match < 25 meters away
create table temp (poly varchar(10000), nhood varchar(100), dist double);
insert into temp select p.poly, n.nhood st_distance(n.poly_geom, p.poly_geom) from neighborhoods as n, parcels as p where p.nhood is null and not exists (select * from neighborhoods as n2 where st_distance(n2.poly_geom, p.poly_geom) < st_distance(n.poly_geom, p.poly_geom);

update parcels set nhood = temp.nhood from temp where parcels.nhood is null and parcels.poly = temp.poly and temp.dist < 25;


-- find crimes corresponding to parcels. use neighborhoods to narrow down search.
-- first try containment
update parcels set crime_count = 0;

drop table temp;
create table temp (point varchar(100), poly varchar(10000));
insert into temp c.point, p.poly from crimes as c, parcels as p where c.nhood = p.nhood and st_contains(p.poly_geom, c.point_geom);

-- next try address matching
-- load function matches from matches.sql before running this part
insert into temp c.point, p.poly from crimes as c, parcels as p where matches(p.parcel_name, c.address) and p.nhood = c.nhood;

-- for remaining crimes try closest parcel within 25 meters
insert into temp c.point, p.poly from crimes as c, parcels as p where not exists (select * from temp as t where t.point = c.point) and not exists (select * from parcels as p2 where st_distance(p2.poly_geom, c.point_geom) < st_distance(p.poly_geom, c.point_geom)) and st_distance(p.poly_geom, c.point_geom) < 25 and c.nhood = p.nhood;

drop table temp2;
create table temp2 (poly varchar(10000), crime_count int);
insert into temp2 select temp.poly, count(*) from temp group by temp.poly;

update parcels set crime_count = temp2.crime_count from temp2 where parcels.poly = temp2.poly;



-- use same method to find complaints corresponding to parcels
update parcels set complaint_count = 0;

-- first containment
drop table temp;
create table temp (point varchar(100), poly varchar(10000));
insert into temp c.point, p.poly from complaints as c, parcels as p where c.nhood = p.nhood and st_contains(p.poly_geom, c.point_geom);

-- next address matching
insert into temp c.point, p.poly from complaints as c, parcels as p where matches(p.parcel_name, c.address) and p.nhood = c.nhood;

-- lastly closest parcel within 25 meters
insert into temp c.point, p.poly from complaints as c, parcels as p where not exists (select * from temp as t where t.point = c.point) and not exists (select * from parcels as p2 where st_distance(p2.poly_geom, c.point_geom) < st_distance(p.poly_geom, c.point_geom)) and st_distance(p.poly_geom, c.point_geom) < 25 and c.nhood = p.nhood;

drop table temp2;
create table temp2 (poly varchar(10000), complaint_count int);
insert into temp2 select temp.poly, count(*) from temp group by temp.poly;

update parcels set complaint_count = temp2.complaint_count from temp2 where parcels.poly = temp2.poly;



-- use same method to find violations corresponding to parcels
update parcels set violation_count = 0;

-- first containment
drop table temp;
create table temp (point varchar(100), poly varchar(10000));
insert into temp v.point, p.poly from violations as v, parcels as p where v.nhood = p.nhood and st_contains(p.poly_geom, v.point_geom);

-- next address matching
insert into temp v.point, p.poly from violations as v, parcels as p where matches(p.parcel_name, v.address) and p.nhood = v.nhood;

-- lastly closest parcel within 25 meters
insert into temp v.point, p.poly from violations as v, parcels as p where not exists (select * from temp as t where t.point = v.point) and not exists (select * from parcels as p2 where st_distance(p2.poly_geom, v.point_geom) < st_distance(p.poly_geom, v.point_geom)) and st_distance(p.poly_geom, v.point_geom) < 25 and v.nhood = p.nhood;

drop table temp2;
create table temp2 (poly varchar(10000), violation_count int);
insert into temp2 select temp.poly, count(*) from temp group by temp.poly;

update parcels set violation_count = temp2.violation_count from temp2 where parcels.poly = temp2.poly;



-- use same methods to find dismantle permits corresponding to parcels and set their state as 'blighted'
update parcels set state = 'not_blighted';

-- first containment
drop table temp;
create table temp (point varchar(100), poly varchar(10000));
insert into temp v.point, p.poly from permits as v, parcels as p where v.nhood = p.nhood and st_contains(p.poly_geom, v.point_geom);

-- next address matching
insert into temp v.point, p.poly from permits as v, parcels as p where matches(p.parcel_name, v.address) and p.nhood = v.nhood;

-- lastly closest parcel within 25 meters
insert into temp v.point, p.poly from permits as v, parcels as p where not exists (select * from temp as t where t.point = v.point) and not exists (select * from parcels as p2 where st_distance(p2.poly_geom, v.point_geom) < st_distance(p.poly_geom, v.point_geom)) and st_distance(p.poly_geom, v.point_geom) < 25 and v.nhood = p.nhood;

update parcels set state = 'blighted' where exists (select * from temp where temp.poly = parcels.poly);

-- also set a parcel to 'blighted' if its condition is 'suggest demolition'
update parcels set state = 'blighted' where condition = 'suggest demolition';



-- now we can output the data needed for modeling
\copy parcels to 'parcels_modeling_data.csv' csv header;
