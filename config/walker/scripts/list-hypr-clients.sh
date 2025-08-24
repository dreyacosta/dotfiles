#!/bin/bash

hyprctl clients -j | jq -r '[ .[] | select(.workspace.id != -1) ] | sort_by([.workspace.name, .class, .title]) | .[] | "\(.address)\t\(.pid)\t\(.workspace.name)\t\(.title)"' | while IFS=$'\t' read -r address pid workspace_name title; do
  binary_name=$(ps -p "$pid" -o comm=)
  echo -e "label=[$workspace_name] [$binary_name] $title;value=$address"
done
