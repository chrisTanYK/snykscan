def lambda_handler(event, context):
    print("Hello, Rger!")
    return {
        'statusCode': 200,
        'body': 'Hello from Lambda!'
    }