/*
 * Copyright 2020 The OpenSSL Project Authors. All Rights Reserved.
 *
 * Licensed under the Apache License 2.0 (the "License").  You may not use
 * this file except in compliance with the License.  You can obtain a copy
 * in the file LICENSE in the source distribution or at
 * https://www.openssl.org/source/license.html
 */

#include <openssl/core_names.h>
#include "internal/ffc.h"
#include "internal/sizes.h"

/*
 * The intention with the "backend" source file is to offer backend support
 * for legacy backends (EVP_PKEY_ASN1_METHOD and EVP_PKEY_METHOD) and provider
 * implementations alike.
 */

int ffc_params_fromdata(FFC_PARAMS *ffc, const OSSL_PARAM params[])
{
    const OSSL_PARAM *prm;
    const OSSL_PARAM *param_p, *param_q, *param_g;
    BIGNUM *p = NULL, *q = NULL, *g = NULL, *j = NULL;
#if 0
    char group_name[OSSL_MAX_NAME_SIZE];
    char *str = group_name;
#endif
    int i;

    if (ffc == NULL)
        return 0;

/* TODO(3.0) Add for DH PR */
#if 0
    prm  = OSSL_PARAM_locate_const(params, OSSL_PKEY_PARAM_FFC_GROUP);
    if (prm != NULL) {
        if (!OSSL_PARAM_get_utf8_string(prm, &str, sizeof(group_name)))
            goto err;
        if (!ffc_set_group_pqg(ffc, group_name))
            goto err;
    }
#endif
    param_p = OSSL_PARAM_locate_const(params, OSSL_PKEY_PARAM_FFC_P);
    param_g = OSSL_PARAM_locate_const(params, OSSL_PKEY_PARAM_FFC_G);
    param_q = OSSL_PARAM_locate_const(params, OSSL_PKEY_PARAM_FFC_Q);

    if ((param_p != NULL && !OSSL_PARAM_get_BN(param_p, &p))
        || (param_q != NULL && !OSSL_PARAM_get_BN(param_q, &q))
        || (param_g != NULL && !OSSL_PARAM_get_BN(param_g, &g)))
        goto err;

    prm = OSSL_PARAM_locate_const(params, OSSL_PKEY_PARAM_FFC_GINDEX);
    if (prm != NULL) {
        if (!OSSL_PARAM_get_int(prm, &i))
            goto err;
        ffc->gindex =  i;
    }
    prm = OSSL_PARAM_locate_const(params, OSSL_PKEY_PARAM_FFC_PCOUNTER);
    if (prm != NULL) {
        if (!OSSL_PARAM_get_int(prm, &i))
            goto err;
        ffc->pcounter = i;
    }
    prm = OSSL_PARAM_locate_const(params, OSSL_PKEY_PARAM_FFC_COFACTOR);
    if (prm != NULL) {
        if (!OSSL_PARAM_get_BN(prm, &j))
            goto err;
    }
    prm = OSSL_PARAM_locate_const(params, OSSL_PKEY_PARAM_FFC_H);
    if (prm != NULL) {
        if (!OSSL_PARAM_get_int(prm, &i))
            goto err;
        ffc->h =  i;
    }
    prm  = OSSL_PARAM_locate_const(params, OSSL_PKEY_PARAM_FFC_SEED);
    if (prm != NULL) {
        if (prm->data_type != OSSL_PARAM_OCTET_STRING)
            goto err;
        if (!ffc_params_set_seed(ffc, prm->data, prm->data_size))
            goto err;
    }
    ffc_params_set0_pqg(ffc, p, q, g);
    ffc_params_set0_j(ffc, j);
    return 1;

 err:
    BN_free(j);
    BN_free(p);
    BN_free(q);
    BN_free(g);
    return 0;
}