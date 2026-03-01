import boto3
import json
import base64
import logging
import os

logger = logging.getLogger()
logger.setLevel(logging.INFO)

eb = boto3.client("events")
BUS = os.environ.get("EVENT_BUS_NAME", "default")


def _get_raw_body(event):
    """
    Safely return the raw request body as a UTF-8 string.
    HTTP API (payload v2.0) provides event('body') (string) and isBase64Encoded
    flag.
    """
    body = event.get("body", "")
    if event.get("isBase64Encoded"):
        body = base64.b64decode(body or b"").decode("utf-8", errors="replace")
    return body or ""


def index_handler(event, context):
    """
    Basic webhook receiver and publishes into AWS EventBridge:
      - logs headers, query params, and JSON payload
      - publish to EventBridge (if EVENTBRIDGE_BUS_NAME is set)
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
        query = event.get("queryStringParameters") or {}
        logger.info("Headers: %s", json.dumps(headers, indent=2))
        logger.info("Query: %s", json.dumps(query, indent=2))
        logger.info("Payload: %s", json.dumps(payload, indent=2))

        # Put events in AWS Eventbridge
        eb.put_events(
            Entries=[{
                "EventBusName": BUS,
                "Source": "webhook-handler",
                "DetailType": payload.get("type", "webhook.event"),
                "Detail": json.dumps({
                    "headers": headers,
                    "query": query,
                    "payload": payload
                })
            }]
        )

        return {
            "statusCode": 200,
            "headers": {
                "Content-Type": "application/json"
            },
            "body": json.dumps({
                "message": "Hello from API Gateway, Lambda and EventBridge!",
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
