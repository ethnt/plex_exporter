console:
    iex -S mix

run:
    iex -S mix run --no-halt

build:
    nix build .#

test:
    MIX_ENV=test mix test

dialyzer:
    mix dialyzer

format:
    treefmt
