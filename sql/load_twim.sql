BEGIN;

-- load into a temp table, then merge into live table
-- Deploy tvd:tvd to pg

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = newtbmap, pg_catalog;


CREATE TEMP TABLE twimincoming (
    site_no integer NOT NULL,
    loc character varying(64),
    wim_type character varying(64),
    cal_pm character varying(12),
    latitude numeric,
    longitude numeric,
    last_modified date,
    freeway_id integer NOT NULL,
    direction character varying(1) NOT NULL,
    geom public.geometry
);

\copy twimincoming FROM './sql/twim.txt'

insert into newtbmap.twim
select  i.*
from  twimincoming i
left outer join twim  USING (site_no)
where twim.site_no is null
;


COMMIT;
