BEGIN;

-- load into a temp table, then merge into live table
-- Deploy tvd:tvd to pg

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = newtbmap, pg_catalog;


CREATE TEMP TABLE tvdincoming (
    id integer NOT NULL,
    name character varying(64),
    freeway_dir character varying(2),
    lanes integer,
    length numeric,
    cal_pm character varying(12),
    abs_pm double precision,
    latitude numeric,
    longitude numeric,
    last_modified date,
    gid integer,
    geom public.geometry,
    freeway_id integer,
    vdstype character varying(4),
    district integer
);



\copy tvdincoming FROM './sql/tvd.txt'

insert into tvd
select  vv.*
from  tvdincoming vv
left outer join tvd using (id)
where tvd.id is null
;


COMMIT;
