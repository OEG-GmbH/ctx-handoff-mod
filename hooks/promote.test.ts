// fork-patch: Die Promotion („Regeln ohne Rueckfrage in AGENTS.md/CLAUDE.md/Hooks/Skills schreiben“) ist
// abgeschaltet (register.ts promoteBlock, FORK_PROMOTE_DISABLED). Die Upstream-Tests zur Promotion sind
// durch diese Gegenprobe ersetzt: auch unter genau den Bedingungen, unter denen der Upstream den
// Auftrag einfuegt (git repo, Regel >= 3 mal, aktiver Guard), darf kein Promotion-Block entstehen.
import { expect, test } from 'claude-code/testing'
import type { Engine } from 'claude-code/testing'
import { NOTES, pushGuard, startSession, world } from './test-world'

const PROMOTE_NOTES = [
  '# ctx-handoff 專案經驗',
  '',
  '## 記憶',
  '- [feedback] 舊 A',
  '',
  '## 規則',
  '',
  '### 正式站刪除要斷言筆數（4 次）',
  '- 規則：DELETE 前先在 DO 區塊斷言筆數',
  '',
].join('\n')
const promoteBlockOf = async ($: Engine) =>
  (await $.prompt.context({ blocks: [] })).blocks.find(b => b.name === 'ctxHandoffPromote')?.text

test('fork-patch: kein Promotion-Block, auch in einem git repo mit Regel (4 mal) und aktivem Guard', async ($, on) => {
  const w = world(on, 100_000, 1_000_000, { 'guards:C--proj': [pushGuard('on')] }, [], 5)
  w.files.set(NOTES, PROMOTE_NOTES)
  w.files.set('C:/proj/.git', '')
  await startSession($)
  expect(await promoteBlockOf($)).toBeUndefined()
})
