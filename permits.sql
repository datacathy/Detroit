-- create permits table for detroit dismantle permits data
CREATE TABLE permits (
       permit_no		varchar(50),
       permit_applied		date,
       permit_issued		date,
       permit_expires		date,
       site_address		varchar(100),
       between1			varchar(100),
       parcel_no		varchar(50),
       lot_number		varchar(10),
       subdivision		varchar(50),
       case_type		varchar(10),
       case_description		varchar(50),
       legal_use		varchar(100),
       estimated_cost		varchar(20),
       parcel_size		float4,
       parcel_clust_sec		float4,
       stories			float4,
       parcel_floor_area	float4,
       parcel_ground_area	float4,
       prc_aka_address		varchar(50),
       bld_permit_type		varchar(20),
       permit_description	varchar(20),
       bld_permit_desc		varchar(250),
       bld_type_use		varchar(50),
       residential		varchar(50),
       description		varchar(50),
       bld_type_const_cod	varchar(10),
       bld_zoning_dist		varchar(10),
       bld_use_group		varchar(10),
       bld_basement		varchar(10),
       fee_type			varchar(20),
       csm_caseno		varchar(50),
       csf_created_by		varchar(10),
       seq_no			int,
       pcf_amt_pd		varchar(10),
       pcf_amt_due		varchar(15),
       pcf_updated		varchar(20),
       owner_last_name		varchar(100),
       owner_first_name		varchar(100),
       owner_address1		varchar(50),
       owner_address2		varchar(50),
       owner_city		varchar(25),
       owner_state		varchar(5),
       owner_zip		varchar(10),
       contractor_last_name	varchar(100),
       contractor_first_name	varchar(100),
       contractor_address1	varchar(50),
       contractor_address2	varchar(50),
       contractor_city		varchar(25),
       contractor_state		varchar(5),
       contractor_zip		varchar(10),
       condition_for_approval	varchar(500),
       site_location		varchar(100),
       owner_location		varchar(100),
       contractor_location	varchar(100),
       lat			float8,
       lon			float8,
       point			varchar(100),
       point_geom		geometry,
       nhood			varchar(100)
);

-- to get the data:
--   1. get the tsv data on demolitions from either the coursera capstone page or https://data.detroitmi.gov/
--   2. load the tsv into python and use basemap package to get wkt form of geometric points
--   3. create and save dataframe into permits.csv
\copy permits(permit_no, permit_applied, permit_issued, permit_expires, site_address, between1, parcel_no, lot_number, subdivision, case_type, case_description, legal_use, estimated_cost, parcel_size, parcel_clust_sec, stories, parcel_floor_area, parcel_ground_area, prc_aka_address, bld_permit_type, permit_description, bld_permit_desc, bld_type_use, residential, description, bld_type_const_cod, bld_zoning_dist, bld_use_group, bld_basement, fee_type, csm_caseno, csv_created_by, seq_no, pcf_amt_pd, pcf_amt_due, pcf_updated, owner_last_name, owner_first_name, owner_address1, owner_address2, owner_city, owner_state, owner_zip, contractor_last_name, contractor_first_name, contractor_address1, contractor_address2, contractor_city, contractor_state, contractor_zip, condition_for_approval, site_location, owner_location, contractor_location, lat, lon, point) from 'permits.csv' csv header;

-- create postGIS objects
update permits set point_geom = st_geomfromtext(point);

-- find neighborhoods
-- first, use containment
update permits set nhood = n.nhood from neighborhoods as n where st_contains(n.poly_geom, point_geom);

-- then find closest neighborhoods for nulls
create table temp (point varchar(100), nhood varchar(100), dist double);
insert into temp select p.point, n.nhood, st_distance(n.poly_geom, p.point_geom) from neighborhoods as n, permits as p where p.nhood is null and not exists (select * from neighborhoods as n2 where st_distance(n2.poly_geom, p.point_geom) < st_distance(n.poly_geom, p.point_geom));

update table permits set nhood = temp.nhood from temp where permits.nhood is null and permits.point = temp.point and temp.dist < 25;




