RACC = racc
PARSER = parser.y

parser.rb: ${PARSER}
	${RACC} -v $< -o $@

clean:
	rm parser.rb
	rm parser.output