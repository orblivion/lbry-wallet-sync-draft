# Server Operations

The server is not to be trusted by the clients. Synchronization issuses will be the responsibility of the clients alone. If the server aids in synchronization process (paying attention to sequence number, etc), it should only be considered an optimization by the clients, not relied on as a source of truth.

Questions of baseline versions for merging will be the responsibility of the clients. We can't trust the server to tell us what the baseline versions are.

    register

      Register a new account

      params: id, password, version
      response: authToken
      errors: version not supported, id already exists

    oauth

      Support the standard Oauth flows. We'll probably integrate with existing IDP project

    getWallet

      Get the current wallet data

      params: authToken
      response: version, encryptedWallet, sequence
      errors: invalid authToken

    putWallet

      Store new wallet data

      NOTE: Consider if making putWallet a locking call could optimize sync

      NOTE: We may need to save versons per-device to facilitate syncing
      NOTE: If so, likely we want putWallet to fail if the saved wallet is of earlier version *per-device*

      params: authToken, version, encryptedWallet, sequence
      response: ok
      errors: invalid authToken, version not supported, sequence mismatch

    changePassword

      This is the same as a putWallet, but also changes the loginKey.

      params: authToken, version, loginKey, encryptedWallet, sequence
      response: ok
      errors: invalid authToken, version not supported, sequence mismatch

# State Constructors

As we model state transitions, how do we represent the state of a device or an account on a backup server?

The idea here is that a state is a function of certain independent inputs that may or may not be retrievable based on its outputs. For instance, `encryptedWallet` is a function of `wallet` and `walletKey`. `walletKey` is a function of `password`. A server has access to an `encryptedWallet`, but not the `password` nor the `wallet` that produced it. However the state of the server is still a _function of_ the `wallet` and `pasword` (and other inputs) so we describe it as such.

By contrast, some inputs such as `sequence` are used directly as outputs.

Another benefit of this approach is that there could be two different outputs that depend on the same input. For example, `wallet` -> `encryptedWallet`, `wallet` -> `loginPrivateKey` -> `signature`. This allows us to think in more functional terms as inputs (such as `password`) change.

## Inputs

* `wallet` - Plaintext private user data. May include seed phrases, private keys, app info, settings, etc.
* `sequence` - A counter that is incremented every time a wallet is updated.
  - This prevents race conditions where multiple simultaneous writes overwrite one another.
  - TODO - Also update on password change?
* `timestamp` - Timestamp on device when and where the given walletState was created
  - Included because it may be helpful for conflict resolution. Maybe we don't need it.
* `sourceDeviceId` - DeviceId where the given walletState was created
  - Included because it may be helpful for conflict resolution. Maybe we don't need it.
* `password` - Used only as an input to generate `walletKey` and `downloadKey`
  - It can be discarded from memory once it does.
  - `walletKey` should only ever be in memory.
      - Writing it to disk would be tantamount to not encrypting the wallet on disk
      - We need to enter password on app startup to put it in memory.
          - TODO - This is probably a non-starter but I don't know how to avoid requiring password on startup and still be secure. Maybe there's something better.
  - `downloadKey` is only needed when 1) installing the application on a new device or 2) changing password
      - Both uses happen right after entering password, so it can be discarded from memory immediately after.
* `authToken`
  - Time limited
  - Can perhaps be saved to device disk to reduce need for entering password
  - Would be of rather limited use without `walletKey`. We can check for sync updates, but could not apply them because we can't decrypt wallet.
  
## Functions

These are functions that output part of a device or server account state.

