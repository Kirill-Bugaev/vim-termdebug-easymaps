" ============================================================================
" File:        termdebug-easymaps.vim
" Date:	       March 6, 2019
" Description: Set temporary maps for source buffers during debug
" Author:      Kirill Bugaev <kirill.bugaev87@gmail.com>
" Licence:     Vim licence
" Website:     https://github.com/Kirill-Bugaev/vim-termdebug-easymaps
" Version:     0.1
"
" Copyright notice:
"              Permission is hereby granted to use and distribute this code,
"              with or without modifications, provided that this copyright
"              notice is copied with it. Like anything else that's free,
"              plugin is provided *as is* and comes with no warranty of
"              any kind, either expressed or implied. In no event will the
"              copyright holder be liable for any damamges resulting from the
"              use of this software.
" ============================================================================

" Set user defined and default config
" Open source file when gdb starts
if !exists('g:termdebug_easymaps_opensource')
	let g:termdebug_easymaps_opensource = 1
endif
" Focus source window when gdb starts
if !exists('g:termdebug_easymaps_focussource')
	let g:termdebug_easymaps_focussource = 1
endif
" Treat (set maps and modifiable flag) opened source buffers when gdb starts
if !exists('g:termdebug_easymaps_treatopened')
	let g:termdebug_easymaps_treatopened = 1
endif
" Treat (set maps and modifiable state) source buffers when gdb opens it when
" running
if exists('g:termdebug_easymaps_treatonrun')
	if g:termdebug_easymaps_treatonrun
		let g:termdebug_easymaps_treatopened = 0
	endif
else
	let g:termdebug_easymaps_treatonrun = 0
endif
" Timeout in milliseconds after which request to gdb considered expired
if !exists('g:termdebug_easymaps_timeout')
	let g:termdebug_easymaps_timeout = 5000
endif
" Set source buffers no modifiable on treat
if !exists('g:termdebug_easymaps_nomodifiable')
	let g:termdebug_easymaps_nomodifiable = 1
endif
" Don't request confirmation when terminate debuged program or gdb
if !exists('g:termdebug_easymaps_forceterm')
	let g:termdebug_easymaps_forceterm = 1
endif
" User defined or default maps toggle
if !exists('g:termdebug_easymaps_usermaps')
	let g:termdebug_easymaps_usermaps = 0
endif

" Define maps
" Set break point
if !exists('g:termdebug_easymaps_break_map') || !g:termdebug_easymaps_usermaps
	let g:termdebug_easymaps_break_map = 'bs'
endif
" Clear break point
if !exists('g:termdebug_easymaps_clear_map') || !g:termdebug_easymaps_usermaps
	let g:termdebug_easymaps_clear_map = 'bc'
endif
" Step
if !exists('g:termdebug_easymaps_step_map') || !g:termdebug_easymaps_usermaps
	let g:termdebug_easymaps_step_map = 's'
endif
" Over (next)
if !exists('g:termdebug_easymaps_over_map') || !g:termdebug_easymaps_usermaps
	let g:termdebug_easymaps_over_map = 'n'
endif
" Finish
if !exists('g:termdebug_easymaps_finish_map') || !g:termdebug_easymaps_usermaps
	let g:termdebug_easymaps_finish_map = 'f'
endif
" Run
if !exists('g:termdebug_easymaps_run_map') || !g:termdebug_easymaps_usermaps
	let g:termdebug_easymaps_run_map = 'r'
endif
" Arguments
if !exists('g:termdebug_easymaps_arguments_map') || !g:termdebug_easymaps_usermaps
	let g:termdebug_easymaps_arguments_map = 'a'
endif
" Stop
if !exists('g:termdebug_easymaps_stop_map') || !g:termdebug_easymaps_usermaps
	let g:termdebug_easymaps_stop_map = 'i'
endif
" Continue
if !exists('g:termdebug_easymaps_continue_map') || !g:termdebug_easymaps_usermaps
	let g:termdebug_easymaps_continue_map = 'c'
endif
" Evaluate
if !exists('g:termdebug_easymaps_evaluate_map') || !g:termdebug_easymaps_usermaps
	let g:termdebug_easymaps_evaluate_map = 'e'
endif
" Go to gdb window
if !exists('g:termdebug_easymaps_gdb_map') || !g:termdebug_easymaps_usermaps
	let g:termdebug_easymaps_gdb_map = 'gd'
