import boto3
import hashlib
import json
import logging
import os
from urllib import request


####### Get values from environment variables  ######
IPV4_SET_NAME=os.environ['IPV4_SET_NAME'].strip()
IPV4_SET_ID=os.environ['IPV4_SET_ID'].strip()
IPV6_SET_NAME=os.environ['IPV6_SET_NAME'].strip()
IPV6_SET_ID=os.environ['IPV6_SET_ID'].strip()

# Set default services if env. variable does not exist or its an empty string
SERVICES = os.getenv( 'SERVICES', 'ROUTE53_HEALTHCHECKS,CLOUDFRONT').split(',')
if SERVICES == ['']: SERVICES = ['ROUTE53_HEALTHCHECKS','CLOUDFRONT']

# Set EC2 region to 'all' if env. variable does not exist or its an empty string
EC2_REGIONS = os.getenv('EC2_REGIONS','all').split(',')
if EC2_REGIONS == ['']: EC2_REGIONS = ['all']

# Set logging level from environment variable
INFO_LOGGING = os.getenv('INFO_LOGGING','false')
if INFO_LOGGING == ['']: INFO_LOGGING = 'false'

#######

def lambda_handler(event, context):

    # Set up logging. Set the level if the handler is already configured.
    if len(logging.getLogger().handlers) > 0:
        logging.getLogger().setLevel(logging.ERROR)
    else:
        logging.basicConfig(level=logging.ERROR)
    
    # Set the environment variable DEBUG to 'true' if you want verbose debug details in CloudWatch Logs.
    if INFO_LOGGING == 'true':
        logging.getLogger().setLevel(logging.INFO)


    # If you want different services, set the SERVICES environment variable
    # It defaults to ROUTE53_HEALTHCHECKS and CLOUDFRONT. Using 'jq' and 'curl' get the list of possible
    # services like this:
    # curl -s 'https://ip-ranges.amazonaws.com/ip-ranges.json' | jq -r '.prefixes[] | .service' ip-ranges.json | sort -u 
   
    message = json.loads(event['Records'][0]['Sns']['Message'])

    # Load the ip ranges from the url
    ip_ranges = json.loads(get_ip_groups_json(message['url'], message['md5']))

    # Extract the service ranges
    ranges = get_ranges_for_service(ip_ranges,SERVICES,EC2_REGIONS)

    # Update the AWS WAF IP sets
    update_waf_ipset(IPV4_SET_NAME,IPV4_SET_ID,ranges['ipv4'])
    update_waf_ipset(IPV6_SET_NAME,IPV6_SET_ID,ranges['ipv6'])

    return ranges
    
def get_ip_groups_json(url, expected_hash):

    logging.debug("Updating from " + url)

    response = request.urlopen(url)
    ip_json = response.read()

    m = hashlib.md5()
    m.update(ip_json)
    hash = m.hexdigest()

    # If the hash provided is 'test-hash', returns the JSON without checking the hash
    if expected_hash == 'test-hash':
        print('Running in test mode')
        return ip_json

    if hash != expected_hash:
        raise Exception('MD5 Mismatch: got ' + hash + ' expected ' + expected_hash)

    return ip_json

def get_ranges_for_service(ranges, services,ec2_regions):
    """Gets IPv4 and IPv6 prefixes from the matching services"""
    service_ranges = {'ipv6':[],'ipv4':[]}
    ec2_regions = strip_list(ec2_regions)
    services = strip_list(services)

    # Loop over the IPv4 prefixes and appends the matching services
    print(f'Searching for {services} IPv4 prefixes')
    for prefix in ranges['prefixes']:

        if prefix['service'] in services and \
            (
                (prefix['service'] != 'EC2') \
                or \
                (prefix['service']=='EC2' and ec2_regions != ['all'] and prefix['region'] in ec2_regions) \
                or \
                (prefix['service']=='EC2' and ec2_regions == ['all'])
            ):

            logging.info((f"Found {prefix['service']} region: {prefix['region']} range: {prefix['ip_prefix']}"))
            service_ranges['ipv4'].append(prefix['ip_prefix'])

    # Loop over the IPv6 prefixes and appends the matching services
    print(f'Searching for {services} IPv6 prefixes')
    for ipv6_prefix in ranges['ipv6_prefixes']:

        if ipv6_prefix['service'] in services and \
            (
                (ipv6_prefix['service'] != 'EC2') \
                or \
                (ipv6_prefix['service']=='EC2' and ec2_regions != ['all'] and ipv6_prefix['region'] in ec2_regions) \
                or \
                (ipv6_prefix['service']=='EC2' and ec2_regions == ['all'])
            ):

            logging.info((f"Found {ipv6_prefix['service']} region: {ipv6_prefix['region']} ipv6 range: {ipv6_prefix['ipv6_prefix']}"))
            service_ranges['ipv6'].append(ipv6_prefix['ipv6_prefix'])

    return service_ranges

def update_waf_ipset(ipset_name,ipset_id,address_list):
    """Updates the AWS WAF IP set"""
    waf_client = boto3.client('wafv2')

    lock_token = get_ipset_lock_token(waf_client,ipset_name,ipset_id)

    logging.info(f'Got LockToken for AWS WAF IP Set "{ipset_name}": {lock_token}')

    waf_client.update_ip_set(
        Name=ipset_name,
        Scope='REGIONAL',
        Id=ipset_id,
        Addresses=address_list,
        LockToken=lock_token
    )

    print(f'Updated IPSet "{ipset_name}" with {len(address_list)} CIDRs')

def get_ipset_lock_token(client,ipset_name,ipset_id):
    """Returns the AWS WAF IP set lock token"""
    ip_set = client.get_ip_set(
        Name=ipset_name,
        Scope='REGIONAL',
        Id=ipset_id)
    
    return ip_set['LockToken']

def strip_list(list):
    """Strips individual elements of the strings"""
    return [item.strip() for item in list]