import json
import re
import sys

sys.stdout.reconfigure(encoding='utf-8')

with open('src/content/postsData.json', 'r', encoding='utf-8') as f:
    posts = json.load(f)

post = None
for p in posts:
    if p.get('slug') == 'swiftfox':
        post = p
        break

if not post:
    print("swiftfox not found")
    sys.exit(1)

new_body = []
for item in post['body']:
    if item.startswith('code:'):
        lines = item.splitlines()
        header = lines[0] # e.g. code:python:image_encoder.py
        
        # Special case for sequence_concept: make it clean text layout without '#'
        if 'sequence_concept' in header:
            header = 'code:text:sequence_layout.txt'
            clean_lines = [
                header,
                "Text chat mode:",
                "[<user>] {input} [<assistant>] {generated_text}",
                "",
                "Multi-image mode (up to 3 images, expandable to more):",
                "[IMG1_1] ... [IMG1_16]  [IMG2_1] ... [IMG2_16]  [<user>] [T1] ... [TN]  [<assistant>] [G1] ... [GM]"
            ]
            new_body.append('\n'.join(clean_lines))
            continue
            
        clean_code_lines = [header]
        for line in lines[1:]:
            # check if line is purely a comment
            stripped = line.strip()
            if stripped.startswith('#'):
                continue
            # check if line has inline comment e.g. code # comment
            if '#' in line:
                # Be careful not to strip # inside string literals
                # In these snippets, '#' is only used as comment
                line_no_comment = re.sub(r'\s*#.*$', '', line)
                if line_no_comment.strip():
                    clean_code_lines.append(line_no_comment)
                continue
            clean_code_lines.append(line)
        
        # Clean consecutive blank lines
        final_lines = []
        for l in clean_code_lines:
            if not l.strip() and final_lines and not final_lines[-1].strip():
                continue
            final_lines.append(l)
        new_body.append('\n'.join(final_lines))
    else:
        new_body.append(item)

post['body'] = new_body

with open('src/content/postsData.json', 'w', encoding='utf-8') as f:
    json.dump(posts, f, indent=2, ensure_ascii=False)

print("Comments stripped from all code blocks in swiftfox successfully!")
