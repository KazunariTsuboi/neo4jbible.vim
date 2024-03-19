py3file <sfile>:h:h/python3/neo4jbible.py
py3file <sfile>:h:h/python3/bible.py
python3 import vim

" 一覧作成用のバッファ名
let g:neo4j_list_buffer = "NEO4JLISTS"
let g:neo4j_list_buffer_right = "NEO4JLISTS_RIGHT"
let g:neo4j_list_buffer_bible = "NEO4JLISTS_BIBLE"

" 履歴を保持するリスト
let g:neo4j_history = []
let g:neo4j_unhistory = []

" 履歴にアイテムを追加する関数
function! neo4jbible#AddToHistory(item)
    " リストの長さが20を超えた場合、古いアイテムを削除
    if len(g:neo4j_history) >= 20
        call remove(g:neo4j_history, 0)
    endif
    " 新しいアイテムをリストの末尾に追加
    call add(g:neo4j_history, a:item)
endfunction


" 履歴（元に戻す）にアイテムを追加する関数
function! neo4jbible#AddToUnHistory(item)
    " リストの長さが20を超えた場合、古いアイテムを削除
    if len(g:neo4j_unhistory) >= 20
        call remove(g:neo4j_unhistory, 0)
    endif
    " 新しいアイテムをリストの末尾に追加
    call add(g:neo4j_unhistory, a:item)
endfunction

" 履歴を表示する関数
function! neo4jbible#ShowHistory()
    echo join(g:neo4j_history, "\n")
endfunction

function! neo4jbible#make_windows_History() abort
    let g:current_window_id = win_getid()
    call neo4jbible#lock_unlock_window(g:neo4j_list_buffer, 'unlock')

    if len(g:neo4j_history) > 1
      let last_item = g:neo4j_history[-1]
      call neo4jbible#make_windows(last_item)
      call neo4jbible#AddToUnHistory(last_item)
      call remove(g:neo4j_history, len(g:neo4j_history) - 1)
    elseif len(g:neo4j_history) == 1
      let last_item = g:neo4j_history[-1]
      call neo4jbible#make_windows(last_item)
      call neo4jbible#AddToUnHistory(last_item)
    else
        echo "履歴は空です。"
        return
    endif
endfunction

function! neo4jbible#make_windows_UnHistory() abort
    let g:current_window_id = win_getid()
    call neo4jbible#lock_unlock_window(g:neo4j_list_buffer, 'unlock')

    if len(g:neo4j_unhistory) > 1
      let last_item = g:neo4j_unhistory[-1]
      call neo4jbible#make_windows(last_item)
      call neo4jbible#AddToHistory(last_item)
      call remove(g:neo4j_unhistory, len(g:neo4j_unhistory) - 1)
    elseif len(g:neo4j_unhistory) == 1
      let last_item = g:neo4j_unhistory[-1]
      call neo4jbible#make_windows(last_item)
      call neo4jbible#AddToUnHistory(last_item)
    else
        echo "もとに戻すは空です"
        return
    endif
endfunction

function! neo4jbible#make_windows_from_command(...) abort
  let g:current_window_id = win_getid()
    let arg_book =    a:0 >= 1 ? a:1 : 'マタイ'
    let arg_chapter = a:0 >= 2 ? a:2 : '1'

    call neo4jbible#lock_unlock_window(g:neo4j_list_buffer, 'unlock')
    " 現在のウィンドウIDの取得
    python3 vim.command(f'let s:result = {neo4jbible_getStudynote(book=vim.eval("arg_book"), chapter=vim.eval("arg_chapter"))}')
    call neo4jbible#make_windows(s:result)
    call neo4jbible#AddToHistory(s:result)
endfunction

