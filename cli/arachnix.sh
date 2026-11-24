usage() {
cat <<'USAGE'
usage: arachnix <command> <harness.nix> [options]

eval	<harness.nix>	[-o out.json]
check	<harness.nix>	

`harness.nix` is the top-level Nix module associated with a given harness.
USAGE
}

root="${ARACHNIX_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
features='nix-command flakes pipe-operators'

########### Sanity checks #############
# I find Bash syntax rather obtuse so this documentation is mostly for me.
# Pop the current command (or -help if empty) in cmd, then shift to the next.
cmd="${1:-help}"
[ "$#" -gt 0 ] && shift

# Check if the user has requested help, print usage, exit
case "$cmd" in help|-h|--help) usage; exit 0 ;; esac

# Require a harness file
if [ "$#" -lt 1 ]; then
  echo "Error: missing harness file." >&2
  usage; exit 2
fi

harness="$1"; shift
out=""

# Parse shared flags
while [ "$#" -gt 0 ]; do
  case "$1" in
    -o|--output) out="$2"; shift 2 ;;
    *) echo "unknown option: $1" >&2; exit 2 ;;
  esac
done

############# Commands ###############
build_json() {
	local tgt
	tgt="$(realpath "$1")";
	nix eval --json --impure --extra-experimental-features "$features" --expr \
		"(builtins.getFlake \"path:$root\").lib.evalHarness [ (/. + \"$tgt\") ]"
}

cmd_eval() {
  if [ -n "$out" ]; then
    build_json "$harness" > "$out"
    echo "wrote $out" >&2
  else
    build_json "$harness"
  fi
}

cmd_check() {
  local json
  json="$(build_json "$harness")"

  jq -r '
    .results[] | select(.ignored | not)
    | [ .severity, .stage, .id, (.subject // .path), .msg ] | @tsv
  ' <<< "$json" | column -t -s $'\t'

  jq -r '"\(.stats.failed) of \(.stats.checked) checks failed"' <<< "$json"
  jq -e '.ok' >/dev/null <<< "$json"
}

case "$cmd" in
  eval)  cmd_eval ;;
  check) cmd_check ;;
  *)     echo "unknown command: $cmd" >&2; usage; exit 2 ;;
esac
