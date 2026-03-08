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
LOC=$($CORE_LOCATION -format "%latitude %longitude")
LAT=$(echo $LOC | awk '{print $1}')
LON=$(echo $LOC | awk '{print $2}')

# 今日の日付
TODAY=$(date "+%Y-%m-%d")
TOMORROW=$(date -v+1d "+%Y-%m-%d")

# 現在の天気
CURRENT=$(curl -s "https://api.openweathermap.org/data/2.5/weather?lat=$LAT&lon=$LON&appid=$API_KEY&units=metric&lang=en")

# 明日12時の天気（3時間刻み）
FORECAST=$(curl -s "https://api.openweathermap.org/data/2.5/forecast?lat=$LAT&lon=$LON&appid=$API_KEY&units=metric&lang=en")

# 場所名の取得（OpenStreetMapのNominatim）
LOCATION_NAME=$(curl -s "https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$LAT&lon=$LON&accept-language=en" | $JQ -r '.address.city // .address.town // .address.village // .address.state // "Unknown Location"')

# 今日の天気情報
TODAY_WEATHER=$(echo "$CURRENT" | $JQ -r '.weather[0].description')
TODAY_ICON=$(echo "$CURRENT" | $JQ -r '.weather[0].icon')
TODAY_MIN=$(echo "$FORECAST" | $JQ --arg date "$TODAY" --argjson cur "$(echo "$CURRENT" | $JQ '.main.temp_min')" -r '[.list[] | select(.dt_txt | startswith($date)) | .main.temp_min] + [$cur] | min | floor')
TODAY_MAX=$(echo "$FORECAST" | $JQ --arg date "$TODAY" --argjson cur "$(echo "$CURRENT" | $JQ '.main.temp_max')" -r '[.list[] | select(.dt_txt | startswith($date)) | .main.temp_max] + [$cur] | max | floor')

# 明日の天気（アイコンと天気は12時のものを使用し、気温は1日の最低・最高を計算）
TOMORROW_DATA=$(echo "$FORECAST" | $JQ --arg time "$TOMORROW 12:00:00" -r '.list[] | select(.dt_txt == $time)' | $JQ -s '.[0]')
TOMORROW_WEATHER=$(echo "$TOMORROW_DATA" | $JQ -r '.weather[0].description')
TOMORROW_ICON=$(echo "$TOMORROW_DATA" | $JQ -r '.weather[0].icon')
TOMORROW_MIN=$(echo "$FORECAST" | $JQ --arg date "$TOMORROW" -r '[.list[] | select(.dt_txt | startswith($date)) | .main.temp_min] | min | floor')
TOMORROW_MAX=$(echo "$FORECAST" | $JQ --arg date "$TOMORROW" -r '[.list[] | select(.dt_txt | startswith($date)) | .main.temp_max] | max | floor')

# JSONで出力
echo $(
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
)
