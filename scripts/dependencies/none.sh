function build_libiconv()
{
  # https://www.gnu.org/software/libiconv/
  # https://ftp.gnu.org/pub/gnu/libiconv/

  # https://github.com/archlinux/svntogit-community/blob/packages/libiconv/trunk/PKGBUILD
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=libiconv

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/libiconv.rb

  # 2011-08-07 1.14"
  # 2017-02-02 "1.15"
  # 2019-04-26 "1.16"
  # 2022-05-15 "1.17"

  local libiconv_version="$1"
  local name_suffix=${2-''}

  local libiconv_src_folder_name="libiconv-${libiconv_version}"

  local libiconv_archive="${libiconv_src_folder_name}.tar.gz"
  local libiconv_url="https://ftp.gnu.org/pub/gnu/libiconv/${libiconv_archive}"

  local libiconv_folder_name="${libiconv_src_folder_name}${name_suffix}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${libiconv_folder_name}"

  local libiconv_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${libiconv_folder_name}-installed"
  if [ ! -f "${libiconv_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${libiconv_url}" "${libiconv_archive}" \
      "${libiconv_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${libiconv_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${libiconv_folder_name}"

      xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      # -fgnu89-inline fixes "undefined reference to `aliases2_lookup'"
      #  https://savannah.gnu.org/bugs/?47953
      CFLAGS="${XBB_CFLAGS_NO_W} -fgnu89-inline"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_LIB}"
      if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
      then
        LDFLAGS+=" -Wl,-rpath,${LD_LIBRARY_PATH}"
      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      if [ ! -f "config.status" ]
      then
        (
          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            env | sort
          fi

          echo
          echo "Running libiconv${name_suffix} configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${libiconv_src_folder_name}/configure" --help
          fi

          config_options=()

          config_options+=("--prefix=${XBB_BINARIES_INSTALL_FOLDER_PATH}${name_suffix}")
          config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}${name_suffix}/lib")
          config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}${name_suffix}/include")
          # config_options+=("--datarootdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}${name_suffix}/share")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}${name_suffix}/share/man")

          config_options+=("--build=${XBB_BUILD}")
          if [ "${name_suffix}" == "-bootstrap" ]
          then
            # The bootstrap binaries will run on the build machine.
            config_options+=("--host=${XBB_BUILD}")
          else
            config_options+=("--host=${XBB_HOST}")
          fi
          config_options+=("--target=${XBB_TARGET}")

          config_options+=("--disable-debug") # HB
          config_options+=("--disable-dependency-tracking") # HB
          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            config_options+=("--disable-silent-rules") # HB
          fi

          config_options+=("--disable-nls")

          config_options+=("--enable-static") # HB
          config_options+=("--enable-extra-encodings") # Arch

          # Fails on macOS:
          # /bin/bash: /Users/ilg/Work/xbb-bootstrap-4.0.0/darwin-arm64/sources/libiconv-1.16/libcharset/build-aux/libtool-reloc: No such file or directory
          # config_options+=("--enable-relocatable")

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${libiconv_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${libiconv_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libiconv_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running libiconv${name_suffix} make..."

        # Build.
        run_verbose make -j 1 # ${XBB_JOBS}

        if [ "${XBB_WITH_TESTS}" == "y" ]
        then
          run_verbose make -j1 check
        fi

        if [ "${XBB_WITH_STRIP}" == "y" ]
        then
          run_verbose make install-strip
        else
          run_verbose make install
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${libiconv_folder_name}/make-output-$(ndate).txt"

      if [ -z "${name_suffix}" ]
      then
        copy_license \
          "${XBB_SOURCES_FOLDER_PATH}/${libiconv_src_folder_name}" \
          "${libiconv_folder_name}"
      fi

    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${libiconv_stamp_file_path}"

  else
    echo "Library libiconv${name_suffix} already installed."
  fi
}
