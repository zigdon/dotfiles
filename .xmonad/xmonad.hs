import XMonad
import XMonad.Actions.CopyWindow
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Layout.NoBorders
import XMonad.Layout.ResizableTile
import XMonad.Layout.ThreeColumns
import XMonad.Prompt
import XMonad.Prompt.AppendFile
import XMonad.Util.Dmenu
import XMonad.Util.EZConfig(additionalKeys)
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.NamedScratchpad
import XMonad.Hooks.UrgencyHook

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
    , className =? "gnubby_ssh_prompt" --> doRectFloat (W.RationalRect 0.35 0.3 0.3 0.2)
    , appName =? "crx_knipolnnllmklapflnccelgolnpehhpl" --> doFloat -- Hangout windows
    , title =? "Terminator Preferences" --> doFloat
    , title =? "Page(s) Unresponsive" --> doFloat
    , isFullscreen --> doFullFloat
    ]

myResizable = ResizableTall 1 (3/100) (2/3) []
myThree = ThreeCol 1 (3/100) (1/2)
myLayout = avoidStruts $ smartBorders $ myResizable ||| noBorders Full ||| myThree

main = do
    xmproc <- spawnPipe "/usr/bin/xmobar $HOME/.xmonad/xmobar.rc"
    xmonad $ withUrgencyHook NoUrgencyHook defaultConfig
        { manageHook = myManageHook <+> manageDocks <+> namedScratchpadManageHook scratchpads <+>
            (fmap not isDialog --> doF avoidMaster) <+> manageHook defaultConfig
        , layoutHook = myLayout
        , handleEventHook = fullscreenEventHook
        , logHook = dynamicLogWithPP xmobarPP
                        { ppOutput = hPutStrLn xmproc
                        , ppTitle = xmobarColor "green" "" . shorten 100
                        }
        , modMask = mod4Mask     -- Rebind Mod to the win key
        , terminal = "terminator"
        } `additionalKeys`
        [ ((mod4Mask .|. shiftMask, xK_z), spawn "/usr/bin/gnome-screensaver-command -l")
        , ((mod4Mask, xK_a), sendMessage MirrorShrink) -- adjust window height
        , ((mod4Mask, xK_z), sendMessage MirrorExpand)
        , ((mod4Mask, xK_g), focusUrgent)
        , ((mod4Mask .|. shiftMask, xK_q), quitWithWarning)
        , ((mod4Mask, xK_o), spawn "$HOME/bin/logouts.sh")
        , ((mod4Mask, xK_c), spawn "$HOME/bin/clip-to-chrome.sh")
        , ((mod4Mask, xK_u), spawn "$HOME/bin/puburl.sh")
        , ((mod4Mask, xK_b), sendMessage ToggleStruts) -- toggle xmobar
        , ((mod4Mask .|. controlMask, xK_t), spawn "$HOME/bin/touchpad_enable.sh 1") -- enable touchpad
        , ((mod4Mask .|. shiftMask, xK_t), spawn "$HOME/bin/touchpad_enable.sh 0") -- disable touchpad
        , ((0, xF86XK_AudioLowerVolume), spawn "/usr/bin/amixer set Master 2dB-") -- adjust volume
        , ((0, xF86XK_AudioRaiseVolume), spawn "/usr/bin/amixer set Master 2dB+")
        , ((0, xF86XK_AudioMute), spawn "/usr/bin/amixer set Master toggle")
        , ((0, xF86XK_Launch1), spawn "$HOME/bin/suspend") -- laptop blue button
        , ((0, xK_Print), spawn "/usr/bin/gnome-screenshot; notify-send 'screenshot captured'") -- screenshots
        , ((controlMask, xK_Print), spawn "/usr/bin/gnome-screenshot -i")
        , ((mod4Mask .|. controlMask, xK_n), do -- quick note taking
                     spawn ("date>>"++"$HOME/Documents/notes.txt")
                     appendFilePrompt defaultXPConfig "/home/zigdon/Documents/notes.txt")
        , ((mod4Mask .|. shiftMask, xK_n), namedScratchpadAction scratchpads "notes" )

        -- mod-a copy to all
        -- mod-shift-a remove from all but current
        , ((mod4Mask .|. controlMask, xK_a ), windows copyToAll)
        , ((mod4Mask .|. shiftMask, xK_a ), killAllOtherCopies)
        ]
