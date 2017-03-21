-- load complaints data and find corresponding neighborhoods
create table complaints(
       ticket_id			varchar(20),
       city				varchar(50),
       issue_type			varchar(100),
       ticket_status			varchar(20),
       issue_description		varchar(1500),
       rating				int,
       ticket_closed_date_time		date,
       acknowledged_at			date,
       ticket_created_date_time		date,
       ticket_last_updated_date_time	date,
       address				varchar(100),
       lat				float8,
       lng				float8,
       location				varchar(100),
       image				varchar(200),
       point				varchar(100),
       site				varchar(100),
       point_geom 			geometry,
       nhood				varchar(100)
);

-- to get the data:
--   1. download the detroit 311 complaints csv file from the coursera page or https://data.detroitmi.gov/
--   2. load the complaints into python and use the basemap package to get wkt (well-known text) format for the points
--   3. create and save data frame into 'complaints.csv'
\copy complaints(ticket_id, city, issue_type, ticket_status, issue_description, rating, ticket_closed_date_time, acknowledged_at, ticket_created_date_time, ticket_last_updated_date_time, address, lat, lng, location, image, point, site) from 'complaints.csv' csv header;

-- create postGIS objects
update complaints set point_geom = st_geomfromtext(point);

-- now find corresponding neighborhood for complaints
-- first, check for containment
update complaints set nhood = n.nhood from neighborhoods as n where st_contains(n.poly_geom, point_geom);

-- then find neighborhoods with shortest distances from points not already found
create table temp (point varchar(100), nhood varchar(100), dist double);
insert into temp select c.point, n.nhood, st_distance(n.poly_geom, c.point_geom) from neighborhoods as n, complaints as c where c.nhood is null and not exists (select * from neighborhoods as n2 where st_distance(n2.poly_geom, c.point_geom) < st_distance(n.poly_geom, c.point_geom);

-- use distance < 25 to fill remaining neighborhoods
update complaints set nhood = temp.nhood from temp where complaints.nhood is null and complaints.point = temp.point and temp.dist < 25;
