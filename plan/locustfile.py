import time
from locust import HttpUser, task, between


class Quickstart(HttpUser):
    wait_time = between(1, 5)

    @task
    def google(self):
        self.client.request_name = "google"
        self.client.get("https://google.com/")