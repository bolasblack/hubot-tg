if [ -d ./telegram-cli-wrapper ]; then
  git submodule --recursive update
else
  git clone --recursive https://github.com/bolasblack/telegram-cli-wrapper.git
fi

cd ./telegram-cli-wrapper
./compile-dependencies.sh