function! neo4jbible#make_windows_from_selected(text) abort
    let g:current_window_id = win_getid()

    call neo4jbible#lock_unlock_window(g:neo4j_list_buffer, 'unlock')
    " 現在のウィンドウIDの取得
    python3 vim.command(f'let s:result = {neo4jbible_getStudynote_from_selectedtext(vim.eval("a:text"))}')
    call neo4jbible#make_windows(s:result)
    call neo4jbible#AddToHistory(s:result)
endfunction

function! neo4jbible#make_windows_from_selected_noweb(text) abort
    let g:current_window_id = win_getid()

    call neo4jbible#lock_unlock_window(g:neo4j_list_buffer, 'unlock')
    " 現在のウィンドウIDの取得
    python3 vim.command(f'let s:result = {neo4jbible_getBible_noweb(vim.eval("a:text"))}')
    call neo4jbible#make_windows(s:result)
    call neo4jbible#AddToHistory(s:result)
endfunction

function! neo4jbible#make_windows_bible_merginalref_args(...) abort
    let arg_addr = a:1.' '.a:2
    let g:current_window_id = win_getid()
    call neo4jbible#lock_unlock_window(g:neo4j_list_buffer, 'unlock')
    python3 vim.command(f'let s:result = {neo4jbible_get_neo4j_bible_merginalref(vim.eval("arg_addr"))}')
    call neo4jbible#make_windows(s:result)
    call neo4jbible#AddToHistory(s:result)
endfunction

function! neo4jbible#make_windows_bible_merginalref(text) abort
    let g:current_window_id = win_getid()
    echo(a:text)
    call neo4jbible#lock_unlock_window(g:neo4j_list_buffer, 'unlock')
    python3 vim.command(f'let s:result = {neo4jbible_get_neo4j_bible_merginalref(vim.eval("a:text"))}')
    call neo4jbible#make_windows(s:result)
    call neo4jbible#AddToHistory(s:result)
endfunction

function! neo4jbible#make_windows(result) abort
    let g:result_list = a:result[0]
    let g:result_dict = a:result[1]
    if g:result_dict == {}
      echo 'おそらくまだスタディノートが公開されていません'
      if bufexists(g:neo4j_list_buffer)
        " バッファがウィンドウに表示されている場合は`win_gotoid`でウィンドウに移動します
        let winid = bufwinid(g:neo4j_list_buffer)
        if winid isnot# -1
          call win_gotoid(winid)
          %delete _
        endif
      endif
      return
    endif

    " 'NEO4JLISTS' バッファが存在している場合
    if bufexists(g:neo4j_list_buffer)
      " バッファがウィンドウに表示されている場合は`win_gotoid`でウィンドウに移動します
      let winid = bufwinid(g:neo4j_list_buffer)
      if winid isnot# -1
        call win_gotoid(winid)
  
      " バッファがウィンドウに表示されていない場合は`sbuffer`で新しいウィンドウを作成してバッファを開きます
      else
        execute 'sbuffer' g:neo4j_list_buffer
      endif
  
    else
      " バッファが存在していない場合は`new`で新しいバッファを作成します
      execute 'new' g:neo4j_list_buffer_right
      execute 'vnew' g:neo4j_list_buffer
      execute "normal \<C-W>l"
      execute 'new' g:neo4j_list_buffer_bible
      execute "normal \<C-W>h"
  
      " キーマッピングを定義します
      call neo4jbible#set_keymap(g:neo4j_list_buffer)
      call neo4jbible#set_keymap_infowindow(g:neo4j_list_buffer_right)
  
    endif
  
    " セッションファイルを表示する一時バッファのテキストをすべて削除して、取得したファイル一覧をバッファに挿入します
    %delete _
    " キーのみを抽出
    let g:result_keys = map(copy(g:result_list), 'v:val[0]')
    call setline(1, g:result_keys)
    call neo4jbible#lock_unlock_window(g:neo4j_list_buffer, 'lock')
    call neo4jbible#infowindow(g:result_dict[getline('.')])
endfunction




