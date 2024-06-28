# -*- coding: utf-8 -*-
"""
Created on Fri Mar 24 11:29:45 2023

@author: gbxu
"""

from selenium import webdriver
from selenium.webdriver.support.ui import WebDriverWait
import time
import requests

def download():
    opt = webdriver.ChromeOptions()
    # opt.add_argument("--headless") # 无窗口模式
    opt.add_argument("start-maximized"); # open Browser in maximized mode
    opt.add_argument("disable-infobars"); # 禁用浏览器正在被自动化程序控制的提示
    opt.add_argument('--window-size=1366,768')         # 设置浏览器分辨率（窗口大小）
    opt.add_argument('blink-settings=imagesEnabled=false')  # 不加载图片, 提升速度
    opt.add_argument("--disable-extensions"); # disabling extensions
    opt.add_argument("--disable-gpu"); # applicable to windows os only
    opt.add_argument("--disable-dev-shm-usage"); # overcome limited resource problems
    opt.add_argument("--no-sandbox"); # Bypass OS security model
    driver = webdriver.Chrome()

    #%% 随便打开一个网页
    driver.get("https://www.usenix.org/conference/atc18/presentation/chae")

    # 程序打开网页后 手动设置cookie
    time.sleep(5)

    xpath = '//*[@id="node-paper-full-group-open-access-content"]/div[*]/div/div/span/a'
    pdf_url = ''
    try:
        elem = driver.find_element("xpath", xpath)
        pdf_url = elem.get_attribute("href")
        print(pdf_url, idx, "/", len(lines))
        response = requests.get(pdf_url)
        with open(pdf_url.split('/')[-1], "wb") as pdf:
           pdf.write(response.content)
    except Exception as e:
        print("Error : ", url, pdf_url)

    def every_downloads_chrome(driver):
        if not driver.current_url.startswith("chrome://downloads"):
            driver.get("chrome://downloads/")
        return driver.execute_script("""
            var items = document.querySelector('downloads-manager')
                .shadowRoot.getElementById('downloadsList').items;
            if (items.every(e => e.state === "COMPLETE"))
                return items.map(e => e.fileUrl || e.file_url);
            """)

    # waits for all the files to be completed and returns the paths
    paths = WebDriverWait(driver, 120, 1).until(every_downloads_chrome)

    print(paths)
    time.sleep(600)

    driver.close()

if __name__ == '__main__':
