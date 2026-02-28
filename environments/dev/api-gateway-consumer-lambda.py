import json
import base64
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def _get_raw_body(event):
    """
    Safely return the raw request body as a UTF-8 string.
    HTTP API (payload v2.0) provides event('body') (string) and isBase64Encoded
    flag.
    """
    body = event.get('body', '')
    if event.get('isBase64Encoded'):
        body = base64.b64decode(body or b"").decode('utf-8', errors="replace")
    return body or ""


def lambda_handler(event, context):
    """
    Basic webhook receiver:
      - logs headers, query params, and JSON payload
      - returns 200 with a small JSON response
    """
    try:
        raw_body = _get_raw_body(event)

        # Parse JSON body (if emtpy, use {})
        try:
            payload = json.loads(raw_body) if raw_body else {}
        except json.JSONDecodeError as e:
            logger.warning(f"Invalid JSON in request body: {e}")
            return {
                "statusCode": 400,
                "headers": {
                    "Content-Type": "application/json"
                },
                "body": json.dumps({
                    "ok": False, "error": "Invalid JSON in request body"
                })
            }

        # Log context for debugging
        headers = event.get("headers") or {}
        query = event.get("queryStirng Parameters") or {}
        logger.info("Headers: %s", json.dumps(headers, indent=2))
        logger.info("Query: %s", json.dumps(query, indent=2))
        logger.info("Payload: %s", json.dumps(payload, indent=2))

        # TODO: your business logic here
        # e.g. if payload.get("type") == "order.created": ...

        return {
            "statusCode": 200,
            "headers": {
                "Content-Type": "application/json"
            },
            "body": json.dumps({
                "message": "Hello from API Gateway & Lambda!",
                "ok": True,
                "received": True
            })
        }
    except Exception:
        logger.exception("Unhandled exception")
        return {
            "statusCode": 500,
            "headers": {
                "Content-Type": "application/json"
            },
            "body": json.dumps({
                "ok": False, "error": "Internal server error"
            })
        }
