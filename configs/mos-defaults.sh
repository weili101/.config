#!/usr/bin/env bash
set -euo pipefail

# Mos preferences observed on this Mac. Mos may overwrite these while running,
# so quit Mos before applying.
defaults write com.caldis.Mos allowlist -int 0
defaults write com.caldis.Mos deadZone -int 1
defaults write com.caldis.Mos duration -string "1.809087171052632"
defaults write com.caldis.Mos hideStatusItem -int 1
defaults write com.caldis.Mos reverse -int 1
defaults write com.caldis.Mos reverseHorizontal -int 1
defaults write com.caldis.Mos reverseVertical -int 1
defaults write com.caldis.Mos smooth -int 1
defaults write com.caldis.Mos smoothHorizontal -int 1
defaults write com.caldis.Mos smoothSimTrackpad -int 0
defaults write com.caldis.Mos smoothVertical -int 1
defaults write com.caldis.Mos speed -string "3.150000000000002"
defaults write com.caldis.Mos step -string "36.98461220189144"
defaults write com.caldis.Mos updateCheckOnAppStart -int 0
defaults write com.caldis.Mos updateIncludingBetaVersion -int 0
