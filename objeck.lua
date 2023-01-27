-- Copyright 2006-2023 Mitchell. See LICENSE.
-- C# LPeg lexer.

local lexer = require('lexer')
local token, word_match = lexer.token, lexer.word_match
local P, S = lpeg.P, lpeg.S

local lex = lexer.new('objeck')

-- Whitespace.
lex:add_rule('whitespace', token(lexer.WHITESPACE, lexer.space^1))

-- Keywords.
lex:add_rule('keyword', token(lexer.KEYWORD, word_match{
  'class', 'method', 'function', 'public', 'abstract', 'private', 'static', 'native', 'virtual',
  'Parent', 'As', 'from', 'implements', 'interface', 'enum', 'alias', 'consts', 'bundle',
  'use', 'leaving', 'if', 'else', 'do', 'while', 'select', 'break', 'continue', 'other',
  'for', 'each', 'reverse', 'label', 'return', 'critical', 'New', 'and', 'or', 'xor', 'not',
  'true', 'false'--, 'Nil'
}))

-- Types.
lex:add_rule('type', token(lexer.TYPE, word_match{
  'Nil', 'Byte', 'ByteHolder', 'Int', 'IntHolder', 'Float', 'FloatHolder', 'Char', 'CharHolder',
  'Bool', 'BoolHolder', 'String', 'BaseArrayHolder', 'BoolArrayHolder', 'ByteArrayHolder',
  'CharArrayHolder', 'FloatArrayHolder', 'IntArrayHolder', 'StringArrayHolder',
  'Func2Holder', 'Func3Holder', 'Func4Holder', 'FuncHolder'
}))

-- Identifiers.
lex:add_rule('identifier', token(lexer.IDENTIFIER, lexer.word))

-- Comments.
local line_comment = lexer.to_eol('//', true)
local block_comment = lexer.range('/*', '*/')
lex:add_rule('comment', token(lexer.COMMENT, line_comment + block_comment))

-- Strings.
local sq_str = lexer.range("'", true)
local dq_str = lexer.range('"', true)
local ml_str = P('@')^-1 * lexer.range('"', false, false)
lex:add_rule('string', token(lexer.STRING, sq_str + dq_str + ml_str))

-- Numbers.
lex:add_rule('number', token(lexer.NUMBER, lexer.number * S('lLdDfFmM')^-1))

-- Preprocessor.
lex:add_rule('preprocessor', token(lexer.PREPROCESSOR, '#' * S('\t ')^0 *
  word_match('define elif else endif error if line undef warning region endregion')))

-- Operators.
lex:add_rule('operator', token(lexer.OPERATOR, S('~!.,:;+-*/<>=\\^|&%?()[]{}')))

-- Fold points.
lex:add_fold_point(lexer.PREPROCESSOR, 'if', 'endif')
lex:add_fold_point(lexer.PREPROCESSOR, 'ifdef', 'endif')
lex:add_fold_point(lexer.PREPROCESSOR, 'ifndef', 'endif')
lex:add_fold_point(lexer.PREPROCESSOR, 'region', 'endregion')
lex:add_fold_point(lexer.OPERATOR, '{', '}')
lex:add_fold_point(lexer.COMMENT, '/*', '*/')

lexer.property['scintillua.comment'] = '//'

return lex
