#!/usr/bin/env bash
set -euo pipefail

usage() {
	echo "Usage: arachnix <command> [args]"
	echo ""
	echo "Commands:"
	echo "  eval <file.nix> [--results] [--viz] [--out <file.json>]"
	echo "  results <file.json>"
	#echo "  viz <file.json> [--out <file.yml>]"
	exit 1
}

# cmd_results() { }

# cmd_viz() {}

cmd_eval() {
	local target="$1"
	shift
	local out_file="arachnix-output.json"
	local show_results=0
	local run_viz=0

	while [[ $# -gt 0 ]]; do
		case $1 in
			--out) out_file="$2"; shift 2 ;;
			--results) show_results=1; shift ;;
			--viz) run_viz=1; shift ;;
			*) echo "Unknown flag: $1"; exit 1 ;;
		esac
	done

	echo "Evaluating $target..."
	nix-instantiate --eval --strict --json \
	--extra-experimental-features pipe-operators \
	"$target" > "$out_file"
  
	echo "Saved evaluation to $out_file"

#	if [ $show_results -eq 1 ]; then cmd_results "$out_file"; fi
#	if [ $run_viz -eq 1 ]; then cmd_viz "$out_file"; fi
}

