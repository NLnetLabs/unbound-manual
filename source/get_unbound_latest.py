import requests
import tarfile
import os.path
from os import path

latest_str = "unbound-latest.tar.gz"

url = "https://nlnetlabs.nl/downloads/unbound/" + latest_str

if path.exists("latest_str"):
	exit()

r = requests.get(url, allow_redirects=True)

open(latest_str, 'wb').write(r.content)

tar = tarfile.open(latest_str, "r:gz")
tar.extractall()
tar.close()
