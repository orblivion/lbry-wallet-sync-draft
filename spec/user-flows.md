# Initial Setup

![](user-flows-diagrams/diagram-1.svg)

<details><summary>source</summary>

<!-- I don't know why `direction RL` within the subgraphs makes it go top-down.
     TD doesn't. Maybe it's a bug that they'll fix in which case we'll need to
     change these to TD. -->

```mermaid
flowchart TD
  classDef start fill:#8f8;
  classDef finish fill:#f88;
  LoggedOutHomeScreen:::start
  LoggedInHomeScreen:::finish
  Login:::finish

  LoggedOutHomeScreen --<big><b>Log In / Sign Up</b></big>--> Signup
  Signup --<big><b>Sign Up</b></big> - <i>Success</i>--> LoggedInHomeScreen
  Signup --<big><b>I already have an account</b></big>--> Login

  Signup --<big><b>Sign Up</b></big> - <i>Bad Credentials</i>--> SignupErrorCredentials
  SignupErrorCredentials --<big><b>Try Again</b></big>--> Signup

  Signup --<big><b>Sign Up</b></big> - <i>Email Exists On Server</i>--> SignupErrorEmailExists
  SignupErrorEmailExists --<big><b>Sign up with a different email address</b></big>--> Signup
  SignupErrorEmailExists --<big><b>Log In Instead</b></big>--> Login

  Signup --<big><b>Sign Up</b></big> - <i>Wallet PubKey Exists On Server with different Email</i>--> SignupErrorPubKeyExists
  SignupErrorPubKeyExists --<big><b>Log In Instead</b></big>--> Login

  Signup --<big><b>Sign Up</b></big> - <i>Wallet PubKey Email Pair Exists On Server</i>--> SignupErrorPubKeyEmailExists
  SignupErrorPubKeyEmailExists --<big><b>Log In Instead</b></big>--> Login

  subgraph LoggedOutHomeScreen
    direction RL
    LoggedOutHomeScreen1[<h3>Trending Videos</h3>]
    LoggedOutHomeScreen2[<h3>Buttons</h3><ul><li>Log In / Sign Up</li></ul>]
  end

  subgraph LoggedInHomeScreen
    direction RL
    LoggedInHomeScreen1[<h3>Logged In Home Screen</h3>...]
  end

  subgraph Login
    direction RL
    Login1[<h3>Log In</h3>...]
  end

  subgraph SignupErrorPubKeyEmailExists
    direction RL
    SignupErrorPubKeyEmailExists1[<h3>Error</h3>An account with your wallet and this email already exists]
    SignupErrorPubKeyEmailExists2[<h3>Buttons</h3><ul><li>Log In Instead</li></ul>]
  end

  subgraph SignupErrorEmailExists
    direction RL
    SignupErrorEmailExists1[<h3>Error</h3>This email already exists on this server]
    SignupErrorEmailExists2[<h3>Buttons</h3><ul><li>Log In Instead</li><li>Sign up with a different email address</li></ul>]
  end

  subgraph Signup
    direction RL
    Signup1[<h3>Enter Credentials</h3><ul><li>Server</li><li>Email</li><li>Password</li></ul>]
    Signup2[<h3>Buttons</h3><ul><li>Sign Up</li></ul>]
    Signup2[<h3>Buttons</h3><ul><li>Sign Up</li><li>I already have an account</li></ul>]
    Signup3[<h3>Heads Up For User</h3><ul><li>Wallet goes on server, but it's encrypted<li>Don't lose your password! We have <b>no</b> recovery options without it.<li>Make your password strong. Don't trust the server!</ul>]
  end

  subgraph SignupErrorCredentials
    direction RL
    SignupErrorCredentials1[<h3>Error</h3><i>One of the following</i><ul><li> Server Invalid<li> Email Malformed<li> Password Not Good Enough</ul>]
    SignupErrorCredentials2[<h3>Buttons</h3><ul><li>Try Again</li></ul>]
  end


  subgraph SignupErrorPubKeyExists
    direction RL
    SignupErrorPubKeyExists1[<h3>Error</h3>An account with your wallet, but not the email you entered, already exists]
    SignupErrorPubKeyExists2[<h3>Note to user</h3>Change email later if you want, after you log in]
    SignupErrorPubKeyExists3[<h3>Buttons</h3><ul><li>Log In Instead</li></ul>]
  end
```



</details>

# Account Recovery

![](user-flows-diagrams/diagram-2.svg)

<details><summary>source</summary>

