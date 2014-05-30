.PHONY : TAGS

INCLUDES = lib \
	app/scripts

TAGS:
	find ${INCLUDES} -type f -iname '*.coffee' | xargs ctags

tags:TAGS

push:
	git push origin master
	git push gitlab master
