"""
Sample Lambda function for AWS Free Tier demo
Responds to HTTP requests and S3 events
"""
import json
import os
from datetime import datetime


def handler(event, context):
    """
    Main Lambda handler function
    
    Handles:
    - Direct invocations
    - Function URL (HTTP) requests
    - S3 event notifications
    """
    
    # Determine event type
    event_type = get_event_type(event)
    
    # Process based on event type
    if event_type == 'http':
        return handle_http_request(event, context)
    elif event_type == 's3':
        return handle_s3_event(event, context)
    else:
        return handle_direct_invocation(event, context)


def get_event_type(event):
    """Determine the type of event"""
    if 'requestContext' in event:
        return 'http'
    elif 'Records' in event and event['Records']:
        if 's3' in event['Records'][0]:
            return 's3'
    return 'direct'


def handle_http_request(event, context):
    """Handle HTTP requests from Function URL"""
    
    # Extract request details
    method = event.get('requestContext', {}).get('http', {}).get('method', 'UNKNOWN')
    path = event.get('rawPath', '/')
    
    # Parse body if present
    body = {}
    if 'body' in event and event['body']:
        try:
            body = json.loads(event['body'])
        except json.JSONDecodeError:
            body = {'raw': event['body']}
    
    # Build response
    response_data = {
        'message': 'Hello from AWS Free Tier Lambda!',
        'timestamp': datetime.utcnow().isoformat(),
        'request': {
            'method': method,
            'path': path,
            'body': body
        },
        'environment': {
            'function_name': context.function_name,
            'function_version': context.function_version,
            'memory_limit_mb': context.memory_limit_in_mb,
            'aws_request_id': context.aws_request_id
        },
        'free_tier_info': {
            'monthly_requests': '1,000,000',
            'compute_time_gb_seconds': '400,000',
            'note': 'This function is running within AWS free tier limits!'
        }
    }
    
    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type'
        },
        'body': json.dumps(response_data, indent=2)
    }


def handle_s3_event(event, context):
    """Handle S3 event notifications"""
    
    results = []
    
    for record in event['Records']:
        s3_info = record['s3']
        bucket = s3_info['bucket']['name']
        key = s3_info['object']['key']
        size = s3_info['object']['size']
        
        results.append({
            'bucket': bucket,
            'key': key,
            'size': size,
            'event': record['eventName']
        })
        
        print(f"Processed S3 event: {record['eventName']} - {bucket}/{key} ({size} bytes)")
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'S3 events processed',
            'results': results
        })
    }


def handle_direct_invocation(event, context):
    """Handle direct Lambda invocations"""
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'Direct invocation successful',
            'timestamp': datetime.utcnow().isoformat(),
            'event': event,
            'context': {
                'function_name': context.function_name,
                'function_version': context.function_version,
                'memory_limit_mb': context.memory_limit_in_mb
            }
        })
    }