endif
" Go to debuged program window
if !exists('g:termdebug_easymaps_program_map') || !g:termdebug_easymaps_usermaps
	let g:termdebug_easymaps_program_map = 'gp'
endif
" Go to source window
if !exists('g:termdebug_easymaps_source_map') || !g:termdebug_easymaps_usermaps
	let g:termdebug_easymaps_source_map = 'gs'
endif
" Terminate program
if !exists('g:termdebug_easymaps_termprog_map') || !g:termdebug_easymaps_usermaps
	let g:termdebug_easymaps_termprog_map = 'tp'
endif
" Terminate gdb
if !exists('g:termdebug_easymaps_termdebug_map') || !g:termdebug_easymaps_usermaps
	let g:termdebug_easymaps_termdebug_map = 'td'
endif

" Falgs that define s:CommOutput() function behavior which communicates with
" 'gdb communication easymaps' buffer.
" s:commflags['current_source'] = 1 waiting for 'info source' gdb command
" response.
" s:commflags['all_sources'] = 1 waiting for 'info sources' gdb command
" response.
" s:commflags['debug_run'] = 1 then waiting for 'info program' gdb command
" response.
" Callback (s:CommOutput() function) is asynchronous. Be careful!
let s:commflags = { 'current_source': 0, 'all_sources': 0, 'program_run': 0 }

" Time value in milliseconds for sleep command. Defines step of timeout cycle.
let s:sleeptime = 10

" Source window id
let s:sourcewin = -1
" gdb buffer nr
let s:gdbbuf = -1
" easymaps communication buffer nr
let s:commbuf = -1

" Values of next variables returned by s:CommOutput function.
" It is global only because this function calls are asynchronous,
" so function can't return value usual way.
" Current source file path
let s:current_source = ''
" All source files list
let s:source_list = []
" Debugged program run state
let s:program_run = 0

" End suffix of output returned to s:CommOutput() function
" by gdb request. Used because gdb request can be divided
" into multiple messages.
let s:gdbreq_donsuf = '^done' . "\r\n" . '(gdb) ' . "\r\n"
let s:gdbreq_errsuf = '^error'
let s:gdbreq_brksuf = '^\(\*stopped\|=thread-selected\)'
" Merged output of gdb request
let s:reqout = ''

" Saved buffers state (maps and modifiable)
" Dictionary { 'bufnr': {'modifiable': 0/1, 'maps': []} }
let s:saved_buffers_state = {}

" List of maps which will be saved
let s:savedmaps = []
call add(s:savedmaps, g:termdebug_easymaps_break_map)
call add(s:savedmaps, g:termdebug_easymaps_clear_map)
call add(s:savedmaps, g:termdebug_easymaps_step_map)
call add(s:savedmaps, g:termdebug_easymaps_over_map)
call add(s:savedmaps, g:termdebug_easymaps_finish_map)
call add(s:savedmaps, g:termdebug_easymaps_run_map)
call add(s:savedmaps, g:termdebug_easymaps_arguments_map)
call add(s:savedmaps, g:termdebug_easymaps_stop_map)
call add(s:savedmaps, g:termdebug_easymaps_continue_map)
call add(s:savedmaps, g:termdebug_easymaps_evaluate_map)
call add(s:savedmaps, g:termdebug_easymaps_gdb_map)
call add(s:savedmaps, g:termdebug_easymaps_program_map)
call add(s:savedmaps, g:termdebug_easymaps_source_map)
call add(s:savedmaps, g:termdebug_easymaps_termprog_map)
call add(s:savedmaps, g:termdebug_easymaps_termdebug_map)

func s:StartDebug(bang, ...)	
	" First argument is the command to debug, second core file or process ID.
	call s:StartDebug_internal(0, a:000, a:bang)
endfunc

func s:StartDebugCommand(bang, ...)
	" First argument is the command to debug, rest are run arguments.
	call s:StartDebug_internal(1, a:000, a:bang)
endfunc

