#!/usr/bin/env zsh

# Copyright (c) 2015 G2, Inc
# Author: Shawn Webb <shawn.webb@g2-inc.com>
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# 1. Redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above
# copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided
# with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
# COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
# ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

function get_topdir() {
    self=${1}
    echo $(realpath $(dirname ${self}))
}

function sanity_check() {
	if [ -z "${STAGEDIR}" ]; then
		echo "[-] Please define STAGEDIR." >&2
		exit 1
	fi

	if [ ! -d ${STAGEDIR} ]; then
		mkdir -p ${STAGEDIR}
		if [ ! ${?} -eq 0 ]; then
			echo "[-] ${STAGEDIR} does not exist. Please create." >&2
			exit 1
		fi
	fi
}

function main() {
	set -xe

	TOPDIR=$(get_topdir ${1})
	cd ${TOPDIR}

	source ${TOPDIR}/configs/main.conf
	source ${TOPDIR}/lib/util.zsh
	source ${TOPDIR}/lib/rule_parser.zsh

	sanity_check
	clean_work
	extract_source
	if [ -z "$(which pkg-config)" ]; then
		patch_source
	fi
	create_rule_directories
	parse_rules
	res=${?}
	if [ ! ${res} -eq 0 ]; then
		echo "[-] Could not parse rules. Bailing." >&2
		exit 1
	fi
	run_autotools
	res=${?}
	if [ ! ${res} -eq 0 ]; then
		echo "[-] Could not run autotools" >&2
		exit 1
	fi
	run_configure
	res=${?}
	if [ ! ${res} -eq 0 ]; then
		echo "[-] Could not run configure" >&2
		exit 1
	fi
	run_build
}

main ${0} $*
