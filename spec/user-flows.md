# Initial Setup

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
    Signup1[<h3>Enter Credentials</h3><ul><li>Server URL</li><li>Email</li><li>Password</li></ul>]
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

# Account Recovery

```mermaid
flowchart TD
  classDef start fill:#8f8;
  classDef finish fill:#f88;
  classDef editorNote fill:#CCC;
  Login:::start
  LoggedInHomeScreen:::finish
  LoggedOutHomeScreen:::finish
  DataError:::finish
  MergeLoggedInLoggedOut3:::editorNote
  DataError3:::editorNote

  Login --<big><b>Log In</b></big> - <i>Existing pre-login local changes</i>--> MergeLoggedInLoggedOut
  Login --<big><b>Log In</b></big> - <i>Data Error</i>--> DataError
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
    Login1[<h3>Enter Credentials</h3><ul><li>Server URL</li><li>Email</li><li>Password</li></ul>]
    Login2[<h3>Buttons</h3><ul><li>Log In</li></ul>]
  end
```

# Set Up Additional Device

The only difference between this and Account Recovery is that there is another device connected somewhere. The one place this could change the flow is if that device pushes a change while this device is in the middle of MergeLoggedInLoggedOut.

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

# Recover with existing wallet file

TODO

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

TODO - consider "Periodic Get Wallet" that doesn't lead to data error. If there's no merge conflict, there's no user interaction to model (though we should leave a note about it). What about if there is a conflict? I guess we skip that, because we should instead follow the "make changes" path, since we want to push ASAP, right?

TODO - other buttons. Change Password, etc? Or is that not this flow?

```mermaid
flowchart TD
  classDef start fill:#8f8;
  classDef finish fill:#f88;
  classDef editorNote fill:#CCC;

  LoggedInHomeScreen:::start
  DataError:::finish
  MergeChanges3:::editorNote

  LoggedInHomeScreen --<big><b>Make Changes</b></big> - <i>Change committed to server</i>--> LoggedInHomeScreen
  LoggedInHomeScreen --<big><b>Make Changes</b></big> - <i>Conflict on server</i>--> MergeChanges
  LoggedInHomeScreen --<big><b>Periodic Get Wallet</b></big> - <i>Data Error</i>--> DataError
  LoggedInHomeScreen --<big><b>Check Visual Hash</b></big>--> VisualHash
  VisualHash --<big><b>Go Back</b></big>--> LoggedInHomeScreen

  MergeChanges --<big><b>Commit Merge</b></big> - <i>Other device pushed an update during MergeChanges</i>--> MergeChanges
  MergeChanges --<big><b>Commit Merge</b></big> - <i>Merge committed to server</i>--> LoggedInHomeScreen
  MergeChanges --<big><b>Commit Merge</b></big> - <i>Too many network errors, giving up for now</i>--> LoggedInHomeScreen
  MergeChanges --<big><b>Commit Merge</b></big> - <i>Data Error</i>--> DataError

  subgraph MergeChanges
    direction RL
    MergeChanges1[<h3>Prompt</h3>Merge changes that were made here and at least one other device without rebasing]
    MergeChanges2[<h3>Buttons</h3><ul> <li>Commit Merge</li> </ul>]
    MergeChanges3[<i>this is a complicated part</i>]
  end

  subgraph LoggedInHomeScreen
    direction RL
    LoggedInHomeScreen1[<h3>Trending Videos</h3>]
    LoggedInHomeScreen2[<h3>Buttons</h3><ul> <li>Make Changes</li> <li>Check Visual Hash</li> <li>Change Password</li> <li>Change Server</li> </ul>]
  end

  subgraph DataError
    direction RL
    DataError1[<h3>Data Error</h3>...]
  end

  subgraph VisualHash
    direction RL
    VisualHash1[<h3>Prompt</h3>Confirm all of your devices are in sync]
    VisualHash2[<h3>visual hash</h3>...]
    VisualHash3[<h3>Buttons</h3><ul><li>Go Back</li></ul>]
  end

```

