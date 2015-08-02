module Rules (
    oracleRules, cabalRules, configRules, packageRules, generateTargets
    ) where

import Base
import Util
import Stage
import Expression
import Rules.Cabal
import Rules.Config
import Rules.Package
import Rules.Oracles
import Rules.Resources
import Settings.Packages
import Settings.TargetDirectory

-- generateTargets needs package-data.mk files of all target packages
generateTargets :: Rules ()
generateTargets = action $ do
    targets <- fmap concat . forM [Stage0 ..] $ \stage -> do
        pkgs <- interpret (stageTarget stage) getPackages
        fmap concat . forM pkgs $ \pkg -> return
            [ targetPath stage pkg -/- "build/haskell.deps"
            , targetPath stage pkg -/- "build/c.deps" ]
    need targets

-- TODO: add Stage2 (compiler only?)
packageRules :: Rules ()
packageRules = do
    resources <- resourceRules
    forM_ [Stage0, Stage1] $ \stage -> do
        forM_ knownPackages $ \pkg -> do
            buildPackage resources (stagePackageTarget stage pkg)
