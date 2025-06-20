{-# LANGUAGE DataKinds           #-}
{-# LANGUAGE NoImplicitPrelude   #-}
{-# LANGUAGE TemplateHaskell     #-}
{-# LANGUAGE OverloadedStrings   #-}

module Main where

import Cardano.Api.Shelley (PlutusScript (PlutusScriptSerialised))
import Cardano.Api
import PlutusLedgerApi.V3
import PlutusTx.Prelude
import PlutusTx
import Prelude (IO, putStrLn, show)

import DFCT.Governance

-- replace with policy id
dfcSymbol :: CurrencySymbol
dfcSymbol = CurrencySymbol "ba620a995810f982de2a8994901335bda7fa041eeec1ae32dc57edfa"

{-# INLINABLE mkWrappedGV #-}
mkWrappedGV :: BuiltinData -> BuiltinUnit
mkWrappedGV ctx = mkGovernanceValidator dfcSymbol ctx

gValidator :: CompiledCode (BuiltinData -> BuiltinUnit)
gValidator = $$(PlutusTx.compile [|| mkWrappedGV ||])

genGV3Script :: PlutusScript PlutusScriptV3
genGV3Script = PlutusScriptSerialised $ serialiseCompiledCode gValidator

main :: IO ()
main = do
  result <- writeFileTextEnvelope "dfct-governance.plutus" Nothing genGV3Script
  case result of
    Left err -> putStrLn $ "Error writing script: " ++ show err
    Right () -> putStrLn "Successfully wrote dfct-governance.plutus"