.PHONY : TAGS

INCLUDES = server \
	client/static/scripts

TAGS:
	find ${INCLUDES} -type f -iname '*.coffee' | xargs ctags

tags:TAGS
