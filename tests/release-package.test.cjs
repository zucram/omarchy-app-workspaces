// SPDX-License-Identifier: MIT
const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { execFileSync } = require('node:child_process');
const test = require('node:test');
const { releaseFiles, checkTree, packageRelease } = require('../scripts/package-release.cjs');
const root = path.resolve(__dirname, '..');

test('published source tree contains no agent instruction files', () => {
    checkTree(root);
});

test('release guard rejects agent instruction files and directories at any depth', t => {
    const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'app-workspaces-instructions-'));
    t.after(() => fs.rmSync(dir, { recursive: true, force: true }));
    for (const name of ['AGENTS.md', 'nested/CLAUDE.md', 'a/b/agents.override.md',
        'a/b/CLAUDE.local.md', 'a/b/GEMINI.md', 'a/b/CODEX.md', 'a/b/SKILL.md',
        'a/b/.cursorrules', 'a/b/.windsurfrules', 'a/b/.clinerules/rules.md',
        'a/b/.claude/rules/style.md', 'a/b/.codex/config.toml',
        'a/b/.cursor/rules/style.mdc', 'a/b/.github/copilot-instructions.md',
        'a/b/.github/instructions/style.instructions.md']) {
        const file = path.join(dir, name);
        fs.mkdirSync(path.dirname(file), { recursive: true });
        fs.writeFileSync(file, 'test fixture');
        assert.throws(() => checkTree(dir), /Agent instruction path/, name);
        fs.rmSync(dir, { recursive: true });
        fs.mkdirSync(dir);
    }
});

test('release archive contains exactly the runtime and documentation allowlist', t => {
    const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'app-workspaces-package-'));
    t.after(() => fs.rmSync(dir, { recursive: true, force: true }));
    const archive = path.join(dir, 'release.tar.gz');
    packageRelease(root, archive);
    const entries = execFileSync('tar', ['-tzf', archive], { encoding: 'utf8' }).trim().split('\n');
    assert.deepEqual(entries.sort(), [...releaseFiles].sort());
    const unpacked = path.join(dir, 'unpacked');
    fs.mkdirSync(unpacked);
    execFileSync('tar', ['-xzf', archive, '-C', unpacked]);
    checkTree(unpacked);
    for (const name of releaseFiles) {
        assert.deepEqual(fs.readFileSync(path.join(unpacked, name)), fs.readFileSync(path.join(root, name)), name);
    }
});
