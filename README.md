# ihateb portfolio

Next.js portfolio/blog inspired by the Raw House 404 page, with draggable ducks and simple file-based content.

## Publish a new post

1. Put your images in `public/images`.
2. Open `src/content/posts.ts`.
3. Copy one object from the `posts` array.
4. Change `slug`, `title`, `date`, `category`, `excerpt`, `shortStory`, `cover`, `gallery`, and `body`.
5. Visit `/blog/your-slug`.

Posts are sorted newest first by `date`. `shortStory` is the short text shown in the "Recent things I have done" section.

## Run locally

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000).