# Change Password

Password changes will happen in the same line as other changes to the walletState:

* A password change (with no other changes) will add a new walletState with a new sequence.
* As with any other walletState changes, it will be necessary to pull and merge the latest walletState before pushing a password change.

## Summary

Now that we have wallet content changes _and_ password changes, we will have a lot of different user screens to consider in the diagrams below.

We can summarize the situation as a simple heirarchy, albeit with some nuanced rules. Sometimes a rule prevents an action. Sometimes a rule preempts an action with another action if remote and local actions happen concurrently. Sometimes, a rule causes an action to happen silently, without bothering the user. A higher level on this heirarchy will preempt or prevent a lower level:

### Merge in remote password change

This involves user interaction (entering the new remote password on the local device).

This change takes highest priority.

### Merge in remote wallet changes

This sometimes involves user interaction (conflict resolution, if there is a merge conflict with local wallet changes).

* Can't happen if there is a **remote password change** pending. This is by virtue of the fact that the local device can't decrypt the new remote wallet changes without knowing the new remote password.

### Push Local wallet changes

This requires no user interaction.

* Can't happen if there are **remote wallet changes** pending. We need to merge those in first. However if they merge cleanly with the local changes, it will require no user interaction.

* Can't happen while there is a **remote password change** pending. Without the new remote password, the local device can't know if there are also remote wallet changes. Besides, from this point on we don't want the local device to produce any new wallets encrypted with the old password; we want to change the local password to match the new remote password.

### Push local password change

This involves user interaction (entering a new local password).

* Can't happen while there are **local wallet changes** pending: It's forbidden as a rule just to keep our system simpler.

* Can't happen while there are **remote wallet changes** pending: We don't want to overwrite remote wallet changes without merging them in. However, because of our rule against local changes, we can guarantee that the merge will require no user interaction. We can pull and apply those changes silently if they come while the user is entering a new password.

* Can't happen if there is a **remote password change** pending: If the remote password changed, there might also be new remote wallet changes that we can't see without decrypting it, so we need to enter the remote new password. If the remote password changes *while* the user is creating a local password change, we will *discard* the local new password and instead adopt the remote new password. This is just to simplify the UI (for both user and developers).

## Initiating a password change

NOTE: We are assuming here that the "Change Password" button is on the home screen for simplicity. We will likely want to revise this with a settings screen.

### Simple Case

A user wants to change the password from `P0` to `P1` using Device A. They click on the Change Password button on their home screen and get a prompt. They try entering a few passwords. The first one fails because it doesn't match. The second one fails because it's not strong enough. The third one succeeds, and they go back to the home screen.

### Blocked by local wallet changes

A user wants to change the password from `P0` to `P1` using Device A. The password change button is greyed out for the moment, because there are local wallet changes that have not yet been pushed. Later, the changes have been pushed, and the button appears. The user clicks the button, changes their password successfully, and goes back to the home screen.

### Not blocked by remote wallet changes

A user wants to change the password from `P0` to `P1` using Device A. The user clicks the button and enters the new password, but they do not yet submit. They then go to Device B and make some changes to wallet content, and it gets pushed to the server. The user then submits the password they entered on Device A. At this point, the password gets submittend and the user goes back to the home screen.

Under the hood, Device A is interrupted by having to download the wallet changes from Device B before pushing the new password. However we can guarantee that there will be no need for conflict resolution, because there are no wallet changes on Device A. If there are network problems in downloading, the error can be presented to the user the same way as network problems when submitting the password.

### Canceled by remote password change

A user's current password is `P0`. They open the password change screen on both Device A and Device B. They submit `P1` on Device B. They then submit either `P1` or `P2` on Device A. At this point, Device A shows the `ChangePasswordPreempted` prompt which will inform them that the password has been changed on a different device (Device B), that the password they just entered on Device A has been discarded (though they're welcome to submit it again later), and that they now need to confirm the new password (the one submitted on Device B).

