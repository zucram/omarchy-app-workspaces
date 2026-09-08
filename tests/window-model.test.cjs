// SPDX-License-Identifier: MIT
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const test = require('node:test');
const model = {};
vm.createContext(model);
vm.runInContext(fs.readFileSync(path.join(__dirname,
    '../WindowModel.js'), 'utf8')
    .replace(/^\.pragma library\s*/, ''), model);
const plain = value => JSON.parse(JSON.stringify(value));
const entry = (id, name, icon, more = {}) => ({ id, name, icon, ...more });

test('classless LibrePods uses its launcher name', () => {
    const libre = entry('me.kavishdevar.librepods', 'LibrePods', 'librepods');
    assert.equal(model.resolveEntry('', 'LibrePods', [libre], null), libre);
});

test('YouTube URL class wins over a generic browser heuristic', () => {
    const youtube = entry('YouTube', 'YouTube', 'youtube', {
        execString: 'omarchy-launch-webapp https://youtube.com/'
    });
    const browser = entry('helium', 'Helium', 'helium');
    assert.equal(model.resolveEntry('chrome-youtube.com__-Default', 'Video',
        [browser, youtube], browser), youtube);
    const other = entry('other', 'Other', 'other', {
        execString: 'omarchy-launch-webapp https://youtube.com/other'
    });
    assert.equal(model.resolveEntry('chrome-youtube.com_other_-Default', '',
        [youtube, other], browser), other);
});

test('T3 iconless class hint finds the visible launcher with the same name', () => {
    const hint = entry('com.t3tools.T3Code', 'T3 Code (Nightly)', '', { noDisplay: true });
    const visible = entry('t3code', hint.name, '/home/zucram/icons/t3code.png');
    assert.equal(model.resolveEntry('com.t3tools.T3Code', 'project',
        [hint, visible], hint), visible);
});

test('Beeper installed after an initial miss resolves without stale cache', () => {
    assert.equal(model.resolveEntry('Beeper', 'Chat', [], null), null);
    const beeper = entry('beeper', 'Beeper', 'beeper');
    assert.equal(model.resolveEntry('Beeper', 'Chat', [beeper], null), beeper);
});

test('exact startup class and ID outrank name hints; iconless entries do not win', () => {
    const startup = entry('different-id', 'Different', 'exact', { startupClass: 'App' });
    const id = entry('app.desktop', 'App', 'id');
    const hint = entry('guess', 'Guess', 'guess');
    assert.equal(model.resolveEntry('App', '', [id, startup, hint], hint), startup);
    assert.equal(model.resolveEntry('App', '', [{ ...startup, icon: '' }, id], hint), id);
    assert.equal(model.resolveEntry('unknown', '', [], null), null);
    assert.equal(model.resolveEntry('unknown', '', [], { icon: '' }), null);
});

test('overrides match exact keys and desktop IDs only', () => {
    const custom = entry('custom', 'Custom', 'custom');
    const original = entry('beeper', 'Beeper', 'beeper');
    assert.equal(model.resolveEntry('Beeper', '', [original, custom], null,
        { Beeper: 'custom.desktop' }), custom);
    assert.equal(model.resolveEntry('Beeper', '', [original, custom], null,
        { beeper: 'custom' }), original);
    assert.equal(model.resolveEntry('', 'LibrePods', [custom], null,
        { 'title:LibrePods': 'custom' }), custom);
    assert.equal(model.resolveEntry('Unknown', '', [custom], null,
        { Unknown: '$(touch /tmp/never-run)' }), null);
    assert.equal(model.resolveEntry('Unknown', '', [custom], null,
        Object.create({ Unknown: 'custom' })), null);
});

test('workspace 3 follows screen order, preserving one icon per window by default', () => {
    const windows = [
        { address: 'd', class: 'Outlook', at: [5757, 0] },
        { address: 'b', class: 'Teams', at: [1937, 0] },
        { address: 'a', class: 'Obsidian', at: [22, 0] },
        { address: 'c', class: 'Helium', at: [3847, 0] }
    ];
    assert.deepEqual(plain(model.orderedWindows(windows, false)).map(w => w.class),
        ['Obsidian', 'Teams', 'Helium', 'Outlook']);
    assert.equal(windows[0].class, 'Outlook');
    const duplicates = [windows[0], { ...windows[0], address: 'e', at: [1, 0] }];
    assert.equal(model.orderedWindows(duplicates, false).length, 2);
    assert.equal(model.orderedWindows(duplicates, true)[0].address, 'e');
});

test('ties sort by y then address; classless groups use title', () => {
    const rows = ['b', 'a', 'c'].map((address, i) => ({
        address, class: '', title: i < 2 ? 'LibrePods' : 'Other', at: [0, i === 2 ? -1 : 0]
    }));
    assert.deepEqual(plain(model.orderedWindows(rows, false)).map(w => w.address), ['c', 'a', 'b']);
    assert.deepEqual(plain(model.orderedWindows(rows, true)).map(w => w.address), ['c', 'a']);
    assert.equal(model.orderedWindows([{}, {}], true).length, 2);
});

