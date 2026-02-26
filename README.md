# merge_env

What it does:
🔍 Scans all subfolders (up to 3 levels deep) for .env files across all your projects — autodukan-v2, basira-news-deepseek-v3, footmania-platform, etc.
💾 Backs up your existing /home/kali/.env with a timestamp before touching anything
✅ Adds new KEY=VALUE pairs with a comment showing which project they came from
⏭️ Skips duplicates — if a key already exists in master, it won't be overwritten
📋 Summary at the end showing how many keys were added vs skipped