A `walletState` is considered trustworthy so long as the signature is valid, because forging a signature would require a compromise of either decrypted wallet or password. It may still be invalid in some way due to a faulty client, but the signature should limit the range of potential problems to that.


    walletState(wallet, sequence, timestamp, sourceDeviceId, password)
      wKey = walletKey(password)
      encryptedWallet = encrypt(wKey, password)

      // Validate walletState updates based on loginPublicKey when the user already has a wallet on the device
      // TODO - maybe `signature` isn't useful now that we have `recoverySignature` below?
      signature = sign(
        encryptedWallet + sequence + timestamp + sourceDeviceId,
        wallet.loginPrivateKey
      )

      // Validate walletState based on a password-derived key when the user is restoring to a freshly installed client
      recoverySignature = sign(
        encryptedWallet + sequence + timestamp + sourceDeviceId,
        wKey // or some other password-derived key
      )

      return {
        encryptedWallet,
        sequence,
        timestamp,
        sourceDevId,
        signature,
        recoverySignature,
      }
   
    downloadKey(password)
      wKey, dKey = KDF(password)
      return dKey
   
    walletKey(password)
      wKey, dKey = KDF(password)
      return wKey

## Client Device

A device has a walletState (saved to file, sent over the wire). It also has a decrypted wallet (at least sometimes in memory) for various LBRY functions, and also for access to loginPrivateKey and loginPublicKey.

    Device(wallet, sequence, timestamp, sourceDeviceId, password, authToken)
      return {
        walletState(wallet, sequence, timestamp, sourceDeviceId, password),
        wallet,
        walletKey(password),
        authToken,
      }

## Account on Server:

This represents the _account of the user in question_ on a server.

The server doesn't have access to wallet, even though it has walletState. Thus, loginPublicKey (the primary key for the account) must be a separate element.

    Server(wallet, sequence, timestamp, sourceDeviceId, password, authToken, loginPublicKey)
      return {
        loginPublicKey,
        walletState(wallet, sequence, timestamp, sourceDeviceId, password),
        authToken,
      }

## Auth Server:

    AuthServer(password, authToken, loginPublicKey)
      return {
        downloadKey(password),
        authToken,
      }

### TODO - fix the above

  Per Github: An auth request (login or password change) contains:

      loginPublicKey (user ID)
      downloadKey
      domain (prevent reuse elsewhere)
      timestamp (prevent reuse later)
      (probably other stuff)
      Signature of the above using loginPrivateKey


# Message Constructors

These are functions that generate messages that are sent over rpcs.

    register(wallet, password)
      walletKey, downloadKey = KDF(password)
      wallet.loginPublicKey
      signature = sign(wallet.loginPublicKey + downloadKey, wallet.loginPrivateKey)
      return {
        loginPublicKey,
        downloadKey,
        signature,
      }

      TODO - getWallet

      TODO - putWallet

      TODO - putDownloadKey

# Flows

## Initial Setup

*State: First Install*

    device     = Device()
    authserver = AuthServer()
    server     = Server()

*Transition: create wallet*

*State: Wallet Local Only*

    device     = Device(wallet, sequence=0, timestamp, sourceDeviceId, password, authToken=null)
    authserver = AuthServer()
    server     = Server()

*Transition: rpc(register(device.wallet, password))*

*State: Registered, Wallet Not Uploaded*

    device     = Device(wallet, sequence=0, timestamp, sourceDeviceId, password, authToken)
    authserver = AuthServer(password, authToken, loginPublicKey)
    server     = Server()

*Transition: rpc(putWallet(device.walletState))*

*State: In Sync*

    device = Device(wallet, sequence=0, timestamp, sourceDeviceId, password, authToken)
    authserver = AuthServer(password, authToken, loginPublicKey)
    server = Server(wallet, sequence=0, timestamp, sourceDeviceId, password, authToken, loginPublicKey)

## Set Up Additional Device - Successful:

(note: this may end up being identical to account recovery)

TODO - flow

## Set Up Additional Device - Outdated Wallet:

Installed, but outdated.

TODO - flow

## Set Up Additional Device - Unauthenticated Wallet:

*Bookmark*. Complicated Edge Case.

## Set Up Additional Device - Corrupted Wallet:

*Bookmark*. Complicated Edge Case.

Wallet created by a bad but not compromised client

## Account Recovery - Successful:

TODO - flow

## Account Recovery - Outdated Wallet:

TODO - flow

Installed, but outdated.

## Account Recovery - Unauthenticated Wallet:

*Bookmark*. Complicated Edge Case.

