#!/usr/bin/env bash
# GitHub Actions の ubuntu job 用。make init が止まったとき、cancel ではなく失敗で終わらせて原因を残す
# (cancel された job の log は API で読めない)
#   1. WATCHDOG_SECONDS 経っても終わらなければ、process の状況を出して、この step を失敗にする
#   2. make が終わった後に、step の stdout を握ったまま残る process があれば、表示して止め、step を失敗にする
set -u

WATCHDOG_SECONDS="${WATCHDOG_SECONDS:-1980}"
MAKE_TIMEOUT="${MAKE_TIMEOUT:-45m}"
MAKE_CMD="${MAKE_CMD:-make init}"
self=$$

as_root=()
if [ "$(id -u)" -ne 0 ]; then
  as_root=(sudo -n)
fi

# 引数の process の子孫をすべて止める(sudo で起動された root 所有のものも含む)。
# 止めずに step を終えると、残った子孫が step の stdout を握ったままで、runner が step を終われない
kill_descendants() {
  local pids
  pids="$(ps -eo pid=,ppid= 2>/dev/null | awk -v r="$1" '
    { parent[$1] = $2 }
    END {
      mark[r] = 1; changed = 1
      while (changed) {
        changed = 0
        for (p in parent) if (!(p in mark) && (parent[p] in mark)) { mark[p] = 1; changed = 1 }
      }
      for (p in mark) if (p != r) print p
    }')"
  if [ -n "${pids}" ]; then
    # shellcheck disable=SC2086
    "${as_root[@]}" kill -KILL ${pids} 2>/dev/null || true
  fi
}

dump_state() {
  echo "--- process tree"
  timeout 20 ps -eo pid,ppid,user,etime,stat,wchan:24,args --forest 2>/dev/null | cut -c1-200 | tail -150
  echo "--- stdout / stderr が pipe の process"
  timeout 20 sh -c 'ls -l /proc/[0-9]*/fd/1 /proc/[0-9]*/fd/2 2>/dev/null | grep "pipe:" | cut -c1-170' || true
  echo "--- dmesg (末尾)"
  timeout 10 sudo -n dmesg 2>/dev/null | tail -40 || true
}

(
  # kill されたら、握っている sleep も止めて終わる(sleep が残ると step の stdout を握り続ける)
  trap 'kill "${sleeper:-}" 2>/dev/null; exit 0' TERM
  sleep "${WATCHDOG_SECONDS}" &
  sleeper=$!
  wait "${sleeper}"
  echo "=== watchdog: ${WATCHDOG_SECONDS} 秒経っても make が終わらない ==="
  dump_state
  echo "::error title=make init が終わらない::${WATCHDOG_SECONDS} 秒経過。process tree は上の log を参照"
  kill_descendants "${self}"
  kill -TERM "${self}"
) &
watchdog=$!

rc=0
# shellcheck disable=SC2086
timeout -k 30 "${MAKE_TIMEOUT}" ${MAKE_CMD} || rc=$?

kill "${watchdog}" 2>/dev/null || true
wait "${watchdog}" 2>/dev/null || true

if [ "${rc}" -ne 0 ]; then
  echo "=== make init exit code: ${rc}"
  dump_state
fi

# step の stdout を握ったまま残る process(sudo 起動のものは root 所有なので root で探す)
out="$(readlink "/proc/${self}/fd/1" 2>/dev/null || true)"
case "${out}" in
  pipe:*)
    leaked="$(timeout 30 "${as_root[@]}" bash -s -- "${out}" "${self}" <<'SCAN' 2>/dev/null || true
out="$1"
me="$2"
for fd1 in /proc/[0-9]*/fd/1; do
  pid="${fd1#/proc/}"
  pid="${pid%%/*}"
  [ "${pid}" = "${me}" ] && continue
  [ "$(readlink "${fd1}" 2>/dev/null)" = "${out}" ] || continue
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
          "$(timeout 5 "${as_root[@]}" tr '\0' ' ' < "/proc/${pid}/cmdline" 2>/dev/null | cut -c1-160)")"
        echo "${line}"
        details="${details}${details:+ | }${line}"
      done
      dump_state
      echo "::error title=step の stdout を握る process が残っている::${details}"
      # shellcheck disable=SC2086
      "${as_root[@]}" kill ${leaked} 2>/dev/null || true
      sleep 2
      [ "${rc}" -ne 0 ] || rc=1
    fi
    ;;
esac

exit "${rc}"
