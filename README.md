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