## Account Recovery - Corrupted Wallet:

*Bookmark*. Complicated Edge Case.

Wallet created by a bad but not compromised client

## Get Wallet - No Changes

*State: In Sync*

    device = Device(wallet, sequence, timestamp, sourceDeviceId, password, authToken)
    server = Server(wallet, sequence, timestamp, sourceDeviceId, password, authToken, loginPublicKey)

*Transition: rpc(getWallet())*

*State: In Sync*

(sequence is the same, no change made)

    device = Device(wallet, sequence, timestamp, sourceDeviceId, password, authToken)
    server = Server(wallet, sequence, timestamp, sourceDeviceId, password, authToken, loginPublicKey)

## Get Wallet - Updated Wallet

*State: Device Wallet Out of Date*

    device = Device(wallet=w1, sequence=s,     timestamp=t0,     sourceDeviceId, password, authToken)
    server = Server(wallet=w2, sequence=s + 1, timestamp=t0 + t, sourceDeviceId, password, authToken, loginPublicKey)

*Transition: rpc(getWallet())*

*State: In Sync*

    device = Device(wallet=w2, sequence=s + 1, timestamp=t0 + t, sourceDeviceId, password, authToken)
    server = Server(wallet=w2, sequence=s + 1, timestamp=t0 + t, sourceDeviceId, password, authToken, loginPublicKey)

## Get Wallet - Downgraded Wallet

*State: Server Wallet Out of Date*

    device = Device(wallet=w1, sequence=s,     timestamp=t0,     sourceDeviceId, password, authToken)
    server = Server(wallet=w2, sequence=s - 1, timestamp=t0 - t, sourceDeviceId, password, authToken, loginPublicKey)

*Transition: rpc(getWallet())*

*State: Server Wallet Out of Date*

(New wallet is older. No update happens.)

    device = Device(wallet=w1, sequence=s,     timestamp=t0,     sourceDeviceId, password, authToken)
    server = Server(wallet=w2, sequence=s - 1, timestamp=t0 - t, sourceDeviceId, password, authToken, loginPublicKey)

## Get Wallet - Unauthenticated Wallet

*Bookmark*. Complicated Edge Case.

## Get Wallet - Corrupted Wallet

*Bookmark*. Complicated Edge Case.

Wallet created by a bad but not compromised client

## Sync - Conflict

TODO - Actually, we need to figure out how different clients handle versions before we worry about how the server will behave or even what it needs to be storing. See [the sync document](sync.md) for that. This section as currently written may not be very useful in the end.

### Summary

* Server sequence=s-1
* Client 1 made change, sequence=s
* Client 2 made change, sequence=s
* Client 1 pushes change sequence=s
* Client 2 pushes change sequence=s - fail because s=s
* Client 2 pulls sequence=s
* Client 2 resolves change to sequence=s+1
* Client 2 pushes back sequence=s+1
* Client 1 pulls sequence=s+1

### Detail

*State: Devices in Conflict*

-- TODO - device and server is a M2M relationship. Each should have a list of authTokens rather than just one

    device1 = Device(wallet=w1, sequence=s,     timestamp=t0 + t1, sourceDeviceId=d1, password, authToken)
    device2 = Device(wallet=w2, sequence=s,     timestamp=t0 + t2, sourceDeviceId=d2, password, authToken)
    server =  Server(wallet=w3, sequence=s - 1, timestamp=t0,      sourceDeviceId,    password, authToken, loginPublicKey)

*Transition: device1.rpc(putWallet(wallet=w1, sequence=s, timestamp=t0 + t1, sourceDeviceId=d1, password, authToken))*

*State: Server and One Device in Conflict*

    device1 = Device(wallet=w1, sequence=s, timestamp=t0 + t1, sourceDeviceId=d1, password, authToken)
    device2 = Device(wallet=w2, sequence=s, timestamp=t0 + t2, sourceDeviceId=d2, password, authToken)
    server =  Server(wallet=w1, sequence=s, timestamp=t0 + t1, sourceDeviceId=d1, password, authToken, loginPublicKey)

