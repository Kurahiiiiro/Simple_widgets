# 情報を取得するためのコマンド
# 各情報は ":::DATA:::" という区切り文字で連結して出力されます
# $(df -h / | awk 'NR==2{print $5 " (" $3 "/" $2 ")"}'):::DATA:::\ は使わなくなったディスク情報

command: """
  echo "$(sw_vers -productVersion 2>/dev/null):::DATA:::\
$(system_profiler SPHardwareDataType 2>/dev/null | grep 'Model Name:' | awk -F': ' '{print $2}'):::DATA:::\
$(sysctl -n hw.model 2>/dev/null):::DATA:::\
$(sysctl -n machdep.cpu.brand_string 2>/dev/null):::DATA:::\
$(echo "$(($(sysctl -n hw.memsize 2>/dev/null) / 1024 / 1024 / 1024)) GB"):::DATA:::\
$(diskutil info / 2>/dev/null | awk -F': +' '/Total Space/ {print $2}' | cut -d' ' -f1,2):::DATA:::\
$(diskutil info / 2>/dev/null | awk -F': +' '/Free Space/ {print $2}' | cut -d' ' -f1,2):::DATA:::\
$(ipconfig getifaddr en0 || ipconfig getifaddr en1 || echo "N/A"):::DATA:::\
$(pmset -g batt | grep "InternalBattery" | awk '{gsub(";",""); print $3 "(" $4 ")"} END {if (NR == 0) print "N/A"}'):::DATA:::\
$(top -l 1 | awk '/CPU usage:/ {print $3 " User, " $5 " System, " $7 " Idle"; exit}')"
"""

# 更新頻度（ミリ秒単位）
# CPU使用率などを表示するため、やや短めの10秒に設定
refreshFrequency: 10000 # 10秒

# データを分割するための区切り文字
DELIMITER: ":::DATA:::"

# ウィジェットのHTMLとデータのレンダリング
render: (output) ->
  parts = output.trim().split(@DELIMITER).map (p) -> p.trim()

  # 期待通り10つのパーツが取得できたか確認
  if parts.length == 10
    os_version      = parts[0]
    model_name      = parts[1]
    model_id        = parts[2]
    processor       = parts[3]
    ram             = parts[4]
    disk_total      = parts[5]
    disk_free       = parts[6]
    local_ip        = parts[7]
    battery         = parts[8]
    cpu_usage       = parts[9]

    """
    <div class="system-info-widget">
      <div class="header">System Overview</div>
      <div class="info-row"><span class="label">OS Version:</span><span class="value">#{os_version}</span></div>
      <div class="info-row"><span class="label">Model:</span><span class="value">#{model_name} (#{model_id})</span></div>
      <div class="info-row"><span class="label">Processor:</span><span class="value">#{processor}</span></div>
      <div class="info-row"><span class="label">RAM:</span><span class="value">#{ram}</span></div>
      <div class="info-row"><span class="label">Storage:</span><span class="value">#{disk_free} Free / #{disk_total}</span></div>
      <div class="info-row"><span class="label">IP Address:</span><span class="value">#{local_ip}</span></div>
      <div class="info-row"><span class="label">Battery:</span><span class="value">#{battery}</span></div>
      <div class="info-row"><span class="label">CPU Usage:</span><span class="value">#{cpu_usage}</span></div>
    </div>
    """
  else
    # データ取得エラー時の表示
    """
    <div class="system-info-widget error">
      <p>Error fetching system data.</p>
      <p>Received: #{parts.length} parts (expected 10). Output: "#{output.trim()}"</p>
    </div>
    """

# ウィジェットのスタイル (CSS)
style: """
  top: 20px
  left: 20px
  color: #fff
  font-family: "Helvetica Neue", -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, system-ui, sans-serif
  font-size: 13px
  background-color: rgba(0, 0, 0, 0.4)
  padding: 15px
  border-radius: 12px
  width: 380px
  box-sizing: border-box
  backdrop-filter: blur(10px)
  border: 1px solid rgba(255, 255, 255, 0.1)
  text-shadow: 0 1px 2px rgba(0,0,0,0.5)

  .system-info-widget .header
    font-size: 11px
    text-transform: uppercase
    letter-spacing: 1px
    margin-bottom: 12px
    color: rgba(255, 255, 255, 0.5)
    font-weight: 500

  .system-info-widget .info-row
    display: flex
    justify-content: space-between
    margin-bottom: 6px
    align-items: baseline

  .system-info-widget .label
    color: rgba(255, 255, 255, 0.7)
    font-weight: 500
    flex-shrink: 0
    margin-right: 10px

  .system-info-widget .value
    text-align: right
    font-weight: 300
    word-break: break-all

  .system-info-widget.error
    color: #ff6666
    background-color: rgba(50, 0, 0, 0.6)
"""