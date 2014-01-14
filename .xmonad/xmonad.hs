import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Layout.NoBorders
import XMonad.Layout.ResizableTile
import XMonad.Prompt
import XMonad.Prompt.AppendFile
import XMonad.Util.Dmenu
import XMonad.Util.EZConfig(additionalKeys)
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.NamedScratchpad

import System.Exit
import System.IO

import Control.Monad
import Graphics.X11.ExtraTypes.XF86

import qualified XMonad.StackSet as W

quitWithWarning :: X()
quitWithWarning = do
  let m = "confirm quit"
  s <- dmenu [m]
  when (m == s) (io exitSuccess)

avoidMaster :: W.StackSet i l a s sd -> W.StackSet i l a s sd
avoidMaster = W.modify' $ \c -> case c of
    W.Stack t [] (r:rs) -> W.Stack t [r] rs
    otherwise           -> c

scratchpads = [
        -- gvim editing ~/Documents/notes.txt
        NS "notes" "gvim --role notes ~/Documents/notes.txt" (role =? "notes") doFloat
    ] where role = stringProperty "WM_WINDOW_ROLE"

myManageHook = composeAll
    [ className =? "Gimp"      --> doFloat
    , className =? "Vncviewer" --> doFloat
    , title =? "pterm Reconfiguration" --> doFloat
    , isFullscreen --> doFullFloat
    ]

myLayout = avoidStruts $ smartBorders $ ResizableTall 1 (3/100) (2/3) [] ||| Full

main = do
    xmproc <- spawnPipe "/usr/bin/xmobar $HOME/.xmonad/xmobar.rc"
    xmonad $ defaultConfig
        { manageHook = myManageHook <+> manageDocks <+> namedScratchpadManageHook scratchpads <+>
            (fmap not isDialog --> doF avoidMaster) <+> manageHook defaultConfig
        , layoutHook = myLayout
        , handleEventHook = fullscreenEventHook
        , logHook = dynamicLogWithPP xmobarPP
                        { ppOutput = hPutStrLn xmproc
                        , ppTitle = xmobarColor "green" "" . shorten 100
                        }
        , modMask = mod4Mask     -- Rebind Mod to the win key
        , terminal = "pterm"
        } `additionalKeys`
        [ ((mod4Mask .|. shiftMask, xK_z), spawn "/usr/bin/gnome-screensaver-command -l")
        , ((mod4Mask, xK_a), sendMessage MirrorShrink) -- adjust window height
        , ((mod4Mask, xK_z), sendMessage MirrorExpand)
        , ((mod4Mask .|. shiftMask, xK_i), spawn "/usr/bin/fetchotp -x")
        , ((mod4Mask .|. shiftMask, xK_q), quitWithWarning)
        , ((mod4Mask, xK_c), spawn "$HOME/bin/clip-to-chrome.sh")
        , ((mod4Mask, xK_b), sendMessage ToggleStruts) -- toggle xmobar
        , ((0, xF86XK_AudioLowerVolume), spawn "/usr/bin/amixer set Master 2dB-") -- adjust volume
        , ((0, xF86XK_AudioRaiseVolume), spawn "/usr/bin/amixer set Master 2dB+")
        , ((0, xF86XK_AudioMute), spawn "/usr/bin/amixer set Master toggle")
        , ((0, xF86XK_Launch1), spawn "/usr/bin/sudo /usr/sbin/pm-suspend-hybrid & /usr/bin/gnome-screensaver-command -l") -- laptop blue button
        , ((0, xK_Print), spawn "/usr/bin/gnome-screenshot; notify-send 'screenshot captured'") -- screenshots
        , ((controlMask, xK_Print), spawn "/usr/bin/gnome-screenshot -i")
        , ((mod4Mask .|. controlMask, xK_n), do -- quick note taking
                     spawn ("date>>"++"$HOME/Documents/notes.txt")
                     appendFilePrompt defaultXPConfig "/home/zigdon/Documents/notes.txt")
        , ((mod4Mask .|. shiftMask, xK_n), namedScratchpadAction scratchpads "notes" )

        ]
