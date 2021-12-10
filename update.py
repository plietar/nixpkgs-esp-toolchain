#!/usr/bin/env python3

import argparse
from typing import Optional
from contextlib import nullcontext
import subprocess
import json
from pathlib import Path
import sys
import re

DEFAULT_COMPONENTS = [
    "binutils-gdb",
    "gcc",
    "newlib-esp32",
]

class Updater:
    def __init__(self, release, do_prefetch):
        self.pattern = re.compile(f"refs/tags/(esp-([0-9.]*)[_-]{re.escape(release)})")
        self.do_prefetch = do_prefetch

    def find_tag(self, repo):
        cmd = subprocess.run(["git", "ls-remote", repo], check=True, stdout=subprocess.PIPE, encoding="utf-8")
        for line in cmd.stdout.splitlines():
            [rev, ref] = line.split('\t')
            if m := self.pattern.fullmatch(ref):
                return (m.group(1), m.group(2))

    def prefetch(self, owner, repo, rev):
        cmd = subprocess.run(["nix-prefetch-github", "--json", "--rev", rev, owner, repo], check=True, stdout=subprocess.PIPE, encoding="utf-8")
        return json.loads(cmd.stdout)["hash"]

    def find_component(self, name):
        parts = name.split("/")
        if len(parts) == 1:
            owner, repo = "espressif", name
        else:
            owner, repo = parts

        (rev, version) = self.find_tag(f"https://github.com/{owner}/{repo}")
        print(f"Found version {version} for {owner}/{repo}", file=sys.stderr)
        result = {
            "owner": owner,
            "repo": repo,
            "rev": rev,
            "version": version,
        }

        if self.do_prefetch:
            result["hash"] = self.prefetch(owner, repo, rev)

        return result

def open_output(path: Optional[Path]):
    if path is None:
        return nullcontext(sys.stdout)
    else:
        return path.open("w")

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("release")
    parser.add_argument("--component", "-c", action="append", dest="components")
    parser.add_argument("--no-prefetch", action="store_false", dest="prefetch")
    parser.add_argument("--output", "-o", type=Path)

    args = parser.parse_args()
    components = args.components or DEFAULT_COMPONENTS

    updater = Updater(args.release, args.prefetch)
    result = { c: updater.find_component(c) for c in components }
    with open_output(args.output) as f:
        json.dump(result, f, indent=2)

main()
