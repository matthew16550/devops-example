#! /usr/bin/env python3

# Idempotently configure Kong via its admin api
# An alternative is to try https://github.com/kevholditch/terraform-provider-kong

import json
import os
import sys
import time
import urllib.error
import urllib.parse
import urllib.request

admin_url = os.environ['ADMIN_URL']
service_discovery_namespace = os.environ['SERVICE_DISCOVERY_NAMESPACE']


def http_request(method, url, data):
    try:
        body = json.dumps(data, indent=2, sort_keys=True)
        req = urllib.request.Request(url,
                                     data=body.encode('ascii'),
                                     headers={'content-type': 'application/json'},
                                     method=method)
        print(f"\n{method} {url}\n{body}")
        res = urllib.request.urlopen(req)
        print(f"Response={res.code}")
        return json.loads(read_body(res))
    except urllib.error.HTTPError as e:
        print(f"{e.code} {read_body(e)}")
        sys.exit(1)


def read_body(res):
    return res.read().decode(res.info().get_content_charset())


def wait_for_url(url):
    while True:
        try:
            print(f"Waiting for {url} ...")
            res = urllib.request.urlopen(url, timeout=10)
            print(res.code)
            break
        except urllib.error.HTTPError as e:
            print(e.code)
        except urllib.error.URLError as e:
            print(e.reason)

            time.sleep(5)


wait_for_url(admin_url)

admin_service_id = http_request('PUT', f"{admin_url}/services/admin-api", {
    'host': 'localhost',
    'port': 8001
})['id']

http_request('PUT', f"{admin_url}/routes/admin-api-route", {
    'paths': ['/admin-api'],
    'service': {'id': admin_service_id},
})

hello_service_id = http_request('PUT', f"{admin_url}/services/hello-service", {
    'host': f"hello.{service_discovery_namespace}"
})['id']

http_request('PUT', f"{admin_url}/routes/hello-route", {
    'paths': ['/hello'],
    'service': {'id': hello_service_id},
})
