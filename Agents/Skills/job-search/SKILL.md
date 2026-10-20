---
name: job-search
description: Searches public job boards for openings that match a resume and filters (salary, remote/hybrid/on-site, location). Use when the user asks to find jobs, job opportunities, openings, or to search a board. Which boards run is the table in boards.md, or boards.local.md when that file exists.
---

# Skill: Job search

**This machine:** After this file, read `user-config.md` in this folder when it exists. Additions extend the skill. Overrides replace the matching part on this machine only. Never commit that file. Copy [user-config.example.md](./user-config.example.md) to create it. Board on/off stays in `boards.local.md`, not in `user-config.md`.

**Job Finder** loads this skill. The parent agent must not run a job search itself. Collect **all** inputs below, then search. Do not invent openings.

**Never** commit a resume or result file to git. **Never** write resume contents (or SSN, address, phone) into `MEMORY.md`.

## 1. Collect inputs (stop until complete)

Ask, in this order, skipping any the user already answered:

1. **Resume** — Ask them to **attach** the file or give a filesystem path (PDF, DOCX, MD, TXT). Do not proceed without it. Parse into a short profile (do not dump the resume back):
   - Target titles / seniority
   - Skills, tools, stacks
   - Years of experience (if stated)
   - Industries
   - Locations already on the resume
2. **Result count** — Positive integer (how many openings to return). Default **10** if they decline to pick.
3. **Minimum salary** — Number + currency (assume **USD** if omitted). Annual unless they say hourly. Drop or deprioritize roles clearly below this; if pay is unlisted, keep the role but mark `salary: unknown`.
4. **Work mode** — Exactly one of: **in-office**, **hybrid**, **remote**.
5. **If in-office** — **City and state** (or city + country). Then **offer** (do not force): also list **10 large employers** in that area and search those career pages.

If any required field is missing, ask — do not search yet.

## 2. Search

Use web search and page fetch (public pages only). Do **not** log into sites, bypass paywalls, or scrape behind auth.

Query with profile titles + skills + mode + location + `salary` / `$min`. Prefer postings with an **apply URL**.

Boards come from one table. If `boards.local.md` exists in this folder, search **only** that file. Otherwise search [`boards.md`](./boards.md). Use each row whose **On** value is `yes`. Skip `no`. Use that row's **Site / query**. Do not add boards that are not in the active table. To make a personal list, copy [`boards.local.example.md`](./boards.local.example.md) to `boards.local.md`.

If a board returns nothing or blocks, record it under **Sources skipped** and continue. Do not fabricate listings from that board.

**In-office extra (if they accepted):** web-search 10 large employers in that city/state, then search `careers` / `jobs` / Greenhouse/Lever pages for roles matching the resume. Merge into the same ranked list.

Deduplicate by apply URL, then `(employer + title)`.

## 3. Rank (best → worst)

Score each opening 0–100 using the parsed resume:

| Signal | Weight |
|--------|--------|
| Title / seniority vs resume | 30 |
| Skills overlap | 30 |
| Work mode + location fit | 20 |
| Salary vs minimum (known ≥ min beats unknown beats below min) | 15 |
| Recency (if posted date known) | 5 |

Sort **descending**. Return the top **N** (their result count). Include a one-line **why** on each.

## 4. Present, then output, then follow-up

Each result **must** include:

- Job title
- Employer
- Work mode / location
- Salary if known, else `unknown`
- Short job description (5–8 lines from the posting, not invented)
- Apply link (URL)
- Source board
- Match score

Return that ranked list in the Job Report. Do not list output ids inside the report. The **parent** then follows [`options.md`](./options.md):

1. Offer `out-chat`, `out-md`, `out-xml`, `out-raw` unless this run already named an output id. Wait.
2. Deliver that output. **Job Finder** writes Desktop files from the matches already returned (not the parent, not the hub repo). Do not search the boards again for a save.
   - macOS: `~/Desktop/`
   - Windows: `%USERPROFILE%\Desktop\`
   - Filename: `job-matches-YYYY-MM-DD.<ext>` (append `-2` if it exists). Confirm the path after writing.
3. Offer **Yes** and **No**: follow-up work on these results? Wait.
4. **No:** stop.
5. **Yes:** offer one follow-up id from [`options.md`](./options.md). Wait.
6. Say the steps for that id, then do them.
7. When that follow-up finishes, go back to step 1.

If the host control fails and they do not answer the output question, use **`out-chat`**.

## 5. Privacy

- Do not echo full resume, SSN, or home address into chat or files on Desktop (results file = jobs only).
- Do not store the resume in the repo.
