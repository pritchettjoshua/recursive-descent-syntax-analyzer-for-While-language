# this method primary usage involves checking the tokens and also error handling. 
def match (token_to_match)
	if @lookahead[0] != token_to_match
		puts("Error: Expecting: ")
		puts(token_to_match)
		puts("This is what you had: ")
		puts(@lookahead[1])
		exit()
	else
		@lookahead = tokenGetter
	end
end
# the following defines the BNF logic
def gtprogram
  stmts
end

def stmts
	stmt
	if @lookahead[0] == :SEMI
		match(:SEMI)
		stmts
	end
end

def stmt
	if @lookahead[0] == :SKIP
		match(:SKIP)
	elsif @lookahead[0] == :ID
		match(:ID)
		match(:ASSIGN)
		expr
	elsif @lookahead[0] == :IF
		match(:IF)
		match(:LPAR)
		lexpr
		match(:RPAR)
		match(:THEN)
		match(:LPAR)
		stmts
		match(:RPAR)
		match(:ELSE)
		match(:LPAR)
		stmts
		match(:RPAR)
	elsif @lookahead[0] == :WHILE
		match(:WHILE)
		match(:LPAR)
		lexpr
		match(:RPAR)
		match(:DO)
		match(:LPAR)
		stmts
		match(:RPAR)
	else
		puts("error improper syntax")
		exit()
	end
end

def expr
	term
	if @lookahead[0] == :ADDOP
		exprs
	end
end

def exprs
	match(:ADDOP)
	term
	if @lookahead[0] == :ADDOP
		exprs
	end
end

def term
	factor
	if @lookahead[0] == :MUL
		terms
	end
end

def terms
	match(:MUL)
	factor
	if @lookahead[0] == :MUL
		terms
	end
end

def factor
	if @lookahead[0] == :NUM
		match(:NUM)
	elsif @lookahead[0] == :ID
		match(:ID)
	elsif @lookahead[0] == :LPAR
		match(:LPAR)
		expr
		match(:RPAR)
	else
		puts("error")
	end
end

def lexpr
	lterm
	if @lookahead[0] == :AND
		lexprs
	end
end

def lexprs
	match(:AND)
	lterm
	if @lookahead[0] == :AND
		lexprs
	end
end

def lterm
	if @lookahead[0] == :NOT
		match(:NOT)
	end
	lfactor
end

def lfactor
	if @lookahead[0] == :BOOL
		match(:BOOL)
	else
		expr
		match(:RELOP)
		expr
	end
end
# end of BNF method definitions and parsing


# This method return token with it's lexemeValVal and value. also inside this method the list of tokens get shift.
def tokenGetter
	if @tokens.length > 0
		value_to_check = @tokens.shift()[0]
	else
		return [:EOF, "EOF"]
	end
	
	$lexemeVal
	if value_to_check =~ /^\+|^\-/
		 $lexemeVal = :ADDOP
	elsif value_to_check =~ /^\*/
		 $lexemeVal = :MUL
	elsif value_to_check =~ /^\(/
		 $lexemeVal = :LPAR
	elsif value_to_check =~ /^\)/
		 $lexemeVal = :RPAR
	elsif value_to_check =~ /^;/
		 $lexemeVal = :SEMI
	elsif value_to_check =~ /^<=|^=/
		 $lexemeVal = :RELOP
	elsif value_to_check =~ /^:=/
		 $lexemeVal = :ASSIGN
	elsif value_to_check =~ /^true|^false/
		 $lexemeVal = :BOOL
	elsif value_to_check =~ /^not/
		 $lexemeVal = :NOT
	elsif value_to_check =~ /^and/
		 $lexemeVal = :AND
	elsif value_to_check =~ /^skip/
		 $lexemeVal = :SKIP
	elsif value_to_check =~ /^if/
		 $lexemeVal = :IF
	elsif value_to_check =~ /^then/
		 $lexemeVal = :THEN
	elsif value_to_check =~ /^else/
		 $lexemeVal = :ELSE
	elsif value_to_check =~ /^do/
		 $lexemeVal = :DO
	elsif value_to_check =~ /^while/
		 $lexemeVal = :WHILE
	elsif value_to_check =~ /^[0-9]+/
		 $lexemeVal = :NUM
	elsif value_to_check =~ /^[a-zA-Z_][a-zA-Z0-9_]*/
		 $lexemeVal = :ID
	end
	return [$lexemeVal, value_to_check]
end
 # method for file reading and removing comments
puts "Please enter the name of the .While file to be parsed."
file = gets.chomp
f = File.new(file, "r")
File.write('deleteFile.while', "")
while(line = f.gets)
if line.include? "//"
    new_line = line.slice(0..(line.index('/')))
    new_line = new_line.sub! '/', ''
    open('deleteFile.while', 'a') do |f|
        f.puts new_line
        end
    else
    open('deleteFile.while', 'a') do |f|
        f.puts line
        end
    end
end
f.close


# read in a file specified on command line
inputFile = File.open( 'deleteFile.while' ).read
@tokens = inputFile.scan /(;|\+|\-|\*|\(|\)|<=|=|:=|true|false|not|and|[0-9]+|skip|if|then|else|do|while|[a-zA-Z_][a-zA-Z0-9_]*)/
@lookahead = tokenGetter()

# this starts the BNF method 
gtprogram()
if @lookahead[0] == :EOF
	puts("Success, No error!")
else
	puts("Expecting: ;")
	puts("This is what you had: ")
	puts(@lookahead[1])
end
