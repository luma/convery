grammar Convey;


program
  : package imports? expressions* EOF
  ;

package
  : Package ws? name=Identifier
  ;
Package : 'package';

imports
  : Import ws? OpenParen importStatement+ CloseParen
  | Import ws? importStatement+
  ;

Import : 'import';


importStatement
  : ws? alias=Variable? ws? path=StringLiteral
  ;

expressions
  : ws? expression+
  ;

expression
  : typeDeclarationExpression
  | assignmentExpression
  | simpleExpression
  ;


simpleExpression
  : simpleExpression OpenBrace key=simpleExpression CloseBrace                    // lookup expressions
  | simpleExpression ws? Variable ws? keyValuePairList                          // unary message send with un-parenthesised arguments
  | simpleExpression ws? Variable ws? args=tupleLiteral?                        // unary message send, with and without parenthesised arguments
  | Variable ws? keyValuePairList                          // unary message send with un-parenthesised arguments
  | Variable ws? args=tupleLiteral?                        // unary message send, with and without parenthesised arguments
  | operand1=simpleExpression ws? op=BinaryOperator ws? operand2=simpleExpression // binary message send
  | closure
  | literal
  | Identifier                                                                    // message send with implicit receiver
  ;

assignmentExpression
  : lhs=Variable ws? Assignment ws? rhs=simpleExpression
  ;


unarySend
  : binarySend ws? Variable
  ;


binarySend
  : operand1=callWithArgs ws? op=BinaryOperator ws? operand2=callWithArgs
  ;



callWithArgs
  : simpleExpression ws? Variable ws? keyValuePairList                          // unary message send with un-parenthesised arguments
  | simpleExpression ws? Variable ws? args=tupleLiteral?                        // unary message send, with and without parenthesised arguments
  | Variable ws? keyValuePairList                          // unary message send with un-parenthesised arguments
  | Variable ws? args=tupleLiteral?                        // unary message send, with and without parenthesised arguments
  ;

// unarySend > binary ops > call with args


lookupOperator
  : rangeLiteral
  | integerLiteral
  | Variable
  ;



// GRAMMAR OF A TYPE DECLARATION
typeDeclarationExpression
  : Type ws? name=Identifier ws? Assignment ws? (tupleDeclaration | literal)
  ;

Type : 'type';


// GRAMMAR OF A CLOSURE DECLARATION
// ( param1:type param2:type ... paramN:type | <message-expressions> )
closure
  : OpenParen ws? args=typeDeclaration ws? Pipe ws? (simpleExpression ws?)* CloseParen
  ;

ws : WhitespaceChar+;

literal
  : dictLiteral
  | namedTupleLiteral
  | tupleLiteral
  | setLiteral
  | listLiteral
  | rangeLiteral
  | BoolLiteral
  | StringLiteral
  | SymbolLiteral
  | numericLiteral
  ;



namedTupleLiteral
  : Identifier tupleLiteral
  ;

tupleLiteral
  : '(' keyValuePairList ')'
  | '(' listItems ')'
  ;

setLiteral
  : '{' '}'
  | '{' listItems '}'
  ;

listLiteral
  : '[' ']'
  | '[' listItems ']'
  ;

listItems
  : ws? simpleExpression ( ws? ',' ws? simpleExpression )* ws?
  ;

dictLiteral
 : '{' '}'
 | '{' keyValuePairList '}'
;



keyValuePairList
  : keyValuePair+
  ;

keyValuePair
  : ws? SymbolLiteral ws? simpleExpression
  ;

tupleDeclaration
  : '(' typeDeclaration+ ')'
  ;

typeDeclaration
  : ws? SymbolLiteral (Identifier | literal) ws?
  ;



numericLiteral
  : Dash? integerLiteral
  | Dash? FloatingPointLiteral
 ;


// TODO binary literal from Erlang
// List comprehension?
// Pattern matching assignment


// GRAMMAR OF A RANGE LITERAL
rangeLiteral
  : startc=charLiteral RangeInclusive endc=charLiteral?
  | startc=charLiteral RangeExclusive endc=charLiteral?
  | RangeExclusive endc=charLiteral
  | RangeInclusive endc=charLiteral
  | starti=integerLiteral RangeInclusive endi=integerLiteral?
  | starti=integerLiteral RangeExclusive endi=integerLiteral?
  | RangeInclusive endi=integerLiteral
  | RangeExclusive endi=integerLiteral
  ;

RangeExclusive : '..';
RangeInclusive : '...';

// GRAMMAR OF A CHAR LITERAL
charLiteral : '\'' (LittleChar | BigChar) '\'';


// GRAMMAR OF A BOOL LITERAL
BoolLiteral : True | False;
fragment True : 'true';
fragment False : 'false';

// GRAMMAR OF AN SYMBOL LITERAL
SymbolLiteral : Variable Colon;
fragment Colon : ':';