function! neo4jbible#set_keymap(bufname) abort
    let current_window_id = win_getid()
    let targetwindow_id = bufwinid(a:bufname)
    if targetwindow_id != -1
      call win_gotoid(targetwindow_id)
        " 1. セッション一覧のバッファで`q`を押下するとバッファを破棄
        " 2. `Enter`でセッションをロード
        " の2つのキーマッピングを定義します。
        "
        " <C-u>と<CR>はそれぞれコマンドラインでCTRL-uとEnterを押下した時の動作になります
        " <buffer>は現在のバッファにのみキーマップを設定します
        " <silent>はキーマップで実行されるコマンドがコマンドラインに表示されないようにします
        " <Plug>という特殊な文字を使用するとキーを割り当てないマップを用意できます
        " ユーザはこのマップを使用して自分の好きなキーマップを設定できます
        "
        " \ は改行するときに必要です
        nnoremap <silent> <buffer>
          \ <Plug>(session-move-j)
          \ :<C-u> call neo4jbible#move(1) <CR>
        nnoremap <silent> <buffer>
          \ <Plug>(session-move-k)
          \ :<C-u> call neo4jbible#move(-1) <CR>
        nnoremap <silent> <buffer>
          \ <Plug>(session-close)
          \ :<C-u> call neo4jbible#clearHighlight() <CR>
          \ :<C-u> execute 'bwipeout!' g:neo4j_list_buffer_bible <CR>
          \ :<C-u> execute 'bwipeout!' g:neo4j_list_buffer_right <CR>
          \ :<C-u> execute 'bwipeout!' g:neo4j_list_buffer <CR>
        nnoremap <silent> <buffer>
          \ <Plug>(session-open)
          \ :<C-u> call neo4jbible#echo_line_data(getline('.')) <CR>
          "\ :<C-u> call neo4jbible#echo_line_data(g:result_dict[getline('.')]) <CR>
          \ :<C-u> call neo4jbible#clearHighlight() <CR>
        nnoremap <silent> <buffer>
          \ <Plug>(session-select)
          \ :<C-u> call neo4jbible#selectLine()<CR>
        nnoremap <silent> <buffer>
          \ <Plug>(neo4j-open-node)
          \ :<C-u> call neo4jbible#openNode() <CR>
        nnoremap <silent> <buffer>
          \ <Plug>(neo4j-history-back)
          \ :<C-u> call neo4jbible#make_windows_History() <CR>
        nnoremap <silent> <buffer>
          \ <Plug>(neo4j-history-next)
          \ :<C-u> call neo4jbible#make_windows_UnHistory() <CR>
    
        " <Plug>マップをキーにマッピングします
        " `q` は最終的に :<C-u>bwipeout!<CR>
        " `Enter` は最終的に :<C-u>call session#load_session()<CR>
        " が実行されます
        nmap <buffer> j <Plug>(session-move-j)
        nmap <buffer> k <Plug>(session-move-k)
        nmap <buffer> q <Plug>(session-close)
        nmap <buffer> <CR> <Plug>(session-open)
        nmap <buffer> z <Plug>(session-select)
        nmap <buffer> <S-m> <Plug>(neo4j-open-node)
        nmap <buffer> u <Plug>(neo4j-history-back)
        nmap <buffer> <C-r> <Plug>(neo4j-history-next)

      call win_gotoid(current_window_id)
    endif
endfunction


function! neo4jbible#set_keymap_infowindow(bufname) abort
    let current_window_id = win_getid()
    let targetwindow_id = bufwinid(a:bufname)
    if targetwindow_id != -1
      call win_gotoid(targetwindow_id)
        nnoremap <silent> <buffer>
          \ <Plug>(session-close)
          \ :<C-u> execute 'bwipeout!' g:neo4j_list_buffer_bible <CR>
          \ :<C-u> execute 'bwipeout!' g:neo4j_list_buffer_right <CR>
          \ :<C-u> execute 'bwipeout!' g:neo4j_list_buffer <CR>
        nnoremap <silent> <buffer>
          \ <Plug>(session-open)
          \ :<C-u> call neo4jbible#echo_line_data(g:result_dict[getline('.')]) <CR>
    
        " <Plug>マップをキーにマッピングします
        " `q` は最終的に :<C-u>bwipeout!<CR>
        " `Enter` は最終的に :<C-u>call session#load_session()<CR>
        " が実行されます
        nmap <buffer> q <Plug>(session-close)
        nmap <buffer> <CR> <Plug>(session-open)

      call win_gotoid(current_window_id)
    endif
