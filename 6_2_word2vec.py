import pandas as pd
from gensim.models import Word2Vec

df = pd.read_csv('word2vec/News.csv')
df1 = pd.read_csv('word2vec/LibNews.csv')
df2 = pd.read_csv('word2vec/ConNews.csv')

docs = [row["pos"].split(' ') for i, row in df.iterrows()]
docs1 = [row["pos"].split(' ') for i, row in df1.iterrows()]
docs2 = [row["pos"].split(' ') for i, row in df2.iterrows()]

model = Word2Vec(docs, window=5,size=300)
model1 = Word2Vec(docs1, window=5,size=300)
model2 = Word2Vec(docs2, window=5,size=300)

df = pd.DataFrame()

df['victim-total'] = [(translator.translate(word[0]).text, word[0], round(word[1], 2)) for word in model.wv.similar_by_word('피해자',topn=30)]
df['victim-con'] = [(translator.translate(word[0]).text, word[0], round(word[1], 2)) for word in model1.wv.similar_by_word('피해자',topn=30)]
df['victim-lib'] = [(translator.translate(word[0]).text, word[0], round(word[1], 2)) for word in model2.wv.similar_by_word('피해자',topn=30)]
df['attacker-total'] = [(translator.translate(word[0]).text, word[0], round(word[1], 2)) for word in model.wv.similar_by_word('가해자',topn=30)]
df['attacker-con'] = [(translator.translate(word[0]).text, word[0], round(word[1], 2)) for word in model1.wv.similar_by_word('가해자',topn=30)]
df['attacker-lib'] = [(translator.translate(word[0]).text, word[0], round(word[1], 2)) for word in model2.wv.similar_by_word('가해자',topn=30)]

df['violence-total'] = [(translator.translate(word[0]).text, word[0], round(word[1], 2)) for word in model.wv.similar_by_word('성폭행',topn=30)]
df['violence-con'] = [(translator.translate(word[0]).text, word[0], round(word[1], 2)) for word in model1.wv.similar_by_word('성폭행',topn=30)]
df['violence-lib'] = [(translator.translate(word[0]).text, word[0], round(word[1], 2)) for word in model2.wv.similar_by_word('성폭행',topn=30)]
df['false-total'] = [(translator.translate(word[0]).text, word[0], round(word[1], 2)) for word in model.wv.similar_by_word('무고죄',topn=30)]
df['false-con'] = [(translator.translate(word[0]).text, word[0], round(word[1], 2)) for word in model1.wv.similar_by_word('무고죄',topn=30)]
df['false-lib'] = [(translator.translate(word[0]).text, word[0], round(word[1], 2)) for word in model2.wv.similar_by_word('무고죄',topn=30)]

import pickle
with open('w2v.p', 'wb') as f:
    pickle.dump(df, f)

print([(word[0], round(word[1], 2)) for word in model1.wv.similar_by_word('피해자',topn=30)])
print([(word[0], round(word[1], 2)) for word in model2.wv.similar_by_word('피해자',topn=30)])

model1.wv.similar_by_word('역차별',topn=30)
model2.wv.similar_by_word('역차별',topn=30)

seed = ['성폭력', '피해자', '가해자', '용기', '무고']
words = list(set([j[0] for i in seed for j in model.most_similar(i, topn=50)] + seed))
windex = [words.index(i) for i in seed]
s = [30] * len(words)
c = ['blue'] * len(words)
for i in windex:
    s[i] = 300
    c[i] = 'red'
wordvecs = [model.wv.word_vec(i) for i in words]

from sklearn.decomposition import PCA
import matplotlib.pyplot as plt
pca = PCA(n_components=2)
pca.fit(wordvecs)
X = pca.transform(wordvecs)
# xs = X[:, 0]
# ys = X[:, 1]
# plt.figure(figsize=(5,5))
# plt.scatter(xs, ys, s=s, c=c)

words_tras = [translator.translate(word).text for word in words]

df = pd.DataFrame()
df['PC1'] = X[:, 0]
df['PC2'] = X[:, 1]
df['kor'] = words
df['eng'] = words_tras
df.to_csv('topic_8.csv')
# from sklearn.manifold import TSNE
# tsne = TSNE(learning_rate=300, perplexity=10.0).fit_transform(wordvecs)
# xs = tsne[:,0]
# ys = tsne[:,1]
# plt.figure(figsize=(7,7))
# plt.scatter(xs, ys, s=s, c=c)


# font_fname = 'c:/windows/fonts/malgun.ttf' # A font of your choice
# font_name = font_manager.FontProperties(fname=font_fname).get_name()
# rc('font', family='NanumGothic')

from matplotlib import font_manager, rc
from adjustText import adjust_text
rc('font',family='NanumGothic', size=5)
texts = [plt.text(k, v, s) for k, v, s in zip(xs,ys,words)]
adjust_text(texts)
plt.savefig('toipc28_2.jpeg')


from googletrans import Translator
translator = Translator()

words_list = ['안녕하세요', '이럴수가', '힘들다', '젠장']
trans_list = [translator.translate(word).text for word in words_list]
words_tras = [translator.translate(word).text for word in words]
trans_list[1].text

tr_results = translator.translate('안녕하세요.')
tr_results.text

