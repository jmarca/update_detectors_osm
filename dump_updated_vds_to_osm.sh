#!/bin/sh

set -x

# expect to call this from npm

src_db=${npm_package_config_src_db:-"spatialvds"}
src_host=${npm_package_config_src_host:-"127.0.0.1"}
src_port=${npm_package_config_src_port:-5432}
src_user=${npm_package_config_src_user:-""}

tgt_db=${npm_package_config_tgt_db:-"osm"}
tgt_host=${npm_package_config_tgt_host:-"127.0.0.1"}
tgt_port=${npm_package_config_tgt_port:-5432}
tgt_user=${npm_package_config_tgt_user:-""}


# update tvd and twim on src with any new data by refreshing materialized view

psql -U $src_user -h $src_host -p $src_port -d $src_db -c 'REFRESH MATERIALIZED VIEW newtbmap.tvd;'
psql -U $src_user -h $src_host -p $src_port -d $src_db -c 'REFRESH MATERIALIZED VIEW newtbmap.twim;'


# Then dump both views for copying

psql -U $src_user  -h $src_host -p $src_port -d $src_db  -c '\copy (select * from newtbmap.tvd)  to  sql/tvd.txt'

psql -U $src_user  -h $src_host -p $src_port -d $src_db  -c '\copy (select * from newtbmap.twim)  to  sql/twim.txt'


# load tvd
psql -U $tgt_user  -h $tgt_host -p $tgt_port -d $tgt_db -f sql/load_tvd.sql -o load_tvd.out


# load twim
psql -U $tgt_user  -h $tgt_host -p $tgt_port -d $tgt_db -f sql/load_twim.sql -o load_twim.out