```mermaid
flowchart TD
  classDef start fill:#8f8;
  classDef finish fill:#f88;
  classDef editorNote fill:#CCC;
  Login:::start
  LoggedInHomeScreen:::finish
  LoggedOutHomeScreen:::finish
  MergeLoggedInLoggedOut3:::editorNote
  DataError3:::editorNote

  Login --<big><b>Log In</b></big> - <i>Existing pre-login local changes</i>--> MergeLoggedInLoggedOut
  Login --<big><b>Log In</b></big> - <i>Data Error<i>--> DataError
  Login --<big><b>Log In</b></big> - <i>No existing pre-login local changes</i>--> LoggedInHomeScreen

  MergeLoggedInLoggedOut --<big><b>Discard logged out changes</b></big>--> LoggedInHomeScreen
  MergeLoggedInLoggedOut --<big><b>Merge logged out changes</b></big>--> LoggedInHomeScreen
  MergeLoggedInLoggedOut --<big><b>Cancel login</b></big>--> LoggedOutHomeScreen

  subgraph LoggedInHomeScreen
    direction RL
    LoggedInHomeScreen1[...]
  end

  subgraph LoggedOutHomeScreen
    direction RL
    LoggedOutHomeScreen1[...]
  end

  subgraph MergeLoggedInLoggedOut
    direction RL
    MergeLoggedInLoggedOut1[<h3>Prompt</h3>Before you logged in, you took some actions that were saved to your wallet. Would you like to merge them?]
    MergeLoggedInLoggedOut2[<h3>Buttons</h3><ul><li>Discard logged out changes</li><li>Merge logged out changes</li><li>Don't log in for now</li></ul>]
    MergeLoggedInLoggedOut3[<i>this is a complicated part<br>this is unlike normal conflict resolution because the baseline is zero, and also the logged out wallet's keypair is discarded</i>]
  end

  subgraph DataError
    direction RL
    DataError1[<h3>Error</h3><i>One of the following</i><ul><li>Corrupt wallet JSON</li><li>Signature does not match</li><li>Sequence error</li></ul>]
    DataError2[<h3>Buttons</h3><ul><li>??? <i>TODO</i></li></ul>]
    DataError3[<i>this is a complicated part<br>This might be Error Recovery Mode, or Error Recovery Mode may be split off from here</i>]
  end

  subgraph Login
    direction RL
    Login1[<h3>Enter Credentials</h3><ul><li>Server</li><li>Email</li><li>Password</li></ul>]
    Login2[<h3>Buttons</h3><ul><li>Log In</li></ul>]
  end
```

</details>

# Set Up Additional Device

The only difference between this and Account Recovery is that there is another device connected somewhere. The one place this could change the flow is if that device pushes a change while this device is in the middle of MergeLoggedInLoggedOut.

![](user-flows-diagrams/diagram-3.svg)

<details><summary>source</summary>

```mermaid
flowchart TD
  classDef startGrey fill:#efe,stroke:#aea,color:#aea;
  classDef finishGrey fill:#fee,stroke:#eaa,color:#eaa;
  classDef editorNote fill:#CCC;
  Login:::startGrey
  Login1:::startGrey
  LoggedInHomeScreen:::finishGrey
  LoggedInHomeScreen1:::finishGrey
  LoggedOutHomeScreen:::finishGrey
  LoggedOutHomeScreen1:::finishGrey
  MergeLoggedInLoggedOut3:::editorNote

  Login --<font color='#aaa'>Log In - Existing pre-login local changes</font>--> MergeLoggedInLoggedOut

  MergeLoggedInLoggedOut --<font color='#aaa'>Discard logged out changes</font>--> LoggedInHomeScreen
  MergeLoggedInLoggedOut --<font color='#05f'><big><b>Merge logged out changes</b></big> - <i>success</i></font>--> LoggedInHomeScreen
  MergeLoggedInLoggedOut --<font color='#aaa'>Cancel login</font>--> LoggedOutHomeScreen

  MergeLoggedInLoggedOut --<font color='#05f'><big><b>Merge logged out changes</b></big> - <i>Other device pushed an update in the middle of merging</i></font>--> MergeLoggedInLoggedOut

  subgraph LoggedInHomeScreen
    direction RL
    LoggedInHomeScreen1[...]
  end

  subgraph LoggedOutHomeScreen
    direction RL
    LoggedOutHomeScreen1[...]
  end

  subgraph MergeLoggedInLoggedOut
    direction RL
    MergeLoggedInLoggedOut1[<h3>Prompt</h3>Before you logged in, you took some actions that were saved to your wallet. Would you like to merge them?]
    MergeLoggedInLoggedOut2[<h3>Buttons</h3><ul><li>Discard logged out changes</li><li>Merge logged out changes</li><li>Don't log in for now</li></ul>]
    MergeLoggedInLoggedOut3[<i>this is a complicated part<br>this is unlike normal conflict resolution because the baseline is zero, and also the logged out wallet's keypair is discarded</i>]
  end

  subgraph Login
    direction RL
    Login1[...]
  end
```

