from lib2to3.pgen2 import token
from tkinter import N
from turtle import end_fill
from typing import Set
import nltk
import pandas as pd
import re

df = pd.read_csv('data/IMDB_Dataset.csv')

tagged_tokens_p_reviews = []
tagged_tokens_n_reviews = []
for row in df.head(N).itertuples():
    text = row[1]

    text = text.lower()
    text = re.sub(r'[0-9]+', '', text)
    text = re.sub(r'\<br \/\>', '', text)  # 謎に改行タグが突っ込まれている
    text = re.sub(r'[\.\,\']', '', text)
    sentiment = row[2]
    tokens = nltk.word_tokenize(text)
    tagged_tokens = nltk.pos_tag(tokens)
    if sentiment == 'positive':
        tagged_tokens_p_reviews.append(tagged_tokens)
    elif sentiment == 'negative':
        tagged_tokens_n_reviews.append(tagged_tokens)

# 計算量エグいので、pandasの標準機能でリプレイスしよう
tagged_token_set = set()
for tagged_token_list in tagged_tokens_p_reviews:
    tagged_token_set = tagged_token_set | set(tagged_token_list)
for tagged_token_list in tagged_tokens_n_reviews:
    tagged_token_set = tagged_token_set | set(tagged_token_list)

target_tapples = []
for tagged_token in tagged_token_set:
    tf_plus = 0
    tf_minus = 0
    df_plus = 0
    df_minus = 0
    for p_tagged_token_list in tagged_tokens_p_reviews:
        if tagged_token in p_tagged_token_list:
            df_plus += 1
            tf_plus += p_tagged_token_list.count(tagged_token)

    for n_tagged_token_list in tagged_tokens_n_reviews:
        if tagged_token in n_tagged_token_list:
            df_minus += 1
            tf_minus += n_tagged_token_list.count(tagged_token)
    target_tapples.append(
        (tagged_token[0],
         tagged_token[1],
         tf_plus,
         tf_minus,
         df_plus,
         df_minus))
    # $<t_i, post_i, tf_i ^ +, tf_i ^ -, df_i ^ +, df_i ^ ->$