endfunction

function! neo4jbible#move(num) abort
  let pos = getcurpos()
  let newpos = [pos[1] + a:num,pos[2],pos[3],pos[4]]
  call cursor(newpos)
  "echo(g:lists[trim(getline('.'))])
  call neo4jbible#infowindow(g:result_dict[trim(getline('.'))])
  python3 line = vim.eval('getline(".")')
  python3 bible_content = get_bible(line)
  python3 vim.command('let s:bible_content = "{}"'.format(bible_content.replace('"', '\\"')))
  "echo(s:bible_content)
  call neo4jbible#biblewindow(getline("."),0)
  call neo4jbible#biblewindow(s:bible_content,1)
endfunction

function! neo4jbible#openNode() abort
  let text = getline(".")
  call neo4jbible#make_windows_bible_merginalref(text)
endfunction

function! neo4jbible#infowindow(info) abort
    call neo4jbible#lock_unlock_window(g:neo4j_list_buffer_right, 'unlock')
    call neo4jbible#delete_window(g:neo4j_list_buffer_right)
    call InsertNewLine(g:neo4j_list_buffer_right, 1, a:info)
    call neo4jbible#lock_unlock_window(g:neo4j_list_buffer_right, 'lock')
endfunction

function! neo4jbible#biblewindow(info,offset) abort
    call neo4jbible#lock_unlock_window(g:neo4j_list_buffer_bible, 'unlock')
    "call neo4jbible#delete_window(g:neo4j_list_buffer_bible)
    call setbufline(g:neo4j_list_buffer_bible, 1+a:offset, a:info)
    call neo4jbible#lock_unlock_window(g:neo4j_list_buffer_bible, 'lock')
endfunction

function! neo4jbible#lock_unlock_window(bufname, lock_flag) abort
    let current_window_id = win_getid()
    let targetwindow_id = bufwinid(a:bufname)
    if targetwindow_id != -1
      call win_gotoid(targetwindow_id)

      " バッファの種類を指定します
      " ユーザが書き込むことはないバッファなので`nofile`に設定します
      " 詳細は`:h buftype`を参照してください
      setlocal buftype=nofile
        if a:lock_flag == 'lock'
          setlocal nomodifiable
        elseif a:lock_flag == 'unlock'
          setlocal modifiable
        endif
      call win_gotoid(current_window_id)
    endif
endfunction


