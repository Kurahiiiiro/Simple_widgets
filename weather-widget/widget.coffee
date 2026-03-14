command: "bash Simple_widgets/weather-widget/get-weather.sh"

refreshFrequency: 60 * 60 * 1000  # 毎時更新

style: """
.weather-widget {
  position: fixed;
  bottom: 180px;
  left: 20px;
  font-family: "Helvetica Neue", -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, system-ui, sans-serif;
  font-size: 14px;
  font-weight: 300;
  color: white;
  background: rgba(0,0,0,0.3);
  border-radius: 8px;
  padding: 10px;
}

.weather-widget table {
  width: 100%;
  border-collapse: collapse;
}

.weather-widget td, .weather-widget th {
  padding: 4px 8px;
}

.city-name {
  font-size: 16pt;
  font-weight: 500;
  text-align: center;
}

.today {
  font-size: 14pt;
  font-weight: 300;
  text-align: center;
  width: 50%;
}

.tomorrow {
  font-size: 14pt;
  font-weight: 300;
  text-align: center;
  border-left: 1px solid white;
  width: 50%;
}

.weather-text {
  font-size: 12pt;
  font-weight: 200;
}

.temp_today {
  font-size: 12pt;
  font-weight: 200;
  text-align: center;
}

.temp_tomorrow {
  font-size: 12pt;
  font-weight: 200;
  text-align: center;
  border-left: 1px solid white;
}

.error-msg {
  color: #ffcccc;
  font-size: 13pt;
  text-align: center;
  padding: 10px;
}
"""

render: (output) ->
  try
    cleanedOutput = output.trim()
    data = JSON.parse(cleanedOutput)

    if data.error
      return """
        <div class="weather-widget">
          <div class="error-msg">#{data.error}</div>
        </div>
      """

    """
    <div class="weather-widget">
      <table>
        <tr>
          <th colspan="4" class="city-name">#{data.location}</th>
        </tr>
        <tr>
          <td colspan="2" class="today">Today</td>
          <td colspan="2" class="tomorrow">Tomorrow</td>
        </tr>
        <tr>
          <td><img src="#{data.today.icon}" style="height: 32px;" /></td>
          <td class="weather-text">#{data.today.weather}</td>
          <td style="border-left: 1px solid white;"><img src="#{data.tomorrow.icon}" style="height: 32px;" /></td>
          <td class="weather-text">#{data.tomorrow.weather}</td>
        </tr>
        <tr>
          <td colspan="2" class="temp_today"><span style="color: #ffaa99;">H #{data.today.temp_max}°</span> / <span style="color: #99ccff;">L #{data.today.temp_min}°</span></td>
          <td colspan="2" class="temp_tomorrow"><span style="color: #ffaa99;">H #{data.tomorrow.temp_max}°</span> / <span style="color: #99ccff;">L #{data.tomorrow.temp_min}°</span></td>
        </tr>
      </table>
    </div>
    """
  catch error
    "<div class='weather-widget'><div class='error-msg'>データ取得エラー</div></div>"
