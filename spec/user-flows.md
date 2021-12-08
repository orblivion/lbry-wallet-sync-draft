# Initial Setup

![](user-flows-diagrams/diagram-1.svg)

<details><summary>source</summary>

```mermaid
classDiagram

LoggedOutHomeScreen --|> Signup : Set Up Account
Signup --|> LoggedInHomeScreen : Sign Up - Success
Signup --|> Login : I already have an account

Signup --|> SignupErrorCredentials : Sign Up - Bad Credentials
SignupErrorCredentials --|> Signup : Try Again

Signup --|> SignupErrorEmailExists : Sign Up - Email Exists On Server
SignupErrorEmailExists --|> Signup : Sign up with a different email address
SignupErrorEmailExists --|> Login : Log In Instead

Signup --|> SignupErrorPubKeyExists : Sign Up - Wallet PubKey Exists On Server with different Email
SignupErrorPubKeyExists --|> Login : Log In Instead

Signup --|> SignupErrorPubKeyEmailExists : Sign Up - Wallet PubKey Email Pair Exists On Server
SignupErrorPubKeyEmailExists --|> Login : Log In Instead

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

Login : ...
```

</details>

# Account Recovery / Login

![](user-flows-diagrams/diagram-2.svg)

<details><summary>source</summary>

```mermaid
classDiagram

Login --|> MergeLoggedInLoggedOut : Log In - Existing pre-login local changes
Login --|> DataError : Log In - Data Error
Login --|> LoggedInHomeScreen : Log In - No existing pre-login local changes

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

Login : Enter Credentials
Login : * [Server]
Login : * [Email]
Login : * [Password]
Login : Log In()
```

</details>

# Set Up Additional Device

The only difference between this and Recovery / Login is that there is another device connected somewhere. The one place this could change the flow is if that device pushes a change while this device is in the middle of MergeLoggedInLoggedOut.

![](user-flows-diagrams/diagram-3.svg)

<details><summary>source</summary>

```mermaid
classDiagram

Login --|> MergeLoggedInLoggedOut : Existing pre-login local changes
Login --|> LoggedInHomeScreen : No existing pre-login local changes

MergeLoggedInLoggedOut --|> LoggedInHomeScreen : Discard logged out changes
MergeLoggedInLoggedOut --|> LoggedInHomeScreen : Merge logged out changes
MergeLoggedInLoggedOut --|> LoggedOutHomeScreen : Cancel login

MergeLoggedInLoggedOut --|> MergeLoggedInLoggedOut : Other device pushed an update in the middle of merging

LoggedInHomeScreen : ...
LoggedOutHomeScreen : ...

MergeLoggedInLoggedOut : ...

Login : ...

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

To simplify the flow, we don't allow the user to initiate a password change on their device while that device has unmerged changes to their wallet. This way, if another device pushes a change, it can be trivially merged before applying the password change and pushing it back to the server.

However, if another device pushes a different password change (B), we have to cancel the password change (A) on this device. This is because we need the user to input password B first. We need password B to know if there are any changes to the wallet in addition to the password. During the process we invite the user to change the password to A again after if they want, but we leave it to them.

![](user-flows-diagrams/diagram-5.svg)

<details><summary>source</summary>

```mermaid
classDiagram

LoggedInHomeScreen --|> ChangePassword : Change Password - *only if no un-merged changes present*
ChangePassword --|> BadPassword : Submit - Bad Password
ChangePassword --|> ChangePasswordPreempted : Submit - Another device updated the password
ChangePasswordPreempted --|> ConfirmPassword : Resolve Changes
ChangePassword --|> LoggedInHomeScreen : Submit - Success
BadPassword --|> ChangePassword : Try Again

LoggedInHomeScreen --|> ConfirmPassword : Other device changes password
ConfirmPassword --|> IncorrectPassword : Submit - Incorrect
ConfirmPassword --|> LoggedInHomeScreen : Submit - Success
IncorrectPassword --|> ConfirmPassword : Try Again

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
ChangePasswordPreempted : Resolve Changes()

ConfirmPassword : Enter Credentials
ConfirmPassword : * [Password]
ConfirmPassword : Submit()

IncorrectPassword : Password Does Not Match
IncorrectPassword : Try Again()

```

</details>


# Change Server

![](user-flows-diagrams/diagram-6.svg)

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
