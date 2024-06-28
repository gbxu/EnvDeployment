import requests
import subprocess
import random
import time
import re
import datetime
import logging
from requests.adapters import HTTPAdapter
from requests.packages.urllib3.util.retry import Retry

global_user_agents = [
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3",
  "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Safari/605.1.15",
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
  "Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1",
  "Mozilla/5.0 (iPad; CPU OS 11_0 like Mac OS X) AppleWebKit/604.1.34 (KHTML, like Gecko) Version/11.0 Mobile/15A5341f Safari/604.1",
  "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3) AppleWebKit/537.75.14 (KHTML, like Gecko) Version/7.0.3 Safari/7046A194A",
  "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36",
  "Mozilla/5.0 (Linux; Android 10; SM-G975F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.92 Mobile Safari/537.36",
  "Mozilla/5.0 (Linux; Android 9; SM-N960F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.111 Mobile Safari/537.36",
  "Mozilla/5.0 (Linux; U; Android 4.4; en-us; Nexus 5 Build/KRT16M) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.4 Mobile Safari/537.36",
  "Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; AS; rv:11.0) like Gecko",
  "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:52.0) Gecko/20100101 Firefox/52.0",
  "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.1 Safari/605.1.15",
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:68.0) Gecko/20100101 Firefox/68.0"
]

global_proxies = {
  'http': 'http://10.10.1.10:3128',
  'https': 'http://10.10.1.10:1080',
}

class Worker:
    def __init__(self, timeout=30):
        self.session = requests.Session()
        self.user_agent = random.choice(global_user_agents)
        self.timeout = timeout
        self.proxies = global_proxies
        retries = Retry(total=5, backoff_factor=1, status_forcelist=[502, 503, 504])
        self.session.mount('http://', HTTPAdapter(max_retries=retries))
        self.session.mount('https://', HTTPAdapter(max_retries=retries))
        # 配置日志
        logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

    def close(self):
        self.session.close()  # 关闭Session，释放资源

    def _random_delay(self):
        time.sleep(random.uniform(0.5, 3.0))  # 随机延迟0.5到3秒

    def send_request(self, url, method='GET', data=None):
        self._random_delay()  # 请求前随机延迟
        headers = {'User-Agent': self.user_agent}
        try:
            response = self.session.request(method=method, url=url, headers=headers, timeout=self.timeout, proxies=self.proxies)
            response.raise_for_status()
            return response
        except requests.exceptions.RequestException as e:
            logging.error(f"{method.upper()} request error: {e}")
            return None

    def parse_and_store(self, response):
        # 示例：使用BeautifulSoup解析HTML
        soup = BeautifulSoup(response.text, 'html.parser')
        # 这里添加解析逻辑
        pass

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Simple Web Crawler')
    parser.add_argument('--url', type=str, help='URL to crawl', required=True)
    parser.add_argument('--method', type=str, default='GET', help='HTTP method (GET or POST)')
    args = parser.parse_args()
    pass