*Transition: device2.rpc(putWallet(wallet=w2, sequence=s, timestamp=t0 + t2, sourceDeviceId=d2, password, authToken))*

Failure: Server rejects: already has sequence=s

*State: Server and One Device in Conflict*

    device1 = Device(wallet=w1, sequence=s, timestamp=t0 + t1, sourceDeviceId=d1, password, authToken)
    device2 = Device(wallet=w2, sequence=s, timestamp=t0 + t2, sourceDeviceId=d2, password, authToken)
    server =  Server(wallet=w1, sequence=s, timestamp=t0 + t1, sourceDeviceId=d1, password, authToken, loginPublicKey)

*Transition: device2.rpc(getWallet())*

Device 2 gets w1 from the server. It has the same sequence (`s`) as its current wallet w2, so we do conflict resolution.

*State: Server Wallet and One Device Wallet Out of Date*

-- TODO - need to add baseline wallet/sequence to the state for comparison for conflict revolution. this isn't a trivial task.

    w4 = conflict_resolution(w1, w2)
    device1 = Device(wallet=w1, sequence=s,     timestamp=t0 + t1, sourceDeviceId=d1, password, authToken)
    device2 = Device(wallet=w4, sequence=s + 1, timestamp=t0 + t3, sourceDeviceId=d2, password, authToken)
    server =  Server(wallet=w1, sequence=s,     timestamp=t0 + t1, sourceDeviceId=d1, password, authToken, loginPublicKey)

*Transition: device1.rpc(putWallet(wallet=w4, sequence=s + 1, timestamp=t0 + t3, sourceDeviceId=2, password, authToken))*

*State: Device Wallet Out of Date*

    w4 = conflict_resolution(w1, w2)
    device1 = Device(wallet=w1, sequence=s,     timestamp=t0 + t1, sourceDeviceId=d1, password, authToken)
    device2 = Device(wallet=w4, sequence=s + 1, timestamp=t0 + t3, sourceDeviceId=d2, password, authToken)
    server =  Server(wallet=w4, sequence=s + 1, timestamp=t0 + t3, sourceDeviceId=d2, password, authToken, loginPublicKey)

*Transition: device2.rpc(getWallet())*

*State: In Sync*

