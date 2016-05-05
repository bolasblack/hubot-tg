if [ ! -d ./telegram-cli-wrapper ]; then
  git clone --recursive https://github.com/bolasblack/telegram-cli-wrapper.git
  cd ./telegram-cli-wrapper
  ./compile-dependencies.sh
  exit
fi

cd ./telegram-cli-wrapper
originHash=$(git rev-parse HEAD)
git fetch origin && git reset --hard origin/master
git submodule update --init --recursive
currentHash=$(git rev-parse HEAD)
if [ $originHash != $currentHash ]; then
  ./compile-dependencies.sh
fi
