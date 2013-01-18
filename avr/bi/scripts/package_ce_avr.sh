#!/usr/bin/bash

# Should this include trisano.jar, authentication stuff?

rm -rf tmp
mkdir -p tmp/warehouse/build_metadata
cp warehouse_init.sql etl.sh dw.sql dw.png ../schema/TriSano.OLAP.xml tmp/warehouse
pushd build_metadata
cp build_metadata.sh build_metadata.rb build_metadata_schema.sql ../tmp/warehouse/build_metadata
popd
pushd tmp
tar -czf trisano-dw.tar.gz warehouse
mv trisano-dw.tar.gz ..
popd
rm -rf tmp
