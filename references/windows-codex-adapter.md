# Windows + Codex Adapter

Use this reference whenever the research-paper-writing skill runs in Codex on Windows.

## Defaults

- Use PowerShell commands unless the user explicitly asks for Git Bash, WSL, or Linux.
- Prefer `python` over `python3` on Windows.
- Prefer `Copy-Item`, `Remove-Item`, `Get-ChildItem`, `Get-Content`, and `Select-String` over Unix shell utilities.
- Do not use `nohup`, `ps aux`, `tail`, `grep`, `find`, `xargs`, `cp -r`, or `rm -f` as Windows defaults.
- Avoid shell chains such as `cmd1 && cmd2 && cmd3`; run commands separately or use a PowerShell script block.
- For long-running experiments, use Codex PTY sessions when available. If the user needs unattended monitoring after the Codex session ends, suggest Windows Task Scheduler or a dedicated terminal session.

## Command Translation

| Unix/Hermes pattern | Windows/Codex default |
| --- | --- |
| `ls -la` | `Get-ChildItem -Force` |
| `find . -name "*.py" \| head -30` | `Get-ChildItem -Recurse -Filter *.py \| Select-Object -First 30` |
| `grep -r "pattern" --include="*.md"` | `Get-ChildItem -Recurse -Include *.md,*.txt -File \| Select-String -Pattern "pattern"` |
| `find . -name "*.bib"` | `Get-ChildItem -Recurse -Filter *.bib` |
| `tail -30 logs/run.log` | `Get-Content logs/run.log -Tail 30` |
| `cat file.json` | `Get-Content file.json` |
| `ps aux \| grep python` | `Get-Process python -ErrorAction SilentlyContinue` |
| `cp -r src dst` | `Copy-Item -Recurse -Force src dst` |
| `rm -f *.aux *.log` | `Remove-Item *.aux,*.log -Force -ErrorAction SilentlyContinue` |
| `python3 -c "..."` | `python -c "..."` |
| `nohup python run.py > log 2>&1 &` | Start a Codex PTY session, or use `Start-Process` with redirected output when the user needs a detached process. |

## Codex Tool Mapping

| Hermes term in original skill | Codex equivalent |
| --- | --- |
| `terminal(...)` | `functions.exec_command` with `shell: "powershell"` by default |
| `read_file` | `Get-Content` through `exec_command`, or normal file inspection |
| `write_file` / `patch` | `apply_patch` for manual edits |
| `execute_code` | `python` through `exec_command` |
| `delegate_task` | subagents only when the user explicitly asks for delegation or parallel agent work |
| `todo` | `functions.update_plan` for current-session task tracking |
| `memory` | Summarize decisions in final response or a project note; do not assume a memory tool exists |
| `cronjob` / `deliver:` | Not available by default in Codex. Use current-session polling, Windows Task Scheduler, or a user-managed terminal process. |
| `clarify` | Ask a concise user question in chat only when genuinely blocked |

## PowerShell Snippets

Explore a repository:

```powershell
Get-ChildItem -Force
Get-ChildItem -Recurse -Filter *.py | Select-Object -First 30
Get-ChildItem -Recurse -Include *.md,*.txt -File |
  Select-String -Pattern 'result|conclusion|finding' -List
```

Monitor an experiment:

```powershell
Get-Process python -ErrorAction SilentlyContinue
Get-Content .\logs\experiment_01.log -Tail 30
Get-ChildItem .\results
```

Commit completed results without a shell chain:

```powershell
git add -A
git commit -m "Add <experiment name>: <key finding in 1 line>"
git push
```

Clean and compile LaTeX:

```powershell
Remove-Item *.aux,*.bbl,*.blg,*.log,*.out,*.toc,*.fls,*.fdb_latexmk -Force -ErrorAction SilentlyContinue
latexmk -pdf main.tex
Get-Item .\main.pdf
```

Start a detached experiment only when needed:

```powershell
New-Item -ItemType Directory -Force logs | Out-Null
Start-Process -WindowStyle Hidden -FilePath python -ArgumentList 'run_experiment.py --config config.yaml' -RedirectStandardOutput logs\experiment_01.log -RedirectStandardError logs\experiment_01.err -PassThru
```

Prefer an interactive Codex PTY session over detached `Start-Process` when the user wants live monitoring and the process can stay attached to the current session.
