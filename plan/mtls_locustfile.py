from locust import HttpUser, task, between
import ssl
import requests
import json

class TLSAdapter(requests.adapters.HTTPAdapter):
    def init_poolmanager(self, *args, **kwargs):
        ctx = ssl.create_default_context()
        ctx.set_ciphers('DEFAULT@SECLEVEL=1')
        ctx.load_default_certs()
        ctx.load_verify_locations("/root/##SERVER_CERT##")
        ctx.load_cert_chain(certfile="/root/##CLIENT_CERT##", keyfile="/root/##CLIENT_KEY##")
        kwargs['ssl_context'] = ctx
        return super(TLSAdapter, self).init_poolmanager(*args, **kwargs)

url = ""

payload = json.dumps({})
headers = {
  'Pragma': 'akamai-x-ew-debug, akamai-x-cache-on, akamai-x-cache-remote-on, akamai-x-check-cacheable, akamai-x-get-cache-key, akamai-x-get-true-cache-key, akamai-x-serial-no, akamai-x-get-request-id, akamai-x-get-client-ip, akamai-x-im-trace, X-Akamai-Scan-status, x-akamai-edgescape',
  'User-Agent': 'Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/113.0.0.0 Safari/537.36',
  'Content-Type': 'application/json'
}

class AddPhotoUser(HttpUser):
    wait_time = between(5, 10)

    @task
    def add_photo(self):
        session = self.client
        session.mount('https://', TLSAdapter())

        session.request(
          "POST", 
          url, 
          headers=headers, 
          data=payload
        )

