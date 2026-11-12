#!/bin/bash
input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "Claude"')
dir=$(echo "$input" | jq -r '.workspace.current_dir // empty')
branch=$(git -C "${dir:-.}" branch --show-current 2>/dev/null)

used=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
size=$(echo "$input" | jq -r '.context_window.context_window_size // 0')
case "$size" in
  1000000) size_label="1M" ;;
  200000) size_label="200k" ;;
  0) size_label="?" ;;
  *) size_label="$((size / 1000))k" ;;
esac

make_bar() {
  local pct=$1 out="" i filled
  filled=$((pct / 10))
  for ((i = 0; i < 10; i++)); do
    if ((i < filled)); then out+="▓"; else out+="░"; fi
  done
  echo "$out"
}

bar=$(make_bar "$used")

cost=$(echo "$input" | jq -r '.cost.total_cost_usd // 0' | xargs printf '%.2f')
limit=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty' | cut -d. -f1)
resets=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
reset_time=""
[[ -n $resets ]] && reset_time=$(date -d "@$resets" +%H:%M 2>/dev/null || date -r "$resets" +%H:%M)

pr_bar() {
  command -v pr-review-digest >/dev/null || return
  local cache_dir="${XDG_STATE_HOME:-$HOME/.local/state}/pr-review-digest/bar"
  local cache="$cache_dir/$(printf '%s@%s' "$dir" "$branch" | tr -c 'A-Za-z0-9._-' '_')"
  mkdir -p "$cache_dir"
  if [[ -z $(find "$cache" -mmin -1 2>/dev/null) ]]; then
    touch "$cache"
    (cd "${dir:-.}" && pr-review-digest --bar >"$cache.tmp" 2>/dev/null; mv "$cache.tmp" "$cache") >/dev/null 2>&1 &
  fi
  cat "$cache" 2>/dev/null
}

[[ -n $branch ]] && pr=$(pr_bar)

sep="  ◆  "
line="$model"
[[ -n $branch ]] && line+="${sep}$branch"
[[ -n $pr ]] && line+=" $pr"
line+="${sep}$bar ${used}% of ${size_label}${sep}\$${cost}"
if [[ -n $limit ]]; then
  line+="${sep}5h $(make_bar "$limit") ${limit}%"
  [[ -n $reset_time ]] && line+=" → ${reset_time}"
fi

echo "$line"
