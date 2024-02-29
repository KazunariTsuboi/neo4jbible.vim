py3file <sfile>:h:h/python3/neo4jbible.py
python3 import vim

" 一覧作成用のバッファ名
let g:neo4j_list_buffer = "NEO4JLISTS"
let g:neo4j_list_buffer_right = "NEO4JLISTS_RIGHT"


function! neo4jbible#testlist() abort
    setlocal modifiable
    " 現在のウィンドウIDの取得
    let g:current_window_id = win_getid()
    python3 vim.command(f'let g:lists = {neo4jbible_getlist2()}')

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
  
      " バッファの種類を指定します
      " ユーザが書き込むことはないバッファなので`nofile`に設定します
      " 詳細は`:h buftype`を参照してください
      set buftype=nofile
  
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
        \ :<C-u> execute 'bwipeout!' g:neo4j_list_buffer_right <CR>
        \ :<C-u> execute 'bwipeout!' g:neo4j_list_buffer <CR>
      nnoremap <silent> <buffer>
        \ <Plug>(session-open)
        \ :<C-u> call neo4jbible#echo_line_data(g:lists[trim(getline('.'))]) <CR>
  
      " <Plug>マップをキーにマッピングします
      " `q` は最終的に :<C-u>bwipeout!<CR>
      " `Enter` は最終的に :<C-u>call session#load_session()<CR>
      " が実行されます
      nmap <buffer> j <Plug>(session-move-j)
      nmap <buffer> k <Plug>(session-move-k)
      nmap <buffer> q <Plug>(session-close)
      nmap <buffer> <CR> <Plug>(session-open)
    endif
  
    " セッションファイルを表示する一時バッファのテキストをすべて削除して、取得したファイル一覧をバッファに挿入します
    %delete _
    call setline(1, keys(g:lists))
    setlocal nomodifiable
endfunction


function! neo4jbible#move(num) abort
  let pos = getcurpos()
  let newpos = [pos[1] + a:num,pos[2],pos[3],pos[4]]
  call cursor(newpos)
  echo(g:lists[trim(getline('.'))])
  call neo4jbible#infowindow(g:lists[trim(getline('.'))])
endfunction

function! neo4jbible#infowindow(info) abort
    call neo4jbible#lock_unlock_window(g:neo4j_list_buffer_right, 'unlock')
    call setbufline(g:neo4j_list_buffer_right, 1, a:info)
    call neo4jbible#lock_unlock_window(g:neo4j_list_buffer_right, 'lock')
endfunction

function! neo4jbible#lock_unlock_window(bufname, lock_flag) abort
    let current_window_id = win_getid()
    let targetwindow_id = bufwinid(a:bufname)
    if targetwindow_id != -1
      call win_gotoid(targetwindow_id)
        if a:lock_flag == 'lock'
          setlocal nomodifiable
        elseif a:lock_flag == 'unlock'
          setlocal modifiable
        endif
      call win_gotoid(current_window_id)
    endif
endfunction


function! neo4jbible#echo_line_data(msg) abort
  call win_gotoid(g:current_window_id)
  echo a:msg
endfunction

