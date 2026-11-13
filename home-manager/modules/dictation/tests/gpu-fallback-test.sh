#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
test_dir="$(mktemp -d)"
runtime_dir="${test_dir}/runtime"
data_dir="${test_dir}/data"
bin_dir="${test_dir}/bin"
work_dir="${runtime_dir}/dictation/recording.test"
log_file="${test_dir}/whisper.log"

cleanup() {
  rm -rf "$test_dir"
}
trap cleanup EXIT

mkdir -p "$bin_dir" "$work_dir" "${data_dir}/whisper-cpp"
printf 'audio' >"${work_dir}/dictation.wav"
printf 'small' >"${data_dir}/whisper-cpp/ggml-small.bin"
printf 'medium' >"${data_dir}/whisper-cpp/ggml-medium.bin"
printf 'recording|999999||%s\n' "$work_dir" >"${runtime_dir}/dictation/state"

for command in notify-send xclip xdotool; do
  cat >"${bin_dir}/${command}" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
  chmod +x "${bin_dir}/${command}"
done

cat >"${bin_dir}/nvidia-smi" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
chmod +x "${bin_dir}/nvidia-smi"

cat >"${bin_dir}/gpu-whisper" <<'EOF'
#!/usr/bin/env bash
printf 'gpu %s\n' "$*" >>"$DICTATION_TEST_LOG"
exit 1
EOF
chmod +x "${bin_dir}/gpu-whisper"

cat >"${bin_dir}/cpu-whisper" <<'EOF'
#!/usr/bin/env bash
printf 'cpu %s\n' "$*" >>"$DICTATION_TEST_LOG"
output_file=""
while [ "$#" -gt 0 ]; do
  if [ "$1" = "--output-file" ]; then
    output_file="$2"
    break
  fi
  shift
done
printf 'fallback text' >"${output_file}.txt"
EOF
chmod +x "${bin_dir}/cpu-whisper"

PATH="${bin_dir}:$PATH" \
XDG_RUNTIME_DIR="$runtime_dir" \
XDG_DATA_HOME="$data_dir" \
DICTATION_WHISPER_GPU="${bin_dir}/gpu-whisper" \
DICTATION_WHISPER_CPU="${bin_dir}/cpu-whisper" \
DICTATION_TEST_LOG="$log_file" \
bash "${root}/dictation.sh" stop

grep -Fq "gpu --model ${data_dir}/whisper-cpp/ggml-medium.bin" "$log_file"
grep -Fq "cpu --model ${data_dir}/whisper-cpp/ggml-small.bin" "$log_file"
