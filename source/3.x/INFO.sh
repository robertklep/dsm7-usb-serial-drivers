#!/bin/bash
# Copyright (c) 2000-2017 Synology Inc. All rights reserved.

source /pkgscripts-ng/include/pkg_util.sh

package="ch341"
version="1.0.0-0001"
displayname="ch341"
maintainer="robert@klep.name"
arch="$(pkg_get_platform)"
description="ch341 kernel module for Synology DSM 7"
[ "$(caller)" != "0 NULL" ] && return 0
pkg_dump_info
