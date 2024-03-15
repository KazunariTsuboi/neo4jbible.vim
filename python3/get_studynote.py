import sys
import requests, urllib
from lxml import html
from bs4 import BeautifulSoup
import json

#from biblesitation import vs2str, str2vs_chapter_range
import biblesitation

URL = f"https://www.jw.org/ja/%E3%83%A9%E3%82%A4%E3%83%96%E3%83%A9%E3%83%AA%E3%83%BC/%E8%81%96%E6%9B%B8/%E3%82%B9%E3%82%BF%E3%83%87%E3%82%A3%E3%83%BC%E7%89%88%E8%81%96%E6%9B%B8/%E5%90%84%E6%9B%B8/json/data/"

def get_studynote_json(url_bistring):
    headers = { 'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.66 Safari/537.36'}
    #urlpath = r"https://www.jw.org/ja/%E3%83%A9%E3%82%A4%E3%83%96%E3%83%A9%E3%83%AA%E3%83%BC/%E8%81%96%E6%9B%B8/%E3%82%B9%E3%82%BF%E3%83%87%E3%82%A3%E3%83%BC%E7%89%88%E8%81%96%E6%9B%B8/%E5%90%84%E6%9B%B8/json/data/40001000-40001999"
    urlpath = URL + url_bistring
    urlpath = urllib.parse.unquote(urlpath)
    res=requests.request('GET',urlpath, headers=headers,timeout=(5,5))
    data = json.loads(res.text)
    return data


def make_studynote_lists(text_with_tag):
    # 返り値 リスト（２次元配列）
    # return[0...][0] 見出し語
    # return[0...][1] 要素
    soup = BeautifulSoup(text_with_tag, 'html.parser')
    text = soup.get_text().strip()
    return [t.split(': ') for t in  text.split('\n')]

def make_ref_lists(text_with_tag, cnt):
    # 返り値 リスト（２次元配列）
    # return[0...][0] 見出し語
    # return[0...][1] 要素
    soup = BeautifulSoup(text_with_tag, 'html.parser')
    text = soup.get_text().strip()
    return [[f"脚注*{str(cnt)}" , text]]

def make_verse_text(text_with_tag):
    # 返り値 リスト（２次元配列）
    # return[0...][0] なし
    # return[0...][1] 要素
    soup = BeautifulSoup(text_with_tag, 'html.parser')
    text = soup.get_text().strip()
    return text.replace('\xa0',' ')

def make_url_bistring(text):
    result =[biblesitation.str2vs(i) for i in biblesitation.citation_text(text)]
    result_text = ','.join(result)
    return result_text

def make_studynote_list_and_dict(book="ヨハネ",chapter="1"):
    url_bistring = biblesitation.str2vs_chapter_range(f'{book} {chapter}')
    data = get_studynote_json(url_bistring)
    refcomment_dic = {}
    refcomment_list = []
    for key in data['ranges'].keys():
        for refcomments in data['ranges'][key]['commentaries']:
            studynote_lists = make_studynote_lists(refcomments['content'])
            
            if refcomments['source'] != None:
                for studynote in studynote_lists:
                    refcomment_dic[biblesitation.vs2str(refcomments['source'])+'| ' + studynote[0]] = studynote[1]
                    refcomment_list.append([biblesitation.vs2str(refcomments['source'])+'| ' + studynote[0] , studynote[1]])

        cnt = 0
        for refcomments in data['ranges'][key]['footnotes']:
            cnt += 1
            studynote_lists = make_ref_lists(refcomments['content'],cnt)
            
            if refcomments['source'] != None:
                for studynote in studynote_lists:
                    refcomment_dic[biblesitation.vs2str(refcomments['source'])+'| ' + studynote[0]] = studynote[1]
                    refcomment_list.append([biblesitation.vs2str(refcomments['source'])+'| ' + studynote[0] , studynote[1]])
    return [refcomment_list, refcomment_dic]

def make_studynote_list_from_text2(text):
    url_bistring = make_url_bistring(text)
    data = get_studynote_json(url_bistring)
    refcomment_dic = {}
    refcomment_list = []
    for key in data['ranges'].keys():
        for verse in data['ranges'][key]['verses']:
            verse_text = make_verse_text(verse['content'])
            # 聖句内容を投入する場合
            #refcomment_dic[verse['standardCitation'].replace('&nbsp;',' ')] = verse_text
            #refcomment_list.append([verse['standardCitation'].replace('&nbsp;',' '), verse_text])
            # 聖句の内容は投入せずに bible.get_bible を使った情報を表示させる場合
            bi_citationed = biblesitation.citation_text(verse['standardCitation'].replace('&nbsp;',' '))
            refcomment_dic[bi_citationed[0]] = ''
            refcomment_list.append([bi_citationed[0], ''])

        for refcomments in data['ranges'][key]['commentaries']:
            studynote_lists = make_studynote_lists(refcomments['content'])
            
            if refcomments['source'] != None:
                for studynote in studynote_lists:
                    refcomment_dic[biblesitation.vs2str(refcomments['source'])+'| ' + studynote[0]] = studynote[1]
                    refcomment_list.append([biblesitation.vs2str(refcomments['source'])+'| ' + studynote[0] , studynote[1]])

        cnt = 0
        for refcomments in data['ranges'][key]['footnotes']:
            cnt += 1
            studynote_lists = make_ref_lists(refcomments['content'],cnt)
            
            if refcomments['source'] != None:
                for studynote in studynote_lists:
                    refcomment_dic[biblesitation.vs2str(refcomments['source'])+'| ' + studynote[0]] = studynote[1]
                    refcomment_list.append([biblesitation.vs2str(refcomments['source'])+'| ' + studynote[0] , studynote[1]])

    return [refcomment_list, refcomment_dic]

def make_biblelist_from_text_noweb(text):
    bible_citation_list = biblesitation.citation_text(text)
    refcomment_dic = {}
    refcomment_list = []

    for bi in bible_citation_list:
        refcomment_dic[bi] = ''
        refcomment_list.append([bi, ''])

    return [refcomment_list, refcomment_dic]