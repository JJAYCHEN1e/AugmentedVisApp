export PATH="/opt/homebrew/bin:$PATH"
shell_path=$(cd "$(dirname "$0")";pwd)
root_path=$(dirname $shell_path)
echo "Start building..."
# This is now done in editor's yarn build script
# sh $shell_path/update-local-dependency.sh
# wait
cd $shell_path/myarvis-json-editor && yarn build&
wait
rm -rf $root_path/macOS/Features/JSON\ Editor/Web\ Code\ Source/EditorPanel
mkdir $root_path/macOS/Features/JSON\ Editor/Web\ Code\ Source/EditorPanel
cp -R $shell_path/myarvis-json-editor/build/* $root_path/macOS/Features/JSON\ Editor/Web\ Code\ Source/EditorPanel
echo "Build finished."
