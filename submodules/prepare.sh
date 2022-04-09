shell_path=$(cd "$(dirname "$0")";pwd)
cd $shell_path/myarvis-json-renderer && yarn&
cd $shell_path/myarvis-json-compiler && yarn&
wait
cd $shell_path/myarvis-json-editor && yarn&
wait