test('settings reject malformed types and clamp numeric ranges', () => {
    const defaults = { iconSize: 20, iconGap: 6, maxIcons: 0, showNumbers: true,
        showIcons: true, showEmpty: false, perMonitor: true, groupApps: false, showScratchpad: true, showEmptyScratchpad: false, showFloating: true, markFloating: true };
    for (const raw of [null, undefined, false, 'bad', {}, { iconSize: '28', iconGap: NaN,
        maxIcons: Infinity, showEmpty: 'false', groupApps: 1 }]) {
        assert.deepEqual(plain(model.normalizeSettings(raw)), defaults);
    }
    assert.deepEqual(plain(model.normalizeSettings({ iconSize: 100, iconGap: -10,
        maxIcons: 99, showNumbers: false, showIcons: false, showEmpty: true,
        perMonitor: false, groupApps: true })), { iconSize: 28, iconGap: 2, maxIcons: 20,
        showNumbers: false, showIcons: false, showEmpty: true, perMonitor: false, groupApps: true, showScratchpad: true, showEmptyScratchpad: false, showFloating: true, markFloating: true });
});

test('workspaces filter by monitor, occupancy and active ID without an ID ceiling', () => {
    const rows = [
        { id: 21, monitor: 'A', windows: 1 }, { id: 3, monitor: 'A', windows: 0 },
        { id: 1, monitor: 'A', windows: 0 }, { id: 2, monitor: 'B', windows: 1 },
        { id: -99, monitor: 'A', windows: 1 }, { id: 0, monitor: 'A', windows: 1 }
    ];
    const ids = settings => plain(model.visibleWorkspaces(rows, 'A', 3, settings)).map(w => w.id);
    assert.deepEqual(ids({}), [3, 21]);
    assert.deepEqual(ids({ showEmpty: true }), [1, 3, 4, 5, 6, 7, 8, 9, 10, 21]);
    assert.deepEqual(ids({ perMonitor: false }), [2, 3, 21]);
    assert.equal(rows[0].id, 21);
});

test('show empty offers the ten standard destinations before Hyprland creates them', () => {
    const rows = [{ id: 1, name: '1', monitor: 'A', windows: 2 }];
    const shown = plain(model.visibleWorkspaces(rows, 'A', 1, { showEmpty: true }));
    assert.deepEqual(shown.map(w => w.id), [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
    assert.equal(shown[0].windows, 2);
    assert.ok(shown.slice(1).every(w => w.windows === 0 && w.monitor === 'A'));
    assert.deepEqual(plain(model.visibleWorkspaces(rows, 'A', 1, {})).map(w => w.id), [1]);
    assert.equal(rows.length, 1);
    assert.equal(model.visibleWorkspaces([], 'A', 1, { showEmpty: true }).length, 10);
});

test('empty destinations do not duplicate live workspaces assigned to another monitor', () => {
    const rows = [{ id: 2, name: '2', monitor: 'B', windows: 0 },
        { id: 15, name: '15', monitor: 'A', windows: 1 }];
    const local = plain(model.visibleWorkspaces(rows, 'A', 15, { showEmpty: true }));
    assert.ok(!local.some(w => w.id === 2));
    assert.equal(local.at(-1).id, 15);
    const all = plain(model.visibleWorkspaces(rows, 'A', 15,
        { showEmpty: true, perMonitor: false }));
    assert.equal(all.filter(w => w.id === 2).length, 1);
    assert.equal(all.find(w => w.id === 2).monitor, 'B');
});

test('scratchpads stay reachable across monitors and can be hidden', () => {
    const rows = [{ id: -98, name: 'special:scratchpad', windows: 2, monitor: 'B' },
        { id: -97, name: 'special:music', windows: 0 }, { id: 1, name: '1', windows: 1 }];
    assert.deepEqual(plain(model.scratchpads(rows, [], {})).map(w => w.id), [-98]);
    assert.equal(model.scratchpads(rows, [], { showScratchpad: false }).length, 0);
    assert.equal(model.scratchpads(rows, [], { showEmptyScratchpad: true }).length, 2);
    assert.equal(model.scratchpads(rows, [-97], {}).length, 2);
});

test('floating filters apply to numbered and special workspaces before grouping', () => {
    const rows = [{ address: 'a', workspaceId: 3, class: 'app', floating: true, at: [0,0] },
        { address: 'b', workspaceId: 3, class: 'app', floating: false, at: [2,0] },
        { address: 'c', workspaceId: -98, class: 'app', floating: true, at: [1,0] }];
    assert.deepEqual(plain(model.windowsForWorkspace(rows, 3, {})).map(w => w.address), ['a', 'b']);
    assert.deepEqual(plain(model.windowsForWorkspace(rows, 3,
        { showFloating: false, groupApps: true })).map(w => w.address), ['b']);
    assert.equal(model.windowsForWorkspace(rows, -98, { showFloating: false }).length, 0);
    assert.equal(model.normalizeSettings({ markFloating: false }).markFloating, false);
});

test('Lua strings quote names without executable fragments or raw newlines', () => {
    assert.equal(model.luaString('scratchpad'), '"scratchpad"');
    assert.equal(model.luaString('x"\\\n\u0000'), '"x\\"\\\\\\010\\000"');
});

test('empty scratchpad preference preserves named destinations after last close', () => {
    const placeholders = plain(model.scratchpads([], [], { showEmptyScratchpad: true },
        ['special:scratchpad', 'special:music']));
    assert.deepEqual(placeholders.map(w => w.name), ['special:music', 'special:scratchpad']);
    assert.ok(placeholders.every(w => w.placeholder && w.windows === 0));
    assert.equal(model.scratchpads([], [], {}).length, 0);
});
