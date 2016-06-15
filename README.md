# update detectors in OSM

The detector metadata is stored directly in the spatialvds database.
The details of each detector need to be copied into the OSM database
in order to generate the matching line segments.

This repository holds code to copy the VDS and WIM detector metadata
from the spatialvds database to the OSM database.

Edit the package.json file to include the correct names for the
spatialvds and osm database.  The database names, hosts, ports, and
usernames should be specified.  The user name is the most important of
these, as it has no default value.

# npm is *not* slicing the bread

While I have high hopes for the future, at this time it is not
possible to do everything by a simple `npm install` or similar.
Instead, npm install will download all of the dependencies, but will
not run anything.

At the time of this writing, running `npm install` will create the
following directory tree under the top level `node_modules` directory:


```
node_modules/
├── calvad_db_geoextensions
│   ├── ...
├── calvad_detectors_schema
│   ├── ...
├── tvd
│   ├── ...
├── tvd_view
│   ├── ...
└── twim
    └── ...
```

Each of the above directories houses a sqitch package that must be
deployed to the source and target database prior to doing anything
with this package.

Here is how to get them to install.

# Source and target database URIs

The first step is to set up source and target database URIs.  In
trying to get npm to do the dirty work, I came up with some code that
can be used as a model.  For example:

```

tgt_db=${npm_package_config_tgt_db:-"osm"}
tgt_host=${npm_package_config_tgt_host:-"127.0.0.1"}
tgt_port=${npm_package_config_tgt_port:-5432}
tgt_user=${npm_package_config_tgt_user:-""}

SQITCH_DB_URI="db:pg://${tgt_user}@${tgt_host}:${tgt_port}/$tgt_db"
```

The general pattern is given on the source website at
[https://github.com/theory/uri-db/](https://github.com/theory/uri-db/).

Set up one URI for the OSM database, and one for the spatialvds
database. For example, if the user is the same on both, host is the
machine you are on, and the database port is the standard 5432, you
might have:

```
export SQITCH_SRC_DB_URI="db:pg://dbuser@127.0.0.1/spatialvds"
export SQITCH_TGT_DB_URI="db:pg://dbuser@127.0.0.1/osm"
```



# Geoextensions

Both the target and the source database need to have geoextensions
deployed.  They may already be there, and you might have the same
thing in place already without needing to actually deploy.

Change into the calvad_db_geoextensions directory under node_modules

You can look inside of the "deploy" directory to see what this package
does.

To deploy it, run sqitch deploy:


```
cd node_modules/calvad_db_geoextensions
sqitch deploy ${SQITCH_SRC_DB_URI}
sqitch deploy ${SQITCH_TGT_DB_URI}
```

If either of these commands give an error that looks like it is saying
that the database already has the extensions, then run it with the
log-only flag.  For example:

```
sqitch deploy --log-only ${SQITCH_SRC_DB_URI}
```


# calvad_detectors_schema

The detectors schema package is handled in exactly the same way as the
geoextensions package.

Change into the directory and run the sqitch deploy script.



```
cd node_modules/calvad_detectors_schema
sqitch deploy ${SQITCH_SRC_DB_URI}
sqitch deploy ${SQITCH_TGT_DB_URI}
```

If there is an error that looks like the schema already exists, then
re-run the script with the --log-only flag.


# tvd

This package and twim actually do stuff.  You should *not* run them on
the spatialvds database, but rather only on the target OSM database.
They create a target table, and then populate it with data.  Again,
you can look at the scripts inside of the `deploy` directory to see
what they do.

```
cd node_modules/tvd
sqitch deploy ${SQITCH_TGT_DB_URI}
```

Again, be sure that the `TGT` URI actually points to the target OSM
database.  You do not what to run this on the spatialvds database.  We
use the tvd_view for that operation.

There should not be an error, but if there is and if it says the table
already exists, it is safe to run this with the --log-only flag.



# twim

The instructions for twim are identical for tvd, above.  Only the
directory changes.


```
cd node_modules/twim
sqitch deploy ${SQITCH_TGT_DB_URI}
```



# tvd_view

This package is supposed to be deployed to spatialvds.  It sets up a
view that pulls together and "denormalizes" the metadata about each
VDS detector and WIM site.

Note that the database this package is deployed to is the `SRC`
database.  At the time of this writing, that database is called
spatialvds.


```
cd node_modules/tvd_view
sqitch deploy ${SQITCH_SRC_DB_URI}
```

Again, there should not be an error, but if there is, you have to do
some work.

This package creates a materialized view.  Older versions of
spatialvds had a straight table that performed the same function, that
was periodically updated by dropping the table and re-running a
`SELECT INTO` statement.

To get rid of the target table if it exists, do:

```
drop table newtbmap.tvd cascade;
```

This may also drop other dependent views.  These views are historical
and not really used anymore, but in any event, the code to rebuild the
views is kept along with the code that uses it, so if it becomes an
issue, it should be clear how to rebuild the view.

After dropping any table that might be in the way, the deploy should
progress cleanly.

Do NOT run this with a --log-only option unless you are sure that the
materialized view is already in place.
