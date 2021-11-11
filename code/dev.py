import sys
import os
import json
import pprint

#--- main lambda handler            
def handler(event, context):
          
    return {
        "statusCode": 200,
        "body": "waf poc lambda function",
        "headers": {
            "Content-Type": "application/json"
        }
    }