</details>

# Recover with existing wallet file

<!--

TODO - What if you have a wallet, copy it manually to a few devices, and then try to start the syncing? Make sure that it enters manual recovery mode, because we can't be sure that it's in sync without the metadata trail.

Though on the real - what we figure out whether to sync or not, or whatever, is:

* The unsynced change
* The walletstate before the new changes
* The walletstate on the server now (can pull to see)
* That's all. That's your merge.

The metadata is only to make sure that the server isn't lying about how much of the client's previous changes it has incorporated.

-->

# Make Logged In changes to wallet

![](user-flows-diagrams/diagram-4.svg)

<details><summary>source</summary>

```mermaid
classDiagram

LoggedInHomeScreen --|> LoggedInHomeScreen : Make Changes - Change committed to server
LoggedInHomeScreen --|> MergeChanges : Make Changes - Conflict on server
LoggedInHomeScreen --|> DataError : Periodic Get Wallet - Data Error
LoggedInHomeScreen --|> VisualHash : Check Visual Hash
VisualHash --|> LoggedInHomeScreen : Go Back

MergeChanges --|> MergeChanges : Commit Merge - Other device pushed an update during MergeChanges
MergeChanges --|> LoggedInHomeScreen : Commit Merge - Merge committed to server
MergeChanges --|> LoggedInHomeScreen : Commit Merge - Too many errors [network, etc], giving up for now
MergeChanges --|> DataError : Commit Merge - Data Error

MergeChanges : Merge changes that were made here and at least one other device without rebasing
MergeChanges : - this is a complicated part -
MergeChanges : Commit Merge()

LoggedInHomeScreen : Trending Videos
LoggedInHomeScreen : Make Changes()
LoggedInHomeScreen : Check Visual Hash()
LoggedInHomeScreen : Change Password()
LoggedInHomeScreen : Change Server()

DataError : ...

VisualHash : Confirm all of your devices are in sync
VisualHash : - visual hash -
VisualHash : GoBack()

```
</details>

# Change Password

Password changes will happen in the same line as other changes to the walletState:

* A password change (with no other changes) will add a new walletState with a new sequence.
* It will be necessary to pull the latest walletState before pushing a password change.

## If you are *initiating* a password change on a given device:

To simplify the flow, we don't allow the user to initiate a password change (A) on their device while that device has unmerged changes to their wallet. This way, if another device pushes a change (with the previous password), it can be trivially merged before applying the password change and pushing it back to the server.

However, if another device pushes a different password change (B), we have to cancel the password change (A) on this device. This is because we need the user to input password (B) first to decrypt the latest wallet. We can't just overwrite it with password (A) because the latest wallet may also have changes that we need to merge in. Though we interrupt the password change (A), we invite the user to change the password to (A) again later if they want, but we leave it to them.

## If you are *confirming* a password change created on another device:

Supposing the password is changed from (P) to (A) on another device, and the user gets a **password confirmation prompt** on this device.

If another device changes the password _again_ to (B) in the middle of the **password confirmation prompt**, we should be able to hide the complications from the user. The user probably expects password (B) to work, so that's what we will expect. This means that we will pull the wallet again _after_ the user enters their password to confirm that it decrypts.

If a third device also creates a change to the wallet it will have the password (B), assuming other clients are working correctly. This is because no clients will push until they've updated their own password to what's on the server. It won't have passwords (P) or (A). The only exception is if this third device also _initiates_ a new password change. In all, every wallet on the server should be assumed to be encrypted by the most recent password change initiation that is accepted by the server.

If there is a wallet change along with the password change, it can be merged in cleanly if there are no local changes. If there are local changes, they can be resolved with MergeChanges after password (B) is confirmed. If another device changes the password _again_ during the MergeChanges screen, the merge will fail simply because the wallet on the server is updated. The new wallet will be pulled, the device will see that the password doesn't match (B), and it will bring up the **password confirmation prompt** again. At this point it can safely discard password (B), because we no longer need the wallet encrypted by password (B). We have yet to make and push a successful merge, so our local baseline is still the wallet encrypted with password (P). All of the changes that we have yet to merge are in the wallet with password (C).

![](user-flows-diagrams/diagram-5.svg)

<details><summary>source</summary>