func s:StartDebug_internal(command_mode, args, bang)
	if bufexists('!gdb')
		echo 'Termdebug already running!'
		return
	endif

	" Start Termdebug and create communication window
	if a:command_mode
		let l:cmd = 'TermdebugCommand'
	else
		let l:cmd = 'Termdebug'
	endif
	if a:bang 
		let l:cmd .= '!'
	endif
	let l:cmd .= ' ' . join(a:args)
	exe l:cmd
	call s:CreateCommWin()

	" Set focus on Source window
	" if Termdebug doesn't set focus on Source window by default
	if !(exists('g:termdebug_focussource') && g:termdebug_focussource)
		if !g:termdebug_easymaps_focussource
			let l:previous_winid = win_getid(winnr())
		endif
		" will use Source window id if it is possible
		if exists('g:termdebug_sourcewin')
			call win_gotoid(g:termdebug_sourcewin)
		else " or set focus on Source window blindly
			if exists('g:termdebug_vertsource')
						\ && g:termdebug_vertsource	
				if exists('g:termdebug_leftsource')
							\&& g:termdebug_leftsource
					exe 'wincmd h'
				else
					exe 'wincmd l'
				endif
			else
				exe 'wincmd j'
				exe 'wincmd j'
			endif
		endif
	endif
	" Save Source window id. It may be useful in future.
	let s:sourcewin = win_getid(winnr())

	" Get full name of current source file
	" and open it if desirable
	if g:termdebug_easymaps_opensource
		call s:OpenCurrentSource()
	endif
	
	" Scan opened buffers for belonging debuged program
	" and treat (set maps and modifiable state) them if desirable
	if g:termdebug_easymaps_treatopened && !g:termdebug_easymaps_treatonrun
		call s:GetSourceList()
		call s:TreatOpenedBuffersOnStart()	
	end

	" Restore focus
	if exists('l:previous_winid')
		call win_gotoid(l:previous_winid)
		unlet l:previous_winid
	endif

	" Add autocmd group
	augroup termdebug-easymaps
		autocmd!
		autocmd BufWipeout * call s:OnWipeoutEvent()
		autocmd BufDelete * call s:OnBufDeleteEvent()
		if g:termdebug_easymaps_treatopened && !g:termdebug_easymaps_treatonrun
			autocmd BufReadPost * call s:OnBufReadPostEvent()
		endif
	augroup END
endfunc

func s:TerminateProgram()
	if s:ProgramRunState()
		exe 'call TermDebugSendCommand("kill")'
		if g:termdebug_easymaps_forceterm
			exe 'call TermDebugSendCommand("y")'
		else
			call s:GoToDebugWindow()
		endif
	else
		echo 'Debugged program not started yet!'
	endif
endfunc

func s:StopTermdebug()
	if bufexists('!gdb')
		let runstate = s:ProgramRunState()
		exe 'call TermDebugSendCommand("quit")'
		if runstate
			if g:termdebug_easymaps_forceterm
				exe 'call TermDebugSendCommand("y")'
			else
				call s:GoToDebugWindow()
			endif
		endif
	else
		echo 'Termdebug not started yet!'
	endif
endfunc

func s:GoToDebugWindow()
	let gdbwinlist = win_findbuf(s:gdbbuf)
	if len(gdbwinlist) > 0
		call win_gotoid(gdbwinlist[0])
	else
		exe 'buffer ' . s:gdbbuf
	endif
	silent! exe 'normal! i'
endfunc

func s:OpenCurrentSource()
	let l:current_source = s:GetCurrentSourceFullname()
	if l:current_source != '' && filereadable(l:current_source)
		if expand('%:p') != fnamemodify(l:current_source, ':p')
			if &modified
				exe 'split ' . fnameescape(l:current_source)
				" Disable first Source window
				" and enable second if it is possible
				if exists('*g:Termdebug_InstallWinbar')
							\ && exists('*g:Termdebug_RemoveWinbar')
							\ && exists('*g:Termdebug_SetSourcewinid')
					let l:cur_winid = win_getid(winnr())
					call win_gotoid(s:sourcewin)
					call g:Termdebug_RemoveWinbar()
					call win_gotoid(l:cur_winid)
					call g:Termdebug_InstallWinbar()
					call Termdebug_SetSourcewinid(l:cur_winid)
					let s:sourcewin = l:cur_winid
				endif
			else
				exe 'edit ' . fnameescape(l:current_source)
			endif
		endif
	endif
endfunc

