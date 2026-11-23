"""arachnix-viz build model.json -o harness.yml [--render]"""
from __future__ import annotations

import argparse
import json
import shutil
import subprocess
import sys

import yaml

from .wireviz import convert


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(prog="arachnix-viz")
    sub = ap.add_subparsers(dest="cmd", required=True)
    b = sub.add_parser("build", help="convert ArachNix JSON to WireViz YAML")
    b.add_argument("model", help="JSON from `arachnix eval`")
    b.add_argument("-o", "--output", required=True, help="WireViz YAML to write")
    b.add_argument("--render", action="store_true", help="then run the wireviz executable on it")
    args = ap.parse_args(argv)

    with open(args.model) as f:
        model = json.load(f)
    doc = convert(model)
    with open(args.output, "w") as f:
        yaml.safe_dump(doc, f, sort_keys=False, allow_unicode=True)
    print(f"wrote {args.output}", file=sys.stderr)

    if args.render:
        exe = shutil.which("wireviz")
        if exe is None:
            print("wireviz is not installed; the YAML is ready to render elsewhere", file=sys.stderr)
            return 0
        # a separate process: WireViz is never imported
        return subprocess.run([exe, args.output]).returncode
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
