-- create a table to hold the neighborhoods for detroit
create table neighborhoods (
       nhood 		varchar(100),
       poly		varchar(10000),
       poly_geom	geometry,
       area_m		float8
);

-- How to get the data:
--   1. download the neighborhoods shapefile from http://portal.datadrivendetroit.org/datasets/b4ce77680a8d4d1fac8e2c3ba303d0f9_0
--   2. load the shapefile into python using the basemap package
--   3. create a data frame that is the neighborhood name, the shapely polygons wkt (well-known text) format, and the area
--   4. save the data frame into "neighborhoods.csv"
\copy neighborhoods(nhood, poly, area_m) from 'neighborhoods.csv' csv header;

-- use the postGIS package to create geometric object corresponding to each neighborhood
update neighborhoods set poly_geom = st_geomfromtext(poly);




