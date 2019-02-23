" obsession.vim - Fork of Tim Pope's Obsession.vim (https://github.com/tpope/vim-obsession)
" Maintainer:   studio.vx
" Version:      1.0

if exists("g:loaded_obsession") || v:version < 700 || &cp
  finish
endif
let g:loaded_obsession = 1
let g:obsession_last_save = localtime()

command! -bar -bang -complete=file -nargs=? Obsession
      \ execute s:dispatch(<bang>0, <q-args>)
command! ObsessionSave execute s:save()

function! s:dispatch(bang, file) abort
  let session = get(g:, 'this_obsession', v:this_session)
  try
    if a:bang && empty(a:file) && filereadable(session)
      echo 'Deleting session in '.fnamemodify(session, ':~:.')
      call delete(session)
      unlet! g:this_obsession
      return ''
    elseif empty(a:file) && exists('g:this_obsession')
      echo 'Pausing session in '.fnamemodify(session, ':~:.')
      unlet g:this_obsession
      return ''
    elseif empty(a:file) && !empty(session)
      let file = session
    elseif empty(a:file)
      let file = getcwd() . '/Session.vim'
    elseif isdirectory(a:file)
      let file = substitute(fnamemodify(expand(a:file), ':p'), '[\/]$', '', '')
            \ . '/Session.vim'
    else
      let file = fnamemodify(expand(a:file), ':p')
    endif
    if !a:bang
      \ && file !~# 'Session\.vim$'
      \ && filereadable(file)
      \ && getfsize(file) > 0
      \ && readfile(file, '', 1)[0] !=# 'let SessionLoad = 1'
      return 'mksession '.fnameescape(file)
    endif
    let g:this_obsession = file
    let error = s:persist()
    if empty(error)
      echo 'Tracking session in '.fnamemodify(file, ':~:.')
      let v:this_session = file
      return ''
    else
      return error
    endif
  finally
    let &l:readonly = &l:readonly
  endtry
endfunction

function! s:doautocmd_user(arg) abort
  if !exists('#User#' . a:arg)
    return ''
  elseif v:version >= 704
    return 'doautocmd <nomodeline> User ' . fnameescape(a:arg)
  else
    return 'try | let [save_mls, &mls] = [&mls, 0] | ' .
          \ 'doautocmd <nomodeline> User ' . fnameescape(a:arg) . ' | ' .
          \ 'finally | let &mls = save_mls | endtry'
  endif
endfunction

function! s:persist() abort
  if exists('g:SessionLoad')
    return ''
  endif
  let sessionoptions = &sessionoptions
  if exists('g:this_obsession')
    try
      set sessionoptions-=blank sessionoptions-=options sessionoptions+=tabpages
      execute 'mksession! '.fnameescape(g:this_obsession)
      let body = readfile(g:this_obsession)
      call insert(body, 'let g:this_session = v:this_session', -3)
      call insert(body, 'let g:this_obsession = v:this_session', -3)
      call insert(body, 'let g:this_obsession_status = 2', -3)
      if type(get(g:, 'obsession_append')) == type([])
        for line in g:obsession_append
          call insert(body, line, -3)
        endfor
      endif
      call writefile(body, g:this_obsession)
      let g:this_session = g:this_obsession
      exe s:doautocmd_user('Obsession')
      let g:obsession_last_save = localtime()
    catch
      unlet g:this_obsession
      let &l:readonly = &l:readonly
      return 'echoerr '.string(v:exception)
    finally
      let &sessionoptions = sessionoptions
    endtry
  endif
  return ''
endfunction

function! ObsessionStatus(...) abort
  let args = copy(a:000)
  let numeric = !empty(v:this_session) + exists('g:this_obsession')
  if type(get(args, 0, '')) == type(0)
    if !remove(args, 0)
      return ''
    endif
  endif
  if empty(args)
    let args = ['[$]', '[S]']
  endif
  if len(args) == 1 && numeric == 1
    let fmt = args[0]
  else
    let fmt = get(args, 2-numeric, '')
  endif
  let time_since_save = (localtime() - g:obsession_last_save) / 60
  if time_since_save >= 1
    let suffix = time_since_save > 1 ? ' mins)' : ' min)'
    let fmt .= ' (' . time_since_save . suffix
  endif
  return substitute(fmt, '%s', get(['', 'Session', 'Obsession'], numeric), 'g')
endfunction

function! s:save() abort
  execute s:persist()
  echom 'Obsession: session saved.'
endfunction

augroup obsession
  autocmd!
  autocmd BufWritePost * exe s:persist()
  autocmd User Flags call Hoist('global', 'ObsessionStatus')
augroup END

" vim:set et sw=2:
