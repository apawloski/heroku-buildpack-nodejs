# GP-MCE fix
set_local_config() {
    npm config set registry "http://registry.npmjs.org/"
    npm config set proxy "$http_proxy"
    npm config set https-proxy "$https_proxy"
    npm set strict-ssl false
    npm config list
}

run_if_present() {
  local script_name=${1:-}
  local has_script=$(read_json "$BUILD_DIR/package.json" ".scripts[\"$script_name\"]")
  if [ -n "$has_script" ]; then
      echo "Running $script_name"
      set_local_config
      npm run "$script_name" --if-present
  fi
}

install_node_modules() {
  local build_dir=${1:-}

  if [ -e $build_dir/package.json ]; then
    cd $build_dir

    if [ -e $build_dir/npm-shrinkwrap.json ]; then
      echo "Installing node modules (package.json + shrinkwrap)"
    else
      echo "Installing node modules (package.json)"
    fi
    set_local_config
    npm install --unsafe-perm 2>&1 # --userconfig $build_dir/.npmrc 2>&1
  else
    echo "Skipping (no package.json)"
  fi
}

rebuild_node_modules() {
  local build_dir=${1:-}

  if [ -e $build_dir/package.json ]; then
    cd $build_dir
    echo "Rebuilding any native modules"
    npm rebuild 2>&1
    if [ -e $build_dir/npm-shrinkwrap.json ]; then
      echo "Installing any new modules (package.json + shrinkwrap)"
    else
      echo "Installing any new modules (package.json)"
    fi
    set_local_config
    npm install --unsafe-perm --userconfig $build_dir/.npmrc 2>&1
  else
    echo "Skipping (no package.json)"
  fi
}
