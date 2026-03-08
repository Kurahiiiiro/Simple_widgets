command: "COLUMNS=1000 ps -axo pid,uid,%mem,args | sort -k3 -nr | head -n 11"

refreshFrequency: 10000  # 10秒ごとに更新

render: (output) ->
  return "<div class='container'>Loading...</div>" unless output
  
  lines = output.trim().split('\n').slice(1)  # ヘッダ行を除去
  
  items = lines.map (line) ->
    # フィールド順序: PID UID %MEM ARGS
    trimmedLine = line.trim()
    parts = trimmedLine.split(/\s+/, 3)  # 最初の3つのフィールドのみ分割
    return "" if parts.length < 3
    
    pid = parts[0]
    uid = parts[1]
    mem = parts[2]
    
    # 残りの部分がargs（プロセスのフルパス + 引数）
    argsStart = trimmedLine.indexOf(parts[2]) + parts[2].length
    args = trimmedLine.substring(argsStart).trim()
    
    # プロセス名を抽出・短縮
    processName = args
    if args.includes('/Applications/')
      # /Applications/AppName.app形式から抽出
      appMatch = args.match(/\/Applications\/([^\/]+)\.app/)
      if appMatch
        processName = appMatch[1]
    else if args.includes('/System/Library/')
      # システムプロセスは実行ファイル名のみ
      processName = args.split(/\s+/)[0].split('/').pop()
    else
      # その他の場合は最初の引数（実行ファイル）のベース名
      firstArg = args.split(/\s+/)[0]
      processName = firstArg.split('/').pop()
    
    # プロセス名が空の場合をチェック
    displayName = if processName then processName else "Unknown"
    memoryPercent = if mem then mem else "0.0"
    
    "<tr><td class='process-name' title='#{args}'>#{displayName}</td><td class='memory-usage'>#{memoryPercent}%</td></tr>"

  # 空の項目を除去
  validItems = items.filter (item) -> item.length > 0

  """
  <div class="container">
    <h2>Top Memory Processes</h2>
    <table>
      <thead>
        <tr>
          <th>Process</th>
          <th>Memory</th>
        </tr>
      </thead>
      <tbody>
        #{validItems.join('\n        ')}
      </tbody>
    </table>
  </div>
  """

style: """

  top: 300px;
  left: 20px;


  .container {
    font-family: "Helvetica Neue", -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, system-ui, sans-serif;
    background: rgba(0, 0, 0, 0.3);
    color: white;
    padding: 16px;
    border-radius: 12px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3);
    width: 320px;
    backdrop-filter: blur(10px);
    border: 1px solid rgba(255, 255, 255, 0.1);
  }

  h2 {
    margin: 0 0 12px 0;
    font-size: 16px;
    font-weight: 300;
    color: #ffffff;
    text-align: center;
  }

  table {
    width: 100%;
    border-collapse: collapse;
    font-size: 13px;
  }

  th {
    padding: 8px 12px;
    text-align: left;
    border-bottom: 2px solid rgba(255, 255, 255, 0.3);
    font-weight: 600;
    font-size: 12px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    color: #cccccc;
  }

  td {
    padding: 6px 12px;
    border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  }

  .process-name {
    font-weight: 200;
    max-width: 200px;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  .memory-usage {
    text-align: right;
    font-weight: 300;
    color: #ffffff;
    min-width: 60px;
  }

  tbody tr:hover {
    background: rgba(255, 255, 255, 0.1);
  }

  tbody tr:last-child td {
    border-bottom: none;
  }
"""