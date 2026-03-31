#!/bin/sh
# checks tls_connection_match_domain=yes creates new connection to the same dst ip:port for another tls domain
#
# Copyright (C) 2026 furmur@pm.me
#
# This file is part of Kamailio, a free SIP server.
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

. include/common
. include/require.sh

CFGFILE=62.cfg
TMPFILE=$(mktemp -t kamailio-test.XXXXXXXXXX)
SIPSAKOPTS="-H localhost -s sip:127.0.0.1:5060 -v"
KAMCMD=../../utils/kamcmd/kamcmd
KAMCMDOPTS="-s unixs:kamailio_ctl"
TLSKEYFILE=kamailio-selfsigned.key
TLSCERTFILE=kamailio-selfsigned.pem

end_test_no_kamailio() {
	rm -f ${TMPFILE} ${TLSKEYFILE} ${TLSCERTFILE}
	exit ${ret}
}

end_test() {
	kill_kamailio
	end_test_no_kamailio
}

assert_tls_connections_count() {
	# run tls.info and extract opened_connections value
	tls_connections_count=$(${KAMCMD} ${KAMCMDOPTS} tls.info | awk '/opened_connections/{ print $2 }')
	ret=$?
	if [ "${ret}" -ne 0 ] ; then
		echo "kamcmd or awk returned ${ret}, aborting"
		end_test
	fi

	if [ ! ${tls_connections_count} -eq "$1" ]; then
		ret=1
		echo "got ${tls_connections_count} tls connections count while expected: $1"
		end_test
	fi
}

if [ ! -x ${KAMCMD} ]; then
	echo "${KAMCMD} not found. not run"
	exit 0
fi

if [ ! -x $MOD_DIR/tls/tls_cert.sh ]; then
	echo "$MOD_DIR/tls/tls_cert.sh not found. not run"
	exit 0
fi

$MOD_DIR/tls/tls_cert.sh -d . > /dev/null
if [ "$?" -ne 0 ] ; then
	echo "failed to generate cert. not run"
	end_test_no_kamailio
fi

if [ ! -f ${TLSKEYFILE} ]; then
	echo "no ${TLSKEYFILE} generated. not run"
	end_test_no_kamailio
fi

if [ ! -f ${TLSCERTFILE} ]; then
	echo "no ${TLSCERTFILE} generated. not run"
	end_test_no_kamailio
fi

if ! (check_sipsak && check_kamailio && check_module "tls"); then
	exit 0
fi

${BIN} -L $MOD_DIR -Y $RUN_DIR -P $PIDFILE -w . -f ${CFGFILE} > /dev/null
ret=$?

sleep 1
if [ "${ret}" -ne 0 ] ; then
	echo "oops"
	end_test
fi

# send 1st request. should go sipsak --udp--> 127.0.0.1:5060 kamailio 127.0.0.1:random --tls domain with server_id:1--> 127.0.0.1:5061 kamailio
sipsak ${SIPSAKOPTS} --headers "X-TLS-Server-ID: 1\n" > ${TMPFILE}
ret=$?
if [ "${ret}" -ne 0 ] ; then
	echo "1st sipsak returned ${ret}, aborting"
	cat ${TMPFILE}
	end_test
fi

# send 2nd request. should go sipsak --udp--> 127.0.0.1:5060 kamailio 127.0.0.1:random --tls domain with server_id:1--> 127.0.0.1:5061 kamailio
# this one is to check if first connection was reused
sipsak ${SIPSAKOPTS} --headers "X-TLS-Server-ID: 1\n" > ${TMPFILE}
ret=$?
if [ "${ret}" -ne 0 ] ; then
	echo "2nd sipsak returned ${ret}, aborting"
	cat ${TMPFILE}
	end_test
fi

# assert first tls connection was reused
assert_tls_connections_count 2

# send 3rd request. should go sipsak --udp--> 127.0.0.1:5060 kamailio 127.0.0.1:random --tls domain with server_id:2--> 127.0.0.1:5061 kamailio
sipsak ${SIPSAKOPTS} --headers "X-TLS-Server-ID: 2\n" > ${TMPFILE}
ret=$?
if [ "${ret}" -ne 0 ] ; then
	echo "3rd sipsak returned ${ret}, aborting"
	cat ${TMPFILE}
	end_test
fi

# the test essence here: we expect 4 tls connections. 2 (client + server) for each TLS client domain
assert_tls_connections_count 4

ret=0
end_test