function! neo4jbible#echo_line_data(msg) abort

  if g:neo4jbible#highlighted_lines == {}
    python3 line = vim.eval('getline(".")')
    python3 bible_content = get_bible(line)
    python3 vim.command('let s:bible_content = "{}"'.format(bible_content.replace('"', '\\"')))

    "call win_gotoid(g:current_window_id)
    call win_gotoid(neo4jbible#GetOtherWindowId())

    "echo a:msg
    call append(line('.')-1, a:msg)
    call append(line('.')-1, s:bible_content)
    call append(line('.')-1, g:result_dict[a:msg])

    "call append(line('.')+1, '')
    let pos = getcurpos()
    let newpos = [pos[1]+1 ,pos[2],pos[3],pos[4]]
    "call cursor(newpos)
    call win_gotoid(bufwinid(g:neo4j_list_buffer))
    normal 0
  else
    "call win_gotoid(g:current_window_id)
    call win_gotoid(GetOtherWindowId())

    for key in keys(g:neo4jbible#highlighted_lines)
      let s:key_bi = g:neo4jbible#highlighted_lines[key]
      python3 line = vim.eval('s:key_bi')
      python3 bible_content = get_bible(line)
      python3 vim.command('let s:bible_content = "{}"'.format(bible_content.replace('"', '\\"')))

      call append(line('.')-1, g:neo4jbible#highlighted_lines[key])
      call append(line('.')-1, s:bible_content)
      call append(line('.')-1, g:result_dict[g:neo4jbible#highlighted_lines[key]])
      "call append(line('.')-1, g:result_dict[key])
      let pos = getcurpos()
      let newpos = [pos[1]+1 ,pos[2],pos[3],pos[4]]
      "call cursor(newpos)
    endfor
    call win_gotoid(bufwinid(g:neo4j_list_buffer))
    normal 0
  endif
endfunction


" グローバル変数の初期化
let g:neo4jbible#highlighted_lines = {}
" 行をハイライトする関数
function! neo4jbible#selectLine() abort
    " 現在の行番号を取得
    let lnum = line('.')

    " 行がすでにハイライトされているかチェック
    if get(g:neo4jbible#highlighted_lines, lnum, '-1') == -1
        " ハイライトされていない場合、行をハイライトし、リストに追加
        call matchadd('Statement', '\%' . lnum . 'l')
        let g:neo4jbible#highlighted_lines[lnum] = getline('.')
    else
        " ハイライトされている場合、ハイライトを解除し、リストから削除
        echo('ハイライトされている')
        call remove(g:neo4jbible#highlighted_lines, lnum)
        call matchdelete(neo4jbible#findMatchByLinenum(lnum))
    endif
endfunction

function! neo4jbible#findMatchByLinenum(linenum) abort
    let matches = getmatches()
    for match in matches
        if match['pattern'] == '\%'.a:linenum.'l'
            return match['id']
        endif
    endfor
    return {}  " マッチが見つからなかった場合、空の辞書を返す
endfunction

function! neo4jbible#clearHighlight() abort
  call clearmatches()
  let g:neo4jbible#highlighted_lines = {}
endfunction

function! neo4jbible#getSelectedText()
    let selected_text = @"
    return selected_text
endfunction

function! InsertNewLine(buffer,num, text)
    " 改行で分割して配列にする
    let lines = split(a:text, '&return&')

    " 現在の行に配列の内容を挿入
    call setbufline(a:buffer, a:num, lines)
endfunction

function! neo4jbible#GetOtherWindowId()
  " 現在のタブページ内のすべてのウィンドウをループします。
  for winid in range(1, winnr('$'))
    " ウィンドウのバッファ名を取得します。
    let bufname = bufname(winid)
    " 特定の名前でない場合、そのウィンドウIDを返します。
    if bufname != g:neo4j_list_buffer && bufname != g:neo4j_list_buffer_right && bufname != g:neo4j_list_buffer_bible
      return bufwinid(winid)
    endif
  endfor
  " 該当するウィンドウがない場合は-1を返します。
  return -1

"  " 現在のタブページ内のすべてのウィンドウをループします。
"  for winid in win_findbuf(bufnr('%'))
"    " ウィンドウのバッファ名を取得します。
"    let bufname = bufname(winbufnr(winid))
"    " 特定の名前でない場合、そのウィンドウIDを返します。
"    if bufname != g:neo4j_list_buffer && bufname != g:neo4j_list_buffer_right && bufname != g:neo4j_list_buffer_bible
"      return winid
"    endif
"  endfor
"  " 該当するウィンドウがない場合は-1を返します。
"  return -1
endfunction

function! neo4jbible#delete_window(bufname) abort
    let current_window_id = win_getid()
    let targetwindow_id = bufwinid(a:bufname)
    if targetwindow_id != -1
      call win_gotoid(targetwindow_id)
      %delete _
      call win_gotoid(current_window_id)
    endif
endfunction