_memegen()
{
  local curw
  COMPREPLY=()
  curw=${COMP_WORDS[COMP_CWORD]}
  COMPREPLY=($(compgen -W '$(echo "" | memegen --list)' -- $curw))
  return 0
}
complete -F _memegen -o dirnames memegen