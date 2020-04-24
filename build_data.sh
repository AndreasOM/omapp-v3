#!/usr/bin/env sh
DATA=Data
TEMP=Temp

if [ ! -d ${DATA} ]; then
	mkdir -p ${DATA};
fi
if [ ! -d ${TEMP} ]; then
	mkdir -p ${TEMP};
fi

omt-asset build --content-directory Content --temp-directory ${TEMP} --data-directory ${DATA} --archive App/data/base.omar --paklist ${DATA}/data.paklist

# :HACK: since omt-asset doesn't write the paklist yet
cd ${DATA}
ls -1 |grep -v data.paklist >data.paklist
cd -

omt-packer pack --basepath ${DATA} --output App/data/base.omar --paklist ${DATA}/data.paklist