NOTE: We could sometimes simplify this for the user: If the user submits `P1` on _both_ devices, Device A would have `P1` in its memory. This could serve as the confirmation for the incoming password change created by Device B. It could skip the `ChangePasswordPreempted` and go straight back to the home screen as if nothing happened. However, we will assume that changing password simultaneously on two devices is rare in the first place. For now we will not complicate our UI design with this minor improvement in user convenience. We are only considering this edge case to make sure we have _something_ to handle it.

NOTE: We could simplify our design at the expense of the user's convenience, perhaps, by sending the user from `ChangePasswordPreempted` to the home screen instead of the password confirmation screen.

```mermaid
flowchart TD
  classDef start fill:#8f8;
  classDef finish fill:#f88;

  LoggedInHomeScreen:::finish
  LoggedInHomeScreen_:::start
  ChangePasswordPreempted:::finish

  LoggedInHomeScreen --<big><b>Change Password</b></big>-->ChangePassword
  ChangePassword --<big><b>Submit</b></big> - <i>Bad Password</i>-->BadPassword
  ChangePassword --<big><b>Submit</b></big> - <i>Another device updated the password</i>-->ChangePasswordPreempted
  ChangePassword --<big><b>Submit</b></big> - <i>Success</i>-->LoggedInHomeScreen
  BadPassword --<big><b>Try Again</b></big>-->ChangePassword

  subgraph LoggedInHomeScreen
    subgraph LoggedInHomeScreen_
      direction RL
      LoggedInHomeScreen1[<h3>Trending Videos</h3>]
      LoggedInHomeScreen2[<h3>Buttons</h3><ul> <li>Make Changes To Wallet</li> <li>Check Visual Hash</li> <li>Change Server</li> </ul>]
      LoggedInHomeScreen3[<h3>Buttons - only if local changes are synced</h3><ul> <li>Change Password</li> </ul>]
    end
  end

  subgraph ChangePassword
    direction RL
    ChangePassword1[<h3>Enter Credentials</h3><ul><li>Password</li><li>Repeat Password</li></ul>]
    ChangePassword2[<h3>Buttons</h3><ul><li>Submit</li></ul>]
  end

  subgraph BadPassword
    direction RL
    BadPassword1[<h3>Prompt</h3>Password Not Good Enough]
    BadPassword2[<h3>Buttons</h3><ul><li>Try Again</li></ul>]
  end

  subgraph ChangePasswordPreempted
    direction RL
    ChangePasswordPreempted1[<h3>Prompt</h3>Looks like you changed your password on another device.<br> You need to enter this new password on this device to continue.<br> If you still would like to change your password using this device, do so afterwards.]
    ChangePasswordPreempted2[<h3>Buttons</h3><ul><li>Accept New Password Instead</li></ul>]
  end
```

## Confirm a password changed on another device

For this section, we are assuming that there are no new remote wallet changes, only _password changes_.

### Simple Case

A user has changed the password to `P1` using Device B. The go to their home screen on Device A and see a new button: "Confirm New Password". They click it and are taken to the password confirmation screen. On their first attempt they enter `P1` incorrectly. On the second attempt they get it right and go back to the home screen.

### Multi Change Case

A user has changed the password multiple times using Device B: from `P0` to `P1` to `P2` to `P3`, while Device A has been offline. The user takes Device A online again, and sees the "Confirm New Password" button on their homescreen. They click it, enter `P3` successfully and return to the home screen.

