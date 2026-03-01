import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    logger.info("Event: %s", json.dumps(event, indent=2))
    detail_type = event.get("detail-type")
    source = event.get("source")
    payload = event.get("detail", {})

    # TODO: persist to S3/DynamoDB, etc.
    # Route by detail-type if needed:
    # if detail_type == "order.created": ...
    if detail_type == "order.created":
        logger.info("Webhook event received: %s", payload)
        logger.info("Headers: %s", payload.get("headers"))
        logger.info("Query: %s", payload.get("query"))
        logger.info("Payload: %s", payload.get("payload"))
        logger.info("Source: %s", source)
        logger.info("All good!")

    return {
        'statusCode': 200,
        "body": json.dumps({"ok": True})
    }
