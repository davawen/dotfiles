" Vim syntax file
" Language: DotVM
"
" Usage: put this in your $MYVIMRUNTIME/syntax directory

set commentstring=//%s

if exists("b:current_syntax")
	finish
endif

syntax match bikeIdentifier '\M\[a-zA-Z_]\[a-zA-Z0-9_]\*'

syntax match bikeFunc '\M\[a-zA-Z_]\[a-zA-Z0-9_]\*\ze('
syntax match bikeIntrisic '\M\[a-zA-Z_]\[a-zA-Z0-9_]\*#\ze('

syntax match bikeNumber '\(0\(x\|X\)\x\+\)\|\(0\o\+\)\|\(\d\+\)'
syntax match bikeStringEscape '\\.' contained

syntax region bikeComment start='//' end='$'
syntax region bikeString start=/\v"/ skip=/\v\\./ end=/\v"/ contains=bikeStringEscape

syntax keyword bikeKeyword func let return break loop if else type struct
syntax keyword bikeBool true false
syntax keyword bikeType u8 i8 u32 i32 u64 i64 bool void str

let b:current_syntax = "bikelang"

hi default link bikeComment Comment

hi default link bikeIdentifier Normal
hi default link bikeFunc Function
hi default link bikeIntrisic Macro
hi default link bikeNumber Number 
hi default link bikeString String
hi default link bikeStringEscape Number
hi default link bikeBool Bool 

hi default link bikeKeyword Keyword 
hi default link bikeType Type 


