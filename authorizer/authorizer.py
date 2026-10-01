import hmac
import logging
import os

import boto3

logger = logging.getLogger()
logger.setLevel("INFO")

ssm = boto3.client("ssm")
_api_key = None


def get_api_key():
    # Busca a chave no SSM so na primeira execucao e guarda em memoria
    global _api_key
    if _api_key is None:
        response = ssm.get_parameter(
            Name=os.environ["API_KEY_PARAMETER"],
            WithDecryption=True,
        )
        _api_key = response["Parameter"]["Value"]
    return _api_key


def lambda_handler(event, context):
    headers = event.get("headers") or {}
    received_key = headers.get("x-api-key", "")

    # compare_digest evita ataques que tentam adivinhar a chave pelo tempo de resposta
    authorized = hmac.compare_digest(received_key.encode(), get_api_key().encode())

    logger.info("Authorization %s | route: %s",
                "granted" if authorized else "denied",
                event.get("routeKey"))

    return {"isAuthorized": authorized}
