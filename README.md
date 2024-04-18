# neo4jbible.vim


### 表示画面追加のMEMO
- get_studynote.py に [リスト, 辞書] を返す関数を追加する  
リスト: 左側に表示されるもの  
辞書:  右下に表示されるもの。リストの要素が key  


- 追加した関数を neo4jbible.py に登録する
 vimscript 側から pythonコマンドを呼び出すときに処理を一本化したいため  
 
- autoload/neo4jbible.vim: pythonで処理し結果を受け取る関数を追加

- plugin/neo4jbible.vim: コマンドにしたいならここに処理を追加


