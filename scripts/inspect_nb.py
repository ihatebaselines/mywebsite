import json, sys
sys.stdout.reconfigure(encoding='utf-8')
nb_path = r'C:\Users\kenyp\.gemini\antigravity\brain\1e33501b-37d4-456b-a34c-29ac1999494c\.user_uploaded\media_1793372736496_bc523910.ipynb'
with open(nb_path, 'r', encoding='utf-8') as f:
    nb = json.load(f)

c10 = ''.join(nb['cells'][10].get('source', []))
lines = c10.splitlines()
for idx, l in enumerate(lines):
    if "load_balance_loss" in l or "ResidualBlock2D" in l:
        print(f"--- around line {idx} ---")
        for j in range(max(0, idx-5), min(len(lines), idx+30)):
            print(f"{j}: {lines[j]}")
        print("--------------------")
        break