" This function should be run only at the start of debugger.
func s:GetCurrentSourceFullname()
	let s:commflags['current_source'] = 1
	" First send 'list 1,1' command to gdb in order to gdb responses on
	" 'info source' command proper way. I don't know how to force gdb
	" print current source file name otherwise.
    call term_sendkeys(s:commbuf, "list 1,1" . "\r")
    call term_sendkeys(s:commbuf, "info source" . "\r")

	" Wait response from s:CommOutput() function
	let timeout = g:termdebug_easymaps_timeout
	let elapsedtime = 0
	while s:commflags['current_source']	&& elapsedtime <= timeout 
		exe 'sleep ' . s:sleeptime . ' m'
		let elapsedtime += s:sleeptime
	endwhile
	" If no response
	if s:commflags['current_source']
		let retvalue = ''
	else
		let retvalue = s:current_source
	endif

	" Restore list count
    call term_sendkeys(s:commbuf, "list 0,0" . "\r")
	return retvalue
endfunc

" Scan opened buffers for belonging debuged program and treat (set maps and
" modifiable state) them.
func s:TreatOpenedBuffersOnStart()
	let initial_bufnr = bufnr('%')
	let opened_buffers = s:GetOpenedSourceBuffersList()
	for curbufnr in opened_buffers
		exe 'buffer ' . curbufnr 
		call s:SaveCurrentBufferState()
		call s:MapCurrentBuffer()
	endfor
	" Go back to initial buffer
	exe 'buffer ' . initial_bufnr
endfunc

" Restore saved maps and make new
func s:UpdateMaps()
	call s:RestoreBuffersState()
	call s:GetSourceList()
	call s:TreatOpenedBuffersOnStart()
endfunc

" Save all defined in plugin maps and modifiable state of current buffer
func s:SaveCurrentBufferState()
	" Get current buffer nr
	let cur_bufnr = bufnr('%')
	" Add item for current buffer in saved buffers state dictionary
	let s:saved_buffers_state[cur_bufnr] = {}
	" Save modifiable state
	if g:termdebug_easymaps_nomodifiable
		let s:saved_buffers_state[cur_bufnr].modifiable = &modifiable
	endif
	" Save buffer maps
	let s:saved_buffers_state[cur_bufnr].maps =
				\ user9433424#savemaps#Save_mappings(s:savedmaps, 'n', 0)
endfunc

" Restore all buffers listed in s:saved_buffers_state
func s:RestoreBuffersState()
	" Try to jump to source window
	call win_gotoid(s:sourcewin)
	let initial_bufnr = bufnr('%')
	for key in keys(s:saved_buffers_state)
		" Check buffer exists and listed
		if buflisted(str2nr(key))
			exe 'buffer ' . key 
			call s:RestoreCurrentBuffersState()
		endif
	endfor
	" Go back to initial buffer
	silent! exe 'buffer ' . initial_bufnr
	let s:saved_buffers_state = {}
endfunc

" Restore all defined in plugin maps and modifiable flag of current buffer
func s:RestoreCurrentBuffersState()
	" Get current buffer nr
	let cur_bufnr = bufnr('%')
	" Restore modifiable state
	if g:termdebug_easymaps_nomodifiable
		if s:saved_buffers_state[cur_bufnr].modifiable
			setlocal modifiable
		else
			setlocal nomodifiable
		endif
	endif
	" Restore buffer maps
	call user9433424#savemaps#Restore_mappings(s:saved_buffers_state[cur_bufnr].maps)
endfunc

