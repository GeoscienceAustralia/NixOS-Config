#!/usr/bin/env nix-shell
#!nix-shell -p python3 -p python3Packages.requests2 -p python3Packages.semantic-version -i python3

import os
import requests
import semantic_version
import sys

api_url = 'https://atlas.hashicorp.com/api/v1'
atlas_token = os.environ['ATLAS_TOKEN']
request_headers = {'X-Atlas-Token': atlas_token}

def get(url):
    response = requests.get(url, headers=request_headers)
    if response.status_code == requests.codes.ok:
        return response.json()
    elif response.status_code == requests.codes.not_found:
        return None
    else:
        response.raise_for_status()

def post(url, **kwargs):
    response = requests.post(url, headers=request_headers, **kwargs)
    response.raise_for_status()

def put(url, **kwargs):
    response = requests.put(url, headers=request_headers, **kwargs)
    response.raise_for_status()

def get_current_version(username, box):
    response = get(box_url(username, box))
    if response is not None:
        current_version = response['current_version']
        if current_version is not None:
            return semantic_version.Version(current_version['version'])
    return None

def create_new_version(username, box, version):
    post(box_versions_url(username, box), data='version[version]=' + str(version))

def create_new_provider(username, box, version, provider):
    post(box_providers_url(username, box, version), data='provider[name]=' + provider)

def bump_version(username, box):
    current_version = get_current_version(username, box)
    next_version = semantic_version.Version('1.0.0') if current_version is None else current_version.next_major()
    create_new_version(username, box, next_version)
    return (next_version, box_url(username, box, version=next_version))

def upload_new_box(username, box, box_file):
    version, box_url = bump_version(username, box);
    create_new_provider(username, box, version, 'virtualbox')
    upload_url = get(box_url + '/provider/virtualbox' + '/upload')['upload_path']
    print(upload_url)
    put(upload_url, data=open(box_file, 'rb'))
    put(box_url + '/release')

def box_url(username, box, **kwargs):
    url = '/box/' + username + '/' + box;
    version = kwargs.get('version')
    provider = kwargs.get('provider')
    if version is not None:
        url = url + '/version/' + str(version)
    if provider is not None:
        url = url + '/provider/' + provider
    return api_url + url

def box_versions_url(username, box):
    return box_url(username, box) + '/versions'

def box_providers_url(username, box, version):
    return box_url(username, box, version=version) + '/providers/'

def print_usage():
    print("upload-box-to-atlas.py <user> <box> <file.box>")

def main():
    if len(sys.argv) != 4:
        print_usage()
        exit(1)
    else:
        username = sys.argv[1]
        box = sys.argv[2]
        box_file = sys.argv[3]
        upload_new_box(username, box, box_file)

if __name__ == "__main__":
    main()



