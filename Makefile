# Test and dist helpers

# make test             Runs the test suite
# make t/simple.vim     Runs the test "t/simple.vim"
# make dist             Creates the zip archive for distribution on vim.org
# make vimball          Creates a Vimball archive
# make clean            Removes all archives

VSPEC   = ~/.vim/bundle/vspec/bin/vspec
RTPDIRS = ~/.vim/bundle/{vspec,textobj-user,textobj-comment}

FILES = plugin/textobj/comment.vim autoload/textobj/comment.vim \
        doc/textobj-comment.txt
TESTS = t/plugin.vim t/leaders.vim t/simple.vim t/paired.vim t/inline.vim

test:
	@for t in $(TESTS); do \
	    echo "$${t}"; \
	    $(VSPEC) $(RTPDIRS) "$${t}"; \
	done

$(TESTS):
	$(VSPEC) $(RTPDIRS) $@

dist: textobj-comment.zip
textobj-comment.zip: $(FILES)
	zip -r textobj-comment $(FILES)

VMBDEPS = $(shell if [ -f textobj-comment.vba ]; \
		  then echo textobj-comment.vba; \
		  else echo textobj-comment.vmb; fi)
vimball: $(VMBDEPS)
textobj-comment.vmb textobj-comment.vba: $(FILES)
	@cat <(for f in $(FILES); do echo "$${f}"; done) \
		| vim -c 'silent exe "%MkVimball! textobj-comment ." | q!' -

clean:
	-rm -f textobj-comment.zip
	-rm -f textobj-comment.{vmb,vba}*

SHELL = /bin/bash
.PHONY: test $(TESTS) dist vimball clean
