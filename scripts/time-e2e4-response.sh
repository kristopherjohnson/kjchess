#!/bin/bash

kjchess-cli <<DONE
uci
ucinewgame
position start moves e2e4
go
quit
DONE

