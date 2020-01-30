#!/bin/bash
### usage ./convert.sh game
## where game is baseName of the export
 
if [ ! "$1" ]; then
    read -p 'Game name: ' game
else
    game="$1"
fi

echo "gzipping wasm and pck files"

gzip -f "$game.wasm"
gzip -f "$game.pck"

f="$game.html"
if [ -f $f -a -r $f ]; then
f="$f"
else
f="index.html"
fi

if [[ "$OSTYPE" = *"linux"* ]]; then
SED="sed -i\"\""
else
SED="sed -i \"\""
fi

echo "placing paco inside $f..."
$SED -e "s@$find@$replace@" "$f"

echo "modifying $game.js to load gziped files..."
find="function loadXHR(resolve, reject, file, tracker) {"
replace=$(cat <<\EOF
    function loadXHR(resolve, reject, file, tracker) {  if (file.substr(-5) === '.wasm' || file.substr(-4) === '.pck') { file += '.gz'; var resolve_orig = resolve; resolve = function(xhr) { return resolve_orig(xhr.responseURL.substr(-3) === '.gz' ? { response: pako.inflate(xhr.response),    responseType: xhr.responseType, responseURL: xhr.responseURL, status: xhr.status,   statusText: xhr.statusText } : xhr); }; }
EOF
)

$SED -e "s@$find@$replace@" "$game.js"