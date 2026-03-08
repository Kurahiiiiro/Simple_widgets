#!/bin/bash

# APIキー設定
API_KEY="a55e14b710006b0a219f003b63d976e2"  # OWM API Key

# ツールのパスを探索する関数（UbersichtはユーザーのPATHを引き継がないため明示的に探す）
find_tool() {
  local tool=$1
  if command -v "$tool" >/dev/null 2>&1; then
    command -v "$tool"
  elif [ -x "/opt/homebrew/bin/$tool" ]; then
    echo "/opt/homebrew/bin/$tool"
  elif [ -x "/usr/local/bin/$tool" ]; then
    echo "/usr/local/bin/$tool"
  else
    echo ""
  fi
}

CORE_LOCATION=$(find_tool "CoreLocationCLI")
JQ=$(find_tool "jq")

if [ -z "$CORE_LOCATION" ]; then
  # ウィジェット側にエラーをJSONで伝える
  echo '{"error": "CoreLocationCLI not found. Please brew install corelocationcli"}'
  exit 0
fi

if [ -z "$JQ" ]; then
  echo '{"error": "jq not found. Please brew install jq"}'
  exit 0
fi

# 緯度経度の取得
LOC=$($CORE_LOCATION -format "%latitude %longitude" 2>/dev/null)
LAT=$(echo $LOC | awk '{print $1}' | tr -d '[:space:]')
LON=$(echo $LOC | awk '{print $2}' | tr -d '[:space:]')

# 1. CoreLocationCLI が失敗した場合、IPベースで取得を試みる
if [[ ! "$LAT" =~ ^-?[0-9.]+ ]] || [[ ! "$LON" =~ ^-?[0-9.]+ ]]; then
  IP_LOC=$(curl -s "http://ip-api.com/json")
  LAT=$(echo "$IP_LOC" | $JQ -r '.lat // empty')
  LON=$(echo "$IP_LOC" | $JQ -r '.lon // empty')
fi

# 2. それでも失敗した場合の最終フォールバック（東京）
if [[ ! "$LAT" =~ ^-?[0-9.]+ ]] || [[ ! "$LON" =~ ^-?[0-9.]+ ]]; then
  LAT="35.6895"
  LON="139.6917"
fi

# 今日の日付
TODAY=$(date "+%Y-%m-%d")
TOMORROW=$(date -v+1d "+%Y-%m-%d")

# 現在の天気
CURRENT=$(curl -s "https://api.openweathermap.org/data/2.5/weather?lat=$LAT&lon=$LON&appid=$API_KEY&units=metric&lang=en")

# 取得失敗チェック
if echo "$CURRENT" | $JQ -e '.cod != 200' >/dev/null 2>&1; then
  ERR_MSG=$(echo "$CURRENT" | $JQ -r '.message // "API Error"')
  echo "{\"error\": \"Weather API Error: $ERR_MSG\"}"
  exit 0
fi

# 明日の天気（3時間刻み）
FORECAST=$(curl -s "https://api.openweathermap.org/data/2.5/forecast?lat=$LAT&lon=$LON&appid=$API_KEY&units=metric&lang=en")

# 取得失敗チェック
if echo "$FORECAST" | $JQ -e '.cod != "200"' >/dev/null 2>&1; then
  echo '{"error": "Forecast API Error"}'
  exit 0
fi

# 場所名の取得（OpenStreetMapのNominatim）
# Nominatimは失敗しやすいため、失敗時はOpenWeatherMapのデータから取得
LOCATION_NAME=$(curl -s "https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$LAT&lon=$LON&accept-language=en" | $JQ -r '.address.city // .address.town // .address.village // .address.state // empty')
if [ -z "$LOCATION_NAME" ] || [ "$LOCATION_NAME" = "null" ]; then
  LOCATION_NAME=$(echo "$CURRENT" | $JQ -r '.name // "Unknown Location"')
fi

# 今日の天気情報
TODAY_WEATHER=$(echo "$CURRENT" | $JQ -r '.weather[0].description // "N/A"')
TODAY_ICON=$(echo "$CURRENT" | $JQ -r '.weather[0].icon // "01d"')
TODAY_MIN=$(echo "$FORECAST" | $JQ --arg date "$TODAY" --argjson cur "$(echo "$CURRENT" | $JQ '.main.temp_min')" -r '([.list[] | select(.dt_txt | startswith($date)) | .main.temp_min] + [$cur] | min // 0) | floor')
TODAY_MAX=$(echo "$FORECAST" | $JQ --arg date "$TODAY" --argjson cur "$(echo "$CURRENT" | $JQ '.main.temp_max')" -r '([.list[] | select(.dt_txt | startswith($date)) | .main.temp_max] + [$cur] | max // 0) | floor')

# 明日の天気（アイコンと天気は12時のものを使用し、気温は1日の最低・最高を計算）
TOMORROW_DATA=$(echo "$FORECAST" | $JQ --arg time "$TOMORROW 12:00:00" -r '.list[] | select(.dt_txt == $time)' | $JQ -s '.[0] // empty')
if [ -z "$TOMORROW_DATA" ]; then
  TOMORROW_WEATHER="N/A"
  TOMORROW_ICON="01d"
else
  TOMORROW_WEATHER=$(echo "$TOMORROW_DATA" | $JQ -r '.weather[0].description // "N/A"')
  TOMORROW_ICON=$(echo "$TOMORROW_DATA" | $JQ -r '.weather[0].icon // "01d"')
fi
TOMORROW_MIN=$(echo "$FORECAST" | $JQ --arg date "$TOMORROW" -r '([.list[] | select(.dt_txt | startswith($date)) | .main.temp_min] | min // 0) | floor')
TOMORROW_MAX=$(echo "$FORECAST" | $JQ --arg date "$TOMORROW" -r '([.list[] | select(.dt_txt | startswith($date)) | .main.temp_max] | max // 0) | floor')

# JSONで出力
$JQ -n \
  --arg location "$LOCATION_NAME" \
  --arg today "$TODAY" \
  --arg today_weather "$TODAY_WEATHER" \
  --arg today_icon "https://openweathermap.org/img/wn/${TODAY_ICON}@2x.png" \
  --argjson today_min "${TODAY_MIN:-0}" \
  --argjson today_max "${TODAY_MAX:-0}" \
  --arg tomorrow "$TOMORROW" \
  --arg tomorrow_weather "$TOMORROW_WEATHER" \
  --arg tomorrow_icon "https://openweathermap.org/img/wn/${TOMORROW_ICON}@2x.png" \
  --argjson tomorrow_min "${TOMORROW_MIN:-0}" \
  --argjson tomorrow_max "${TOMORROW_MAX:-0}" \
  '{
    location: $location,
    today: {
      date: $today,
      weather: $today_weather,
      icon: $today_icon,
      temp_min: $today_min,
      temp_max: $today_max
    },
    tomorrow: {
      date: $tomorrow,
      weather: $tomorrow_weather,
      icon: $tomorrow_icon,
      temp_min: $tomorrow_min,
      temp_max: $tomorrow_max
    }
  }'
