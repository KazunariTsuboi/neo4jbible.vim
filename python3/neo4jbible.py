import sys,os
import get_studynote
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
