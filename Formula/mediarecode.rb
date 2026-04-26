class Mediarecode < Formula
  desc "GUI video workflow tool for remuxing, encoding, Dolby Vision and HDR10+"
  homepage "https://github.com/Hydro74000/mediarecode"
  version "2.0.0"
  license "MIT"

  on_linux do
    url "https://github.com/Hydro74000/mediarecode/releases/download/v2.0.0/Mediarecode-x86_64_allinc-2.0.0.AppImage"
    sha256 "61abe49df728c4d1acfca5a49f9259b709e000e1183d2bcceb3f3106be03e88c"
  end

  on_macos do
    url "https://github.com/Hydro74000/mediarecode/releases/download/v2.0.0/Mediarecode-2.0.0-homebrew-macos.tar.gz"
    sha256 "8a066a87cf59fce3d66a649f6c0d8f0267d8cb8d971d7bc034d391c5a96e9086"

    depends_on "ffmpeg"
    depends_on "mediainfo"

    resource "dovi_tool" do
      url "https://github.com/quietvoid/dovi_tool/releases/download/2.3.2/dovi_tool-2.3.2-universal-macOS.zip"
      sha256 "a79653695b29fa61ce46e855baf9bcd2f56628b66ab8266cf87a587914829da7"
    end

    resource "hdr10plus_tool" do
      url "https://github.com/quietvoid/hdr10plus_tool/releases/download/1.7.2/hdr10plus_tool-1.7.2-universal-macOS.zip"
      sha256 "d76977ed2ea90f8d6bce9035e37ea9dbffcead4725ceb1acf455c25d8658ff28"
    end
  end

  def install_linux_desktop_entry
    desktop_dir = Pathname.new(File.expand_path("~/.local/share/applications"))
    desktop_dir.mkpath
    (desktop_dir/"mediarecode.desktop").write <<~EOS
      [Desktop Entry]
      Name=Mediarecode
      Comment=MKV/MP4 workflow - DoVi, HDR10+, encoding
      Exec=#{opt_bin}/mediarecode %F
      Icon=video-x-generic
      Type=Application
      Categories=AudioVideo;Video;
      MimeType=audio/aac;audio/flac;audio/mp4;audio/ogg;audio/opus;audio/vnd.dts;audio/vnd.dts.hd;audio/x-m4a;audio/x-matroska;audio/x-ms-wma;audio/x-wav;audio/x-wavpack;application/x-subrip;application/x-matroska;application/x-mpegURL;application/x-ssa;application/x-ass;text/plain;text/vtt;text/x-ass;text/x-ssa;video/mp4;video/mpeg;video/quicktime;video/webm;video/x-flv;video/x-matroska;video/x-msvideo;video/x-ms-wmv;video/x-m2ts;video/x-mpeg;video/x-h264;video/x-h265;video/x-av1;video/x-vc1;
      Terminal=false
      StartupNotify=true
    EOS
  end

  def install_macos_app_link
    apps_dir = Pathname.new(File.expand_path("~/Applications"))
    apps_dir.mkpath
    app_link = apps_dir/"Mediarecode.app"
    return if app_link.exist?

    app_link.make_symlink(opt_prefix/"Mediarecode.app")
  rescue StandardError
    nil
  end

  def install
    if OS.mac?
      prefix.install "Mediarecode.app"
      (libexec/"tools").mkpath

      resource("dovi_tool").stage do
        libexec.install Dir["**/dovi_tool"].first => "tools/dovi_tool"
      end

      resource("hdr10plus_tool").stage do
        libexec.install Dir["**/hdr10plus_tool"].first => "tools/hdr10plus_tool"
      end

      chmod 0755, libexec/"tools/dovi_tool"
      chmod 0755, libexec/"tools/hdr10plus_tool"
      install_macos_app_link

      (libexec/"mediarecode").write <<~EOS
        #!/bin/bash
        set -euo pipefail
        CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/mediarecode"
        CONFIG_FILE="${CONFIG_DIR}/config.ini"
        APPS_DIR="${HOME}/Applications"
        APP_LINK="${APPS_DIR}/Mediarecode.app"
        mkdir -p "${CONFIG_DIR}"
        mkdir -p "${APPS_DIR}"
        if [ ! -f "${CONFIG_FILE}" ]; then
          cat > "${CONFIG_FILE}" <<'CFG'
# Mediarecode - configuration locale
# Fichier cree par le wrapper Homebrew pour eviter le setup interactif.
CFG
        fi
        if [ ! -e "${APP_LINK}" ]; then
          ln -s "#{opt_prefix}/Mediarecode.app" "${APP_LINK}" 2>/dev/null || true
        fi
        export PATH="#{opt_libexec}/tools:#{HOMEBREW_PREFIX}/bin:$PATH"
        exec "#{opt_prefix}/Mediarecode.app/Contents/MacOS/Mediarecode" "$@"
      EOS
      chmod 0755, libexec/"mediarecode"
      bin.install_symlink libexec/"mediarecode"
    else
      libexec.install Dir["*.AppImage"].first => "Mediarecode.AppImage"
      chmod 0755, libexec/"Mediarecode.AppImage"
      install_linux_desktop_entry

      (libexec/"mediarecode").write <<~EOS
        #!/bin/bash
        set -euo pipefail
        CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/mediarecode"
        CONFIG_FILE="${CONFIG_DIR}/config.ini"
        DESKTOP_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
        DESKTOP_FILE="${DESKTOP_DIR}/mediarecode.desktop"
        mkdir -p "${CONFIG_DIR}"
        mkdir -p "${DESKTOP_DIR}"
        if [ ! -f "${CONFIG_FILE}" ]; then
          cat > "${CONFIG_FILE}" <<'CFG'
# Mediarecode - configuration locale
# Fichier cree par le wrapper Homebrew.
CFG
        fi
        if [ ! -f "${DESKTOP_FILE}" ]; then
          cat > "${DESKTOP_FILE}" <<'DESKTOP'
[Desktop Entry]
Name=Mediarecode
Comment=MKV/MP4 workflow - DoVi, HDR10+, encoding
Exec=#{opt_bin}/mediarecode %F
Icon=video-x-generic
Type=Application
Categories=AudioVideo;Video;
MimeType=audio/aac;audio/flac;audio/mp4;audio/ogg;audio/opus;audio/vnd.dts;audio/vnd.dts.hd;audio/x-m4a;audio/x-matroska;audio/x-ms-wma;audio/x-wav;audio/x-wavpack;application/x-subrip;application/x-matroska;application/x-mpegURL;application/x-ssa;application/x-ass;text/plain;text/vtt;text/x-ass;text/x-ssa;video/mp4;video/mpeg;video/quicktime;video/webm;video/x-flv;video/x-matroska;video/x-msvideo;video/x-ms-wmv;video/x-m2ts;video/x-mpeg;video/x-h264;video/x-h265;video/x-av1;video/x-vc1;
Terminal=false
StartupNotify=true
DESKTOP
        fi
        if [ ! -e /dev/fuse ]; then
          export APPIMAGE_EXTRACT_AND_RUN=1
        fi
        exec "#{opt_libexec}/Mediarecode.AppImage" "$@"
      EOS
      chmod 0755, libexec/"mediarecode"
      bin.install_symlink libexec/"mediarecode"
    end
  end

  test do
    if OS.mac?
      assert_predicate prefix/"Mediarecode.app", :exist?
      assert_predicate bin/"mediarecode", :exist?
    else
      assert_predicate libexec/"Mediarecode.AppImage", :exist?
      assert_predicate bin/"mediarecode", :exist?
    end
  end
end
