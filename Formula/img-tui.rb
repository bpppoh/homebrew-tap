class ImgTui < Formula
  desc "Offline keyboard-first image compressor TUI with iLoveIMG-grade pipelines"
  homepage "https://github.com/bpppoh/img-tui"
  url "https://github.com/bpppoh/img-tui/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "90db264d83a7279f083b4bcad3b3dc689d5bb13424706e3b3b4b03ab343088c8"
  license "MIT"

  depends_on "gifsicle"
  depends_on "mozjpeg"
  depends_on "oxipng"
  depends_on "pillow"
  depends_on "pngquant"
  depends_on "python@3.14"
  depends_on "webp"

  def install
    libexec.install "src"

    (libexec/"img-tui").write <<~SH
      #!/bin/sh
      SELF="$0"
      CALL_DIR="$(cd "$(dirname "$0")" && pwd)"
      while [ -L "$SELF" ]; do
        TARGET="$(readlink "$SELF")"
        case "$TARGET" in
          /*) SELF="$TARGET" ;;
          *) SELF="$(dirname "$SELF")/$TARGET" ;;
        esac
      done
      CELLAR_ROOT="$(cd "$(dirname "$SELF")/.." && pwd)"
      PY=""
      for candidate in \\
        "$CALL_DIR/../opt/python@3.14/libexec/bin/python" \\
        "$CELLAR_ROOT/../../opt/python@3.14/libexec/bin/python"; do
        if [ -x "$candidate" ]; then
          PY="$candidate"
          break
        fi
      done
      [ -n "$PY" ] || PY="python3.14"
      PYTHONPATH="$CELLAR_ROOT/libexec/src${PYTHONPATH:+:$PYTHONPATH}" exec "$PY" -m img_tui "$@"
    SH

    chmod 0755, libexec/"img-tui"
    bin.install_symlink libexec/"img-tui"
  end

  def caveats
    return unless OS.linux?

    <<~EOS
      Optional HEIC/HEIF support on Linux requires ffmpeg:
        brew install ffmpeg
    EOS
  end

  test do
    assert_match "img-tui #{version}", shell_output("#{bin}/img-tui --version")
    python = formula_opt_libexec("python@3.14")/"bin/python"
    system python, "-c",
           "import sys; sys.path.insert(0, '#{libexec}/src'); " \
           "from PIL import Image; " \
           "import img_tui.app, img_tui.compressor, img_tui.preview"
  end
end
