#!/usr/bin/env sh

omt-asset build --content-directory Content --temp-directory Temp --data-directory Data --archive App/data/base.omar --paklist Data/data.paklist
omt-packer pack --basepath Data --output App/data/base.omar --paklist Data/data.paklist
