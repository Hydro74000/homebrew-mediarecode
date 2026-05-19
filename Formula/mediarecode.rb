class Mediarecode < Formula
  desc "Renamed to Muxiveo — use Hydro74000/muxiveo tap instead"
  homepage "https://github.com/Hydro74000/muxiveo"
  version "3.0.0"
  license "MIT"

  url "https://github.com/Hydro74000/muxiveo/releases/download/v3.0.0/Muxiveo-3.0.0-homebrew-macos.tar.gz"
  sha256 "37ef49e87c349567a8ea738c612d68a557836a6884ea8952d477c12ea141a8b3"

  deprecate! date: "2026-05-19", because: :renamed, replacement_formula: "Hydro74000/muxiveo/muxiveo"

  def install
    odie <<~EOS
      Mediarecode a été renommé en Muxiveo.
      Veuillez migrer avec :

        brew uninstall mediarecode
        brew untap Hydro74000/mediarecode
        brew tap Hydro74000/muxiveo
        brew install muxiveo
    EOS
  end
end