// GRAMMAR OF AN IDENTIFIER
Identifier : BigChar+[a-zA-Z0-9_]*;

Variable : LittleChar+[a-zA-Z0-9_]*;


LittleChar : [a-z];
BigChar : [A-Z];
CloseParen : ')';
OpenParen : '(';
OpenBrace : '[';
CloseBrace : ']';
OpenCurly : '{';
CloseCurly : '}';
Pipe : '|';
Assignment : ':=';
Dash : '-';
Comma : ',';


// GRAMMAR OF AN STRING LITERAL
StringLiteral
  : BackTick StringCharacter* BackTick
  | DoubleQuote StringCharacter* DoubleQuote
  ;

fragment DoubleQuote : '"';
fragment BackTick : '`';

fragment StringCharacter
 : ~["\\\r\n]
 | '\\' EscapeSequence
 | LineContinuation
 ;

fragment EscapeSequence
 : CharacterEscapeSequence
 | '0'
 | HexEscapeSequence
 | UnicodeEscapeSequence
 ;
fragment CharacterEscapeSequence
 : SingleEscapeCharacter
 | NonEscapeCharacter
 ;
fragment HexEscapeSequence
 : 'x' HexDigit HexDigit
 ;
fragment UnicodeEscapeSequence
 : 'u' HexDigit HexDigit HexDigit HexDigit
 ;
fragment SingleEscapeCharacter
 : ['"\\bfnrtv]
 ;

fragment NonEscapeCharacter
 : ~['"\\bfnrtv0-9xu\r\n]
 ;
fragment EscapeCharacter
 : SingleEscapeCharacter
 | DecimalDigit
 | [xu]
 ;
fragment LineContinuation
 : '\\' LineTerminatorSequence
 ;
fragment LineTerminatorSequence
 : '\r\n'
 | LineTerminator
 ;




// GRAMMAR OF AN INTEGER LITERAL
integerLiteral
 : BinaryLiteral
 | OctalLiteral
 | DecimalLiteral
 | PureDecimalDigits
 | HexLiteral
 ;

BinaryLiteral : '0b' BinaryDigit BinaryLiteralCharacters? ;
fragment BinaryDigit : [01] ;
fragment BinaryLiteralCharacter : BinaryDigit | '_'  ;
fragment BinaryLiteralCharacters : BinaryLiteralCharacter+ ;

OctalLiteral : '0o' OctalDigit OctalLiteralCharacters? ;
fragment OctalDigit : [0-7] ;
fragment OctalLiteralCharacter : OctalDigit | '_'  ;
fragment OctalLiteralCharacters : OctalLiteralCharacter+ ;

DecimalLiteral		: [0-9] [0-9_]* ;
PureDecimalDigits : [0-9]+ ;
fragment DecimalDigit : [0-9] ;
fragment DecimalLiteralCharacter : DecimalDigit | '_'  ;
fragment DecimalLiteralCharacters : DecimalLiteralCharacter+ ;

HexLiteral : '0x' HexDigit HexLiteralCharacters? ;
fragment HexDigit : [0-9a-fA-F] ;
fragment HexLiteralCharacter : HexDigit | '_'  ;
fragment HexLiteralCharacters : HexLiteralCharacter+ ;


// GRAMMAR OF A FLOATING_POINT LITERAL
FloatingPointLiteral
 : DecimalLiteral DecimalFraction? DecimalExponent?
 | HexLiteral HexFraction? HexExponent
 ;
fragment DecimalFraction : '.' DecimalLiteral ;
fragment DecimalExponent : FloatingPointE Sign? DecimalLiteral ;
fragment HexFraction : '.' HexDigit HexLiteralCharacters? ;
fragment HexExponent : FloatingPointP Sign? DecimalLiteral ;
fragment FloatingPointE : [eE] ;
fragment FloatingPointP : [pP] ;
fragment Sign : [+\-] ;


BinaryOperator
  : '+='
  | '-='
  | '*='
  | '/='
  | '\\='
  | '+'
  | '*'
  | '^'         // power
  | '/'         // div with fractional result
  | '\\'        // remainder with fractional result
  | '//'        // div with integer result
  | '\\\\'      // remainder with integer result
  | '&'
  | '|'
  | '=='
  | '!='
  | '>='
  | '<='
  | '>'
  | '<'
  | '~'
  ;


//
//// A single line comment
//
SingleLineComment
  : '#' ~[\r\n\u2028\u2029]* -> channel(HIDDEN)
 ;


//
//// Whiespace handling
//
LineTerminator
  : ('\n'  | '\r\n'  | '\r'  | '\u2028'  | '\u2029') -> channel(HIDDEN)
 ;

WhitespaceChar
  : [\t\u000B\u000C\u0020\u00A0]  -> channel(HIDDEN)
 ;
