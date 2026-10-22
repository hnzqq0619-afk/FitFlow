// Dependency-free static checks. This script does not compile Swift or run iOS tests.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import { fileURLToPath } from 'node:url';
const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const read = p => fs.readFileSync(path.join(root, p), 'utf8');
const exists = p => fs.existsSync(path.join(root, p));
const walk = dir => fs.readdirSync(path.join(root, dir), { withFileTypes: true }).flatMap(e => {
  const p = path.posix.join(dir, e.name);
  return e.isDirectory() ? walk(p) : [p];
});

// Parse OpenStep property lists, including quoted build-setting keys and comments.
function parseProject(source) {
  let i = 0;
  const tokens = [];
  while (i < source.length) {
    if (/\s/.test(source[i])) { i++; continue; }
    if (source.startsWith('//', i)) { const n = source.indexOf('\n', i); i = n < 0 ? source.length : n + 1; continue; }
    if (source.startsWith('/*', i)) {
      const end = source.indexOf('*/', i + 2); assert(end >= 0, 'Unterminated project comment'); i = end + 2; continue;
    }
    if ('{}()=;,'.includes(source[i])) { tokens.push(source[i++]); continue; }
    if (source[i] === '"') {
      let value = ''; i++;
      while (i < source.length && source[i] !== '"') {
        if (source[i] === '\\') { i++; assert(i < source.length); }
        value += source[i++];
      }
      assert.equal(source[i++], '"', 'Unterminated quoted project value');
      tokens.push({ value }); continue;
    }
    const begin = i;
    while (i < source.length && !/\s/.test(source[i]) && !'{}()=;,"'.includes(source[i])) i++;
    assert(i > begin, 'Unrecognized project token');
    tokens.push({ value: source.slice(begin, i) });
  }
  let cursor = 0;
  const take = expected => assert.equal(tokens[cursor++], expected, 'Invalid project syntax');
  function parse() {
    const token = tokens[cursor++];
    if (token === '{') {
      const object = {};
      while (tokens[cursor] !== '}') {
        const key = tokens[cursor++]?.value;
        assert.equal(typeof key, 'string', 'Expected project dictionary key');
        assert(!Object.hasOwn(object, key), 'Duplicate project key: ' + key);
        take('='); object[key] = parse(); take(';');
      }
      take('}'); return object;
    }
    if (token === '(') {
      const array = [];
      while (tokens[cursor] !== ')') { array.push(parse()); if (tokens[cursor] !== ')') take(','); }
      take(')'); return array;
    }
    assert.equal(typeof token?.value, 'string', 'Expected project value');
    return token.value;
  }
  const result = parse();
  assert.equal(cursor, tokens.length, 'Unexpected trailing project tokens');
  return result;
}

const projectText = read('FitFlow.xcodeproj/project.pbxproj');
const project = parseProject(projectText);
assert(project.objects[project.rootObject], 'Missing root project');
function verifyReferences(value) {
  if (typeof value === 'string' && /^[A-F0-9]{24}$/.test(value)) {
    assert(project.objects[value], 'Dangling Xcode object reference: ' + value);
  } else if (Array.isArray(value)) value.forEach(verifyReferences);
  else if (value && typeof value === 'object') Object.values(value).forEach(verifyReferences);
}
verifyReferences(project);
const configs = Object.values(project.objects).filter(o => o.isa === 'XCBuildConfiguration' && o.buildSettings.GENERATE_INFOPLIST_FILE);
assert.equal(configs.length, 2, 'Both app configurations must generate Info.plist');
for (const config of configs) {
  assert.equal(config.buildSettings.GENERATE_INFOPLIST_FILE, 'YES');
  assert(!config.buildSettings.INFOPLIST_FILE, 'Unexpected missing explicit Info.plist');
  assert(config.buildSettings.INFOPLIST_KEY_NSHealthShareUsageDescription);
  assert(exists(project.objects[config.baseConfigurationReference].path), 'Missing base xcconfig');
}
assert(!projectText.includes('GoogleGenerativeAI'), 'Deprecated SDK still referenced');
assert(!projectText.includes('JV7N3RT6H2'), 'Original signing team still hardcoded');
assert.equal(JSON.parse(read('FitFlow.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved')).pins.length, 0);
assert(read('Config/Project.xcconfig').includes('#include? "Local.xcconfig"'));
assert(read('.gitignore').includes('Config/Local.xcconfig'));

const manifest = read('Package.swift');
const sourceList = manifest.match(/sources:\s*\[([\s\S]*?)\]/)?.[1];
assert(sourceList, 'Swift package sources missing');
for (const match of sourceList.matchAll(/"([^"]+)"/g)) assert(exists('FitFlow/' + match[1]), 'Missing Swift package source: ' + match[1]);

const catalog = JSON.parse(read('FitFlow/Constants/Localizable.xcstrings'));
const cases = [...read('FitFlow/Constants/Enum/LocalizableEnum.swift').matchAll(/^\s*case\s+(\w+)/gm)].map(m => m[1]);
const formats = s => (s.match(/%(?:\d+\$)?(?:\.\d+)?(?:lld|ld|d|f|@)/g) ?? []).sort();
for (const key of cases) {
  const localizations = catalog.strings[key]?.localizations;
  const en = localizations?.en?.stringUnit?.value;
  const zh = localizations?.['zh-Hans']?.stringUnit?.value;
  assert(en && zh, 'Missing English/Chinese localization: ' + key);
  assert.deepEqual(formats(en), formats(zh), 'Format placeholders differ: ' + key);
}
for (const p of walk('FitFlow')) {
  if (/\.(json|xcstrings)$/.test(p)) JSON.parse(read(p));
}
const swiftFiles = walk('FitFlow').filter(p => p.endsWith('.swift'));
for (const p of swiftFiles) {
  const text = read(p);
  assert(!/import GoogleGenerativeAI|prefix\(5\).*isNumber|as! Error/.test(text), 'Obsolete unsafe code: ' + p);
  assert(!/AIza[A-Za-z0-9_-]{30,}/.test(text), 'Possible API secret in ' + p);
}
assert(!read('FitFlow/FitFlow.entitlements').includes('health-records'), 'Unused clinical entitlement remains');
assert(!read('FitFlow/Core/Manager/HealthManager.swift').includes('sharingAuthorized'), 'Write permission used as read permission');
const fixture = JSON.parse(read('Tests/FitFlowCoreTests/Fixtures/valid-plan.json'));
assert.equal(fixture.daily_plan.length, 7);
assert.equal(fixture.meal_plan.daily_meal_plans.length, 7);
console.log('Static checks passed: Xcode project references, configuration, ' + cases.length +
  ' localization keys, ' + swiftFiles.length + ' Swift source files, JSON resources and secret patterns.');
console.log('Swift compilation, XCTest and iOS runtime checks were NOT run by this script.');
