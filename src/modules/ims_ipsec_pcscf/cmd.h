/*
 * $Id$
 *
 * Copyright (C) 2012 Smile Communications, jason.penton@smilecoms.com
 * Copyright (C) 2012 Smile Communications, richard.good@smilecoms.com

 *
 * The initial version of this code was written by Dragos Vingarzan
 * (dragos(dot)vingarzan(at)fokus(dot)fraunhofer(dot)de and the
 * Fraunhofer FOKUS Institute. It was and still is maintained in a separate
 * branch of the original SER. We are therefore migrating it to
 * Kamailio/SR and look forward to maintaining it from here on out.
 * 2011/2012 Smile Communications, Pty. Ltd.
 * ported/maintained/improved by
 * Jason Penton (jason(dot)penton(at)smilecoms.com and
 * Richard Good (richard(dot)good(at)smilecoms.com) as part of an
 * effort to add full IMS support to Kamailio/SR using a new and
 * improved architecture
 *
 * NB: A lot of this code was originally part of OpenIMSCore,
 * FhG Fokus.
 * Copyright (C) 2004-2006 FhG Fokus
 * Thanks for great work! This is an effort to
 * break apart the various CSCF functions into logically separate
 * components. We hope this will drive wider use. We also feel
 * that in this way the architecture is more complete and thereby easier
 * to manage in the Kamailio/SR environment
 *
 * This file is part of Kamailio, a free SIP server.
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 *
 * Kamailio is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version
 *
 * Kamailio is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 *
 */

#ifndef IPSEC_CMD_H
#define IPSEC_CMD_H

typedef void (*contact_expired_t)(pcontact_t *c, int type, void *param);
typedef int (*reconfig_tunnels_t)();

/*! ipsec pcscf API export structure */
typedef struct ipsec_pcscf_api
{
	contact_expired_t ipsec_on_expire;
	reconfig_tunnels_t ipsec_reconfig;
} ipsec_pcscf_api_t;

/*! ipsec pcscf API export bind function */
typedef int (*bind_ipsec_pcscf_t)(ipsec_pcscf_api_t *api);

struct sip_msg;
struct udomain_t;

int ipsec_create(struct sip_msg *m, udomain_t *d, int _cflags);
int ipsec_forward(struct sip_msg *m, udomain_t *d, int _cflags);
int ipsec_destroy(struct sip_msg *m, udomain_t *d, str *uri);
int ipsec_cleanall();
int ipsec_reconfig();
void ipsec_on_expire(pcontact_t *c, int type, void *param);
int ipsec_destroy_by_contact(
		udomain_t *_d, str *uri, str *received_host, int received_port);

#endif /* IPSEC_CMD_H */