Under the hood, any wallet on the server (assuming it's working properly) will at that point contain all of the latest data. It will be encrypted using the latest password. Previous password changes do not matter.

### Multi Change During Prompt Case

A user has changed the password from `P0` to `P1` using Device B. The user picks up Device A and sees the "Confirm New Password" screen on their homescreen. They click it, but don't enter the password yet. They realize that they prefer a different password. They go to Device B and change the password again from `P1` to `P2`. They go back to the password confirmation screen on Device A and enter `P2`. This is accepted and the user is taken back to the home screen.

Under the hood, Device A will pull the latest wallet from the server before confirming a password change. This is to check for such additional password changes. The latest password is the one that will be expected.

NOTE: This is a rare case, and it would be simpler to design and implement for the application to expect `P0` rather than pulling from the server before accepting. However, rare as this is, it may be good to avoid confusing the user. The user probably expects the most recently submitted password to work. However, this can be changed. One alternative could perhaps be to display an error on Device A and send the user to the home screen instead.

### Start from Preempted Case

A user tried to use the password change screens on both Device A and Device B at the same time, and ended up on `ChangePasswordPreempted` on Device A. From here, they are sent to the password confirmation screen. They successfully enter the password originally submitted on Device B, and return to the home screen.

### Data Error Case

The user has changed the password using Device B. On Device A, instead of seeing the "Confirm New Password" button, they see a scary looking "Sync Error" alert. They click it and find that there was a problem with the latest wallet sent by Device B, and that they need to enter Error Recovery Mode.

Under the hood: If the server presents the device with a new wallet with a password change that is _out of sequence_ for any device (see `lastSyncedById` in the [sync](sync.md) document), we want to know *before* the user enters the password. It could be a very old password that the user has forgotten, which would leave the user stuck without understanding why. For this reason, the metadata that holds the sequence data should be _unencrypted_.

```mermaid
flowchart TD
  classDef start fill:#8f8;
  classDef finish fill:#f88;

  LoggedInHomeScreen:::finish
  LoggedInHomeScreen_:::start
  ChangePasswordPreempted:::start
  DataError:::finish

  LoggedInHomeScreen --<big><b>Confirm New Password</b></big>-->ConfirmNewPassword
  ConfirmNewPassword --<big><b>Submit</b></big><br>Other device changes password<br>during ConfirmNewPassword-->ConfirmNewPassword
  ConfirmNewPassword --<big><b>Submit</b></big> - <i>Incorrect</i>-->IncorrectPassword
  ConfirmNewPassword --<big><b>Submit</b></big> - <i>Success</i>-->LoggedInHomeScreen
  IncorrectPassword --<big><b>Try Again</b></big>-->ConfirmNewPassword

  LoggedInHomeScreen --<big><b>Periodic Get Wallet</b></big><br>New password<br><i>Data Error</i>--> DataError

  ChangePasswordPreempted --<big><b>Accept New Password Instead</b></big>-->ConfirmNewPassword

  subgraph LoggedInHomeScreen
    subgraph LoggedInHomeScreen_
      direction RL
      LoggedInHomeScreen1[<h3>Trending Videos</h3>]
      LoggedInHomeScreen2[<h3>Buttons</h3><ul> <li>Make Changes To Wallet</li> <li>Check Visual Hash</li> <li>Change Server</li> </ul>]
      LoggedInHomeScreen3[<h3>Buttons - only if there is an incoming password change</h3><ul> <li>Confirm New Password</li> </ul>]
    end
  end

  subgraph ConfirmNewPassword
    direction RL
    ConfirmNewPassword1[<h3>Enter Credentials</h3><ul><li>Password</li><li>Repeat Password</li></ul>]
    ConfirmNewPassword2[<h3>Buttons</h3><ul><li>Submit</li></ul>]
  end

  subgraph IncorrectPassword
    direction RL
    IncorrectPassword1[<h3>Prompt</h3>Password Does Not Match]
    IncorrectPassword2[<h3>Buttons</h3><ul><li>Try Again</li></ul>]
  end

  subgraph ChangePasswordPreempted
    direction RL
    ChangePasswordPreempted1[<h3>Prompt</h3>Looks like you changed your password on another device.<br> You need to enter this new password on this device to continue.<br> If you still would like to change your password using this device, do so afterwards.]
    ChangePasswordPreempted2[<h3>Buttons</h3><ul><li>Accept New Password Instead</li></ul>]
  end

  subgraph DataError
    direction RL
    DataError1[<h3>Data Error</h3>...]
  end
```

## Confirm a password change along with additional changes from another device

```mermaid
flowchart LR
  Device_A<-->Server
  Server<-->Device_B
  subgraph Device_B
    direction RL
    Device_B1[<ul> <li><b>Sequence 4</b>: Wallet Changes</li> <li><b>Sequence 3</b>: Password Change</li> <li><b>Sequence 2</b>: Wallet Changes</li> <li><b>Sequence 1</b>: Wallet Changes</li> </ul>]
  end
  subgraph Device_A
    direction RL
    Device_A1[<ul> <li><b>Sequence 1</b>: Wallet Changes</li> </ul>]
    Device_A2[<b>Unmerged Local Wallet Changes</b>]
  end
```

Supposing the user has changed their password (**Sequence 3**) and made additional changes to their wallet before (**Sequence 2**) and after (**Sequence 4**), all on Device B. Device A has not yet applied anything after **Sequence 1**. The latest version of the wallet with all of these changes is on the server, encrypted with the _new_ password. Thus, when Device A receives Changes 2-4 from the server all at once, it cannot read any of them until the user enters the new password into Device A.

Meanwhile, there are unmerged local wallet changes on Device A that it cannot push until Device A is up to date. Furthermore, those changes have a conflict with the new wallet changes coming from Device B. Thus, after the user enters the new password on Device A allowing Device A to decrypt the new changes, the user will immediately need to resolve the conflict.

It's also possible that, while handling the merge conflict on Device A, the user changes the password _again_ on Device B. In this case, after completing (or cancelling) the merge conflict resolution, the user will once again be asked to enter this latest password on Device A. After this, the user will be asked to resolve the merge conflict _again_ from the beginning (this is expected to be rare, but it will simplify the design).

We can't easily prevent these scenarios. We do stop the user from changing the password while there are unmerged local changes _on the same device_, which cuts down on complication. However doing the same _across_ devices, at least at first glance, would require a protocol change that would add more complication than it alleviates. However, if there is enough demand, some more consideration could be given to finding a better solution.

Once a password change is initiated, every client will need to update its password before submitting any further changes. Thus, assuming the clients are behaving properly, the password won't ever accidentally go back.

```mermaid
flowchart TD
  classDef start fill:#8f8;
  classDef finish fill:#f88;

  LoggedInHomeScreen:::finish
  LoggedInHomeScreen_:::start

  LoggedInHomeScreen --<big><b>Confirm New Password</b></big>-->ConfirmNewPassword
  ConfirmNewPassword --<big><b>Submit</b></big><br>Other device changes password<br>during ConfirmNewPassword-->ConfirmNewPassword
  ConfirmNewPassword --<big><b>Submit</b></big><br><i>Success. This device is up to date.</i>-->LoggedInHomeScreen
  ConfirmNewPassword --<big><b>Submit</b></big><br><i>Success. However, but we've now decrypted<br>new changes that conflict with local changes</i>-->MergeChanges

  MergeChanges --<big><b>Commit Merge</b></big><br><i>Other device changes password<br>during MergeChanges<br>Merge resolution discarded.</i>-->ConfirmNewPassword
  MergeChanges --<big><b>Commit Merge</b></big> - <i>Merge committed to server</i>-->LoggedInHomeScreen

  subgraph MergeChanges
    direction RL
    MergeChanges1[<h3>Prompt</h3>Merge changes that were made here and at least one other device without rebasing]
    MergeChanges2[<h3>Buttons</h3><ul> <li>Commit Merge</li> </ul>]
    MergeChanges3[<i>this is a complicated part</i>]
  end

  subgraph LoggedInHomeScreen
    subgraph LoggedInHomeScreen_
      direction RL
      LoggedInHomeScreen1[<h3>Trending Videos</h3>]
      LoggedInHomeScreen2[<h3>Buttons</h3><ul> <li>Make Changes To Wallet</li> <li>Check Visual Hash</li> <li>Change Server</li> </ul>]
      LoggedInHomeScreen3[<h3>Buttons - only if there is an incoming password change</h3><ul> <li>Confirm New Password</li> </ul>]
    end
  end

  subgraph ConfirmNewPassword
    direction RL
    ConfirmNewPassword1[<h3>Enter Credentials</h3><ul><li>Password</li><li>Repeat Password</li></ul>]
    ConfirmNewPassword2[<h3>Buttons</h3><ul><li>Submit</li></ul>]
  end
```

## Recovering from forgetting a new password just entered.

TODO

<!--

# TODO - I just changed my password but I forgot it. I'd like to change it again.

This is just to make sure that this flow should be possible. They should never get stuck having to put in a recently entered password. Don't forget that the server can't save them.

When putting in a new password, they probably shouldn't need to put in their old password anyway, so this should be automatically covered. But perhaps we do want to ask for old password for security reasons somehow. It's not too uncommon. If that's the case, maybe we can not require it for the first hour or something?

-->

## Putting it together

Here's a graph that allows for the most complicated scenario: One one device, we change password. However, it is preempted by a password change along with other changes come from another device.

```mermaid
flowchart TD
  classDef start fill:#8f8;
  classDef finish fill:#f88;

  LoggedInHomeScreen:::finish
  LoggedInHomeScreen_:::start
  DataError:::finish

  LoggedInHomeScreen --<big><b>Change Password</b></big>-->ChangePassword
  ChangePassword --<big><b>Submit</b></big> - <i>Bad Password</i>-->BadPassword
  ChangePassword --<big><b>Submit</b></big> - <i>New password came in</i>-->ChangePasswordPreempted
  ChangePasswordPreempted --<big><b>Accept New Password Instead</b></big>-->ConfirmNewPassword
  ChangePassword --<big><b>Submit</b></big> - <i>Success</i>-->LoggedInHomeScreen
  BadPassword --<big><b>Try Again</b></big>-->ChangePassword

  LoggedInHomeScreen --<big><b>Confirm New Password</b></big>-->ConfirmNewPassword
  LoggedInHomeScreen --<big><b>Periodic Get Wallet</b></big><br>New password<br><i>Data Error</i>--> DataError

  ConfirmNewPassword --<big><b>Submit</b></big><br>New password came in-->ConfirmNewPassword
  ConfirmNewPassword --<big><b>Submit</b></big> - <i>Incorrect</i>-->IncorrectPassword
  ConfirmNewPassword --<big><b>Submit</b></big><br><i>Success</i>-->LoggedInHomeScreen
  ConfirmNewPassword --<big><b>Submit</b></big><br><i>Success, but new changes decrypted</i>-->MergeChanges
  IncorrectPassword --<big><b>Try Again</b></big>-->ConfirmNewPassword

  MergeChanges --<big><b>Commit Merge</b></big><br><i>Success, but new password came in</i>-->ConfirmNewPassword
  MergeChanges --<big><b>Commit Merge</b></big> - <i>Merge committed to server</i>-->LoggedInHomeScreen

  subgraph MergeChanges
    MergeChanges1[...]
  end

  subgraph LoggedInHomeScreen
    subgraph LoggedInHomeScreen_
      LoggedInHomeScreen1[...]
    end
  end

  subgraph ChangePassword
    ChangePassword1[...]
  end

  subgraph BadPassword
    BadPassword1[...]
  end

  subgraph ChangePasswordPreempted
    ChangePasswordPreempted1[...]
  end

  subgraph ConfirmNewPassword
    ConfirmNewPassword1[...]
  end

  subgraph IncorrectPassword
    IncorrectPassword1[...]
  end

  subgraph DataError
    direction RL
    DataError1[...]
  end
```

# Turn On Application and Log In

There is an edge case when starting the app. If _both_ of the following are true:

* A password change is waiting on the server
* There are local _unmerged_ changes on the device

then the user will need to enter both their old and new passwords on startup. The old password will decrypt the local wallet, and the new password decrypt the wallet on the server.

```mermaid
flowchart TD
  classDef start fill:#8f8;
  classDef finish fill:#f88;

  DeviceOff:::start
  LoggedInHomeScreen:::finish

  DeviceOff --<big><b>Start App</b></big> - Normal--> AppStartLogin
  AppStartLogin --<big><b>Log In</b></big> <br> <i>No password change on server</i>-->LoggedInHomeScreen
  AppStartLogin --<big><b>Log In</b></big> <br> <i>New Password <br> Password change exists on server. No local wallet changes</i>-->LoggedInHomeScreen

  AppStartLogin --<big><b>Log In</b></big> <br> <i>New Password <br> Password change exists on server, local wallet changes exist</i>-->GetLocalPassword
  AppStartLogin --<big><b>Log In</b></big> <br> <i>Old Password <br> Password change exists on server</i>-->GetServerPassword

  GetLocalPassword --<big><b>Log In</b></big> - <i>Old Password</i>-->LoggedInHomeScreen
  GetServerPassword --<big><b>Log In</b></big> - <i>New Password</i>-->LoggedInHomeScreen

  subgraph DeviceOff
    direction RL
    DeviceOff1[<h3>Buttons</h3><ul><li>Start App</li></ul>]
  end
  subgraph AppStartLogin
    direction RL
    AppStartLogin1[<h3>Buttons</h3><ul><li>Log In</li></ul>]
  end
  subgraph LoggedInHomeScreen
    direction RL
    LoggedInHomeScreen1[...]
  end
  subgraph GetLocalPassword
    direction RL
    GetLocalPassword1[<h3>Prompt</h3>Looks like you have some changes that you haven't pushed.<br>Enter your old password to unlock your wallet so it can be pushed.]
    GetLocalPassword2[<h3>Buttons</h3><ul><li>Log In</li></ul>]
  end
  subgraph GetServerPassword
    direction RL
    GetServerPassword1[<h3>Prompt</h3>Looks like you changed your password from another device.<br>Enter your new password.]
    GetServerPassword2[<h3>Buttons</h3><ul><li>Log In</li></ul>]
  end
```

# Change Server

```mermaid
flowchart TD
  classDef start fill:#8f8;
  classDef finish fill:#f88;

  LoggedInHomeScreen:::finish
  LoggedInHomeScreen_:::start

  LoggedInHomeScreen --<big><b>Change Server</b></big>--> ChangeServer
  ChangeServer  --<big><b>Confirm</b></big> - Bad Server--> BadServer
  ChangeServer  --<big><b>Confirm</b></big> - Success--> ChangeServerConfirmation
  BadServer --<big><b>Try Again</b></big>--> ChangeServer
  ChangeServerConfirmation --<big><b>Confirm</b></big>--> LoggedInHomeScreen

  subgraph LoggedInHomeScreen
    subgraph LoggedInHomeScreen_
      direction RL
      LoggedInHomeScreen1[<h3>Trending Videos</h3>]
      LoggedInHomeScreen2[<h3>Buttons</h3><ul> <li>Make Changes</li> <li>Check Visual Hash</li> <li>Change Password</li> <li>Change Server</li> </ul>]
    end
  end

  subgraph ChangeServer
    direction RL
    ChangeServer1[<h3>Prompt</h3>We don't trust the server you were at.<br>Gather all of your devices and confirm visual hash to make sure they're all synced first<br>- visual hash -]
    ChangeServer2[<h3>Enter Credentials</h3><ul><li>New Server URL</li></ul>]
    ChangeServer3[<h3>Buttons</h3><ul> <li>Confirm</li> </ul>]
  end

  subgraph ChangeServerConfirmation
    direction RL
    ChangeServerConfirmation1[<h3>Prompt</h3>Confirm new visual hashes to confirm new server<br>- visual hash -]
    ChangeServerConfirmation2[<h3>Buttons</h3><ul> <li>Confirm</li> </ul>]
  end

  subgraph BadServer
    direction RL
    BadServer1[<h3>Prompt</h3>Server Invalid]
    BadServer2[<h3>Buttons</h3><ul> <li>Try Again</li> </ul>]
  end
```
