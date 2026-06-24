# Quick Start Guide - Rebar3 Setup

This guide helps you set up and run the Erlang Contracts DSL project using rebar3.

## Installation

### 1. Install Erlang/OTP
Visit http://erlang.org/download.html and install the latest version (OTP 21+)

**macOS (Homebrew)**:
```bash
brew install erlang
```

**Ubuntu/Debian**:
```bash
sudo apt-get install erlang
```

**Windows**: Download installer from erlang.org

### 2. Install Rebar3

**macOS**:
```bash
brew install rebar3
```

**Linux/Unix**:
```bash
wget https://s3.amazonaws.com/rebar3/rebar3
chmod +x rebar3
sudo mv rebar3 /usr/local/bin/
```

**Windows**: Download from https://github.com/erlang/rebar3/releases

### 3. Verify Installation

```bash
erlc --version
rebar3 version
```

## Project Setup

The project is already configured as a rebar3 project. The structure includes:

```
erlang_Contracts/
├── rebar.config              # Rebar3 configuration
├── src/                      # Source files
│   ├── instruments.app.src   # Application definition
│   ├── *.erl                 # 6 source modules
├── test/                     # Test files
│   └── *_SUITE.erl          # 5 test suites (38 tests)
└── ebin/                     # Compiled files (auto-generated)
```

## Building

```bash
cd erlang_Contracts

# Compile all source files
rebar3 compile

# Clean build artifacts
rebar3 clean
```

## Running Tests

### Run All Tests
```bash
rebar3 eunit
```

Output example:
```
======================== EUnit ========================
barrier_logic_SUITE: up_and_in_activation_test (module 'barrier_logic_SUITE')...ok
barrier_logic_SUITE: down_and_in_activation_test (module 'barrier_logic_SUITE')...ok
...
======================== 38 tests passed ==========
```

### Run Specific Test Suite
```bash
# Run only barrier logic tests
rebar3 eunit --module=barrier_logic_SUITE

# Run only integration tests  
rebar3 eunit --module=integration_SUITE
```

### Verbose Test Output
```bash
rebar3 eunit --verbose
```

### Generate Coverage Report
```bash
rebar3 cover
```

This generates coverage statistics in `_build/test/cover/` directory.

## Interactive Shell

```bash
rebar3 shell
```

Then in the shell:
```erlang
1> instrument_custom:start().
{ok, <0.123.0>}

2> Digital = instrument_custom:digital(stock, 100).
<0.124.0>

3> Env = #{time => terminal, {stock, terminal} => 120}.
#{...}

4> instrument_server:value(Digital, Env).
1

5> q().
```

## Run the Example

From the shell:
```erlang
1> main:run().
Digital: 1
Exchange: 10
Rainbow: 130
Barrier: 1
ok
```

## Project Structure Details

### src/ Directory
- **barrier_logic.erl**: Barrier option state machine
- **instruments.erl**: DSL primitives
- **instrument_server.erl**: Evaluation engine (gen_server)
- **instrument_custom.erl**: Contract constructors
- **instrument_sup.erl**: OTP supervisor
- **main.erl**: Example usage
- **instruments.app.src**: App configuration

### test/ Directory
- **barrier_logic_SUITE.erl**: 6 tests
- **instruments_SUITE.erl**: 9 tests
- **instrument_server_SUITE.erl**: 8 tests
- **instrument_custom_SUITE.erl**: 10 tests
- **integration_SUITE.erl**: 5 tests

## Configuration

### rebar.config
The `rebar.config` file includes:
- Erlang compiler options
- Debug info enabled
- Warnings as errors
- Coverage reporting enabled
- Xref (cross-reference) checks

### instruments.app.src
Application resource file specifying:
- Application name and version
- Module dependencies (kernel, stdlib)
- Module list
- Registered processes (supervisor)

## Troubleshooting

### "command not found: rebar3"
- Make sure rebar3 is in PATH: `which rebar3`
- Reinstall rebar3 if not found

### "command not found: erlc"
- Erlang is not installed. Install from http://erlang.org/download.html

### Compilation errors
```bash
# Clean and rebuild
rebar3 clean
rebar3 compile
```

### Test failures
```bash
# Run with verbose output
rebar3 eunit --verbose

# Run single test to debug
rebar3 eunit --module=barrier_logic_SUITE
```

## Common Rebar3 Commands

```bash
# Compile
rebar3 compile

# Clean
rebar3 clean

# Test
rebar3 eunit
rebar3 eunit --module=<module>_SUITE

# Code analysis
rebar3 xref

# Code coverage
rebar3 cover

# Shell
rebar3 shell

# Dependencies (none in this project)
rebar3 deps

# Release building (advanced)
rebar3 release

# Documentation
rebar3 edoc
```

## Next Steps

1. ✅ Compile the project: `rebar3 compile`
2. ✅ Run tests: `rebar3 eunit`
3. ✅ Explore examples: `rebar3 shell` → `main:run().`
4. 📖 Read [REBAR3_README.md](REBAR3_README.md) for detailed documentation
5. 📖 Read [TEST_DOCUMENTATION.md](TEST_DOCUMENTATION.md) for test details

## Further Learning

- **Erlang Documentation**: http://erlang.org/doc/
- **Rebar3 Documentation**: https://rebar3.org/
- **OTP Design Principles**: http://erlang.org/doc/design_principles/users_guide.html
- **Financial Derivatives Background**: Research Simon Peyton Jones "Composable and Modular Financial Contracts"

## Support

For issues or questions:
1. Check REBAR3_README.md for project documentation
2. Review test suites for example usage
3. Consult Erlang/Rebar3 official documentation
