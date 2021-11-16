# Overview

Conflict resoultion is invoked under clearly defined conditions: a LBRY client is presented with two _sets of changes_ to the wallet, based on a known common previous version. The source of these changes could be an updated wallet from a backup service (ultimately from another client), or it could be based on changes done locally.

(TODO - the "common base" part may not be right. But we should have two diffs at very least. But also... the entire history matters? Otherwise what if you unsubscribe then subscribe again. The diff would be as if nothing happened.)

This document describes how these changes are resolved. Two sets of changes are passed in, and one resolved change is produced. This document does *not* describe the conditions and methods for gathering these changes.

The state change document handles the conditions under which a conflict resolution should occur, and exactly what the changes are (which version of the wallet to compare as a baseline, etc). The goal is to abstract these things out so that this document can concern itself with the contents of the wallet indepenently. The two exceptions to this are the `sequence` number which the state change document needs to determine the baseline version, and any data that could invalidate a wallet prima facie (malformed json, change in loginPrivateKey, etc).

## Inputs

TODO (full wallets? diffs? common base? etc etc)

## Complication

The challenge of Conflict Resolution comes down to User Experience design. Otherwise, there could be a very simple, degenerate solution: let the user resolve it in a text editor. This would only be preferable to some advanced users.

Where possible, there should be no user interaction at all. Where user interaction is necessary, it should be as simple as possible. This requires enumerating cases and strategies.

## Delicacy

At the same time, we are working with delicate user data. Data loss could be catastrophic, which means we have to limit our mistakes. Data exposure could be catastrophic, which means we cannot ever see what we're working on, nor can we simply reach into a database to manually fix mistakes. One solace is that that we could (on the state change level) have a plan to restore to previous versions.

## Approach

Because our task is delicate, we will restrict ourselves to _simply_ defined cases resolution strategies. Our final case, after all other cases fail to apply, will need to be a catch-all. The strategy for the catch-all is a last resort: either clobbering one change or the other, or (for advanced users) asking the user to resolve the conflict manually.

The major benefits of this approach are that simplicity reduces the chance of mistakes with simple cases, and we can keep a simple UI for (hopefully) a lot of conflicts that occur.

The major cost is that there would be many changes to enumerate (taking our time) or leave out (limiting UX). As we add more to the wallet schema, our burden increases here.

# Tiers of resolution strategies

We will employ different strategies for different types of conflicts. These strategies fit into three categories:

## No-Input:

* Changes that we fully understand
* Each case simply and individually enumerated
* The correct resolution is _unambiguous_
* The user should be none the wiser about the existence of the conflict

## Basic Confirmation

* Changes that we fully understand
* Each case simply and individually enumerated
* The correct resolution is _ambiguous_
* The user should be given a _simple_ prompt to resolve it

## Advanced

* Changes that we don't fully understand (or have not yet been enumerated above)
* No enumeration because we can't anticipate them
* The correct resolution is _ambiguous at best_
* The user should be given three options:
  * "Accept the version created at X time on Y device"
  * "Accept the version created at Z time on this device"
  * "Advanced: Resolve Manually"

# No-Input Strategies

## Case: No Changes

* No changes to accept

## Case: Only one side has changes

* All changes should be accepted

## Case: Both sides only subscribe

Case:

* wallet1: User subscribes to channel(s) Xs and channel(s) Ys
* wallet2: User subscribes to channel(s) Xs and channel(s) Zs

Strategy:

* Subscribe to Ys and Zs, as they are independent from other changes
* Subscribe to Xs, as they were subscribed to on both devices

## TODO: Get feedback before taking the time to add more cases

# Basic Confirmation Strategies

## Case: Both sides only subscribe and unsubscribe

Case:

* wallet1: User subscribes to channel(s) Xs and channel(s) Ys, unsubscribes from channel(s) As and channel(s) Bs.
* wallet2: User subscribes to channel(s) As and channel(s) Cs, unsubscribes from channel(s) Xs and channel(s) Zs.

Strategy:

* Subscribe to Ys and Zs, as they are independent from other changes
* Unsubscribe from Bs and Cs, as they are independent from other changes
* Prompt the user to ask which channels among As and Xs they would like to be subscribed to, as the changes between the devices are in contradiction.

Alternate idea: Arguably, subscribing is safer than unsubscribing. We could resolve this by subscribing to all Ys.

## TODO: Get feedback before taking the time to add more cases

# Advanced

Anything not enumerated by the other strategies should be covered here. We should not enumerate anything here. We should handle it in a generic, dumb way.

To be safe, even if two unknown changes don't clobber each other, we should alert the user about both of them in case their functionality conflicts in some way.

The user interface would give three options:

* "Accept the version edited from time X to time Y on device Z (click here to see difference)"
* "Accept the version created from time A to time B on this device (click here to see difference)"
* "Manually resolve (Warning: advanced and dangerous)"

The "difference" that you can see for each altered version would be a well formatted text diff of the json.

The "manually resolve" option would let an advanced user do a basic diff merge. We would inform the user that this is useful if something important is being merged, and that they could get some help here from the community (though they should not share any secrets).

# Possible Intermediate:

Making the "Advanced" case more user friendly in a _safe way_ would be difficult, given the boundless possibilities. But maybe we could do something.

Even for cases that we can't catch with enumerations, maybe we can *in some cases* reliably represent things to the user without resorting to a diff. Ex:

Instead of:

   "unknown-field": {
--   "value": 1
 +   "value": 2
+    "value": 3
   }

We might show the user:

There are changes between these wallets.

Previously we had:

`unknown-field`.'value` = 1

On this app, you set this value:

`unknown-field`.'value` = 2

On a different app, you set this value:

`unknown-field`.'value` = 3
