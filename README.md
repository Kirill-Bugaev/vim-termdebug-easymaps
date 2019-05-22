# termdebug-easymaps
Wrapper for Vim TermDebug plugin which sets temporary key maps for source code buffers during debug that makes debug procedure in Vim fast and easy.

## Introduction
Before use this plugin I recommend to replace native Vim TermDebug plugin with [patched TermDebug][].

This plugin is wrapper for Vim TermDebug plugin. It makes temporary maps for opened source code buffers and makes them nomodifiable if it is desirable during debug process. After debug has finished plugin restore maps that was before debug. It works in two modes. In first plugin set maps after debugger has been opened before actual debugging start. In second after debug process have been started. Switching between modes can be done by setting `g:termdebug_easymaps_treatopened` and `g:termdebug_easymaps_treatonrun` configure variables.

### Default key maps
`bs` - Set breakpoint

`bc` - Clear breakpoint

`s` - Step

`n` - Over (Next by gdb terms)

`f` - Finish

`r` - Run

`a` - Arguments

`i` - Stop

`c` - Continue

`e` - Evaluate

`gd` - Goto debugger window

`gp` - Goto debugged program window

`gs` - Goto source code window 

`tp` - Terminate debugged program

`td` - Terminate debugger

## Options

### termdebug_easymaps_debugcurrent
If `1` plugin will try to find program file with same name as current buffer and debug it when debugger starts. It is useful when current buffer is program code (eg. C code).
```vim
let g:termdebug_easymaps_debugcurrent = 1
```
(boolean, default `1`)

### termdebug_easymaps_opensource
If `1` plugin will try to open source code of debugged program in Source window when debugger starts.
```vim
let g:termdebug_easymaps_opensource = 1
```
(boolean, default `1`)

### termdebug_easymaps_focussource
If `1` plugin will set focus on Source window when debugger starts.
```vim
let g:termdebug_easymaps_focussource = 1
```
(boolean, default `1`)

### termdebug_easymaps_treatopened
If `1` plugin will set maps and nomodifiable state (if desirable) in already opened source code buffers (when debugger starts) and later manually opened source code buffers which belongs to debugged program. If big project (like Linux kernel) is debugged it may slow down Vim during debugger opening. In this case better to use `termdebug_easymaps_treatonrun` option (see below). 
```vim
let g:termdebug_easymaps_treatopened = 1
```
(boolean, default `1`)

### termdebug_easymaps_treatonrun
If `1` plugin will set maps and nomodifiable state (if desirable) only for source code buffers which would opened during debug process (eg. when breakpoint is reached). If `1` it abolishes behaviour defined by `g:termdebug_easymaps_treatopened` option.
```vim
let g:termdebug_easymaps_treatonrun = 1
```
(boolean, default `0`)

### termdebug_easymaps_timeout
Time in milliseconds during which plugin will wait debugger communication response. It is necessary because communication between plugin and debugger carried out asynchronously. So plugin send request to debugger and run wait response cycle which is finished when response is received or time setted by this option is elapsed.
```vim
let g:termdebug_easymaps_timeout = 5000
```
(numeric, default `5000`)

### termdebug_easymaps_nomodifiable
If `1` plugin will make source code buffers `nomodifiable` during debug process and restore previous state after debug is finished.
```vim
let g:termdebug_easymaps_nomodifiable = 1
```
(boolean, default `1`)

### termdebug_easymaps_forceterm
If `1` plugin will terminate debugged program and debugger after appropriate command is executed without confirmation.
```vim
let g:termdebug_easymaps_forceterm = 1
```
(boolean, default `1`)

### termdebug_easymaps_usermaps
```vim
let g:termdebug_easymaps_usermaps = 1
```
If `1` set user defined key maps instead of default. If you want to set some key map by default just not define appropriate global variable. Example:
```vim
" Set default key map for breakpoint installation
unlet g:termdebug_easymaps_break_map
```
If you want to switch off some key map define appropriate global variable with empty string value. Example:
```vim
" Switch off key map for breakpoint installation
let g:termdebug_easymaps_break_map = ''
```
(boolean, default `0`)

## Key maps
If you are going to change plugin default maps don't forget to set `g:termdebug_easymaps_usermaps = 1`

### termdebug_easymaps_break_map
Key map for breakpoint installation.
```vim
let g:termdebug_easymaps_break_map = 'bs'
```
(string, default `'bs'`)

### termdebug_easymaps_clear_map
Key map for breakpoint clearing.
```vim
let g:termdebug_easymaps_clear_map = 'bc'
```
(string, default `'bc'`)

### termdebug_easymaps_step_map
Key map for debug Step.
```vim
let g:termdebug_easymaps_step_map = 's'
```
(string, default `'s'`)

### termdebug_easymaps_over_map
Key map for debug Over (Next by gdb terms).
```vim
let g:termdebug_easymaps_over_map = 'n'
```
(string, default `'n'`)

### termdebug_easymaps_finish_map
Key map for debug Finish.
```vim
let g:termdebug_easymaps_finish_map = 'f'
```
(string, default `'f'`)

### termdebug_easymaps_run_map
Key map for debug Run.
```vim
let g:termdebug_easymaps_run_map = 'r'
```
(string, default `'r'`)

### termdebug_easymaps_arguments_map
Key map for debug Arguments.
```vim
let g:termdebug_easymaps_arguments_map = 'a'
```
(string, default `'a'`)

### termdebug_easymaps_stop_map
Key map for debug Stop.
```vim
let g:termdebug_easymaps_stop_map = 'i'
```
(string, default `'i'`)

### termdebug_easymaps_continue_map
Key map for debug Continue.
```vim
let g:termdebug_easymaps_continue_map = 'c'
```
(string, default `'c'`)

### termdebug_easymaps_evaluate_map
Key map for debug Evaluate.
```vim
let g:termdebug_easymaps_evaluate_map = 'e'
```
(string, default `'e'`)

### termdebug_easymaps_gdb_map
Key map for Goto Debugger window.
```vim
let g:termdebug_easymaps_gdb_map = 'gd'
```
(string, default `'gd'`)

### termdebug_easymaps_program_map
Key map for Goto debugged Program window.
```vim
let g:termdebug_easymaps_program_map = 'gp'
```
(string, default `'gp'`)

### termdebug_easymaps_source_map
Key map for Goto Source window.
```vim
let g:termdebug_easymaps_source_map = 'gs'
```
(string, default `'gs'`)

### termdebug_easymaps_termprog_map
Key map for Terminate debugged Program.
```vim
let g:termdebug_easymaps_termprog_map = 'tp'
```
(string, default `'tp'`)

### termdebug_easymaps_termdebug_map
Key map for Terminate Debugger.
```vim
let g:termdebug_easymaps_termdebug_map = 'td'
```
(string, default `'td'`)

## Commands
You will may be want to define map for debugger running:
```vim
nnoremap <silent> <Leader>gdb :TermdebugEasymaps<CR>
```

### TermdebugEasymaps
Analog of Vim `Termdebug` command. Without arguments run debugger for program file named as current buffers.

### TermdebugEasymapsCommand
Analog of Vim `TermdebugCommand` command. Without arguments run debugger for program file named as current buffers.

### TermdebugEasymapsUpdate
Update maps for opened source code buffers. Useful when new debug starts (eg. with gdb command `file {filename}`)

[patched TermDebug]: https://github.com/Kirill-Bugaev/vim-termdebug-vertical
