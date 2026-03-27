#!/usr/bin/env python3
import os
import subprocess
import sys

# Configuration
WORK_DIR = "/Users/suchuanlei/.openclaw/workspace/slide-deck/karpathy-loopy-era"
SKILL_DIR = "/Users/suchuanlei/.openclaw/workspace/skills/baoyu-image-gen"
PROMPT_DIR = os.path.join(WORK_DIR, "prompts")

# Explicit config from ppt-afp experience
GOOGLE_BASE_URL = "https://work.poloapi.com/"
MODEL = "gemini-3.1-flash-image-preview"

# Get list of prompt files
prompt_files = sorted([f for f in os.listdir(PROMPT_DIR) if f.endswith(".md")])
total = len(prompt_files)
print(f"Found {total} prompt files")

# Generate each slide
success_count = 0
failed_count = 0

for i, prompt_file in enumerate(prompt_files, start=1):
    prompt_path = os.path.join(PROMPT_DIR, prompt_file)
    image_file = prompt_file.replace(".md", ".png")
    image_path = os.path.join(WORK_DIR, image_file)

    print(f"\nGenerating slide {i}/{total}: {image_file}")

    # Build command
    cmd = [
        "npx", "-y", "bun",
        f"{SKILL_DIR}/scripts/main.ts",
        "--promptfiles", prompt_path,
        "--image", image_path,
        "--provider", "google",
        "--model", MODEL,
        "--ar", "16:9",
        "--quality", "2k"
    ]

    # Set environment variables
    env = os.environ.copy()
    env["GOOGLE_BASE_URL"] = GOOGLE_BASE_URL
    env["NODE_TLS_REJECT_UNAUTHORIZED"] = "0"

    # Run
    try:
        result = subprocess.run(
            cmd,
            cwd=WORK_DIR,
            env=env,
            check=True,
            capture_output=True,
            text=True
        )
        print(f"✅ Slide {i}/{total} done")
        success_count += 1
    except subprocess.CalledProcessError as e:
        print(f"❌ Slide {i}/{total} failed")
        print(f"STDOUT: {e.stdout}")
        print(f"STDERR: {e.stderr}")
        failed_count += 1

    # Report progress every 3 slides
    if i % 3 == 0:
        print(f"\n📊 Progress: {i}/{total} done ({success_count} succeeded, {failed_count} failed)")

# Final summary
print(f"\n🎉 Generation complete!")
print(f"Success: {success_count}/{total}")
print(f"Failed: {failed_count}/{total}")

if failed_count > 0:
    sys.exit(1)
