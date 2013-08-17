users-augment Cookbook
======================

[![Build Status](https://travis-ci.org/modcloth-cookbooks/users-augment.png?branch=master)]
(https://travis-ci.org/modcloth-cookbooks/users-augment)

**NOTE:** This functionality is intended to eventually be submitted as a
pull request to the [canonical `users`](https://github.com/opscode-cookbooks/users)
cookbook, but for now, it will remain here.

## High Level Overview

### Summary

Using Chef for user management is handy, especially if you are already
using Chef for infrastructure automation.  However, Chef-based user
management tends to suffer from one problem: user management is
generally part of a base role and is therefore the same accross all
machines in a given Chef organization.

This cookbook aims to alleviate this issue by providing an easy way to
augment user access at a more granular level.  This can be as specific
as giving certain users root access on an individual machine or more
general like setting application-user access for all machines that
fulfill a given role.

### Design Goals

This project has a few important design goals.  `users-augment` is...

* **Unobtrusive:** It modifies your base role, but only by one line.
* **Controlled:** You can add users but users can't add themselves.
  Access to your Chef org is still rquired to enable `users-augment`
* **Dependency-Free:** It doesn't depend on any other cookbooks, so it's
  easy to add and easy to remove.
* **Flexible:** User access requirements vary quite a bit from machine
  to role to organization, and `users-augment` aims to be as
accomodating as possible.

## Detailed Usage

`users-augment` requires three steps:

0. Add the recipe to your base role
0. Create your `augment_keys` data bag
0. Add attributes to nodes or roles to set access

### 1. Add the Recipe

First, add the `default` recipe to your base role.  Don't worry - if you
don't tell it to modify any users, it won't.

```ruby
name 'example-base'
description 'This is an example base role.'

run_list(
  'role[youroperatingsystem]',
  'recipe[users-augment]',
  # ... other stuff
)  
```

### 2. Create Your Keys

To maintain simplicity, `users-augment` searches for a single data bag
in your `users` bag named `augment_keys`.  For each key/value pair in
this bag, the key is the name of the user or group, and the value is
either a string or an array of strings containing your ssh public keys.

**NOTE:** While creating groups of users in either your `augment_keys`
bag or by way of a role is completely possible, it is not recommended.
One potential problem with semi-manual user management is that it can be
difficult to keep track of when your users should *no longer* have
access to your machines (i.e. if they leave the team or company).  The
more groups you have that user in, the more likely it is that you
accidentally leave their key somewhere and therefore create a security
hole.  Instead, it is recommended that you insert each user into the
`augment_keys` file individually.  That way, if you need to remove a
user's access, you can simply remove their entry in that file (assuming
all of your machines are converging).

A key file would look something like this:

```javascript
{
  "id": "augment_keys", // this is the most important part
  "alice": "bobskey123",
  "bob": "joeskey456",
  "and-a-third-user": "that-third-user_s-key"
}
```

### Add attributes to your nodes

For example:

```javascript
{
  // ... other attributes
  "users_augment": {
    "root": {
      // you can specify the path to authorized_keys
      "authorized_keys_path": "/root/.ssh/authorized_keys",
      "users": {
        "alice",
        "bob"
      }
    },
    "appuser": {
      // if you don't specify the path to authorized_keys,
      // it is assumed to be /home/<username>/.ssh/authorized_keys
      "users": {
        "and-a-third-user"
      }
    }
  }
}
```

In this scenario, alice and bob can log in as the `root` user, and
and-a-third-user can log in as `appuser`


*NOTE:* It may be advantageous to use roles for pre-defined
`users_augment` attribute sets.

## Contributing

See [CONTRIBUTING](CONTRIBUTING.md)

## License and Authors

See [LICENSE](LICENSE.txt) and [AUTHORS](AUTHORS.md)
