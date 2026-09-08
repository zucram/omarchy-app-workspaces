// SPDX-License-Identifier: MIT
const fs = require('node:fs');
const path = require('node:path');
const { execFileSync } = require('node:child_process');

// Include only the runtime, attribution, and user documentation in archives.
const releaseFiles = [
    'Workspaces.qml', 'SettingsPanel.qml', 'WindowModel.js', 'manifest.json',
    'README.md', 'NOTICE.md', 'LICENSE', 'CHANGELOG.md', 'preview.png',
    'docs/appearance.png', 'docs/windows.png', 'docs/validation.md'
];

function isAgentInstruction(relativePath) {
    const parts = relativePath.replaceAll('\\', '/').toLowerCase().split('/');
    return parts.some((part, index) =>
        /^(agents|claude|gemini|codex)(\.[^.]+)*\.md$/.test(part)
        || /^(skill|copilot-instructions)\.md$/.test(part)
        || /^\.(agents|claude|codex|cursor|cursorrules|windsurf|windsurfrules|cline|clinerules|roo|roorules)$/.test(part)
        || (parts[index - 1] === '.github' && ['instructions', 'agents', 'prompts'].includes(part)));
}

function checkTree(root, relative = '') {
    for (const entry of fs.readdirSync(path.join(root, relative), { withFileTypes: true })) {
        if (!relative && entry.name === '.git') continue;
        const name = relative ? `${relative}/${entry.name}` : entry.name;
        if (isAgentInstruction(name)) throw new Error(`Agent instruction path is not publishable: ${name}`);
        if (entry.isSymbolicLink()) throw new Error(`Symlink is not publishable: ${name}`);
        if (entry.isDirectory()) checkTree(root, name);
    }
}

function packageRelease(root, output) {
    checkTree(root);
    for (const name of releaseFiles) {
        if (!fs.statSync(path.join(root, name)).isFile()) throw new Error(`Missing release file: ${name}`);
    }
    execFileSync('tar', ['-czf', path.resolve(output), '-C', root, '--', ...releaseFiles]);
}

module.exports = { releaseFiles, isAgentInstruction, checkTree, packageRelease };

if (require.main === module) {
    const root = path.resolve(__dirname, '..');
    const version = JSON.parse(fs.readFileSync(path.join(root, 'manifest.json'))).version;
    const output = process.argv[2] || path.join(root, `app-workspaces-${version}.tar.gz`);
    packageRelease(root, output);
    console.log(`Packaged ${output}`);
}
