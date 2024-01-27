#!/usr/bin/env bash

export CLICOLOR_FORCE=1 # Used by ninja in msys2 terminal

tabs 4

export PATH="/d/utility/Python/Python312/Scripts:/d/utility/Python/Python312:${PATH}"


# TODO: Find a place for git subrepo rc
export GIT_SUBREPO_ROOT="/d/utility/git-subrepo"
export PATH="/d/utility/git-subrepo/lib:$PATH"
export MANPATH="/d/utility/git-subrepo/man:$MANPATH"