(Note that device1 has sourceDeviceId=d2 because that's the source of that walletState)

    w4 = conflict_resolution(w1, w2)
    device1 = Device(wallet=w4, sequence=s + 1, timestamp=t0 + t3, sourceDeviceId=d2, password, authToken)
    device2 = Device(wallet=w4, sequence=s + 1, timestamp=t0 + t3, sourceDeviceId=d2, password, authToken)
    server =  Server(wallet=w4, sequence=s + 1, timestamp=t0 + t3, sourceDeviceId=d2, password, authToken, loginPublicKey)

## Sync - Corrupted Sequence

*Bookmark*. Complicated Edge Case.

Sequence created by a bad but not compromised client.

Sets sequence to +1000: How does this play out with the client who is getting this wallet? Probably fine, this client just accepts the new sequence and does a sync as usual.

Sets sequence to -1000: How does this play out with the client who is getting this wallet?

What if sequence is close to int(max)? Maybe there should be some sort of failsafe that doesn't accept such sequence values. But what to do in such a case?

## Sync - Unauthenticated Wallet

*Bookmark*. Complicated Edge Case.

## Sync - Corrupted Wallet

Wallet created by a bad but not compromised client

*Bookmark*. Complicated Edge Case.

## Change Password - Evil Server

What if the server refuses to acknowledge your password change in the downloadKey and/or the wallet? Would this be worse than having no server at all?

*Bookmark*. Complicated Edge Case.

## Put Wallet - No Change

*State: In Sync*

    device = Device(wallet, sequence, timestamp, sourceDeviceId, password, authToken)
    server = Server(wallet, sequence, timestamp, sourceDeviceId, password, authToken, loginPublicKey)

*Transition: rpc(putWallet(wallet, sequence, timestamp, sourceDeviceId, password, authToken))*

*State: In Sync*

(sequence is the same, no change made)

    device = Device(wallet, sequence, timestamp, sourceDeviceId, password, authToken)
    server = Server(wallet, sequence, timestamp, sourceDeviceId, password, authToken, loginPublicKey)

## Put Wallet - Updated Wallet

*State: Device Wallet Out of Date*

    device = Device(wallet=w1, sequence=s + 1, timestamp=t0 + t, sourceDeviceId, password, authToken)
    server = Server(wallet=w2, sequence=s,     timestamp=t0,     sourceDeviceId, password, authToken, loginPublicKey)

*Transition: rpc(putWallet(wallet, sequence=s + 1, timestamp=t0 + t, sourceDeviceId, password, authToken))*

*State: In Sync*

    device = Device(wallet=w1, sequence=s + 1, timestamp=t0 + t, sourceDeviceId, password, authToken)
    server = Server(wallet=w1, sequence=s + 1, timestamp=t0 + t, sourceDeviceId, password, authToken, loginPublicKey)

## Put Wallet - Downgraded Wallet

*State: Server Wallet Out of Date*

    device = Device(wallet=w1, sequence=s,     timestamp=t0,     sourceDeviceId, password, authToken)
    server = Server(wallet=w2, sequence=s - 1, timestamp=t0 - t, sourceDeviceId, password, authToken, loginPublicKey)

*Transition: rpc(putWallet(wallet=w1, sequence=s - 1, timestamp=t0, sourceDeviceId, password, authToken))*

*State: Server Wallet Out of Date*

(New wallet is older. No update happens.)

    device = Device(wallet=w1, sequence=s,     timestamp=t0,     sourceDeviceId, password, authToken)
    server = Server(wallet=w2, sequence=s - 1, timestamp=t0 - t, sourceDeviceId, password, authToken, loginPublicKey)

## Change Password - Basic

*State: In Sync*

    device =     Device(wallet, sequence, timestamp, sourceDeviceId, password=p1, authToken)
    server =     Server(wallet, sequence, timestamp, sourceDeviceId, password=p1, authToken, loginPublicKey)
    authserver = AuthServer(password=p1, authToken, loginPublicKey)

*Transition: Encrypt Wallet with New Password*

*State: Server Password and AuthServer Password Out of Date*

    device =     Device(wallet, sequence, timestamp, sourceDeviceId, password=p2, authToken)
    server =     Server(wallet, sequence, timestamp, sourceDeviceId, password=p1, authToken, loginPublicKey)
    authserver = AuthServer(password=p1, authToken, loginPublicKey)

*Transition: rpc(putWallet(wallet, sequence, timestamp, sourceDeviceId, password=p2, authToken))*

*State: AuthServer Password Out of Date*

    device =     Device(wallet, sequence, timestamp, sourceDeviceId, password=p2, authToken)
    server =     Server(wallet, sequence, timestamp, sourceDeviceId, password=p2, authToken, loginPublicKey)
    authserver = AuthServer(password=p1, authToken, loginPublicKey)

*Transition: rpc(putDownloadKey(password=p2))*

*State: In Sync*

    device =     Device(wallet, sequence, timestamp, sourceDeviceId, password=p2, authToken)
    server =     Server(wallet, sequence, timestamp, sourceDeviceId, password=p2, authToken, loginPublicKey)
    authserver = AuthServer(password=p2, authToken, loginPublicKey)

## Change Password - While Registering New Device

-- TODO a complicated scenario wherein a new device is confused by another device in the middle of updating its password:

 * D2 - Install
 * D1 - change walletKey locally
 * D1 - putWallet
 * D2 - use old password: can't log in
 * D2 - use new password: logged in
 * D2 - getWallet - can't decrypt. retrying in a few...
 * D1 - updatePassword - new downloadKey
 * D2 - getWallet - success

## Change Password - Evil Server

What if the server refuses to acknowledge your password change in the downloadKey and/or the wallet? Would this be worse than having no server at all?

*Bookmark*. Complicated Edge Case.

## Switch Servers

TODO - flow

## Two Servers

TODO - flow
