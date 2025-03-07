#!/bin/bash

todos_file_path=/home/sean/todos/todos.md
done_file_path=/home/sean/todos/done.md
date_format='+%m-%d'
grep_options="--color=always"
sort_options=("--stable" "--output=${todos_file_path}" "--key=1,1")

# new todo
tn () {
  echo "$@" >> "$todos_file_path"
  sort $sort_options "$todos_file_path"
}

# list today's todos
t () {
  cat "$todos_file_path" | grep `date "$date_format"` | awk '{ $1=""; print }' | awk '{ $1=$1; print }' | grep "$grep_options" "^\|^[^+]*" | cat -n
}

# edit todo file
et () {
  nvim -c "exe '/'..strftime('%y-%m-%d')" "$todos_file_path"
  sort $sort_options "$todos_file_path"
  t
}

# list all todos
ta () {
  cat "$todos_file_path"
}

# search by project
tp () {
  t | grep "$grep_options" "+$1"
}

# mark todo done
td () {
  done_line="$(cat -n ${todos_file_path} | fzf --reverse | awk '{print $1}')"

  # check if no selection
  if [[ -z "$done_line" ]]; then
    echo "No line selected to delete."
    return
  fi

  sed -n "${done_line}p" "$todos_file_path" >> "$done_file_path" 
  sed -i "${done_line}d" "$todos_file_path"
}

# help
th ()
{
  echo "*** todo.sh ***

- tn:                 add todo ('todo new')
- td:                 mark todo done ('todo done')
- et:                 edit todo file ('edit todos')
- t:                  list today's todos ('todos')
- ta:                 list all todos ('todo all')
- tp <project_name>:  list all todos with the given <project_name> ('todo project')
- th:                 show help (current command) ('todo help')"
}
