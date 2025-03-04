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
# Template for Python Scripts
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
                user_home = os.environ.get("USERPROFILE")
                app_json = os.path.join(user_home, "scoop", "buckets", bucket, "bucket", f"{app}.json")

                logging.debug(f"Look for: {app_json}")

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
                    logging.debug(f"NOFILE: {line}: {app_json}")
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

