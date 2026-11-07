# step の最後に source する(実行ではなく source。$$ が step の shell である必要がある)。
# make が終わっても、この step の stdout を握ったまま残る process があると、runner は step を終えられない。
# 残っている process を表示して止める(原因の特定と、step が終わらないことの回避)。
# runner の step は一般ユーザーで、sudo で起動された process は root のものなので、探すのも止めるのも root で行う
out="$(readlink "/proc/$$/fd/1" 2>/dev/null || true)"
leaked=""
case "${out}" in
  pipe:*)
    as_root=""
    if [ "$(id -u)" -ne 0 ]; then
      as_root="sudo -n"
    fi
    # shellcheck disable=SC2086
    leaked="$(${as_root} bash -s -- "${out}" "$$" <<'SCAN' 2>/dev/null || true
out="$1"
me="$2"
for fd1 in /proc/[0-9]*/fd/1; do
  pid="${fd1#/proc/}"
  pid="${pid%%/*}"
  [ "${pid}" = "${me}" ] && continue
  [ "$(readlink "${fd1}" 2>/dev/null)" = "${out}" ] || continue
  # このスキャン自身と、その一時的な子 process は除く
  [ "${pid}" = "$$" ] && continue
  [ "$(awk '{print $4}' "/proc/${pid}/stat" 2>/dev/null)" = "$$" ] && continue
  printf '%s ' "${pid}"
done
SCAN
    )"
    if [ -n "${leaked}" ]; then
      echo "=== step の stdout を握ったまま残っている process(止めます) ==="
      details=""
      for pid in ${leaked}; do
        line="$(printf '%s ppid=%s user=%s %s' "${pid}" \
          "$(awk '{print $4}' "/proc/${pid}/stat" 2>/dev/null)" \
          "$(stat -c %U "/proc/${pid}" 2>/dev/null)" \
          "$(${as_root:-} tr '\0' ' ' < "/proc/${pid}/cmdline" 2>/dev/null | cut -c1-160)")"
        echo "${line}"
        details="${details}${details:+ | }${line}"
      done
      echo "--- process tree"
      ps -eo pid,ppid,user,etime,args --forest 2>/dev/null | cut -c1-180 | tail -60
      # 原因が分かるまで step を失敗にして、test が通った扱い(= 公開の起動)にしない。呼び出し側が leaked を見る
      echo "::error title=step の stdout を握る process が残っている::${details}"
      # shellcheck disable=SC2086
      ${as_root} kill ${leaked} 2>/dev/null || true
      sleep 2
    fi
    ;;
esac
