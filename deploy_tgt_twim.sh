#!/bin/sh


NODE_MODULES=${NODE_MODULES:-~+/node_modules}

echo "$NODE_MODULES"

tgt_db=${npm_package_config_tgt_db:-"osm"}
tgt_host=${npm_package_config_tgt_host:-"127.0.0.1"}
tgt_port=${npm_package_config_tgt_port:-5432}
tgt_user=${npm_package_config_tgt_user:-""}

SQITCH_TGT_DB_URI=${SQITCH_DB_URI:-"db:pg://${tgt_user}@${tgt_host}:${tgt_port}/$tgt_db"}


pushd ${NODE_MODULES}/twim/
SQITCH_DB_URI=${SQITCH_TGT_DB_URI} npm run sqitch:deploy
popd
# pushd ${NODE_MODULES}/tvd/
# SQITCH_DB_URI=${SQITCH_TGT_DB_URI} npm run sqitch:deploy
# popd
