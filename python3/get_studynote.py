import sys
import requests, urllib
from lxml import html
from bs4 import BeautifulSoup
import json

def get_studynote_json(url_bistring):
    headers = { 'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.66 Safari/537.36'}
    #urlpath = r"https://www.jw.org/ja/%E3%83%A9%E3%82%A4%E3%83%96%E3%83%A9%E3%83%AA%E3%83%BC/%E8%81%96%E6%9B%B8/%E3%82%B9%E3%82%BF%E3%83%87%E3%82%A3%E3%83%BC%E7%89%88%E8%81%96%E6%9B%B8/%E5%90%84%E6%9B%B8/json/data/40001000-40001999"
    urlpath = f"https://www.jw.org/ja/%E3%83%A9%E3%82%A4%E3%83%96%E3%83%A9%E3%83%AA%E3%83%BC/%E8%81%96%E6%9B%B8/%E3%82%B9%E3%82%BF%E3%83%87%E3%82%A3%E3%83%BC%E7%89%88%E8%81%96%E6%9B%B8/%E5%90%84%E6%9B%B8/json/data/{url_bistring}"
    urlpath = urllib.parse.unquote(urlpath)
    res=requests.get(urlpath, headers=headers)
    data = json.loads(res.text)
    return data


def make_studynote_lists(text_with_tag):
    # 返り値 リスト（２次元配列）
    # return[0...][0] 見出し語
    # return[0...][1] 要素
    soup = BeautifulSoup(text_with_tag, 'html.parser')
    text = soup.get_text().strip()
    return [t.split(': ') for t in  text.split('\n')]

def make_studynote_dic(book,chapter):
    url_bistring = str2vs(f'{book} {chapter}')
    data = get_studynote_json(url_bistring)
    refcomment_dic = {}
    for key in data['ranges'].keys():
        for refcomments in data['ranges'][key]['commentaries']:
            studynote_lists = make_studynote_lists(refcomments['content'])
            
            if refcomments['source'] != None:
                for studynote in studynote_lists:
                    refcomment_dic[vs2str(refcomments['source'])+'| ' + studynote[0]] = studynote[1]
    return refcomment_dic

def vs2str(vs):
    bookdir = {
    1:'創世',
    2:'出エジプト',
    3:'レビ',
    4:'民数',
    5:'申命',
    6:'ヨシュア',
    7:'裁き人',
    8:'ルツ',
    9:'サムエル第一',
    10:'サムエル第二',
    11:'列王第一',
    12:'列王第二',
    13:'歴代第一',
    14:'歴代第二',
    15:'エズラ',
    16:'ネヘミヤ',
    17:'エステル',
    18:'ヨブ',
    19:'詩編',
    20:'格言',
    21:'伝道',
    22:'ソロモンの歌',
    23:'イザヤ',
    24:'エレミヤ',
    25:'哀歌',
    26:'エゼキエル',
    27:'ダニエル',
    28:'ホセア',
    29:'ヨエル',
    30:'アモス',
    31:'オバデヤ',
    32:'ヨナ',
    33:'ミカ',
    34:'ナホム',
    35:'ハバクク',
    36:'ゼパニヤ',
    37:'ハガイ',
    38:'ゼカリヤ',
    39:'マラキ',
    40:'マタイ',
    41:'マルコ',
    42:'ルカ',
    43:'ヨハネ',
    44:'使徒',
    45:'ローマ',
    46:'コリント第一',
    47:'コリント第二',
    48:'ガラテア',
    49:'エフェソス',
    50:'フィリピ',
    51:'コロサイ',
    52:'テサロニケ第一',
    53:'テサロニケ第二',
    54:'テモテ第一',
    55:'テモテ第二',
    56:'テトス',
    57:'フィレモン',
    58:'ヘブライ',
    59:'ヤコブ',
    60:'ペテロ第一',
    61:'ペテロ第二',
    62:'ヨハネ第一',
    63:'ヨハネ第二',
    64:'ヨハネ第三',
    65:'ユダ',
    66:'啓示'}
    varse = int(vs[-3:])
    chapter = int(vs[-6:-3])
    book = int(vs[:-6])

    txt = '"'+bookdir[int(book)]+" "+ str(chapter) +":"+ str(varse)+'"'
    return txt

def str2vs(str_bi):
    bookdir = {
        '創世': 1,
        '出エジプト': 2,
        'レビ': 3,
        '民数': 4,
        '申命': 5,
        'ヨシュア': 6,
        '裁き人': 7,
        'ルツ': 8,
        'サムエル第一': 9,
        'サムエル第二': 10,
        '列王第一': 11,
        '列王第二': 12,
        '歴代第一': 13,
        '歴代第二': 14,
        'エズラ': 15,
        'ネヘミヤ': 16,
        'エステル': 17,
        'ヨブ': 18,
        '詩編': 19,
        '格言': 20,
        '伝道': 21,
        'ソロモンの歌': 22,
        'イザヤ': 23,
        'エレミヤ': 24,
        '哀歌': 25,
        'エゼキエル': 26,
        'ダニエル': 27,
        'ホセア': 28,
        'ヨエル': 29,
        'アモス': 30,
        'オバデヤ': 31,
        'ヨナ': 32,
        'ミカ': 33,
        'ナホム': 34,
        'ハバクク': 35,
        'ゼパニヤ': 36,
        'ハガイ': 37,
        'ゼカリヤ': 38,
        'マラキ': 39,
        'マタイ': 40,
        'マルコ': 41,
        'ルカ': 42,
        'ヨハネ': 43,
        '使徒': 44,
        'ローマ': 45,
        'コリント第一': 46,
        'コリント第二': 47,
        'ガラテア': 48,
        'エフェソス': 49,
        'フィリピ': 50,
        'コロサイ': 51,
        'テサロニケ第一': 52,
        'テサロニケ第二': 53,
        'テモテ第一': 54,
        'テモテ第二': 55,
        'テトス': 56,
        'フィレモン': 57,
        'ヘブライ': 58,
        'ヤコブ': 59,
        'ペテロ第一': 60,
        'ペテロ第二': 61,
        'ヨハネ第一': 62,
        'ヨハネ第二': 63,
        'ヨハネ第三': 64,
        'ユダ': 65,
        '啓示': 66,
    }
    chapter = str_bi.split(' ')[1].zfill(3)
    book = bookdir[str_bi.split(' ')[0]]

    start_addr = f'{book}{chapter}000'
    end_addr   = f'{book}{chapter}999'

    return start_addr + '-' + end_addr
    

