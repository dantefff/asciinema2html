#!/bin/bash

if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    echo "Uso: $0 <file.cast> [speed=1.0]"
    exit 1
fi

CAST_FILE="$1"
SPEED="${2:-1.0}"
HTML_FILE="${CAST_FILE%.cast}.html"
IDLE_LIMIT=2

if [ ! -f "$CAST_FILE" ]; then
    echo "Error: $CAST_FILE not found."
    exit 1
fi

HEADER=$(head -n1 "$CAST_FILE")
COLS=$(echo "$HEADER" | grep -o '"width":[^,}]*' | cut -d: -f2 | tr -d '[:space:]')
ROWS=$(echo "$HEADER" | grep -o '"height":[^,}]*' | cut -d: -f2 | tr -d '[:space:]')

BASE64_CONTENT=$(base64 -w 0 "$CAST_FILE")
SRC="data:text/plain;base64,$BASE64_CONTENT"

cat > "$HTML_FILE" << EOF
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Reproducción de $(basename "$CAST_FILE") - ${COLS}x${ROWS}, Speed: ${SPEED}x</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/asciinema-player@3/dist/bundle/asciinema-player.min.css">
</head>
<body>
  <div id="player"></div>
  <script src="https://cdn.jsdelivr.net/npm/asciinema-player@3/dist/bundle/asciinema-player.min.js"></script>
  <script>
    AsciinemaPlayer.create('$SRC', document.getElementById('player'), {
      cols: $COLS,
      rows: $ROWS,
      autoplay: true,
      loop: false,
      idleTimeLimit: $IDLE_LIMIT,
      speed: $SPEED,
      controls: true
    });
  </script>
</body>
</html>
EOF

echo "Generated HTML portable at: $HTML_FILE"
