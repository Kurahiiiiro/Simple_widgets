# command: "date +'{\"hour\":\"%H\", \"minute\":\"%M\", \"second\":\"%S\", \"day\":\"%A\", \"date_day\":\"%d\", \"month_name\":\"%B\"}'"
# update a widget every second, so the clock is live.
command: "date +'%H:%M:%S%n%A, %B %d'"

# the refresh frequency in milliseconds
refreshFrequency: 1000 # 1秒ごとに更新

# the CSS style for this widget, written using Stylus
# スタイルは自由に調整してください
style: """
  // ウィジェット全体のスタイル
  bottom: 20px         // 画面下からの位置
  left: 20px          // 画面右からの位置
  color: #fff          // 文字色（白）
  background-color: rgba(0, 0, 0, 0.3) // 背景色（半透明の黒）
  padding: 15px 25px   // 内側の余白
  border-radius: 10px  // 角の丸み
  font-family: "Helvetica Neue", -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, system-ui, sans-serif
  font-size: 28px      // フォントサイズ
  font-weight: 300     // フォントの太さ
  text-align: left    // 文字の左寄せ

  // 時刻部分のスタイル
  .time
    font-size: 72px
    font-weight: 100
    margin-bottom: 5px

  // 日付部分のスタイル
  .date
    font-size: 18px
    font-weight: 200
"""

# a widget can be configured to not render if it has no output
# render: (output) -> "#{output}"

# render gets the output of the command as a string.
# you can then manipulate the output or just display it as is.
# here we use jsx to style the output.
render: (output) ->
  # output は "HH:MM:SS\nDay, Month Date" の形式で渡されます
  # 例: "22:37:23\nSunday, May 11"
  parts = output.split('\n')
  time = parts[0]
  date = parts[1]

  return (
    """
    <div>
      <div class="time">#{time}</div>
      <div class="date">#{date}</div>
    </div>
    """
  )

# update is called when the shell command has executed.
# it is not needed in this widget.
# update: (output, domEl) ->
#  $(domEl).find('div').text output