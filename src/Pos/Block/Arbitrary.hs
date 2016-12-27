{-# LANGUAGE FlexibleContexts     #-}
{-# LANGUAGE FlexibleInstances    #-}
{-# LANGUAGE StandaloneDeriving   #-}
{-# LANGUAGE UndecidableInstances #-}

module Pos.Block.Arbitrary () where

import           Test.QuickCheck           (Arbitrary (..), Gen, oneof)
import           Universum

import           Pos.Binary                (Bi)
import           Pos.Block.Network         as T
import           Pos.Crypto                (Hash)
import           Pos.Merkle                (MerkleRoot (..), MerkleTree, mkMerkleTree)
import           Pos.Ssc.Class.Types       (Ssc (..))
import qualified Pos.Types                 as T
import           Pos.Util                  (Raw, makeSmall)

------------------------------------------------------------------------------------------
-- Arbitrary instances for Blockchain related types
------------------------------------------------------------------------------------------

instance (Arbitrary (SscProof ssc), Bi Raw, Ssc ssc) =>
    Arbitrary (T.BlockSignature ssc) where
    arbitrary = oneof [ T.BlockSignature <$> arbitrary
                      , T.BlockPSignature <$> arbitrary
                      ]

------------------------------------------------------------------------------------------
-- GenesisBlockchain
------------------------------------------------------------------------------------------

instance Ssc ssc => Arbitrary (T.GenesisBlockHeader ssc) where
    arbitrary = T.GenericBlockHeader
        <$> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary

instance Arbitrary (T.BodyProof (T.GenesisBlockchain ssc)) where
    arbitrary = T.GenesisProof <$> arbitrary

instance Arbitrary (T.ConsensusData (T.GenesisBlockchain ssc)) where
    arbitrary = T.GenesisConsensusData
        <$> arbitrary
        <*> arbitrary

instance Arbitrary (T.Body (T.GenesisBlockchain ssc)) where
    arbitrary = T.GenesisBody <$> arbitrary

instance Ssc ssc => Arbitrary (T.GenericBlock (T.GenesisBlockchain ssc)) where
    arbitrary = T.GenericBlock
        <$> arbitrary
        <*> arbitrary
        <*> arbitrary

------------------------------------------------------------------------------------------
-- MainBlockchain
------------------------------------------------------------------------------------------

instance Bi Raw => Arbitrary (MerkleRoot T.Tx) where
    arbitrary = MerkleRoot <$> (arbitrary :: Gen (Hash Raw))

instance Arbitrary (MerkleTree T.Tx) where
    arbitrary = mkMerkleTree <$> arbitrary

instance (Arbitrary (SscProof ssc), Bi Raw, Ssc ssc) =>
    Arbitrary (T.MainBlockHeader ssc) where
    arbitrary = T.GenericBlockHeader
        <$> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary

instance (Arbitrary (SscProof ssc), Bi Raw) =>
    Arbitrary (T.BodyProof (T.MainBlockchain ssc)) where
    arbitrary = T.MainProof
        <$> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary

instance (Arbitrary (SscProof ssc), Bi Raw, Ssc ssc) =>
    Arbitrary (T.ConsensusData (T.MainBlockchain ssc)) where
    arbitrary = T.MainConsensusData
        <$> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary

instance Arbitrary (SscPayload ssc) => Arbitrary (T.Body (T.MainBlockchain ssc)) where
    arbitrary = makeSmall $ do
        (txs,txIns) <- unzip <$> (arbitrary :: Gen [(T.Tx, T.TxWitness)])
        sscPayload <- arbitrary
        return $ T.MainBody (mkMerkleTree txs) txIns sscPayload

instance (Arbitrary (SscProof ssc), Arbitrary (SscPayload ssc), Ssc ssc) =>
    Arbitrary (T.GenericBlock (T.MainBlockchain ssc)) where
    arbitrary = T.GenericBlock
        <$> arbitrary
        <*> arbitrary
        <*> arbitrary

------------------------------------------------------------------------------------------
-- Block network types
------------------------------------------------------------------------------------------

instance Ssc ssc => Arbitrary (T.MsgGetHeaders ssc) where
    arbitrary = T.MsgGetHeaders
        <$> arbitrary
        <*> arbitrary

instance Ssc ssc => Arbitrary (T.MsgGetBlocks ssc) where
    arbitrary = T.MsgGetBlocks
        <$> arbitrary
        <*> arbitrary

instance (Arbitrary (SscProof ssc), Bi Raw, Ssc ssc) => Arbitrary (T.MsgHeaders ssc) where
    arbitrary = T.MsgHeaders <$> arbitrary

instance (Arbitrary (SscProof ssc), Arbitrary (SscPayload ssc), Ssc ssc) =>
    Arbitrary (T.MsgBlock ssc) where
    arbitrary = T.MsgBlock <$> arbitrary
