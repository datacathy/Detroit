-- create violations table for detroit blight violations data
CREATE TABLE violations (
       TicketID			varchar(10),
       TicketNumber		varchar(20),
       AgencyName		varchar(100),
       ViolName			varchar(200),
       ViolationStreetNumber	varchar(50),
       ViolationStreetName	varchar(50),
       MailingStreetNumber	varchar(50),
       MailingStreetName	varchar(100),
       MailingCity		varchar(50),
       MailingState		varchar(50),
       MailingZipCode		varchar(20),
       NonUsAddressCode		varchar(100),
       Country			varchar(50),
       TicketIssuedDT		varchar(50),
       TicketIssuedTime		varchar(50),
       HearingDT		varchar(50),
       CourtTime		varchar(20),
       ViolationCode		varchar(50),
       ViolDescription		varchar(500),
       Disposition		varchar(100),
       FineAmt			varchar(20),
       AdminFee			varchar(20),
       LateFee			varchar(20),
       StateFee			varchar(20),
       CleanUpCost		varchar(20),
       JudgmentAmt		varchar(20),
       PaymentStatus		varchar(20),
       Void			float4,
       ViolationCategory	int,
       ViolationAddress		varchar(200),
       MailingAddress		varchar(200),
       LAT			float8,
       LON			float8,
       point			varchar(500),
       address			varchar(100),
       nhood			varchar(100),
       point_geom		geometry
);

-- to get the data:
--   1. download the csv from the coursera webpage or https://data.detroitmi.gov/
--   2. load into python and use basemap package to get wkt (well-known text) for points
--   3. put street number and street name together for address
--   4. create and output corresponding data frame 'violations.csv'
\copy violations(ticketid, ticketnumber, agencyname, violname, violationstreetnumber, violationstreetname, mailingstreetnumber, mailingstreetname, mailingcity, mailingstate, mailingzipcode, nonusaddresscode, country, ticketissueddt, ticketissuedtime, hearingdt, courttime, violationcode, violdescription, disposition, fineamt, adminfee, latefee, statefee, cleanupcost, judgmentamt, paymentstatus, void, violationcategory, violationaddress, mailingaddress, lat, lon, point, address) from 'violations.csv' csv header;

-- create postGIS objects
update violations set point_geom = st_geomfromtext(point);

-- find corresponging neighborhoods
-- first, check containment
update violations set nhood = n.nhood from neighborhoods as n where st_contains(n.poly_geom, point_geom);

-- then find shortest distances for violations not already given neighborhoods
create table temp (point varchar(500), nhood varchar(100), dist double);
insert into temp select v.point, n.nhood, st_distance(n.poly_geom, v.point_geom) from violations as v, neighborhoods as n where v.nhood is null and not exists (select * from neighborhoods as n2 where st_distance(n2.poly_geom, v.point_geom) < st_distance(n.poly_geom, v.point_geom));

update table violations set nhood = temp.nhood from temp where violations.nhood is null and violations.point = temp.point and temp.dist < 25;

