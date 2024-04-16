import sys,os
import get_studynote
import bible
import vim

def neo4jbible_testecho():
    output = "これはテストです。これはテストです"
    return output

def neo4jbible_getlist():
    return {"ほげほげ":"123", "はげはげ":"2222", "ふげふげ":"3333"}

def neo4jbible_getlist2():
    return {"1ほげほげ":"a123", "2はげはげ":"b2222", "3ふげふげ":"c3333"}

def neo4jbible_getStudynote(book,chapter):
    return get_studynote.make_studynote_list_and_dict(book,chapter)

def neo4jbible_getStudynote_from_selectedtext(text):
    return get_studynote.make_studynote_list_from_text2(text)

def neo4jbible_getBible_noweb(text):
    return get_studynote.make_biblelist_from_text_noweb(text)

def neo4jbible_get_neo4j_bible_merginalref(text):
    return get_studynote.get_neo4j_bible_merginalref(text)

def neo4jbible_get_neo4j_bible_insight(text):
    return get_studynote.get_neo4j_bible_Insight(text)

def neo4jbible_get_neo4j_bible_watchtower(text):
    return get_studynote.get_neo4j_bible_Watchtower(text)

def neo4jbible_get_neo4j_bible_watchtower_from_title(text):
    return get_studynote.get_neo4j_bible_Watchtower_from_title(text)

def neo4jbible_get_neo4j_bible_insight_from_title(text):
    return get_studynote.get_neo4j_bible_Insight_from_title(text)

def neo4jbible_get_neo4j_bible_route_4steps(text):
    return get_studynote.get_neo4j_bible_route_4steps(text)

def neo4jbible_get_neo4j_bible_route_3steps(text):
    return get_studynote.get_neo4j_bible_route_3steps(text)

def neo4jbible_get_neo4j_bible_route_2steps(text):
    return get_studynote.get_neo4j_bible_route_2steps(text)

def neo4jbible_get_neo4j_bible_route_1steps(text):
    return get_studynote.get_neo4j_bible_route_1steps(text)