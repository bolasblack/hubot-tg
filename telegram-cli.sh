echo $PWD
cd "$(dirname "$0")"

if [ -d telegram-cli-wrapper ]; then
  git clone --recursive https://github.com/bolasblack/telegram-cli-wrapper.git
else
  git submodule --recursive update
fi

cd telegram-cli-wrapper
./compile-dependencies.sh
