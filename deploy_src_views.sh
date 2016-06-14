#!/bin/sh
set -x

src_db=${npm_package_config_src_db:-"spatialvds"}
src_host=${npm_package_config_src_host:-"127.0.0.1"}
src_port=${npm_package_config_src_port:-5432}
src_user=${npm_package_config_src_user:-""}



SQITCH_SRC_DB_URI=${SQITCH_DB_URI:-"db:pg://${src_user}@${src_host}:${src_port}/$src_db"}

cd node_modules/tvd_view/

SQITCH_DB_URI=${SQITCH_SRC_DB_URI} npm run sqitch:deploy
