
if exists("b:current_syntax")
	finish
endif

syntax match confTodo 'TODO' contained
syntax match confComment /#.*/ contains=confTodo

syntax match confNormal /[a-zA-Z0-9\_]\+/

syntax region confString start=/"/ skip=/\\\\\|\\"/ end=/"/

syntax match confNumber /\d\+\(\.\d\+\)\=\(\(deg\)\|%\)\=/

syntax keyword confBoolean true false on off yes no

syntax match confBuiltin /rgba\=\ze(\x*)/
syntax match confColor /rgba(\zs\x\+\ze)\|rgb(\zs\x\+\ze)\|0x\x*/

syntax match confKeyword /[a-z][A-Za-z0-9\_.]*\ze\s*=/
syntax match confVariable /\$[a-zA-Z0-9\_]\+/
syntax match confSubcategory /[a-zA-Z\_.]\+\ze\s*{/

highlight default link confTodo Todo
highlight default link confComment Comment

highlight default link confString String
highlight default link confNumber Number
highlight default link confBoolean Boolean
highlight default link confColor @variable.builtin
highlight default link confBuiltin @type.builtin

highlight default link confKeyword Function
highlight default link confVariable Define
highlight default link confSubcategory Structure

highlight default link confNormal Normal
