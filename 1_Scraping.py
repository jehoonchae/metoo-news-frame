from bs4 import BeautifulSoup
from selenium import webdriver
import os
os.getcwd()
import time
import random
from urllib.request import urlopen

# 기사의 내용을 조금 걸러서 들여와보자
def articlepre(article):
    split=re.split("@",article)  # 기자의 메일주소를 기점으로 짤라내고
    if len(split)==1:
        article=split[0]
    else: article="".join(split[0:-1])
    split = re.split("▶", article)  # 이런 방식으로 뒤의 것들을 잘라낸다.
    if len(split) == 1:
        article = split[0]
    else:
        article = "".join(split[0:-1])
    split=re.split("©",article)
    if len(split)==1:
        article=split[0]
    else: article="".join(split[0:-1])
    split=re.split("모바일 경향",article)
    if len(split)==1:
        article=split[0]
    else: article="".join(split[0:-1])
    article=re.sub("flash 오류를 우회하기 위한 함수 추가|function _flash_removeCallback|모바일 경향|"
                   "공식 SNS 계정|[\{\}\[\]\/,;:|\)*`^\-_+<>@\#$%&\\\=\(\'\"]"," ",article)
    article=re.sub('[a-zA-Z]|\n|\t|\r|▲|【|】|▶|©', '', article)

    return article


def get_articles(html):
    results = []
    soup = BeautifulSoup(html, 'lxml')
    lis = soup.find_all('li', attrs={'id':re.compile(r'sp_nws')})
    for li in lis:
        title='NA'
        naver_url = 'NA'
        pub = 'NA'
        date = 'NA'
        title = li.find('a', attrs={'class':re.compile(r'_sp_each_title')}).get('title').strip()
        if li.find('a', attrs={'class':re.compile(r'_sp_each_url')}).text:
            naver_url = li.find('a', attrs={'class':re.compile(r'_sp_each_url')}).get('href').strip()
        pub = li.find('span', attrs={'class':'_sp_each_source'}).text.strip()
        date = li.find('span', attrs={'class':'bar'}).next_sibling.strip()
        results.append([title, naver_url, pub,date])
        print(title, naver_url, pub, date)
    return results

import re

#driver = webdriver.Chrome(executable_path=r'C:\Users\Sang\Downloads\chromedriver_win32_1\chromedriver.exe')
#driver = webdriver.Chrome(executable_path=r'C:\Users\Sang\Downloads\chromedriver_win32_1\chromedriver.exe')
driver = webdriver.Chrome('/Users/jhchae/Dropbox/Pycharm/web_scraping/chromedriver')
url = 'https://www.naver.com/'
driver.get(url)
sleep_time = random.random()*3
time.sleep(sleep_time)
url1 = 'https://search.naver.com/search.naver?query=q&where=news&ie=utf8&sm=nws_hty'
driver.get(url1)
element0 = driver.find_element_by_id('_search_option_btn')
element0.click()
element = driver.find_element_by_xpath('/html/body/div[3]/div[1]/div[3]/div/ul/li[5]/a')
element.click()
time.sleep(0.5)

# element1 = driver.find_element_by_id('ca_1020') # 동아
# element1.click()
# element1 = driver.find_element_by_id('ca_1023') # 조선
# element1.click()
# element1 = driver.find_element_by_id('ca_1448') #TV조선
# element1.click()
# element1 = driver.find_element_by_id('ca_1449') #채널A
# element1.click()

# element1 = driver.find_element_by_id('ca_1032') # 경향
# element1.click()
# element1 = driver.find_element_by_id('ca_1028') # 한겨
# element1.click()
element1 = driver.find_element_by_id('ca_1437') #JTBC
element1.click()
element1 = driver.find_element_by_id('ca_1019') # MBN
element1.click()

# element1 = driver.find_element_by_id('ca_1056') # KBS
# element1.click()
# element1 = driver.find_element_by_id('ca_1214') # MBC
# element1.click()
# element1 = driver.find_element_by_id('ca_1055') # SBS
# element1.click()

element2 = driver.find_element_by_xpath('/html/body/div[3]/div[1]/div[3]/div/ul/li[5]/div/div[2]/div[3]/button[1]')
element2.click()
time.sleep(1)

q = '미투'
startDate = '2017.10.01'
endDate = '2019.10.21'
# 한번에 가져올 수 있는 기사의 수는 4,000개가 max
pickle_name = q+'_'+startDate+'_'+endDate+'.p'
total_results = []
for page in range(400):
    sleep_time = random.random()*5
    time.sleep(sleep_time)
    start = page*10 + 1
    url = 'https://search.naver.com/search.naver?&where=news&query='+q+'&sm=tab_pge&sort=2&photo=0&field=0&reporter_article=&pd=3&ds='+startDate+'&de='+endDate+'&mynews=1&refresh_start=0&start='+str(start)
    driver.get(url)
    html = driver.page_source
    if re.search(r'검색결과가 없습니다',html):
        break
    results = get_articles(html)
    print(page, results, len(results))
    total_results.extend(results)


url_list = []
for i in total_results:
    url_list.append(i[1])

with open('/Users/jhchae/Dropbox/MA/News_Framing_Refugee/Data/Raw/metoo_lib_url1.csv', 'w', encoding='utf8') as f:
    for i in url_list:
        f.write(i + '\n')

with open('/Users/jhchae/Dropbox/MA/News_Framing_Refugee/Data/Raw/metoo_lib1.csv', 'w', encoding='utf8') as f:
    for i, url in enumerate(url_list):
        # soup = BeautifulSoup(requests.get(url).text, 'lxml')
        soup = BeautifulSoup(urlopen(url), 'lxml')
        try:
            if soup.find('span', class_='t11')==None and soup.find('span', class_="author")==None:
                date = re.sub("\.", "-", re.findall("[0-9]{4}.[0-9]{2}.[0-9]{2}", soup.find('div', class_="info").text)[0])
                press = soup.find('span', id='pressLogo').find('img')['alt']
                title = articlepre(soup.find("h4", class_="title").text)
                article = articlepre(soup.find('div', id="newsEndContents").text)
                f.write(date + ',' + press + ',' + title + ',' + article + '\n')
                print("About " + str(round(i / len(url_list) * 100, 2)) + "% done")
            elif soup.find('span', class_='t11')==None:
                date = re.sub("\.", "-", re.findall("[0-9]{4}.[0-9]{2}.[0-9]{2}", soup.find('span', class_="author").text)[0])
                press = soup.find('div', class_="press_logo").find('img')['alt']
                title = articlepre(soup.find("h2", class_="end_tit").text)
                article = articlepre(soup.find('div', id="articeBody").text)
                f.write(date + ',' + press + ',' + title + ',' + article + '\n')
                print("About " + str(round(i / len(url_list) * 100, 2)) + "% done")
            else:
                date = re.sub("\.", "-", re.findall("[0-9]{4}.[0-9]{2}.[0-9]{2}", soup.find('span', class_="t11").text)[0])
                press = soup.find('div', class_="article_header").find('img')['title']
                title = articlepre(soup.find("h3", id="articleTitle").text)
                article = articlepre(soup.find('div', class_="_article_body_contents").text)
                f.write(date + ',' + press + ',' + title + ',' + article + '\n')
                print("About " + str(round(i / len(url_list) * 100, 2)) + "% done")
        except AttributeError as e:
            print('pass')
