#!/bin/sh
# Prueft, dass die Fork-Patches (Promotion aus, kein safe-replace-Hinweis) jeden Upstream-Merge
# ueberleben. Aufruf aus dem Repo-Wurzelverzeichnis: sh tools/fork-guard.sh
set -eu

cd "$(dirname "$0")/.."

fail() {
  echo "fork-guard: $1" >&2
  exit 1
}

grep -q '^const FORK_PROMOTE_DISABLED = true$' hooks/register.ts ||
  fail "FORK_PROMOTE_DISABLED fehlt oder ist nicht true"
grep -q 'if (FORK_PROMOTE_DISABLED) return undefined' hooks/register.ts ||
  fail "Frueher Ausstieg in promoteBlock fehlt"
grep -q 'fork-patch: kein Promotion-Block' hooks/promote.test.ts ||
  fail "Fork-Test fehlt"
grep -q 'fork-patch: Ablauf (3 mal)' hooks/procedures.test.ts ||
  fail "Fork-Test (Ablaeufe) fehlt"
grep -q 'fork-patch: kein safe-replace' hooks/loops.test.ts ||
  fail "Fork-Test (safe-replace) fehlt"
[ -z "$(grep -rn safe-replace hooks/ | grep -v '\.test\.ts:' || true)" ] ||
  fail "safe-replace taucht in hooks/ (ausser Tests) wieder auf"
[ "$(grep -rn 'promoteText(' hooks/ | grep -v 'export const promoteText' | grep -o 'promoteText(' | wc -l)" -eq 1 ] ||
  fail "promoteText( muss in hooks/ genau einmal aufgerufen werden (Definition nicht gezaehlt)"

echo "fork-guard: Fork-Patches vorhanden"
