#!/usr/bin/env bash
vim -c "silent grep! $*" -c "copen" -c "redraw!"
