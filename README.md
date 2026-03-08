# Simple Widgets for Übersicht

A collection of simple, elegant widgets for the [Übersicht](https://github.com/felixhageloh/uebersicht) Mac desktop customization app.

## Included Widgets

* **Clock**: A simple digital clock with date.
* **System2**: Displays system information including OS version, Mac model, CPU, RAM, Disk usage, IP address, and Battery status.
* **Memory2**: Shows the top processes consuming memory in real-time.
* **Weather**: Displays the current weather and tomorrow's forecast for your accurate location.

## Installation

### 1. Install Übersicht
If you haven't already, download and install [Übersicht](http://tracesof.net/uebersicht/).

### 2. Add Widgets
You can add these widgets to your Übersicht setup by cloning or downloading this repository.

1. Clone the repository or download the ZIP file.
2. Open Übersicht and select **"Open Widgets Folder"** from the menu bar icon.
3. Move the `Simple_widgets` folder into the Übersicht widgets directory.

### 3. Weather Widget Setup
The Weather widget requires a couple of external command-line tools and a free API key to function.

#### Dependencies
Open your Terminal and install the required tools using [Homebrew](https://brew.sh/):
```bash
brew install corelocationcli
brew install jq
```

#### API Key
1. Sign up for a free API key at [OpenWeatherMap](https://openweathermap.org/api).
2. Open `Simple_widgets/weather-widget/get-weather.sh` in a text editor.
3. Replace the placeholder `API_KEY` value on line 4 with your real API key:
   ```bash
   API_KEY="your_api_key_here"
   ```

## Customization
You can easily customize the appearance of any widget by editing its `.coffee` or `.jsx` file. The styles are written in standard CSS/Stylus syntax inside the files.
