import base64
import json
import logging
import os
import uuid
from decimal import Decimal

import boto3
from botocore.exceptions import ClientError

logger = logging.getLogger()
logger.setLevel(os.environ.get("LOG_LEVEL", "INFO"))

# Nome da tabela vem da variável de ambiente (definida pelo Terraform)
TABLE_NAME = os.environ["TABLE_NAME"]
table = boto3.resource("dynamodb").Table(TABLE_NAME)


class DecimalEncoder(json.JSONEncoder):
    """DynamoDB devolve números como Decimal, que o json não sabe serializar."""

    def default(self, obj):
        if isinstance(obj, Decimal):
            return int(obj) if obj % 1 == 0 else float(obj)
        return super().default(obj)


def response(status_code, body):
    return {
        "statusCode": status_code,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(body, cls=DecimalEncoder),
    }


def parse_body(event):
    body = event.get("body") or ""
    if event.get("isBase64Encoded"):
        body = base64.b64decode(body).decode("utf-8")
    # parse_float=Decimal porque o boto3 não aceita float no DynamoDB
    return json.loads(body, parse_float=Decimal) if body else {}


# ---------- Operações ----------

def create_product(event):
    data = parse_body(event)
    name = data.get("name")
    price = data.get("price")

    if not isinstance(name, str) or not name.strip():
        logger.warning("Validation failed: invalid name")
        return response(400, {"error": "'name' é obrigatório e deve ser texto"})
    if isinstance(price, bool) or not isinstance(price, (int, Decimal)) or price < 0:
        logger.warning("Validation failed: invalid price")
        return response(400, {"error": "'price' é obrigatório e deve ser um número >= 0"})

    item = {"id": str(uuid.uuid4()), "name": name.strip(), "price": price}
    logger.info("Creating product | id=%s", item["id"])
    table.put_item(Item=item)
    logger.info("Product created successfully | id=%s", item["id"])
    return response(201, item)


def list_products(event):
    logger.info("Listing products")
    items = []
    scan_kwargs = {}
    # Scan devolve no máximo 1 MB por chamada, então paginamos
    while True:
        result = table.scan(**scan_kwargs)
        items.extend(result.get("Items", []))
        if "LastEvaluatedKey" not in result:
            break
        scan_kwargs["ExclusiveStartKey"] = result["LastEvaluatedKey"]
    logger.info("Products found: %d", len(items))
    return response(200, items)


def get_product(event):
    product_id = event["pathParameters"]["id"]
    logger.info("Getting product | id=%s", product_id)
    result = table.get_item(Key={"id": product_id})
    if "Item" not in result:
        logger.info("Product not found | id=%s", product_id)
        return response(404, {"error": "Produto não encontrado"})
    return response(200, result["Item"])


def delete_product(event):
    product_id = event["pathParameters"]["id"]
    logger.info("Deleting product | id=%s", product_id)
    result = table.delete_item(Key={"id": product_id}, ReturnValues="ALL_OLD")
    if "Attributes" not in result:
        logger.info("Product not found for deletion | id=%s", product_id)
        return response(404, {"error": "Produto não encontrado"})
    logger.info("Product deleted successfully | id=%s", product_id)
    return response(200, {"message": "Produto excluído", "id": product_id})


ROUTES = {
    "POST /products": create_product,
    "GET /products": list_products,
    "GET /products/{id}": get_product,
    "DELETE /products/{id}": delete_product,
}


def lambda_handler(event, context):
    route_key = event.get("routeKey", "")
    method = event.get("requestContext", {}).get("http", {}).get("method")
    logger.info("Request received | HTTP method: %s | route: %s | request_id: %s",
                method, route_key, context.aws_request_id)

    handler = ROUTES.get(route_key)
    if handler is None:
        logger.warning("Route not found: %s", route_key)
        return response(404, {"error": "Rota não encontrada"})

    try:
        return handler(event)
    except json.JSONDecodeError:
        logger.warning("Invalid JSON body")
        return response(400, {"error": "JSON inválido"})
    except ClientError:
        logger.exception("DynamoDB error")
        return response(500, {"error": "Erro interno"})
    except Exception:
        logger.exception("Unexpected error")
        return response(500, {"error": "Erro interno"})