" Map current buffer for all defined in plugin maps
func s:MapCurrentBuffer()
	" Set buffer not modifiable if it is desirable
	if g:termdebug_easymaps_nomodifiable
		setlocal nomodifiable
	endif
	" Set maps
	if g:termdebug_easymaps_break_map != ''
		exe 'nnoremap <silent> <buffer> ' . g:termdebug_easymaps_break_map
					\ . ' :Break<CR>'
	endif
	if g:termdebug_easymaps_clear_map != ''
		exe 'nnoremap <silent> <buffer> ' . g:termdebug_easymaps_clear_map
					\ . ' :Clear<CR>'
	endif
	if g:termdebug_easymaps_step_map != ''
		exe 'nnoremap <silent> <buffer> ' . g:termdebug_easymaps_step_map
					\ . ' :Step<CR>'
	endif
	if g:termdebug_easymaps_over_map != ''
		exe 'nnoremap <silent> <buffer> ' . g:termdebug_easymaps_over_map
					\ . ' :Over<CR>'
	endif
	if g:termdebug_easymaps_finish_map != ''
		exe 'nnoremap <silent> <buffer> ' . g:termdebug_easymaps_finish_map
					\ . ' :Finish<CR>'
	endif
	if g:termdebug_easymaps_run_map != ''
		exe 'nnoremap <silent> <buffer> ' . g:termdebug_easymaps_run_map
					\ . ' :Run<CR>'
	endif
	if g:termdebug_easymaps_arguments_map != ''
		exe 'nnoremap <silent> <buffer> ' . g:termdebug_easymaps_arguments_map
					\ . ' :Arguments<CR>'
	endif
	if g:termdebug_easymaps_stop_map != ''
		exe 'nnoremap <silent> <buffer> ' . g:termdebug_easymaps_stop_map
					\ . ' :Stop<CR>'
	endif
	if g:termdebug_easymaps_continue_map != ''
		exe 'nnoremap <silent> <buffer> ' . g:termdebug_easymaps_continue_map
					\ . ' :Continue<CR>'
	endif
	if g:termdebug_easymaps_evaluate_map != ''
		exe 'nnoremap <silent> <buffer> ' . g:termdebug_easymaps_evaluate_map
					\ . ' :Evaluate<CR>'
	endif
	if g:termdebug_easymaps_gdb_map != ''
		exe 'nnoremap <silent> <buffer> ' . g:termdebug_easymaps_gdb_map
					\ . ' :Gdb<CR>'
	endif
	if g:termdebug_easymaps_program_map != ''
		exe 'nnoremap <silent> <buffer> ' . g:termdebug_easymaps_program_map
					\ . ' :Program<CR>'
	endif
	if g:termdebug_easymaps_source_map != ''
		exe 'nnoremap <silent> <buffer> ' . g:termdebug_easymaps_source_map
					\ . ' :Source<CR>'
	endif
	if g:termdebug_easymaps_termprog_map != ''
		exe 'nnoremap <silent> <buffer> ' . g:termdebug_easymaps_termprog_map
					\ . ' :call <SID>TerminateProgram()<CR>'
	endif
	if g:termdebug_easymaps_termdebug_map != ''
		exe 'nnoremap <silent> <buffer> ' . g:termdebug_easymaps_termdebug_map
					\ . ' :call <SID>StopTermdebug()<CR>'
	endif
endfunc

" Get full list of source files by gdb request
func s:GetSourceList()
	let s:commflags['all_sources'] = 1
    call term_sendkeys(s:commbuf, "info sources" . "\r")
	
	" Wait response from s:CommOutput() function
	let timeout = g:termdebug_easymaps_timeout
	let elapsedtime = 0
	while s:commflags['all_sources'] && elapsedtime <= timeout
		exe 'sleep ' . s:sleeptime . ' m'
		let elapsedtime += s:sleeptime
	endwhile
endfunc

" Return list of opened source buffers.
func s:GetOpenedSourceBuffersList()
	let retlist = []
	" Scan all buffers for matching sources
	for bufitem in getbufinfo({'buflisted':1})
		" I hope that callback (s:CommOutput() function) is synchronous
		for sourcename in s:source_list
			if fnamemodify(sourcename, ':p') ==# fnamemodify(bufitem.name, ':p')
				call add(retlist, bufitem.bufnr)
				break
			endif
		endfor
	endfor
	return retlist
endfunc

" Return debugged program running state
func s:ProgramRunState()
	let s:commflags['program_run'] = 1
    call term_sendkeys(s:commbuf, "info program" . "\r")
	
	" Wait response from s:CommOutput() function
	let timeout = g:termdebug_easymaps_timeout
	let elapsedtime = 0
	while s:commflags['program_run'] && elapsedtime <= timeout
		exe 'sleep ' . s:sleeptime . ' m'
		let elapsedtime += s:sleeptime
	endwhile
	if !s:commflags['program_run']
		return s:program_run
	else
		return 0
	endif
endfunc

func s:CloseBuffers()
	" Close communication buffer
	exe 'bwipe! ' . s:commbuf
	unlet s:commbuf
	" Delete orphan !gdb buffer if it still exists
	if bufexists('!gdb') 
		silent! exe 'bwipe! !gdb'
	endif
endfunc

func s:CreateCommWin()
	" Create a hidden terminal window to communicate with gdb
	let s:commbuf = term_start('NONE', {
		\ 'term_name': 'easymaps gdb communication',
		\ 'out_cb': function('s:CommOutput'),
		\ 'hidden': 1,
		\ })
	if s:commbuf == 0
		echoerr 'Failed to open easymaps communication terminal window'
    	return 0
  	endif
  	let l:commpty = job_info(term_getjob(s:commbuf))['tty_out']
	" Connect gdb to the communication pty, using the GDB/MI interface
	let s:gdbbuf =	bufnr('!gdb')
 	call term_sendkeys(s:gdbbuf, 'new-ui mi ' . l:commpty . "\r")
	return 1
