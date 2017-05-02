#!/bin/bash

kjchess-cli --search-depth=6 --concurrent-tasks=4 <<END
uci
ucinewgame
position startpos moves e2e4
go
quit
END

