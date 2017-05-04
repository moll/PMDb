bin/pmdb.exe: lib/pmdb.exy
	cd lib && exerb pmdb.exy
	mkdir -p bin
	mv "$<" "$@"

lib/pmdb.exy: .FORCE
	cd lib && bundle exec mkexy -I. pmdb.rb

.PHONY: .FORCE
