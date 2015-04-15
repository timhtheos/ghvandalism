# **ghvandalism**

## *Github History Vandalism bash automated*

## Intro

Similar to [Gitfiti](https://github.com/gelstudios) and [Pokrovsky](http://pokrovsky.herokuapp.com/), this does the same.

Text decorate your github account's commit history calendar by (blatantly) abusing git's ability to accept commits in the past, and in effect, creating a text-based graffiti.

**Example screenshots:**

![](https://www.evernote.com/shard/s479/sh/48cb6dd5-872d-440b-a0b3-81d9b3b0ec10/4f4d50637ba74824ba55c365c6f0f981/deep/0/timhtheos-(Timothy)---GitHub.png)
![](https://www.evernote.com/shard/s479/sh/91d78147-eda8-4651-8612-678590ccf46e/780a094378f36db0e7532b9c76092fb8/deep/0/timhtheos-(Timothy)---GitHub.png)

## Background History

[Gelstudios](https://github.com/gelstudios)' [Gitfiti](https://github.com/gelstudios/gitfiti) is written in python.  You have to fork it locally, and then run `gitfiti.py` and manually provide your github credentials there to generate commits.

[Pokrovsky](http://pokrovsky.herokuapp.com/) is a web service that provides web API to generate a bash file that can be ran locally. It owes a lot from Gitfiti.

#### Limitations
1. With gitfiti, it's python dependent, and you have to type your credentials each generate of the graffiti.
2. With Pokrovsky, it's much easier, but it does not (same with gitfiti) create and delete github repositories.

#### Solution
Automation - where both of them ends, this script begins.

1. You supply your github credentials.
2. This will pull Auth Token via github dev API with permission to create `repo` and `delete_repo`.
3. This creates a repository in your github account, as well as deletes it when you generate new graffiti.
4. This uses Pokrovsky web service. I opt to use this service vs using the original gitfiti.

## Use Case

After you vandalised your github history using either of the abovementioned, you will soon realize that as days and weeks pass by, the `graffiti` is cut off at the left part of it - because it's moving to the left direction, as it is crafted in commits history and history is growing old as time and days pass by.

To update the graffiti, you need to delete the repository, and create a new one, and generate new commits containing dates that form the new `graffiti`.

This script automates it with a `config.info` file that is ignored in git's `.gitignore` file.  So you should not bother yourself with this file.

## Dependencies

Unfortunately, I was not able to write pure bash to handle the automation.  This shell script uses the following, as dependency:

1. curl
2. **jq** - is a lightweight and flexible command-line JSON processor.  For installation, go to their [website](http://stedolan.github.io/jq/)'s [download](http://stedolan.github.io/jq/download/) page.

## How to use
1. Clone this repository
  ```
  git clone --depth=1 https://github.com/timhtheos/ghvandalism.git
  cd ghvandalism
  ```

2. Run `install.sh` file with 1 argument
  ```
  bash install.sh <arg1>
  ```

  `<arg1>` shall be the text to convert into graffiti, e.g.
  ```
  bash install.sh ILOVEU
  ```

  The text shall not exceed 6 characters.  If you provide more than 6 characters, it won't throw an error, but all characters after the 6th character won't appear in the graffiti.

  If you provide 2 words, such as `@ 2015`, have them double quoted, e.g. **"@ 2015"**.  Also please note that a space ` ` is counted as one character.

  **Notice:**  The first time you run install.sh, it will do the following:
  2.1 It will ask you to input your github username, password, and repository.
    
    The `username` shall be the one from the URL of your github profile, not the email address associated to your account.

    The repository, may not exist. But it is recommended that you provide a repositoy that does not exist yet. install.sh will delete existing repositories and replace it with an empty one. If you happen to set an existing important repository, it will be deleted, and it cannot be undone.

    This prompt (asking for github credentials) happens once. Shold you decide to reset, just delete your `config.info` file.

  2.2 It will create a config.info file and write in it the information you entered above.

  2.3 It will generate github auth token, and set an initial auth_note_suffix to 0. In case auth_token failed, it will return `null` and `install.sh` will re-run itself, also passing the first argument used. It will continue to re-run until auth_token is generated. Each re-run, auth_note_suffix is incremented.
  
3. (OPTIONAL) Make sure that your install.sh file is executable
  ```
  chmod u+x install.sh
  ```
  
  This has actually been committed in 66c42b66c0eeeacfbb4632b4966b052191527b5e, but just to make sure.

4. To change the text graffiti, just do step 2 again.

## Todos and Improvements

  I shall catch curl error when it timeout.
  Among others.

## Credits
* [Gelstudios](https://github.com/gelstudios)' [Gitfiti](https://github.com/gelstudios/gitfiti)
* [Pokrovsky](http://pokrovsky.herokuapp.com/) web service
* and the one who introduced me to gitfiti
