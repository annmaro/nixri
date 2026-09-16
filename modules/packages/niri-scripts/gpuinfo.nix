{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "gpuinfo";

  # Nix securely packages and injects these dependencies into the script PATH
  runtimeInputs = with pkgs; [
    coreutils    # Provides cut, ls, readlink, head, basename, tr, sort
    gnugrep      # Provides grep
    gawk         # Provides awk
    pciutils     # Provides lspci
    kmod         # Provides lsmod
    gnused       # Provides sed
    lm_sensors   # Provides sensors
    jq           # Provides jq
  ];

  text = ''
    # Pre-declare variables to comply with ShellCheck and strict mode (set -u)
    gpuinfo_file="/tmp/$UID-gpuinfo"
    AQ_DRM_DEVICES="''${AQ_DRM_DEVICES:-WLR_DRM_DEVICES}"
    tired=false
    GPUINFO_EMOJI=0
    GPUINFO_NVIDIA_ENABLE=0
    GPUINFO_AMD_ENABLE=0
    GPUINFO_INTEL_ENABLE=0
    GPUINFO_PREV_STAT=""
    GPUINFO_PREV_IDLE=""
    GPUINFO_PRIORITY=""
    NEXT_PRIORITY=""
    NVIDIA_ADDR=""
    AMD_ADDR=""
    INTEL_ADDR=""
    primary_gpu=""
    utilization=""
    temperature=""
    current_clock_speed=""
    max_clock_speed=""
    core_clock=""
    power_usage=""
    power_limit=""
    power_discharge=""
    fan_speed=""

    # Handle tired flag
    if [[ " $* " =~ " --tired " ]]; then
      if [ -f "$gpuinfo_file" ] && ! grep -q "tired" "$gpuinfo_file"; then
        echo "tired=true" >> "$gpuinfo_file"
        echo "set tired flag"
      else
        echo "already set tired flag"
      fi
      echo "Nvidia GPU will not be queried if it is in suspend mode"
      echo "run --reset to reset the flag"
      exit 0
    fi

    # Handle emoji flag
    if [[ " $* " =~ " --emoji " ]]; then
      if [ -f "$gpuinfo_file" ] && ! grep -q "GPUINFO_EMOJI" "$gpuinfo_file"; then
        echo "export GPUINFO_EMOJI=1" >> "$gpuinfo_file"
        echo "set emoji flag"
      else
        echo "already set emoji flag"
      fi
      echo "run --reset to reset the flag"
      exit 0
    fi

    if [[ ! " $* " =~ " --startup " ]]; then
      gpuinfo_file="''${gpuinfo_file}''${2:-}"
    fi

    detect() {
      local card
      card=$(echo "$AQ_DRM_DEVICES" | cut -d':' -f1 | cut -d'/' -f4)
      
      # FIXED: Replaced ls | grep (SC2010) with a safe loop checking symlink targets
      local slot_number=""
      for link in /dev/dri/by-path/*-card; do
        if [ -L "$link" ]; then
          local target
          target=$(readlink -f "$link")
          if [[ "$target" == *"$card" ]]; then
            local filename
            filename=$(basename "$link")
            local temp
            temp="''${filename#pci-0000:}"
            slot_number="''${temp%-card}"
            break
          fi
        fi
      done

      local vendor_id
      vendor_id=$(lspci -nn -s "$slot_number")
      declare -A vendors=(["10de"]="nvidia" ["8086"]="intel" ["1002"]="amd")
      local initGPU=""
      for vendor in "''${!vendors[@]}"; do
        if [[ "$vendor_id" == *"$vendor"* ]]; then
          initGPU="''${vendors[$vendor]}"
          break
        fi
      done
      if [[ -n "$initGPU" ]]; then
        "$0" --use "$initGPU" --startup
      fi
    }

    query() {
      GPUINFO_NVIDIA_ENABLE=0 
      GPUINFO_AMD_ENABLE=0 
      GPUINFO_INTEL_ENABLE=0
      touch "$gpuinfo_file"

      if lsmod | grep -q 'nouveau'; then
        echo "GPUINFO_NVIDIA_GPU=\"Linux\"" >> "$gpuinfo_file"
        echo "GPUINFO_NVIDIA_ENABLE=1 # Using nouveau an open-source nvidia driver" >> "$gpuinfo_file"
      elif command -v nvidia-smi >/dev/null 2>&1; then
        local GPUINFO_NVIDIA_GPU
        GPUINFO_NVIDIA_GPU=$(nvidia-smi --query-gpu=gpu_name --format=csv,noheader,nounits | head -n 1)
        if [[ -n "$GPUINFO_NVIDIA_GPU" ]]; then
          if [[ "$GPUINFO_NVIDIA_GPU" == *"NVIDIA-SMI has failed"* ]]; then
            echo "GPUINFO_NVIDIA_ENABLE=0 # NVIDIA-SMI has failed" >> "$gpuinfo_file"
          else
            local nv_gpu_clean
            nv_gpu_clean="''${GPUINFO_NVIDIA_GPU/NVIDIA /}"
            NVIDIA_ADDR=$(lspci | grep -Ei "VGA|3D" | grep -i "$nv_gpu_clean" | cut -d' ' -f1)
            {
              echo "NVIDIA_ADDR=\"$NVIDIA_ADDR\""
              echo "GPUINFO_NVIDIA_GPU=\"$nv_gpu_clean\""
              echo "GPUINFO_NVIDIA_ENABLE=1"
            } >> "$gpuinfo_file"
          fi
        fi
      fi

      if lspci -nn | grep -E "(VGA|3D)" | grep -iq "1002"; then
        local GPUINFO_AMD_GPU
        GPUINFO_AMD_GPU="$(lspci -nn | grep -Ei "VGA|3D" | grep -m 1 "1002" | awk -F'Advanced Micro Devices, Inc. ' '{gsub(/ *\[[^\]]*\]/,""); gsub(/ *\([^)]*\)/,""); print $2}')"
        AMD_ADDR=$(lspci | grep -Ei "VGA|3D" | grep -i "$GPUINFO_AMD_GPU" | cut -d' ' -f1)
        {
          echo "AMD_ADDR=\"$AMD_ADDR\""
          echo "GPUINFO_AMD_ENABLE=1"
          echo "GPUINFO_AMD_GPU=\"$GPUINFO_AMD_GPU\""
        } >> "$gpuinfo_file"
      fi

      if lspci -nn | grep -E "(VGA|3D)" | grep -iq "8086"; then
        local GPUINFO_INTEL_GPU
        GPUINFO_INTEL_GPU="$(lspci -nn | grep -Ei "VGA|3D" | grep -m 1 "8086" | awk -F'Intel Corporation ' '{gsub(/ *\[[^\]]*\]/,""); gsub(/ *\([^)]*\)/,""); print $2}')"
        INTEL_ADDR=$(lspci | grep -Ei "VGA|3D" | grep -i "$GPUINFO_INTEL_GPU" | cut -d' ' -f1)
        {
          echo "INTEL_ADDR=\"$INTEL_ADDR\""
          echo "GPUINFO_INTEL_ENABLE=1"
          echo "GPUINFO_INTEL_GPU=\"$GPUINFO_INTEL_GPU\""
        } >> "$gpuinfo_file"
      fi

      if ! grep -q "GPUINFO_PRIORITY=" "$gpuinfo_file" && [[ -n "$AQ_DRM_DEVICES" ]]; then
        trap detect EXIT
      fi
    }

    toggle() {
      if [[ -n "''${1:-}" ]]; then
        NEXT_PRIORITY="GPUINFO_''${1^^}_ENABLE"
        if ! grep -q "''${NEXT_PRIORITY}=1" "$gpuinfo_file"; then
          echo "Error: ''${NEXT_PRIORITY} not found in $gpuinfo_file"
        fi
      else
        if ! grep -q "GPUINFO_AVAILABLE=" "$gpuinfo_file"; then
          local GPUINFO_AVAILABLE
          GPUINFO_AVAILABLE=$(grep "_ENABLE=1" "$gpuinfo_file" | cut -d '=' -f 1 | tr '\n' ' ' | tr -d '#')
          echo "" >> "$gpuinfo_file"
          echo "GPUINFO_AVAILABLE=\"''${GPUINFO_AVAILABLE[*]}\"" >> "$gpuinfo_file"
        fi

        if ! grep -q "GPUINFO_PRIORITY=" "$gpuinfo_file"; then
          local GPUINFO_AVAILABLE_VAL
          GPUINFO_AVAILABLE_VAL=$(grep "GPUINFO_AVAILABLE=" "$gpuinfo_file" | cut -d'=' -f 2)
          local initGPU
          initGPU=$(echo "$GPUINFO_AVAILABLE_VAL" | cut -d ' ' -f 1)
          echo "GPUINFO_PRIORITY=''${initGPU}" >> "$gpuinfo_file"
        fi
        
        mapfile -t anchor < <(grep "_ENABLE=1" "$gpuinfo_file" | cut -d '=' -f 1)
        GPUINFO_PRIORITY=$(grep "GPUINFO_PRIORITY=" "$gpuinfo_file" | cut -d'=' -f 2)
        local current_index=0
        for index in "''${!anchor[@]}"; do
          if [[ "''${anchor[$index]}" = "$GPUINFO_PRIORITY" ]]; then
            current_index="$index"
          fi
        done
        local next_index
        next_index=$(((current_index + 1) % ''${#anchor[@]}))
        local raw_next
        raw_next="''${anchor[$next_index]}"
        NEXT_PRIORITY="''${raw_next#\#}"
      fi

      sed -i 's/^\(GPUINFO_NVIDIA_ENABLE=1\|GPUINFO_AMD_ENABLE=1\|GPUINFO_INTEL_ENABLE=1\)/#\1/' "$gpuinfo_file"
      sed -i "s/^#$NEXT_PRIORITY/$NEXT_PRIORITY/" "$gpuinfo_file"
      sed -i "s/GPUINFO_PRIORITY=$GPUINFO_PRIORITY/GPUINFO_PRIORITY=$NEXT_PRIORITY/" "$gpuinfo_file"
    }

    map_floor() {
      local pairs_str="$1"
      local value_to_check="$2"
      local def_val=""
      
      IFS=', ' read -r -a pairs <<< "$pairs_str"
      if [[ ''${pairs[-1]} != *":"* ]]; then
        def_val="''${pairs[-1]}"
        unset "pairs[''${#pairs[@]}-1]"
      fi
      for pair in "''${pairs[@]}"; do
        IFS=':' read -r key value <<< "$pair"
        local num="''${value_to_check%%.*}"
        if [[ "$num" =~ ^-?[0-9]+$ && "$key" =~ ^-?[0-9]+$ ]]; then
          if ((num > key)); then
            echo "$value"
            return
          fi
        elif [[ -n "$num" && -n "$key" && "$num" > "$key" ]]; then
          echo "$value"
          return
        fi
      done
      if [ -n "$def_val" ]; then
        echo "$def_val"
      else
        echo " "
      fi
    }

    get_temp_color() {
      local temp=$1
      declare -A temp_colors=(
        [90]="#8b0000"
        [85]="#ad1f2f"
        [80]="#d22f2f"
        [75]="#ff471a"
        [70]="#ff6347"
        [65]="#ff8c00"
        [60]="#ffa500"
        [45]=""
        [40]="#add8e6"
        [35]="#87ceeb"
        [30]="#4682b4"
        [25]="#4169e1"
        [20]="#0000ff"
        [0]="#00008b"
      )

      for threshold in $(echo "''${!temp_colors[@]}" | tr ' ' '\n' | sort -nr); do
        if ((temp >= threshold)); then
          local color="''${temp_colors[$threshold]}"
          if [[ -n "$color" ]]; then
            echo "<span color='$color'><b>''${temp}°C</b></span>"
          else
            echo "''${temp}°C"
          fi
          return
        fi
      done
    }

    generate_json() {
      local temp_lv
      if [[ "$GPUINFO_EMOJI" -ne 1 ]]; then
        temp_lv="85:, 65:, 45:☁, ❄"
      else
        temp_lv="85:🌋, 65:🔥, 45:☁️, ❄️"
      fi
      local util_lv="90:, 60:󰓅, 30:󰾅, 󰾆"

      local icons
      icons="$(map_floor "$util_lv" "$utilization")$(map_floor "$temp_lv" "$temperature")"
      local speedo="''${icons:0:1}"
      local thermo="''${icons:1:1}"
      local emoji="''${icons:2}"
      local temp_color
      temp_color=$(get_temp_color "$temperature")

      local json="{\"text\":\"''${thermo} ''${temperature}°C\", \"tooltip\":\"''${emoji} ''${primary_gpu}\n''${thermo} Temperature: ''${temp_color}"

      declare -A tooltip_parts
      if [[ -n "$utilization" ]]; then tooltip_parts["\n$speedo Utilization: "]="''${utilization}%"; fi
      if [[ -n "$current_clock_speed" ]] && [[ -n "$max_clock_speed" ]]; then tooltip_parts["\n Clock Speed: "]="''${current_clock_speed}/''${max_clock_speed} MHz"; fi
      if [[ -n "$core_clock" ]]; then tooltip_parts["\n Clock Speed: "]="''${core_clock} MHz"; fi
      if [[ -n "$power_usage" ]]; then
        if [[ -n "$power_limit" ]]; then
          tooltip_parts["\n󱪉 Power Usage: "]="''${power_usage}/''${power_limit} W"
        else
          tooltip_parts["\n󱪉 Power Usage: "]="''${power_usage} W"
        fi
      fi
      if [[ -n "$power_discharge" ]] && [[ "$power_discharge" != "0" ]]; then tooltip_parts["\n Power Discharge: "]="''${power_discharge} W"; fi
      if [[ -n "$fan_speed" ]]; then tooltip_parts["\n Fan Speed: "]="''${fan_speed} RPM"; fi

      for key in "''${!tooltip_parts[@]}"; do
        local value="''${tooltip_parts[$key]}"
        if [[ -n "$value" && "$value" =~ [a-zA-Z0-9] ]]; then
          json+="$key$value"
        fi
      done
      json="$json\"}"
      echo "$json"
    }

    general_query() {
      local sensors_data
      sensors_data=$(sensors 2>/dev/null)
      temperature=$(echo "$sensors_data" | grep -m 1 -E "(edge|Package id.*|junction|hotspot)" | awk -F ':' '{print int($2)}')
      fan_speed=$(echo "$sensors_data" | grep -m 1 -E "fan[1-9]" | awk -F ':' '{print int($2)}')

      for file in /sys/class/power_supply/BAT*/power_now; do
        [[ -f "$file" ]] && power_discharge=$(awk '{print $1*10^-6 ""}' "$file") && break
      done
      [[ -z "$power_discharge" ]] && for file in /sys/class/power_supply/BAT*/current_now; do
        [[ -e "$file" ]] && power_discharge=$(awk -v current="$(cat "$file")" -v voltage="$(cat "''${file/current_now/voltage_now}")" 'BEGIN {print (current * voltage) / 10^12 ""}') && break
      done

      get_utilization() {
        local statFile
        statFile=$(head -1 /proc/stat)
        if [[ -z "''${GPUINFO_PREV_STAT:-}" ]]; then
          GPUINFO_PREV_STAT=$(awk '{print $2+$3+$4+$6+$7+$8 }' <<< "$statFile")
          echo "GPUINFO_PREV_STAT=\"$GPUINFO_PREV_STAT\"" >> "$gpuinfo_file"
        fi
        if [[ -z "''${GPUINFO_PREV_IDLE:-}" ]]; then
          GPUINFO_PREV_IDLE=$(awk '{print $5 }' <<< "$statFile")
          echo "GPUINFO_PREV_IDLE=\"$GPUINFO_PREV_IDLE\"" >> "$gpuinfo_file"
        fi
        local currStat
        currStat=$(awk '{print $2+$3+$4+$6+$7+$8 }' <<< "$statFile")
        local currIdle
        currIdle=$(awk '{print $5 }' <<< "$statFile")
        local diffStat=$((currStat - GPUINFO_PREV_STAT))
        local diffIdle=$((currIdle - GPUINFO_PREV_IDLE))

        GPUINFO_PREV_STAT=$currStat
        GPUINFO_PREV_IDLE=$currIdle

        sed -i -e "/^GPUINFO_PREV_STAT=/c\GPUINFO_PREV_STAT=\"$currStat\"" -e "/^GPUINFO_PREV_IDLE=/c\GPUINFO_PREV_IDLE=\"$currIdle\"" "$gpuinfo_file" || {
          echo "GPUINFO_PREV_STAT=\"$currStat\"" >> "$gpuinfo_file"
          echo "GPUINFO_PREV_IDLE=\"$currIdle\"" >> "$gpuinfo_file"
        }

        awk -v stat="$diffStat" -v idle="$diffIdle" 'BEGIN {printf "%.1f", (stat/(stat+idle))*100}'
      }

      utilization=$(get_utilization)
      current_clock_speed=$(awk '{sum += $1; n++} END {if (n > 0) print sum / n / 1000 ""}' /sys/devices/system/cpu/cpufreq/policy*/scaling_cur_freq)
      max_clock_speed=$(awk '{print $1/1000}' /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq)
    }

    intel_GPU() {
      primary_gpu="Intel $GPUINFO_INTEL_GPU"
      general_query
    }

    nvidia_GPU() {
      primary_gpu="NVIDIA $GPUINFO_NVIDIA_GPU"
      if [[ "$GPUINFO_NVIDIA_GPU" == "Linux" ]]; then
        general_query
        return
      fi
      if "$tired"; then
        local is_suspend
        is_suspend="$(cat "/sys/bus/pci/devices/0000:$NVIDIA_ADDR/power/runtime_status")"
        if [[ "$is_suspend" == *"suspend"* ]]; then
          printf '{"text":"󰤂", "tooltip":"%s ⏾ Suspended mode"}' "$primary_gpu"
          exit
        fi
      fi
      local gpu_info
      gpu_info=$(nvidia-smi --query-gpu=temperature.gpu,utilization.gpu,clocks.current.graphics,clocks.max.graphics,power.draw,power.limit --format=csv,noheader,nounits)
      IFS=',' read -ra gpu_data <<< "$gpu_info"
      temperature="''${gpu_data[0]// /}"
      utilization="''${gpu_data[1]// /}"
      current_clock_speed="''${gpu_data[2]// /}"
      max_clock_speed="''${gpu_data[3]// /}"
      power_usage="''${gpu_data[4]// /}"
      power_limit="''${gpu_data[5]// /}"
    }

    amd_GPU() {
      primary_gpu="AMD $GPUINFO_AMD_GPU"

      if command -v amd-smi >/dev/null 2>&1; then
        local amd_output
        amd_output=$(amd-smi metric -t --json 2>/dev/null)
        if [ -n "$amd_output" ]; then
          temperature=$(echo "$amd_output" | jq -r '.gpu_0.temperature.hotspot_temp // .gpu_0.temperature.edge_temp // (to_entries[] | select(.key | startswith("gpu_")) | .value.temperature.hotspot_temp // .value.temperature.edge_temp) // empty' 2>/dev/null | head -n1)
          temperature=$(echo "$temperature" | cut -d'.' -f1 2>/dev/null)
          utilization=$(echo "$amd_output" | jq -r '.gpu_0.utilization.gfx_activity // (to_entries[] | select(.key | startswith("gpu_")) | .value.utilization.gfx_activity) // empty' 2>/dev/null | head -n1)
          core_clock=$(echo "$amd_output" | jq -r '.gpu_0.clock.gfx_clock // (to_entries[] | select(.key | startswith("gpu_")) | .value.clock.gfx_clock) // empty' 2>/dev/null | head -n1)
          power_usage=$(echo "$amd_output" | jq -r '.gpu_0.power.socket_power // .gpu_0.power.total_power // (to_entries[] | select(.key | startswith("gpu_")) | .value.power.socket_power // .value.power.total_power) // empty' 2>/dev/null | head -n1)
        fi
      fi

      if [ -n "$temperature" ] && [ "$temperature" != "N/A" ]; then
        for card in /sys/class/drm/card*/device; do
          if [ -L "$card/driver" ] && basename "$(readlink -f "$card/driver")" 2>/dev/null | grep -qi "amdgpu"; then
            [ -z "$utilization" ] && [ -f "$card/gpu_busy_percent" ] && utilization=$(cat "$card/gpu_busy_percent" 2>/dev/null)
            [ -z "$core_clock" ] && [ -f "$card/pp_dpm_sclk" ] && core_clock=$(cat "$card/pp_dpm_sclk" 2>/dev/null | grep '\*' | grep -o '[0-9]\+' | head -n1)
            break
          fi
        done
      else
        general_query
      fi
    }

    if [[ ! -f "$gpuinfo_file" ]]; then
      query
      echo -e "Initialized Variable:\n$(cat "$gpuinfo_file")\n\nReboot or '$0 --reset' to RESET Variables"
    fi
    
    # shellcheck source=/dev/null
    source "$gpuinfo_file"

    case "''${1:-}" in
    "--toggle" | "-t")
      toggle
      echo -e "Sensor: $NEXT_PRIORITY GPU" | sed 's/_ENABLE//g'
      exit
      ;;
    "--use" | "-u")
      toggle "''${2:-}"
      ;;
    "--reset" | "-rf")
      rm -fr "''${gpuinfo_file}"*
      query
      echo -e "Initialized Variable:\n$(cat "$gpuinfo_file" || true)\n\nReboot or '$0 --reset' to RESET Variables"
      exit
      ;;
    "--stat")
      case "''${2:-}" in
      "amd")
        if [[ "$GPUINFO_AMD_ENABLE" -eq 1 ]]; then
          echo "GPUINFO_AMD_ENABLE: $GPUINFO_AMD_ENABLE"
          exit 0
        fi
        ;;
      "intel")
        if [[ "$GPUINFO_INTEL_ENABLE" -eq 1 ]]; then
          echo "GPUINFO_INTEL_ENABLE: $GPUINFO_INTEL_ENABLE"
          exit 0
        fi
        ;;
      "nvidia")
        if [[ "$GPUINFO_NVIDIA_ENABLE" -eq 1 ]]; then
          echo "GPUINFO_NVIDIA_ENABLE: $GPUINFO_NVIDIA_ENABLE"
          exit 0
        fi
        ;;
      *)
        echo "Error: Invalid argument for --stat. Use amd, intel, or nvidia."
        exit 1
        ;;
      esac
      echo "GPU not enabled."
      exit 1
      ;;
    *"-"*)
      GPUINFO_AVAILABLE="''${GPUINFO_AVAILABLE//GPUINFO_/}"
      cat <<EOF
    Available GPU: ''${GPUINFO_AVAILABLE//_ENABLE/}
  [options]
  --toggle         * Toggle available GPU
  --use [GPU]      * Only call the specified GPU (Useful for adding specific GPU on waybar)
  --reset          * Remove & restart all query

  [flags]
  --tired            * Adding this option will not query nvidia-smi if gpu is in suspend mode
  --startup          * Useful if you want a certain GPU to be set at startup
  --emoji            * Use Emoji instead of Glyphs

  * If $USER declared env = AQ_DRM_DEVICES on hyprland then use this as the primary GPU
  EOF
      exit
      ;;
    esac

    GPUINFO_NVIDIA_ENABLE="''${GPUINFO_NVIDIA_ENABLE:-0}"
    GPUINFO_INTEL_ENABLE="''${GPUINFO_INTEL_ENABLE:-0}"
    GPUINFO_AMD_ENABLE="''${GPUINFO_AMD_ENABLE:-0}"

    if [[ "$GPUINFO_NVIDIA_ENABLE" -eq 1 ]]; then
      nvidia_GPU
    elif [[ "$GPUINFO_AMD_ENABLE" -eq 1 ]]; then
      amd_GPU
    elif [[ "$GPUINFO_INTEL_ENABLE" -eq 1 ]]; then
      intel_GPU
    else
      primary_gpu="initialising..."
      general_query
    fi

    generate_json
  '';
}