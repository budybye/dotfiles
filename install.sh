#! /usr/bin/env bash

chezmoi init --apply budybye || su -c 'sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin" init --apply budybye' $(whoami)
