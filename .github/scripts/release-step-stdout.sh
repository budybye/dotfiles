# step の最後に source する(実行ではなく source。$$ が step の shell である必要がある)。
# make が終わっても、この step の stdout を握ったまま残る process があると、runner は step を終えられない。
# 残っている process を表示して止める(原因の特定と、step が終わらないことの回避)
out="$(readlink "/proc/$$/fd/1" 2>/dev/null || true)"
case "${out}" in
  pipe:*)
    leaked=""
    for fd1 in /proc/[0-9]*/fd/1; do
      pid="${fd1#/proc/}"
      pid="${pid%%/*}"
      [ "${pid}" = "$$" ] && continue
      [ "$(readlink "${fd1}" 2>/dev/null)" = "${out}" ] || continue
      ppid="$(awk '{print $4}' "/proc/${pid}/stat" 2>/dev/null || true)"
      # このループが起こす一時的な子 process は除く
      [ "${ppid}" = "$$" ] && continue
      leaked="${leaked} ${pid}"
    done
    if [ -n "${leaked}" ]; then
      echo "=== step の stdout を握ったまま残っている process(止めます) ==="
      details=""
      for pid in ${leaked}; do
        line="$(printf '%s ppid=%s %s' "${pid}" "$(awk '{print $4}' "/proc/${pid}/stat" 2>/dev/null)" \
          "$(tr '\0' ' ' < "/proc/${pid}/cmdline" 2>/dev/null | cut -c1-160)")"
        echo "${line}"
        details="${details}${details:+ | }${line}"
      done
      # 原因が分かるまで step を失敗にして、test が通った扱い(= 公開の起動)にしない。呼び出し側が leaked を見る
      echo "::error title=step の stdout を握る process が残っている::${details}"
      # shellcheck disable=SC2086
      kill ${leaked} 2>/dev/null || true
      sleep 2
    fi
    ;;
esac
