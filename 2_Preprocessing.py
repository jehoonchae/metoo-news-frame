import re
import os
import pandas as pd
import pickle
from bs4 import BeautifulSoup
import nltk
from ckonlpy.tag import Twitter


################################################################################
os.getcwd()
# df1 = pd.read_csv('/Users/jhchae/Dropbox/MA/News_Framing_Refugee/Data/Raw/metoo_lib1.csv'
#                   , sep=',', names=["date", "press", "title", "article"])
# df2 = pd.read_csv('/Users/jhchae/Dropbox/MA/News_Framing_Refugee/Data/Raw/metoo_lib2.csv'
#                   , sep=',', names=["date", "press", "title", "article"])
# df3 = pd.read_csv('/Users/jhchae/Dropbox/MA/News_Framing_Refugee/Data/Raw/metoo_con.csv'
#                   , sep=',', names=["date", "press", "title", "article"])

# frames = [df1, df2, df3]
# result = pd.concat(frames, ignore_index=True, sort=False)
# df = result

df = pd.read_csv('/Users/jhchae/Dropbox/MA/STM_Metoo/data_raw/metoo_chosun.csv'
                  , sep=',', names=["date", "press", "title", "article"])
df = df[df['article'].str.len() > 50].reset_index(drop=True)

pos_tagger = Twitter()

def pos(doc):
    with open('/Users/jhchae/Dropbox/MA/News_Framing_Refugee/Data/news_stopwords.txt', 'r', encoding='utf8') as f:
        stopwords_list = [re.sub(r'\n', '', i) for i in f.readlines()]

    doc = re.sub('|'.join(stopwords_list), '', doc)

    return [t[0] for t in pos_tagger.pos(doc, norm=True, stem=True) if 'Noun' in t[1] and len(t[0]) > 1]

df['article'] = df['article'].str.replace('[^가-힣]', ' ')
df['article'] = df['article'].str.replace('조선일보|동아일보|한겨레|경향신문|채널A|JTBC|MBN|TV조선', ' ')
df['article'] = df['article'].str.replace('[가-힣]{2,3}\s{1,3}기자', '')
df['article'] = df['article'].str.replace(r'[연합뉴스] <저작권자 ⓒ 1980-2018 ㈜연합뉴스. 무단 전재 재배포 금지.>', ' ')
df['article'] = df['article'].str.replace(r'연합뉴스 모바일', ' ')

df['date'] = df['date'].astype('object')  # 데이터 타입 조정
df['press'] = df['press'].astype('object')

df['pos'] = df['article']

# df.to_csv("web_scraping/refugee/news_prep_1.csv", sep=',', index = False)
# df.to_csv("web_scraping/refugee/metoo_prep.csv", sep=',', index = False)
# df.to_csv("/Users/jhchae/Dropbox/MA/News_Framing_Refugee/Data/metoo_1021.csv", sep=',', index=False)

df['pos'] = pd.Series([pos(i) for i in df['pos']])  # 명사만 넣어두기

"""
with open('/Users/jhchae/Dropbox/MA/News_Framing_Refugee/Data/Jeju.pickle','wb') as p:
    pickle.dump(df, p)

with open('/Users/jhchae/Dropbox/MA/News_Framing_Refugee/Data/Raw/metoo.pickle','wb') as p:
    pickle.dump(df, p)

with open('/Users/jhchae/Dropbox/MA/News_Framing_Refugee/Data/Raw/jeju_news.pickle','wb') as p:
    pickle.dump(df, p)

with open('/Users/jhchae/Dropbox/MA/News_Framing_Refugee/Data/Raw/metoo_1021.pickle','wb') as p:
    pickle.dump(df, p)

"""

################### 단어 빈도

# with open('/Users/jhchae/Dropbox/MA/News_Framing_Refugee/Data/Jeju.pickle', 'rb') as p:
#     df = pickle.load(p)

with open('/Users/jhchae/Dropbox/MA/STM_Metoo/data_prep/metoo_1021.pickle', 'rb') as p:
    df = pickle.load(p)

import nltk

tokens = [j for i in df['pos'] for j in i]

text = nltk.Text(tokens)

import matplotlib.pyplot as plt
from matplotlib import rc

rc('font', family='AppleGothic')  # 한글 깨짐 방지
plt.rcParams['axes.unicode_minus'] = False

fig = plt.figure()
fig.set_label('test')
plt.figure(figsize=(10, 8))
text.plot(50)

from nltk.probability import FreqDist

freq = FreqDist(text)
freq.keys()

freq_list = [i[0] for i in freq.most_common()]
freq_list_upper = [i[0] for i in freq.most_common(100)]
freq_list_lower = [i[0] for i in freq.most_common() if i[1] < 10]

len(freq_list)
len(freq_list_lower)

press_list = list(set(df['press']))
len(press_list)

df['month'] = [i[:7] for i in df['date']]
df = df.dropna(subset=['article', 'date', 'press', 'pos'])

len(df)

year = 2017
month = 10

import numpy as np

df['dindex'] = [np.nan for _ in range(0, len(df['title']))]
df['dindex'] = [12 * (int(i.split('-')[0]) - year) + int(i.split('-')[1]) - month for i in df['month']]

df['date'] = df['date'].astype('str')  # 데이터 타입 조정
df['month'] = df['month'].astype('str')  # 데이터 타입 조정
df['press'] = df['press'].astype('object')
# df['date'] = df['date'].str.replace('-', '.')
# df['date'] = df['date'].str.replace('.', '-')

df['date'] = df['date'].astype('object')

df['pos'] = [' '.join(i) for i in df['pos']]  # [] 없애고 list를 str로 만들어버리기

# df['pos'] = df['pos'].str.replace('난민|미국|대통령|정부|한국|시간|총리|세계|국가|사회', '')
df['pos'] = df['pos'].str.replace('여성|미투', '')
df['pos'] = [i.strip() for i in df['pos']]

# df.to_csv('/Users/jhchae/Dropbox/MA/News_Framing_Refugee/Data/metoo_1021.csv', encoding='utf8', index=False)
df.to_csv('/Users/jhchae/Dropbox/MA/STM_Metoo/data_prep/metoo_chosun.csv', encoding='utf8', index=False)

with open('/Users/jhchae/Dropbox/MA/STM_Metoo/data_prep/freq_dist_100.txt', 'w', encoding='utf8') as f:
    for dic in freq_list:
        f.write(dic + '\n')

fdic = {i[0]: i[1] for i in freq.most_common(100)}

pd.DataFrame.from_dict(fdic, orient='index').to_csv('/Users/jhchae/Dropbox/MA/STM_Metoo/data_prep/freq_dist_100.csv', encoding='utf-8')