build: components lib
	@rm -rf dist
	@mkdir dist
	@coffee -b -o dist -c lib/*.coffee
	@component build --standalone soundcloud
	@mv build/build.js soundcloud.js
	@rm -rf build
	@node_modules/.bin/uglifyjs -nc --unsafe -mt -o soundcloud.min.js soundcloud.js
	@echo "File size (minified): " && cat soundcloud.min.js | wc -c
	@echo "File size (gzipped): " && cat soundcloud.min.js | gzip -9f  | wc -c
	@cp soundcloud.js ./examples
	
components: component.json
	@component install --dev

clean:
	rm -fr components