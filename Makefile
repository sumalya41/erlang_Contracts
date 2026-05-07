.PHONY: all clean compile test demo

all: compile

compile:
	@echo "Generating lexer and parser..."
	cd src && erlc trading_lexer.xrl
	cd src && erlc trading_parser.yrl
	@echo "Compiling Erlang modules..."
	cd src && erlc *.erl
	@echo "Done!"

clean:
	@echo "Cleaning..."
	rm -f src/*.beam
	rm -f src/trading_lexer.erl
	rm -f src/trading_parser.erl
	@echo "Done!"

test: compile
	@echo "Running demo..."
	erl -noshell -pa src -eval "trading_demo:run(), init:stop()."

demo: test

repl: compile
	@echo "Starting Erlang REPL..."
	erl -pa src

help:
	@echo "Available targets:"
	@echo "  all     - Build everything (default)"
	@echo "  compile - Generate lexer/parser and compile modules"
	@echo "  clean   - Remove compiled files"
	@echo "  test    - Run demo"
	@echo "  demo    - Run demo (same as test)"
	@echo "  repl    - Start Erlang REPL with compiled modules"
	@echo "  help    - Show this help message"