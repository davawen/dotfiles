
if exists("b:current_syntax")
	finish
endif

syntax match pest_string_escape '\\.' contained
syntax region pest_string start=/\v\^?"/ skip=/\v\\./ end=/\v"/ contains=pest_string_escape

syntax match func_call '\v[a-zA-Z_]+\[' contains=func,pest_bracket
syntax match func '\v[a-zA-Z_]+' contained

syntax match pest_operator '\v\||\&|\!|\*|\+|\?|(\{[0-9]*(,[0-9]*)?\})|\-|\~|\='
syntax match rule_declaration '\v[a-zA-Z_]+\s*\=\s*_?\{' contains=modifier,rule
syntax match modifier '_' contained
syntax match rule '\v[a-zA-Z][a-zA-Z_]*' contained

syntax match pest_bracket '[[\]()]'

syntax keyword pest_builtin ANY SOI EOI WHITESPACE COMMENT BLANK NEWLINE ASCII_DIGIT ASCII_NONZERO_DIGIT ASCII_BIN_DIGIT ASCII_OCT_DIGIT ASCII_HEX_DIGIT ASCII_ALPHA_LOWER ASCII_ALPHA_UPPER ASCII_ALPHA ASCII_ALPHANUMERIC
syntax keyword pest_builtin_unicode LETTER CASED_LETTER UPPERCASE_LETTER LOWERCASE_LETTER TITLECASE_LETTER MODIFIER_LETTER OTHER_LETTER MARK NONSPACING_MARK SPACING_MARK ENCLOSING_MARK NUMBER DECIMAL_NUMBER LETTER_NUMBER OTHER_NUMBER PUNCTUATION CONNECTOR_PUNCTUATION DASH_PUNCTUATION OPEN_PUNCTUATION CLOSE_PUNCTUATION INITIAL_PUNCTUATION FINAL_PUNCTUATION OTHER_PUNCTUATION SYMBOL MATH_SYMBOL CURRENCY_SYMBOL MODIFIER_SYMBOL OTHER_SYMBOL SEPARATOR SPACE_SEPARATOR LINE_SEPARATOR PARAGRAPH_SEPARATOR OTHER CONTROL FORMAT SURROGATE PRIVATE_USE UNASSIGNED


highlight default link pest_string String
highlight default link pest_string_escape Number
highlight default link func Function
highlight default link rule Identifier
highlight default link modifier Operator
highlight default link pest_operator Operator
highlight default link pest_builtin Type
highlight default link pest_builtin_unicode Type
highlight default link pest_bracket @punctuation.bracket
