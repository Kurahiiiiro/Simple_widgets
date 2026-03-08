# 情報を取得するためのコマンド
# 各情報は ":::DATA:::" という区切り文字で連結して出力されます
# $(df -h / | awk 'NR==2{print $5 " (" $3 "/" $2 ")"}'):::DATA:::\ は使わなくなったディスク情報

command: """
  echo "$(sw_vers -productVersion):::DATA:::\
$(system_profiler SPHardwareDataType | grep "Model Name:" | awk -F': ' '{print $2}'):::DATA:::\
$(sysctl -n hw.model):::DATA:::\
$(sysctl -n machdep.cpu.brand_string):::DATA:::\
$(echo "$(($(sysctl -n hw.memsize) / 1024 / 1024 / 1024)) GB"):::DATA:::\
$(diskutil info / | awk -F': +' '/Total Space/ {print $2}' | cut -d' ' -f1,2):::DATA:::\
$(diskutil info / | awk -F': +' '/Free Space/ {print $2}' | cut -d' ' -f1,2):::DATA:::\
$(ipconfig getifaddr en0 || ipconfig getifaddr en1 || echo "N/A"):::DATA:::\
$(pmset -g batt | awk '/InternalBattery/ {gsub(";",""); print $3 "(" $4 ")"; exit} END{if(NR==0)print "N/A"}'):::DATA:::\
$(top -l 1 | awk '/CPU usage:/ {print $3 " User, " $5 " System, " $7 " Idle"; exit}')"
"""

# 更新頻度（ミリ秒単位）
# CPU使用率などを表示するため、やや短めの10秒に設定
refreshFrequency: 10000 # 10秒

# データを分割するための区切り文字
DELIMITER: ":::DATA:::"

# ウィジェットのHTMLとデータのレンダリング
render: (output) ->
  parts = output.trim().split(@DELIMITER)

  # 期待通り9つのパーツが取得できたか確認
  if parts.length == 10
    os_version      = parts[0]
    model_name      = parts[1] # Macのモデル名 (例: MacBook Pro)
    model_id        = parts[2] # モデル識別子 (例: MacBookPro18,1)
    processor       = parts[3]
    ram             = parts[4]
    disk_total      = parts[5]
    disk_free       = parts[6]
    local_ip        = parts[7]
    battery         = parts[8]
    cpu_usage       = parts[9]

    """
    <div class="system-info-widget">
      <p class="label">System</p>
      <p><span class="label">OS Version:</span> #{os_version}</p>
      <p><span class="label">Model Name:</span> #{model_name}</p>
      <p><span class="label">Model Identifier:</span> #{model_id}</p>
      <p><span class="label">Processor:</span> #{processor}</p>
      <p><span class="label">RAM:</span> #{ram}</p>
      <p><span class="label">Macintosh HD:</span> #{disk_free} Free / #{disk_total} Total</p>
      <p><span class="label">IP Address:</span> #{local_ip}</p>
      <p><span class="label">Battery:</span> #{battery}</p>
      <p><span class="label">CPU Usage:</span> #{cpu_usage}</p>
    </div>
    """
  else
    # データ取得エラー時の表示
    """
    <div class="system-info-widget error">
      <p>Error fetching system data.</p>
      <p>Received: #{parts.length} parts (expected 9). Output: "#{output.trim()}"</p>
    </div>
    """

# ウィジェットのスタイル (CSS)
style: """
  // 右上に配置する例
  top: 20px
  left: 20px
  // 基本的なスタイル
  color: #fff
  font-family: "Helvetica Neue", sans-serif
  font-size: 14px
  background-color: rgba(0, 0, 0, 0.3) // 半透明の背景
  padding: 10px
  border-radius: 8px
  width: 400px // ウィジェットの幅を少し広げることも検討

  .system-info-widget p
    margin: 4px 0
    line-height: 1.4
    font-weight: 200
    word-wrap: break-word // プロセッサ名などが長い場合に対応

  .system-info-widget .label
    font-weight: 300
    min-width: 110px // ラベルの最小幅を調整 (Model Identifier のため)
    display: inline-block

  .system-info-widget.error
    color: #ff6666 // エラー時の文字色
"""