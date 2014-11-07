Planit
======

GETTING STARTED FROM GITHUB

Go to Terminal
Go to planit directory (`code planit`)
Pull code (`gp` -- "git pull")
If there's a fast-fowards error, stash your changes and lay them on top:
  - `ga .`
  - `gss` ("git stash save") -- saves your staged changes and sets them aside
  - `gp` ("git pull")
  - `gsp` ("git stach pop") -- "pops" the top layer of set-aside changes onto your history

PUSHING TO GITHUB

Go to Terminal
Go to planit directory (`code planit`)
Check file changes (`gs` -- "git status")
Add ("stage") ALL changes (`ga .` -- "git add .") -- the . means the present directory
  - `ga -u .` as well, if you want to add deleted files
Commit files (`gc -m "Comment about changes"` -- `git commit`)

OTHER GH COMMANDS

`gl` -- Git Log (previous commits)
`gd` -- Git diff (see tracked but unstaged changes)
`gds` -- Git diff --staged (see staged changes)