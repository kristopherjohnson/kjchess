# xboard and polyglot can be installed from Homebrew:  brew install xboard polyglot
XBOARD=/usr/local/bin/xboard
POLYGLOT=/usr/local/bin/polyglot

all:
	xcodebuild -alltargets

kjchess-cli:
	xcodebuild -target kjchess-cli

kjchess:
	xcodebuild -target kjchess

kjchessTests:
	xcodebuild -target kjchessTests

test:
	xcodebuild -scheme kjchess test

clean:
	xcodebuild -alltargets clean

# Launch XBoard, using PolyGlot UCI adapter with kjchess UCI engine.
# Human plays white; kjchess plays black.
play: kjchess-cli
	"$(XBOARD)" -fcp "'$(POLYGLOT)' -noini -log true -ec '$(CURDIR)/build/Release/kjchess-cli' -en kjchess -ed '$(CURDIR)/build/Release'"

.PHONY: all kjchess-cli kjchess kjchessTests test clean

