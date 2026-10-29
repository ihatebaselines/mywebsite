import cv2, numpy as np, random, os
from PIL import Image

updates = [
    ('update 2.1', 'update_2_1.jpg', 201),
    ('update 2.0', 'update_2_0.jpg', 200),
    ('update 1.9.5', 'update_1_9_5.jpg', 195),
    ('update 1.9.3', 'update_1_9_3.jpg', 193),
    ('update 1.9.2', 'update_1_9_2.jpg', 192),
    ('update 1.9.1', 'update_1_9_1.jpg', 191),
    ('update 1.9', 'update_1_9.jpg', 190),
    ('update 1.8.5', 'update_1_8_5.jpg', 185),
    ('update 1.8', 'update_1_8.jpg', 180),
    ('update 1.5', 'update_1_5.jpg', 150),
    ('update 1.0', 'update_1_0.jpg', 100),
    ('update 0.2', 'update_0_2.jpg', 20),
    ('update 0.1', 'update_0_1.jpg', 10),
]

symbols = [
    '※', '⁂', '⁑', '⁕', '⁖', '⁘', '⁙', '⁛', '⁜', '⁝',
    '⌁', '⌇', '⌖', '⌗', '⌘', '⌬', '⌭', '⌯', '⌰', '⌿',
    '¿', '¡', '‽', '※', '〄', '〒', '〆', '々', '〻', 'ゞ',
    'ヰ', 'ヱ', 'ヲ', 'メ', 'ヌ', 'シ', 'ツ', '乂', '文', '幽',
]

os.makedirs('public/images/updates/glitch', exist_ok=True)
os.makedirs('public/images/updates/normal', exist_ok=True)

SIZE = 500

for text, filename, seed in updates:
    for is_glitch, folder in [(True, 'public/images/updates/glitch'), (False, 'public/images/updates/normal')]:
        random.seed(seed + (999 if is_glitch else 0))
        np.random.seed(seed + (999 if is_glitch else 0))
        img = np.ones((SIZE, SIZE, 3), dtype=np.uint8) * 255
        font = cv2.FONT_HERSHEY_DUPLEX
        
        if is_glitch:
            color = (180, 70, 220) # Glitch purple/magenta BGR
        else:
            color = (115, 116, 63) # Site green BGR for rgb(63, 116, 115)
            
        font_scale = 1.35
        thickness = 3
        (text_w, text_h), baseline = cv2.getTextSize(text, font, font_scale, thickness)
        x = (SIZE - text_w) // 2
        y = (SIZE + text_h) // 2

        if is_glitch:
            for _ in range(12):
                symbol = random.choice(symbols)
                sx = random.randint(25, SIZE - 25)
                sy = random.randint(35, SIZE - 25)
                if abs(sx - SIZE//2) < (text_w // 2 + 25) and abs(sy - SIZE//2) < 45:
                    sx = random.choice([random.randint(25, max(30, x - 30)), random.randint(min(SIZE - 35, x + text_w + 20), SIZE - 20)])
                    sy = random.randint(35, SIZE - 25)
                scale = random.uniform(0.7, 1.6)
                thick = random.randint(1, 2)
                try:
                    cv2.putText(img, symbol, (sx, sy), font, scale, color, thick, cv2.LINE_AA)
                except Exception:
                    pass

        cv2.putText(img, text, (x, y), font, font_scale, color, thickness, cv2.LINE_AA)

        # Wave remap
        h, w, _ = img.shape
        x_grid, y_grid = np.meshgrid(np.arange(w), np.arange(h))
        max_y = y_grid.copy().astype(np.float32)
        max_x = (x_grid + 8 * np.sin(0.05 * y_grid)).astype(np.float32)

        new_img = cv2.remap(img, max_x, max_y, cv2.INTER_NEAREST, cv2.BORDER_REFLECT)

        if is_glitch:
            res = new_img.copy()
            res[:, :, 2] = np.roll(res[:, :, 2], 45, axis=1)
            res[:, :, 2] = np.roll(res[:, :, 0], -45, axis=1)
            res[:, :, 0] = np.roll(res[:, :, 1], -28, axis=1)
            res[:, :, 2] = np.roll(res[:, :, 1], 28, axis=1)
            res[:, :, 2] = np.roll(res[:, :, 2], -8, axis=1)
            res[:, :, 0] = np.roll(res[:, :, 2], 18, axis=0)
            res[:, :, 1] = np.roll(res[:, :, 1], 4, axis=0)
            res[:, :, 1] = np.roll(res[:, :, 0], random.randint(4, 14), axis=0)
        else:
            res = new_img.copy()

        # Pixelated resize
        res = cv2.resize(res, (SIZE // 4, SIZE // 4), interpolation=cv2.INTER_LINEAR)
        res = cv2.resize(res, (SIZE, SIZE), interpolation=cv2.INTER_NEAREST)

        out_path = os.path.join(folder, filename)
        Image.fromarray(res).save(out_path, quality=95)
        print(f"Generated {out_path}")

print("All square update images generated successfully!")
