# Test and dist helpers

# make test             Runs the test suite
# make t/simple.vim     Runs the test "t/simple.vim"
# make dist             Creates the zip archive for distribution on vim.org
# make clean            Removes the zip archive

VSPEC   = ~/.vim/bundle/vspec/bin/vspec
RTPDIRS = ~/.vim/bundle/vspec \
          ~/.vim/bundle/textobj-user \
          ~/.vim/bundle/textobj-comment

FILES = plugin/textobj/comment.vim autoload/textobj/comment.vim \
        doc/textobj-comment.txt
TESTS = $(wildcard t/*.vim)

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

clean:
	-rm -f textobj-comment.zip

.PHONY: test $(TESTS) dist clean