```mermaid
classDiagram

LoggedInHomeScreen --|> ChangePassword : Change Password - *only if no un-merged changes present*
ChangePassword --|> BadPassword : Submit - Bad Password
ChangePassword --|> ChangePasswordPreempted : Submit - Another device updated the password
ChangePasswordPreempted --|> ConfirmPassword : Accept New Password Instead
ChangePassword --|> LoggedInHomeScreen : Submit - Success
BadPassword --|> ChangePassword : Try Again

LoggedInHomeScreen --|> ConfirmPassword : Other device changes password
ConfirmPassword --|> ConfirmPassword : Other device changes password during ConfirmPassword
ConfirmPassword --|> IncorrectPassword : Submit - Incorrect
ConfirmPassword --|> LoggedInHomeScreen : Submit - Success
ConfirmPassword --|> MergeChanges : Submit - Success, but we've now decrypted changes that we need to merge
IncorrectPassword --|> ConfirmPassword : Try Again

MergeChanges --|> ConfirmPassword : Commit Merge - Other device changes password during MergeChanges
MergeChanges --|> LoggedInHomeScreen : Commit Merge - Merge committed to server

MergeChanges : ...

LoggedInHomeScreen : Trending Videos
LoggedInHomeScreen : Make Changes()
LoggedInHomeScreen : Check Visual Hash()
LoggedInHomeScreen : Change Password()
LoggedInHomeScreen : Change Server()

ChangePassword : Enter Credentials
ChangePassword : * [Password]
ChangePassword : Submit()

BadPassword : Password Not Good Enough
BadPassword : Try Again()

ChangePasswordPreempted : Looks like you changed your password on another device.
ChangePasswordPreempted : You need to enter this new password on this device to continue.
ChangePasswordPreempted : If you still would like to change your password using this device, do so afterwards.
ChangePasswordPreempted : Accept New Password Instead()

ConfirmPassword : Enter Credentials
ConfirmPassword : * [Password]
ConfirmPassword : Submit()

IncorrectPassword : Password Does Not Match
IncorrectPassword : Try Again()

```

</details>

# Turn On Application and Log In

There is an edge case when starting the app. If _both_ of the following are true:

* A password change is waiting on the server
* There are local _unmerged_ changes on the device

then the user will need to enter both their old and new passwords on startup. The old password will decrypt the local wallet, and the new password decrypt the wallet on the server.

![](user-flows-diagrams/diagram-6.svg)

<details><summary>source</summary>

```mermaid
classDiagram

DeviceOff --|> AppStartLogin : Start App - Normal
AppStartLogin --|> LoggedInHomeScreen : Log In - No password change on server
AppStartLogin --|> LoggedInHomeScreen : Log In - New Password - Password change exists on server. No local wallet changes

AppStartLogin --|> GetLocalPassword : Log In - New Password - Password change exists on server, local wallet changes exist
AppStartLogin --|> GetServerPassword : Log In - Old Password - Password change exists on server

GetLocalPassword --|> LoggedInHomeScreen : Log In - Old Password
GetServerPassword --|> LoggedInHomeScreen : Log In - New Password

DeviceOff : Start App()
AppStartLogin : Log In()
LoggedInHomeScreen : ...
GetLocalPassword : Looks like you have some changes that you haven't pushed.
GetLocalPassword : Enter your old password to unlock your wallet so it can be pushed.
GetLocalPassword : Log In()
GetServerPassword : Looks like you changed your password from another device.
GetServerPassword : Enter your new password.
GetServerPassword : Log In()
```

</details>

# Change Server

![](user-flows-diagrams/diagram-7.svg)

<details><summary>source</summary>

```mermaid
classDiagram

LoggedInHomeScreen --|> ChangeServer : Change Server
ChangeServer  --|> BadServer : Confirm - Bad Server
ChangeServer  --|> ChangeServerConfirmation : Confirm - Success
BadServer --|> ChangeServer : Try Again
ChangeServerConfirmation --|> LoggedInHomeScreen : Confirm

LoggedInHomeScreen : Trending Videos
LoggedInHomeScreen : Make Changes()
LoggedInHomeScreen : Check Visual Hash()
LoggedInHomeScreen : Change Password()
LoggedInHomeScreen : Change Server()

ChangeServer : We don't trust the server you were at.
ChangeServer : Gather all of your devices and confirm visual hash to make sure they're all synced first
ChangeServer : - visual hash -
ChangeServer : * [New Server URL]
ChangeServer : Confirm()

ChangeServerConfirmation : Confirm new visual hashes to confirm new server
ChangeServerConfirmation : - visual hash -
ChangeServerConfirmation : Confirm()

BadServer : Server Invalid
BadServer : Try Again()
```

</details>
