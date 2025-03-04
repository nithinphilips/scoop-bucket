#!/usr/bin/env -S uv run --script
# PYTHON_ARGCOMPLETE_OK
# /// script
# requires-python = ">=3.12"
# dependencies = [
#   "argh",
#   "argcomplete",
#   "prompt_toolkit"
# ]
# [tool.uv]
# exclude-newer = "2025-02-24T00:00:00Z"
# ///
#
#
# Bash Autocompletion:
#
#   1. Install bash-completion package
#   2. Add to your .bashrc:
#
#         [[ $PS1 && -f /usr/share/bash-completion/bash_completion ]] && \
#               . /usr/share/bash-completion/bash_completion
#
#   4. In bash run:
#
#           activate-global-python-argcomplete
#
#   5. Restart your shell.
#

# Use of prompt toolkit is optional.
# If enabled, it allows advanced use of the terminal
# https://python-prompt-toolkit.readthedocs.io/
USE_PROMPT_TOOLKIT = True

import argparse
import argcomplete
import re
import sys
import logging
import json
import os
import csv
import glob

from argh import ArghParser, completion, set_default_command, arg
from argcomplete.completers import ChoicesCompleter,  FilesCompleter

script_dir = os.path.dirname(os.path.realpath(__file__))

if USE_PROMPT_TOOLKIT:
    from prompt_toolkit import HTML, print_formatted_text
    printf = print_formatted_text
else:
    printf = print
    HTML = lambda x: x


regex = re.compile(r"^(?P<prefix>[\s]*)scoop install (?P<package>[^\s]*)")

def process():
    """
    Prints a list of apps in this bucket with links to home pages
    """

    prefix = "* "

    # Usually on read from stdin if a file is not given or given as "-"
    apps = glob.glob("./bucket/*.json")
    for app_json in apps:
        if os.path.exists(app_json):
            with open(app_json) as f:
                logging.debug(f"Processing {app_json}")
                d = json.load(f)
                package, _ = os.path.splitext(os.path.basename(app_json))
                app_desc = d['description']
                app_url = d['homepage']
                sys.stdout.write(f"{prefix}[{package}]({app_url}) - {app_desc}\n")

    #for filename in filenames:
    #    sys.stdout.write(f"  * {filename}\n")

#-- Leave everything below as-is

COMMON_PARSER = argparse.ArgumentParser(add_help=False)
COMMON_PARSER.add_argument('--debug',
                           action='store_true',
                           default=False,
                           help="Enable debug logging.")

def read_stdin_lines():
    """
    Method to read lines from STDIN. This blocks until EOF is received

    Return a list of lines or None if there is no input.
    """
    stdin_lines = []
    for line in sys.stdin:
            stdin_lines.append(line)

    return None if len(stdin_lines) <= 0 else stdin_lines

if __name__ == '__main__':
    # Read lines from STDIN
    parser = ArghParser(parents=[COMMON_PARSER])
    set_default_command(parser, process)
    argcomplete.autocomplete(parser)
    args = parser.parse_args()

    if args.debug:
        logging.basicConfig(
            level=logging.DEBUG, format='%(asctime)s %(levelname)s: %(message)s'
        )

    parser.dispatch()

