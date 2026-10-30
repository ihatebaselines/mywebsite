import json
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

# Find the timeline index
body = post['body']
timeline_idx = None
for i, item in enumerate(body):
    if item.startswith('timeline:'):
        timeline_idx = i
        break

if timeline_idx is not None:
    # Update heading right before timeline if it exists
    if timeline_idx > 0 and body[timeline_idx - 1].startswith('## '):
        body[timeline_idx - 1] = "## 1. The Real Timeline (:"
    
    # Real timeline
    real_timeline = (
        "timeline:School Day | 3 Random CS Classes | Was sitting through 3 computer science classes at school, got bored, and hammered out the core multimodal architecture in an hour and a half. | 1.5 HOURS\n"
        "Evening | 1 Hour at Home | Got back home, spent about one more hour polishing the patching pipeline and setting up the training loop. | +1 HOUR\n"
        "Next 2 Days | The 48h Training Run | Trained it for 2 straight days. Saw that it was actually learning and converging, but realized it could be way better. | 2 DAYS\n"
        "~2 Weeks Later | Why Not MoE? | Came back to the code after about a week and a half or two. Decided to slap an Adaptive Mixture of Experts with SwiGLU onto it because honestly... why not (: that's literally it. | MOE"
    )
    body[timeline_idx] = real_timeline

post['body'] = body

with open('src/content/postsData.json', 'w', encoding='utf-8') as f:
    json.dump(posts, f, indent=2, ensure_ascii=False)

print("Updated timeline to the real origin story successfully!")
