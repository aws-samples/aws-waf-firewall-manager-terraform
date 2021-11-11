import base64
import json
import pyasn
from user_agents import parse
from counter_robots import is_machine, is_robot
import boto3
import os
import re
import requests
from requests_aws4auth import AWS4Auth

print('Loading AWS WAF Logs Enrichment function')
asndb = pyasn.pyasn('/opt/ipasn.dat')
ua = {}
s3 = boto3.client('s3')


def getUAInfo(user_agent_string):
    if user_agent_string in ua:
        return ua[user_agent_string]
    else:
        info = {}
        user_agent = parse(user_agent_string)
        browser = {}
        browser['family'] = user_agent.browser.family
        browser['version'] = user_agent.browser.version_string
        info['browser'] = browser
        os = {}
        os['family'] = user_agent.os.family
        os['version'] = user_agent.os.version_string
        info['os'] = os
        device = {}
        device['family'] = user_agent.device.family
        device['brand'] = user_agent.device.brand
        device['model'] = user_agent.device.model
        info['device'] = device
        ua[user_agent_string] = info
        return info

def enrich(payload):
    #output = []
    #payload = base64.b64decode(record['data'])
    log = json.loads(payload)
    # Flattens the header fields
    flatheaders = {}
    for item in log['httpRequest']['headers']:
        flatheaders[item['name'].lower()] = item['value']
    del(log['httpRequest']['headers'])
    log['httpRequest']['headers'] = flatheaders
    # Parse and add webacl information
    webacl_info = log['webaclId'].split(":")
    log['webaclRegion'] = webacl_info[3]
    log['webaclAccount'] = webacl_info[4]
    webacl_name = webacl_info[5].split("/")
    log['webaclName'] = webacl_name[2]

    # Adds  ASN number
    ip = ""
    if 'x-forwarded-for' in log['httpRequest']['headers']:
        ip = log['httpRequest']['headers']['x-forwarded-for']
        # XFF header may come with more than one IP address, we'll use the first appearance in the list to report the ASN
        if len(ip) > 15:
            print(f'[WARNING] XFF with multiple IP addresses: {ip}; considering last')
            ip = ip.split(', ')[-1]
    else:
        ip = log['httpRequest']['clientIp']
    try:
        log['httpRequest']['asn'] = asndb.lookup(ip)[0]
    except Exception as e:
        log['httpRequest']['asn'] = 'unknown'
        print(f'[ERROR] Got error {e}, while processing ASN for IP {ip}')
        print(e)
    if 'user-agent' in log['httpRequest']['headers']:
        user_agent_string = log['httpRequest']['headers']['user-agent']
        # Adds user-agent information
        ua_info = getUAInfo(user_agent_string)
        log['httpRequest']['browser'] = ua_info['browser']
        log['httpRequest']['os'] = ua_info['os']
        log['httpRequest']['device'] = ua_info['device']
        # Adds robot information
        device_type = ''
        if is_machine(user_agent_string):
            device_type = 'machine'
        elif is_robot(user_agent_string):
            device_type = 'robot'
        else:
            device_type = 'other'
        log['httpRequest']['deviceType'] = device_type
    #payload_output = json.dumps(log)
    #output_record = {
    #    'recordId': record['recordId'],
    #    'result': 'Ok',
    #    'data': base64.b64encode(payload.encode('utf-8') + b'\n').decode('utf-8')
    #}
    #output.append(output_record)
    print("Successfully processed record")
    return log

def lambda_handler(event, context):
    print(event)
    index = os.environ['index'] + "-" +  (event['Records'][0]['eventTime'].split("T"))[0]
    region = event['Records'][0]['awsRegion']
    print(region)
    service = 'es'
    credentials = boto3.Session().get_credentials()
    awsauth = AWS4Auth(credentials.access_key, credentials.secret_key, region, service, session_token=credentials.token)
    headers = { "Content-Type": "application/json" }
    endpoint_name=os.environ['DOMAINNAME']
    type = '_doc'
    url = "https://" + endpoint_name + '/' + index + '/' + type
    print(url)


    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']
        try:
            obj = s3.get_object(Bucket=bucket, Key=key)
            body = obj['Body'].read()
            lines = body.splitlines()
            print(body)
            
            for line in lines:
                
                line = line.decode("utf-8")
                print(line)
                enrich_line = enrich(line)
                print(enrich_line)
                r = requests.post(url, auth=awsauth, json=enrich_line, headers=headers)
                print(r)
            

            
        except Exception as e:
            print(e)
            print('Error getting object {} from bucket {}. Make sure they exist and your bucket is in the same region as this function.'.format(key, bucket))
            raise e
