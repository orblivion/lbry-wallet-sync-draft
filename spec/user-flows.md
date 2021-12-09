# Initial Setup

![](user-flows-diagrams/diagram-1.svg)

<details><summary>source</summary>

```mermaid
classDiagram

LoggedOutHomeScreen --|> Signup : Set Up Account
Signup --|> LoggedInHomeScreen : Sign Up - Success
Signup --|> SetupLogin : I already have an account

Signup --|> SignupErrorCredentials : Sign Up - Bad Credentials
SignupErrorCredentials --|> Signup : Try Again

Signup --|> SignupErrorEmailExists : Sign Up - Email Exists On Server
SignupErrorEmailExists --|> Signup : Sign up with a different email address
SignupErrorEmailExists --|> SetupLogin : Log In Instead

Signup --|> SignupErrorPubKeyExists : Sign Up - Wallet PubKey Exists On Server with different Email
SignupErrorPubKeyExists --|> SetupLogin : Log In Instead

Signup --|> SignupErrorPubKeyEmailExists : Sign Up - Wallet PubKey Email Pair Exists On Server
SignupErrorPubKeyEmailExists --|> SetupLogin : Log In Instead

LoggedOutHomeScreen : Trending Videos
LoggedOutHomeScreen : Set Up Account()

LoggedInHomeScreen : ...

Signup : Enter Credentials
Signup : * [Server]
Signup : * [Email]
Signup : * [Password]
Signup : -
Signup : Warnings
Signup : * Wallet goes on server, but it's encrypted
Signup : * Don't lose your password! We have *no* recovery options without it.
Signup : * Make your password strong. Don't trust the server!
Signup : Sign Up()
Signup : I already have an account()

SignupErrorCredentials : Possible Errors
SignupErrorCredentials : * Server Invalid
SignupErrorCredentials : * Email Malformed
SignupErrorCredentials : * Password Not Good Enough
SignupErrorCredentials : Try Again()

SignupErrorPubKeyExists : An account with your wallet, but not the email you entered, already exists
SignupErrorPubKeyExists : Note to user
SignupErrorPubKeyExists : * Change email later if you want, after you log in
SignupErrorPubKeyExists : Log In Instead()

SignupErrorPubKeyEmailExists : An account with your wallet and this email already exists
SignupErrorPubKeyEmailExists : Log In Instead()

SignupErrorEmailExists : This email already exists on this server
SignupErrorEmailExists : Log In Instead()
SignupErrorEmailExists : Sign up with a different email address()

SetupLogin : ...
```

</details>

# Account Recovery

![](user-flows-diagrams/diagram-2.svg)

<details><summary>source</summary>

```mermaid
classDiagram

SetupLogin --|> MergeLoggedInLoggedOut : Log In - Existing pre-login local changes
SetupLogin --|> DataError : Log In - Data Error
SetupLogin --|> LoggedInHomeScreen : Log In - No existing pre-login local changes

MergeLoggedInLoggedOut --|> LoggedInHomeScreen : Discard logged out changes
MergeLoggedInLoggedOut --|> LoggedInHomeScreen : Merge logged out changes
MergeLoggedInLoggedOut --|> LoggedOutHomeScreen : Cancel login

LoggedInHomeScreen : ...
LoggedOutHomeScreen : ...

MergeLoggedInLoggedOut : Before you logged in, you took some actions that were saved to your wallet. Would you like to merge them?
MergeLoggedInLoggedOut : - this is a complicated part -
MergeLoggedInLoggedOut : - this is unlike normal conflict resolution because the baseline is zero, and also the logged out wallet's keypair is discarded -
MergeLoggedInLoggedOut : Discard logged out changes()
MergeLoggedInLoggedOut : Merge logged out changes()
MergeLoggedInLoggedOut : Don't log in for now()

DataError : Possible Errors
DataError : * Corrupt wallet JSON
DataError : * Signature does not match
DataError : * Sequence error
DataError : - This might be Error Recovery Mode, or Error Recovery Mode may be split off from here -
DataError : - this is a complicated part -
DataError : ????()

SetupLogin : Enter Credentials
SetupLogin : * [Server]
SetupLogin : * [Email]
SetupLogin : * [Password]
SetupLogin : Log In()
```

</details>

# Set Up Additional Device

The only difference between this and Account Recovery is that there is another device connected somewhere. The one place this could change the flow is if that device pushes a change while this device is in the middle of MergeLoggedInLoggedOut.

![](user-flows-diagrams/diagram-3.svg)

<details><summary>source</summary>

```mermaid
classDiagram

SetupLogin --|> MergeLoggedInLoggedOut : Existing pre-login local changes
SetupLogin --|> LoggedInHomeScreen : No existing pre-login local changes

MergeLoggedInLoggedOut --|> LoggedInHomeScreen : Discard logged out changes
MergeLoggedInLoggedOut --|> LoggedInHomeScreen : Merge logged out changes
MergeLoggedInLoggedOut --|> LoggedOutHomeScreen : Cancel login

MergeLoggedInLoggedOut --|> MergeLoggedInLoggedOut : Other device pushed an update in the middle of merging

LoggedInHomeScreen : ...
LoggedOutHomeScreen : ...

MergeLoggedInLoggedOut : ...

SetupLogin : ...

```

</details>

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
