export PATH="/opt/homebrew/bin:$PATH"
shell_path=$(cd "$(dirname "$0")";pwd)
cd $shell_path/myarvis-json-compiler && yarn lib& 
wait
cd $shell_path/myarvis-json-renderer && yarn lib&
wait