env:
	guix shell --pure --no-substitutes --rebuild-cache --manifest=guix.scm -- emacs -q
