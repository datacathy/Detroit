-- crimes.sql: create and load detroit crime incident data and find what neighborhood it corresponds to
create table crimes (
       rownum	    int,
       caseid	    int,
       incino	    varchar(100),
       category	    varchar(100),
       description  varchar(1000),
       stateclass   float8,
       incidate	    date,
       incihour	    int,
       sca	    float4,
       precinct	    float4,
       council	    varchar(100),
       nhood1	    varchar(100),
       tract	    float4,
       address	    varchar(100),
       lon	    float8,
       lat	    float8,
       location	    varchar(500),
       point	    varchar(500),
       nhood	    varchar(100),
       point_geom   geometry
);

-- to get the crimes data:
--   1. download the crime incident data from the coursera page or from https://data.detroitmi.gov/browse?category=Public+Safety
--   2. load the csv into python and use the basemap package to map locations to shapely points
--   3. create and output the dataframe as crimes.csv
\copy crimes(rownum, caseid, incino, category, description, stateclass, incidate, incihour, sca, precinct, council, nhood1, tract, address, lon, lat, location, point) from 'crimes.csv' csv header;

-- once loaded, create geometric object corresponding to point column (point is WKT for the shapely point objects)
update crimes set point_geom = st_geomfromtext(point);

-- now find neighborhood corresponding to each crime incident.
--   First find neighborhood based on containment.
--   Then find neighborhood based on distance < 25 for remaining incidents.
update table crimes set nhood = n.nhood from neighborhoods as n where st_contains(n.poly_geom, point_geom);

-- to find remaining neighborhoods based on distance, first find closest neighborhoods then include those < 25 away
create table temp (rownum int, nhood varchar(100), dist double);
insert into temp select c.rownum, n.nhood, st_distance(n.poly_geom, c.point_geom) from crimes as c, neighborhoods as n where nhood is null and not exists (select * from neighborhoods as n2 where st_distance(n2.poly_geom, c.point_geom) < st_distance(n.poly_geom, c.point_geom);

-- note: if there's more than one neighborhood with minimum distance this will fail
-- in that case need to select a random single neighborhood from temp
update table crimes set nhood = t.nhood from temp as t where crimes.rownum = t.rownum and t.dist < 25;

