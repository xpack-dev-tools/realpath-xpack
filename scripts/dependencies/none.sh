function build_coreutils()
{
  # https://www.gnu.org/software/coreutils/
  # https://ftp.gnu.org/gnu/coreutils/

  # https://github.com/archlinux/svntogit-packages/blob/packages/coreutils/trunk/PKGBUILD
  # https://archlinuxarm.org/packages/aarch64/coreutils/files/PKGBUILD

  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/coreutils.rb

  # 2018-07-01, "8.30"
  # 2019-03-10 "8.31"
  # 2020-03-05, "8.32"
  # 2021-09-24, "9.0"
  # 2022-04-15, "9.1"

  local coreutils_version="$1"

  local coreutils_src_folder_name="coreutils-${coreutils_version}"

  local coreutils_archive="${coreutils_src_folder_name}.tar.xz"
  local coreutils_url="https://ftp.gnu.org/gnu/coreutils/${coreutils_archive}"

  local coreutils_folder_name="${coreutils_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${coreutils_folder_name}"

  local coreutils_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${coreutils_folder_name}-installed"
  if [ ! -f "${coreutils_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${coreutils_url}" "${coreutils_archive}" \
      "${coreutils_src_folder_name}"

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${coreutils_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${coreutils_folder_name}"

      xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      # LDFLAGS="${XBB_LDFLAGS_APP_STATIC_GCC}"
      LDFLAGS="${XBB_LDFLAGS_APP}"
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
          echo "Running coreutils configure..."

          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            run_verbose bash "${XBB_SOURCES_FOLDER_PATH}/${coreutils_src_folder_name}/configure" --help
          fi

          if [ "${HOME}" == "/root" ]
          then
            # configure: error: you should not run configure as root
            # (set FORCE_UNSAFE_CONFIGURE=1 in environment to bypass this check)
            export FORCE_UNSAFE_CONFIGURE=1
          fi

          config_options=()

          config_options+=("--prefix=${XBB_BINARIES_INSTALL_FOLDER_PATH}")
          config_options+=("--libdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib")
          config_options+=("--includedir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/include")
          # config_options+=("--datarootdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")

          config_options+=("--build=${XBB_BUILD}")
          config_options+=("--host=${XBB_HOST}")
          config_options+=("--target=${XBB_TARGET}")

          config_options+=("--without-selinux") # HB

          config_options+=("--with-universal-archs=${XBB_TARGET_BITS}-bit")
          config_options+=("--with-computed-gotos")
          config_options+=("--with-dbmliborder=gdbm:ndbm")

          # config_options+=("--with-openssl") # Arch
          config_options+=("--with-openssl=no")

          config_options+=("--with-gmp") # HB

          config_options+=("--disable-debug") # HB
          config_options+=("--disable-dependency-tracking") # HB
          if [ "${XBB_IS_DEVELOP}" == "y" ]
          then
            config_options+=("--disable-silent-rules") # HB
          fi

          config_options+=("--disable-nls")

          if [ "${XBB_TARGET_PLATFORM}" == "darwin" ]
          then
            # This is debatable, to either keep the original names
            # (and avoid ar) or to prefix everything with g (like HB).

            # config_options+=("--program-prefix=g") # HB
            # `ar` must be excluded, it interferes with Apple similar program.
            config_options+=("--enable-no-install-program=ar")
          fi

          # --enable-no-install-program=groups,hostname,kill,uptime # Arch

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${coreutils_src_folder_name}/configure" \
            "${config_options[@]}"

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${coreutils_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${coreutils_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running coreutils make..."

        # Build.
        run_verbose make -j 1 # ${XBB_JOBS}
        # run_verbose make -j ${XBB_JOBS}

        if [ "${XBB_COREUTILS_INSTALL_REALPATH_ONLY:-}" == "y" ]
        then
          run_verbose install -v -d \
            "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin"
          run_verbose install -v -c -m 755 src/realpath \
            "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin/grealpath"
          run_verbose install -v -c -m 755 src/readlink \
            "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin/greadlink"
        else
          if [ "${XBB_TARGET_PLATFORM}" == "darwin" ]
          then
            # Strip fails with:
            # 2022-10-01T12:53:19.6394770Z /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/strip: error: symbols referenced by indirect symbol table entries that can't be stripped in: /Users/ilg/Work/xbb-bootstrap-4.0/darwin-arm64/install/xbb-bootstrap/libexec/coreutils/_inst.24110_
            run_verbose make install
          else
            if [ "${XBB_WITH_STRIP}" == "y" ]
            then
              run_verbose make install-strip
            else
              run_verbose make install
            fi
          fi
        fi

        # Takes very long and fails.
        # x86_64: FAIL: tests/misc/chroot-credentials.sh
        # x86_64: ERROR: tests/du/long-from-unreadable.sh
        # WARN-TEST
        # make -j1 check

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${coreutils_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${coreutils_src_folder_name}" \
        "${coreutils_folder_name}"
    )

    (
      if [ "${XBB_COREUTILS_INSTALL_REALPATH_ONLY:-}" == "y" ]
      then
        test_coreutils_realpath "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin"
      else
        test_coreutils "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin"
      fi
    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${coreutils_folder_name}/test-output-$(ndate).txt"

    hash -r

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${coreutils_stamp_file_path}"

  else
    echo "Component coreutils already installed."
  fi

  if [ "${XBB_COREUTILS_INSTALL_REALPATH_ONLY:-}" == "y" ]
  then
    tests_add "test_coreutils_realpath" "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin"
  else
    tests_add "test_coreutils" "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin"
  fi
}
