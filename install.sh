#! /usr/bin/env bash

chezmoi init --apply budybye || su $(whoami) -c 'sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin" init --apply budybye'
