#!/usr/bin/env python3
# PYTHON_ARGCOMPLETE_OK

#
# Template for Python Scripts
#
# Features:
#  * Command-line parsing
#  * Python 3 Support
#  * Bash auto completion
#  * Logging
#
# Prerequisites:
#   pip3 install argh argcomplete prompt_toolkit
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

from argh import ArghParser, completion, set_default_command, arg
from argcomplete.completers import ChoicesCompleter,  FilesCompleter

if USE_PROMPT_TOOLKIT:
    from prompt_toolkit import HTML, print_formatted_text
    printf = print_formatted_text
else:
    printf = print
    HTML = lambda x: x


regex = re.compile(r"^(?P<prefix>[\s]*)scoop install (?P<package>[^\s]*)")

def process():
    """
    Given a list of `scoop install bucket/app` lines, adds the app description
    above the line as a comment.

    All other lines are left as-is.
    """

    fieldnames = ['package', 'bucket', 'description', 'homepage']
    writer = csv.writer(sys.stdout)
    writer.writerow(fieldnames)

    # Usually on read from stdin if a file is not given or given as "-"
    lines = read_stdin_lines()
    if lines:
        for line in lines:
            match = regex.match(line)
            if match:
                logging.debug(f"Groups: {match.groups()}")
                package = match.group("package")
                prefix = match.group("prefix")
                logging.debug(package)

                parts = package.split("/")

                if len(parts) == 1:
                    bucket = "main"
                    app = parts[0]
                elif len(parts) == 2:
                    bucket = parts[0]
                    app = parts[1]

                logging.debug(f"Bucket: {bucket}, App: {app}")
                app_json = os.path.join("/cygdrive/c/Users/Nithin/scoop/buckets", bucket, "bucket", f"{app}.json")

                if os.path.exists(app_json):
                    with open(app_json) as f:
                        d = json.load(f)
                        app_desc = d['description']
                        app_url = d['homepage']
                        #sys.stdout.write(f"{prefix}#{app_desc}\n")
                        #sys.stdout.write(f"{prefix}scoop install {package}\n")
                        #sys.stdout.write(f"{package},{bucket},{app_desc},{app_url}\n")
                        writer.writerow([package,bucket,app_desc,app_url])
                else:
                    logging.debug(f"NOMATCH: {line}")
                    #sys.stdout.write(line)

            else:
                logging.debug(f"NOMATCH: {line}")
                #sys.stdout.write(line)

        logging.debug("")

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

