if [ -d telegram-cli-wrapper ]; then
  git clone --recursive git@github.com:bolasblack/telegram-cli-wrapper.git
else
  git submodule --recursive update
fi

cd telegram-cli-wrapper
./compile-dependencies.sh
