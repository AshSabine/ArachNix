"""Convert the JSON built by `arachnix eval` into a WireViz YAML document.

Reads `resolved` (what the machine understood) and `output` (issues per entity).

Vocabulary mapping:
    connector            -> connector            pin requests -> pinlabels
    cable                -> cable                cores        -> wires (wirecount)
    core touching 2 pins -> one connection       core touching 3+ pins -> a junction connector
Pin NUMBERS are chosen here: ArachNix declares pin names only, so this is where numbering
happens, for visualisation. A request's `num` wins; the rest fill the free numbers in order.
"""
from __future__ import annotations

import re
from collections import defaultdict

NC_LABEL = "N/C"


def number_pins(requests: list[dict], pin_count: int | None) -> tuple[list[str], dict[str, int]]:
    """-> (pinlabels, {pin name: pin number}). Numbers are 1-based."""
    taken = {r["num"] for r in requests if r.get("num")}
    nxt = 1
    placed: list[tuple[int, dict]] = []
    for r in requests:
        if r.get("num"):
            number = r["num"]
        else:
            while nxt in taken:
                nxt += 1
            number = nxt
            taken.add(number)
        placed.append((number, r))

    size = max([pin_count or 0] + [n for n, _ in placed])
    labels = [""] * size
    numbers: dict[str, int] = {}
    for number, r in placed:
        labels[number - 1] = NC_LABEL if r.get("nc") else (r.get("name") or "")
        if r.get("name") and not r.get("nc"):
            numbers.setdefault(r["name"], number)
    return labels, numbers


def color_code(color: dict | None) -> str | None:
    """IEC tokens become their code, joined (GN + YE -> GNYE). Hex-only colours pass through."""
    if not color:
        return None
    tokens = [t for t in color.get("tokens", []) if t.get("ty") != "ERR"]
    if not tokens:
        return None
    if all(t["ty"] == "IEC" for t in tokens):
        return "".join(t["val"] for t in tokens)
    return tokens[0]["val"]


class Designators:
    """WireViz designators cannot contain '.', '#', '~' and the like: map names to safe, unique ones."""

    def __init__(self) -> None:
        self._by_name: dict[str, str] = {}
        self._used: set[str] = set()

    def __call__(self, name: str) -> str:
        if name in self._by_name:
            return self._by_name[name]
        base = re.sub(r"[^A-Za-z0-9_]", "_", name) or "_"
        safe, n = base, 2
        while safe in self._used:
            safe, n = f"{base}_{n}", n + 1
        self._used.add(safe)
        self._by_name[name] = safe
        return safe


def notes_for(issues: list[dict]) -> str | None:
    lines = [f'{i["severity"]}: {i["msg"]}' for i in issues if i.get("severity") in ("error", "warning")]
    return "\n".join(lines) if lines else None


def convert(model: dict) -> dict:
    resolved = model["resolved"]
    out = model.get("output", {})
    connectors = resolved.get("connectors", {})
    cables = resolved.get("cables", {})
    cores = resolved.get("cores", {})

    doc: dict = {"connectors": {}, "cables": {}, "connections": []}
    d = Designators()

    # ---- connectors -------------------------------------------------------------------
    pin_map: dict[str, dict[str, int]] = {}
    for name, c in connectors.items():
        labels, numbers = number_pins(c.get("requests", []), c.get("pinCount"))
        pin_map[name] = numbers
        entry: dict = {"pinlabels": labels}
        bom = c.get("bom") or {}
        if bom.get("desc"):
            entry["type"] = bom["desc"]
        if c.get("connType"):
            entry["subtype"] = c["connType"]
        if bom.get("mfr"):
            entry["manufacturer"] = bom["mfr"]
        if bom.get("sku"):
            entry["pn"] = bom["sku"]
        if notes := notes_for(out.get("connectors", {}).get(name, {}).get("issues", [])):
            entry["notes"] = notes
        doc["connectors"][d(name)] = entry

    # ---- cables and connections ---------------------------------------------------------
    by_cable: dict[str, list[dict]] = defaultdict(list)
    for core in cores.values():
        by_cable[core["cable"]].append(core)

    def resolve(ep: dict) -> tuple[str, int] | None:
        conn, pin = ep.get("conn"), ep.get("pin")
        if conn in pin_map and pin in pin_map[conn]:
            return conn, pin_map[conn][pin]
        return None

    for cable_id, cable in cables.items():
        its = sorted(by_cable.get(cable_id, []), key=lambda c: c["index"])
        if not its:
            continue
        entry = {"wirecount": len(its)}
        codes = [color_code(c.get("color")) for c in its]
        if any(codes):
            entry["colors"] = [code or "" for code in codes]
        bom = cable.get("bom") or {}
        if bom.get("desc"):
            entry["type"] = bom["desc"]
        if bom.get("mfr"):
            entry["manufacturer"] = bom["mfr"]
        if bom.get("sku"):
            entry["pn"] = bom["sku"]
        notes = [n for c in its if (n := notes_for(out.get("cores", {}).get(c["id"], {}).get("issues", [])))]
        if notes:
            entry["notes"] = "\n".join(notes)
        doc["cables"][d(cable_id)] = entry

        # 2-pin cores, grouped by connector pair so a bundle renders as one connection
        groups: dict[tuple[str, str], list[tuple[int, int, int]]] = {}
        for wire_no, core in enumerate(its, start=1):
            eps = [resolve(e) for e in core.get("conns", [])]
            if len(eps) == 2 and all(eps):
                (a, pa), (b, pb) = eps
                groups.setdefault((a, b), []).append((pa, wire_no, pb))
            elif len(eps) > 2 and all(eps):
                # a splice: a junction connector, wired to every endpoint by its own wires
                junction = d(f'splice_{core["id"]}')
                spliced = d(f'splice_{core["id"]}_wires')
                doc["connectors"][junction] = {"pinlabels": [f"{j}" for j in range(1, len(eps) + 1)],
                                               "type": "splice"}
                doc["cables"][spliced] = {"wirecount": len(eps)}
                for k, (conn, pin) in enumerate(eps, start=1):
                    doc["connections"].append([{d(conn): [pin]}, {spliced: [k]}, {junction: [k]}])
            elif len(eps) == 1 and eps[0]:
                conn, pin = eps[0]
                doc["connections"].append([{d(conn): [pin]}, {d(cable_id): [wire_no]}])
            # cores with unresolved endpoints are left out; their issues are in the notes

        direct = len(groups) + sum(1 for core in its if len(core.get("conns", [])) == 1)
        if direct == 0:
            del doc["cables"][d(cable_id)]      # every core was spliced: nothing to draw for the cable itself
            continue

        for (a, b), rows in groups.items():
            doc["connections"].append([
                {d(a): [r[0] for r in rows]},
                {d(cable_id): [r[1] for r in rows]},
                {d(b): [r[2] for r in rows]},
            ])

    return doc
