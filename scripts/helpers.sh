cd "$(dirname "$0")/.."
export app_root=`pwd`
export base_folder=$app_root/tmp
export source_folder=$base_folder/src
export build_folder=$base_folder/build
export blobs_folder=$base_folder/blobs
export assets_folder=$app_root/scripts/assets

mkdir -p $base_folder
mkdir -p $source_folder
mkdir -p $build_folder
mkdir -p $blobs_folder


function download_sources {
  local package_name=$1
  local package_version=$2
  local url=$3
  local target_archive=$source_folder/$package_name-$package_version.tar.gz
  if [ ! -f $target_archive ]; then
    wget -O $source_folder/$package_name-$package_version.tar.gz $url
  fi
}

function update_package_configs {
  local package_name=$1
  local package_version=$2	
  set_environment_variables $package_name $package_version
  unarchive_package
  cd $build_folder
  update_config_files $full_package_name
  tar -czvf $blobs_folder/$full_package_name.tar.gz $full_package_name
}

function update_config_files {
  local package_to_update_name=$1
  local config_guess_path=`find $package_to_update_name -name config.guess`
  [ -f "$config_guess_path" ] && cp $assets_folder/config.guess $config_guess_path
  local config_sub_path=`find $package_to_update_name -name config.sub`
  [ -f "$config_sub_path" ] && cp $assets_folder/config.sub $config_sub_path
}

function patch_package {
  local package_name=$1
  local package_version=$2  
  set_environment_variables $package_name $package_version
  unarchive_package
  go_to_build_folder
  patch -p1 < $assets_folder/$package_name-$package_version.patch
}

function set_environment_variables {
  local package_name=$1
  local package_version=$2

  export full_package_name=$package_name-$package_version
}

function unarchive_package {
  tar -xzvf $source_folder/$full_package_name.tar.gz -C $build_folder
}

function go_to_build_folder {
  cd $build_folder/$full_package_name
}

function archive_package {
  local $scope=$1
  export target_folder=$blobs_folder/$scope
  mkdir -p $target_folder  
  tar -xzvf $source_folder/$full_package_name.tar.gz -C $build_folder
}