endfunc

func s:CommOutput(out, msg)
	" Merge output
	let s:reqout .= a:msg
	
	" Check stop suffixes
	let msgs = split(a:msg, "\r")
	let stop = 0
	for msg in msgs
		" remove prefixed NL
		if msg[0] ==# "\n"
			let msg = msg[1:]
		endif
		if msg[:len(s:gdbreq_errsuf) - 1] ==# s:gdbreq_errsuf
					\ || msg =~# s:gdbreq_brksuf
			let stop = 1
			break
		endif
	endfor

	" If error response or last message is reached
	if l:stop || a:msg[len(a:msg) - len(s:gdbreq_donsuf):len(a:msg) - 1] ==#
				\ s:gdbreq_donsuf
		call s:ProcessGdbRequestOutput()
		let s:reqout = ''
	endif
endfunc

func s:ProcessGdbRequestOutput()
	let msgs = split(s:reqout, "\r")

	" Define sources part flag just in case all source files have been
	" requested
	if s:commflags['all_sources']
		let sources_part = 0
	endif

 	for msg in msgs
		" remove prefixed NL
		if msg[0] ==# "\n"
			let msg = msg[1:]
		endif

		if msg == ''
			continue
		end

		" If request of current source file has been done
		if s:commflags['current_source']	
			" If path of current source file was received 
			if msg =~# 'Located in'
				" Extract file path (This is Windows incompatible. TODO) 
				let s:current_source = ''
				let i = 0
				while i < len(msg) && msg[i] != '/'
					let i += 1
				endwhile
				while i < len(msg) && msg[i] != '\'
					let s:current_source .= msg[i]
					let i += 1
				endwhile
				let s:commflags['current_source'] = 0
				break
			elseif  msg =~# 'No symbol table is loaded'
						\ || msg =~# 'No such file or directory'
				let s:current_source = ''
				let s:commflags['current_source'] = 0
				break
			endif
		endif

		" If request of all source files has been done
		if s:commflags['all_sources']
			" Set flag means that further will received first part of
			" source files
			if msg =~# 'Source files for which symbols have been read in'
				let sources_part = 1
			" Set flag means that further will received second part of
			" source files
			elseif msg =~# 'Source files for which symbols will be read in on demand'
				let sources_part = 2
			" If second part of source files is empty reset sources
			" request flag
			elseif  msg[0:4] == '~"\n"' && sources_part == 2
				let s:commflags['all_sources'] = 0
				break
			" If paths of source files was received
			elseif msg[0:2] == '~"/'
				" Extract files paths (This is Windows incompatible. TODO) 
				" If received first part of source files create source
				" list
				if sources_part == 1
					let s:source_list = []
				endif
				let i = 2
				while i < len(msg) && msg[i:i+1] !=# '\n'
					let flpath = ''
					while i < len(msg) && msg[i:i+1] != ', '
								\ && msg[i:i+1] !=# '\n'
						let flpath .= msg[i]
						let i += 1
					endwhile
					" Add file path to list if it hasn't been added before
					if match(s:source_list, flpath) == -1
						let s:source_list += [flpath]
					endif
					if msg[i:i+1] == ', '
						let i += 2
					endif
				endwhile
				" If received second part of source files reset sources
				" request flag
				if sources_part == 2
					let s:commflags['all_sources'] = 0
					break
				endif
			elseif msg =~# 'No symbol table is loaded'
				let s:source_list = []
				let s:commflags['all_sources'] = 0
				break
			endif
		endif

		" If request of debugged program running state
		if s:commflags['program_run']
			if msg =~# 'Using the running image of child'
						\ || msg =~# 'Selected thread is running'
				let s:program_run = 1
				let s:commflags['program_run'] = 0
			elseif msg =~# 'The program being debugged is not being run'
				let s:program_run = 0
				let s:commflags['program_run'] = 0
			endif
		endif

