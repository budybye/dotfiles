#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
generate_diagram.py
-------------------
圏のオブジェクトと射の情報から Graphviz (dot) を生成し、PNG または SVG で出力します。
入力は標準入力から JSON 形式で受け取ります:

```json
{
  "objects": ["A", "B", "C"],
  "arrows": [
    ["A", "B", "f"],
    ["B", "C", "g"]
  ]
}
```

出力はバイナリの PNG（デフォルト）または `--format svg` オプションで SVG を標準出力します。
"""
import sys
import json
import subprocess
from pathlib import Path
import argparse

def build_dot(objects, arrows):
    lines = ["digraph G {", "  rankdir=LR;", "  node [shape=ellipse];"]
    for obj in objects:
        lines.append(f'  "{obj}";')
    for src, dst, label in arrows:
        lines.append(f'  "{src}" -> "{dst}" [label="{label}"];')
    lines.append("}")
    return "\n".join(lines)

def main():
    parser = argparse.ArgumentParser(description="Generate a category diagram using Graphviz.")
    parser.add_argument("--format", choices=["png", "svg"], default="png", help="Output image format")
    args = parser.parse_args()

    try:
        data = json.load(sys.stdin)
    except json.JSONDecodeError as e:
        sys.stderr.write(f"[error] Invalid JSON input: {e}\n")
        sys.exit(1)

    objects = data.get("objects", [])
    arrows = data.get("arrows", [])
    dot_src = build_dot(objects, arrows)

    # Write temporary dot file
    tmp_dot = Path("/tmp/category_diagram.dot")
    tmp_dot.write_text(dot_src, encoding="utf-8")

    out_path = Path("/tmp/category_diagram.") / args.format
    cmd = ["dot", f"-T{args.format}", str(tmp_dot), "-o", str(out_path)]
    try:
        subprocess.run(cmd, check=True, capture_output=True)
    except subprocess.CalledProcessError as e:
        sys.stderr.write(e.stderr.decode())
        sys.exit(1)

    # Emit binary image to stdout
    sys.stdout.buffer.write(out_path.read_bytes())
    # Cleanup temporary files
    try:
        tmp_dot.unlink()
        out_path.unlink()
    except Exception:
        pass

if __name__ == "__main__":
    main()
