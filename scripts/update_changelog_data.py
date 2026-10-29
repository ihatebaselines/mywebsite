import json

path = 'src/content/changelogData.json'
with open(path, 'r', encoding='utf-8') as f:
    data = json.load(f)

meta_map = {
    'v2.1': ('swift 1', '/images/updates/update_2_1.jpg'),
    'v2.0': ('swift', '/images/updates/update_2_0.jpg'),
    'v1.9.5': ('zero 9.5', '/images/updates/update_1_9_5.jpg'),
    'v1.9.3': ('zero 9.3', '/images/updates/update_1_9_3.jpg'),
    'v1.9.2': ('zero 9.2', '/images/updates/update_1_9_2.jpg'),
    'v1.9.1': ('zero 9.1', '/images/updates/update_1_9_1.jpg'),
    'v1.9': ('zero 9', '/images/updates/update_1_9.jpg'),
    'v1.8.5': ('zero 8.5', '/images/updates/update_1_8_5.jpg'),
    'v1.8': ('zero 8', '/images/updates/update_1_8.jpg'),
    'v1.5': ('zero 5', '/images/updates/update_1_5.jpg'),
    'v1.0': ('zero', '/images/updates/update_1_0.jpg'),
}

for item in data:
    v = item['version']
    if v in meta_map:
        item['codename'] = meta_map[v][0]
        item['image'] = meta_map[v][1]

versions = [item['version'] for item in data]
if 'v0.2' not in versions:
    data.append({
        'version': 'v0.2',
        'codename': 'hi 2',
        'date': '2026-06-20',
        'title': 'Interactive Canvas & Physics',
        'tag': 'Prototype',
        'tagType': 'feature',
        'summary': 'Early physics sandbox, draggable UI components, and initial interactive experiments.',
        'quote': 'Simplicity is prerequisite for reliability.',
        'quoteAuthor': 'Edsger W. Dijkstra',
        'changes': [
            'Built initial prototype canvas with interactive particle physics.',
            'Experimented with spring mechanics and custom coordinate mapping.',
            'Tested layout foundations for upcoming project releases.'
        ],
        'image': '/images/updates/update_0_2.jpg'
    })

if 'v0.1' not in versions:
    data.append({
        'version': 'v0.1',
        'codename': 'hi 1',
        'date': '2026-06-01',
        'title': 'Genesis',
        'tag': 'Genesis',
        'tagType': 'milestone',
        'summary': "First commit. Blank screen, a simple 'hello world', and the start of ihatebaselines.",
        'quote': 'The journey of a thousand miles begins with a single step.',
        'quoteAuthor': 'Lao Tzu',
        'changes': [
            'Repository initialized at zero.',
            'Basic Next.js scaffolding created.',
            'First local test build succeeded.'
        ],
        'image': '/images/updates/helloglitched.jpg'
    })

with open(path, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print(f"Updated changelogData.json successfully with {len(data)} entries")