"		" If user loads/reloads debug symbols
"		if msg =~# 'Reading symbols from '
"			if g:termdebug_easymaps_treatopened && !g:termdebug_easymaps_treatonrun
"				call s:UpdateMaps()
"			else
"				call s:RestoreBuffersState()
"			endif
"			if g:termdebug_easymaps_opensource
"				call s:OpenCurrentSource()
"			endif
"		endif
		

		" If gdb stops on breakpoint
		if g:termdebug_easymaps_treatonrun
					\ && msg =~# '^\(\*stopped\|=thread-selected\)'
					\ && msg =~# 'fullname='
    		let fname = s:GetFullname(l:msg)
			if filereadable(fname)
				" Wait until Vim have opened buffer
				let timeout = g:termdebug_easymaps_timeout
				let elapsedtime = 0
				while !bufexists(fname)	&& elapsedtime <= timeout 
					exe 'sleep ' . s:sleeptime . ' m'
					let elapsedtime += s:sleeptime
				endwhile
				" If Vim have opened buffer
				if bufexists(fname)
					" Save current buffer number
					let current_bufnr = bufnr('%')
					let opened_bufnr = bufnr(fname)
					" If opened not treated yet
					if !has_key(s:saved_buffers_state, opened_bufnr)
						" Switch to opened buffer
						exe 'buffer ' . opened_bufnr
						call s:SaveCurrentBufferState()
						call s:MapCurrentBuffer()
					endif
					" Restore previous buffer
					exe 'buffer ' .current_bufnr
				endif
			endif
		endif
	endfor
endfunc

" Extract the "name" value from a gdb message with fullname="name".
func s:GetFullname(msg)
  if a:msg !~ 'fullname'
    return ''
  endif
  let name = s:DecodeMessage(substitute(a:msg, '.*fullname=', '', ''))
  if has('win32') && name =~ ':\\\\'
    " sometimes the name arrives double-escaped
    let name = substitute(name, '\\\\', '\\', 'g')
  endif
  return name
endfunc

" Decode a message from gdb.  quotedText starts with a ", return the text up
" to the next ", unescaping characters.
func s:DecodeMessage(quotedText)
  if a:quotedText[0] != '"'
    echoerr 'DecodeMessage(): missing quote in ' . a:quotedText
    return
  endif
  let result = ''
  let i = 1
  while a:quotedText[i] != '"' && i < len(a:quotedText)
    if a:quotedText[i] == '\'
      let i += 1
      if a:quotedText[i] == 'n'
        " drop \n
        let i += 1
        continue
      endif
    endif
    let result .= a:quotedText[i]
    let i += 1
  endwhile
  return result
endfunc

func s:OnWipeoutEvent()
	let l:wiped_bufnr = str2nr(expand('<abuf>'))
	" Check if wiped buffer is gdb and should restore maps of buffers
	if (exists('s:gdbbuf') && l:wiped_bufnr == s:gdbbuf) ||
				\l:wiped_bufnr == bufnr('gdb communication')
		" Restore buffers maps and modifiable state
		call s:RestoreBuffersState()	
		call s:CloseBuffers()
		silent! exe 'bwipe! ' . s:commbuf
		" Remove autocmd events
		augroup termdebug-easymaps
			autocmd!
		augroup END
		" Report that everything is OK
		echo 'termdebug-easymaps stopped'
	endif
endfunc

func s:OnBufDeleteEvent()
	" Remove appropriate item in s:saved_buffers_state dictionary
	" after buffer has been deleted
	if has_key(s:saved_buffers_state, expand('<abuf>'))
		call remove(s:saved_buffers_state, expand('<abuf>'))
	endif
endfunc

func s:OnBufReadPostEvent()
	" Get opened source buffers list
	let opened_sources = s:GetOpenedSourceBuffersList()
	" Get added buffer number
	let added_bufnr = bufnr('%')
	" If treat opened is desirable, buffer in sources list and not treated 
	if index(opened_sources, added_bufnr) >= 0
				\ && !has_key(s:saved_buffers_state, added_bufnr)
		call s:SaveCurrentBufferState()
		call s:MapCurrentBuffer()
	endif
endfunc

packadd termdebug

command! -bar -nargs=* -complete=file -bang TermdebugEasymaps
			\ call s:StartDebug(<bang>0, <f-args>)
command! -bar -nargs=* -complete=file -bang TermdebugEasymapsCommand
			\ call s:StartDebugCommand(<bang>0, <f-args>)
command! -bar -nargs=0 TermdebugEasymapsUpdate
			\ call s:UpdateMaps()
